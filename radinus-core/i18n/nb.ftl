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
menu-statistics-balance-analysis = Analyse Saldoutvikling
menu-statistics-by-category = Stat. per kategori
menu-statistics-by-assignment = Stat. per tildeling
menu-statistics-by-budget-line = Stat. per budsjettpost
menu-statistics-by-payment-mode = Stat. per betalingsmåte
menu-statistics-by-payee = Stat. per motpart og forhandler
menu-statistics-by-project = Stat. per prosjekt
menu-statistics-by-verification = Stat. per kontroll
menu-statistics-dashboard = Dashbord for transaksjoner
menu-statistics-crossed-balance = Kryssbalanse

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

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Verktøy
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
operations-column-status = Transaksjonsstatus
operation-status-pointed = Avstemt
operation-status-committed = Reservert
operation-status-planned = Planlagt
operations-column-verification = Kontroll
operation-verification-to-verify = Å kontrollere
operation-verification-verified = Kontrollert
operation-verification-doubtful = Tvilsom
operation-verification-disputed = Bestridt
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
filter-by-status = Filtrer etter status
filter-by-verification = Filtrer etter kontroll
filter-show-all = Vis alle

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
operation-field-verification = Kontroll
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
operation-clearing-date-required = En avstemt transaksjon må ha en avstemmingsdato.
operation-clearing-date-question =
    En avstemt transaksjon må ha en avstemmingsdato.
    Vil du lagre med transaksjonens egen dato, { $date }?
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
    [0] Ingen transaksjon å avstemme: utvalget er allerede avstemt.
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
operations-recurring-from = Opprett en gjentakende transaksjon fra denne transaksjonen

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
    [verification] Statistikk etter kontroll
   *[category] Statistikk etter kategori
}

statistics-axis-column = { $kind ->
    [assignment] Tildeling
    [budget-line] BudsjettPost
    [payment-mode] TransaksjonsMåte
    [payee] Motpart
    [project] Prosjekter
    [verification] Kontroll
   *[category] KategoriNavn
}

statistics-unclassified = { $kind ->
    [assignment] Uten tildeling
    [budget-line] Uten budsjettpost
    [payment-mode] Uten betalingsmåte
    [payee] Uten motpart
    [project] Uten prosjekt
    [verification] Å kontrollere
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

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Kryssbalanse
crossed-balance-window-name = Kryssbalanse
crossed-balance-column = Kategori
crossed-balance-no-data = Ingen transaksjon denne måneden for de valgte kontoene.
crossed-balance-month-question = Hvilken måned vil du arbeide med? Et tall mellom { $first } og { $last }.
crossed-balance-month-choose = Velg måned
crossed-balance-next = Neste måned
crossed-balance-previous = Forrige måned

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
export-to = Eksporter til
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Kopier cellen
copy-rows = Kopier valgte rader
copy-failed = Kunne ikke kopiere til utklippstavlen.
export-all-years-excel = Eksporter alle år til Excel
export-all-years-ods = Eksporter alle år til LibreOffice Calc
export-all-months-excel = Eksporter alle månedene i det viste året til Excel
export-all-months-ods = Eksporter alle månedene i det viste året til LibreOffice Calc
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
    [verification] Statistikk etter kontroll
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

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Analyse av saldoutviklingen
analysis-heading = Analyse av saldoutviklingen
analysis-hint = Dra over grafen med museknappen holdt nede for å se transaksjonene i den perioden.
analysis-zone = Sone:
analysis-opening = Inngående saldo:
analysis-closing = Utgående saldo:
analysis-variation = Endring:
analysis-detail-name = Saldoanalyse
analysis-detail-none = Ingen transaksjoner i denne sonen.

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
quick-check-verification = Kontroll
quick-column-date = Dato
quick-column-label = Beskrivelse
quick-column-amount = Beløp
quick-column-category = Kategori
quick-column-assignment = Tildeling
quick-column-payment-mode = Betalingsmåte
quick-column-payee = Motpart
quick-column-project = Prosjekter
quick-column-status = Status
quick-column-verification = Kontroll
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
statement-title-open = Åpne en kontoutskriftsfil (OFX, QIF, CSV)
statement-title-info = Informasjon om den åpne filen
statement-title-integrate = Før utvalget inn i kontoen
statement-title-validate = Før denne transaksjonen inn i kontoen
statement-duplicate = Advarsel, dublett: denne transaksjonen ser allerede ut til å være ført inn i databasen (Financial Institution Transaction ID finnes)
statement-no-fitid = Advarsel: denne filen gir ingen identifikator (FITID) for denne raden. En dublett vil ikke kunne oppdages.
statement-loaded = { $count ->
    [0] Denne filen inneholder ingen transaksjoner for denne kontoen.
   *[other] { $count } rader lest, hvorav { $known } allerede finnes på kontoen din.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } rader lest; ingen ligner en transaksjon som allerede finnes på kontoen din.
    [one] { $count } rader lest, hvorav én ligner en transaksjon som allerede finnes på kontoen din (samme dato, samme beskrivelse, samme beløp).
   *[other] { $count } rader lest, hvorav { $alike } ligner transaksjoner som allerede finnes på kontoen din (samme dato, samme beskrivelse, samme beløp).
}
statement-loaded-also-alike = { $alike ->
    [one] Én til ligner en transaksjon som allerede finnes (samme dato, samme beskrivelse, samme beløp).
   *[other] { $alike } til ligner transaksjoner som allerede finnes (samme dato, samme beskrivelse, samme beløp).
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
statement-qif-question = Ingenting i denne filen sier om datoen «{ $date }» er skrevet dag/måned eller måned/dag. Den betyr:
statement-qif-day-month = Dag { $day }, måned { $month } (dag/måned)
statement-qif-month-day = Dag { $day }, måned { $month } (måned/dag)
statement-qif-dates-mixed = Denne filen skriver datoene sine på to måter: «{ $first }» leses dag/måned, «{ $second }» måned/dag. Den blir ikke importert, slik at ingen dato blir feil.
statement-qif-amounts-mixed = Denne filen skriver beløpene sine på to måter: «{ $first }» med punktum, «{ $second }» med komma. Den blir ikke importert, slik at ikke noe beløp blir feil.
statement-qif-opening = Inngående saldo på { $amount } per { $date }: dette er ikke en transaksjon, den blir ikke importert.
statement-qif-opening-undated = Inngående saldo på { $amount }: dette er ikke en transaksjon, den blir ikke importert.
statement-qif-suspect = Rad { $rank }, «{ $label }» ({ $amount }), ser ut som en inngående saldo: kontroller den før du fører den inn.
statement-qif-rejected = { $count ->
    [one] Én uleselig rad blir ikke importert: { $lines }.
   *[other] { $count } uleselige rader blir ikke importert: { $lines }.
}
statement-qif-reason-date = dato
statement-qif-reason-amount = beløp
statement-qif-reason-differ = motstridende beløp
statement-qif-no-account = Denne kontoen finnes ikke lenger i filen: åpne filen på nytt.
statement-balance-unknown = ikke oppgitt i filen
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
backup-not-started = Sikkerhetskopieringen kunne ikke startes:
restore-unreadable = Denne filen er ikke et lesbart Radinus-arkiv: { $reason }
# Spørsmålet sier hva som går tapt før det går tapt. Arkivet er allerede lest
# på dette tidspunktet: det som varsles, er sikkert.
restore-question = Gjenopprette «{ $file }»? Alt nåværende innhold i databasen din blir slettet og erstattet, og det som ligger der, går tapt.
restore-done = Gjenoppretting fullført: { $accounts } kontoer og { $operations } transaksjoner.
restore-failed = Gjenoppretting er ikke mulig: { $reason }
restore-empty-fields = Tomme felt lest som nullverdi: { $count }.


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
database-too-recent = Denne databasen er lagret av en nyere versjon av Radinus (databaseversjon { $found }; denne versjonen leser til og med versjon { $supported }). Oppdater Radinus for å åpne den.
database-not-radinus = Denne filen er ikke en Radinus-database.
database-unreadable = Databasen kunne ikke leses: { $reason }
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
journal-step-restore-empty-fields = Tomme felt fylt ut ved lesing
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
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Kontoer som telles i summene: { $count } av { $total }
welcome-tile-counted = Tell denne kontoen i summene
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
preferences-branch-import = Import
preferences-leaf-verification = Kontroll
preferences-field-verification = Importerte transaksjoner:
preferences-verification-hint = «Kontrollert»: du stoler på banken din, en importert transaksjon regnes som riktig. «Å kontrollere»: hver importert transaksjon venter på kontrollen din; deretter setter du den selv til «Kontrollert» i transaksjonslisten. Innstillingen gjelder bare for kommende importer.
preferences-leaf-qif = QIF-kontoutskrifter
preferences-field-qif-order = Rekkefølge for dag og måned:
preferences-qif-order-ask = Spør meg hver gang
preferences-qif-order-day-month = Alltid dag/måned (05/03 = 5. mars)
preferences-qif-order-month-day = Alltid måned/dag (05/03 = 3. mai)
preferences-qif-order-help = Brukes bare når ingen dato i filen avgjør saken. Så snart en dato som 24/11 viser rekkefølgen, er det filen som avgjør, uansett denne innstillingen.
preferences-field-qif-label = Transaksjonens beskrivelse:
preferences-qif-label-both = Motpart + memo
preferences-qif-label-payee = Bare motpart
preferences-qif-label-memo = Bare memo
preferences-qif-label-help = Når en transaksjon har både en motpart og et memo. Har den bare det ene, er det det som brukes, uansett denne innstillingen.
preferences-qif-hint = Disse innstillingene gjelder for alle QIF-kontoutskrifter, uansett hvilken database som er åpen. «Spør meg hver gang» er det tryggeste: en fil med tvetydige datoer blir aldri lest på måfå.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Gjenopprett standardkolonner
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Vis/Skjul
columns-colour = Fargelegg kolonnen:
columns-colour-none = Ingen farge
columns-colour-red = Rød
columns-colour-orange = Oransje
columns-colour-pink = Rosa
columns-colour-pastel-green = Pastellgrønn
columns-colour-green = Grønn
columns-colour-pastel-blue = Pastellblå
columns-colour-blue = Blå
columns-colour-pastel-yellow = Pastellgul
columns-colour-yellow = Gul
preferences-leaf-columns = Tabellkolonner
preferences-table-operations-list = Transaksjonsliste
preferences-columns-reset = Tilbakestill
preferences-columns-reset-all = Tilbakestill alle
preferences-columns-done = Kolonnene har fått tilbake sitt opprinnelige oppsett.
preferences-columns-hint = Hver tabell husker rekkefølgen på kolonnene, hvilke du skjuler og bredden deres. «Tilbakestill» gir straks tabellen det opprinnelige oppsettet tilbake.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Tilbakestilling
preferences-leaf-comfort = Komfortinnstillinger
preferences-comfort-reset = Tilbakestill komfortinnstillingene
preferences-comfort-hint = Tilbakestiller kolonnene i alle tabeller, rekkefølgen og avmerkingsboksene for kontoene i startvinduet og visningsstørrelsen. Språket, valutaen og kontrollen av importerte transaksjoner berøres ikke.
preferences-comfort-question = Tilbakestille komfortinnstillingene? Tabellkolonnene, startvinduet og visningsstørrelsen går tilbake til sin opprinnelige tilstand.
preferences-comfort-done = Komfortinnstillingene er tilbakestilt.

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

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Lånesimulering
window-loan-title = Lånesimulering
loan-tab-credit = Lånet
loan-tab-afford = Klarer jeg å betale det tilbake?
loan-field-kind = Lånetype
loan-kind-consumer = Forbrukslån
loan-kind-mortgage = Boliglån
loan-field-amount = Lånebeløp
loan-field-payment = Månedlig betaling
loan-field-months = Løpetid
loan-field-rate = Fast rente
loan-field-fees = Etableringsgebyr
loan-field-insurance = Forsikring per måned
loan-unit-months = måneder
loan-unit-percent = %
loan-invalid-field = Verdien er ikke et tall: rett den for å regne på nytt.
loan-report-button = PDF-rapport
loan-monthly-table = Tabell måned for måned
loan-months-count = { $count ->
        [one] { $count } måned
       *[other] { $count } måneder
    }
loan-percent = { $value } %
loan-notice-payment-too-low = Denne betalingen dekker ikke renten: lånet ville aldri blitt nedbetalt. Løpetiden blir stående på 600 måneder.
loan-notice-too-long = Denne betalingen ville kreve mer enn 600 måneder: løpetiden blir stående på 600 måneder.
loan-figure-payment = Månedlig betaling
loan-figure-payment-insured = Betaling inkludert forsikring
loan-figure-taeg = Effektiv rente
loan-figure-interest = Rentekostnad
loan-figure-insurance = Forsikringskostnad
loan-figure-cost = Lånets totale kostnad
loan-figure-total-due = Totalt skyldig beløp
loan-figure-all-in = Totalt tilbakebetalt, inkludert forsikring
loan-part-capital = Lånebeløp
loan-part-interest = Renter
loan-part-fees = Etableringsgebyr
loan-part-insurance = Forsikring
loan-donut-cost-caption = totalt
loan-chart-cost = Hva lånet koster
loan-chart-capital = Gjenværende gjeld
loan-schedule-title = Nedbetalingsplan
loan-schedule-yearly = Nedbetalingsplan, år for år
loan-column-number = Nr.
loan-column-year = År
loan-column-date = Forfall
loan-column-payment = Betaling
loan-column-payments = Betalinger
loan-column-interest = Renter
loan-column-capital = Avdrag
loan-column-insurance = Forsikring
loan-column-remaining = Gjenværende gjeld
loan-history-label = Undersøkt periode
loan-period-last-12 = Siste 12 måneder
loan-accounts-title = Undersøkte kontoer
loan-period-title = Periode
loan-column-account = Konto
loan-column-bank = Bank
loan-column-balance = Reell saldo
loan-unavailable-no-account = Merk av minst én konto for å undersøke historikken din.
loan-unavailable-no-month = Denne perioden har ennå ingen hel måned: velg en annen.
loan-verdict-title = Kort sagt
loan-verdict-green = Gjennomførbart
loan-verdict-orange = Stramt
loan-verdict-red = Risikabelt
loan-verdict-no-income = Ingen inntekter i perioden: gjeldsgraden kan ikke beregnes.
loan-check-debt-green = Gjeldsgrad på { $ratio }: under metodens grense på { $green }.
loan-check-debt-orange = Gjeldsgrad på { $ratio }: mellom { $green } og { $red }, på grensen.
loan-check-debt-red = Gjeldsgrad på { $ratio }: over { $red }.
loan-check-effort = Betalingen på { $payment } tar { $share } av det du setter til side { $kind ->
        [good] en god måned
        [hard] en vanskelig måned
       *[usual] en vanlig måned
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] En god måned
        [hard] En vanskelig måned
       *[usual] En vanlig måned
    } gir deg ingenting til overs: betalingen på { $payment } ville gå av reserven din.
loan-check-reserve-green = Saldoen din holder seg positiv til lånet er nedbetalt.
loan-check-reserve-red = Saldoen din ville gått under null i { $month }, på grunn av dette lånet.
loan-check-reserve-sooner = Saldoen din ville gått under null i { $month }, { $count ->
        [one] én måned
       *[other] { $count } måneder
    } tidligere enn uten lånet.
loan-check-reserve-anyway = Saldoen din ville gått under null rundt { $month } også uten lånet, som knapt endrer noe.
loan-check-reserve-floor-green = Saldoen din holder seg over sikkerhetsreserven ({ $floor }) til lånet er nedbetalt.
loan-check-reserve-floor-red = Saldoen din ville gått under sikkerhetsreserven ({ $floor }) i { $month }, på grunn av dette lånet.
loan-check-reserve-floor-sooner = Saldoen din ville gått under sikkerhetsreserven ({ $floor }) i { $month }, { $count ->
        [one] én måned
       *[other] { $count } måneder
    } tidligere enn uten lånet.
loan-check-reserve-floor-anyway = Saldoen din ville gått under sikkerhetsreserven ({ $floor }) rundt { $month } også uten lånet, som knapt endrer noe.
loan-warning-deficit = Merk: i denne perioden er utgiftene dine allerede i snitt { $amount } høyere enn inntektene per måned, før noe lån.
loan-figure-reference = Sparing { $kind ->
        [good] en god måned
        [hard] en vanskelig måned
       *[usual] en vanlig måned
    }
loan-figure-tipped = Måneder lånet ville satt i minus
loan-gauge-caption = gjeldsgrad
loan-figure-income = Gjennomsnittlige inntekter per måned
loan-figure-spending = Gjennomsnittlige utgifter per måned
loan-figure-saving = Gjennomsnittlig sparing per måned
loan-figure-running = Løpende lån per måned
loan-figure-new = Ny betaling, inkludert forsikring
loan-figure-rest = Å leve for per måned
loan-figure-debt = Gjeldsgrad
loan-red-months-value = { $count } av { $total }
loan-figure-balance-now = Reell saldo i dag
loan-figure-balance-end = Beregnet saldo ved lånets slutt
loan-chart-income = Hvor gjennomsnittsinntekten din går
loan-donut-income-caption = gjennomsnittsinntekt
loan-part-spending = Løpende utgifter
loan-part-running = Løpende lån
loan-part-new = Nytt lån
loan-part-rest = Til overs
loan-part-missing = Mangler
loan-chart-history = Historikken din med dette lånet
loan-chart-history-hint = Hva som ville vært igjen hver måned etter betalingen. Knallrødt: månedene lånet ville satt i minus; blekrødt: de som allerede var det uten lånet.
loan-chart-projection = Din beregnede saldo
loan-mark-loan-end = Slutt: { $label }
loan-mark-negative = I minus
loan-mark-floor = Under reserven
loan-mark-floor-line = Sikkerhetsreserve
loan-running-title = Løpende lån som er tatt med
loan-running-column-label = Gjentakende transaksjon
loan-running-column-monthly = Per måned
loan-running-column-end = Siste betaling
loan-no-running = Ingen løpende lån funnet blant de gjentakende transaksjonene dine.
loan-period-caption = fra { $from } til { $to } ({ $count ->
        [one] { $count } måned
       *[other] { $count } måneder
    })
loan-transfers = { $count ->
        [0] Ingen overføring mellom de avmerkede kontoene dine ble funnet.
        [one] Én overføring mellom de avmerkede kontoene dine ble funnet og holdt utenfor.
       *[other] { $count } overføringer mellom de avmerkede kontoene dine ble funnet og holdt utenfor.
    }
loan-method = Gjennomsnitt over periodens hele måneder, avstemte og registrerte transaksjoner, uten overføringer mellom de avmerkede kontoene dine.
loan-report-title = Lånesimulering
loan-report-made-on = simulering av { $date }
loan-disclaimer = Veiledende simulering uten avtaleverdi. Kun bankens tilbud er bindende.
loan-tab-rules = Innstillinger for vurderingen
loan-method-optimistic = Optimistisk
loan-method-neutral = Nøytral
loan-method-severe = Streng
loan-method-line = Vurderingsmetode: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Vurderingen svarer på tre spørsmål, og hver metode stiller egne krav. Velg den som passer deg: vurderingen i fanen «Klarer jeg å betale det tilbake?» følger den. Siste linje antar at utgiftene dine øker hvert år med oppgitt prosent; betalingen ligger fast.
loan-rule-row-debt = Godtatt gjeldsgrad
loan-rule-row-reference = Referansesparing
loan-rule-row-share = Andel av sparingen betalingen kan ta
loan-rule-row-floor = Grense saldoen ikke må under
loan-rule-row-sooner = Hvis saldoen går under den også uten lånet
loan-rule-row-growth = Økning i utgiftene dine per år
loan-rule-limits = grønt opptil { $green }, oransje opptil { $red }
loan-rule-reference = { $kind ->
        [good] en god måned
        [hard] en vanskelig måned
       *[usual] en vanlig måned
    }: { $amount }
loan-rule-floor-zero = null
loan-rule-floor-cushion = én måneds utgifter: { $amount }
loan-rule-sooner = oransje hvis lånet fremskynder det med { $orange }, rødt med { $red }
loan-unit-percent-year = % per år
loan-method-optimistic-explain = Den optimistiske metoden forutsetter en god måned, godtar gjeldsgrad opptil 40 % og holder ingen reserve: den viser hva som er mulig hvis alt går bra.
loan-method-neutral-explain = Den nøytrale metoden forutsetter en vanlig måned og følger bankenes regel, 33 til 35 % gjeldsgrad: den er referansevurderingen.
loan-method-severe-explain = Den strenge metoden forutsetter en vanskelig måned og holder én måneds utgifter i reserve for det uventede: den viser hva som holder selv om det går dårlig.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Strømforbruk for et elektrisk apparat
window-appliance-title = Strømforbruk for et elektrisk apparat
appliance-device-title = Apparatet
appliance-on-title = Påslått
appliance-standby-title = I standby
appliance-field-on-watts = Effekt i drift
appliance-field-on-hours = Driftstid per dag
appliance-field-days = Bruksdager per uke
appliance-field-share = Andel av driftstiden i lavlasttimer
appliance-field-standby-watts = Effekt i standby
appliance-field-standby-hours = Standbytid per bruksdag
appliance-unit-watts = W
appliance-unit-hours = t
appliance-unit-days = av 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Står feltet tomt, varer standby resten av dagen. På dager uten bruk står apparatet tilkoblet: all den tiden regnes som standby. Er det frakoblet, er standby 0 W.
appliance-contract-title = Din avtale
appliance-field-option = Prisalternativ
appliance-option-base = Fastpris (én pris)
appliance-option-off-peak = Høylasttimer / Lavlasttimer
appliance-field-base = Pris per kWh
appliance-field-peak = Pris per kWh i høylasttimer
appliance-field-off-peak = Pris per kWh i lavlasttimer
appliance-field-off-peak-hours = Lavlasttimer per dag
appliance-contract-hint = Disse prisene gjelder bare for denne beregningen. Den lagrede tariffen stilles inn under Innstillinger › Alternativer › Verktøy.
appliance-contract-reset = Bruk den lagrede tariffen igjen
appliance-period-day = Per dag
appliance-period-month = Per måned
appliance-period-year = Per år
appliance-energy = { $value } kWh
appliance-less-than = under { $amount }
appliance-detail-title = Detaljer for ett år
appliance-column-part = Post
appliance-column-energy = Energi
appliance-column-cost = Kostnad
appliance-column-share = Andel
appliance-line-on = Påslått
appliance-line-standby = I standby
appliance-line-on-peak = Påslått, høylasttimer
appliance-line-on-off-peak = Påslått, lavlasttimer
appliance-line-standby-peak = I standby, høylasttimer
appliance-line-standby-off-peak = I standby, lavlasttimer
appliance-line-total = Totalt
appliance-chart-title = Hvor pengene går
appliance-chart-caption = per år
appliance-standby-sentence = Standby alene koster { $amount } per år: { $share } av det apparatet koster.
appliance-note-plate = Effekten som står på apparatet eller i bruksanvisningen, er et maksimum: i drift bruker de fleste apparater mindre. For et reelt tall kan du måle med en strømmåler for stikkontakt og føre inn det den viser.
appliance-note-subscription = Fastleddet er ikke tatt med: det betaler du enten apparatet er tilkoblet eller ikke.
appliance-invalid-watts = Oppgi en effekt fra 0 til 100 000 W.
appliance-invalid-hours = Oppgi en tid fra 0 til 24 timer per dag.
appliance-invalid-days = Oppgi et helt antall dager, fra 0 til 7.
appliance-invalid-share = Oppgi en andel fra 0 til 100 %.
appliance-invalid-day-overflow = Drift og standby blir til sammen mer enn 24 timer per dag.
appliance-invalid-price = Oppgi en pris per kWh fra 0 til 100.
appliance-invalid-off-peak-hours = Oppgi et helt antall lavlasttimer, fra 0 til 24.
preferences-branch-tools = Verktøy
preferences-leaf-electricity = Strømtariff
preferences-electricity-blue = Tilbake til EDFs Tarif Bleu
preferences-electricity-hint = Tariffen i avtalen din, brukt av verktøyet «Strømforbruk for et elektrisk apparat». Standard: EDFs Tarif Bleu (Frankrike) per 1. august 2026, priser inkl. avgifter, måler på 3 til 6 kVA. Disse prisene endres ofte i februar og august: skriv av dem på regningen din.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Min økonomiske buffer
window-cushion-title = Min økonomiske buffer
cushion-question = Hvis inntektene dine stoppet i morgen, hvor mange måneder ville sparepengene dine holde?
cushion-accounts-title = Kontoene dine
cushion-column-account = Konto
cushion-column-balance = Reell saldo
cushion-column-savings = Sparing
cushion-column-spending = Utgifter
cushion-accounts-hint = «Sparing»: pengene du regner med hvis uhellet er ute. «Utgifter»: kontoene de daglige utgiftene går fra.
cushion-history-label = Analysert periode
cushion-backup-label = Reserveinntekt per måned
cushion-backup-hint = Det som fortsatt ville komme inn: dagpenger, partnerens lønn … Tomt: ingen inntekt.
cushion-categories-title = Utgiftene som tas med
cushion-categories-hint = Fjern haken ved det du ville kuttet hvis uhellet er ute.
cushion-categories-empty = Ingen utgifter i denne perioden.
cushion-verdict-title = Bufferen din
cushion-targets-title = Trygghetsgrensene
cushion-projection-title = Sparepengene dine hvis uhellet er ute
cushion-projection-hint = Det som ville være igjen hver måned hvis inntektene dine stoppet i dag.
cushion-note = Et anslag basert på historikken din: utgiftene i en vanskelig måned kan avvike fra gjennomsnittet.
cushion-invalid-backup = Dette beløpet kan ikke leses: rett det for å kjøre beregningen på nytt.
cushion-no-spending-account = Kryss av for minst én «Utgifter»-konto.
cushion-no-month = Denne perioden har ennå ingen hel måned.
cushion-months = { $value } måneder
cushion-per-month = { $amount } per måned
cushion-figure-holds = Ingen grense
cushion-gauge-caption = med dekkede utgifter
cushion-verdict-short = Under tre måneder: et uventet tilbakeslag ville raskt gi deg problemer.
cushion-verdict-fair = Mellom tre og seks måneder: en grei buffer, som du bør bygge videre på hvis du kan.
cushion-verdict-solid = Seks måneder eller mer: bufferen din er solid.
cushion-verdict-holds = Reserveinntekten din dekker utgiftene dine: sparepengene dine ville ikke minke.
cushion-verdict-nothing = Ingen utgifter tatt med i perioden: det er ingenting å dekke.
cushion-tile-savings = Tilgjengelig sparing
cushion-tile-spending = Utgifter som tas med
cushion-tile-backup = Reserveinntekt
cushion-tile-burn = Sparepengene ville minke med
cushion-tile-rhythm = Sparetakt
cushion-burn-none = Ingenting
cushion-target-title = { $months } måneders utgifter: { $amount }
cushion-target-reached = Nådd.
cushion-target-date = Det mangler { $missing }. Med din sparetakt nås den rundt { $month }.
cushion-target-never = Det mangler { $missing }. Sparepengene dine har ikke vokst i perioden: i denne takten vil denne grensen ikke nås.
cushion-mark-empty = Tomt: { $month }
cushion-period = Gjennomsnitt av { $count ->
        [one] { $count } hel måned
       *[other] { $count } hele måneder
    }, fra { $from } til { $to }. { $transfers ->
        [0] Ingen overføringer mellom kontoene dine.
        [one] Én overføring mellom kontoene dine, holdt utenfor.
       *[other] { $transfers } overføringer mellom kontoene dine, holdt utenfor.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Sparemål
window-goal-title = Sparemål
goal-accounts-title = Kontoene som følges
goal-column-account = Konto
goal-column-balance = Reell saldo
goal-accounts-hint = En overføring mellom to kontoer som følges, nuller seg ut; en overføring til en konto som ikke følges, regnes som penger ut.
goal-period-label = Referanseperiode
goal-period-range = Årsintervall …
goal-range-from = fra
goal-range-to = til
goal-question-title = Spørsmålet ditt
goal-question-when = Når har jeg dette beløpet?
goal-question-amount = Hvor mye har jeg på denne datoen?
goal-question-effort = Hvor mye må jeg spare for å ha dette beløpet på denne datoen?
goal-field-target = Målbeløp
goal-field-date = Måldato
goal-field-rate = Årlig rente på sparingen
goal-field-extra = Og hvis jeg sparte mer, per måned
goal-options-hint = Tomt: ingen rente, ingenting ekstra.
goal-answer-title = Svaret
goal-chart-title = Saldoen din, i går og i morgen
goal-chart-hint = Heltrukken linje: den reelle saldoen de siste tolv månedene; stiplet: framskrivingen; skyggelagt: spennet avhengig av månedene.
goal-disclaimer = En framskriving basert på historikken din, ikke et løfte: én uforutsett hendelse kan endre alt.
goal-no-account = Kryss av for minst én konto som skal følges.
goal-no-month = Denne perioden har ennå ingen hel måned.
goal-invalid-target = Skriv inn et beløp du vil nå.
goal-invalid-date = Velg en dato fram i tid, innen de neste femti årene.
goal-invalid-rate = Skriv inn en rente fra 0 til 100 %.
goal-invalid-extra = Dette beløpet kan ikke leses: rett det for å kjøre beregningen på nytt.
goal-per-month = { $amount } per måned
goal-tile-balance = Saldo i dag
goal-tile-rhythm = Gjennomsnittlig sparetakt
goal-tile-target = Mål
goal-tile-reached = Nådd rundt
goal-tile-date = Måldato
goal-tile-projected = Framskrevet saldo
goal-tile-saved = Spart innen da
goal-tile-interest = Herav renter
goal-tile-needed = Må spares
goal-when-already = Du har allerede { $amount }: kontoene du følger, har til sammen { $balance }.
goal-when-reached = Du har { $amount } rundt { $month }, om { $months ->
        [one] én måned
       *[other] { $months } måneder
    }.
goal-when-range = Avhengig av månedene: mellom { $early } og { $late }.
goal-when-range-open = Tidligst rundt { $early }; med svake måneder ville målet ikke bli nådd.
goal-when-never = I denne takten når du ikke { $amount }.
goal-zero = Saldoen din ville falle til null rundt { $month }.
goal-amount = I { $month } ville du ha omtrent { $amount }.
goal-amount-range = Avhengig av månedene: mellom { $low } og { $high }.
goal-effort-more = For å ha { $amount } i { $month } måtte du spare { $monthly } per måned i gjennomsnitt, altså { $gap } mer enn i dag.
goal-effort-less = For å ha { $amount } i { $month } ville { $monthly } per måned holde, altså { $gap } mindre enn i dag: du ligger foran skjema.
goal-effort-range = Avhengig av månedene ville avviket fra sparetakten din ligge mellom { $low } og { $high } per måned.
goal-chart-target = Mål: { $amount }
goal-chart-today = I dag
goal-note-seasons = Framskrivingen følger årstidene: hver kommende måned bruker gjennomsnittet av de samme månedene i perioden.
goal-note-range = Spennet kommer fra de svake og sterke månedene i perioden: den laveste og den høyeste fjerdedelen.
goal-note-loan = Lånet «{ $label }» avsluttes i { $month }: deretter { $amount } mer per måned.
goal-note-interest = Renter beregnet hver måned med { $rate } % per år: en tilnærming til halvmånedsregelen for sparekontoer.
goal-period = Takten er beregnet over { $count ->
        [one] { $count } hel måned
       *[other] { $count } hele måneder
    }, fra { $from } til { $to }. { $transfers ->
        [0] Ingen overføringer mellom kontoene du følger.
        [one] Én overføring mellom kontoene du følger, holdt utenfor.
       *[other] { $transfers } overføringer mellom kontoene du følger, holdt utenfor.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = Hva om jeg kuttet…?
window-cut-title = Hva om jeg kuttet…?
cut-axis-label = Grupper etter
cut-axis-category = Kategorier
cut-axis-payee = Motparter
cut-axis-budget-line = Budsjettposter
cut-table-title = Utgiftene dine, post for post
cut-table-hint = Skriv inn et kutt i % eller i { $sign } per måned på postene du vil redusere. Et kutt kan ikke være større enn selve utgiften.
cut-column-monthly = Per måned
cut-column-cut = Kutt
cut-column-after = Etter
cut-column-yearly = Spart per år
cut-total = Totalt
cut-horizon-label = Horisont
cut-settings-title = Innstillinger
cut-options-hint = Renten og målbeløpet er valgfrie.
cut-report-button = PDF-rapport
cut-chart-title = Saldoen din, uten og med kuttene
cut-chart-hint = Heltrukken linje: den reelle saldoen de siste tolv månedene; grå stiplet: framskrivingen uten kutt; blå: med kutt; grønn: pengene du sparer.
cut-donut-title = Utgiftene dine per måned etter kutt
cut-donut-caption = per måned etter kutt
cut-donut-others = Andre poster
cut-donut-saved = Spart
cut-legend-with = Med kuttene
cut-legend-without = Uten kutt
cut-years = { $years ->
        [one] { $years } år
       *[other] { $years } år
    }
cut-headline-none = Skriv inn et kutt i tabellen for å se virkningen.
cut-headline = Ved å kutte { $count ->
        [one] denne posten
       *[other] disse { $count } postene
    } ville du sette av { $monthly } mer per måned, altså { $yearly } per år.
cut-tile-monthly = Spart per måned
cut-tile-yearly = Spart per år
cut-tile-horizon = Spart over { $years ->
        [one] { $years } år
       *[other] { $years } år
    }
cut-tile-spending = Utgifter per måned
cut-target-already = Du har allerede { $amount }.
cut-target-sooner = Du ville nå { $amount } rundt { $with } i stedet for { $without }: { $months ->
        [0] ikke tidligere
        [one] én måned tidligere
       *[other] { $months } måneder tidligere
    }.
cut-target-only-with = Med disse kuttene ville du nå { $amount } rundt { $with }; uten dem, i nåværende takt, aldri.
cut-target-never = Selv med disse kuttene ville du ikke nå { $amount } i nåværende takt.
cut-note-seasons = Hvert kutt følger årstidene til posten sin: en post som veier tyngst om sommeren, sparer mest om sommeren.
cut-note-capped = Et kutt som ble skrevet inn, var større enn utgiften: det er satt ned til selve utgiften.
cut-invalid-cut = Dette kuttet kan ikke leses: en prosent fra 0 til 100, eller et beløp per måned.
cut-report-settings = Innstillingene
cut-report-result = Resultatet
cut-report-accounts = Kontoene som følges

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Planlegg ferien min
window-holiday-title = Planlegg ferien min
holiday-trip-title = Reisen
holiday-field-trip = Reisetype
holiday-trip-stay = Opphold
holiday-trip-cruise = Cruise
holiday-field-adults = Voksne
holiday-field-children = Barn
holiday-field-nights = Oppholdets lengde, i netter
holiday-field-days = Dager
holiday-field-months = Måneder før avreise
holiday-field-stops = Antall anløpshavner
holiday-saved-title = Allerede spart
holiday-saved-hint = Kryss av for kontoene der pengene til ferien allerede er satt av: den reelle saldoen deres regnes som allerede spart.
holiday-budget-title = Budsjettet
holiday-budget-hint = For hver post: et beløp, hvem det gjelder for og hvor lenge. En tom post teller ikke.
holiday-optional-title = Valgfrie poster
holiday-result-title = Resultatet
holiday-donut-title = Hvor reisepengene går
holiday-donut-caption = for reisen
holiday-child-label = Barnepris
holiday-count-label = Lugarer
holiday-open = Åpne et prosjekt…
holiday-save = Lagre prosjektet…
holiday-pdf = PDF-rapport
holiday-excel = Eksporter til Excel
holiday-file-filter = Ferieprosjekt
holiday-replace-question = Hvis du åpner dette prosjektet, erstattes det som er skrevet inn i vinduet. Fortsette?
holiday-file-saved = Prosjekt lagret: { $file }
holiday-file-opened = Prosjekt åpnet: { $file }
holiday-file-not-project = Denne filen er ikke et ferieprosjekt fra Radinus.
holiday-file-too-recent = Dette prosjektet kommer fra en nyere versjon av Radinus: oppdater Radinus for å åpne det.
holiday-file-failed = Filen kunne ikke leses eller skrives: { $reason }
holiday-line-transport = Reise tur-retur
holiday-line-lodging = Overnatting
holiday-line-meals = Måltider og daglige utgifter
holiday-line-visits = Severdigheter og fritid
holiday-line-port = Reise til havnen
holiday-line-cabins = Lugarer
holiday-line-service = Servicepakke (driks)
holiday-line-drinks = Drikkepakke
holiday-line-excursions = Landutflukter
holiday-line-port-taxes = Havneavgifter
holiday-line-wifi = Wifi om bord
holiday-line-onboard = Utgifter om bord og i land
holiday-line-other = Andre kostnader og uforutsette utgifter
holiday-line-insurance = Avbestillingsforsikring
holiday-line-stay-tax = Turistskatt
holiday-line-car = Bil på stedet, drivstoff og bompenger
holiday-line-parking = Parkering ved flyplassen eller stasjonen
holiday-line-bank = Bankgebyrer i utlandet
holiday-line-formalities = Formaliteter (pass, visum, vaksiner)
holiday-line-pets = Dyrepass
holiday-span-trip = for oppholdet
holiday-span-night = per natt
holiday-span-day = per dag
holiday-span-stop = per anløp
holiday-who-all = for alle
holiday-who-person = per person
holiday-who-adults = per voksen
holiday-cabins-count = { $count ->
        [one] { $count } lugar
       *[other] { $count } lugarer
    }
holiday-days = { $days ->
        [one] { $days } dag
       *[other] { $days } dager
    }
holiday-invalid-count = Skriv inn et heltall.
holiday-invalid-amount = Dette beløpet kan ikke leses: et positivt tall, eller en prosent fra 0 til 100.
holiday-headline-empty = Skriv inn budsjettbeløpene for å se hva reisen vil koste.
holiday-headline-stay = Dette oppholdet ville koste { $total } for { $people ->
        [one] én person
       *[other] { $people } personer
    } og { $nights ->
        [0] ingen netter
        [one] én natt
       *[other] { $nights } netter
    }.
holiday-headline-cruise = Dette cruiset ville koste { $total } for { $people ->
        [one] én person
       *[other] { $people } personer
    } og { $nights ->
        [0] ingen netter
        [one] én natt
       *[other] { $nights } netter
    }.
holiday-tile-total = Total kostnad
holiday-tile-person = Per person
holiday-tile-person-day = Per person per dag
holiday-tile-saved = Allerede spart
holiday-tile-remaining = Gjenstår å finansiere
holiday-tile-monthly = Nødvendig sparing
holiday-remaining-none = Ingenting: det er dekket
holiday-monthly-none = Ingenting å sette av
holiday-monthly-now = Avreise denne måneden
holiday-note-days = Dagene er nettene pluss én: sju netter blir åtte dager.
holiday-note-child = Per person betaler et barn barneprisen hvis den er oppgitt; står den tom, betaler barnet som en voksen.
holiday-note-percent = En prosent for forsikringen gjelder reisens hovedposter; prosenten for bankgebyrene gjelder utgiftene på stedet.
holiday-sheet-budget = Budsjett
holiday-sheet-result = Resultat
holiday-column-line = Post
holiday-column-amount = Beløp
holiday-column-child = Barnepris
holiday-column-who = For hvem
holiday-column-span = Hvor lenge
holiday-column-cost = Kostnad
holiday-disclaimer = Et anslag basert på dine egne beløp: de faktiske prisene kan variere.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Kuttprosjekt
cut-file-not-project = Denne filen er ikke et kuttprosjekt fra Radinus.
cut-file-too-recent = Dette prosjektet kommer fra en nyere versjon av Radinus: oppdater Radinus for å åpne det.
cut-sheet-items = Poster

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Loggbok for bilen min
window-car-title = Loggbok for bilen min
car-unnamed = Bilen min
car-sheet-title = Bilen
car-field-plate = Registreringsnummer
car-field-make = Merke
car-field-model = Modell
car-field-engine = Drivlinje
car-field-first-hand = Første eier
car-field-registered = Første gangs registrering
car-field-acquired = Kjøpsdato
car-field-acquired-km = Kilometerstand ved kjøp
car-field-service = Service hver
car-field-service-or = eller hver
car-unit-months-short = mnd.
car-unit-km = km
car-tariff-title = Pris for lading hjemme
car-tariff-hint = Denne prisen lagres i bilens loggbok: den endrer ikke prisen i alternativene.
car-tariff-reset = Bruk prisen fra alternativene
car-engine-petrol = Bensin
car-engine-diesel = Diesel
car-engine-lpg = LPG
car-engine-e85 = E85 (flexifuel)
car-engine-hybrid = Hybrid
car-engine-plug-in = Ladbar hybrid
car-engine-electric = Elektrisk
car-engine-hydrogen = Hydrogen
car-energy-petrol = Bensin
car-energy-diesel = Diesel
car-energy-lpg = LPG
car-energy-e85 = E85
car-energy-electricity = Strøm
car-energy-hydrogen = Hydrogen
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energi
car-rubric-upkeep = Løpende vedlikehold
car-rubric-service = Service
car-rubric-wear = Slitedeler
car-rubric-tyres = Dekk
car-rubric-breakdown = Feil og havari
car-rubric-insurance = Forsikring
car-rubric-inspection = EU-kontroll
car-part-brake-pads = Bremseklosser
car-part-brake-discs = Bremseskiver
car-part-timing-belt = Registerreim
car-part-clutch = Clutch
car-part-battery-12v = 12 V-batteri
car-part-shock-absorbers = Støtdempere
car-part-wipers = Vindusviskere
car-part-spark-plugs = Tennplugger
car-part-glow-plugs = Gløderør
car-part-particulate-filter = Partikkelfilter
car-part-catalytic-converter = Katalysator
car-part-fuel-cell-filter = Filter for brenselcellen
car-part-exhaust = Eksosanlegg
car-part-other = Annen del…
car-axle-all = Alle fire dekkene
car-axle-front = Fordekk
car-axle-rear = Bakdekk
car-verdict-pass = Godkjent
car-verdict-counter = Etterkontroll
car-charge-station = På en ladestasjon
car-charge-home = Hjemme
car-slot-peak = Høylasttimer
car-slot-off-peak = Lavlasttimer
car-entry-new = Ny linje
car-entry-edit = Endre linjen
car-field-date = Dato
car-field-km = Kilometerstand
car-field-rubric = Post
car-field-amount = Beløp
car-field-garage = Verksted eller stasjon
car-field-note = Notat
car-field-energy = Energi
car-field-quantity = Mengde
car-field-charge = Lading
car-field-slot = Ladetidspunkt
car-field-part = Del
car-field-part-name = Navn på delen
car-field-axle = Dekk som er byttet
car-field-verdict = Resultat
car-field-months = Måneder dekket
car-field-battery = Batteritilstand
car-home-amount-hint = Beløpet for en lading hjemme regnes ut med bilens pris.
car-entry-add = Legg til i loggboken
car-entry-update = Lagre linjen
car-entry-cancel = Avbryt
car-entry-delete = Slett linjen
car-delete-question = Slette denne linjen fra loggboken?
car-from-operation = Hent en transaksjon…
car-pick-account = Hvilken konto kommer utgiften fra?
car-pick-operation = Hvilken transaksjon?
car-pick-take = Hent
car-pick-none = Ingen utgifter på denne kontoen.
car-pick-taken = Transaksjonen er hentet: fyll inn kilometerstand og post, og legg deretter til linjen.
car-history-title = Historikken
car-filter-all = Alle poster
car-history-empty = Ingen linjer ennå.
car-history-hint = Klikk på en linje for å endre den.
car-column-date = Dato
car-column-km = Km
car-column-rubric = Post
car-column-detail = Detaljer
car-column-amount = Beløp
car-column-garage = Verksted
car-column-note = Notat
car-column-share = Andel
car-column-per-km = Per km
car-column-energy = Energi
car-column-quantity = Mengde
car-column-price = Snittpris
car-column-consumption = Forbruk
car-column-part = Del
car-column-changes = Bytter
car-column-last = Siste bytte
car-column-life = Levetid
car-column-next = Neste bytte
car-total = Totalt
car-summary-title = Hva bilen koster
car-headline-empty = Fyll ut bilkortet, og legg så til en første linje: en tanking, en service, en verkstedregning…
car-headline = Siden { $since } har bilen din kostet deg { $total }.
car-headline-km = Siden { $since } har bilen din kostet deg { $total } for { $km } kjørt: { $cost } per kilometer.
car-tile-total = Total kostnad
car-tile-month = Per måned
car-tile-km = Per kilometer
car-tile-driven = Kilometer kjørt
car-tile-consumption = Forbruk
car-tile-energy-km = Energi per kilometer
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } måned
       *[other] { $months } måneder
    }
car-detail-battery = Batteri: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Per post
car-energy-title = Energien
car-parts-title = Slitedeler
car-tyres-title = Dekk
car-battery-title = Batteritilstand
car-years-title = Hva bilen har kostet hvert år
car-donut-title = Hvor pengene går
car-donut-caption = totalt
car-deadlines-title = Fristene
car-deadlines-empty = Ingen frister ennå: noter en service, en EU-kontroll, en forsikring eller to bytter av samme del.
car-deadline-service = Service
car-deadline-inspection = EU-kontroll
car-deadline-counter = Etterkontroll etter EU-kontrollen
car-deadline-insurance = Forsikringen utløper
car-when-date = den { $date }
car-when-km = ved { $km }
car-when-km-reached = ved { $km }, rundt { $month } i ditt tempo
car-when-date-km = den { $date } eller ved { $km }, det som kommer først
car-when-inspection-unknown = Noter den siste EU-kontrollen for å få vite datoen for den neste.
car-tone-late = Overskredet
car-tone-soon = Snart
car-note-since = Alt regnes fra kjøpet: datoen og kilometerstanden som er notert på bilkortet.
car-note-consumption = Forbruket måles fra full tank til full tank: fyll tanken helt og noter kilometerstanden hver gang.
car-note-e85 = En E85-bil drikker det den får: kilometerne etter en tanking regnes for det drivstoffet.
car-note-home = En lading hjemme prises med bilens pris den dagen den noteres, og beholder den kostnaden.
car-note-inspection = EU-kontrollen følger den franske regelen: den første innen fire år etter første gangs registrering, deretter hvert annet år; en etterkontroll innen to måneder.
car-disclaimer = Fristene og levetidene er anslag hentet fra loggboken: bare produsentens servicehefte er gjeldende.
car-invalid-date = Oppgi en gyldig dato som ikke ligger i fremtiden.
car-invalid-acquired = Kjøpsdatoen kan ikke være før første gangs registrering.
car-invalid-km = Oppgi en kilometerstand i hele kilometer.
car-invalid-amount = Dette beløpet kan ikke leses.
car-invalid-quantity = Skriv inn mengden: liter, kWh eller kilo.
car-invalid-part = Velg delen som er byttet, eller skriv inn navnet.
car-invalid-rubric = Velg en post.
car-invalid-months = Oppgi et helt antall måneder.
car-invalid-battery = Oppgi en batteritilstand fra 0 til 100 %.
car-open = Åpne en loggbok…
car-save = Lagre loggboken…
car-report-button = PDF-rapport
car-file-filter = Billoggbok
car-file-saved = Loggbok lagret: { $file }
car-file-opened = Loggbok åpnet: { $file }
car-file-not-logbook = Denne filen er ikke en billoggbok fra Radinus.
car-file-too-recent = Denne loggboken kommer fra en nyere versjon av Radinus: oppdater Radinus for å åpne den.
car-replace-question = Hvis du åpner denne loggboken, erstattes den som er i vinduet. Fortsette?
car-sheet-history = Loggbok
car-sheet-summary = Sammendrag

analysis-history-hint = Jo lengre historikk du har, desto bedre blir denne analysen: ideelt sett bør du ha minst ett år med transaksjoner.

# --- F48 — Del en utgift (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Del en utgift
window-sharing-title = Del en utgift
sharing-question = Hvem betaler hva?
sharing-setup-title = Delingen
sharing-field-label = Betegnelse
sharing-label-hint = For eksempel «Restaurant 12/10» eller «Bretagne-tur 2027»: den gir navn til filene og rapportene.
sharing-field-total = Totalt
sharing-total-hint = Hvis feltet står tomt, er totalen summen av postene og av hver og ens egne tillegg.
sharing-field-rule = Regel
sharing-field-rounding = Avrunding
sharing-field-people = Personer
sharing-mode-whole = Én regel for hele utgiften
sharing-mode-item = Én regel per post
sharing-rule-equal = Like deler
sharing-rule-parts = Etter andeler
sharing-rule-percent = I prosent
sharing-rule-income = I forhold til inntekt
sharing-rounding-cent = Til øre
sharing-rounding-euro = Til hele enheter
sharing-round-euro = Avrund til hele enheter
sharing-hide-incomes = Skjul inntektene i rapportene og eksporten
sharing-people-title = Personene
sharing-people-hint = Én rad per person, én kolonne per post: kryss av for hvem som deltar i hva. Alt annet er valgfritt. Noen som trekker seg og lar depositumet bli igjen: et eksakt beløp som tilsvarer det vedkommende har betalt, og ingen avkrysset rute.
sharing-add-person = Legg til en person
sharing-person-default = Person { $number }
sharing-items-title = Postene
sharing-items-hint = Bare det som ikke gjelder alle, som vinen. Resten av totalen går til den felles posten.
sharing-add-item = Legg til en post
sharing-common = Felles
sharing-payments-title = Betalingene
sharing-payments-hint = Hvem som har betalt, hvor mye og når. En rad uten beløp teller ikke ennå.
sharing-payments-none = Ingen betalinger ennå.
sharing-add-payment = Legg til en betaling
sharing-result-title = Resultatet
sharing-balances-title = Slik ligger betalingene an
sharing-transfers-title = Foreslåtte overføringer
sharing-delete = Slett
sharing-delete-person-question = Denne personen har betalinger: slette dem sammen med personen?
sharing-disclaimer = Radinus foreslår en deling: mellom venner står hver og en fritt til å gjøre opp på en annen måte.
sharing-column-person = Person
sharing-column-household = Husholdning
sharing-column-income = Inntekt
sharing-column-parts = Andeler
sharing-column-percent = %
sharing-column-floor = Minst
sharing-column-cap = Maks
sharing-column-fixed = Eksakt beløp
sharing-column-alone = Egne tillegg
sharing-column-gift = Gitt overskudd
sharing-column-share = Andel
sharing-column-typed = Oppgitt %
sharing-column-constraint = Hva som gjaldt
sharing-column-due = Å betale
sharing-column-item = Post
sharing-column-amount = Beløp
sharing-column-rule = Regel
sharing-column-participants = Deltakere
sharing-column-unit = Husholdning eller person
sharing-column-members = Medlemmer
sharing-column-paid = Betalt
sharing-column-balance = Saldo
sharing-column-date = Dato
sharing-column-who = Hvem
sharing-column-label = Betegnelse
sharing-help-household = Personer i samme husholdning gjør opp sammen: betalingene og det de skylder legges sammen, og de får én oppstilling. Eksempel: «Familien Martin» for foreldrene og barna.
sharing-help-income = Brukes bare av regelen «I forhold til inntekt»: jo høyere inntekt, desto større andel. Skriv inn månedsinntekten.
sharing-help-parts = En person med 2 andeler betaler dobbelt så mye som en person med 1 andel. Eksempel: voksen 1, barn 0,5.
sharing-help-percent = Den delen av utgiften som personen betaler. Prosentene må bli 100 % til sammen.
sharing-help-floor = Personen betaler minst dette beløpet, selv om den beregnede andelen er mindre. Differansen reduserer de andres andel.
sharing-help-cap = Personen betaler aldri mer enn dette beløpet. Det som ikke betales, faller på de andre deltakerne i personens poster.
sharing-help-fixed = Personen betaler dette beløpet uansett hva som skjer, og resten deles mellom de andre. Eksempel: noen som trekker seg og lar depositumet bli igjen.
sharing-help-alone = Det personen har tatt kun for seg selv, som en dessert eller en kaffe. Det betales fullt ut, i tillegg til andelen.
sharing-help-gift = Hvis personen har betalt mer enn sin andel: avkrysset er overskuddet en gave til gruppen, ellers blir det tilbakebetalt.
sharing-help-items = Kryss av for de som deltar i denne posten. Den felles posten er det som er igjen av totalen når de andre postene er trukket fra.
sharing-help-due = Det personen skylder til sammen: andelen av postene, egne tillegg og avrundingen.
sharing-help-share = Hva andelen utgjør, i prosent av summen som deles.
sharing-help-typed = Prosenten du oppga. Den kan avvike fra den faktiske andelen når et minimum, et maksimum eller et eksakt beløp gjaldt.
sharing-help-constraint = Viser om personens andel ble endret av et minimum, et maksimum, et eksakt beløp eller et gitt overskudd.
sharing-help-item = Bare det som ikke gjelder alle, som vinen. Resten av totalen går til den felles posten, som deles mellom de avkryssede.
sharing-help-rule = Hvordan denne posten deles: like deler, etter andeler, i prosent eller i forhold til inntekt.
sharing-help-paid = Det husholdningen eller personen allerede har betalt, ifølge de registrerte betalingene.
sharing-help-balance = Det som gjenstår å betale, eller det som er betalt utover andelen. Eksempel: «Gjenstår å betale: 61,54 €».
sharing-advice-equal = { $count ->
        [one] { $total } for én person.
       *[other] { $total } ÷ { $count } personer = { $amount } hver.
    }
sharing-advice-equal-varied = Like deler mellom dem som deltar, med hensyn til grensene og unntakene.
sharing-advice-parts = { $parts } andeler i alt: én andel er verdt { $amount }.
sharing-advice-parts-varied = Hver betaler etter sine andeler, med hensyn til grensene og unntakene. En tom rute teller som 1 andel.
sharing-advice-percent-rest = Det mangler { $rest } % for å nå 100 %.
sharing-advice-percent-over = Prosentene går { $over } % over 100 %.
sharing-advice-percent-ok = Prosentene blir nøyaktig 100 %.
sharing-advice-percent-nobody = Prosentene er allerede 100 %: { $count ->
        [one] { $names } ville ikke måtte betale noe.
       *[other] ingen av { $names } ville måtte betale noe.
    }
sharing-advice-income = Hver betaler { $rate } % av inntekten sin.
sharing-advice-income-missing = Skriv inn inntekten til hver enkelt for å dele i forhold til inntekt.
sharing-advice-income-varied = Hver betaler like stor del av inntekten sin, med hensyn til grensene og unntakene.
sharing-advice-empty = Skriv inn beløpet som skal deles.
sharing-apply-advice = Bruk de foreslåtte verdiene
sharing-help-apply-advice = Fyller de tomme rutene med de grå verdiene. Ruter som allerede er fylt ut, endres ikke.
sharing-from-incomes = Prosent ut fra inntektene
sharing-help-from-incomes = Erstatter prosentene med hver inntekts andel av de samlede inntektene. De blir 100 % til sammen.
sharing-reset-percents = Fordel alt på nytt
sharing-help-reset-percents = Tømmer prosentene og fordeler dem likt mellom alle. Nyttig etter at du har lagt til en person.
sharing-reset-percents-question = Tømme alle prosentene og fordele dem likt mellom alle?
sharing-open = Åpne et prosjekt…
sharing-save = Lagre prosjektet…
sharing-pdf-distribution = Fordeling (PDF)
sharing-pdf-payments = Betalingsstatus (PDF)
sharing-pdf-statements = Individuelle oppstillinger (PDF)…
sharing-statements-everyone = Alle
sharing-excel = Eksporter til Excel
sharing-file-filter = Delingsprosjekt
sharing-replace-question = Hvis du åpner dette prosjektet, erstattes det som er skrevet inn i vinduet. Fortsette?
sharing-file-saved = Prosjekt lagret: { $file }
sharing-file-opened = Prosjekt åpnet: { $file }
sharing-file-not-project = Denne filen er ikke et delingsprosjekt fra Radinus.
sharing-file-too-recent = Dette prosjektet kommer fra en nyere versjon av Radinus: oppdater Radinus for å åpne det.
sharing-file-failed = Filen kunne ikke leses eller skrives: { $reason }
sharing-statements-replace-question = { $count ->
        [one] Én oppstilling finnes allerede i denne mappen. Erstatte den?
       *[other] { $count } oppstillinger finnes allerede i denne mappen. Erstatte dem?
    }
sharing-statements-written = { $count ->
        [one] Én oppstilling skrevet til «{ $folder }».
       *[other] { $count } oppstillinger skrevet til «{ $folder }».
    }
sharing-too-many-people = En deling kan ha høyst 40 personer.
sharing-too-many-items = En deling kan ha høyst 20 poster.
sharing-too-many-payments = En deling kan ha høyst 400 betalinger.
sharing-invalid-amount = Dette beløpet kan ikke leses: det må være et positivt tall.
sharing-invalid-number = Dette tallet kan ikke leses: det må være et positivt tall.
sharing-invalid-percent = En prosentandel går fra 0 til 100.
sharing-invalid-date = Denne datoen kan ikke leses.
sharing-name-missing = Hver person må ha et navn.
sharing-name-duplicate = Det finnes allerede «{ $name }»: skill dem fra hverandre, for eksempel med en forbokstav.
sharing-floor-above-cap = Minimum ligger over maksimum.
sharing-item-label-missing = Denne posten har ikke noe navn.
sharing-items-above-total = Postene og hver og ens egne tillegg overstiger totalen med { $amount }.
sharing-payment-person = Velg hvem som har betalt.
sharing-percent-total = Prosentene blir { $sum } %: de må bli 100 %.
sharing-percent-total-item = «{ $item }»: prosentene blir { $sum } %: de må bli 100 %.
sharing-item-nobody = Ingen deltar i «{ $item }».
sharing-item-no-weight = Ingen veier noe i «{ $item }»: alle deltakerne står på null.
sharing-income-missing = Inntekten til { $name } mangler.
sharing-fixed-above = De eksakte beløpene overstiger summen som skal deles, med { $amount }.
sharing-floors-above = Minimumsbeløpene overstiger summen som skal deles, med { $amount }.
sharing-cap-alone = { $name } er alene om å delta i «{ $item }»: maksimum kan ikke overholdes.
sharing-caps-short = Maksimumsbeløpene er ikke nok til å dekke summen: det mangler { $amount }.
sharing-impossible = Disse vilkårene kan ikke alle overholdes: myk opp et minimum eller et maksimum.
sharing-constraint-floor = Minimum nådd
sharing-constraint-cap = Maksimum nådd
sharing-constraint-fixed = Eksakt beløp
sharing-constraint-gift = Gitt overskudd
sharing-and = { $first } og { $last }
sharing-outside = Utenfor postene
sharing-alone = Egne tillegg
sharing-rounding = Avrunding
sharing-headline-empty = Legg til personene som deler utgiften.
sharing-headline-no-amount = Skriv inn totalen, eller postene som skal deles.
sharing-headline-equal = { $total } å dele: hver betaler { $amount }.
sharing-headline-range = { $total } å dele: fra { $min } til { $max } avhengig av personen.
sharing-participants = { $count ->
        [0] Ingen deltakere
        [one] Én deltaker
       *[other] { $count } deltakere
    }
sharing-balance-due = Gjenstår å betale: { $amount }
sharing-balance-over = Har betalt { $amount } mer enn sin andel
sharing-balance-even = Oppgjort
sharing-summary-collected = { $collected } av { $total } er betalt.
sharing-summary-owing = { $count ->
        [0] Alle er oppgjort.
        [one] Bare én skylder fortsatt { $amount }.
       *[other] { $count } skylder fortsatt { $amount } til sammen.
    }
sharing-remaining-outside = Gjenstår å betale på utgiften: { $amount }
sharing-remaining-reimburse = Skal betales tilbake til { $name }: { $amount }
sharing-all-settled = Alt er oppgjort: ingen skylder noen noe.
sharing-transfer = { $from } skylder { $to } { $amount }
sharing-warning-over-paid = Betalingene overstiger utgiften med { $amount }: kontroller beløpene.
sharing-note-income-zero = { $name } betaler ingenting på { $items }: inntekten er 0.
sharing-note-excluded = { $name } deltar ikke i «{ $item }»: andelen fordeles på de andre.
sharing-note-gift = Overskuddet gitt av { $giver } reduserer de andres andel: { $name } har nå betalt mer enn sin andel.
sharing-note-outside = { $name } betaler { $amount } utenfor sine poster: beløpet trekkes fra det de andre deler.
sharing-note-keeper = Avrundet til hele enheter: { $name } beholder øre, slik at totalen går opp.
sharing-report-distribution = Fordeling
sharing-report-sharing = Delingen
sharing-report-who-pays = Hvem betaler hva
sharing-report-items = Detaljer per post
sharing-report-payments = Betalingsstatus
sharing-report-as-of = Status per { $date }
sharing-report-balances = Andel, betalt, saldo
sharing-report-statement = Oppstilling — { $name }
sharing-report-your-share = Din andel
sharing-statement-total = Totalt for husholdningen: { $amount }
sharing-statement-pay = Å betale til { $name }: { $amount }
sharing-statement-receive = Å motta fra { $name }: { $amount }
sharing-sheet-people = Personer
sharing-sheet-items = Poster
sharing-sheet-result = Resultat
sharing-sheet-payments = Betalinger
sharing-sheet-balances = Tilbakebetalinger
