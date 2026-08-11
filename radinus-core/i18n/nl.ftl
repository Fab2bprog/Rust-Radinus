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
menu-statistics-by-category = Stat per categorie
menu-statistics-by-assignment = Stat per toewijzing
menu-statistics-by-budget-line = Stat per budgetpost
menu-statistics-by-payment-mode = Stat per betaalwijze
menu-statistics-by-payee = Stat per relatie en handelaar
menu-statistics-by-project = Stat per project
menu-statistics-dashboard = Overzicht van de boekingen

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
operations-column-label = Omschrijving
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
   *[category] Statistieken per categorie
}

statistics-axis-column = { $kind ->
    [assignment] Toewijzing
    [budget-line] BudgetPost
    [payment-mode] BoekingsWijze
    [payee] Relatie
    [project] Projecten
   *[category] CategorieNaam
}

statistics-unclassified = { $kind ->
    [assignment] Zonder toewijzing
    [budget-line] Zonder budgetpost
    [payment-mode] Zonder betaalwijze
    [payee] Zonder relatie
    [project] Zonder project
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
export-all-years-excel = Alle jaren naar Excel exporteren
export-all-years-ods = Alle jaren naar LibreOffice Calc exporteren
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
quick-column-date = Datum
quick-column-label = Omschrijving
quick-column-amount = Bedrag
quick-column-category = Categorie
quick-column-assignment = Toewijzing
quick-column-payment-mode = Betaalwijze
quick-column-payee = Relatie
quick-column-project = Projecten
quick-column-status = Status
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
statement-column-debit = Debet
statement-column-credit = Credit
statement-account = Rekening
statement-file = Bestand
statement-difference = Verschil
statement-none = Er is geen bankafschrift geopend: klik op de gele map om een bestand te kiezen.
statement-empty = Dit bankafschrift bevat geen enkele boeking.
statement-no-match = Geen enkele rij komt overeen met het filter.
statement-help = Info: Gebruik muisklik + toets [{ $modifier }] op de tabel om meerdere rijen te selecteren
statement-choose-account = Dit bestand bevat meerdere rekeningen. Welke wilt u importeren?
statement-select-line = Selecteer minstens één rij van het bankafschrift.
statement-title-open = Een bestand met een bankafschrift openen (.ofx)
statement-title-info = Informatie over het geopende bestand
statement-title-integrate = De selectie opnemen in de rekening
statement-title-validate = Deze boeking opnemen in de rekening
statement-duplicate = Let op dubbele invoer: deze transactie lijkt al te zijn opgenomen in de database (Financial Institution Transaction ID bestaat)
statement-no-fitid = Let op: dit bestand geeft geen identificatie (FITID) voor deze rij. Een dubbele invoer kan niet worden gedetecteerd.
statement-loaded = { $count ->
    [0] Dit bestand bevat geen enkele boeking voor deze rekening.
   *[other] { $count } rijen gelezen, waarvan { $known } al aanwezig in uw rekening.
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
    { $count } boekingen, waarvan { $known } al aanwezig in uw rekening.
statement-group-identification = Identificatie van de boeking
statement-group-amount = Bedrag van de boeking
statement-group-classification = Indeling van de boeking voor de berekening van de statistieken
statement-group-status = Status van de boeking
statement-field-date = Datum
statement-field-label = Omschrijving
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
backup-done = Back-up geschreven in “{ $file }”.
backup-failed = Back-up niet mogelijk: { $reason }
backup-not-started = De back-up kon niet worden gestart:
restore-unreadable = Dit bestand is geen leesbaar Radinus-archief: { $reason }
# De vraag zegt wat er verloren gaat voordat het verloren gaat. Het archief is
# op dat moment al gelezen: wat zij aankondigt, is zeker.
restore-question = “{ $file }” terugzetten? De volledige huidige inhoud van uw database wordt gewist en vervangen, en wat zich daarin bevindt, gaat verloren.
restore-done = Terugzetten voltooid: { $accounts } rekeningen en { $operations } boekingen.
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
    [0] Reparatie voltooid: geen enkele afwijking gevonden. { $lines } stappen gelogd.
    [one] Reparatie voltooid: één afwijking gerepareerd. { $lines } stappen gelogd.
   *[other] Reparatie voltooid: { $anomalies } afwijkingen gerepareerd. { $lines } stappen gelogd.
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

