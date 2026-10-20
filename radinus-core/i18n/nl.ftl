# Radinus — meldingen van de core-zijde (Fluent), Nederlands.
# Wordt gaandeweg aangevuld naarmate de core-modules die meldingen voor de
# gebruiker voortbrengen, worden gebouwd. Zie 08_ARCHITECTURE.md §2.1.

# De vaste waarde “0 = Niet opgegeven” die elke optionele koppeling naar
# stamgegevens gebruikt (02_BASE_DE_DONNEES.md §7 regel 2). Wordt boven aan
# elke keuzelijst getoond.
# ---------------------------------------------------------------------
# De naam van de taal, geschreven in haar eigen taal.
#
# Dit is wat het menu Instellingen en de keuzelijst bij de eerste start
# tonen (01_CAHIER_DES_CHARGES.md §3.5: “elke taal geschreven in haar eigen
# taal”). Hij staat hier en niet in de code, omdat dit de enige plek is waar
# hij juist kan zijn: een taal toevoegen is een bestand neerzetten dat
# zichzelf weet te noemen.
# ---------------------------------------------------------------------
language-name = Nederlands

nomenclature-unspecified = Niet opgegeven

# Wordt gevraagd voordat een element uit de stamgegevens wordt verwijderd dat
# nog door boekingen wordt gebruikt (02_BASE_DE_DONNEES.md §7 regel 5). Woord
# voor woord overgenomen uit de oorspronkelijke WinDev-bron (Enreg_Supprimer),
# typografie inbegrepen — de formulering is van de auteur, geen vertaling.
nomenclature-delete-confirm = Er zijn boekingen (banktransacties) aangetroffen met het attribuut van het type '{ $label }'. Bevestigt u dat u dit attribuut wilt resetten?

# Wordt gevraagd voordat een element uit de stamgegevens wordt verwijderd dat
# nergens wordt gebruikt. Het origineel verwijderde zo'n element zonder een
# woord; Fabrice heeft op 25/07/2026 gevraagd dat een verwijdering altijd
# wordt bevestigd — een bewust aanvaarde afwijking van zijn eigen code, en de
# enige in deze module.
nomenclature-delete-plain = Bevestigt u het verwijderen van “{ $label }”?

# Weigering die wordt getoond wanneer het element dat de gebruiker wil
# verwijderen precies het element is dat zijn gegevensblad toont. Beslissing
# van Fabrice van 25/07/2026: een element wordt niet onder zijn eigen geopende
# gegevensblad vandaan verwijderd — het gegevensblad wordt eerst gesloten, in
# plaats van het een record te laten tonen dat niet meer bestaat.
nomenclature-delete-form-open = Het gegevensblad van “{ $label }” is geopend. Sluit het voordat u verwijdert.

# Weigering die wordt getoond wanneer de op te slaan omschrijving al door een
# ander element van dezelfde stamgegevens wordt gedragen (beslissing van de
# auteur, 25/07/2026: twee elementen van één stamgegeven mogen geen naam
# delen — een boeking onder een van twee identieke omschrijvingen indelen is
# kop of munt). `element` is het zelfstandig naamwoord in zijn eigen geslacht,
# “een categorie”, “een relatie”; `label` is de bestaande omschrijving, zoals
# opgeslagen, zodat de gebruiker ziet wat hem in de weg staat.
nomenclature-duplicate = Er bestaat al { $element } met dezelfde naam: “{ $label }”.

# ---------------------------------------------------------------------
# Wat de vensters over zichzelf zeggen.
#
# Alles staat hier, ook wat afhangt van de getoonde stamgegevens: de zinnen
# zijn voluit geschreven, taal voor taal, in plaats van in elkaar gezet uit
# woorden en geslachten. Een samenstelling die in het Frans juist is, is in
# de volgende taal fout, en het is uiteindelijk de code die weet dat er een
# vrouwelijke vorm bestaat — dat is niet zijn werk (regel van de auteur,
# 25/07/2026: “de software werkt vanaf het begin met Fluent in het Frans en
# in het Engels”).
# ---------------------------------------------------------------------

ui-loading = Bezig met laden…
ui-editing = Bewerking.
ui-viewing = Weergave.
ui-modified-suffix = — gewijzigd
ui-label-required = De omschrijving is verplicht.
ui-discard-question = Wijzigingen verwerpen?
ui-yes = Ja
ui-no = Nee
ui-select-record = Selecteer een record
ui-key-multiselect = CTRL
ui-multiselect-help = Info: Gebruik muisklik + toets [{ $modifier }] op de tabel om meerdere elementen te selecteren
ui-no-match = Geen enkele omschrijving komt overeen met het filter.
ui-filter-placeholder = Omschrijvingen filteren…
ui-column-label = OMSCHRIJVING
ui-field-label = Omschrijving
ui-field-budget-line = Budgetpost
ui-identifier = Identificatie
ui-deletion-abandoned = Verwijdering afgebroken: er is niets gewijzigd.
ui-unknown-nomenclature = Onbekende stamgegevens:

ui-title-filter = Filteren
ui-title-create = Aanmaken
ui-title-update = Selectie bewerken
ui-title-delete = Selectie verwijderen
ui-title-read = Selectie bekijken
ui-title-close = Sluiten
ui-title-save = Opslaan
ui-title-add = Toevoegen
ui-title-modify = Bewerken

ui-load-failed = Laden niet mogelijk:
ui-save-failed = Opslaan niet mogelijk:
ui-read-failed = Lezen niet mogelijk:
ui-delete-failed = Verwijderen niet mogelijk:
ui-open-failed = Openen niet mogelijk:
ui-close-failed = Sluiten niet mogelijk:

# --- Zinnen die bij elk soort stamgegevens horen ---------------------

nomenclature-identifier = { $kind ->
    [category] Identificatie van categorie
    [assignment] Identificatie van toewijzing
    [payment-mode] Identificatie van betaalwijze
    [payee] Identificatie van relatie
    [project] Identificatie van project
    [budget-line] Identificatie van budgetpost
   *[bank] Identificatie van bank
}

nomenclature-none = { $kind ->
    [category] Geen categorie.
    [assignment] Geen toewijzing.
    [payment-mode] Geen betaalwijze.
    [payee] Geen relatie.
    [project] Geen project.
    [budget-line] Geen budgetpost.
   *[bank] Geen bank.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Geen categorie om weer te geven.
    [assignment] Geen toewijzing om weer te geven.
    [payment-mode] Geen betaalwijze om weer te geven.
    [payee] Geen relatie om weer te geven.
    [project] Geen project om weer te geven.
    [budget-line] Geen budgetpost om weer te geven.
   *[bank] Geen bank om weer te geven.
}

nomenclature-gone = { $kind ->
    [category] Deze categorie bestaat niet meer.
    [assignment] Deze toewijzing bestaat niet meer.
    [payment-mode] Deze betaalwijze bestaat niet meer.
    [payee] Deze relatie bestaat niet meer.
    [project] Dit project bestaat niet meer.
    [budget-line] Deze budgetpost bestaat niet meer.
   *[bank] Deze bank bestaat niet meer.
}

nomenclature-fresh = { $kind ->
    [category] Nieuwe categorie.
    [assignment] Nieuwe toewijzing.
    [payment-mode] Nieuwe betaalwijze.
    [payee] Nieuwe relatie.
    [project] Nieuw project.
    [budget-line] Nieuwe budgetpost.
   *[bank] Nieuwe bank.
}

nomenclature-created = { $kind ->
    [category] Categorie toegevoegd.
    [assignment] Toewijzing toegevoegd.
    [payment-mode] Betaalwijze toegevoegd.
    [payee] Relatie toegevoegd.
    [project] Project toegevoegd.
    [budget-line] Budgetpost toegevoegd.
   *[bank] Bank toegevoegd.
}

nomenclature-updated = { $kind ->
    [category] Categorie gewijzigd.
    [assignment] Toewijzing gewijzigd.
    [payment-mode] Betaalwijze gewijzigd.
    [payee] Relatie gewijzigd.
    [project] Project gewijzigd.
    [budget-line] Budgetpost gewijzigd.
   *[bank] Bank gewijzigd.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 categorie verwijderd.
       *[other] { $count } categorieën verwijderd.
      }
    [assignment] { $count ->
        [one] 1 toewijzing verwijderd.
       *[other] { $count } toewijzingen verwijderd.
      }
    [payment-mode] { $count ->
        [one] 1 betaalwijze verwijderd.
       *[other] { $count } betaalwijzen verwijderd.
      }
    [payee] { $count ->
        [one] 1 relatie verwijderd.
       *[other] { $count } relaties verwijderd.
      }
    [project] { $count ->
        [one] 1 project verwijderd.
       *[other] { $count } projecten verwijderd.
      }
    [budget-line] { $count ->
        [one] 1 budgetpost verwijderd.
       *[other] { $count } budgetposten verwijderd.
      }
   *[bank] { $count ->
        [one] 1 bank verwijderd.
       *[other] { $count } banken verwijderd.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Er bestaat al een categorie met dezelfde naam: “{ $label }”.
    [assignment] Er bestaat al een toewijzing met dezelfde naam: “{ $label }”.
    [payment-mode] Er bestaat al een betaalwijze met dezelfde naam: “{ $label }”.
    [payee] Er bestaat al een relatie met dezelfde naam: “{ $label }”.
    [project] Er bestaat al een project met dezelfde naam: “{ $label }”.
    [budget-line] Er bestaat al een budgetpost met dezelfde naam: “{ $label }”.
   *[bank] Er bestaat al een bank met dezelfde naam: “{ $label }”.
}

# --- Venstertitels, zonder accenten zoals op de oorspronkelijke vensters -

window-list-title = { $kind ->
    [category] Lijst met categorieën
    [assignment] Lijst met toewijzingen
    [payment-mode] Lijst met betaalwijzen
    [payee] Lijst met relaties en handelaren
    [project] Lijst met projecten
    [budget-line] Lijst met budgetposten
   *[bank] Lijst met banken
}

window-form-title = { $kind ->
    [category] Gegevensblad categorie
    [assignment] Gegevensblad toewijzing
    [payment-mode] Gegevensblad betaalwijze
    [payee] Gegevensblad relatie
    [project] Gegevensblad project
    [budget-line] Gegevensblad budgetpost
   *[bank] Gegevensblad bank
}

# --- Menubalk (01_CAHIER_DES_CHARGES.md §6) ---------------------------

menu-file = Bestand
menu-file-import-statements = Bankafschriften importeren
menu-file-import-excel = Excel-bestand importeren
menu-file-backup = Back-up
menu-file-restore = Terugzetten
menu-file-repair = Reparatie en optimalisatie van de database
menu-file-log = Log tonen
menu-tools-password = De database met een wachtwoord beveiligen
menu-file-disconnect = Verbinding met de huidige database verbreken
menu-file-quit = Afsluiten

menu-accounts = Rekeningen
menu-accounts-manage = Beheer van de bankrekeningen
menu-accounts-balances = De saldi van uw rekeningen bekijken
menu-accounts-operations = De boekingen van een rekening beheren
menu-accounts-quick-classify = Snelle indeling van de boekingen
menu-accounts-recurring = Beheer van de terugkerende boekingen
menu-accounts-transfer = Een bedrag tussen twee rekeningen overboeken
menu-accounts-checkbooks = Beheer van de chequeboekjes

menu-statistics = Statistieken
menu-statistics-balance-chart = Grafiek Verloop van het saldo
menu-statistics-balance-analysis = Analyse Verloop van het saldo
menu-statistics-by-category = Stat per categorie
menu-statistics-by-assignment = Stat per toewijzing
menu-statistics-by-budget-line = Stat per budgetpost
menu-statistics-by-payment-mode = Stat per betaalwijze
menu-statistics-by-payee = Stat per relatie en handelaar
menu-statistics-by-project = Stat per project
menu-statistics-by-verification = Stat per controle
menu-statistics-dashboard = Overzicht van de boekingen
menu-statistics-crossed-balance = Kruisbalans

menu-budget = Budget
menu-budget-entry = Budgetinvoer
menu-budget-control = Budgetcontrole

menu-nomenclatures = Stamgegevens
menu-nomenclature = { $kind ->
    [category] Categorieën
    [assignment] Toewijzingen
    [payment-mode] Betaalwijzen
    [payee] Relaties en handelaren
    [project] Projecten
    [budget-line] Budgetposten
   *[bank] Banken
}
menu-nomenclatures-templates = Boekingssjablonen

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Extra
menu-settings = Instellingen
menu-settings-about-author = Over de auteur
menu-settings-about-radinus = Over Radinus
menu-settings-licence = Gebruikslicentie

menu-misc = Diversen
menu-misc-calculator = Rekenmachine
menu-misc-website = Naar de website van Radinus gaan
menu-misc-database-folder = Toegang tot de map met de database

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = De map van de database openen
database-folder-warning =
    Deze map bevat al uw gegevens. Een bestand hernoemen, verplaatsen of verwijderen kan uw rekeningen doen verliezen, beschadigen of Radinus onbruikbaar maken.
    Wilt u de map echt openen?
menu-misc-application-folder = Toegang tot de map met de toepassing
menu-misc-attachments-folder = Toegang tot de map met de bijlagen
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Beheer van de bijlagen
window-attachments-manager-title = Beheer van de bijlagen
attachments-column-document = Document
attachments-column-size = Grootte
attachments-column-added = Toegevoegd op
attachments-column-state = Staat
attachments-state-intact = Ongewijzigd
attachments-state-altered = Sindsdien gewijzigd
attachments-state-missing = Bestand ontbreekt
attachments-state-unknown = Niet controleerbaar
attachments-state-orphan = Wees
attachments-no-operation = Geen verrichting
attachments-orphan-remove-question = Dit bestand hoort bij geen enkele verrichting. Naar de prullenbak verplaatsen?
attachments-manager-help = Dubbelklik op een regel om het document te openen.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = De verrichting tonen
attachments-reveal = Tonen in de bestandsbeheerder
attachments-manager-summary = { $count } bijlagen, { $size } in totaal.
attachments-disk-name = Naam op de schijf: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = De map met bijlagen openen
attachments-folder-warning =
    Deze map bevat de bestanden die u aan uw verrichtingen hebt gehecht. Radinus bewaart ze onder een zelfgekozen naam: een bestand hernoemen, verplaatsen of verwijderen maakt het niet los van de verrichting, die het blijft aankondigen terwijl het niet meer opent.
    Wilt u de map echt openen?

# ---------------------------------------------------------------------
# Bankrekeningen — F04, F06, F07, F08.
# De tikfouten van versie 1.9.3 (“Bank Identifer Code”, “Solde
# initial prevu”, “Est Cloturé”, de spatie vóór het haakje van de IBAN)
# zijn gecorrigeerd: beslissing van Fabrice van 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Beheer van de bankrekeningen
window-accounts-select-title = Lijst van de rekeningen
window-balances-title = Saldi van uw rekeningen
window-account-title = Rekeningkaart

accounts-none = Geen rekening.
accounts-nothing-to-show = Geen rekening om weer te geven.
accounts-gone = Deze rekening bestaat niet meer.
accounts-fresh = Nieuwe rekening.
accounts-created = Rekening toegevoegd.
accounts-updated = Rekening gewijzigd.
accounts-deleted = { $count ->
    [one] 1 rekening verwijderd.
   *[other] { $count } rekeningen verwijderd.
}
accounts-duplicate-name = Er bestaat al een rekening met dezelfde naam: “{ $label }”.
accounts-multiselect-help = Info: Gebruik muisklik + toets [{ $modifier }] op de tabel om meerdere rekeningen te selecteren
accounts-select-question = Op welke bankrekeningen moeten de statistieken worden gebaseerd?

accounts-column-label = OMSCHRIJVING
accounts-column-bank = Bank
accounts-column-type = Rekeningtype
accounts-column-number = Rek.nr.
accounts-column-account = Rekening
accounts-column-bank-balance = Banksaldo
accounts-column-real-balance = Werkelijk
accounts-column-final-balance = Eindsaldo
accounts-total = TOTAAL

# Het verwijderen van een rekening neemt haar boekingen mee: het is de enige
# plek in de software waar een verwijdering historie vernietigt.
accounts-delete-plain = Bevestigt u het verwijderen van de rekening “{ $label }”?
accounts-delete-with-operations = De rekening “{ $label }” bevat { $count } boekingen, die samen met haar worden verwijderd. Bevestigt u het verwijderen?
accounts-delete-form-open = De rekeningkaart van “{ $label }” is geopend. Sluit deze voordat u verwijdert.

account-group-bank = Rekening- en bankgegevens
account-group-holder = Rekeninghouder
account-group-rib = Bankgegevens (RIB)
account-group-activity = Activiteit
account-group-balances = Saldi

account-field-label = Rekeningnaam
account-field-bank = Bank
account-field-type = Rekeningtype
account-field-branch-address = Adres van het bankkantoor
account-field-holder-name = Naam
account-field-holder-address = Adres
account-field-rib-bank = Bankcode
account-field-rib-branch = Kantoorcode
account-field-rib-number = Rekeningnummer
account-field-rib-key = RIB-controlegetal
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Openingsdatum
account-field-closing-date = Sluitingsdatum
account-field-closed = Is gesloten
account-field-opening-pointed = Afgestemd beginsaldo
account-field-opening-committed = Gereserveerd beginsaldo
account-field-opening-planned = Gepland beginsaldo

account-label-required = De rekeningnaam is verplicht.
account-iban-invalid = Dit IBAN is niet geldig: controleer het controlegetal.
# De blauwe regel onderaan de kaart, woord voor woord die van 1.9.3 — alleen de
# bedragen volgen voortaan de Franse notatie van de andere velden.
account-control-line = Afgestemd beginsaldo ({ $opening }) + Totaal van de boekingen ({ $operations }) = Huidig banksaldo: { $balance }.

amount-not-readable = “{ $field }” bevat geen geldig bedrag.

ui-thousands-separator = .
ui-decimal-separator = ,

# --- Lijst van de boekingen (F02) ------------------------------------

window-operations-title = Lijst boekingen van de rekening: { $account }

operations-none = Geen boeking in deze periode.
operations-bad-period = De grenzen van de periode zijn geen geldige datums.
operations-from = Begindatum
operations-to = Einddatum
operations-delete-confirm = { $count ->
    [one] Bevestigt u het verwijderen van deze boeking?
   *[other] Bevestigt u het verwijderen van deze { $count } rijen? De deelboekingen van de geselecteerde boekingen gaan mee.
}
operations-deleted = { $count ->
    [one] 1 boeking verwijderd.
   *[other] { $count } boekingen verwijderd.
}
operations-selection-total = Totaalbedrag van de geselecteerde boekingen: { $amount }

operations-column-date = Datum
operations-column-clearing-date = Afstemdatum
operations-column-status = Boekingsstatus
operation-status-pointed = Afgestemd
operation-status-committed = Gereserveerd
operation-status-planned = Gepland
operations-column-verification = Controle
operation-verification-to-verify = Te controleren
operation-verification-verified = Gecontroleerd
operation-verification-doubtful = Twijfelachtig
operation-verification-disputed = Betwist
operations-column-label = Omschrijving
operations-column-reference = Betaalreferentie
operations-column-category = Categorie
operations-column-assignment = Toewijzing
operations-column-payment-mode = Betaalw.
operations-column-payee = Relatie
operations-column-project = Projecten
operations-column-month = Maand
operations-column-debit = Debet
operations-column-credit = Credit
operations-column-balance = Saldo
operations-column-comments = Opmerkingen
operations-column-attachments = Bijlagen
operations-column-check = Chequenr.

operations-foot-debit = Debet:
operations-foot-credit = Credit:
operations-foot-total = Totaal:
operations-foot-bank = Banksaldo:
operations-foot-real = Werkelijk saldo:
operations-foot-final = Eindsaldo:

operations-menu-export = Export
operations-menu-print = Afdrukken
operations-menu-filter = Filter
operations-menu-period = Periode
operations-menu-misc = Diversen

operations-title-point = Selectie afstemmen
operations-title-sub = Een deelboeking toevoegen
operations-title-duplicate = Selectie dupliceren
operations-not-yet = Dit scherm bestaat nog niet: het komt verderop in het plan.

accounts-choose-question = Met welke rekening wilt u werken?
ui-title-select = De selectie kiezen

month-january = januari
month-february = februari
month-march = maart
month-april = april
month-may = mei
month-june = juni
month-july = juli
month-august = augustus
month-september = september
month-october = oktober
month-november = november
month-december = december

operations-period-year = Lopend jaar

# --- Menu Periode van F02 --------------------------------------------
# Negen items, waarvan er twee een submenu van de twaalf maanden openen. Elk
# doet maar één ding: er een begindatum en een einddatum uit afleiden, die het
# scherm terugzet in zijn twee velden (verzoek van Fabrice, 25/07/2026).

period-all = Alle
period-last-year = Vorig Jaar
period-this-year = Huidig Jaar
period-whole-year = Het hele jaar
period-last-month = Vorige Maand
period-this-month = Huidige Maand
period-last-week = Vorige Week
period-this-week = Huidige Week
period-yesterday = Gisteren
period-today = Vandaag

# --- Filtermenu van F02 ----------------------------------------------
# Filtert de rijen op de aard van de boeking (verzoek van Fabrice,
# 25/07/2026). De drie statussen zijn die van de database: 1 afgestemd,
# 2 gereserveerd, 3 gepland (02_BASE_DE_DONNEES.md §5.2).

filter-all = Alle boekingen
filter-pointed = Alleen de afgestemde boekingen
filter-committed = Alleen de gereserveerde boekingen
filter-planned = Alleen de geplande boekingen
filter-by-status = Filter op status
filter-by-verification = Filter op controle
filter-show-all = Alles tonen

# --- Boekingsscherm (F03) --------------------------------------------
# De labels zijn die van de schermafbeelding “Fiche operation transaction.png”,
# met de zetfouten van het origineel verbeterd (toestemming van Fabrice,
# 25/07/2026: “les coquilles tu les corriges”): “Libelle” wordt “Libellé”,
# “Categorie” wordt “Catégorie”, “Statut Operation” wordt
# “Statut opération”.

window-operation-title = Boeking rekening: { $account }

operation-menu-identification = Identificatie
operation-menu-options = Opties
operation-fitid-edit = FITID bewerken…
operation-fitid-delete = FITID verwijderen
operation-fitid-question = FITID van deze transactie:
operation-fitid-delete-question = FITID van deze transactie verwijderen?
operation-fitid-written = FITID opgeslagen.
operation-fitid-removed = FITID verwijderd.

operation-group-identification = Identificatie van de boeking
operation-group-amount = Bedrag van de boeking
operation-group-status = Status van de boeking
operation-group-classification = Indeling van de boeking voor de berekening van de statistieken
operation-group-check = Cheque die bij de boeking hoort
operation-group-comment = Opmerking

operation-field-label = Omschrijving
operation-field-reference = Betaalreferentie
operation-field-date = Datum
operation-field-direction = Boekingstype:
operation-field-amount = Bedrag
operation-field-status = Boekingsstatus
operation-field-clearing-date = Afstemdatum
operation-field-verification = Controle
operation-field-category = Categorie
operation-field-assignment = Toewijzing
operation-field-payment-mode = Wijze
operation-field-payee = Relatie
operation-field-project = Project
operation-field-check = Aan cheque koppelen

operation-direction-debit = Debet
operation-direction-credit = Credit

operation-check-info = Info.
operation-check-link = Koppelen
operation-check-unlink = Verwijderen

operation-fresh = Nieuwe boeking.
operation-created = Boeking toegevoegd.
operation-updated = Boeking gewijzigd.
operation-gone = Deze boeking bestaat niet meer.
operation-nothing-to-show = Geen boeking om weer te geven.
operation-label-required = De omschrijving van de boeking is verplicht.
operation-date-required = De datum van de boeking is verplicht.
operation-clearing-date-invalid = De afstemdatum is geen geldige datum.
operation-clearing-date-required = Een afgepunte transactie moet verplicht een afpuntdatum hebben.
operation-clearing-date-question =
    Een afgepunte transactie moet verplicht een afpuntdatum hebben.
    Wilt u opslaan met de datum van de transactie, { $date }?
operation-is-a-sub = Deze rij is een deelboeking: die wijzigt u vanuit haar eigen scherm.
operation-delete-form-open = Het scherm van “{ $label }” is geopend. Sluit het voordat u verwijdert.

operation-attachments = { $count ->
    [0] Geen bijlage
    [one] 1 bijlage
   *[other] { $count } bijlagen
}

operation-title-comment = Opmerking bij de boeking
operation-title-sub = Een deelboeking aanmaken
operation-title-template = Boekingssjablonen
operation-title-attachment = Bijlagen

# --- Scherm deelboeking (F04) ----------------------------------------
# Verkleinde versie van F03: geen Wijze, geen Status, geen Datum — een
# deelboeking krijgt die van haar moeder (`Maj_ProprieteSousOp`, door Fabrice
# bevestigd op 26/07/2026: “dans une sous-opération, comme est le complément,
# on ne peut pas toucher au mode de paiement, cela serait illogique”).

window-sub-operation-title = Scherm deelboeking

sub-operation-group-amount = Bedrag van de deelboeking
sub-operation-field-label = Naam
sub-operation-fresh = Nieuwe deelboeking.
sub-operation-created = Deelboeking toegevoegd.
sub-operation-updated = Deelboeking gewijzigd.
sub-operation-gone = Deze deelboeking bestaat niet meer.
sub-operation-nothing-to-show = Geen deelboeking om weer te geven.
sub-operation-label-required = De naam van de deelboeking is verplicht.
sub-operation-parent-gone = De te verdelen boeking bestaat niet meer.
# Wat het scherm zegt wanneer het het Restant toont. Het is niet beveiligd:
# men kan het wijzigen, maar men moet weten wat men zich op de hals haalt
# (beslissing van Fabrice, 26/07/2026).
sub-operation-is-the-complement = Dit is het Restant: wat er nog te verdelen valt. Wie het hernoemt of het bedrag ervan wijzigt, maakt er een gewone deelboeking van.
sub-operation-of = Verdeling van “{ $label }” ({ $amount })

operations-pointed = { $count ->
    [0] Geen boeking om af te stemmen: de selectie is al afgestemd.
    [one] 1 boeking afgestemd.
   *[other] { $count } boekingen afgestemd.
}
operations-select-one = Selecteer één enkele boeking.

# --- Dupliceren en de weergave van de deelboekingen (F02) -------------
# Dupliceren opent een vooraf ingevuld scherm dat de gebruiker zelf bevestigt
# (beslissing van Fabrice, 26/07/2026): er wordt niets weggeschreven zolang
# hij niet heeft opgeslagen, en hij kan vooraf de datum of het bedrag
# corrigeren.

operation-copy = Kopie nog op te slaan: er is nog niets aangemaakt.
operations-show-children = Alle deelboekingen tonen
operations-hide-children = Alle deelboekingen verbergen
operations-recurring-from = Een periodieke boeking maken op basis van deze boeking

# --- Tweede bevestiging van een ingrijpende verwijdering --------------
# Een bankrekening verwijderen neemt haar hele historie mee: op een Ja/Nee
# klikt men zonder te lezen, dus vragen we om het woord te typen (beslissing
# van Fabrice, 26/07/2026). Het woord is dat van het woordenboek — hier “Ja”,
# in het Engels “Yes” — er hoeft hier dus niets een tweede keer vertaald te
# worden.

accounts-delete-second-question = Deze verwijdering is definitief en neemt de hele historie van de rekening mee. Typ “{ $word }” om haar te bevestigen.

# --- F20-F24 — De zes statistieken ------------------------------------
# Gemeenschappelijk sjabloon, uitgewerkt op zes assen. Die per categorie heeft
# als model gediend en Fabrice heeft haar op 26/07/2026 goedgekeurd voordat de
# vijf andere bestonden — de kolomnamen zijn die van het origineel.

window-statistics-title = { $kind ->
    [assignment] Statistieken per toewijzing
    [budget-line] Statistieken per budgetpost
    [payment-mode] Statistieken per betaalwijze
    [payee] Statistieken per relatie en handelaar
    [project] Statistieken per project
    [verification] Statistieken per controle
   *[category] Statistieken per categorie
}

statistics-axis-column = { $kind ->
    [assignment] Toewijzing
    [budget-line] BudgetPost
    [payment-mode] BoekingsWijze
    [payee] Relatie
    [project] Projecten
    [verification] Controle
   *[category] CategorieNaam
}

statistics-unclassified = { $kind ->
    [assignment] Zonder toewijzing
    [budget-line] Zonder budgetpost
    [payment-mode] Zonder betaalwijze
    [payee] Zonder relatie
    [project] Zonder project
    [verification] Te controleren
   *[category] Zonder categorie
}
statistics-total = Totaal
statistics-sum = Som
statistics-cumulative = Cumulatief

# De vijf schakelaars van de balk. Het label wisselt ON/OFF, net als in het
# origineel: de schakelaar zelf zegt waar hij staat.
statistics-switch-pointed = Afgestemde boekingen { $state }
statistics-switch-committed = Gereserveerde boekingen { $state }
statistics-switch-planned = Geplande boekingen { $state }
statistics-switch-debits = Debetbedragen { $state }
statistics-switch-credits = Creditbedragen { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Er is geen rekening gekozen: de statistiek heeft nergens betrekking op.
statistics-no-data = Geen boeking in dit jaar voor de gekozen rekeningen.
statistics-detail-empty = Klik op een vakje met een getal om de boekingen te zien die het telt.
statistics-detail-none = Geen boeking achter dit vakje.
statistics-accounts = { $count ->
    [one] 1 rekening
   *[other] { $count } rekeningen
}
statistics-year-next = Volgend jaar
statistics-year-previous = Vorig jaar

statistics-column-date = Datum
statistics-column-clearing-date = AfstemDatum
statistics-column-label = Omschrijving
statistics-column-amount = Bedrag
statistics-column-comments = Opmerkingen

accounts-stats-multiselect-help = Info: Gebruik muisklik + toets [{ $modifier }] op de tabel om meerdere rekeningen te kiezen

# Het jaartal van de statistieken: men klikt erop en voert een jaar in.
# De grenzen zijn die van het “Alle” uit het menu Periode — een jaar van
# Radinus is een geheel getal tussen 1950 en 2550 (Fabrice, 26/07/2026).
statistics-year-question = Met welk jaar wilt u werken? Radinus loopt van { $first } tot { $last }.
statistics-year-choose = Kies het jaar

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Kruisbalans
crossed-balance-window-name = Kruisbalans
crossed-balance-column = Categorie
crossed-balance-no-data = Geen boeking in deze maand voor de gekozen rekeningen.
crossed-balance-month-question = Aan welke maand wilt u werken? Een getal tussen { $first } en { $last }.
crossed-balance-month-choose = Maand kiezen
crossed-balance-next = Volgende maand
crossed-balance-previous = Vorige maand

# --- Export van de tabellen (rechtermuisklik) -------------------------
# Een functie van de tabel, niet van een venster: alle lijsten hebben haar.

export-to-excel = Exporteren naar Excel (.xlsx)
export-to-word = Exporteren naar Word (.docx)
export-to-tsv = Exporteren naar TSV (.tsv)
export-to-ini = Exporteren naar INI (.ini)
export-to-toml = Exporteren naar TOML (.toml)
export-to-yaml = Exporteren naar YAML (.yaml)
export-to-ofx = Exporteren naar OFX (.ofx)
export-to-qif = Exporteren naar QIF (.qif)
export-to-ods = Exporteren naar LibreOffice Calc (.ods)
export-to-csv = Exporteren naar CSV (.csv)
export-to-xml = Exporteren naar XML (.xml)
# Het menu Export van het statistiekenvenster: één tabblad per jaar, genaamd
# AN_2026. De lege jaren — onder de ingestelde schakelaars — staan er niet in.
export-menu = Export
export-to = Exporteren naar
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Cel kopiëren
copy-rows = Geselecteerde regels kopiëren
copy-failed = Kopiëren naar het klembord is mislukt.
export-all-years-excel = Alle jaren naar Excel exporteren
export-all-years-ods = Alle jaren naar LibreOffice Calc exporteren
export-all-months-excel = Alle maanden van het getoonde jaar naar Excel exporteren
export-all-months-ods = Alle maanden van het getoonde jaar naar LibreOffice Calc exporteren
export-no-year = Geen enkel jaar bevat een boeking: er is niets te exporteren.
export-years-done = { $years } jaren geëxporteerd naar “{ $file }”.
export-to-json = Exporteren naar JSON (.json)
export-done = Geëxporteerd naar “{ $file }”.
export-failed = Exporteren niet mogelijk: { $reason }
export-nothing = Er is niets te exporteren.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Statistieken per toewijzing
    [budget-line] Statistieken per budgetpost
    [payment-mode] Statistieken per betaalwijze
    [payee] Statistieken per relatie en handelaar
    [project] Statistieken per project
    [verification] Statistieken per controle
   *[category] Statistieken per categorie
}
statistics-detail-name = Detail van de statistieken

# --- F19 — Dashboard ---------------------------------------------------
# Eén periode en drie schakelaars; twee ringdiagrammen per budgetpost;
# drie grote getallen. De kleuren van de sectoren zijn die van het origineel,
# afgelezen van de schermafdruk van Fabrice.

window-dashboard-title = Dashboard
dashboard-menu-period = Periode
dashboard-menu-misc = Diversen
dashboard-from = Begindatum:
dashboard-to = Einddatum:
dashboard-switch-pointed = Afgestemde boekingen meenemen
dashboard-switch-committed = Gereserveerde boekingen meenemen
dashboard-switch-planned = Geplande boekingen meenemen
dashboard-spending = Uitgaven
dashboard-earning = Inkomsten
dashboard-debits = Totaal debetboekingen
dashboard-credits = Totaal creditboekingen
dashboard-balance = Balans
dashboard-unclassified = Zonder budgetpost
dashboard-nothing = Geen boekingen in deze periode.
dashboard-no-account = Er is geen rekening gekozen: het dashboard heeft nergens betrekking op.
dashboard-enlarge = Vergroot openen

# --- F25 — Saldoverloop ------------------------------------------------
# Eén grafiek per gekozen rekening, plus die van het totaal — die pas
# bestaat vanaf twee rekeningen (regel van Fabrice, 26/07/2026). De grafieken
# lopen trapsgewijs: het saldo houdt zijn waarde tot de volgende boeking.

window-curve-title = Saldoverloop
curve-heading = Saldoverloop per dag
curve-menu-period = Periode
curve-total = Totaal
curve-from = Begindatum:
curve-to = Einddatum:
curve-axis-balance = saldo
curve-nothing = Er is geen rekening gekozen: er is geen grafiek te tekenen.
curve-empty = Geen boekingen in deze periode.

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Analyse van het saldoverloop
analysis-heading = Analyse van het saldoverloop
analysis-hint = Sleep met ingedrukte muisknop een zone op de grafiek om de boekingen van die periode te zien.
analysis-zone = Zone:
analysis-opening = Beginsaldo:
analysis-closing = Eindsaldo:
analysis-variation = Verschil:
analysis-detail-name = Saldoanalyse
analysis-detail-none = Geen boeking in deze zone.

# --- F05 — Snelle classificatie van de boekingen -----------------------
# Het scherm waarin men **in bulk** indeelt: men selecteert rijen, vinkt de
# te wijzigen kenmerken aan en past ze in één keer toe — in het geheugen.
# Er wordt niets weggeschreven zolang er niet is opgeslagen, en het opslaan
# schrijft alleen weg wat afwijkt van wat is ingelezen (regels van Fabrice,
# 27/07/2026).

window-quick-classification-title = Snelle classificatie van de boekingen: { $account }
quick-dates-title = Begin- en einddatum van de lijst.
quick-from = Begindatum
quick-to = Einddatum
quick-menu-period = Periode
quick-change-title = Kenmerken van de selectie wijzigen in:
quick-check-category = Categorie
quick-check-assignment = Toewijzing
quick-check-payment-mode = Wijze
quick-check-payee = Relatie
quick-check-project = Project
quick-check-status = Status
quick-check-verification = Controle
quick-column-date = Datum
quick-column-label = Omschrijving
quick-column-amount = Bedrag
quick-column-category = Categorie
quick-column-assignment = Toewijzing
quick-column-payment-mode = Betaalwijze
quick-column-payee = Relatie
quick-column-project = Projecten
quick-column-status = Status
quick-column-verification = Controle
# Op een Mac is Ctrl + klik een rechtermuisklik: de toets die aan een
# selectie toevoegt is daar ⌘, en de hulptekst moet die noemen die werkt.
quick-multiselect-help = Info: Gebruik muisklik + toets [{ $modifier }] op de tabel om meerdere elementen te selecteren
quick-none = Geen boekingen in deze periode.
quick-select-lines = Selecteer minstens één rij en vink minstens één kenmerk aan.
quick-applied = { $count ->
    [0] Er is niets gewijzigd: deze rijen hadden deze indeling al.
    [one] 1 rij ingedeeld. Er is nog niets opgeslagen.
   *[other] { $count } rijen ingedeeld. Er is nog niets opgeslagen.
}
quick-pending = { $count ->
    [0] Geen openstaande wijzigingen.
    [one] 1 rij gewijzigd, niet opgeslagen.
   *[other] { $count } rijen gewijzigd, niet opgeslagen.
}
quick-save-question = { $count ->
    [one] De openstaande wijziging opslaan?
   *[other] De { $count } openstaande wijzigingen opslaan?
}
quick-saved = { $count ->
    [0] Er was niets op te slaan.
    [one] 1 rij opgeslagen.
   *[other] { $count } rijen opgeslagen.
}
quick-nothing-to-save = Geen openstaande wijzigingen.
quick-leave-question = Er zijn wijzigingen die niet zijn opgeslagen. Wat wilt u doen?
quick-leave-save = Opslaan en afsluiten
quick-leave-discard = Verwerpen en afsluiten
quick-leave-stay = Blijven
quick-title-apply = Toepassen op de geselecteerde rijen ( in het geheugen )
quick-title-save = Opslaan op de schijf

# --- F17 / F18 — Importeren van een bankafschrift ----------------------
# Men kiest een rekening, opent een OFX-bestand — dat in het RAM blijft —,
# de rijen die de database al kent verschijnen in pastel, en het derde
# pictogram neemt ze op: in bulk als er meerdere zijn gekozen, anders één
# voor één via de afstemmingskaart (werkwijze van Fabrice, 27/07/2026).

window-statement-import-title = Importeren van bankafschriften: { $account }
window-statement-form-title = Een transactie afstemmen (Neemt een boeking op in de historie van uw rekening)
statement-menu-filter = Filter
statement-filter-all = Alle rijen
statement-filter-pending = Op te nemen
statement-filter-known = Al opgenomen
statement-column-id = ID
statement-column-reconciled = Afgestemd
statement-column-fitid = FITID
statement-column-date = Datum
statement-column-label = Omschrijving
statement-column-reference = Betaalreferentie
statement-column-debit = Debet
statement-column-credit = Credit
statement-account = Rekening
statement-file = Bestand
statement-difference = Verschil
statement-none = Er is geen bankafschrift geopend: klik op de gele map om een bestand te kiezen (OFX, CSV, QIF).
statement-empty = Dit bankafschrift bevat geen enkele boeking.
statement-no-match = Geen enkele rij komt overeen met het filter.
statement-help = Info: Gebruik muisklik + toets [{ $modifier }] op de tabel om meerdere rijen te selecteren
statement-choose-account = Dit bestand bevat meerdere rekeningen. Welke wilt u importeren?
statement-select-line = Selecteer minstens één rij van het bankafschrift.
statement-title-open = Een bestand met een bankafschrift openen (OFX, QIF, CSV)
statement-title-info = Informatie over het geopende bestand
statement-title-integrate = De selectie opnemen in de rekening
statement-title-validate = Deze boeking opnemen in de rekening
statement-duplicate = Let op dubbele invoer: deze transactie lijkt al te zijn opgenomen in de database (Financial Institution Transaction ID bestaat)
statement-no-fitid = Let op: dit bestand geeft geen identificatie (FITID) voor deze rij. Een dubbele invoer kan niet worden gedetecteerd.
statement-loaded = { $count ->
    [0] Dit bestand bevat geen enkele boeking voor deze rekening.
   *[other] { $count } rijen gelezen, waarvan { $known } al aanwezig in uw rekening.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } rijen gelezen; geen enkele lijkt op een boeking die al aanwezig is in uw rekening.
    [one] { $count } rijen gelezen, waarvan één lijkt op een boeking die al aanwezig is in uw rekening (dezelfde datum, dezelfde omschrijving, hetzelfde bedrag).
   *[other] { $count } rijen gelezen, waarvan { $alike } lijken op boekingen die al aanwezig zijn in uw rekening (dezelfde datum, dezelfde omschrijving, hetzelfde bedrag).
}
statement-loaded-also-alike = { $alike ->
    [one] Nog één lijkt op een boeking die al aanwezig is (dezelfde datum, dezelfde omschrijving, hetzelfde bedrag).
   *[other] Nog { $alike } lijken op boekingen die al aanwezig zijn (dezelfde datum, dezelfde omschrijving, hetzelfde bedrag).
}
statement-integrated = { $count ->
    [0] Er is niets opgenomen: deze rijen staan al in uw rekening.
    [one] 1 boeking opgenomen.
   *[other] { $count } boekingen opgenomen.
}
# **De meldingen van het origineel, woord voor woord** (instructie van
# Fabrice, 28/07/2026: trouw blijven aan de oorspronkelijke code). De zijne
# waarschuwt vóór de bulk, vraagt rij voor rij bij een dubbele invoer, en
# legt aan het eind verantwoording af.

statement-mass-question =
    Weet u zeker dat u meerdere boekingen tegelijk in uw rekening wilt opnemen?
    U zult ze later moeten categoriseren en van kenmerken voorzien om nauwkeurige statistieken te maken
    Bij Ofx-bestanden: als er dubbele invoeren worden gedetecteerd, moet u het gedrag van het programma kiezen
    Bij de andere bestandstypen: u zult op dubbele invoeren moeten letten
statement-duplicate-question =
    De transactie: { $date } { $label }: { $amount }
    lijkt al te zijn opgenomen in de transactiehistorie van uw bankrekening.
    Wilt u de afstemming werkelijk uitvoeren?
statement-already-reconciled = U hebt deze transactie al afgestemd: zij is al opgenomen in de transactiehistorie van uw rekening
statement-integration-report =
    Einde van de opname.
    Aantal opgenomen records: { $added }
    Aantal genegeerde records: { $ignored }
statement-integration-abandoned =
    Opname afgebroken!
    Aantal opgenomen records: { $added }
    Aantal genegeerde records: { $ignored }
statement-yes = Ja
statement-no = Nee
statement-cancel = Annuleren
statement-file-info =
    Rekening van het bestand: { $account }
    Periode: van { $from } tot { $to }
    Door de bank opgegeven saldo: { $balance }
statement-qif-question = Niets in dit bestand geeft aan of de datum “{ $date }” geschreven is als dag/maand of als maand/dag. Bedoeld is:
statement-qif-day-month = Dag { $day }, maand { $month } (dag/maand)
statement-qif-month-day = Dag { $day }, maand { $month } (maand/dag)
statement-qif-dates-mixed = Dit bestand schrijft zijn datums op twee manieren: “{ $first }” leest als dag/maand, “{ $second }” als maand/dag. Het wordt niet geïmporteerd, zodat geen enkele datum verkeerd wordt.
statement-qif-amounts-mixed = Dit bestand schrijft zijn bedragen op twee manieren: “{ $first }” met een punt, “{ $second }” met een komma. Het wordt niet geïmporteerd, zodat geen enkel bedrag verkeerd wordt.
statement-qif-opening = Beginsaldo van { $amount } op { $date }: dit is geen boeking, het wordt niet geïmporteerd.
statement-qif-opening-undated = Beginsaldo van { $amount }: dit is geen boeking, het wordt niet geïmporteerd.
statement-qif-suspect = Rij { $rank }, “{ $label }” ({ $amount }), lijkt op een beginsaldo: controleer deze rij voordat u die opneemt.
statement-qif-rejected = { $count ->
    [one] Eén onleesbare rij wordt niet geïmporteerd: { $lines }.
   *[other] { $count } onleesbare rijen worden niet geïmporteerd: { $lines }.
}
statement-qif-reason-date = datum
statement-qif-reason-amount = bedrag
statement-qif-reason-differ = tegenstrijdige bedragen
statement-qif-no-account = Deze rekening staat niet meer in het bestand: open het bestand opnieuw.
statement-balance-unknown = niet vermeld in het bestand
statement-group-identification = Identificatie van de boeking
statement-group-amount = Bedrag van de boeking
statement-group-classification = Indeling van de boeking voor de berekening van de statistieken
statement-group-status = Status van de boeking
statement-field-date = Datum
statement-field-label = Omschrijving
statement-field-reference = Betaalreferentie
statement-field-type = Soort boeking
statement-field-amount = Bedrag
statement-field-mode = Betaalwijze
statement-field-category = Categorie
statement-field-assignment = Toewijzing
statement-field-payee = Relatie
statement-field-project = Project
statement-field-status = Status
statement-field-clearing = Afstemdatum

# --- Het scherm voor het opdelen van een CSV-afschrift -----------------
# Een CSV draagt geen enkele betrouwbare veldnaam: men stelt in, test, kijkt
# en begint opnieuw. Het voorbeeld toont alles, koeterwaals inbegrepen — zo
# ziet men dat men zich heeft vergist — maar alleen de geldige rijen gaan
# door naar het scherm voor de opname (regel van Fabrice, 27/07/2026).

window-csv-statement-title = Importeren van gegevens uit een csv-bestand
csv-preview-title = Voorbeeld van het bestand:
csv-settings-title = Parameters voor het opdelen van het bestand met het oog op het extraheren van de gegevens:
csv-extraction-title = Weergave van de gegevensextractie volgens de parameters voor het opdelen  ( controleer de samenhang van de gegevens ):
csv-column-line = Rijnr.
csv-column-content = Inhoud
csv-header-lines = Aantal te negeren kopregels van het bestand
csv-separator = De gegevens (kolommen) zijn gescheiden door het teken:
csv-date-at = Positie veld datum
csv-label-at = Positie veld omschrijving
csv-debit-at = Positie veld bedrag debet
csv-credit-at = Positie veld bedrag credit
csv-test = Parameters testen
csv-separator-semicolon = Puntkomma   ;
csv-separator-comma = Komma   ,
csv-separator-tab = Tab
csv-separator-pipe = Verticale streep   |
csv-separator-space = Spatie
csv-help = Stel in, test, kijk: alleen rijen met een leesbare datum en een leesbaar bedrag worden geïmporteerd.
csv-none = Het bestand is leeg.
csv-not-tested = Klik op “Parameters testen” om te zien wat het opdelen oplevert.
csv-extraction = { $count ->
    [0] Het opdelen levert geen enkele rij op: controleer het aantal kopregels en het scheidingsteken.
   *[other] { $count } rijen opgedeeld: { $valid } worden geïmporteerd, { $dropped } afgewezen wegens een onleesbare datum of een onleesbaar bedrag.
}
csv-nothing-valid = Geen enkele rij draagt tegelijk een leesbare datum en een leesbaar bedrag: er is niets te importeren. Controleer het aantal kopregels, het scheidingsteken en de positie van de velden.
csv-title-validate = De geldige rijen doorzetten naar het importeren

# --- F13 / F31 / F14 / F12 — Chequeboekjes en cheques (fase 9) ----------
# Overzetting van zijn vijf WinDev-codes en zijn zeven schermafdrukken,
# geleverd op 28/07/2026. Zijn exacte zinnen waar hij er een heeft; de mijne
# elders.
#
# Drie getrouwheden die hij die dag heeft beslecht en die in de woorden
# doorklinken: de dubbele referentie wordt niet gemeld (zijn
# `Existe_Reference` wordt nooit aangeroepen), het aantal cheques wordt niet
# aan de grenzen getoetst, en de boekingenteller telt de dochters die de
# lijsten weigeren.

window-chequebooks-title = Lijst van chequeboekjes
window-chequebook-title = Instellingen chequeboekje
window-cheques-title = Samenstelling van het chequeboekje: lijst van cheques.
window-cheque-title = Chequefiche
window-cheque-operations-title = Lijst van boekingen.

# De lijst van chequeboekjes (F13) — alle boekjes, over alle rekeningen heen:
# zijn twee rekeningkolommen zouden bij één enkele rekening nutteloos zijn.
chequebooks-column-reference = OMSCHRIJVING
chequebooks-column-date = Datum
chequebooks-column-account = Rekeningnaam
chequebooks-column-account-number = Rek.nr.
chequebooks-column-comments = Opmerkingen
chequebooks-none = Er is geen enkel chequeboekje opgeslagen.
chequebooks-nothing-to-show = Geen enkel chequeboekje voldoet aan deze zoekopdracht.
chequebooks-title-composition = De samenstelling van het chequeboekje bekijken
chequebooks-delete-question = Er zijn boekingen (banktransacties) gevonden die aan chequeboekje gekoppeld zijn. Bevestigt u dat u dit chequeboekje wilt verwijderen?
chequebooks-deleted = { $count ->
    [one] Eén chequeboekje verwijderd.
   *[other] { $count } chequeboekjes verwijderd.
}
chequebooks-gone = Dit chequeboekje bestaat niet meer.
chequebooks-created = Chequeboekje opgeslagen, met al zijn cheques.
chequebooks-updated = Chequeboekje gewijzigd.
# Het zwijgen van zijn `HAjoute`: het venster zegt niet dat de referentie al
# bezet is. Het zegt alleen dat er niets is opgeslagen — anders zou men het
# boekje voor aangemaakt houden.
# De acht voorzorgen uit zijn „Precauttion enregistrement cheque.txt”, woord
# voor woord en in zijn volgorde. De eerste zeven zijn `Erreur()`, de achtste
# een `Info()` — en de volgorde bepaalt wat men ziet wanneer er twee dingen
# tegelijk misgaan.
chequebook-refusal-duplicate = Er bestaat al een referentie met dezelfde naam
chequebook-refusal-reference-required = Het invoeren van een referentie is verplicht
chequebook-refusal-number-too-big = De nummers van de eerste en/of de laatste cheque zijn te groot (maximumwaarde 999 999 999)
chequebook-refusal-date = Voer een geldige ontvangstdatum in
chequebook-refusal-numbers-required = Vul de nummers van de eerste en de laatste cheque in
chequebook-refusal-order = Het nummer van de eerste cheque moet lager zijn dan het nummer van de laatste cheque
chequebook-refusal-account = Selecteer verplicht de rekening die met dit chequeboekje in verband staat
chequebook-refusal-too-many = Maximumaantal cheques voor een chequeboekje: 1000, limiet bereikt
# Zijn bevestigingsvraag, alleen bij het toevoegen gesteld: ze vat samen wat
# er wordt aangemaakt en waarschuwt dat er daarna niets meer aan te wijzigen
# valt.
chequebook-creation-question =
    Aanmaken van het chequeboekje met de volgende kenmerken:
    - Aantal aan te maken cheques:{ $count }
    - Cheques genummerd van { $first } tot { $last }
    Let op, deze gegevens zijn na het aanmaken niet meer te wijzigen!

# De chequeboekjesfiche (F31). De eerste vijf velden worden grijs zodra het
# boekje bestaat: zijn cheques zijn er al.
chequebook-field-id = Identificatie van chequeboekje
chequebook-field-reference = Referentie
chequebook-field-received = Vervaardigd of ontvangen op
chequebook-field-first = Nummer van de eerste cheque
chequebook-field-last = Nummer van de laatste cheque
chequebook-field-quantity = Aantal cheques
chequebook-field-account = Koppelen aan de bankrekening:
chequebook-field-comments = Opmerkingen
chequebook-locked = De cheques van dit boekje zijn al aangemaakt: de nummering ervan is niet meer te wijzigen.
# Zijn zin, woord voor woord (`Enreg_Lire`).
chequebook-account-missing = De bankrekening waaraan dit chequeboekje is gekoppeld, ontbreekt of is verwijderd!

# De samenstelling van het chequeboekje (F14). De status wijzigt men in het vak.
cheques-column-number = Chequenr.
cheques-column-date = Datum
cheques-column-place = Plaats
cheques-column-payee = Begunstigde
cheques-column-amount = Bedrag
cheques-column-status = Status
cheques-column-comments = Opmerkingen
cheques-column-operations = Aant. gekopp. boekingen
cheques-none = Dit chequeboekje bevat geen enkele cheque.
cheques-nothing-to-show = Geen enkele cheque voldoet aan deze zoekopdracht.
cheques-help = Klik in het vak Status om die te wijzigen; het vergrootglas toont de gekoppelde boekingen, de schakel koppelt er een.
cheques-title-linked = De boekingen bekijken die al aan deze cheque gekoppeld zijn
cheques-title-link = Een boeking aan deze cheque koppelen
cheques-status-changed = Status van de cheque gewijzigd.

# De chequefiche (F12).
cheque-field-id = Identificatie van cheque
cheque-field-number = Chequenummer
cheque-field-issued = Datum van uitgifte
cheque-field-place = Plaats van uitgifte
cheque-field-payee = Begunstigde
cheque-field-amount = Bedrag
cheque-field-comments = Opmerkingen
cheque-field-status = Status van de cheque
cheque-gone = Deze cheque bestaat niet meer.
cheque-updated = Cheque gewijzigd.

# De twee gezichten van het koppelvenster.
cheque-operations-linked-title = Lijst van de boekingen die al aan deze cheque gekoppeld zijn.
cheque-operations-choose-title = Kies een boeking om aan de cheque te koppelen
cheque-operations-column-account = Rekening
cheque-operations-column-label = Naam
cheque-operations-column-date = Datum
cheque-operations-column-clearing = Afstemdatum
cheque-operations-column-amount = Bedrag
cheque-operations-column-cheque = Gekoppelde cheque
cheque-operations-none-linked = Er is geen boeking aan deze cheque gekoppeld.
cheque-operations-none = Deze rekening bevat geen enkele boeking.
cheque-operations-nothing-to-show = Geen enkele boeking voldoet aan deze zoekopdracht.
cheque-operations-help = De vetgedrukte boekingen dragen al een cheque.
cheque-operations-linked-help = Het rode kruis maakt de cheque los van de boeking: er wordt niets verwijderd.
cheque-operations-linked = Boeking aan de cheque gekoppeld.
cheque-operations-dissociated = Cheque losgemaakt van de boeking.
cheque-operations-menu-filter = Filter
cheque-title-associate = Deze boeking aan de cheque koppelen
cheque-title-dissociate = De cheque losmaken van deze boeking

# De banner „Cheque in verband met de boeking” van de boekingsfiche, en de
# twee stappen van het chequevissen — eerst het boekje, dan de cheque.
chequebooks-select-question = Kies het chequeboekje
cheques-select-question = Kies de cheque om aan de boeking te koppelen
operation-check-save-first = Sla eerst de boeking op: een cheque wordt gekoppeld aan een boeking die bestaat.
operation-check-none = Deze boeking draagt geen enkele cheque.

# --- F36 / F37 — De boekingssjablonen (fase 10) -------------------------
# Een sjabloon is een kant-en-klare invoer: men past het toe om niet opnieuw
# te hoeven typen, en het **overschrijft** wat er in de fiche staat. Er gaat
# niets naar de schijf zolang de boekingsfiche niet is bevestigd (regel van
# Fabrice, 29/07/2026).

window-operation-templates-title = Lijst van boekingssjablonen
window-operation-template-title = Fiche boekingssjabloon

operation-templates-none = Er is geen enkel boekingssjabloon opgeslagen.
operation-templates-nothing-to-show = Geen enkel sjabloon voldoet aan deze zoekopdracht.
operation-templates-select-question = Kies het toe te passen sjabloon
operation-templates-delete-question = Bevestigt u het verwijderen van de geselecteerde sjablonen?
operation-templates-deleted = { $count ->
    [one] Eén sjabloon verwijderd.
   *[other] { $count } sjablonen verwijderd.
}
operation-template-gone = Dit sjabloon bestaat niet meer.
operation-template-fresh = Nieuw sjabloon.
operation-template-created = Sjabloon opgeslagen.
operation-template-updated = Sjabloon gewijzigd.
operation-template-label-required = Het invoeren van een naam is verplicht
operation-template-duplicate = Er bestaat al een sjabloon met dezelfde naam

# De fiche F36, sectie voor sectie — zijn exacte opschriften.
operation-template-field-id = ID boekingssjabloon
operation-template-group-name = Standaardnaam van de toekomstige boeking na toepassing van het sjabloon
operation-template-field-label = Naam
operation-template-group-amount = Standaardbedrag van de boeking dat in dit sjabloon is vastgelegd
operation-template-field-direction = Boekingstype
operation-template-field-amount = Bedrag
operation-template-group-status = Standaardstatus van de boeking in dit sjabloon
operation-template-field-status = Boekingsstatus
operation-template-group-classification = Gegevens van het sjabloon voor indeling en berekening van de statistieken
operation-template-field-category = Categorie
operation-template-field-assignment = Toewijzing
operation-template-field-mode = Wijze
operation-template-field-payee = Relatie
operation-template-field-project = Project

# De knop „Sjabloon” van de boekingsfiche: één pictogram, twee gebaren.
operation-template-question = Wat wilt u met de boekingssjablonen doen?
operation-template-apply = Een sjabloon toepassen
operation-template-save-as = Als sjabloon opslaan
operation-template-applied = Sjabloon toegepast. Bevestig de fiche om het op te slaan.
operation-template-saved-as = Boeking als sjabloon opgeslagen.
operation-template-needs-label = Geef de boeking een naam voordat u er een sjabloon van maakt.

# --- F26 / F27 — Het budget (fase 11) -----------------------------------
# Twee deuren, twee vragen: men voert zijn budget in, of men controleert of
# het is nageleefd. De as is de budgetpost, de eenheid is het jaar, en de
# tekenafspraak is die van de boekingen — een uitgave wordt negatief
# geschreven.

window-budget-entry-title = Budgetinvoer: geplande uitgaven(-) en inkomsten(+) over een jaar
window-budget-control-title = Budgetcontrole

budget-column-line = Budgetpost
budget-none = Er is geen enkele budgetpost opgeslagen: het budget wordt per post ingevoerd.
budget-planned = Gepland
budget-actual = Gerealiseerd
budget-sum = Som
budget-cumulative = Cumulatief
budget-total = Totaal
# De herinnering aan de tekenafspraak, in het rood onder de invoertabel.
# Zijn zin, woord voor woord en inclusief de spaties (schermafdruk „POINT 004
# saisie budget.png”): ze staat in het rood onder de tabel, en de venstertitel
# herhaalt ze verkort. Niemand zou de afspraak zonder haar raden.
budget-sign-warning = Voer de uitgaven verplicht  in met een negatief teken en de geplande inkomsten met positieve bedragen
budget-entry-help = Typ de bedragen in de vakken en sla vervolgens op.
budget-saved = Budget opgeslagen.
budget-nothing-changed = Geen wijziging om op te slaan.
budget-discard-question = Wijzigingen aan het budget verwerpen?

# Het menu Weergave van de controle: de twee manieren om hetzelfde verschil te
# lezen.
budget-menu-display = Weergave
budget-display-money = Waarden
budget-display-percent = Percentages
budget-control-help = Groen: minstens zo goed als gepland. Rood: minder goed.

# --- F09 — Overboeking van een bedrag tussen twee rekeningen (fase 12) ---
# Een overschrijving is geen boeking, het zijn er twee: een debet op de bron,
# een credit op de bestemming. Ze vertrekken samen of helemaal niet.

window-transfer-title = Een bedrag tussen twee rekeningen overboeken

transfer-group-source = Het bedrag van deze bronrekening afboeken
transfer-group-target = Het bedrag op deze bestemmingsrekening bijschrijven
transfer-group-description = Omschrijving van de boeking
transfer-group-nomenclature = Gegevens van de stamgegevens
transfer-group-amount = Bedrag van de over te boeken som
transfer-field-source = Bronrekening
transfer-field-target = Bestemmingsrekening
transfer-field-label = Omschrijving
transfer-field-reference = Betalingsreferentie
transfer-field-date = Datum
transfer-field-status = Boekingsstatus
transfer-field-clearing = Afstemdatum
transfer-field-category = Categorie
transfer-field-mode = Betaalwijze
transfer-field-assignment = Toewijzing
transfer-field-payee = Relatie / handelaren
transfer-field-project = Project
transfer-field-amount = Bedrag

# De enige knop van de panelen die iets melden in plaats van iets te vragen.
ui-ok = OK
transfer-help = Kies de twee rekeningen: hun saldi worden hier weergegeven.
transfer-title-validate = Overschrijving uitvoeren
# De drie saldi van de gekozen rekening, om te weten wat de overschrijving betekent.
transfer-balances = { $account } — Banksaldo: { $bank } · Werkelijk: { $real } · Eindsaldo: { $final }
# Het paneel dat samenvat wat er zojuist is weggeschreven.
transfer-done = Overschrijving uitgevoerd. { $amount } van rekening { $source } naar rekening { $target }, op { $date }.

transfer-refusal-accounts-required = Kies de bronrekening en de bestemmingsrekening
transfer-refusal-same-account = De bronrekening en de bestemmingsrekening kunnen niet dezelfde zijn: een overschrijving gaat van de ene rekening naar een andere
transfer-refusal-account-gone = Een van beide rekeningen bestaat niet meer
transfer-refusal-label-required = De omschrijving is verplicht
transfer-refusal-date-required = De datum is verplicht
transfer-refusal-amount = Het over te boeken bedrag moet strikt positief zijn

# ---------------------------------------------------------------------------
# Fase 13 — de import van een Excel-blad (F34, F35, koppeling).
# ---------------------------------------------------------------------------

window-excel-import-title = Import van Excel-blad [ Stap 1/3 ]: bepaling van het opnamegebied
window-excel-fields-title = Import van Excel-blad [ Stap 2/3 ]: koppeling van de velden
window-excel-association-title = Import van Excel-blad: koppeling van de gegevens

# De vraag die bij het openen wordt gesteld. Een Excel-bestand wordt met de hand
# gemaakt: het bevat wat het bevat, en een deel van de onzin die erin staat is
# niet te ontdekken. We bieden dus het vangnet aan vóór de sprong.
excel-backup-question = Een Excel-blad wordt met de hand gemaakt: het kan data bevatten die geldig en toch verkeerd zijn, bedragen met de juiste opmaak en het verkeerde teken — en dat kan geen enkele controle zien. De import schrijft die rijen in uw rekening. Wilt u een back-up van uw gegevens maken voordat u begint?

excel-group-file = 1 - Het te importeren Excel-bestand aanwijzen
excel-pick = Het Excel-bestand aanwijzen
excel-sheet = Blad van de werkmap:
excel-group-header = 2 - Bepalen: celcoördinaten van de koprij van de tabel waar de kolomnamen staan.
excel-header-row = Nummer van de eerste rij waar de kolomnamen staan
excel-first-column = Eerste kolom van de koprij ( kolom uiterst links ):
excel-column-count = Aantal kolommen van de tabel
excel-group-rows = 3 - Bepalen: nummers van de eerste en de laatste rij van de lijst met de gegevens van de tabel ( onder de koprij en zonder die rij )
excel-first-data-row = Eerste rij met gegevens
excel-last-data-row = Laatste rij met gegevens:
excel-group-shape = 4 - Bepalen: hoe uw bestand de bedragen schrijft
excel-shape-single = Eén enkele kolom met bedragen, met teken ( uitgaven negatief )
excel-shape-debit-credit = Twee aparte kolommen: een kolom Debet en een kolom Credit
excel-shape-note = In de modus met twee kolommen telt het teken in de kolom Debet niet mee: een debet haalt altijd geld weg, of er nu “-50” of “50” staat.
excel-group-test = 5 - Testweergave: bekijk de opname zoals uw instellingen die opleveren
excel-test = Test de instellingen die u in stap 2, 3 en 4 hebt bepaald.
excel-test-note = Aanwijzing: de namen van de koppen en de inhoud van de tabel hieronder moeten overeenkomen met die van uw Excel-tabel. Het opnamegebied mag niet buiten het gebied van de tabel vallen.

excel-help = Loop de vijf groepen op volgorde af en test daarna: u kunt pas naar stap 2 als u hebt gezien wat het gebied opvangt.
excel-no-file = Wijs eerst het te importeren Excel-bestand aan.
excel-not-tested = Instellingen gewijzigd: start de testweergave opnieuw voordat u bevestigt.
excel-tested = Opgenomen gebied: { $rows } rijen, { $columns } kolommen. Controleer of de tabel hieronder op uw blad lijkt.
excel-empty-capture = Het gebied dat u hebt opgegeven vangt geen enkele rij op: controleer de rij- en kolomnummers.
excel-title-next = Naar de volgende stap gaan
excel-into-account = Import in de rekening { $account }.

excel-tab-links = Koppelingen tussen velden
excel-tab-settings = Importinstellingen
excel-column-excel = Kop_Excel
excel-column-radinus = Rubriek_Radinus
excel-links-help = Geef naast elke kolom van uw blad aan welke rubriek van Radinus die vult. Kolommen die op [IGNORE] blijven staan, worden niet geïmporteerd.
excel-group-category = Categorieën zonder overeenkomst
excel-group-payment-mode = Betaalwijze zonder overeenkomst
excel-group-assignment = Toewijzing zonder overeenkomst
excel-policy-create = { $kind ->
    [payment-mode] Niet-bestaande betaalwijzen automatisch aanmaken
    [assignment] Niet-bestaande toewijzingen automatisch aanmaken
   *[category] Niet-bestaande categorieën automatisch aanmaken
}
excel-policy-ask = { $kind ->
    [payment-mode] Voor elke niet-bestaande betaalwijze vragen waar de gegevens naartoe moeten
    [assignment] Voor elke niet-bestaande toewijzing vragen waar de gegevens naartoe moeten
   *[category] Voor elke niet-bestaande categorie vragen waar de gegevens naartoe moeten
}
excel-policy-blank = { $kind ->
    [payment-mode] De betaalwijze leeg laten
    [assignment] De toewijzing leeg laten
   *[category] De categorie leeg laten
}
excel-policy-default = { $kind ->
    [payment-mode] Niet-bestaande betaalwijzen naar een standaardbetaalwijze overbrengen
    [assignment] Niet-bestaande toewijzingen naar een standaardtoewijzing overbrengen
   *[category] Niet-bestaande categorieën naar een standaardcategorie overbrengen
}
excel-define-destination = Bestemming bepalen
excel-not-linked = { $kind ->
    [payment-mode] Geen enkele kolom vult de betaalwijze: deze instelling is niet van toepassing.
    [assignment] Geen enkele kolom vult de toewijzing: deze instelling is niet van toepassing.
   *[category] Geen enkele kolom vult de categorie: deze instelling is niet van toepassing.
}
excel-fields-help = Stel de overeenkomsten in en daarna de drie regels, voordat u de import start.
excel-title-import = De import starten

excel-refusal-required = De rubrieken Datum, Omschrijving en Bedrag moeten verplicht naar Excel-kolommen verwijzen
excel-refusal-column-twice = Verschillende Radinus-rubrieken verwijzen naar dezelfde Excel-kolom: een kolom kan maar één rubriek vullen
excel-refusal-field-twice = Dezelfde Radinus-rubriek is aan twee Excel-kolommen gekoppeld: ze kan er maar één hebben
excel-refusal-ask-unset = { $kind ->
    [payment-mode] U hebt gekozen om te vragen waar onbekende betaalwijzen naartoe moeten: druk op “Bestemming bepalen” voordat u de import start.
    [assignment] U hebt gekozen om te vragen waar onbekende toewijzingen naartoe moeten: druk op “Bestemming bepalen” voordat u de import start.
   *[category] U hebt gekozen om te vragen waar onbekende categorieën naartoe moeten: druk op “Bestemming bepalen” voordat u de import start.
}

excel-column-data = Gegevens_Excel
excel-column-destination = { $kind ->
    [payment-mode] Betaalwijze_Radinus
    [assignment] Toewijzing_Radinus
   *[category] Categorie_Radinus
}
excel-association-help = Kies naast elke waarde uit uw blad die van Radinus waaronder ze moet worden ingedeeld. Een rij die leeg blijft, blijft zonder indeling.
excel-association-none = Geen enkele onbekende waarde: alles wat uw blad bevat, bestaat al in Radinus.

excel-imported = Import voltooid: { $count } boekingen weggeschreven, { $refused } rijen geweigerd, { $created } waarden in de stamgegevens aangemaakt.
excel-report-title = Verslag van de import
excel-column-row = Excel-rij
excel-column-content = Inhoud
excel-column-reason = Reden van weigering
excel-nothing-refused = Alle rijen van uw blad zijn overgenomen: geen enkele weigering.

excel-refused-date = Datum ontbreekt of is onleesbaar
excel-refused-amount = Bedrag ontbreekt of is onleesbaar
excel-refused-amount-both = Een bedrag in de kolom Debet en een ander in de kolom Credit: kiezen is onmogelijk
excel-refused-amount-missing = Geen debet en geen credit op deze rij

# ---------------------------------------------------------------------------
# Fase 16 — de terugkerende boekingen (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Lijst van terugkerende boekingen
window-recurring-form-title = Fiche die de regel voor het genereren van terugkerende boekingen bepaalt
window-recurring-calendar-title = Voorstel voor de kalender van boekingen die in uw bankrekeningen moeten worden ingevoegd

recurring-column-label = OMSCHRIJVING
recurring-none = Geen terugkerende regel opgeslagen.
recurring-help = Kies een regel en daarna de kalender om de vervaldata te zien die ze voorstelt.
recurring-title-calendar = De kalender met vervaldata voorstellen
recurring-deleted = { $count ->
    [0] Geen regel verwijderd.
    [one] Eén regel verwijderd. Haar boekingen blijven in de rekening.
   *[other] { $count } regels verwijderd. Hun boekingen blijven in de rekeningen.
}
recurring-gone = Deze regel bestaat niet meer.
recurring-delete-question = De geselecteerde regels verwijderen? De boekingen die ze al hebben ingevoegd, blijven in uw rekeningen.

recurring-group-identity = Identificatie en betrokken bankrekening
recurring-group-nomenclature = Stamgegevens
recurring-group-amount = Bepaling van het bedrag van de boeking
recurring-group-period = Bepaling van het interval
recurring-group-ending = Voorwaarden voor het einde van het interval
recurring-group-produced = Informatie over al ingevoegde boekingen ( alleen ter inzage )

recurring-field-id = Identificatie van de boeking
recurring-field-account = Doelrekening
recurring-field-label = Omschrijving
recurring-field-category = Categorie
recurring-field-mode = Betaalwijze
recurring-field-assignment = Toewijzing
recurring-field-payee = Relatie / handelaar
recurring-field-project = Project
recurring-field-direction = Soort boeking
recurring-field-amount = Bedrag
recurring-field-next = Datum volgende boeking
recurring-field-every = Daarna elke
recurring-field-end-date = Einddatum
recurring-field-repeat = Aantal herhalingen
recurring-field-guid = GUID boeking
recurring-field-produced-count = Aantal ingevoegde boekingen
recurring-field-produced-last = Datum laatste ingevoegde boeking
recurring-field-produced-total = Totaal gegenereerde bedragen

recurring-unit-day = Dag
recurring-unit-week = Week
recurring-unit-month = Maand
recurring-unit-quarter = Kwartaal
recurring-unit-year = Jaar
recurring-ending-no-limit = Zonder limiet
recurring-ending-until-date = Met einddatum
recurring-ending-repeat-count = Aantal herhalingen

recurring-title-erase = De boekingen wissen die deze regel al heeft ingevoegd
recurring-erase-question = { $count ->
    [one] Deze regel heeft één boeking in uw rekeningen ingevoegd. Wilt u die wissen? De saldi worden herberekend en de regel gaat niet terug.
   *[other] Deze regel heeft { $count } boekingen in uw rekeningen ingevoegd. Wilt u ze allemaal wissen? De saldi worden herberekend en de regel gaat niet terug.
}
recurring-erase-none = Deze regel heeft nog geen enkele boeking ingevoegd.
recurring-erased = { $count ->
    [0] Geen boeking gewist.
    [one] Eén boeking gewist, saldi herberekend.
   *[other] { $count } boekingen gewist, saldi herberekend.
}

recurring-calendar-help = Haal met de prullenbak de vervaldata weg die u niet wilt en bevestig daarna om ze in te voegen.
recurring-calendar-none = Geen enkele vervaldatum om voor te stellen: controleer de datum van de volgende boeking en de rekening van uw regels.
recurring-calendar-column-account = Rekening
recurring-calendar-column-date = Datum
recurring-calendar-column-label = Beschrijving
recurring-calendar-column-amount = Bedrag
recurring-calendar-column-category = Categorie
recurring-calendar-column-assignment = Toewijzing
recurring-calendar-column-mode = Betaalwijze
recurring-calendar-column-payee = Relatie
recurring-calendar-column-project = Projecten
recurring-calendar-removed = { $count ->
    [one] Eén vervaldatum uit het voorstel gehaald.
   *[other] { $count } vervaldata uit het voorstel gehaald.
}
recurring-title-insert = De behouden vervaldata in de rekeningen invoegen
recurring-nothing = Er blijft geen enkele vervaldatum meer over om in te voegen.
# De vraag die vóór het wegschrijven wordt gesteld: een kalender invoegen maakt echte
# boekingen in echte rekeningen aan, en dat gebeurt niet met een verstrooide klik.
recurring-insert-question = { $count ->
    [one] Deze vervaldatum in uw rekening invoegen? Er wordt één boeking aangemaakt en de saldi worden herberekend.
   *[other] Deze { $count } vervaldata in uw rekeningen invoegen? Er worden evenveel boekingen aangemaakt en de saldi worden herberekend.
}
recurring-inserted = { $count ->
    [one] Eén boeking ingevoegd. De regel loopt verder na de laatste ingevoegde vervaldatum.
   *[other] { $count } boekingen ingevoegd. De regels lopen verder na hun laatste ingevoegde vervaldatum.
}

recurring-refusal-label-required = Het invullen van een omschrijving is verplicht
recurring-refusal-date-required = Het invullen van de datum van de volgende boeking is verplicht
recurring-refusal-date-too-old = De datum van de volgende boeking moet in het jaar 2000 of later liggen
recurring-refusal-account-gone = De opgegeven bankrekening is onvindbaar; selecteer een nieuwe om de regel toepasbaar te maken
recurring-refusal-end-required = Bij een einddatum moet die datum worden ingevuld
recurring-refusal-end-before-start = De einddatum kan niet vóór de datum van de volgende boeking liggen
recurring-refusal-end-too-far = Het verschil tussen de datum van de volgende boeking en de einddatum mag niet meer dan 10 000 dagen bedragen

# --- Fase 15 — de afdrukken en overzichten -----------------------------
# De grote titel van de banner, woord voor woord overgenomen uit het oorspronkelijke WinDev-overzicht.
print-operations-title = Lijst van banktransacties en deelboekingen
print-menu-operations-pdf = Afdrukken naar PDF-bestand
print-recap-title = Overzicht per categorie
print-recap-count = Rijen
print-row-count = Aantal rijen:
print-total-debit = Totaal debet:
print-total-credit = Totaal credit:
print-final-balance = Eindsaldo:
print-licence = Radinus is vrije software onder de GNU GPL v3-licentie of later
print-nothing = Er is niets af te drukken.
print-done = Overzicht afgedrukt en geopend: “{ $file }”.
print-failed = Afdrukken niet mogelijk: { $reason }
# De PDF is wel degelijk geschreven, maar het systeem kon hem niet openen: we
# zeggen het zonder een mislukking te suggereren, want het bestand is er.
print-not-opened = Overzicht afgedrukt in “{ $file }”, maar uw systeem kon het niet vanzelf openen.

# --- Het RIB-overzicht (F32) -------------------------------------------
# De opschriften van het bankidentiteitsbewijs, overgenomen uit het oorspronkelijke document.
rib-title = BANKGEGEVENS
rib-bank = Bank:
rib-national = RIB - Nationale rekeningidentificatie
rib-establishment = INSTELLING
rib-branch = KANTOOR
rib-number = REKENINGNUMMER
rib-key = RIB-CONTROLEGETAL
rib-domiciliation = REKENINGHOUDEND KANTOOR
rib-iban = IBAN - Internationale rekeningidentificatie
rib-bic = BIC - Internationale identificatie van de instelling
rib-holder = Rekeninghouder

# --- Het venster F32 ---------------------------------------------------
window-rib-title = Afdrukken van RIB ( Relevé d'Identité Bancaire )
rib-group-bank = Bank
rib-group-holder = Rekeninghouder
rib-group-details = Bankgegevens
rib-field-bank = Naam bank
rib-field-domiciliation = Rekeninghoudend kantoor
rib-field-holder = Naam van de houder
rib-field-address = Adres
rib-field-establishment = Instelling
rib-field-branch = Kantoor
rib-field-number = Rekeningnummer
rib-field-key = RIB-controlegetal
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Belangrijke gebruiksvoorwaarden die bij het afdrukken verplicht in acht moeten worden genomen
rib-declaration = Ik, ondergetekende gebruiker van de software, verklaar op erewoord:
rib-declaration-first = - Bevestig bij mijn bank te hebben gecontroleerd dat de bankgegevens in dit venster juist zijn en overeenkomen met mijn wil . Bevestig op dezelfde wijze dat ik mij ertoe verbind te controleren dat de gegevens in het afdrukoverzicht van het RIB juist zijn en overeenkomen met mijn wil. Dit afdrukken en het gebruik van het RIB gebeuren onder mijn volledige verantwoordelijkheid
rib-declaration-second = - De houder te zijn van de rekening waarvan het RIB wordt afgedrukt, en de functies van deze software niet te gebruiken voor een doel dat in strijd is met de wet.
rib-title-print = Afdrukken op printer
rib-title-pdf = Afdrukken naar PDF-bestand
# Het vakje is geen decoratieve waarschuwing: zolang het niet is aangevinkt,
# zijn beide knoppen uitgeschakeld (arbitrage van Fabrice, 01/08/2026).
rib-declaration-required = Vink de verklaring op erewoord aan om te kunnen afdrukken.
rib-help = Controleer uw gegevens, vink de verklaring aan en druk dan af.
rib-account-gone = Deze bankrekening is niet te vinden.
rib-fields-read-only = Deze gegevens komen uit de rekeningfiche: corrigeer ze in de fiche om ze hier te wijzigen.
rib-printed = RIB naar uw standaardprinter verzonden.
rib-print-failed = Afdrukken niet mogelijk: { $reason }
rib-pdf-done = RIB afgedrukt en geopend: “{ $file }”.
rib-pdf-not-opened = RIB afgedrukt in “{ $file }”, maar uw systeem kon het niet vanzelf openen.
menu-accounts-bank-details = Een bankidentiteitsbewijs opmaken

# De keuze van de printer. Radinus stelt de vraag zelf: geen van de drie
# webviews opent het afdrukvenster van het systeem.
print-choose-printer = Op welke printer wilt u afdrukken?
print-do-print = Afdrukken
rib-printed-on = RIB naar de printer “{ $printer }” verzonden.
ui-cancel = Annuleren

# Het systeem kon geen enkele printer benoemen: we drukken toch af op de
# standaardprinter in plaats van de gebruiker te blokkeren.
print-printers-unknown = Uw systeem kon geen enkele printer benoemen: het document is naar de standaardprinter gegaan.

print-menu-operations-printer = Afdrukken op printer
print-sent-on = Overzicht naar de printer “{ $printer }” verzonden.
print-sent-default = Overzicht naar uw standaardprinter verzonden.

# --- Fase 17 — de bewerkingen op de database ----------------------------
backup-archive = Radinus-archief
backup-no-database = Er is geen database geopend.
backup-done = De back-up van de database “{ $base }” is geschreven in “{ $file }”. De andere databases worden niet beïnvloed.
backup-failed = Back-up niet mogelijk: { $reason }
backup-not-started = De back-up kon niet worden gestart:
restore-unreadable = Dit bestand is geen leesbaar Radinus-archief: { $reason }
# De vraag zegt wat er verloren gaat voordat het verloren gaat. Het archief is
# op dat moment al gelezen: wat zij aankondigt, is zeker.
restore-question = “{ $file }” terugzetten in de database “{ $base }”? De volledige huidige inhoud van deze database wordt gewist en vervangen, en wat zich daarin bevindt, gaat verloren. De andere databases blijven onaangeroerd.
restore-done = De database “{ $base }” is teruggezet: { $accounts } rekeningen en { $operations } boekingen. De andere databases blijven onaangeroerd.
restore-failed = Terugzetten niet mogelijk: { $reason }
restore-empty-fields = Lege velden gelezen als nulwaarde: { $count }.


# --- Het logboek van de technische bewerkingen (fase 17) ----------------
# De drie statussen van zijn Ajoute_Log, in hoofdletters zoals bij hem.
journal-status-success = GESLAAGD
journal-status-failure = MISLUKT
journal-status-repaired = GEREPAREERD
journal-step-reindex = Reparatie databasetabel
journal-step-refill = Systeemstamgegevens leeg: standaardwaarden hersteld
journal-step-table-created = Tabel ontbreekt in de database: leeg opnieuw aangemaakt
journal-step-column-added = Kolom ontbreekt in de tabel: toegevoegd met zijn standaardwaarde

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Beveiliging met wachtwoord
window-password-form-title = Beveiliging met wachtwoord
password-ask = Deze database is beveiligd. Voer het wachtwoord in.
password-group-database = Betrokken database
password-group-password = Wachtwoord
password-group-warning = Voordat u bevestigt
password-field-old = Oud wachtwoord
password-field-new = Nieuw wachtwoord
password-field-repeat = Herhaal het nieuwe wachtwoord
password-hint = Laat het oude leeg als de database nog niet beveiligd is. Laat beide nieuwe leeg om de beveiliging op te heffen.
password-lost-warning = Een verloren wachtwoord is een verloren database: niets kan haar terughalen. De back-ups blijven daarentegen onversleuteld.
password-show = Wachtwoord tonen
password-remove-question = De beveiliging van deze database opheffen?
password-mismatch = De twee invoeren van het nieuwe wachtwoord verschillen
password-wrong = Het wachtwoord past niet
database-too-recent = Deze database is opgeslagen door een recentere versie van Radinus (databaseversie { $found }; deze versie leest tot en met versie { $supported }). Werk Radinus bij om ze te openen.
database-not-radinus = Dit bestand is geen Radinus-database.
database-unreadable = De database kon niet worden gelezen: { $reason }
password-close-first = Sluit deze database voordat u het wachtwoord wijzigt
password-now-protected = De database is beveiligd met een wachtwoord
password-now-clear = De database is niet meer beveiligd
journal-step-date-fixed = Correctie van een boeking zonder datum
journal-step-circular = Verwijdering van een inconsistente boeking: circulaire verwijzing
journal-step-flag-parent-true = Verkeerde vlag EstParent=Onwaar op een hoofdboeking
journal-step-flag-parent-false = Verkeerde vlag EstParent=Waar op een hoofdboeking
journal-step-flag-child = Verkeerde vlag EstParent=Waar op een deelboeking
journal-step-orphan = Verwijdering van een verweesde deelboeking
journal-step-third-level = Verwijdering van een deelboeking die aan een andere deelboeking was gekoppeld
journal-step-coherence = Algemene herberekening van de samenhang tussen deelboekingen en hoofdboekingen
journal-step-balances = Herberekening van alle saldi van alle rekeningen
journal-step-vacuum = Optimalisatie van het databasebestand
journal-step-analyze = Bijwerken van de zoekstatistieken
journal-step-backup-begin = Begin van de back-up van de database
journal-step-backup-end = Einde van de back-up van de database
journal-step-restore-begin = Begin van het terugzetten van de database uit het archief
journal-step-restore-end = Einde van het terugzetten van de database uit het archief
journal-step-restore-read = Lezen van het archief

# --- Het venster van het logboek (⌘H) -----------------------------------
window-journal-title = Logboek van de laatste technische bewerking
journal-column-step = Stap
journal-column-file = Bestand
journal-column-table = Tabel
journal-column-status = Status
journal-column-error = Fout
journal-column-comments = Opmerkingen
journal-empty = Sinds het openen van de software is er nog geen enkele technische bewerking uitgevoerd.
journal-help = Het logboek bewaart alleen de laatste technische bewerking: back-up, terugzetten, reparatie, wissen of het openen van een database.

# --- De reparatie -------------------------------------------------------
menu-file-repair-running = Reparatie en optimalisatie bezig…
repair-done = { $anomalies ->
    [0] Reparatie van de database “{ $base }” voltooid: geen enkele afwijking gevonden. { $lines } stappen gelogd. De andere databases worden niet beïnvloed.
    [one] Reparatie van de database “{ $base }” voltooid: één afwijking gerepareerd. { $lines } stappen gelogd. De andere databases worden niet beïnvloed.
   *[other] Reparatie van de database “{ $base }” voltooid: { $anomalies } afwijkingen gerepareerd. { $lines } stappen gelogd. De andere databases worden niet beïnvloed.
}
repair-failed = Reparatie niet mogelijk: { $reason }

journal-status-started = BEZIG
journal-status-finished = VOLTOOID
journal-step-backup-table = Schrijven van de tabel in het archief
journal-step-backup-write = Schrijven van het archief
journal-step-backup-verified = Controle van het geschreven archief: bestanden teruggelezen / verwacht, records teruggelezen / geschreven
journal-step-backup-total = Totaal geback-upt: records, gegevens, bestandsgrootte
journal-step-restore-table = Lezen van de tabel in het archief
journal-step-restore-missing = Bestand ontbreekt in het archief: deze tabel wordt niet teruggezet
journal-step-restore-wipe = Volledige wissing van de inhoud van de database vóór het terugzetten
journal-step-restore-write = Schrijven in de database
journal-step-restore-total = Totaal teruggezet: rekeningen, boekingen
journal-step-restore-empty-fields = Lege velden ingevuld tijdens het lezen
backup-verify-mismatch = Het geschreven archief laat zich niet teruglezen zoals het is geschreven: vertrouw er niet op, maak de back-up opnieuw.

# --- De bijlagen van een boeking (F28, fase 17) -------------------------
window-attachments-title = Bijlagen van de boeking
attachment-filter = Toegestane documenten
attachment-none = Deze boeking draagt geen enkele bijlage.
attachment-title-add = Een document aan deze boeking hechten
attachment-title-open = De bijlage openen
attachment-title-remove = De bijlage verwijderen en haar bestand naar de prullenbak sturen
# De staat van het bestand op de schijf. “Niet controleerbaar” is geen gratuite
# bekentenis van onwetendheid: de vingerafdrukken uit Radinus 1.9.3 zijn door het
# back-upformaat verminkt, en een bestand daarop beoordelen zou lukraak beschuldigen zijn.
attachment-state-ok = Intact
attachment-state-changed = Gewijzigd
attachment-state-missing = Bestand ontbreekt
attachment-state-unknown = Niet controleerbaar
attachment-added = “{ $name }” is aan de boeking gehecht.
attachment-removed = Bijlage verwijderd, haar bestand staat in de prullenbak.
attachment-removed-kept = Bijlage verwijderd, maar haar bestand kon niet naar de prullenbak worden verplaatst.
attachment-remove-question = “{ $name }” uit deze boeking verwijderen? Haar bestand wordt naar de prullenbak gestuurd.
attachment-opened = “{ $name }” is geopend.
attachment-opened-changed = “{ $name }” is geopend, maar haar inhoud is gewijzigd sinds zij werd gehecht.
attachment-gone = Deze bijlage bestaat niet meer.
attachment-file-missing = Het bestand van “{ $name }” is niet te vinden op de schijf.
attachment-failed = Bewerking niet mogelijk: { $reason }
attachment-save-first = Sla eerst de boeking op: een bijlage hoort bij een boeking die bestaat.
attachment-refusal-missing = Dit bestand bestaat niet.
attachment-refusal-extension = Dit bestandstype wordt niet geaccepteerd. Geaccepteerd worden: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = De boeking waaraan dit document moet worden gehecht, bestaat niet.
journal-step-backup-attachments = Bijlagen toegevoegd aan het archief
journal-step-backup-attachment-missing = Bijlage niet te vinden op de schijf: zij zal ontbreken in het archief
journal-step-restore-attachments = Bijlagen uit het archief gehaald
attachment-title-replace = Het document van deze bijlage vervangen
attachment-replaced = Het document is vervangen door “{ $name }”.

# ---------------------------------------------------------------------
# F08 — het menu “Extra” van de rekeningfiche.
#
# De drie ingangen ervan zijn porteringen van het WLangage van Fabrice (map
# “Information import export base piece jointe”): de berekening van het
# afgestemde beginsaldo, de statistieken van de rekening, en de verwijdering
# van al haar transacties. Het menu werkt alleen bij bewerken (arbitrage van
# 02/08/2026): bij het aanmaken valt er niets te tellen, bij het raadplegen
# laat de fiche alleen maar zien.
# ---------------------------------------------------------------------

account-tools = Extra
account-tools-initial-balance = Het afgestemde beginsaldo bepalen
account-tools-statistics = Statistieken bankrekening
account-tools-delete-operations = Alle transacties van de rekening verwijderen

# De vraag van de berekening, woord voor woord die van het origineel. { $total }
# is het totaal van de afgestemde boekingen, al in valutaformaat geschreven.
account-initial-balance-question =
    Om het afgestemde beginsaldo te berekenen ten aanzien van de boekingen die op deze rekening aanwezig zijn, gelieve het actuele saldo van uw bank in te vullen
    Het afgestemde beginsaldo wordt berekend als zijnde gelijk aan:
    { "[" }Actueel banksaldo] - [Totaal afgestemde boekingen ({ $total }) ].
    { "" }
    Om deze waarde niet opnieuw te hoeven invoeren, moet u volledig bij zijn met de lijst van bankboekingen op deze rekening.

account-statistics-none = Geen transactie

# De veertien regels van zijn Info(). De schrijffout “pengagés” van het origineel
# is gecorrigeerd, op beslissing van Fabrice van 02/08/2026 — net als “Bank
# Identifer Code” op ditzelfde blad.
account-statistics =
    Totaal aantal transacties in deze rekening: { $count }
    { "" }
    Aantal afgestemde transacties in deze rekening: { $pointed }
    Bedrag van de afgestemde debetposten: { $pointedDebits }
    Bedrag van de afgestemde creditposten: { $pointedCredits }
    Verschil tussen afgestemde credit- en debetposten: { $pointedDifference }
    { "" }
    Aantal gereserveerde transacties in deze rekening: { $committed }
    Bedrag van de gereserveerde debetposten: { $committedDebits }
    Bedrag van de gereserveerde creditposten: { $committedCredits }
    Verschil tussen gereserveerde credit- en debetposten: { $committedDifference }
    { "" }
    Aantal geplande transacties in deze rekening: { $planned }
    Bedrag van de geplande debetposten: { $plannedDebits }
    Bedrag van de geplande creditposten: { $plannedCredits }
    Verschil tussen geplande credit- en debetposten: { $plannedDifference }
    { "" }
    Oudste transactie: { $first }
    Meest recente transactie: { $last }

# De dubbele barrière van het verwijderen. { $word } is het “ja” van de
# huidige taal — een Spaanstalige aan wie men zou vragen OUI te schrijven zou
# het niet begrijpen (beslissing van Fabrice, 02/08/2026).
account-delete-operations-question =
    Weet u zeker dat u alle boekingen van deze bankrekening wilt verwijderen?
    Schrijf ter bevestiging { $word } in het veld hieronder en bevestig

account-delete-operations-done =
    { $count ->
        [0] Geen transactie verwijderd.
        [one] 1 transactie verwijderd.
       *[other] { $count } transacties verwijderd.
    }

# ---------------------------------------------------------------------
# De keuzelijst van de databases en de keuze van de taal (02/08/2026)
#
# Beslissingen genomen in overleg met Fabrice: Radinus maakt geen database
# meer aan zonder toestemming; zonder taal in de configuratie vraagt hij de
# taal vóór al het andere; een database is elke map van databases/ die een
# radinus.sqlite bevat, welke naam die map ook draagt.
#
# Het venster van de taalkeuze heeft hier geen enkele sleutel: het gebruikt
# geen enkele zin, en juist daardoor kan het begrepen worden voordat men
# weet welke taal de gebruiker spreekt.
# ---------------------------------------------------------------------

window-database-selector-title = Databases
window-database-form-title = Nieuwe database
database-group-identity = Identificatie van de database
database-group-restore = De database initialiseren met de gegevens van een back-up
database-choose-backup = Back-upbestand selecteren
database-no-backup = Geen back-up gekozen: de database wordt leeg aangemaakt.

databases-column-label = Database
databases-column-comment = Commentaar
databases-column-folder = Map
databases-column-created = Aangemaakt op

databases-none = Nog geen database: maak er een aan.
databases-help = Kies de database die u wilt openen, of maak een nieuwe aan.
databases-select = Kies eerst een database in de lijst.
databases-tools = Extra
databases-title-open = Deze database openen

database-created = De database “{ $label }” is aangemaakt.
database-field-label = Naam van de database
database-field-comment = Commentaar
database-label-required = Geef deze database een naam: die onderscheidt haar van de andere.
database-gone = Deze database is er niet meer: ze is verplaatst of gewist sinds dit venster is geopend.

# Het verwijderen van een database (02/08/2026). De map gaat naar de
# prullenbak van het systeem, net als de bijlagen: een per ongeluk gewiste
# database komt met een rechterklik terug. De geopende database wordt
# geweigerd — Radinus houdt haar bestand vast.
databases-title-delete = Deze database verwijderen
database-delete-question =
    Weet u zeker dat u de database “{ $label }” wilt verwijderen?
    { "" }
    Haar hele map gaat naar de prullenbak: de boekingen, de rekeningen en de bijlagen.
    Schrijf ter bevestiging { $word } in het veld hieronder en bevestig.
database-in-use = Deze database is geopend: Radinus kan haar niet verwijderen. Open eerst een andere.
database-deleted = De database “{ $label }” staat in de prullenbak.

# De keuzelijst heeft twee standen (Fabrice, 02/08/2026). Tijdens het werken
# geopend, kan zij niet meer openen: een venster van Radinus wordt één keer
# gebouwd en nooit afgebroken, en niets kan het de database doen vergeten die
# het toont. Men kijkt, men maakt aan, men verwijdert — en om van database te
# wisselen, sluit men af.
database-quit-first = Om deze database te openen, sluit Radinus af en start het opnieuw: de keuzelijst biedt haar u aan bij het starten.


# --- F01 — het startvenster (fase 17 bis, 03/08/2026) ---------------------
#
# Eerste toevoeging van 2.0.0 op 1.9.3: het startvenster draagt niet meer
# alleen de banner. De regel die het bestuurt staat in document 04 F01:
# het is het beeld ZONDER ÉÉN KLIK, en niets wat een instelling vraagt komt
# erin.
#
# De twee titels van de ringdiagrammen dragen de hele maand in plaats van door
# het venster stuk voor stuk aan elkaar geplakt te worden: “Uitgaven ... —
# augustus 2026” heeft in de drie talen niet dezelfde woordvolgorde, en alleen
# Fluent weet waar het gat zit.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Geen rekening open
    [one] 1 rekening open
   *[other] { $count } rekeningen open
}
welcome-total-bank = Banksaldo
welcome-total-real = Werkelijk saldo
welcome-total-final = Eindsaldo
welcome-total-real-detail = afgestemd + gereserveerd
welcome-total-final-detail = afgestemd + gereserveerd + gepland
welcome-accounts = Uw rekeningen
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Rekeningen meegeteld in de totalen: { $count } van { $total }
welcome-tile-counted = Deze rekening meetellen in de totalen
welcome-tile-bank = Bij de bank
welcome-tile-real = Werkelijk
welcome-tile-final = Eind
welcome-spending = Uitgaven — { $month }
welcome-earning = Inkomsten — { $month }
ui-legend-budget-lines = Budgetposten
ui-legend-categories = Categorieën
welcome-nothing = Geen boeking deze maand.
welcome-open-account = Info: klik op een rekening om haar boekingen te openen.
welcome-no-account = Nog geen bankrekening.
welcome-no-account-create = Maak een bankrekening aan door hier te klikken
welcome-previous-month = Vorige maand
welcome-next-month = Volgende maand
welcome-refresh = Alles opnieuw inlezen


# --- F39 — de voorkeuren (fase 17 ter, 03/08/2026) ------------------------
#
# De plaats van het valutateken woont hier, naast de twee scheidingstekens:
# zij volgt de taal en niet de valuta. “before” zet het teken vóór het getal,
# elke andere waarde zet het erachter. GEEN ENKEL valutateken staat in dit
# bestand: “Nederlands” betekent niet “euro”.

ui-money-sign-position = before
window-preferences-title = Voorkeuren
menu-settings-preferences = Voorkeuren…
menu-settings-show-main = Hoofdvenster tonen
menu-settings-folders = Mappen van Radinus
preferences-branch-display = Weergave
preferences-leaf-language = Taal
preferences-leaf-currency = Valuta
preferences-field-language = Taal van het programma:
preferences-field-currency = Weergegeven valuta:
preferences-field-custom = Teken van de valuta:
preferences-currency-system = Systeemvaluta
preferences-currency-euro = Euro
preferences-currency-dollar = Dollar
preferences-currency-canadian = Canadese dollar
preferences-currency-cfa = CFA-frank
preferences-currency-cfp = CFP-frank
preferences-currency-swiss = Zwitserse frank
preferences-currency-none = Geen
preferences-currency-custom = Aangepast
preferences-currency-system-is = Uw systeem meldt:
preferences-currency-system-silent = Uw systeem meldt geen enkele valuta: de bedragen worden in euro's weergegeven.
preferences-custom-required = Typ het teken van uw valuta voordat u opslaat.
preferences-saved = Voorkeuren opgeslagen.
preferences-help = Kies een optie in de boom en sla daarna op.
preferences-sign-too-long = Het teken van een valuta beslaat hoogstens 8 tekens.
preferences-sign-not-a-number = Het teken van een valuta mag geen cijfer, geen rekenteken en geen komma bevatten: Radinus haalt die weg wanneer het een bedrag leest, en “120” zou “12” worden.
preferences-leaf-zoom = Grootte van de weergave
preferences-field-zoom = Vergroting:
preferences-zoom-reset = Standaardwaarde
preferences-zoom-hint = Alles wordt samen groter: de tekst, de pictogrammen, de kolommen. Onder 100 % past er meer op het scherm. De menubalk van het systeem en zijn dialoogvensters volgen daarentegen de instellingen van uw computer en niet deze hier.
preferences-branch-import = Import
preferences-leaf-verification = Controle
preferences-field-verification = Geïmporteerde boekingen:
preferences-verification-hint = ‘Gecontroleerd’: u vertrouwt uw bank, een geïmporteerde boeking wordt als juist beschouwd. ‘Te controleren’: elke geïmporteerde boeking wacht op uw controle; daarna zet u ze zelf op ‘Gecontroleerd’ in de boekingenlijst. Deze instelling geldt alleen voor toekomstige imports.
preferences-leaf-ofx = OFX-bankafschriften
preferences-field-ofx-label = Omschrijving van de boeking:
preferences-field-ofx-reference = Betaalreferentie:
preferences-ofx-choice-name = De naam van de boeking
preferences-ofx-choice-memo = Het memo van de bank
preferences-ofx-choice-name-and-memo = De naam gevolgd door het memo
preferences-ofx-choice-empty = Niets (leeg laten)
preferences-ofx-label-help = Wat er in de omschrijving van een geïmporteerde boeking komt. De naam is wat de bank toont, bijvoorbeeld ‘PRLV SEPA’; sommige banken voegen er een gedetailleerd memo aan toe: de schuldeiser van een incasso, de begunstigde en het doel van een overschrijving. Als een boeking geen memo heeft, behoudt de omschrijving de naam.
preferences-ofx-reference-help = Wat er in de betaalreferentie van een geïmporteerde boeking komt, waar u die kunt zien en erop kunt filteren. Als een boeking geen memo heeft, laat ‘Het memo van de bank’ de referentie leeg. Als het memo de naam al herhaalt, wordt het niet twee keer geschreven.
preferences-ofx-hint = Deze instellingen gelden voor alle OFX-bankafschriften, welke database ook geopend is. Ze worden toegepast op het volgende bankafschrift dat u opent.
preferences-leaf-qif = QIF-bankafschriften
preferences-field-qif-order = Volgorde van dag en maand:
preferences-qif-order-ask = Mij elke keer vragen
preferences-qif-order-day-month = Altijd dag/maand (05/03 = 5 maart)
preferences-qif-order-month-day = Altijd maand/dag (05/03 = 3 mei)
preferences-qif-order-help = Wordt alleen gebruikt als geen enkele datum in het bestand de doorslag geeft. Zodra een datum als 24/11 de volgorde bewijst, beslist het bestand, ongeacht deze instelling.
preferences-field-qif-label = Omschrijving van de boeking:
preferences-qif-label-both = Relatie + memo
preferences-qif-label-payee = Alleen relatie
preferences-qif-label-memo = Alleen memo
preferences-qif-label-help = Wanneer een boeking zowel een relatie als een memo heeft. Heeft zij er maar één, dan wordt die gebruikt, ongeacht deze instelling.
preferences-qif-hint = Deze instellingen gelden voor alle QIF-bankafschriften, welke database ook geopend is. ‘Mij elke keer vragen’ is het veiligst: een bestand met dubbelzinnige datums wordt nooit op goed geluk gelezen.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Standaardkolommen herstellen
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Tonen/Verbergen
columns-colour = Kolom kleuren:
columns-colour-none = Geen kleur
columns-colour-red = Rood
columns-colour-orange = Oranje
columns-colour-pink = Roze
columns-colour-pastel-green = Pastelgroen
columns-colour-green = Groen
columns-colour-pastel-blue = Pastelblauw
columns-colour-blue = Blauw
columns-colour-pastel-yellow = Pastelgeel
columns-colour-yellow = Geel
preferences-leaf-columns = Tabelkolommen
preferences-table-operations-list = Lijst boekingen
preferences-columns-reset = Herstellen
preferences-columns-reset-all = Alles herstellen
preferences-columns-done = De kolommen hebben weer hun oorspronkelijke indeling.
preferences-columns-hint = Elke tabel onthoudt de volgorde van zijn kolommen, de kolommen die u verbergt en hun breedte. ‘Herstellen’ geeft de tabel meteen zijn oorspronkelijke indeling terug.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Herstellen
preferences-leaf-comfort = Comfortinstellingen
preferences-comfort-reset = Comfortinstellingen herstellen
preferences-comfort-hint = Herstelt de kolommen van alle tabellen, de volgorde en de selectievakjes van de rekeningen in het startvenster, en de grootte van de weergave. De taal, de valuta en de controle van geïmporteerde boekingen blijven ongemoeid.
preferences-comfort-question = Comfortinstellingen herstellen? De tabelkolommen, het startvenster en de grootte van de weergave keren terug naar hun oorspronkelijke staat.
preferences-comfort-done = De comfortinstellingen zijn hersteld.

# --- De banner van het startvenster ---------------------------------------
#
# Deze zinnen stonden sinds fase 0 hard in `index.html` en werden dus niet
# vertaald (opgemerkt door Fabrice op 03/08/2026). De slagzin is zijn stem:
# de Engelse en de Spaanse versie zijn voorstellen, door hem te verbeteren —
# een slogan wordt niet woord voor woord vertaald.
ui-language-tag = nl
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — de eekhoorn als mascotte, in kostuum, omringd door een euro, een rekenmachine en grafieken
welcome-slogan-one = Een programma voor het beheer van persoonlijke financiën dat u helpt minder uit te geven om meer te winnen
welcome-slogan-two = Met Radinus zult u begrijpen waarom kleine beekjes grote rivieren maken.

# --- “Over de auteur” -----------------------------------------------------
#
# De naam en het adres staan gelijkluidend in de drie bestanden: zij worden
# niet vertaald. Zij staan hier toch, en niet in de pagina, opdat het beeld
# geen enkele zin draagt — en opdat zij op één enkele plaats te verbeteren
# zijn op de dag dat de auteur verhuist.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Over de auteur
about-author-flag-alt = Vlag van Corsica — het Morenhoofd

# --- “Over Radinus” -------------------------------------------------------
#
# `about-radinus-version` draagt een gat: het nummer komt uit het draaiende
# binaire bestand, nooit uit een overgeschreven tekenreeks. Zij staat dus niet
# in het woordenboek van de vensters — het is de opdracht `app_version` die
# haar vult.
window-about-radinus-title = Over Radinus
about-radinus-name = Radinus
about-radinus-version = Versie { $version }
about-radinus-rust-alt = Het logo van de taal Rust
about-radinus-tauri-alt = Het logo van Tauri
about-radinus-built = Radinus is in Rust geschreven en met Tauri gebouwd. De eerste berekent uw rekeningen, de tweede maakt er een bureaubladtoepassing van.
about-radinus-licence = Vrije software, onder GNU GPL v3-licentie.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Gebruikslicentie
licence-heading = GEBRUIKSLICENTIE VAN DE SOFTWARE RADINUS
licence-logo-alt = Het logo van de GNU General Public License versie 3
licence-name = GNU GPL v3 of later
licence-intro = Radinus is vrije software.
licence-freedoms-title = De licentie geeft u vier vrijheden:
licence-freedom-use = Het gebruiken zoals u wilt, waarvoor u wilt.
licence-freedom-study = De broncode bestuderen, die voor iedereen open is.
licence-freedom-share = Het kopiëren en doorgeven aan anderen.
licence-freedom-improve = Het wijzigen en uw wijzigingen delen.
licence-read = De volledige licentietekst lezen

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Dit programma wordt geleverd zonder enige garantie, voor zover de wet dat toestaat.
licence-info = De officiële tekst opent in uw browser, op gnu.org.

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Leningsimulatie
window-loan-title = Leningsimulatie
loan-tab-credit = De lening
loan-tab-afford = Kan ik die terugbetalen?
loan-field-kind = Soort lening
loan-kind-consumer = Consumptief krediet
loan-kind-mortgage = Hypotheek
loan-field-amount = Geleend bedrag
loan-field-payment = Maandbedrag
loan-field-months = Looptijd
loan-field-rate = Vaste rentevoet
loan-field-fees = Dossierkosten
loan-field-insurance = Verzekering per maand
loan-unit-months = maanden
loan-unit-percent = %
loan-invalid-field = Deze waarde is geen getal: verbeter ze om de berekening opnieuw te starten.
loan-report-button = PDF-rapport
loan-monthly-table = Tabel maand per maand
loan-months-count = { $count ->
        [one] { $count } maand
       *[other] { $count } maanden
    }
loan-percent = { $value }%
loan-notice-payment-too-low = Dit maandbedrag dekt de rente niet: de lening zou nooit terugbetaald worden. De looptijd blijft op 600 maanden.
loan-notice-too-long = Dit maandbedrag zou meer dan 600 maanden vergen: de looptijd blijft op 600 maanden.
loan-figure-payment = Maandbedrag
loan-figure-payment-insured = Maandbedrag met verzekering
loan-figure-taeg = JKP
loan-figure-interest = Rentekosten
loan-figure-insurance = Verzekeringskosten
loan-figure-cost = Totale kosten van de lening
loan-figure-total-due = Totaal verschuldigd bedrag
loan-figure-all-in = Totaal terugbetaald, verzekering inbegrepen
loan-part-capital = Geleend bedrag
loan-part-interest = Rente
loan-part-fees = Dossierkosten
loan-part-insurance = Verzekering
loan-donut-cost-caption = in totaal
loan-chart-cost = Wat deze lening kost
loan-chart-capital = Openstaand kapitaal
loan-schedule-title = Aflossingstabel
loan-schedule-yearly = Aflossingstabel, jaar per jaar
loan-column-number = Nr.
loan-column-year = Jaar
loan-column-date = Vervaldag
loan-column-payment = Termijn
loan-column-payments = Termijnen
loan-column-interest = Rente
loan-column-capital = Kapitaal
loan-column-insurance = Verzekering
loan-column-remaining = Openstaand kapitaal
loan-history-label = Onderzochte periode
loan-period-last-12 = Laatste 12 maanden
loan-accounts-title = Onderzochte rekeningen
loan-period-title = Periode
loan-column-account = Rekening
loan-column-bank = Bank
loan-column-balance = Reëel saldo
loan-unavailable-no-account = Vink minstens één rekening aan om uw geschiedenis te onderzoeken.
loan-unavailable-no-month = Deze periode heeft nog geen volledige maand: kies een andere.
loan-verdict-title = Kort gezegd
loan-verdict-green = Haalbaar
loan-verdict-orange = Krap
loan-verdict-red = Riskant
loan-verdict-no-income = Geen inkomsten in deze periode: de schuldratio is niet te berekenen.
loan-check-debt-green = Schuldratio van { $ratio }: onder de drempel van { $green } van deze methode.
loan-check-debt-orange = Schuldratio van { $ratio }: tussen { $green } en { $red }, op de grens.
loan-check-debt-red = Schuldratio van { $ratio }: boven { $red }.
loan-check-effort = Het maandbedrag van { $payment } neemt { $share } van wat u opzijzet in { $kind ->
        [good] een goede maand
        [hard] een moeilijke maand
       *[usual] een gewone maand
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Een goede maand
        [hard] Een moeilijke maand
       *[usual] Een gewone maand
    } laat u niets over: het maandbedrag van { $payment } zou van uw reserve gaan.
loan-check-reserve-green = Uw saldo blijft positief tot het einde van de lening.
loan-check-reserve-red = Uw saldo zou in { $month } onder nul zakken, door deze lening.
loan-check-reserve-sooner = Uw saldo zou in { $month } onder nul zakken, { $count ->
        [one] één maand
       *[other] { $count } maanden
    } vroeger dan zonder deze lening.
loan-check-reserve-anyway = Uw saldo zou rond { $month } ook zonder deze lening onder nul zakken; de lening verandert daar nauwelijks iets aan.
loan-check-reserve-floor-green = Uw saldo blijft tot het einde van de lening boven uw veiligheidsreserve ({ $floor }).
loan-check-reserve-floor-red = Uw saldo zou in { $month } onder uw veiligheidsreserve ({ $floor }) zakken, door deze lening.
loan-check-reserve-floor-sooner = Uw saldo zou in { $month } onder uw veiligheidsreserve ({ $floor }) zakken, { $count ->
        [one] één maand
       *[other] { $count } maanden
    } vroeger dan zonder deze lening.
loan-check-reserve-floor-anyway = Uw saldo zou rond { $month } ook zonder deze lening onder uw veiligheidsreserve ({ $floor }) zakken; de lening verandert daar nauwelijks iets aan.
loan-warning-deficit = Let op: in deze periode zijn uw uitgaven al gemiddeld { $amount } per maand hoger dan uw inkomsten, vóór elke lening.
loan-figure-reference = Spaarbedrag in { $kind ->
        [good] een goede maand
        [hard] een moeilijke maand
       *[usual] een gewone maand
    }
loan-figure-tipped = Maanden die de lening in het rood zou brengen
loan-gauge-caption = schuldratio
loan-figure-income = Gemiddelde inkomsten per maand
loan-figure-spending = Gemiddelde uitgaven per maand
loan-figure-saving = Gemiddeld spaarbedrag per maand
loan-figure-running = Lopende leningen per maand
loan-figure-new = Nieuw maandbedrag, verzekering inbegrepen
loan-figure-rest = Om van te leven per maand
loan-figure-debt = Schuldratio
loan-red-months-value = { $count } op { $total }
loan-figure-balance-now = Reëel saldo vandaag
loan-figure-balance-end = Verwacht saldo aan het einde van de lening
loan-chart-income = Waar uw gemiddelde inkomen naartoe gaat
loan-donut-income-caption = gemiddeld inkomen
loan-part-spending = Dagelijkse uitgaven
loan-part-running = Lopende leningen
loan-part-new = Nieuwe lening
loan-part-rest = Rest
loan-part-missing = Tekort
loan-chart-history = Uw geschiedenis met deze lening
loan-chart-history-hint = Wat er elke maand over zou zijn, na betaling van het maandbedrag. Felrood: de maanden die de lening in het rood zou brengen; lichtrood: de maanden die er al zonder haar in stonden.
loan-chart-projection = Uw verwachte saldo
loan-mark-loan-end = Einde: { $label }
loan-mark-negative = In het rood
loan-mark-floor = Onder de reserve
loan-mark-floor-line = Veiligheidsreserve
loan-running-title = Meegerekende lopende leningen
loan-running-column-label = Periodieke verrichting
loan-running-column-monthly = Per maand
loan-running-column-end = Laatste termijn
loan-no-running = Geen lopende lening herkend onder uw periodieke verrichtingen.
loan-period-caption = van { $from } tot { $to } ({ $count ->
        [one] { $count } maand
       *[other] { $count } maanden
    })
loan-transfers = { $count ->
        [0] Er werd geen overschrijving tussen uw aangevinkte rekeningen herkend.
        [one] Eén overschrijving tussen uw aangevinkte rekeningen werd herkend en buiten beschouwing gelaten.
       *[other] { $count } overschrijvingen tussen uw aangevinkte rekeningen werden herkend en buiten beschouwing gelaten.
    }
loan-method = Gemiddelden over de volledige maanden van de periode, afgepunte en vastgelegde verrichtingen, zonder de overschrijvingen tussen uw aangevinkte rekeningen.
loan-report-title = Leningsimulatie
loan-report-made-on = simulatie van { $date }
loan-disclaimer = Indicatieve simulatie, zonder contractuele waarde. Alleen het aanbod van de bank is bindend.
loan-tab-rules = Instellingen van het oordeel
loan-method-optimistic = Optimistisch
loan-method-neutral = Neutraal
loan-method-severe = Streng
loan-method-line = Beoordelingsmethode: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Het oordeel beantwoordt drie vragen, en elke methode stelt haar eigen eisen. Kies de methode die bij u past: het oordeel van het tabblad „Kan ik die terugbetalen?” volgt haar. De laatste regel veronderstelt dat uw uitgaven elk jaar met het opgegeven percentage stijgen; het maandbedrag blijft gelijk.
loan-rule-row-debt = Aanvaarde schuldratio
loan-rule-row-reference = Referentiespaarbedrag
loan-rule-row-share = Deel van dat spaarbedrag dat het maandbedrag mag nemen
loan-rule-row-floor = Drempel waar het saldo niet onder mag
loan-rule-row-sooner = Als het saldo er ook zonder de lening onder zakt
loan-rule-row-growth = Stijging van uw uitgaven per jaar
loan-rule-limits = groen tot { $green }, oranje tot { $red }
loan-rule-reference = { $kind ->
        [good] een goede maand
        [hard] een moeilijke maand
       *[usual] een gewone maand
    }: { $amount }
loan-rule-floor-zero = nul
loan-rule-floor-cushion = één maand uitgaven: { $amount }
loan-rule-sooner = oranje als de lening het { $orange } vervroegt, rood bij { $red }
loan-unit-percent-year = % per jaar
loan-method-optimistic-explain = De optimistische methode gaat uit van een goede maand, aanvaardt een schuldratio tot 40% en houdt geen reserve: ze toont wat mogelijk is als alles goed gaat.
loan-method-neutral-explain = De neutrale methode gaat uit van een gewone maand en volgt de regel van de banken, 33 tot 35% schuldratio: het is het referentieoordeel.
loan-method-severe-explain = De strenge methode gaat uit van een moeilijke maand en houdt één maand uitgaven als reserve voor het onverwachte: ze toont wat standhoudt, ook als het tegenzit.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Verbruik van een elektrisch apparaat
window-appliance-title = Verbruik van een elektrisch apparaat
appliance-device-title = Het apparaat
appliance-on-title = Aan
appliance-standby-title = Stand-by
appliance-field-on-watts = Vermogen in bedrijf
appliance-field-on-hours = Gebruiksduur per dag
appliance-field-days = Gebruiksdagen per week
appliance-field-share = Deel van de gebruiksduur in daluren
appliance-field-standby-watts = Stand-byvermogen
appliance-field-standby-hours = Stand-byduur per gebruiksdag
appliance-unit-watts = W
appliance-unit-hours = u
appliance-unit-days = van 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Leeg gelaten duurt stand-by de rest van de dag. Op dagen zonder gebruik blijft het apparaat aangesloten: al die tijd telt als stand-by. Uit het stopcontact is het stand-byverbruik 0 W.
appliance-contract-title = Uw contract
appliance-field-option = Tariefoptie
appliance-option-base = Enkeltarief (één prijs)
appliance-option-off-peak = Piekuren / Daluren
appliance-field-base = Prijs per kWh
appliance-field-peak = Prijs per kWh in piekuren
appliance-field-off-peak = Prijs per kWh in daluren
appliance-field-off-peak-hours = Daluren per dag
appliance-contract-hint = Deze prijzen gelden alleen voor deze berekening. Het opgeslagen tarief stelt u in via Instellingen › Voorkeuren › Extra.
appliance-contract-reset = Opgeslagen tarief opnieuw gebruiken
appliance-period-day = Per dag
appliance-period-month = Per maand
appliance-period-year = Per jaar
appliance-energy = { $value } kWh
appliance-less-than = minder dan { $amount }
appliance-detail-title = Details over een jaar
appliance-column-part = Post
appliance-column-energy = Energie
appliance-column-cost = Kosten
appliance-column-share = Aandeel
appliance-line-on = Aan
appliance-line-standby = Stand-by
appliance-line-on-peak = Aan, piekuren
appliance-line-on-off-peak = Aan, daluren
appliance-line-standby-peak = Stand-by, piekuren
appliance-line-standby-off-peak = Stand-by, daluren
appliance-line-total = Totaal
appliance-chart-title = Waar het geld naartoe gaat
appliance-chart-caption = per jaar
appliance-standby-sentence = Alleen stand-by kost al { $amount } per jaar: { $share } van wat het apparaat kost.
appliance-note-plate = Het vermogen op het apparaat of in de handleiding is een maximum: in bedrijf verbruiken de meeste apparaten minder. Voor een echt cijfer meet u het met een energiemeter voor het stopcontact en vult u in wat die aangeeft.
appliance-note-subscription = Het vastrecht telt niet mee: dat betaalt u of het apparaat nu aangesloten is of niet.
appliance-invalid-watts = Vul een vermogen in van 0 tot 100.000 W.
appliance-invalid-hours = Vul een duur in van 0 tot 24 uur per dag.
appliance-invalid-days = Vul een geheel aantal dagen in, van 0 tot 7.
appliance-invalid-share = Vul een aandeel in van 0 tot 100%.
appliance-invalid-day-overflow = Gebruik en stand-by samen komen boven 24 uur per dag uit.
appliance-invalid-price = Vul een prijs per kWh in van 0 tot 100.
appliance-invalid-off-peak-hours = Vul een geheel aantal daluren in, van 0 tot 24.
preferences-branch-tools = Extra
preferences-leaf-electricity = Elektriciteitstarief
preferences-electricity-blue = Terug naar het Tarif Bleu van EDF
preferences-electricity-hint = Het tarief van uw contract, gebruikt door het hulpmiddel "Verbruik van een elektrisch apparaat". Standaard: het Tarif Bleu van EDF (Frankrijk) op 1 augustus 2026, prijzen inclusief belastingen, aansluiting van 3 tot 6 kVA. Deze prijzen veranderen vaak in februari en augustus: neem die van uw factuur over.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Mijn financiële buffer
window-cushion-title = Mijn financiële buffer
cushion-question = Als uw inkomsten morgen zouden stoppen, hoeveel maanden zou u dan met uw spaargeld rondkomen?
cushion-accounts-title = Uw rekeningen
cushion-column-account = Rekening
cushion-column-balance = Reëel saldo
cushion-column-savings = Spaargeld
cushion-column-spending = Uitgaven
cushion-accounts-hint = “Spaargeld”: het geld waarop u rekent als het tegenzit. “Uitgaven”: de rekeningen waarvan de dagelijkse uitgaven worden betaald.
cushion-history-label = Onderzochte periode
cushion-backup-label = Vervangend inkomen per maand
cushion-backup-hint = Wat zou blijven binnenkomen: werkloosheidsuitkering, salaris van uw partner… Leeg: geen inkomen.
cushion-categories-title = De meegerekende uitgaven
cushion-categories-hint = Vink uit wat u zou schrappen als het tegenzit.
cushion-categories-empty = Geen uitgaven in deze periode.
cushion-verdict-title = Uw buffer
cushion-targets-title = De veiligheidsdrempels
cushion-projection-title = Uw spaargeld als het tegenzit
cushion-projection-hint = Wat er elke maand over zou blijven als uw inkomsten vandaag stopten.
cushion-note = Een schatting op basis van uw geschiedenis: de uitgaven in een moeilijke maand kunnen afwijken van het gemiddelde.
cushion-invalid-backup = Dit bedrag is niet leesbaar: corrigeer het om de berekening opnieuw uit te voeren.
cushion-no-spending-account = Vink ten minste één rekening “Uitgaven” aan.
cushion-no-month = Deze periode bevat nog geen volledige maand.
cushion-months = { $value } maanden
cushion-per-month = { $amount } per maand
cushion-figure-holds = Geen limiet
cushion-gauge-caption = aan uitgaven gedekt
cushion-verdict-short = Minder dan drie maanden: een tegenslag zou u snel in de problemen brengen.
cushion-verdict-fair = Tussen drie en zes maanden: een redelijke buffer, die u best uitbreidt als het kan.
cushion-verdict-solid = Zes maanden of meer: uw buffer is stevig.
cushion-verdict-holds = Uw vervangend inkomen dekt uw uitgaven: uw spaargeld zou niet slinken.
cushion-verdict-nothing = Geen meegerekende uitgaven in de periode: er valt niets te dekken.
cushion-tile-savings = Beschikbaar spaargeld
cushion-tile-spending = Meegerekende uitgaven
cushion-tile-backup = Vervangend inkomen
cushion-tile-burn = Het spaargeld zou slinken met
cushion-tile-rhythm = Spaartempo
cushion-burn-none = Niets
cushion-target-title = { $months } maanden uitgaven: { $amount }
cushion-target-reached = Bereikt.
cushion-target-date = Er ontbreekt { $missing }. In uw spaartempo bereikt rond { $month }.
cushion-target-never = Er ontbreekt { $missing }. Uw spaargeld is in de periode niet gegroeid: in dit tempo wordt deze drempel niet bereikt.
cushion-mark-empty = Leeg: { $month }
cushion-period = Gemiddelde over { $count ->
        [one] { $count } volledige maand
       *[other] { $count } volledige maanden
    }, van { $from } tot { $to }. { $transfers ->
        [0] Geen overboekingen tussen uw rekeningen.
        [one] Eén overboeking tussen uw rekeningen, buiten beschouwing gelaten.
       *[other] { $transfers } overboekingen tussen uw rekeningen, buiten beschouwing gelaten.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Spaardoel
window-goal-title = Spaardoel
goal-accounts-title = De gevolgde rekeningen
goal-column-account = Rekening
goal-column-balance = Reëel saldo
goal-accounts-hint = Een overboeking tussen twee gevolgde rekeningen valt weg; een overboeking naar een niet-gevolgde rekening telt als een uitgave.
goal-period-label = Referentieperiode
goal-period-range = Reeks jaren…
goal-range-from = van
goal-range-to = tot
goal-question-title = Uw vraag
goal-question-when = Wanneer heb ik dit bedrag?
goal-question-amount = Hoeveel heb ik op deze datum?
goal-question-effort = Hoeveel moet ik sparen om dit bedrag op deze datum te hebben?
goal-field-target = Doelbedrag
goal-field-date = Streefdatum
goal-field-rate = Jaarlijkse rente op het spaargeld
goal-field-extra = En als ik extra spaarde, per maand
goal-options-hint = Leeg: geen rente, niets extra.
goal-answer-title = Het antwoord
goal-chart-title = Uw saldo, gisteren en morgen
goal-chart-hint = Doorgetrokken lijn: het reële saldo van de afgelopen twaalf maanden; stippellijn: de projectie; lichte zone: de bandbreedte afhankelijk van de maanden.
goal-disclaimer = Een projectie op basis van uw geschiedenis, geen belofte: één onverwachte gebeurtenis kan alles veranderen.
goal-no-account = Vink ten minste één te volgen rekening aan.
goal-no-month = Deze periode bevat nog geen volledige maand.
goal-invalid-target = Vul een te bereiken bedrag in.
goal-invalid-date = Kies een datum in de toekomst, binnen de komende vijftig jaar.
goal-invalid-rate = Vul een rente van 0 tot 100% in.
goal-invalid-extra = Dit bedrag is niet leesbaar: corrigeer het om de berekening opnieuw uit te voeren.
goal-per-month = { $amount } per maand
goal-tile-balance = Saldo vandaag
goal-tile-rhythm = Gemiddeld spaartempo
goal-tile-target = Doel
goal-tile-reached = Bereikt rond
goal-tile-date = Streefdatum
goal-tile-projected = Verwacht saldo
goal-tile-saved = Gespaard tegen dan
goal-tile-interest = Waarvan rente
goal-tile-needed = Te sparen
goal-when-already = U hebt al { $amount }: uw gevolgde rekeningen komen samen op { $balance }.
goal-when-reached = U hebt { $amount } rond { $month }, over { $months ->
        [one] één maand
       *[other] { $months } maanden
    }.
goal-when-range = Afhankelijk van de maanden: tussen { $early } en { $late }.
goal-when-range-open = Op zijn vroegst rond { $early }; met zwakke maanden zou het doel niet worden bereikt.
goal-when-never = In dit tempo bereikt u { $amount } niet.
goal-zero = Uw saldo zou rond { $month } tot nul dalen.
goal-amount = In { $month } zou u ongeveer { $amount } hebben.
goal-amount-range = Afhankelijk van de maanden: tussen { $low } en { $high }.
goal-effort-more = Om { $amount } te hebben in { $month }, zou u gemiddeld { $monthly } per maand moeten sparen, dus { $gap } meer dan nu.
goal-effort-less = Om { $amount } te hebben in { $month }, zou { $monthly } per maand volstaan, dus { $gap } minder dan nu: u loopt voor op schema.
goal-effort-range = Afhankelijk van de maanden zou het verschil met uw tempo per maand gaan van { $low } tot { $high }.
goal-chart-target = Doel: { $amount }
goal-chart-today = Vandaag
goal-note-seasons = De projectie volgt de seizoenen: elke komende maand neemt het gemiddelde van dezelfde maanden in de periode over.
goal-note-range = De bandbreedte komt van de zwakke en sterke maanden in de periode: het laagste en het hoogste kwart.
goal-note-loan = De lening “{ $label }” loopt af in { $month }: daarna { $amount } meer per maand.
goal-note-interest = Rente elke maand berekend tegen { $rate }% per jaar: een benadering van de halvemaandregel van spaarrekeningen.
goal-period = Tempo berekend over { $count ->
        [one] { $count } volledige maand
       *[other] { $count } volledige maanden
    }, van { $from } tot { $to }. { $transfers ->
        [0] Geen overboekingen tussen uw gevolgde rekeningen.
        [one] Eén overboeking tussen uw gevolgde rekeningen, buiten beschouwing gelaten.
       *[other] { $transfers } overboekingen tussen uw gevolgde rekeningen, buiten beschouwing gelaten.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = En als ik minder uitgaf…?
window-cut-title = En als ik minder uitgaf…?
cut-axis-label = Groeperen op
cut-axis-category = Categorieën
cut-axis-payee = Relaties
cut-axis-budget-line = Budgetposten
cut-table-title = Uw uitgaven, post per post
cut-table-hint = Typ een bezuiniging in % of in { $sign } per maand bij de posten die u wilt verlichten. Een bezuiniging kan niet hoger zijn dan de uitgave zelf.
cut-column-monthly = Per maand
cut-column-cut = Bezuiniging
cut-column-after = Daarna
cut-column-yearly = Besparing per jaar
cut-total = Totaal
cut-horizon-label = Horizon
cut-settings-title = Instellingen
cut-options-hint = De rente en het doelbedrag zijn optioneel.
cut-report-button = PDF-rapport
cut-chart-title = Uw saldo, zonder en met de bezuinigingen
cut-chart-hint = Doorgetrokken lijn: het reële saldo van de afgelopen twaalf maanden; grijze stippellijn: de projectie zonder bezuiniging; blauw: met; groen: het bespaarde geld.
cut-donut-title = Uw uitgaven per maand na bezuiniging
cut-donut-caption = per maand na bezuiniging
cut-donut-others = Overige posten
cut-donut-saved = Bespaard
cut-legend-with = Met de bezuinigingen
cut-legend-without = Zonder bezuiniging
cut-years = { $years ->
        [one] { $years } jaar
       *[other] { $years } jaar
    }
cut-headline-none = Typ een bezuiniging in de tabel om het effect te zien.
cut-headline = Door te bezuinigen op { $count ->
        [one] deze post
       *[other] deze { $count } posten
    } zou u { $monthly } per maand meer opzijzetten, ofwel { $yearly } per jaar.
cut-tile-monthly = Besparing per maand
cut-tile-yearly = Besparing per jaar
cut-tile-horizon = Besparing over { $years ->
        [one] { $years } jaar
       *[other] { $years } jaar
    }
cut-tile-spending = Uitgaven per maand
cut-target-already = U hebt al { $amount }.
cut-target-sooner = U zou { $amount } bereiken rond { $with } in plaats van { $without }: { $months ->
        [0] niet eerder
        [one] één maand eerder
       *[other] { $months } maanden eerder
    }.
cut-target-only-with = Met deze bezuinigingen zou u { $amount } bereiken rond { $with }; zonder, in uw huidige tempo, nooit.
cut-target-never = Zelfs met deze bezuinigingen zou u { $amount } in uw huidige tempo niet bereiken.
cut-note-seasons = Elke bezuiniging volgt de seizoenen van haar post: een post die vooral in de zomer zwaar weegt, levert vooral in de zomer op.
cut-note-capped = Een ingevoerde bezuiniging was hoger dan de uitgave: ze is teruggebracht tot de uitgave zelf.
cut-invalid-cut = Deze bezuiniging is niet leesbaar: een percentage van 0 tot 100, of een bedrag per maand.
cut-report-settings = De instellingen
cut-report-result = Het resultaat
cut-report-accounts = De gevolgde rekeningen

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Mijn vakantie plannen
window-holiday-title = Mijn vakantie plannen
holiday-trip-title = De reis
holiday-field-trip = Soort reis
holiday-trip-stay = Verblijf
holiday-trip-cruise = Cruise
holiday-field-adults = Volwassenen
holiday-field-children = Kinderen
holiday-field-nights = Duur van het verblijf, in nachten
holiday-field-days = Dagen
holiday-field-months = Maanden vóór vertrek
holiday-field-stops = Aantal aanloophavens
holiday-saved-title = Al gespaard
holiday-saved-hint = Vink de rekeningen aan waarop het geld voor de vakantie al opzij is gezet: hun reële saldo telt als al gespaard.
holiday-budget-title = Het budget
holiday-budget-hint = Per post: een bedrag, voor wie het geldt en voor hoe lang. Een lege post telt niet mee.
holiday-optional-title = Optionele posten
holiday-result-title = Het resultaat
holiday-donut-title = Waar het reisgeld naartoe gaat
holiday-donut-caption = voor de reis
holiday-child-label = Kinderprijs
holiday-count-label = Hutten
holiday-open = Een project openen…
holiday-save = Het project opslaan…
holiday-pdf = PDF-rapport
holiday-excel = Exporteren naar Excel
holiday-file-filter = Vakantieproject
holiday-replace-question = Als u dit project opent, wordt vervangen wat in het venster is ingevuld. Doorgaan?
holiday-file-saved = Project opgeslagen: { $file }
holiday-file-opened = Project geopend: { $file }
holiday-file-not-project = Dit bestand is geen vakantieproject van Radinus.
holiday-file-too-recent = Dit project komt uit een nieuwere versie van Radinus: werk Radinus bij om het te openen.
holiday-file-failed = Het bestand kon niet worden gelezen of geschreven: { $reason }
holiday-line-transport = Vervoer heen en terug
holiday-line-lodging = Accommodatie
holiday-line-meals = Maaltijden en dagelijkse uitgaven
holiday-line-visits = Bezoeken en vrije tijd
holiday-line-port = Vervoer naar de haven
holiday-line-cabins = Hutten
holiday-line-service = Servicepakket (fooien)
holiday-line-drinks = Drankenpakket
holiday-line-excursions = Excursies in de aanloophavens
holiday-line-port-taxes = Havengelden
holiday-line-wifi = Wifi aan boord
holiday-line-onboard = Uitgaven aan boord en aan wal
holiday-line-other = Overige kosten en onvoorziene uitgaven
holiday-line-insurance = Annuleringsverzekering
holiday-line-stay-tax = Toeristenbelasting
holiday-line-car = Auto ter plaatse, brandstof en tol
holiday-line-parking = Parkeren bij luchthaven of station
holiday-line-bank = Bankkosten in het buitenland
holiday-line-formalities = Formaliteiten (paspoort, visum, vaccinaties)
holiday-line-pets = Opvang van huisdieren
holiday-span-trip = voor het verblijf
holiday-span-night = per nacht
holiday-span-day = per dag
holiday-span-stop = per aanloophaven
holiday-who-all = voor iedereen
holiday-who-person = per persoon
holiday-who-adults = per volwassene
holiday-cabins-count = { $count ->
        [one] { $count } hut
       *[other] { $count } hutten
    }
holiday-days = { $days ->
        [one] { $days } dag
       *[other] { $days } dagen
    }
holiday-invalid-count = Vul een geheel getal in.
holiday-invalid-amount = Dit bedrag is niet leesbaar: een positief getal, of een percentage van 0 tot 100.
holiday-headline-empty = Typ de bedragen van het budget om te zien wat de reis gaat kosten.
holiday-headline-stay = Dit verblijf zou { $total } kosten voor { $people ->
        [one] één persoon
       *[other] { $people } personen
    } en { $nights ->
        [0] geen enkele nacht
        [one] één nacht
       *[other] { $nights } nachten
    }.
holiday-headline-cruise = Deze cruise zou { $total } kosten voor { $people ->
        [one] één persoon
       *[other] { $people } personen
    } en { $nights ->
        [0] geen enkele nacht
        [one] één nacht
       *[other] { $nights } nachten
    }.
holiday-tile-total = Totale kosten
holiday-tile-person = Per persoon
holiday-tile-person-day = Per persoon per dag
holiday-tile-saved = Al gespaard
holiday-tile-remaining = Nog te financieren
holiday-tile-monthly = Benodigd spaarbedrag
holiday-remaining-none = Niets: het is gedekt
holiday-monthly-none = Niets opzij te zetten
holiday-monthly-now = Vertrek deze maand
holiday-note-days = De dagen zijn de nachten plus één: zeven nachten zijn acht dagen.
holiday-note-child = Per persoon betaalt een kind de kinderprijs als die is opgegeven; blijft die leeg, dan betaalt het kind als een volwassene.
holiday-note-percent = Een verzekeringspercentage geldt voor de hoofdposten van de reis; dat van de bankkosten voor de uitgaven ter plaatse.
holiday-sheet-budget = Budget
holiday-sheet-result = Resultaat
holiday-column-line = Post
holiday-column-amount = Bedrag
holiday-column-child = Kinderprijs
holiday-column-who = Voor wie
holiday-column-span = Voor hoe lang
holiday-column-cost = Kosten
holiday-disclaimer = Een schatting op basis van uw eigen bedragen: de werkelijke prijzen kunnen afwijken.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Besparingsproject
cut-file-not-project = Dit bestand is geen besparingsproject van Radinus.
cut-file-too-recent = Dit project komt uit een nieuwere versie van Radinus: werk Radinus bij om het te openen.
cut-sheet-items = Posten

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Logboek van mijn auto
window-car-title = Logboek van mijn auto
car-unnamed = Mijn auto
car-sheet-title = De auto
car-field-plate = Kenteken
car-field-make = Merk
car-field-model = Model
car-field-engine = Aandrijving
car-field-first-hand = Eerste eigenaar
car-field-registered = Datum eerste toelating
car-field-acquired = Aankoopdatum
car-field-acquired-km = Kilometerstand bij aankoop
car-field-service = Onderhoudsbeurt elke
car-field-service-or = of elke
car-unit-months-short = mnd.
car-unit-km = km
car-tariff-title = Tarief voor thuisladen
car-tariff-hint = Dit tarief wordt in het logboek van de auto bewaard: het verandert niets aan het tarief in de voorkeuren.
car-tariff-reset = Het tarief uit de voorkeuren overnemen
car-engine-petrol = Benzine
car-engine-diesel = Diesel
car-engine-lpg = LPG
car-engine-e85 = E85 (bio-ethanol)
car-engine-hybrid = Hybride
car-engine-plug-in = Plug-in hybride
car-engine-electric = Elektrisch
car-engine-hydrogen = Waterstof
car-energy-petrol = Benzine
car-energy-diesel = Diesel
car-energy-lpg = LPG
car-energy-e85 = E85
car-energy-electricity = Elektriciteit
car-energy-hydrogen = Waterstof
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energie
car-rubric-upkeep = Regulier onderhoud
car-rubric-service = Onderhoudsbeurt
car-rubric-wear = Slijtdelen
car-rubric-tyres = Banden
car-rubric-breakdown = Pech en storingen
car-rubric-insurance = Verzekering
car-rubric-inspection = APK
car-part-brake-pads = Remblokken
car-part-brake-discs = Remschijven
car-part-timing-belt = Distributieriem
car-part-clutch = Koppeling
car-part-battery-12v = Accu 12 V
car-part-shock-absorbers = Schokdempers
car-part-wipers = Ruitenwissers
car-part-spark-plugs = Bougies
car-part-glow-plugs = Gloeibougies
car-part-particulate-filter = Roetfilter
car-part-catalytic-converter = Katalysator
car-part-fuel-cell-filter = Filter van de brandstofcel
car-part-exhaust = Uitlaat
car-part-other = Ander onderdeel…
car-axle-all = Alle vier de banden
car-axle-front = Voorbanden
car-axle-rear = Achterbanden
car-verdict-pass = Goedgekeurd
car-verdict-counter = Herkeuring
car-charge-station = Bij een laadpaal
car-charge-home = Thuis
car-slot-peak = Piekuren
car-slot-off-peak = Daluren
car-entry-new = Nieuwe regel
car-entry-edit = Regel wijzigen
car-field-date = Datum
car-field-km = Kilometerstand
car-field-rubric = Rubriek
car-field-amount = Bedrag
car-field-garage = Garage of tankstation
car-field-note = Notitie
car-field-energy = Energie
car-field-quantity = Hoeveelheid
car-field-charge = Laden
car-field-slot = Laadtijdstip
car-field-part = Onderdeel
car-field-part-name = Naam van het onderdeel
car-field-axle = Vervangen banden
car-field-verdict = Resultaat
car-field-months = Gedekte maanden
car-field-battery = Batterijconditie
car-home-amount-hint = Het bedrag van een laadbeurt thuis wordt berekend met het tarief van de auto.
car-entry-add = Aan het logboek toevoegen
car-entry-update = Regel opslaan
car-entry-cancel = Annuleren
car-entry-delete = Regel verwijderen
car-delete-question = Deze regel uit het logboek verwijderen?
car-from-operation = Een boeking overnemen…
car-pick-account = Van welke rekening komt de uitgave?
car-pick-operation = Welke boeking?
car-pick-take = Overnemen
car-pick-none = Geen uitgaven op deze rekening.
car-pick-taken = Boeking overgenomen: vul de kilometerstand en de rubriek in en voeg dan de regel toe.
car-history-title = De geschiedenis
car-filter-all = Alle rubrieken
car-history-empty = Nog geen regels.
car-history-hint = Klik op een regel om hem te wijzigen.
car-column-date = Datum
car-column-km = Km
car-column-rubric = Rubriek
car-column-detail = Details
car-column-amount = Bedrag
car-column-garage = Garage
car-column-note = Notitie
car-column-share = Aandeel
car-column-per-km = Per km
car-column-energy = Energie
car-column-quantity = Hoeveelheid
car-column-price = Gemiddelde prijs
car-column-consumption = Verbruik
car-column-part = Onderdeel
car-column-changes = Vervangingen
car-column-last = Laatste vervanging
car-column-life = Levensduur
car-column-next = Volgende vervanging
car-total = Totaal
car-summary-title = Wat de auto kost
car-headline-empty = Vul de autogegevens in en voeg dan een eerste regel toe: een tankbeurt, een onderhoudsbeurt, een garagerekening…
car-headline = Sinds { $since } heeft uw auto u { $total } gekost.
car-headline-km = Sinds { $since } heeft uw auto u { $total } gekost voor { $km } gereden: { $cost } per kilometer.
car-tile-total = Totale kosten
car-tile-month = Per maand
car-tile-km = Per kilometer
car-tile-driven = Gereden kilometers
car-tile-consumption = Verbruik
car-tile-energy-km = Energie per kilometer
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } maand
       *[other] { $months } maanden
    }
car-detail-battery = Batterij: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Per rubriek
car-energy-title = De energie
car-parts-title = Slijtdelen
car-tyres-title = Banden
car-battery-title = Batterijconditie
car-years-title = Wat de auto elk jaar heeft gekost
car-donut-title = Waar het geld naartoe gaat
car-donut-caption = in totaal
car-deadlines-title = De termijnen
car-deadlines-empty = Nog geen termijnen: noteer een onderhoudsbeurt, een APK, een verzekering, of twee vervangingen van hetzelfde onderdeel.
car-deadline-service = Onderhoudsbeurt
car-deadline-inspection = APK
car-deadline-counter = Herkeuring van de APK
car-deadline-insurance = Einde van de verzekering
car-when-date = op { $date }
car-when-km = bij { $km }
car-when-km-reached = bij { $km }, rond { $month } in uw tempo
car-when-date-km = op { $date } of bij { $km }, wat het eerst komt
car-when-inspection-unknown = Noteer de laatste APK om de datum van de volgende te kennen.
car-tone-late = Verlopen
car-tone-soon = Binnenkort
car-note-since = Alles telt vanaf de aankoop: de datum en de kilometerstand die in de autogegevens zijn genoteerd.
car-note-consumption = Het verbruik wordt gemeten van volle tank tot volle tank: tank helemaal vol en noteer elke keer de kilometerstand.
car-note-e85 = Een E85-auto drinkt wat hij krijgt: de kilometers na een tankbeurt tellen voor die brandstof.
car-note-home = Een laadbeurt thuis wordt berekend tegen het tarief van de auto op de dag dat ze wordt genoteerd, en houdt die kosten.
car-note-inspection = De APK volgt de Franse regel: de eerste binnen vier jaar na de eerste toelating, daarna om de twee jaar; een herkeuring binnen twee maanden.
car-disclaimer = De termijnen en levensduren zijn schattingen op basis van het logboek: alleen het onderhoudsboekje van de fabrikant is bindend.
car-invalid-date = Vul een geldige datum in die niet in de toekomst ligt.
car-invalid-acquired = De aankoopdatum kan niet vóór de eerste toelating liggen.
car-invalid-km = Vul een kilometerstand in hele kilometers in.
car-invalid-amount = Dit bedrag is niet leesbaar.
car-invalid-quantity = Typ de hoeveelheid: liters, kWh of kilo.
car-invalid-part = Kies het vervangen onderdeel, of typ de naam ervan.
car-invalid-rubric = Kies een rubriek.
car-invalid-months = Vul een geheel aantal maanden in.
car-invalid-battery = Vul een batterijconditie van 0 tot 100 % in.
car-open = Een logboek openen…
car-save = Het logboek opslaan…
car-report-button = PDF-dossier
car-file-filter = Autologboek
car-file-saved = Logboek opgeslagen: { $file }
car-file-opened = Logboek geopend: { $file }
car-file-not-logbook = Dit bestand is geen autologboek van Radinus.
car-file-too-recent = Dit logboek komt uit een nieuwere versie van Radinus: werk Radinus bij om het te openen.
car-replace-question = Als u dit logboek opent, wordt het logboek in het venster vervangen. Doorgaan?
car-sheet-history = Logboek
car-sheet-summary = Overzicht

analysis-history-hint = Hoe langer uw historie, hoe beter deze analyse wordt: ideaal is minstens een jaar aan boekingen.

# --- F48 — Een uitgave verdelen (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Een uitgave verdelen
window-sharing-title = Een uitgave verdelen
sharing-question = Wie betaalt wat?
sharing-setup-title = De verdeling
sharing-field-label = Omschrijving
sharing-label-hint = Bijvoorbeeld “Restaurant van 12/10” of “Reis Bretagne 2027”: ze geeft de bestanden en de rapporten hun naam.
sharing-field-total = Totaal
sharing-total-hint = Als dit leeg blijft, is het totaal de som van de onderdelen en van de extra's van ieder.
sharing-field-rule = Regel
sharing-field-rounding = Afronding
sharing-field-people = Personen
sharing-mode-whole = Eén regel voor de hele uitgave
sharing-mode-item = Eén regel per onderdeel
sharing-rule-equal = Gelijke delen
sharing-rule-parts = Naar delen
sharing-rule-percent = In percentages
sharing-rule-income = Naar verhouding van het inkomen
sharing-rounding-cent = Op de cent
sharing-rounding-euro = Op hele eenheden
sharing-round-euro = Afronden op hele eenheden
sharing-hide-incomes = Inkomens verbergen in de rapporten en de export
sharing-people-title = De personen
sharing-people-hint = Eén rij per persoon, één kolom per onderdeel: vink aan wie aan wat deelneemt. Al het overige is optioneel. Iemand die afhaakt en zijn aanbetaling laat staan: een exact bedrag gelijk aan wat is betaald, en geen enkel vakje aangevinkt.
sharing-add-person = Een persoon toevoegen
sharing-person-default = Persoon { $number }
sharing-items-title = De onderdelen
sharing-items-hint = Alleen wat niet iedereen aangaat, zoals de wijn. De rest van het totaal gaat naar het gemeenschappelijke onderdeel.
sharing-add-item = Een onderdeel toevoegen
sharing-common = Gemeenschappelijk
sharing-payments-title = De betalingen
sharing-payments-hint = Wie heeft betaald, hoeveel en wanneer. Een rij zonder bedrag telt nog niet mee.
sharing-payments-none = Nog geen betalingen.
sharing-add-payment = Een betaling toevoegen
sharing-result-title = Het resultaat
sharing-balances-title = Stand van de betalingen
sharing-transfers-title = Voorgestelde overboekingen
sharing-delete = Verwijderen
sharing-delete-person-question = Deze persoon heeft betalingen: ze samen met de persoon verwijderen?
sharing-disclaimer = Radinus stelt een verdeling voor: onder vrienden staat het ieder vrij het anders te regelen.
sharing-column-person = Persoon
sharing-column-household = Huishouden
sharing-column-income = Inkomen
sharing-column-parts = Delen
sharing-column-percent = %
sharing-column-floor = Minstens
sharing-column-cap = Hoogstens
sharing-column-fixed = Exact bedrag
sharing-column-alone = Eigen extra's
sharing-column-gift = Geschonken overschot
sharing-column-share = Aandeel
sharing-column-typed = Ingevoerd %
sharing-column-constraint = Toegepast
sharing-column-due = Te betalen
sharing-column-item = Onderdeel
sharing-column-amount = Bedrag
sharing-column-rule = Regel
sharing-column-participants = Deelnemers
sharing-column-unit = Huishouden of persoon
sharing-column-members = Leden
sharing-column-paid = Betaald
sharing-column-balance = Saldo
sharing-column-date = Datum
sharing-column-who = Wie
sharing-column-label = Omschrijving
sharing-help-household = Personen van hetzelfde huishouden rekenen samen af: hun betalingen en wat ze verschuldigd zijn worden opgeteld, en ze krijgen één afrekening. Voorbeeld: “Familie Martin” voor de ouders en de kinderen.
sharing-help-income = Alleen gebruikt door de regel “Naar verhouding van het inkomen”: hoe hoger het inkomen, hoe groter het aandeel. Voer het maandinkomen in.
sharing-help-parts = Een persoon met 2 delen betaalt twee keer zoveel als een persoon met 1 deel. Voorbeeld: volwassene 1, kind 0,5.
sharing-help-percent = Het deel van de uitgave dat de persoon betaalt. De percentages moeten samen 100% zijn.
sharing-help-floor = De persoon betaalt minstens dit bedrag, ook als het berekende aandeel kleiner is. Het verschil verlicht de last van de anderen.
sharing-help-cap = De persoon betaalt nooit meer dan dit bedrag. Wat niet wordt betaald, valt terug op de andere deelnemers aan de onderdelen van de persoon.
sharing-help-fixed = De persoon betaalt dit bedrag, wat er ook gebeurt, en de rest wordt over de anderen verdeeld. Voorbeeld: iemand die afhaakt en de aanbetaling laat staan.
sharing-help-alone = Wat de persoon alleen voor zichzelf heeft genomen, zoals een dessert of een koffie. Dat wordt volledig betaald, bovenop het aandeel.
sharing-help-gift = Als de persoon meer heeft betaald dan het aandeel: aangevinkt is het overschot een geschenk aan de groep; niet aangevinkt wordt het teruggegeven.
sharing-help-items = Vink de personen aan die aan dit onderdeel deelnemen. Gemeenschappelijk is wat van het totaal overblijft zodra de andere onderdelen eraf zijn.
sharing-help-due = Wat de persoon in totaal verschuldigd is: het aandeel in de onderdelen, de eigen extra's en de afronding.
sharing-help-share = Wat het aandeel voorstelt, als percentage van de te verdelen som.
sharing-help-typed = Het percentage dat is ingevoerd. Het kan afwijken van het werkelijke aandeel wanneer een minimum, een maximum of een exact bedrag is toegepast.
sharing-help-constraint = Toont of het aandeel van de persoon is gewijzigd door een minimum, een maximum, een exact bedrag of een geschonken overschot.
sharing-help-item = Alleen wat niet iedereen aangaat, zoals de wijn. De rest van het totaal gaat naar het gemeenschappelijke onderdeel, verdeeld over wie daarbij is aangevinkt.
sharing-help-rule = Hoe dit onderdeel wordt verdeeld: in gelijke delen, naar delen, in percentages of naar verhouding van het inkomen.
sharing-help-paid = Wat het huishouden of de persoon al heeft betaald, volgens de ingevoerde betalingen.
sharing-help-balance = Wat nog te betalen is, of wat er meer is betaald dan het aandeel. Voorbeeld: “Nog te betalen: 61,54 €”.
sharing-advice-equal = { $count ->
        [one] { $total } voor één persoon.
       *[other] { $total } ÷ { $count } personen = { $amount } per persoon.
    }
sharing-advice-equal-varied = In gelijke delen over wie deelneemt, rekening houdend met de grenzen en de uitsluitingen.
sharing-advice-parts = { $parts } delen in totaal: één deel is { $amount } waard.
sharing-advice-parts-varied = Ieder betaalt volgens het aantal delen, rekening houdend met de grenzen en de uitsluitingen. Een leeg vakje telt als 1 deel.
sharing-advice-percent-rest = Er ontbreekt { $rest }% om op 100% te komen.
sharing-advice-percent-over = De percentages komen { $over }% boven de 100% uit.
sharing-advice-percent-ok = De percentages komen precies uit op 100%.
sharing-advice-percent-nobody = De percentages zijn al 100%: { $names } { $count ->
        [one] zou niets betalen.
       *[other] zouden niets betalen.
    }
sharing-advice-income = Ieder betaalt { $rate }% van het eigen inkomen.
sharing-advice-income-missing = Typ ieders inkomen om naar verhouding van het inkomen te verdelen.
sharing-advice-income-varied = Ieder betaalt hetzelfde deel van het eigen inkomen, rekening houdend met de grenzen en de uitsluitingen.
sharing-advice-empty = Typ het bedrag dat verdeeld moet worden.
sharing-apply-advice = De voorgestelde waarden overnemen
sharing-help-apply-advice = Vult de lege vakjes met de grijze waarden. Vakjes die al zijn ingevuld, veranderen niet.
sharing-from-incomes = Percentages volgens de inkomens
sharing-help-from-incomes = Vervangt de percentages door het aandeel van elk inkomen in het totaal van de inkomens. Ze komen samen op 100%.
sharing-reset-percents = Alles opnieuw verdelen
sharing-help-reset-percents = Wist de percentages en verdeelt ze in gelijke delen over iedereen. Handig nadat u een persoon hebt toegevoegd.
sharing-reset-percents-question = Alle percentages wissen en in gelijke delen over iedereen verdelen?
sharing-open = Een project openen…
sharing-save = Het project opslaan…
sharing-pdf-distribution = Verdeling (PDF)
sharing-pdf-payments = Stand van de betalingen (PDF)
sharing-pdf-statements = Individuele afrekeningen (PDF)…
sharing-statements-everyone = Iedereen
sharing-excel = Exporteren naar Excel
sharing-file-filter = Verdelingsproject
sharing-replace-question = Als u dit project opent, wordt vervangen wat in het venster is ingevuld. Doorgaan?
sharing-file-saved = Project opgeslagen: { $file }
sharing-file-opened = Project geopend: { $file }
sharing-file-not-project = Dit bestand is geen verdelingsproject van Radinus.
sharing-file-too-recent = Dit project komt uit een nieuwere versie van Radinus: werk Radinus bij om het te openen.
sharing-file-failed = Het bestand kon niet worden gelezen of geschreven: { $reason }
sharing-statements-replace-question = { $count ->
        [one] Er bestaat al een afrekening in deze map. Vervangen?
       *[other] Er bestaan al { $count } afrekeningen in deze map. Vervangen?
    }
sharing-statements-written = { $count ->
        [one] Eén afrekening geschreven in “{ $folder }”.
       *[other] { $count } afrekeningen geschreven in “{ $folder }”.
    }
sharing-too-many-people = Een verdeling telt hoogstens 40 personen.
sharing-too-many-items = Een verdeling telt hoogstens 20 onderdelen.
sharing-too-many-payments = Een verdeling telt hoogstens 400 betalingen.
sharing-invalid-amount = Dit bedrag is niet leesbaar: een positief getal.
sharing-invalid-number = Dit getal is niet leesbaar: een positief getal.
sharing-invalid-percent = Een percentage loopt van 0 tot 100.
sharing-invalid-date = Deze datum is niet leesbaar.
sharing-name-missing = Elke persoon moet een naam hebben.
sharing-name-duplicate = Er is al een “{ $name }”: maak onderscheid, bijvoorbeeld met een initiaal.
sharing-floor-above-cap = Het minimum ligt boven het maximum.
sharing-item-label-missing = Dit onderdeel heeft geen naam.
sharing-items-above-total = De onderdelen en de extra's van ieder overschrijden het totaal met { $amount }.
sharing-payment-person = Kies wie heeft betaald.
sharing-percent-total = De percentages komen uit op { $sum }%: het moet 100% zijn.
sharing-percent-total-item = “{ $item }”: de percentages komen uit op { $sum }%: het moet 100% zijn.
sharing-item-nobody = Niemand neemt deel aan “{ $item }”.
sharing-item-no-weight = Niemand weegt mee in “{ $item }”: alle deelnemers staan op nul.
sharing-income-missing = Het inkomen van { $name } ontbreekt.
sharing-fixed-above = De exacte bedragen overschrijden de te verdelen som met { $amount }.
sharing-floors-above = De minima overschrijden de te verdelen som met { $amount }.
sharing-cap-alone = { $name } is de enige deelnemer aan “{ $item }”: het maximum kan niet worden gerespecteerd.
sharing-caps-short = De maxima volstaan niet om de som te dekken: er ontbreekt { $amount }.
sharing-impossible = Deze voorwaarden kunnen niet allemaal worden gerespecteerd: verruim een minimum of een maximum.
sharing-constraint-floor = Minimum bereikt
sharing-constraint-cap = Maximum bereikt
sharing-constraint-fixed = Exact bedrag
sharing-constraint-gift = Geschonken overschot
sharing-and = { $first } en { $last }
sharing-outside = Buiten de onderdelen
sharing-alone = Eigen extra's
sharing-rounding = Afronding
sharing-headline-empty = Voeg de personen toe die de uitgave delen.
sharing-headline-no-amount = Typ het totaal, of de onderdelen die verdeeld moeten worden.
sharing-headline-equal = { $total } te verdelen: ieder betaalt { $amount }.
sharing-headline-range = { $total } te verdelen: van { $min } tot { $max }, afhankelijk van de persoon.
sharing-participants = { $count ->
        [0] Geen deelnemers
        [one] Eén deelnemer
       *[other] { $count } deelnemers
    }
sharing-balance-due = Nog te betalen: { $amount }
sharing-balance-over = Heeft { $amount } meer betaald dan het eigen aandeel
sharing-balance-even = In orde
sharing-summary-collected = { $collected } betaald van { $total }.
sharing-summary-owing = { $count ->
        [0] Iedereen is in orde.
        [one] Slechts één persoon moet nog { $amount } betalen.
       *[other] { $count } personen moeten nog in totaal { $amount } betalen.
    }
sharing-remaining-outside = Nog te betalen op de uitgave: { $amount }
sharing-remaining-reimburse = Terug te betalen aan { $name }: { $amount }
sharing-all-settled = Alles is vereffend: niemand is iemand iets verschuldigd.
sharing-transfer = { $from } moet { $amount } betalen aan { $to }
sharing-warning-over-paid = De betalingen overschrijden de uitgave met { $amount }: controleer de bedragen.
sharing-note-income-zero = { $name } betaalt niets voor { $items }: het inkomen is 0.
sharing-note-excluded = { $name } neemt niet deel aan “{ $item }”: het bijbehorende aandeel wordt over de anderen verdeeld.
sharing-note-gift = Het overschot dat { $giver } schenkt, verlaagt het aandeel van de anderen: { $name } heeft nu meer betaald dan het eigen aandeel.
sharing-note-outside = { $name } betaalt { $amount } buiten de eigen onderdelen: dat bedrag wordt afgetrokken van wat de anderen delen.
sharing-note-keeper = Afgerond op hele eenheden: { $name } houdt de centen, zodat het totaal precies klopt.
sharing-report-distribution = Verdeling
sharing-report-sharing = De verdeling
sharing-report-who-pays = Wie betaalt wat
sharing-report-items = Detail per onderdeel
sharing-report-payments = Stand van de betalingen
sharing-report-as-of = Stand op { $date }
sharing-report-balances = Aandeel, betaald, saldo
sharing-report-statement = Afrekening — { $name }
sharing-report-your-share = Uw aandeel
sharing-statement-total = Totaal voor het huishouden: { $amount }
sharing-statement-pay = Te betalen aan { $name }: { $amount }
sharing-statement-receive = Te ontvangen van { $name }: { $amount }
sharing-sheet-people = Personen
sharing-sheet-items = Onderdelen
sharing-sheet-result = Resultaat
sharing-sheet-payments = Betalingen
sharing-sheet-balances = Terugbetalingen

## De exportassistent voor een database (P-74, Fabrice, 19/10/2026).
window-database-export-title = Exportassistent voor de database “{ $base }”
menu-tools-export = Exportassistent voor de database…
base-export-only-this = Alleen de database “{ $base }”, die in de lijst geselecteerd is, wordt geëxporteerd. De andere databases blijven ongemoeid.
base-export-purpose = Deze assistent kopieert de gegevens van de database naar bestanden die andere programma's kunnen lezen: een spreadsheet, een database zoals Access, een ander programma voor uw huishoudboekhouding. De database zelf wordt niet gewijzigd.
base-export-step-format = 1. Formaat
base-export-step-options = 2. Opties
base-export-step-place = 3. Locatie
base-export-step-summary = 4. Overzicht
base-export-format-xlsx = Excel (.xlsx)
base-export-format-xlsx-hint = Een werkmap met één blad per tabel, leesbaar in Excel en in de meeste spreadsheetprogramma's.
base-export-format-ods = Calc (.ods)
base-export-format-ods-hint = Het open formaat van LibreOffice en OpenOffice, met één blad per tabel.
base-export-format-csv = CSV (.csv)
base-export-format-csv-hint = Eén tekstbestand per tabel, met waarden gescheiden door puntkomma's: het formaat dat bijna elk programma kan importeren, ook Access.
base-export-format-json = JSON (.json)
base-export-format-json-hint = Voor programmeurs en toepassingen: elke tabel onder haar eigen naam, met een kop die de export beschrijft.
base-export-format-xml = XML (.xml)
base-export-format-xml-hint = Dezelfde inhoud als de JSON, maar in XML geschreven.
base-export-format-sql = SQL-script (.sql)
base-export-format-sql-hint = De opdrachten die de tabellen en hun gegevens opnieuw aanmaken in een andere database (MySQL, PostgreSQL, SQLite…).
base-export-format-sqlite = SQLite-database (.sqlite)
base-export-format-sqlite-hint = Een zelfstandige database, zonder wachtwoord, die veel programma's rechtstreeks kunnen openen.
base-export-format-qif = QIF, één bestand per rekening (.qif)
base-export-format-qif-hint = Om uw rekeningen over te zetten naar een ander programma voor huishoudboekhouding (Money, Quicken, GnuCash, Grisbi…).
base-export-format-ofx = OFX, één bestand per rekening (.ofx)
base-export-format-ofx-hint = Het formaat van bankafschriften, dat de meeste programma's voor huishoudboekhouding kunnen importeren.
base-export-lossy = Let op: QIF en OFX kunnen niet alles bewaren. Alleen de boekingen van de rekeningen gaan mee, met hun relaties, categorieën en opmerkingen; een overboeking wordt aan elke kant een gewone boeking, en de rest (budgetten, terugkerende boekingen, projecten, toewijzingen…) blijft achter. Kies een ander formaat om alles te behouden.
base-export-planned-note = Geplande boekingen en boekingen zonder datum worden niet geëxporteerd: ze zijn nog niet door de bank verwerkt. Hun aantal wordt aan het einde vermeld.
base-export-dates-hint = Datums worden geschreven als jaar-maand-dag (2026-12-31) en bedragen in de valuta van de database: geen enkel programma kan zich daarin vergissen.
base-export-group-layout = Bestanden
base-export-layout-one = Alles in één bestand
base-export-layout-per-table = Eén bestand per tabel, in een map
base-export-group-decimal = Decimaalteken voor de bedragen
base-export-decimal-point = De punt (1234.56)
base-export-decimal-comma = De komma (1234,56)
base-export-group-quotes = Aanhalingstekens
base-export-quotes-all = Elke waarde tussen aanhalingstekens
base-export-quotes-none = Geen aanhalingstekens
base-export-csv-replacements-hint = Zodat elk bestand zonder fouten opnieuw kan worden ingelezen, wordt een puntkomma in een tekst een uitroepteken, een regeleinde een spatie en, zonder aanhalingstekens, een aanhalingsteken een apostrof. Het aantal vervangingen wordt aan het einde vermeld.
base-export-group-qif-order = Volgorde van de datum
base-export-qif-day-month = Dag vóór maand (31/12/2026)
base-export-qif-month-day = Maand vóór dag (12/31/2026)
base-export-qif-order-hint = Kies de volgorde die het programma verwacht dat de bestanden zal lezen: in Europa eerst de dag, in de Verenigde Staten eerst de maand.
base-export-no-option = Dit formaat heeft geen opties.
base-export-choose-file = Bestand kiezen…
base-export-choose-folder = Map kiezen…
base-export-place-file = De export wordt in dit bestand geschreven:
base-export-place-folder = De export wordt in deze map geschreven, die daarvoor wordt aangemaakt:
base-export-place-none = Er is nog geen locatie gekozen.
base-export-place-needed = Kies eerst waar de export moet worden opgeslagen.
base-export-folder-exists = De map “{ $name }” bestaat al. Bestanden met dezelfde naam in die map worden vervangen. Doorgaan?
base-export-summary-base = Database
base-export-summary-format = Formaat
base-export-summary-options = Opties
base-export-summary-place = Locatie
base-export-unprotected = Deze database is beveiligd met een wachtwoord, maar de export niet: iedereen die deze bestanden heeft, kan uw rekeningen lezen. Bewaar ze op een veilige plek.
base-export-previous = Vorige
base-export-next = Volgende
base-export-run = Exporteren
base-export-running = Bezig met exporteren…
base-export-done = De database “{ $base }” is geëxporteerd: { $tables ->
        [one] één tabel
       *[other] { $tables } tabellen
    }, { $rows ->
        [one] één rij
       *[other] { $rows } rijen
    }.
base-export-done-accounts = De database “{ $base }” is geëxporteerd: { $accounts ->
        [one] één rekening
       *[other] { $accounts } rekeningen
    }, { $operations ->
        [one] één boeking
       *[other] { $operations } boekingen
    }.
base-export-done-replacements = { $count ->
        [one] Er is één teken vervangen in de CSV-bestanden.
       *[other] Er zijn { $count } tekens vervangen in de CSV-bestanden.
    }
base-export-done-controls = { $count ->
        [one] { $count } stuurteken, dat dit formaat niet kan bevatten, is vervangen door “�”.
       *[other] { $count } stuurtekens, die dit formaat niet kan bevatten, zijn vervangen door “�”.
    }
base-export-done-excel-cut = { $count ->
        [one] { $count } tekst was langer dan 32.767 tekens, de limiet van Excel: hij is ingekort in de werkmap. De andere formaten bewaren hem volledig.
       *[other] { $count } teksten waren langer dan 32.767 tekens, de limiet van Excel: ze zijn ingekort in de werkmap. De andere formaten bewaren ze volledig.
    }
base-export-done-anomalies = { $count ->
        [one] Eén onleesbare waarde is ongewijzigd overgenomen.
       *[other] { $count } onleesbare waarden zijn ongewijzigd overgenomen.
    }
base-export-done-planned = { $count ->
        [one] Eén geplande boeking is overgeslagen.
       *[other] { $count } geplande boekingen zijn overgeslagen.
    }
base-export-done-undated = { $count ->
        [one] Eén boeking zonder datum is overgeslagen.
       *[other] { $count } boekingen zonder datum zijn overgeslagen.
    }
base-export-done-adjusted = { $count ->
        [one] Eén waarde is aangepast aan het formaat.
       *[other] { $count } waarden zijn aangepast aan het formaat.
    }
base-export-too-old = Deze database komt uit een oudere versie van Radinus. Open ze eerst één keer in Radinus, dat ze bijwerkt, en exporteer ze daarna.
base-export-too-recent = Deze database is opgeslagen door een nieuwere versie van Radinus. Werk Radinus bij om ze te exporteren.
base-export-not-radinus = Dit bestand is geen Radinus-database.
base-export-failed = De export is mislukt: { $reason }

## Het menu Extra van het databasevenster noemt de database (Fabrice, 19/10/2026).
databases-tools-selected = Geselecteerde database: “{ $base }”
databases-tools-none = Geen database geselecteerd
menu-tools-backup = Back-up maken van de database “{ $base }”…
menu-tools-backup-none = Back-up maken van de geselecteerde database…
menu-tools-restore = De database “{ $base }” terugzetten…
menu-tools-restore-none = De geselecteerde database terugzetten…
menu-tools-repair = De database “{ $base }” repareren en optimaliseren…
menu-tools-repair-none = De geselecteerde database repareren en optimaliseren…
