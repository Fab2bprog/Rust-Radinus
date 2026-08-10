# Radinus — Meldungen der Core-Seite (Fluent), Deutsch.
# Wird nach und nach gefüllt, sobald die Core-Module umgesetzt werden, die für
# den Benutzer sichtbare Meldungen erzeugen. Siehe 08_ARCHITECTURE.md §2.1.

# Der Platzhalter „0 = Nicht angegeben“, den jede optionale Stammdaten-Verknüpfung
# verwendet (02_BASE_DE_DONNEES.md §7 Regel 2). Wird oben in jeder Combo gezeigt.
# ---------------------------------------------------------------------
# Der Name der Sprache, geschrieben in ihrer eigenen Sprache.
#
# Das ist es, was das Menü Einstellungen und die Auswahl beim ersten
# Start zeigen (01_CAHIER_DES_CHARGES.md §3.5: „jede Sprache in ihrer
# eigenen Sprache geschrieben“). Er steht hier und nicht im Code, weil das der
# einzige Ort ist, an dem er richtig sein kann: eine Sprache hinzufügen heißt,
# eine Datei abzulegen, die sich selbst zu benennen weiß.
# ---------------------------------------------------------------------
language-name = Deutsch

nomenclature-unspecified = Nicht angegeben

# Wird gefragt, bevor ein Stammdatenelement gelöscht wird, das Buchungen noch
# verwenden (02_BASE_DE_DONNEES.md §7 Regel 5). Wort für Wort aus der
# ursprünglichen WinDev-Quelle (Enreg_Supprimer) übernommen, Typografie
# eingeschlossen — die Formulierung stammt vom Autor, sie ist keine Übersetzung.
nomenclature-delete-confirm = Es wurden Buchungen (Banktransaktionen) festgestellt, die das Attribut vom Typ '{ $label }' besitzen. Bestätigen Sie, dass Sie dieses Attribut zurücksetzen möchten?

# Wird gefragt, bevor ein Stammdatenelement gelöscht wird, das niemand verwendet.
# Das Original löschte ein solches Element ohne ein Wort auf der Stelle; Fabrice
# hat am 25/07/2026 verlangt, dass ein Löschen immer bestätigt wird — eine bewusst
# in Kauf genommene Abweichung von seinem eigenen Code, die einzige in diesem Modul.
nomenclature-delete-plain = Bestätigen Sie das Löschen von „{ $label }“?

# Ablehnung, die gezeigt wird, wenn das Element, das der Benutzer löschen will,
# genau dasjenige ist, das sein Datenblatt anzeigt. Entscheidung von Fabrice vom
# 25/07/2026: Ein Element wird nicht unter seinem eigenen offenen Datenblatt weg
# gelöscht — das Datenblatt wird zuerst geschlossen, statt es einen Datensatz
# zeigen zu lassen, den es nicht mehr gibt.
nomenclature-delete-form-open = Das Datenblatt von „{ $label }“ ist geöffnet. Schließen Sie es, bevor Sie löschen.

# Ablehnung, die gezeigt wird, wenn die zu speichernde Bezeichnung bereits von
# einem anderen Element derselben Stammdaten getragen wird (Entscheidung des Autors,
# 25/07/2026: Zwei Elemente derselben Stammdaten dürfen sich keinen Namen teilen —
# eine Buchung unter eine von zwei identischen Bezeichnungen einzuordnen ist ein
# Münzwurf). `element` ist das Substantiv in seinem eigenen Geschlecht, „eine
# Kategorie“, „ein Zahlungspartner“; `label` ist die bestehende Bezeichnung, so wie
# sie gespeichert ist, damit der Benutzer sieht, was ihm im Weg steht.
nomenclature-duplicate = Es gibt bereits { $element } mit demselben Namen: „{ $label }“.

# ---------------------------------------------------------------------
# Was die Fenster über sich selbst sagen.
#
# Alles steht hier, auch das, was von den angezeigten Stammdaten abhängt: die
# Sätze sind ganz ausgeschrieben, Sprache für Sprache, statt aus Wörtern und
# Geschlechtern zusammengebaut zu werden. Ein Zusammenbau, der im Französischen
# richtig ist, ist in der nächsten Sprache falsch, und am Ende ist es der Code,
# der weiß, dass es ein Femininum gibt — das ist nicht seine Aufgabe (Regel des
# Autors, 25/07/2026: „die Software funktioniert von Anfang an mit Fluent auf
# Französisch und auf Englisch“).
# ---------------------------------------------------------------------

ui-loading = Wird geladen…
ui-editing = Bearbeitung.
ui-viewing = Ansicht.
ui-modified-suffix = — geändert
ui-label-required = Die Bezeichnung ist erforderlich.
ui-discard-question = Änderungen verwerfen?
ui-yes = Ja
ui-no = Nein
ui-select-record = Bitte wählen Sie einen Datensatz aus
ui-key-multiselect = STRG
ui-multiselect-help = Info: Verwenden Sie Mausklick + Taste [{ $modifier }] in der Tabelle, um mehrere Elemente auszuwählen
ui-no-match = Keine Bezeichnung entspricht dem Filter.
ui-filter-placeholder = Bezeichnungen filtern…
ui-column-label = BEZEICHNUNG
ui-field-label = Bezeichnung
ui-field-budget-line = Budgetposten
ui-identifier = Kennung
ui-deletion-abandoned = Löschen abgebrochen: Es wurde nichts geändert.
ui-unknown-nomenclature = Unbekannte Stammdaten:

ui-title-filter = Filtern
ui-title-create = Anlegen
ui-title-update = Auswahl bearbeiten
ui-title-delete = Auswahl löschen
ui-title-read = Auswahl anzeigen
ui-title-close = Schließen
ui-title-save = Speichern
ui-title-add = Hinzufügen
ui-title-modify = Bearbeiten

ui-load-failed = Laden nicht möglich:
ui-save-failed = Speichern nicht möglich:
ui-read-failed = Lesen nicht möglich:
ui-delete-failed = Löschen nicht möglich:
ui-open-failed = Öffnen nicht möglich:
ui-close-failed = Schließen nicht möglich:

# --- Sätze, die zu jeder Stammdatenart gehören -----------------------

nomenclature-identifier = { $kind ->
    [category] Kennung der Kategorie
    [assignment] Kennung der Zuordnung
    [payment-mode] Kennung der Zahlungsart
    [payee] Kennung des Zahlungspartners
    [project] Kennung des Projekts
    [budget-line] Kennung des Budgetpostens
   *[bank] Kennung der Bank
}

nomenclature-none = { $kind ->
    [category] Keine Kategorie.
    [assignment] Keine Zuordnung.
    [payment-mode] Keine Zahlungsart.
    [payee] Kein Zahlungspartner.
    [project] Kein Projekt.
    [budget-line] Kein Budgetposten.
   *[bank] Keine Bank.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Keine Kategorie anzuzeigen.
    [assignment] Keine Zuordnung anzuzeigen.
    [payment-mode] Keine Zahlungsart anzuzeigen.
    [payee] Kein Zahlungspartner anzuzeigen.
    [project] Kein Projekt anzuzeigen.
    [budget-line] Kein Budgetposten anzuzeigen.
   *[bank] Keine Bank anzuzeigen.
}

nomenclature-gone = { $kind ->
    [category] Diese Kategorie gibt es nicht mehr.
    [assignment] Diese Zuordnung gibt es nicht mehr.
    [payment-mode] Diese Zahlungsart gibt es nicht mehr.
    [payee] Diesen Zahlungspartner gibt es nicht mehr.
    [project] Dieses Projekt gibt es nicht mehr.
    [budget-line] Diesen Budgetposten gibt es nicht mehr.
   *[bank] Diese Bank gibt es nicht mehr.
}

nomenclature-fresh = { $kind ->
    [category] Neue Kategorie.
    [assignment] Neue Zuordnung.
    [payment-mode] Neue Zahlungsart.
    [payee] Neuer Zahlungspartner.
    [project] Neues Projekt.
    [budget-line] Neuer Budgetposten.
   *[bank] Neue Bank.
}

nomenclature-created = { $kind ->
    [category] Kategorie hinzugefügt.
    [assignment] Zuordnung hinzugefügt.
    [payment-mode] Zahlungsart hinzugefügt.
    [payee] Zahlungspartner hinzugefügt.
    [project] Projekt hinzugefügt.
    [budget-line] Budgetposten hinzugefügt.
   *[bank] Bank hinzugefügt.
}

nomenclature-updated = { $kind ->
    [category] Kategorie geändert.
    [assignment] Zuordnung geändert.
    [payment-mode] Zahlungsart geändert.
    [payee] Zahlungspartner geändert.
    [project] Projekt geändert.
    [budget-line] Budgetposten geändert.
   *[bank] Bank geändert.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 Kategorie gelöscht.
       *[other] { $count } Kategorien gelöscht.
      }
    [assignment] { $count ->
        [one] 1 Zuordnung gelöscht.
       *[other] { $count } Zuordnungen gelöscht.
      }
    [payment-mode] { $count ->
        [one] 1 Zahlungsart gelöscht.
       *[other] { $count } Zahlungsarten gelöscht.
      }
    [payee] { $count ->
        [one] 1 Zahlungspartner gelöscht.
       *[other] { $count } Zahlungspartner gelöscht.
      }
    [project] { $count ->
        [one] 1 Projekt gelöscht.
       *[other] { $count } Projekte gelöscht.
      }
    [budget-line] { $count ->
        [one] 1 Budgetposten gelöscht.
       *[other] { $count } Budgetposten gelöscht.
      }
   *[bank] { $count ->
        [one] 1 Bank gelöscht.
       *[other] { $count } Banken gelöscht.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Es gibt bereits eine Kategorie mit demselben Namen: „{ $label }“.
    [assignment] Es gibt bereits eine Zuordnung mit demselben Namen: „{ $label }“.
    [payment-mode] Es gibt bereits eine Zahlungsart mit demselben Namen: „{ $label }“.
    [payee] Es gibt bereits einen Zahlungspartner mit demselben Namen: „{ $label }“.
    [project] Es gibt bereits ein Projekt mit demselben Namen: „{ $label }“.
    [budget-line] Es gibt bereits einen Budgetposten mit demselben Namen: „{ $label }“.
   *[bank] Es gibt bereits eine Bank mit demselben Namen: „{ $label }“.
}

# --- Fenstertitel, ohne Akzente wie auf den ursprünglichen Fenstern ---

window-list-title = { $kind ->
    [category] Liste der Kategorien
    [assignment] Liste der Zuordnungen
    [payment-mode] Liste der Zahlungsarten
    [payee] Liste der Zahlungspartner und Händler
    [project] Liste der Projekte
    [budget-line] Liste der Budgetposten
   *[bank] Liste der Banken
}

window-form-title = { $kind ->
    [category] Datenblatt Kategorie
    [assignment] Datenblatt Zuordnung
    [payment-mode] Datenblatt Zahlungsart
    [payee] Datenblatt Zahlungspartner
    [project] Datenblatt Projekt
    [budget-line] Datenblatt Budgetposten
   *[bank] Datenblatt Bank
}

# --- Menüleiste (01_CAHIER_DES_CHARGES.md §6) -------------------------

menu-file = Datei
menu-file-import-statements = Import von Kontoauszügen
menu-file-import-excel = Import einer Excel-Datei
menu-file-backup = Datensicherung
menu-file-restore = Wiederherstellung
menu-file-repair = Reparatur und Optimierung der Datenbank
menu-file-log = Log anzeigen
menu-tools-password = Datenbank mit einem Passwort schützen
menu-file-disconnect = Von der aktuellen Datenbank trennen
menu-file-quit = Beenden

menu-accounts = Konten
menu-accounts-manage = Verwaltung der Bankkonten
menu-accounts-balances = Salden Ihrer Konten ansehen
menu-accounts-operations = Buchungen eines Kontos verwalten
menu-accounts-quick-classify = Schnelle Kategorisierung der Buchungen
menu-accounts-recurring = Verwaltung der wiederkehrenden Buchungen
menu-accounts-transfer = Einen Betrag zwischen zwei Konten umbuchen
menu-accounts-checkbooks = Verwaltung der Scheckhefte

menu-statistics = Statistiken
menu-statistics-balance-chart = Diagramm Saldenentwicklung
menu-statistics-by-category = Statistik nach Kategorien
menu-statistics-by-assignment = Statistik nach Zuordnungen
menu-statistics-by-budget-line = Statistik nach Budgetposten
menu-statistics-by-payment-mode = Statistik nach Zahlungsarten
menu-statistics-by-payee = Statistik nach Zahlungspartnern und Händlern
menu-statistics-by-project = Statistik nach Projekten
menu-statistics-dashboard = Übersicht der Buchungen

menu-budget = Budget
menu-budget-entry = Budgeterfassung
menu-budget-control = Budgetkontrolle

menu-nomenclatures = Stammdaten
menu-nomenclature = { $kind ->
    [category] Kategorien
    [assignment] Zuordnungen
    [payment-mode] Zahlungsarten
    [payee] Zahlungspartner und Händler
    [project] Projekte
    [budget-line] Budgetposten
   *[bank] Banken
}
menu-nomenclatures-templates = Buchungsvorlagen

menu-settings = Einstellungen
menu-settings-about-author = Über den Autor
menu-settings-about-radinus = Über Radinus
menu-settings-licence = Lizenz

menu-misc = Verschiedenes
menu-misc-calculator = Taschenrechner
menu-misc-website = Zur Radinus-Website gehen
menu-misc-database-folder = Zugriff auf den Ordner mit der Datenbank

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Den Ordner der Datenbank öffnen
database-folder-warning =
    Dieser Ordner enthält alle Ihre Daten. Eine Datei darin umzubenennen, zu verschieben oder zu löschen kann Ihre Konten verlieren, beschädigen oder Radinus unbrauchbar machen.
    Möchten Sie ihn wirklich öffnen?
menu-misc-application-folder = Zugriff auf den Ordner mit der Anwendung
menu-misc-attachments-folder = Zugriff auf den Ordner mit den Anhängen
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Anhänge verwalten
window-attachments-manager-title = Anhänge verwalten
attachments-column-document = Dokument
attachments-column-size = Größe
attachments-column-added = Hinzugefügt am
attachments-column-state = Zustand
attachments-state-intact = Unverändert
attachments-state-altered = Seitdem geändert
attachments-state-missing = Datei fehlt
attachments-state-unknown = Nicht prüfbar
attachments-state-orphan = Verwaist
attachments-no-operation = Keine Buchung
attachments-orphan-remove-question = Diese Datei gehört zu keiner Buchung. In den Papierkorb verschieben?
attachments-manager-help = Doppelklicken Sie auf eine Zeile, um das Dokument zu öffnen.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Die Buchung anzeigen
attachments-reveal = Im Dateimanager anzeigen
attachments-manager-summary = { $count } Anhänge, insgesamt { $size }.
attachments-disk-name = Name auf der Festplatte: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Den Ordner der Anhänge öffnen
attachments-folder-warning =
    Dieser Ordner enthält die Dateien, die Sie Ihren Buchungen beigefügt haben. Radinus legt sie unter einem selbst gewählten Namen ab: eine Datei umzubenennen, zu verschieben oder zu löschen löst sie nicht von der Buchung — diese kündigt sie weiterhin an, und sie lässt sich nicht mehr öffnen.
    Möchten Sie ihn wirklich öffnen?

# ---------------------------------------------------------------------
# Bankkonten — F04, F06, F07, F08.
# Die Tippfehler der Version 1.9.3 („Bank Identifer Code“, „Solde
# initial prevu“, „Est Cloturé“, das Leerzeichen vor der Klammer der IBAN)
# sind korrigiert: Entscheidung von Fabrice vom 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Verwaltung der Bankkonten
window-accounts-select-title = Kontenliste
window-balances-title = Salden Ihrer Konten
window-account-title = Kontoblatt

accounts-none = Kein Konto.
accounts-nothing-to-show = Keine Konten zum Anzeigen.
accounts-gone = Dieses Konto existiert nicht mehr.
accounts-fresh = Neues Konto.
accounts-created = Konto hinzugefügt.
accounts-updated = Konto geändert.
accounts-deleted = { $count ->
    [one] 1 Konto gelöscht.
   *[other] { $count } Konten gelöscht.
}
accounts-duplicate-name = Es existiert bereits ein Konto mit demselben Namen: „{ $label }“.
accounts-multiselect-help = Hinweis: Verwenden Sie Mausklick + Taste [{ $modifier }] in der Tabelle, um mehrere Konten auszuwählen
accounts-select-question = Auf welchen Bankkonten sollen die Statistiken beruhen?

accounts-column-label = BEZEICHNUNG
accounts-column-bank = Bank
accounts-column-type = Kontoart
accounts-column-number = Kontonr.
accounts-column-account = Konto
accounts-column-bank-balance = Banksaldo
accounts-column-real-balance = Tatsächlicher Saldo
accounts-column-final-balance = Endsaldo
accounts-total = GESAMT

# Das Löschen eines Kontos nimmt seine Buchungen mit: Es ist die einzige
# Stelle der Software, an der ein Löschvorgang Historie zerstört.
accounts-delete-plain = Bestätigen Sie das Löschen des Kontos „{ $label }“?
accounts-delete-with-operations = Das Konto „{ $label }“ enthält { $count } Buchungen, die zusammen mit ihm gelöscht werden. Bestätigen Sie das Löschen?
accounts-delete-form-open = Das Kontoblatt des Kontos „{ $label }“ ist geöffnet. Schließen Sie es vor dem Löschen.

account-group-bank = Konto- und Bankdaten
account-group-holder = Kontoinhaber
account-group-rib = Bankverbindung (RIB)
account-group-activity = Aktivität
account-group-balances = Salden

account-field-label = Kontobezeichnung
account-field-bank = Bank
account-field-type = Kontoart
account-field-branch-address = Adresse der Bankfiliale
account-field-holder-name = Name
account-field-holder-address = Adresse
account-field-rib-bank = Bankcode
account-field-rib-branch = Filialcode
account-field-rib-number = Kontonummer
account-field-rib-key = RIB-Prüfziffer
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Eröffnungsdatum
account-field-closing-date = Schließungsdatum
account-field-closed = Ist geschlossen
account-field-opening-pointed = Abgeglichener Anfangssaldo
account-field-opening-committed = Vorgemerkter Anfangssaldo
account-field-opening-planned = Geplanter Anfangssaldo

account-label-required = Die Kontobezeichnung ist erforderlich.
account-iban-invalid = Diese IBAN ist nicht gültig: Prüfen Sie die Prüfziffer.
# Die blaue Zeile am unteren Rand des Kontoblatts, Wort für Wort die von 1.9.3
# — nur die Beträge folgen nun dem französischen Format der übrigen Felder.
account-control-line = Abgeglichener Anfangssaldo ({ $opening }) + Summe der Buchungen ({ $operations }) = Aktueller Banksaldo: { $balance }.

amount-not-readable = „{ $field }“ enthält keinen gültigen Betrag.

ui-thousands-separator = .
ui-decimal-separator = ,

# --- Buchungsliste (F02) ---------------------------------------------

window-operations-title = Buchungsliste des Kontos: { $account }

operations-none = Keine Buchung in diesem Zeitraum.
operations-bad-period = Die Grenzen des Zeitraums sind keine gültigen Datumsangaben.
operations-from = Anfangsdatum
operations-to = Enddatum
operations-delete-confirm = { $count ->
    [one] Bestätigen Sie das Löschen dieser Buchung?
   *[other] Bestätigen Sie das Löschen dieser { $count } Zeilen? Die Teilbuchungen der ausgewählten Buchungen werden mit ihnen gelöscht.
}
operations-deleted = { $count ->
    [one] 1 Buchung gelöscht.
   *[other] { $count } Buchungen gelöscht.
}
operations-selection-total = Gesamtbetrag der ausgewählten Buchungen: { $amount }

operations-column-date = Datum
operations-column-clearing-date = Abgleichdatum
operations-column-label = Bezeichnung
operations-column-category = Kategorie
operations-column-assignment = Zuordnung
operations-column-payment-mode = ZahlArt
operations-column-payee = Zahlungspartner
operations-column-project = Projekte
operations-column-month = Monat
operations-column-debit = Soll
operations-column-credit = Haben
operations-column-balance = Saldo
operations-column-comments = Kommentare
operations-column-attachments = Anhänge
operations-column-check = Schecknr.

operations-foot-debit = Soll:
operations-foot-credit = Haben:
operations-foot-total = Gesamt:
operations-foot-bank = Banksaldo:
operations-foot-real = Tatsächlicher Saldo:
operations-foot-final = Endsaldo:

operations-menu-export = Export
operations-menu-print = Druck
operations-menu-filter = Filter
operations-menu-period = Zeitraum
operations-menu-misc = Verschiedenes

operations-title-point = Auswahl abgleichen
operations-title-sub = Teilbuchung hinzufügen
operations-title-duplicate = Auswahl duplizieren
operations-not-yet = Dieses Fenster existiert noch nicht: Es kommt später im Plan.

accounts-choose-question = Mit welchem Konto möchten Sie arbeiten?
ui-title-select = Auswahl treffen

month-january = Januar
month-february = Februar
month-march = März
month-april = April
month-may = Mai
month-june = Juni
month-july = Juli
month-august = August
month-september = September
month-october = Oktober
month-november = November
month-december = Dezember

operations-period-year = Laufendes Jahr

# --- Menü Zeitraum von F02 -------------------------------------------
# Neun Einträge, davon zwei, die ein Untermenü der zwölf Monate öffnen. Jeder
# tut nur eine Sache: daraus ein Anfangsdatum und ein Enddatum ableiten, die
# das Fenster in seine beiden Felder einträgt (Wunsch von Fabrice, 25/07/2026).

period-all = Alle
period-last-year = Letztes Jahr
period-this-year = Aktuelles Jahr
period-whole-year = Das ganze Jahr
period-last-month = Letzter Monat
period-this-month = Aktueller Monat
period-last-week = Letzte Woche
period-this-week = Aktuelle Woche
period-yesterday = Gestern
period-today = Heute

# --- Menü Filter von F02 ----------------------------------------------
# Filtert die Zeilen nach der Art der Buchung (Wunsch von Fabrice,
# 25/07/2026). Die drei Status sind die der Datenbank: 1 abgeglichen,
# 2 vorgemerkt, 3 geplant (02_BASE_DE_DONNEES.md §5.2).

filter-all = Alle Buchungen
filter-pointed = Nur die abgeglichenen Buchungen
filter-committed = Nur die vorgemerkten Buchungen
filter-planned = Nur die geplanten Buchungen

# --- Buchungsmaske (F03) ----------------------------------------------
# Die Beschriftungen sind die des Screenshots „Fiche operation transaction.png“,
# Tippfehler des Originals korrigiert (Freigabe von Fabrice, 25/07/2026:
# „les coquilles tu les corriges“): aus „Libelle“ wird „Libellé“,
# aus „Categorie“ wird „Catégorie“, aus „Statut Operation“ wird
# „Statut opération“.

window-operation-title = Buchung Konto: { $account }

operation-menu-identification = Identifikation
operation-menu-options = Optionen
operation-fitid-edit = FITID bearbeiten…
operation-fitid-delete = FITID löschen
operation-fitid-question = FITID dieser Transaktion:
operation-fitid-delete-question = FITID dieser Transaktion löschen?
operation-fitid-written = FITID gespeichert.
operation-fitid-removed = FITID gelöscht.

operation-group-identification = Identifikation der Buchung
operation-group-amount = Betrag der Buchung
operation-group-status = Status der Buchung
operation-group-classification = Einordnung der Buchung für die Berechnung der Statistiken
operation-group-check = Scheck in Verbindung mit der Buchung
operation-group-comment = Kommentar

operation-field-label = Bezeichnung
operation-field-reference = Zahlungsreferenz
operation-field-date = Datum
operation-field-direction = Buchungsart:
operation-field-amount = Betrag
operation-field-status = Buchungsstatus
operation-field-clearing-date = Abgleichdatum
operation-field-category = Kategorie
operation-field-assignment = Zuordnung
operation-field-payment-mode = Art
operation-field-payee = Zahlungspartner
operation-field-project = Projekt
operation-field-check = Mit Scheck verknüpfen

operation-direction-debit = Soll
operation-direction-credit = Haben

operation-check-info = Info.
operation-check-link = Verknüpfen
operation-check-unlink = Löschen

operation-fresh = Neue Buchung.
operation-created = Buchung hinzugefügt.
operation-updated = Buchung geändert.
operation-gone = Diese Buchung existiert nicht mehr.
operation-nothing-to-show = Keine Buchung anzuzeigen.
operation-label-required = Die Bezeichnung der Buchung ist erforderlich.
operation-date-required = Das Datum der Buchung ist erforderlich.
operation-clearing-date-invalid = Das Abgleichdatum ist kein gültiges Datum.
operation-is-a-sub = Diese Zeile ist eine Teilbuchung: Sie wird über ihre eigene Maske bearbeitet.
operation-delete-form-open = Die Maske von „{ $label }“ ist geöffnet. Schließen Sie sie vor dem Löschen.

operation-attachments = { $count ->
    [0] Kein Anhang
    [one] 1 Anhang
   *[other] { $count } Anhänge
}

operation-title-comment = Kommentar der Buchung
operation-title-sub = Teilbuchung anlegen
operation-title-template = Buchungsvorlagen
operation-title-attachment = Anhänge

# --- Maske Teilbuchung (F04) ------------------------------------------
# Verkleinerte Fassung von F03: weder Art noch Status noch Datum — eine
# Teilbuchung übernimmt sie von ihrer Mutter (`Maj_ProprieteSousOp`, von
# Fabrice am 26/07/2026 bestätigt: „dans une sous-opération, comme est le
# complément, on ne peut pas toucher au mode de paiement, cela serait
# illogique“).

window-sub-operation-title = Maske Teilbuchung

sub-operation-group-amount = Betrag der Teilbuchung
sub-operation-field-label = Name
sub-operation-fresh = Neue Teilbuchung.
sub-operation-created = Teilbuchung hinzugefügt.
sub-operation-updated = Teilbuchung geändert.
sub-operation-gone = Diese Teilbuchung existiert nicht mehr.
sub-operation-nothing-to-show = Keine Teilbuchung anzuzeigen.
sub-operation-label-required = Der Name der Teilbuchung ist erforderlich.
sub-operation-parent-gone = Die aufzuteilende Buchung existiert nicht mehr.
# Was die Maske sagt, wenn sie den Restbetrag zeigt. Er ist nicht geschützt:
# man kann ihn ändern, aber man muss wissen, was man sich damit einhandelt
# (Entscheidung von Fabrice, 26/07/2026).
sub-operation-is-the-complement = Dies ist der Restbetrag: das, was noch aufzuteilen ist. Wer ihn umbenennt oder seinen Betrag ändert, macht daraus eine gewöhnliche Teilbuchung.
sub-operation-of = Aufteilung von „{ $label }“ ({ $amount })

operations-pointed = { $count ->
    [one] 1 Buchung abgeglichen.
   *[other] { $count } Buchungen abgeglichen.
}
operations-select-one = Bitte wählen Sie nur eine einzige Buchung aus.

# --- Duplizieren und die Anzeige der Teilbuchungen (F02) ---------------
# Duplizieren öffnet eine vorausgefüllte Maske, die der Benutzer selbst
# bestätigt (Entscheidung von Fabrice, 26/07/2026): nichts wird geschrieben,
# solange er nicht gespeichert hat, und er kann vorher Datum oder Betrag
# korrigieren.

operation-copy = Kopie noch zu speichern: es ist noch nichts angelegt.
operations-show-children = Alle Teilbuchungen anzeigen
operations-hide-children = Alle Teilbuchungen ausblenden

# --- Zweite Bestätigung einer schwerwiegenden Löschung -----------------
# Ein Bankkonto zu löschen nimmt seine ganze Historie mit: ein Ja/Nein wird
# ungelesen weggeklickt, also verlangt man, das Wort zu tippen (Entscheidung
# von Fabrice, 26/07/2026). Das Wort ist das des Wörterbuchs — hier „Ja“, auf
# Englisch „Yes“ — hier ist also nichts ein zweites Mal zu übersetzen.

accounts-delete-second-question = Diese Löschung ist endgültig und nimmt die gesamte Historie des Kontos mit. Tippen Sie „{ $word }“, um sie zu bestätigen.

# --- F20-F24 — Die sechs Statistiken ----------------------------------
# Gemeinsame Vorlage, auf sechs Achsen abgewandelt. Die nach Kategorien hat
# als Modell gedient, und Fabrice hat sie am 26/07/2026 freigegeben, bevor
# die fünf anderen existierten — die Spaltennamen sind die des Originals.

window-statistics-title = { $kind ->
    [assignment] Statistiken nach Zuordnung
    [budget-line] Statistiken nach Budgetposten
    [payment-mode] Statistiken nach Zahlungsart
    [payee] Statistiken nach Zahlungspartner und Händler
    [project] Statistiken nach Projekt
   *[category] Statistiken nach Kategorie
}

statistics-axis-column = { $kind ->
    [assignment] Zuordnung
    [budget-line] BudgetPosten
    [payment-mode] BuchungsArt
    [payee] Zahlungspartner
    [project] Projekte
   *[category] KategorieName
}

statistics-unclassified = { $kind ->
    [assignment] Ohne Zuordnung
    [budget-line] Ohne Budgetposten
    [payment-mode] Ohne Zahlungsart
    [payee] Ohne Zahlungspartner
    [project] Ohne Projekt
   *[category] Ohne Kategorie
}
statistics-total = Gesamt
statistics-sum = Summe
statistics-cumulative = Kumuliert

# Die fünf Schalter der Leiste. Die Beschriftung wechselt ON/OFF, wie im
# Original: der Schalter selbst sagt, wo er steht.
statistics-switch-pointed = Abgeglichene Buchungen { $state }
statistics-switch-committed = Vorgemerkte Buchungen { $state }
statistics-switch-planned = Geplante Buchungen { $state }
statistics-switch-debits = Sollbeträge { $state }
statistics-switch-credits = Habenbeträge { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Es wurde kein Konto gewählt: die Statistik bezieht sich auf nichts.
statistics-no-data = Keine Buchung in diesem Jahr für die gewählten Konten.
statistics-detail-empty = Klicken Sie auf ein Feld mit Zahl, um die Buchungen zu sehen, die es zählt.
statistics-detail-none = Keine Buchung hinter diesem Feld.
statistics-accounts = { $count ->
    [one] 1 Konto
   *[other] { $count } Konten
}
statistics-year-next = Nächstes Jahr
statistics-year-previous = Vorheriges Jahr

statistics-column-date = Datum
statistics-column-clearing-date = AbgleichDatum
statistics-column-label = Bezeichnung
statistics-column-amount = Betrag
statistics-column-comments = Kommentare

accounts-stats-multiselect-help = Info: Verwenden Sie Mausklick + Taste [{ $modifier }] auf der Tabelle, um mehrere Konten zu wählen

# Der Jahrgang der Statistiken: man klickt darauf und gibt ein Jahr ein.
# Die Grenzen sind die des „Alle“ aus dem Menü Zeitraum — ein Jahr von Radinus
# ist eine ganze Zahl zwischen 1950 und 2550 (Fabrice, 26/07/2026).
statistics-year-question = Mit welchem Jahr möchten Sie arbeiten? Radinus geht von { $first } bis { $last }.
statistics-year-choose = Jahr wählen

# --- Export der Tabellen (Rechtsklick) --------------------------------
# Eine Funktion der Tabelle, nicht eines Fensters: alle Listen haben sie.

export-to-excel = Nach Excel exportieren (.xlsx)
export-to-word = Nach Word exportieren (.docx)
export-to-tsv = Nach TSV exportieren (.tsv)
export-to-ini = Nach INI exportieren (.ini)
export-to-toml = Nach TOML exportieren (.toml)
export-to-yaml = Nach YAML exportieren (.yaml)
export-to-ofx = Nach OFX exportieren (.ofx)
export-to-qif = Nach QIF exportieren (.qif)
export-to-ods = Nach LibreOffice Calc exportieren (.ods)
export-to-csv = Nach CSV exportieren (.csv)
export-to-xml = Nach XML exportieren (.xml)
# Das Menü Export des Statistikfensters: ein Reiter pro Jahr, benannt
# AN_2026. Die leeren Jahre — unter den gesetzten Schaltern — sind nicht dabei.
export-menu = Export
export-all-years-excel = Alle Jahre nach Excel exportieren
export-all-years-ods = Alle Jahre nach LibreOffice Calc exportieren
export-no-year = Kein Jahr trägt eine Buchung: es gibt nichts zu exportieren.
export-years-done = { $years } Jahre nach „{ $file }“ exportiert.
export-to-json = Nach JSON exportieren (.json)
export-done = Nach „{ $file }“ exportiert.
export-failed = Export nicht möglich: { $reason }
export-nothing = Es gibt nichts zu exportieren.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Statistiken nach Zuordnung
    [budget-line] Statistiken nach Budgetposten
    [payment-mode] Statistiken nach Zahlungsart
    [payee] Statistiken nach Zahlungspartner und Händler
    [project] Statistiken nach Projekt
   *[category] Statistiken nach Kategorie
}
statistics-detail-name = Detail der Statistiken

# --- F19 — Übersicht --------------------------------------------------
# Ein Zeitraum und drei Schalter; zwei Ringe je Budgetposten; drei große
# Zahlen. Die Farben der Sektoren sind die des Originals, abgelesen vom
# Bildschirmfoto von Fabrice.

window-dashboard-title = Übersicht
dashboard-menu-period = Zeitraum
dashboard-menu-misc = Verschiedenes
dashboard-from = Startdatum:
dashboard-to = Enddatum:
dashboard-switch-pointed = Abgeglichene Buchungen einbeziehen
dashboard-switch-committed = Vorgemerkte Buchungen einbeziehen
dashboard-switch-planned = Geplante Buchungen einbeziehen
dashboard-spending = Ausgaben
dashboard-earning = Einnahmen
dashboard-debits = Summe der Sollbuchungen
dashboard-credits = Summe der Habenbuchungen
dashboard-balance = Bilanz
dashboard-unclassified = Ohne Budgetposten
dashboard-nothing = Keine Buchung in diesem Zeitraum.
dashboard-no-account = Es wurde kein Konto gewählt: Die Übersicht bezieht sich auf nichts.
dashboard-enlarge = Vergrößert öffnen

# --- F25 — Saldoentwicklung --------------------------------------------
# Eine Kurve je gewähltem Konto, dazu die der Summe — die es erst ab zwei
# Konten gibt (Regel von Fabrice, 26/07/2026). Die Kurven verlaufen als
# Treppe: Der Saldo behält seinen Wert bis zur nächsten Buchung.

window-curve-title = Saldoentwicklung
curve-heading = Saldoentwicklung pro Tag
curve-menu-period = Zeitraum
curve-total = Gesamt
curve-from = Startdatum:
curve-to = Enddatum:
curve-axis-balance = Saldo
curve-nothing = Es wurde kein Konto gewählt: Es gibt keine Kurve zu zeichnen.
curve-empty = Keine Buchung in diesem Zeitraum.

# --- F05 — Schnelle Klassifizierung der Buchungen ----------------------
# Das Fenster, in dem man **in Masse** klassifiziert: Man wählt Zeilen aus,
# hakt die zu ändernden Merkmale an und wendet sie auf einen Schlag an — im
# Arbeitsspeicher. Nichts wird geschrieben, solange nicht gespeichert wurde,
# und das Speichern schreibt nur, was von dem abweicht, was gelesen wurde
# (Regeln von Fabrice, 27/07/2026).

window-quick-classification-title = Schnelle Klassifizierung der Buchungen: { $account }
quick-dates-title = Anfangs- und Enddatum der Liste.
quick-from = Startdatum
quick-to = Enddatum
quick-menu-period = Zeitraum
quick-change-title = Merkmale der Auswahl ändern in:
quick-check-category = Kategorie
quick-check-assignment = Zuordnung
quick-check-payment-mode = Art
quick-check-payee = Zahlungspartner
quick-check-project = Projekt
quick-check-status = Status
quick-column-date = Datum
quick-column-label = Bezeichnung
quick-column-amount = Betrag
quick-column-category = Kategorie
quick-column-assignment = Zuordnung
quick-column-payment-mode = Zahlungsart
quick-column-payee = Zahlungspartner
quick-column-project = Projekte
quick-column-status = Status
# Auf einem Mac ist Strg + Klick ein Rechtsklick: Die Taste, die zu einer
# Auswahl hinzufügt, ist dort ⌘, und die Hilfe muss die nennen, die geht.
quick-multiselect-help = Info: Benutzen Sie Mausklick + Taste [{ $modifier }] auf der Tabelle, um mehrere Elemente auszuwählen
quick-none = Keine Buchung in diesem Zeitraum.
quick-select-lines = Wählen Sie mindestens eine Zeile aus und haken Sie mindestens ein Merkmal an.
quick-applied = { $count ->
    [0] Nichts hat sich geändert: Diese Zeilen trugen diese Einordnung bereits.
    [one] 1 Zeile eingeordnet. Es ist noch nichts gespeichert.
   *[other] { $count } Zeilen eingeordnet. Es ist noch nichts gespeichert.
}
quick-pending = { $count ->
    [0] Keine ausstehende Änderung.
    [one] 1 Zeile geändert, nicht gespeichert.
   *[other] { $count } Zeilen geändert, nicht gespeichert.
}
quick-save-question = { $count ->
    [one] Die ausstehende Änderung speichern?
   *[other] Die { $count } ausstehenden Änderungen speichern?
}
quick-saved = { $count ->
    [0] Es gab nichts zu speichern.
    [one] 1 Zeile gespeichert.
   *[other] { $count } Zeilen gespeichert.
}
quick-nothing-to-save = Keine ausstehende Änderung.
quick-leave-question = Es sind Änderungen nicht gespeichert. Was möchten Sie tun?
quick-leave-save = Speichern und verlassen
quick-leave-discard = Verwerfen und verlassen
quick-leave-stay = Bleiben
quick-title-apply = Auf die gewählten Zeilen anwenden ( im Arbeitsspeicher )
quick-title-save = Auf die Festplatte speichern

# --- F17 / F18 — Import eines Kontoauszugs -----------------------------
# Man wählt ein Konto, öffnet eine OFX-Datei — die im RAM bleibt —, die
# Zeilen, die die Datenbank schon kennt, erscheinen in Pastell, und das
# dritte Symbol übernimmt sie: in Masse, wenn mehrere gewählt sind, sonst
# einzeln über die Abgleichmaske (Vorgehen von Fabrice, 27/07/2026).

window-statement-import-title = Import von Bankkontoauszügen: { $account }
window-statement-form-title = Eine Transaktion abgleichen (Übernimmt eine Buchung in den Verlauf Ihres Kontos)
statement-menu-filter = Filter
statement-filter-all = Alle Zeilen
statement-filter-pending = Zu übernehmen
statement-filter-known = Schon übernommen
statement-column-id = ID
statement-column-reconciled = Abgeglichen
statement-column-fitid = FITID
statement-column-date = Datum
statement-column-label = Bezeichnung
statement-column-debit = Soll
statement-column-credit = Haben
statement-account = Konto
statement-file = Datei
statement-difference = Differenz
statement-none = Es ist kein Kontoauszug geöffnet: Klicken Sie auf den gelben Ordner, um eine Datei zu wählen.
statement-empty = Dieser Kontoauszug enthält keine Buchung.
statement-no-match = Keine Zeile entspricht dem Filter.
statement-help = Info: Benutzen Sie Mausklick + Taste [{ $modifier }] auf der Tabelle, um mehrere Zeilen auszuwählen
statement-choose-account = Diese Datei enthält mehrere Konten. Welches möchten Sie importieren?
statement-select-line = Wählen Sie mindestens eine Zeile des Kontoauszugs aus.
statement-title-open = Eine Kontoauszugsdatei öffnen (.ofx)
statement-title-info = Informationen zur geöffneten Datei
statement-title-integrate = Die Auswahl in das Konto übernehmen
statement-title-validate = Diese Buchung in das Konto übernehmen
statement-duplicate = Achtung Dublette: Diese Transaktion scheint schon in die Datenbank übernommen worden zu sein (Financial Institution Transaction ID vorhanden)
statement-no-fitid = Achtung: Diese Datei gibt für diese Zeile keine Kennung (FITID) an. Eine Dublette kann nicht erkannt werden.
statement-loaded = { $count ->
    [0] Diese Datei enthält keine Buchung für dieses Konto.
   *[other] { $count } Zeilen gelesen, davon { $known } schon in Ihrem Konto vorhanden.
}
statement-integrated = { $count ->
    [0] Nichts wurde übernommen: Diese Zeilen sind schon in Ihrem Konto.
    [one] 1 Buchung übernommen.
   *[other] { $count } Buchungen übernommen.
}
# **Die Meldungen des Originals, Wort für Wort** (Anweisung von Fabrice,
# 28/07/2026: dem ursprünglichen Code treu bleiben). Seine warnt vor dem
# Stapel, fragt Zeile für Zeile vor einer Dublette und legt am Ende Rechenschaft ab.

statement-mass-question =
    Sind Sie sicher, dass Sie mehrere Buchungen gleichzeitig in Ihr Konto übernehmen wollen?
    Sie müssen sie später kategorisieren und näher bestimmen, um genaue Statistiken zu machen
    Bei Ofx-Dateien: Wenn Dubletten erkannt werden, müssen Sie das Verhalten des Programms wählen
    Bei den anderen Dateitypen: Sie müssen auf Dubletten achten
statement-duplicate-question =
    Die Transaktion: { $date } { $label }: { $amount }
    scheint schon in den Transaktionsverlauf Ihres Bankkontos übernommen worden zu sein.
    Möchten Sie den Abgleich wirklich durchführen?
statement-already-reconciled = Sie haben diese Transaktion schon abgeglichen: Sie ist schon im Transaktionsverlauf Ihres Kontos übernommen
statement-integration-report =
    Ende der Übernahme.
    Anzahl der übernommenen Datensätze: { $added }
    Anzahl der übergangenen Datensätze: { $ignored }
statement-integration-abandoned =
    Abbruch der Übernahme!
    Anzahl der übernommenen Datensätze: { $added }
    Anzahl der übergangenen Datensätze: { $ignored }
statement-yes = Ja
statement-no = Nein
statement-cancel = Abbrechen
statement-file-info =
    Konto der Datei: { $account }
    Zeitraum: vom { $from } bis { $to }
    Von der Bank angegebener Saldo: { $balance }
    { $count } Buchungen, davon { $known } schon in Ihrem Konto vorhanden.
statement-group-identification = Kennzeichnung der Buchung
statement-group-amount = Betrag der Buchung
statement-group-classification = Einordnung der Buchung für die Berechnung der Statistiken
statement-group-status = Status der Buchung
statement-field-date = Datum
statement-field-label = Bezeichnung
statement-field-type = Buchungsart
statement-field-amount = Betrag
statement-field-mode = Zahlungsart
statement-field-category = Kategorie
statement-field-assignment = Zuordnung
statement-field-payee = Zahlungspartner
statement-field-project = Projekt
statement-field-status = Status
statement-field-clearing = Abgleichdatum

# --- Das Fenster zum Zerlegen eines CSV-Auszugs ------------------------
# Ein CSV trägt keinen verlässlichen Feldnamen: Man stellt ein, testet,
# schaut, fängt von vorn an. Die Vorschau zeigt alles, Kauderwelsch inbegriffen
# — so sieht man, dass man sich geirrt hat —, aber nur die gültigen Zeilen
# wechseln in das Fenster der Übernahme (Regel von Fabrice, 27/07/2026).

window-csv-statement-title = Import von Daten aus einer csv-Datei
csv-preview-title = Vorschau der Datei:
csv-settings-title = Parameter zum Zerlegen der Datei im Hinblick auf die Datenextraktion:
csv-extraction-title = Anzeige der Datenextraktion nach den Parametern des Zerlegens  ( die Stimmigkeit der Daten prüfen ):
csv-column-line = Zeilen-Nr.
csv-column-content = Inhalt
csv-header-lines = Anzahl der zu ignorierenden Kopfzeilen der Datei
csv-separator = Die Daten (Spalten) sind getrennt durch das Zeichen:
csv-date-at = Position Feld Datum
csv-label-at = Position Feld Bezeichnung
csv-debit-at = Position Feld Betrag Soll
csv-credit-at = Position Feld Betrag Haben
csv-test = Parameter testen
csv-separator-semicolon = Semikolon   ;
csv-separator-comma = Komma   ,
csv-separator-tab = Tabulator
csv-separator-pipe = Senkrechter Strich   |
csv-separator-space = Leerzeichen
csv-help = Stellen Sie ein, testen Sie, schauen Sie: Nur Zeilen mit lesbarem Datum und lesbarem Betrag werden importiert.
csv-none = Die Datei ist leer.
csv-not-tested = Klicken Sie auf „Parameter testen“, um zu sehen, was das Zerlegen ergibt.
csv-extraction = { $count ->
    [0] Das Zerlegen ergibt keine Zeile: Prüfen Sie die Anzahl der Kopfzeilen und das Trennzeichen.
   *[other] { $count } Zeilen zerlegt: { $valid } werden importiert, { $dropped } verworfen mangels lesbarem Datum oder Betrag.
}
csv-nothing-valid = Keine Zeile trägt zugleich ein lesbares Datum und einen lesbaren Betrag: Es gibt nichts zu importieren. Prüfen Sie die Anzahl der Kopfzeilen, das Trennzeichen und die Position der Felder.
csv-title-validate = Die gültigen Zeilen zum Import übergeben

# --- F13 / F31 / F14 / F12 — Scheckhefte und Schecks (Phase 9) ----------
# Portierung seiner fünf WinDev-Codes und seiner sieben Screenshots, geliefert
# am 28/07/2026. Seine genauen Sätze dort, wo er einen hat; meine überall sonst.
#
# Drei Treuepflichten, die er an jenem Tag entschieden hat und die man den
# Wörtern anhört: die doppelte Referenz wird nicht gemeldet (sein
# `Existe_Reference` wird nie aufgerufen), die Anzahl der Schecks wird nicht
# gegen die Grenzwerte geprüft, und der Buchungszähler zählt die
# Teilbuchungen mit, die die Listen ablehnen.

window-chequebooks-title = Liste der Scheckhefte
window-chequebook-title = Scheckheft-Einstellungen
window-cheques-title = Zusammensetzung des Scheckhefts: Liste der Schecks.
window-cheque-title = Scheckdatenblatt
window-cheque-operations-title = Liste der Buchungen.

# Die Liste der Scheckhefte (F13) — alle Hefte, über alle Konten hinweg: seine
# beiden Kontospalten wären bei einem einzigen Konto nutzlos.
chequebooks-column-reference = BEZEICHNUNG
chequebooks-column-date = Datum
chequebooks-column-account = Kontoname
chequebooks-column-account-number = Kontonr.
chequebooks-column-comments = Kommentare
chequebooks-none = Es ist kein Scheckheft gespeichert.
chequebooks-nothing-to-show = Kein Scheckheft entspricht dieser Suche.
chequebooks-title-composition = Zusammensetzung des Scheckhefts ansehen
chequebooks-delete-question = Es wurden Buchungen (Banktransaktionen) erkannt, die mit Scheckheft verknüpft sind. Bestätigen Sie, dass Sie dieses Scheckheft löschen möchten?
chequebooks-deleted = { $count ->
    [one] Ein Scheckheft gelöscht.
   *[other] { $count } Scheckhefte gelöscht.
}
chequebooks-gone = Dieses Scheckheft existiert nicht mehr.
chequebooks-created = Scheckheft gespeichert, mit allen seinen Schecks.
chequebooks-updated = Scheckheft geändert.
# Das Schweigen seines `HAjoute`: das Fenster sagt nicht, dass die Referenz
# schon vergeben ist. Es sagt nur, dass nichts gespeichert wurde — sonst
# hielte man das Heft für angelegt.
# Die acht Vorsichtsmaßnahmen aus seinem „Precauttion enregistrement
# cheque.txt“, Wort für Wort und in seiner Reihenfolge. Die ersten sieben sind
# `Erreur()`, die achte ein `Info()` — und die Reihenfolge entscheidet, was man
# sieht, wenn zwei Dinge gleichzeitig schieflaufen.
chequebook-refusal-duplicate = Eine Referenz mit demselben Namen existiert bereits
chequebook-refusal-reference-required = Die Eingabe einer Referenz ist obligatorisch
chequebook-refusal-number-too-big = Die Nummern des ersten und/oder des letzten Schecks sind zu groß (Höchstwert 999 999 999)
chequebook-refusal-date = Bitte geben Sie ein gültiges Empfangsdatum ein
chequebook-refusal-numbers-required = Bitte füllen Sie die Nummern des ersten und des letzten Schecks aus
chequebook-refusal-order = Die Nummer des ersten Schecks muss kleiner sein als die Nummer des letzten Schecks
chequebook-refusal-account = Wählen Sie unbedingt das Konto aus, das mit diesem Scheckheft in Verbindung steht
chequebook-refusal-too-many = Höchstzahl der Schecks für ein Scheckheft: 1000, Grenze erreicht
# Seine Rückfrage, die nur beim Anlegen gestellt wird: sie fasst zusammen, was
# angelegt wird, und warnt, dass davon nachher nichts mehr änderbar ist.
chequebook-creation-question =
    Anlegen des Scheckhefts mit den folgenden Merkmalen:
    - Anzahl der zu erzeugenden Schecks:{ $count }
    - Schecks nummeriert von { $first } bis { $last }
    Achtung, diese Daten sind nach dem Anlegen nicht mehr änderbar!

# Das Scheckheft-Datenblatt (F31). Die ersten fünf Felder sind grau, sobald das
# Heft existiert: seine Schecks sind schon da.
chequebook-field-id = Scheckheft-Kennung
chequebook-field-reference = Referenz
chequebook-field-received = Hergestellt oder erhalten am
chequebook-field-first = Nummer des ersten Schecks
chequebook-field-last = Nummer des letzten Schecks
chequebook-field-quantity = Anzahl der Schecks
chequebook-field-account = Mit dem Bankkonto verknüpfen:
chequebook-field-comments = Kommentare
chequebook-locked = Die Schecks dieses Hefts sind bereits angelegt: seine Nummerierung lässt sich nicht mehr ändern.
# Sein Satz, Wort für Wort (`Enreg_Lire`).
chequebook-account-missing = Das Bankkonto, mit dem dieses Scheckheft verknüpft wurde, fehlt oder wurde gelöscht!

# Die Zusammensetzung des Scheckhefts (F14). Der Status wird im Feld geändert.
cheques-column-number = Scheck-Nr.
cheques-column-date = Datum
cheques-column-place = Ort
cheques-column-payee = Empfänger
cheques-column-amount = Betrag
cheques-column-status = Status
cheques-column-comments = Kommentare
cheques-column-operations = Anz. verkn. Buchungen
cheques-none = Dieses Scheckheft enthält keinen Scheck.
cheques-nothing-to-show = Kein Scheck entspricht dieser Suche.
cheques-help = Klicken Sie in das Feld Status, um ihn zu ändern; die Lupe zeigt die verknüpften Buchungen, das Kettenglied verknüpft eine.
cheques-title-linked = Die bereits mit diesem Scheck verknüpften Buchungen ansehen
cheques-title-link = Eine Buchung mit diesem Scheck verknüpfen
cheques-status-changed = Status des Schecks geändert.

# Das Scheckdatenblatt (F12).
cheque-field-id = Scheck-Kennung
cheque-field-number = Schecknummer
cheque-field-issued = Ausstellungsdatum
cheque-field-place = Ausstellungsort
cheque-field-payee = Empfänger
cheque-field-amount = Betrag
cheque-field-comments = Kommentare
cheque-field-status = Status des Schecks
cheque-gone = Dieser Scheck existiert nicht mehr.
cheque-updated = Scheck geändert.

# Die beiden Gesichter des Verknüpfungsfensters.
cheque-operations-linked-title = Liste der bereits mit diesem Scheck verknüpften Buchungen.
cheque-operations-choose-title = Wählen Sie eine Buchung, die mit dem Scheck verknüpft werden soll
cheque-operations-column-account = Konto
cheque-operations-column-label = Name
cheque-operations-column-date = Datum
cheque-operations-column-clearing = Abgleichdatum
cheque-operations-column-amount = Betrag
cheque-operations-column-cheque = Verknüpfter Scheck
cheque-operations-none-linked = Mit diesem Scheck ist keine Buchung verknüpft.
cheque-operations-none = Dieses Konto enthält keine Buchung.
cheque-operations-nothing-to-show = Keine Buchung entspricht dieser Suche.
cheque-operations-help = Die fett dargestellten Buchungen tragen bereits einen Scheck.
cheque-operations-linked-help = Das rote Kreuz löst den Scheck von der Buchung: nichts wird gelöscht.
cheque-operations-linked = Buchung mit dem Scheck verknüpft.
cheque-operations-dissociated = Scheck von der Buchung gelöst.
cheque-operations-menu-filter = Filter
cheque-title-associate = Diese Buchung mit dem Scheck verknüpfen
cheque-title-dissociate = Den Scheck von dieser Buchung lösen

# Das Banner „Scheck in Verbindung mit der Buchung“ des Buchungsdatenblatts und
# die zwei Schritte des Scheckfangs — erst das Heft, dann der Scheck.
chequebooks-select-question = Wählen Sie das Scheckheft
cheques-select-question = Wählen Sie den Scheck, der mit der Buchung verknüpft werden soll
operation-check-save-first = Speichern Sie zuerst die Buchung: ein Scheck wird mit einer Buchung verknüpft, die existiert.
operation-check-none = Diese Buchung trägt keinen Scheck.

# --- F36 / F37 — Die Buchungsvorlagen (Phase 10) ------------------------
# Eine Vorlage ist eine fertige Eingabe: man wendet sie an, um nicht neu zu
# tippen, und sie **überschreibt**, was im Datenblatt steht. Nichts geht auf
# die Festplatte, solange das Buchungsdatenblatt nicht bestätigt ist (Regel von
# Fabrice, 29/07/2026).

window-operation-templates-title = Liste der Buchungsvorlagen
window-operation-template-title = Datenblatt Buchungsvorlage

operation-templates-none = Es ist keine Buchungsvorlage gespeichert.
operation-templates-nothing-to-show = Keine Vorlage entspricht dieser Suche.
operation-templates-select-question = Wählen Sie die anzuwendende Vorlage
operation-templates-delete-question = Bestätigen Sie das Löschen der ausgewählten Vorlagen?
operation-templates-deleted = { $count ->
    [one] Eine Vorlage gelöscht.
   *[other] { $count } Vorlagen gelöscht.
}
operation-template-gone = Diese Vorlage existiert nicht mehr.
operation-template-fresh = Neue Vorlage.
operation-template-created = Vorlage gespeichert.
operation-template-updated = Vorlage geändert.
operation-template-label-required = Die Eingabe eines Namens ist obligatorisch
operation-template-duplicate = Eine Vorlage mit demselben Namen existiert bereits

# Das Datenblatt F36, Abschnitt für Abschnitt — seine genauen Beschriftungen.
operation-template-field-id = ID Buchungsvorlage
operation-template-group-name = Standardname der künftigen Buchung nach Anwendung der Vorlage
operation-template-field-label = Name
operation-template-group-amount = In dieser Vorlage vordefinierter Standardbetrag der Buchung
operation-template-field-direction = Buchungsart
operation-template-field-amount = Betrag
operation-template-group-status = Standardstatus der Buchung in dieser Vorlage
operation-template-field-status = Buchungsstatus
operation-template-group-classification = Angaben der Vorlage zur Einordnung und Berechnung der Statistiken
operation-template-field-category = Kategorie
operation-template-field-assignment = Zuordnung
operation-template-field-mode = Zahlungsart
operation-template-field-payee = Zahlungspartner
operation-template-field-project = Projekt

# Die Schaltfläche „Vorlage“ des Buchungsdatenblatts: ein Symbol, zwei Gesten.
operation-template-question = Was möchten Sie mit den Buchungsvorlagen tun?
operation-template-apply = Vorlage anwenden
operation-template-save-as = Als Vorlage speichern
operation-template-applied = Vorlage angewendet. Bestätigen Sie das Datenblatt, um sie zu speichern.
operation-template-saved-as = Buchung als Vorlage gespeichert.
operation-template-needs-label = Geben Sie der Buchung einen Namen, bevor Sie daraus eine Vorlage machen.

# --- F26 / F27 — Das Budget (Phase 11) ----------------------------------
# Zwei Türen, zwei Fragen: man gibt sein Budget ein, oder man kontrolliert, ob
# es eingehalten wurde. Die Achse ist der Budgetposten, die Einheit ist das
# Jahr, und die Vorzeichenkonvention ist die der Buchungen — eine Ausgabe wird
# negativ geschrieben.

window-budget-entry-title = Budgeteingabe: geplante Ausgaben(-) und Einnahmen(+) für ein Jahr
window-budget-control-title = Budgetkontrolle

budget-column-line = Budgetposten
budget-none = Es ist kein Budgetposten gespeichert: das Budget wird je Posten eingegeben.
budget-planned = Geplant
budget-actual = Realisiert
budget-sum = Summe
budget-cumulative = Kumuliert
budget-total = Gesamt
# Die Erinnerung an die Vorzeichenkonvention, in Rot unter der Eingabetabelle.
# Sein Satz, Wort für Wort und einschließlich der Leerzeichen (Screenshot
# „POINT 004 saisie budget.png“): er steht in Rot unter der Tabelle, und der
# Fenstertitel wiederholt ihn verkürzt. Ohne ihn erriete niemand die Konvention.
budget-sign-warning = Erfassen Sie unbedingt die Ausgaben  mit negativem Vorzeichen und die geplanten Einnahmen mit positiven Beträgen
budget-entry-help = Tippen Sie die Beträge in die Felder und speichern Sie anschließend.
budget-saved = Budget gespeichert.
budget-nothing-changed = Keine Änderung zu speichern.
budget-discard-question = Änderungen am Budget verwerfen?

# Das Menü Anzeige der Kontrolle: die zwei Arten, dieselbe Abweichung zu lesen.
budget-menu-display = Anzeige
budget-display-money = Werte
budget-display-percent = Prozentwerte
budget-control-help = Grün: mindestens so gut wie geplant. Rot: schlechter.

# --- F09 — Übertragung eines Betrags zwischen zwei Konten (Phase 12) -----
# Eine Umbuchung ist nicht eine Buchung, es sind zwei: eine Belastung auf dem
# Quellkonto, eine Gutschrift auf dem Zielkonto. Sie gehen zusammen los oder
# gar nicht.

window-transfer-title = Einen Betrag zwischen zwei Konten übertragen

transfer-group-source = Den Betrag von diesem Quellkonto abbuchen
transfer-group-target = Den Betrag diesem Zielkonto gutschreiben
transfer-group-description = Beschreibung der Buchung
transfer-group-nomenclature = Angaben zu den Stammdaten
transfer-group-amount = Betrag der zu übertragenden Summe
transfer-field-source = Quellkonto
transfer-field-target = Zielkonto
transfer-field-label = Bezeichnung
transfer-field-reference = Zahlungsreferenz
transfer-field-date = Datum
transfer-field-status = Buchungsstatus
transfer-field-clearing = Abgleichdatum
transfer-field-category = Kategorie
transfer-field-mode = Zahlungsart
transfer-field-assignment = Zuordnung
transfer-field-payee = Zahlungspartner / Händler
transfer-field-project = Projekt
transfer-field-amount = Betrag

# Der einzige Knopf der Fenster, die etwas mitteilen, statt zu fragen.
ui-ok = OK
transfer-help = Wählen Sie die beiden Konten: Ihre Salden werden hier angezeigt.
transfer-title-validate = Überweisung ausführen
# Die drei Salden des gewählten Kontos, damit man sieht, was die Überweisung bedeutet.
transfer-balances = { $account } — Bank: { $bank } · Tatsächlich: { $real } · Endsaldo: { $final }
# Das Fenster, das zusammenfasst, was gerade geschrieben wurde.
transfer-done = Überweisung ausgeführt. { $amount } vom Konto { $source } auf das Konto { $target }, am { $date }.

transfer-refusal-accounts-required = Wählen Sie das Quellkonto und das Zielkonto
transfer-refusal-same-account = Quellkonto und Zielkonto können nicht dasselbe sein: eine Überweisung geht von einem Konto auf ein anderes
transfer-refusal-account-gone = Eines der beiden Konten existiert nicht mehr
transfer-refusal-label-required = Die Bezeichnung ist erforderlich
transfer-refusal-date-required = Das Datum ist erforderlich
transfer-refusal-amount = Der zu überweisende Betrag muss strikt positiv sein

# ---------------------------------------------------------------------------
# Phase 13 — der Import eines Excel-Blatts (F34, F35, Zuordnung).
# ---------------------------------------------------------------------------

window-excel-import-title = Import eines Excel-Blatts [ Schritt 1/3 ]: Festlegung des Erfassungsbereichs
window-excel-fields-title = Import eines Excel-Blatts [ Schritt 2/3 ]: Zuordnung der Felder
window-excel-association-title = Import eines Excel-Blatts: Zuordnung der Daten

# Die Frage, die beim Öffnen gestellt wird. Eine Excel-Datei wird von Hand
# gebaut: sie enthält, was sie enthält, und ein Teil des Unsinns, den sie
# mitbringt, ist nicht erkennbar. Also bieten wir das Netz an, bevor gesprungen wird.
excel-backup-question = Ein Excel-Blatt wird von Hand gebaut: es kann Datumsangaben enthalten, die gültig und trotzdem falsch sind, Beträge im richtigen Format mit falschem Vorzeichen — und das kann keine Prüfung erkennen. Der Import schreibt diese Zeilen in Ihr Konto. Möchten Sie Ihre Daten sichern, bevor Sie beginnen?
excel-backup-later = Die Datensicherung ist in dieser Version von Radinus 2 noch nicht angeschlossen. Schließen Sie solange Radinus und kopieren Sie Ihre Datenbankdatei selbst: dann können Sie ohne Risiko importieren.

excel-group-file = 1 - Die zu importierende Excel-Datei bestimmen
excel-pick = Die Excel-Datei bestimmen
excel-sheet = Blatt der Arbeitsmappe:
excel-group-header = 2 - Festlegen: Zellkoordinaten der Kopfzeile der Tabelle, in der die Spaltennamen stehen.
excel-header-row = Nummer der ersten Zeile, in der die Spaltennamen stehen
excel-first-column = Erste Spalte der Kopfzeile ( Spalte ganz links ):
excel-column-count = Anzahl der Spalten der Tabelle
excel-group-rows = 3 - Festlegen: Nummern der ersten und der letzten Zeile der Liste mit den Daten der Tabelle ( unterhalb der Kopfzeile und ohne diese )
excel-first-data-row = Erste Zeile mit Daten
excel-last-data-row = Letzte Zeile mit Daten:
excel-group-shape = 4 - Festlegen: Wie Ihre Datei die Beträge schreibt
excel-shape-single = Eine einzige Spalte mit Beträgen, mit Vorzeichen ( Ausgaben negativ )
excel-shape-debit-credit = Zwei getrennte Spalten: eine Spalte Soll und eine Spalte Haben
excel-shape-note = Im Modus mit zwei Spalten wird das Vorzeichen in der Spalte Soll nicht berücksichtigt: eine Sollbuchung nimmt immer Geld weg, ob dort „-50“ oder „50“ steht.
excel-group-test = 5 - Testansicht: Sehen Sie sich die Erfassung an, wie Ihre Einstellungen sie ergeben
excel-test = Testen Sie die Einstellungen, die Sie in den Schritten 2, 3 und 4 festgelegt haben.
excel-test-note = Hinweis: Die Namen der Kopfzeile und der Inhalt der Tabelle unten müssen denen Ihrer Excel-Tabelle entsprechen. Der Erfassungsbereich darf nicht über den Bereich der Tabelle hinausgehen.

excel-help = Gehen Sie die fünf Gruppen der Reihe nach durch, dann testen Sie: Sie können erst zu Schritt 2 wechseln, wenn Sie gesehen haben, was der Bereich erfasst.
excel-no-file = Bestimmen Sie zuerst die zu importierende Excel-Datei.
excel-not-tested = Einstellungen geändert: Starten Sie die Testansicht erneut, bevor Sie bestätigen.
excel-tested = Erfasster Bereich: { $rows } Zeilen, { $columns } Spalten. Prüfen Sie, ob die Tabelle unten Ihrem Blatt ähnelt.
excel-empty-capture = Der Bereich, den Sie angegeben haben, erfasst keine einzige Zeile: prüfen Sie die Zeilen- und Spaltennummern.
excel-title-next = Zum nächsten Schritt wechseln
excel-into-account = Import in das Konto { $account }.

excel-tab-links = Verknüpfungen zwischen Feldern
excel-tab-settings = Importeinstellungen
excel-column-excel = Kopfzeile_Excel
excel-column-radinus = Rubrik_Radinus
excel-links-help = Geben Sie neben jeder Spalte Ihres Blatts an, welche Rubrik von Radinus sie speist. Spalten, die auf [IGNORE] stehen bleiben, werden nicht importiert.
excel-group-category = Kategorien ohne Entsprechung
excel-group-payment-mode = Zahlungsart ohne Entsprechung
excel-group-assignment = Zuordnung ohne Entsprechung
excel-policy-create = { $kind ->
    [payment-mode] Nicht vorhandene Zahlungsarten automatisch anlegen
    [assignment] Nicht vorhandene Zuordnungen automatisch anlegen
   *[category] Nicht vorhandene Kategorien automatisch anlegen
}
excel-policy-ask = { $kind ->
    [payment-mode] Für jede nicht vorhandene Zahlungsart fragen, wohin die Daten übertragen werden
    [assignment] Für jede nicht vorhandene Zuordnung fragen, wohin die Daten übertragen werden
   *[category] Für jede nicht vorhandene Kategorie fragen, wohin die Daten übertragen werden
}
excel-policy-blank = { $kind ->
    [payment-mode] Die Zahlungsart leer lassen
    [assignment] Die Zuordnung leer lassen
   *[category] Die Kategorie leer lassen
}
excel-policy-default = { $kind ->
    [payment-mode] Nicht vorhandene Zahlungsarten in eine Standard-Zahlungsart übertragen
    [assignment] Nicht vorhandene Zuordnungen in eine Standard-Zuordnung übertragen
   *[category] Nicht vorhandene Kategorien in eine Standard-Kategorie übertragen
}
excel-define-destination = Ziel festlegen
excel-not-linked = { $kind ->
    [payment-mode] Keine Spalte speist die Zahlungsart: diese Einstellung gilt nicht.
    [assignment] Keine Spalte speist die Zuordnung: diese Einstellung gilt nicht.
   *[category] Keine Spalte speist die Kategorie: diese Einstellung gilt nicht.
}
excel-fields-help = Stellen Sie die Entsprechungen ein, dann die drei Regeln, bevor Sie den Import starten.
excel-title-import = Import starten

excel-refusal-required = Die Rubriken Datum, Bezeichnung und Betrag müssen zwingend auf Excel-Spalten verweisen
excel-refusal-column-twice = Verschiedene Radinus-Rubriken verweisen auf dieselbe Excel-Spalte: eine Spalte kann nur eine einzige Rubrik speisen
excel-refusal-field-twice = Dieselbe Radinus-Rubrik ist zwei Excel-Spalten zugeordnet: sie kann nur eine haben
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Sie haben gewählt, bei unbekannten Zahlungsarten zu fragen, wohin sie übertragen werden: drücken Sie „Ziel festlegen“, bevor Sie den Import starten.
    [assignment] Sie haben gewählt, bei unbekannten Zuordnungen zu fragen, wohin sie übertragen werden: drücken Sie „Ziel festlegen“, bevor Sie den Import starten.
   *[category] Sie haben gewählt, bei unbekannten Kategorien zu fragen, wohin sie übertragen werden: drücken Sie „Ziel festlegen“, bevor Sie den Import starten.
}

excel-column-data = Daten_Excel
excel-column-destination = { $kind ->
    [payment-mode] Zahlungsart_Radinus
    [assignment] Zuordnung_Radinus
   *[category] Kategorie_Radinus
}
excel-association-help = Wählen Sie neben jedem Wert aus Ihrem Blatt den Wert von Radinus, unter dem er eingeordnet werden soll. Eine leer gelassene Zeile bleibt ohne Einordnung.
excel-association-none = Kein unbekannter Wert: alles, was Ihr Blatt enthält, gibt es bereits in Radinus.

excel-imported = Import abgeschlossen: { $count } Buchungen geschrieben, { $refused } Zeilen abgelehnt, { $created } Stammdatenwerte angelegt.
excel-report-title = Bericht über den Import
excel-column-row = Excel-Zeile
excel-column-content = Inhalt
excel-column-reason = Grund der Ablehnung
excel-nothing-refused = Alle Zeilen Ihres Blatts sind übernommen worden: keine Ablehnung.

excel-refused-date = Datum fehlt oder ist unlesbar
excel-refused-amount = Betrag fehlt oder ist unlesbar
excel-refused-amount-both = Ein Betrag in der Spalte Soll und ein weiterer in der Spalte Haben: die Wahl ist unmöglich
excel-refused-amount-missing = Weder Soll noch Haben in dieser Zeile

# ---------------------------------------------------------------------------
# Phase 16 — die wiederkehrenden Buchungen (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Liste der wiederkehrenden Buchungen
window-recurring-form-title = Karte zur Definition der Regel für die Erzeugung wiederkehrender Buchungen
window-recurring-calendar-title = Kalendervorschlag für die Buchungen, die in Ihre Bankkonten eingefügt werden sollen

recurring-column-label = BEZEICHNUNG
recurring-none = Keine wiederkehrende Regel gespeichert.
recurring-help = Wählen Sie eine Regel, dann den Kalender, um die Fälligkeiten zu sehen, die sie vorschlägt.
recurring-title-calendar = Kalender der Fälligkeiten vorschlagen
recurring-deleted = { $count ->
    [0] Keine Regel gelöscht.
    [one] Eine Regel gelöscht. Ihre Buchungen bleiben im Konto.
   *[other] { $count } Regeln gelöscht. Ihre Buchungen bleiben in den Konten.
}
recurring-gone = Diese Regel existiert nicht mehr.
recurring-delete-question = Die ausgewählten Regeln löschen? Die Buchungen, die sie bereits eingefügt haben, bleiben in Ihren Konten.

recurring-group-identity = Kennung und betroffenes Bankkonto
recurring-group-nomenclature = Stammdaten
recurring-group-amount = Festlegung des Betrags der Buchung
recurring-group-period = Festlegung des Intervalls
recurring-group-ending = Bedingungen für das Ende des Intervalls
recurring-group-produced = Informationen zu bereits eingefügten Buchungen ( nur zur Ansicht )

recurring-field-id = Kennung der Buchung
recurring-field-account = Zielkonto
recurring-field-label = Bezeichnung
recurring-field-category = Kategorie
recurring-field-mode = Zahlungsart
recurring-field-assignment = Zuordnung
recurring-field-payee = Zahlungspartner / Händler
recurring-field-project = Projekt
recurring-field-direction = Art der Buchung
recurring-field-amount = Betrag
recurring-field-next = Datum der nächsten Buchung
recurring-field-every = Dann alle
recurring-field-end-date = Enddatum
recurring-field-repeat = Anzahl Wiederholungen
recurring-field-guid = GUID der Buchung
recurring-field-produced-count = Anzahl eingefügter Buchungen
recurring-field-produced-last = Datum der letzten eingefügten Buchung
recurring-field-produced-total = Summe der erzeugten Beträge

recurring-unit-day = Tag
recurring-unit-week = Woche
recurring-unit-month = Monat
recurring-unit-quarter = Quartal
recurring-unit-year = Jahr
recurring-ending-no-limit = Ohne Begrenzung
recurring-ending-until-date = Mit Enddatum
recurring-ending-repeat-count = Anzahl Wiederholungen

recurring-title-erase = Die von dieser Regel bereits eingefügten Buchungen löschen
recurring-erase-question = { $count ->
    [one] Diese Regel hat eine Buchung in Ihre Konten eingefügt. Möchten Sie sie löschen? Die Salden werden neu berechnet, und die Regel geht nicht zurück.
   *[other] Diese Regel hat { $count } Buchungen in Ihre Konten eingefügt. Möchten Sie alle löschen? Die Salden werden neu berechnet, und die Regel geht nicht zurück.
}
recurring-erase-none = Diese Regel hat noch keine Buchung eingefügt.
recurring-erased = { $count ->
    [0] Keine Buchung gelöscht.
    [one] Eine Buchung gelöscht, Salden neu berechnet.
   *[other] { $count } Buchungen gelöscht, Salden neu berechnet.
}

recurring-calendar-help = Entfernen Sie mit dem Papierkorb die Fälligkeiten, die Sie nicht wollen, und bestätigen Sie dann, um sie einzufügen.
recurring-calendar-none = Keine Fälligkeit vorzuschlagen: prüfen Sie das Datum der nächsten Buchung und das Konto Ihrer Regeln.
recurring-calendar-column-account = Konto
recurring-calendar-column-date = Datum
recurring-calendar-column-label = Beschreibung
recurring-calendar-column-amount = Betrag
recurring-calendar-column-category = Kategorie
recurring-calendar-column-assignment = Zuordnung
recurring-calendar-column-mode = Zahlungsart
recurring-calendar-column-payee = Zahlungspartner
recurring-calendar-column-project = Projekte
recurring-calendar-removed = { $count ->
    [one] Eine Fälligkeit aus dem Vorschlag entfernt.
   *[other] { $count } Fälligkeiten aus dem Vorschlag entfernt.
}
recurring-title-insert = Die behaltenen Fälligkeiten in die Konten einfügen
recurring-nothing = Es bleibt keine Fälligkeit mehr zum Einfügen.
# Die Frage, die vor dem Schreiben gestellt wird: einen Kalender einzufügen legt
# echte Buchungen in echten Konten an, und das geschieht nicht auf einen zerstreuten Klick.
recurring-insert-question = { $count ->
    [one] Diese Fälligkeit in Ihr Konto einfügen? Eine Buchung wird angelegt und die Salden werden neu berechnet.
   *[other] Diese { $count } Fälligkeiten in Ihre Konten einfügen? Ebenso viele Buchungen werden angelegt und die Salden werden neu berechnet.
}
recurring-inserted = { $count ->
    [one] Eine Buchung eingefügt. Die Regel läuft nach der letzten eingefügten Fälligkeit weiter.
   *[other] { $count } Buchungen eingefügt. Die Regeln laufen nach ihrer letzten eingefügten Fälligkeit weiter.
}

recurring-refusal-label-required = Die Eingabe einer Bezeichnung ist obligatorisch
recurring-refusal-date-required = Die Eingabe des Datums der nächsten Buchung ist obligatorisch
recurring-refusal-date-too-old = Das Datum der nächsten Buchung muss im Jahr 2000 oder später liegen
recurring-refusal-account-gone = Das angegebene Bankkonto ist nicht auffindbar, bitte wählen Sie ein neues aus, damit die Regel anwendbar wird
recurring-refusal-end-required = Bei einem Enddatum muss das Datum eingegeben werden
recurring-refusal-end-before-start = Das Enddatum kann nicht vor dem Datum der nächsten Buchung liegen
recurring-refusal-end-too-far = Der Abstand zwischen dem Datum der nächsten Buchung und dem Enddatum darf 10 000 Tage nicht überschreiten

# --- Phase 15 — die Ausdrucke und Berichte ------------------------------
# Der große Titel des Bandes, wortwörtlich aus dem ursprünglichen WinDev-Bericht übernommen.
print-operations-title = Liste der Banktransaktionen und Teilbuchungen
print-menu-operations-pdf = Druck in PDF-Datei
print-recap-title = Übersicht nach Kategorie
print-recap-count = Zeilen
print-row-count = Anzahl Zeilen:
print-total-debit = Summe Soll:
print-total-credit = Summe Haben:
print-final-balance = Endsaldo:
print-licence = Radinus ist freie Software unter der GNU GPL v3 oder einer späteren Version
print-nothing = Es gibt nichts zu drucken.
print-done = Bericht gedruckt und geöffnet: „{ $file }“.
print-failed = Drucken nicht möglich: { $reason }
# Das PDF ist ordentlich geschrieben, aber das System konnte es nicht öffnen: wir
# sagen es, ohne einen Fehlschlag vorzutäuschen, denn die Datei ist da.
print-not-opened = Bericht in „{ $file }“ gedruckt, aber Ihr System konnte die Datei nicht von selbst öffnen.

# --- Der RIB-Bericht (F32) ---------------------------------------------
# Die Beschriftungen der Bankverbindung, aus dem Originaldokument übernommen.
rib-title = BANKVERBINDUNG
rib-bank = Bank:
rib-national = RIB - Nationale Kontokennung
rib-establishment = INSTITUT
rib-branch = FILIALE
rib-number = KONTONUMMER
rib-key = RIB-PRÜFZIFFER
rib-domiciliation = KONTOFÜHRENDE STELLE
rib-iban = IBAN - Internationale Kontokennung
rib-bic = BIC - Internationale Institutskennung
rib-holder = Kontoinhaber

# --- Das Fenster F32 ---------------------------------------------------
window-rib-title = Druck der Bankverbindung ( Relevé d'Identité Bancaire )
rib-group-bank = Bank
rib-group-holder = Kontoinhaber
rib-group-details = Bankverbindung
rib-field-bank = Name der Bank
rib-field-domiciliation = Kontoführende Stelle
rib-field-holder = Name des Inhabers
rib-field-address = Anschrift
rib-field-establishment = Institut
rib-field-branch = Filiale
rib-field-number = Kontonummer
rib-field-key = RIB-Prüfziffer
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Wichtige Nutzungsbedingungen, die im Fall eines Ausdrucks zwingend einzuhalten sind
rib-declaration = Ich, der unterzeichnende Benutzer der Software, erkläre an Eides statt:
rib-declaration-first = - Ich bestätige, bei meiner Bank überprüft zu haben, dass die in diesem Fenster enthaltenen Bankdaten korrekt sind und meinem Willen entsprechen . Ebenso bestätige ich, dass ich mich verpflichte zu prüfen, dass die im Ausdruck der Bankverbindung enthaltenen Angaben korrekt sind und meinem Willen entsprechen. Dieser Ausdruck und die Verwendung der Bankverbindung erfolgen unter meiner alleinigen Verantwortung
rib-declaration-second = - Der Inhaber des Kontos zu sein, dessen Bankverbindung gedruckt wird, und die Funktionen dieser Software nicht zu einem gesetzeswidrigen Zweck zu nutzen.
rib-title-print = Druck auf Drucker
rib-title-pdf = Druck in PDF-Datei
# Das Kästchen ist keine schmückende Warnung: Solange es nicht angehakt ist,
# sind die beiden Schaltflächen ausgeschaltet (Entscheidung von Fabrice, 01/08/2026).
rib-declaration-required = Haken Sie die Erklärung an Eides statt an, um drucken zu können.
rib-help = Prüfen Sie Ihre Bankdaten, haken Sie die Erklärung an und drucken Sie dann.
rib-account-gone = Dieses Bankkonto ist nicht auffindbar.
rib-fields-read-only = Diese Bankdaten stammen aus dem Kontoblatt: Korrigieren Sie sie dort, um sie hier zu ändern.
rib-printed = Bankverbindung an Ihren Standarddrucker gesendet.
rib-print-failed = Drucken nicht möglich: { $reason }
rib-pdf-done = Bankverbindung gedruckt und geöffnet: „{ $file }“.
rib-pdf-not-opened = Bankverbindung in „{ $file }“ gedruckt, aber Ihr System konnte die Datei nicht von selbst öffnen.
menu-accounts-bank-details = Eine Bankverbindung ausgeben

# Die Wahl des Druckers. Radinus stellt die Frage selbst: keines der drei
# Webviews öffnet den Druckdialog des Systems.
print-choose-printer = Auf welchem Drucker möchten Sie drucken?
print-do-print = Drucken
rib-printed-on = Bankverbindung an den Drucker „{ $printer }“ gesendet.
ui-cancel = Abbrechen

# Das System konnte keinen Drucker benennen: Wir drucken trotzdem auf dem
# Standarddrucker, statt den Benutzer zu blockieren.
print-printers-unknown = Ihr System konnte keinen Drucker benennen: Das Dokument ist an den Standarddrucker gegangen.

print-menu-operations-printer = Druck auf Drucker
print-sent-on = Bericht an den Drucker „{ $printer }“ gesendet.
print-sent-default = Bericht an Ihren Standarddrucker gesendet.

# --- Phase 17 — die Vorgänge an der Datenbank ---------------------------
backup-archive = Radinus-Archiv
backup-no-database = Es ist keine Datenbank geöffnet.
backup-done = Datensicherung geschrieben in „{ $file }“.
backup-failed = Datensicherung nicht möglich: { $reason }
restore-unreadable = Diese Datei ist kein lesbares Radinus-Archiv: { $reason }
# Die Frage sagt, was verloren geht, bevor es verloren geht. Das Archiv ist zu
# diesem Zeitpunkt bereits gelesen worden: Was sie ankündigt, ist sicher.
restore-question = „{ $file }“ wiederherstellen? Der gesamte aktuelle Inhalt Ihrer Datenbank wird gelöscht und ersetzt, und was sich darin befindet, geht verloren.
restore-done = Wiederherstellung abgeschlossen: { $accounts } Konten und { $operations } Buchungen.
restore-failed = Wiederherstellung nicht möglich: { $reason }
restore-empty-fields = Leere Felder als Nullwert gelesen: { $count }.


# --- Das Protokoll der technischen Vorgänge (Phase 17) ------------------
# Die drei Status seines Ajoute_Log, in Großbuchstaben wie bei ihm.
journal-status-success = ERFOLG
journal-status-failure = FEHLGESCHLAGEN
journal-status-repaired = REPARIERT
journal-step-reindex = Reparatur der Datenbanktabelle
journal-step-refill = Systemstammdaten leer: Standardwerte wiederhergestellt
journal-step-table-created = Tabelle in der Datenbank nicht vorhanden: leer neu erstellt
journal-step-column-added = Spalte in der Tabelle nicht vorhanden: mit ihrem Standardwert hinzugefügt

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Kennwortschutz
window-password-form-title = Kennwortschutz
password-ask = Diese Datenbank ist geschützt. Geben Sie ihr Kennwort ein.
password-group-database = Betroffene Datenbank
password-group-password = Kennwort
password-group-warning = Vor dem Bestätigen
password-field-old = Altes Kennwort
password-field-new = Neues Kennwort
password-field-repeat = Neues Kennwort wiederholen
password-hint = Lassen Sie das alte leer, wenn die Datenbank noch nicht geschützt ist. Lassen Sie beide neuen leer, um den Schutz aufzuheben.
password-lost-warning = Ein verlorenes Kennwort ist eine verlorene Datenbank: nichts kann sie wiederherstellen. Die Datensicherungen bleiben dagegen unverschlüsselt.
password-show = Kennwort anzeigen
password-remove-question = Schutz dieser Datenbank aufheben?
password-mismatch = Die beiden Eingaben des neuen Kennworts sind verschieden
password-wrong = Das Kennwort passt nicht
password-close-first = Schließen Sie diese Datenbank, bevor Sie ihr Kennwort ändern
password-now-protected = Die Datenbank ist durch ein Kennwort geschützt
password-now-clear = Die Datenbank ist nicht mehr geschützt
journal-step-date-fixed = Korrektur einer Buchung ohne Datum
journal-step-circular = Löschung einer widersprüchlichen Buchung: Zirkelbezug
journal-step-flag-parent-true = Falsches Kennzeichen EstParent=Falsch bei einer Hauptbuchung
journal-step-flag-parent-false = Falsches Kennzeichen EstParent=Wahr bei einer Hauptbuchung
journal-step-flag-child = Falsches Kennzeichen EstParent=Wahr bei einer Teilbuchung
journal-step-orphan = Löschung einer verwaisten Teilbuchung
journal-step-third-level = Löschung einer Teilbuchung, die an eine andere Teilbuchung gehängt war
journal-step-coherence = Allgemeine Neuberechnung der Stimmigkeit zwischen Teilbuchungen und Hauptbuchungen
journal-step-balances = Neuberechnung aller Salden aller Konten
journal-step-vacuum = Optimierung der Datenbankdatei
journal-step-analyze = Aktualisierung der Suchstatistiken
journal-step-backup-begin = Beginn der Datensicherung der Datenbank
journal-step-backup-end = Ende der Datensicherung der Datenbank
journal-step-restore-begin = Beginn der Wiederherstellung der Datenbank aus dem Archiv
journal-step-restore-end = Ende der Wiederherstellung der Datenbank aus dem Archiv
journal-step-restore-read = Lesen des Archivs

# --- Das Fenster des Protokolls (⌘H) ------------------------------------
window-journal-title = Protokoll des letzten technischen Vorgangs
journal-column-step = Schritt
journal-column-file = Datei
journal-column-table = Tabelle
journal-column-status = Status
journal-column-error = Fehler
journal-column-comments = Kommentare
journal-empty = Seit dem Start der Software wurde noch kein technischer Vorgang durchgeführt.
journal-help = Das Protokoll bewahrt nur den letzten technischen Vorgang: Datensicherung, Wiederherstellung, Reparatur, Löschung oder Öffnen einer Datenbank.

# --- Die Reparatur ------------------------------------------------------
menu-file-repair-running = Reparatur und Optimierung laufen…
repair-done = { $anomalies ->
    [0] Reparatur abgeschlossen: keine Anomalie gefunden. { $lines } Schritte protokolliert.
    [one] Reparatur abgeschlossen: eine Anomalie repariert. { $lines } Schritte protokolliert.
   *[other] Reparatur abgeschlossen: { $anomalies } Anomalien repariert. { $lines } Schritte protokolliert.
}
repair-failed = Reparatur nicht möglich: { $reason }

journal-status-started = LÄUFT
journal-status-finished = BEENDET
journal-step-backup-table = Schreiben der Tabelle in das Archiv
journal-step-backup-write = Schreiben des Archivs
journal-step-backup-verified = Prüfung des geschriebenen Archivs: Dateien erneut gelesen / erwartet, Datensätze erneut gelesen / geschrieben
journal-step-backup-total = Gesichert insgesamt: Datensätze, Daten, Dateigröße
journal-step-restore-table = Lesen der Tabelle im Archiv
journal-step-restore-missing = Datei fehlt im Archiv: Diese Tabelle wird nicht wiederhergestellt
journal-step-restore-wipe = Vollständige Löschung des Datenbankinhalts vor der Wiederherstellung
journal-step-restore-write = Schreiben in die Datenbank
journal-step-restore-total = Wiederhergestellt insgesamt: Konten, Buchungen
journal-step-restore-empty-fields = Beim Lesen ergänzte leere Felder
backup-verify-mismatch = Das geschriebene Archiv liest sich nicht so zurück, wie es geschrieben wurde: Verlassen Sie sich nicht darauf, machen Sie die Datensicherung erneut.

# --- Die Anhänge einer Buchung (F28, Phase 17) --------------------------
window-attachments-title = Anhänge der Buchung
attachment-filter = Zugelassene Dokumente
attachment-none = Diese Buchung trägt keinen Anhang.
attachment-title-add = Ein Dokument an diese Buchung anhängen
attachment-title-open = Den Anhang öffnen
attachment-title-remove = Den Anhang entfernen und seine Datei in den Papierkorb verschieben
# Der Zustand der Datei auf der Festplatte. „Nicht prüfbar“ ist kein grundloses Eingeständnis
# von Unwissen: Die aus Radinus 1.9.3 stammenden Prüfsummen sind durch das Sicherungsformat
# verstümmelt, und eine Datei danach zu beurteilen hieße, aufs Geratewohl anzuklagen.
attachment-state-ok = Unversehrt
attachment-state-changed = Geändert
attachment-state-missing = Datei fehlt
attachment-state-unknown = Nicht prüfbar
attachment-added = „{ $name }“ wurde der Buchung beigefügt.
attachment-removed = Anhang entfernt, seine Datei liegt im Papierkorb.
attachment-removed-kept = Anhang entfernt, aber seine Datei konnte nicht in den Papierkorb verschoben werden.
attachment-remove-question = „{ $name }“ aus dieser Buchung entfernen? Die Datei wird in den Papierkorb verschoben.
attachment-opened = „{ $name }“ wurde geöffnet.
attachment-opened-changed = „{ $name }“ wurde geöffnet, aber der Inhalt hat sich geändert, seit die Datei angehängt wurde.
attachment-gone = Dieser Anhang existiert nicht mehr.
attachment-file-missing = Die Datei von „{ $name }“ ist auf der Festplatte nicht auffindbar.
attachment-failed = Vorgang nicht möglich: { $reason }
attachment-save-first = Speichern Sie zuerst die Buchung: Ein Anhang hängt an einer Buchung, die es gibt.
attachment-refusal-missing = Diese Datei existiert nicht.
attachment-refusal-extension = Dieser Dateityp wird nicht akzeptiert. Akzeptiert werden: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Die Buchung, an die dieses Dokument angehängt werden soll, existiert nicht.
journal-step-backup-attachments = Anhänge dem Archiv hinzugefügt
journal-step-backup-attachment-missing = Anhang auf der Festplatte nicht auffindbar: Er wird im Archiv fehlen
journal-step-restore-attachments = Anhänge aus dem Archiv entnommen
attachment-title-replace = Das Dokument dieses Anhangs ersetzen
attachment-replaced = Das Dokument wurde durch „{ $name }“ ersetzt.

# ---------------------------------------------------------------------
# F08 — das Menü „Extras“ des Kontoblatts.
#
# Seine drei Einträge sind Portierungen aus Fabrices WLangage (Ordner
# „Information import export base piece jointe“): die Berechnung des
# abgeglichenen Anfangssaldos, die Statistiken des Kontos und die Löschung
# aller seiner Transaktionen. Das Menü wirkt nur im Bearbeitungsmodus
# (Entscheidung vom 02/08/2026): Beim Anlegen gibt es nichts zu zählen, in
# der Ansicht zeigt das Blatt nur.
# ---------------------------------------------------------------------

account-tools = Extras
account-tools-initial-balance = Abgeglichenen Anfangssaldo festlegen
account-tools-statistics = Statistiken Bankkonto
account-tools-delete-operations = Alle Transaktionen des Kontos löschen

# Die Frage der Berechnung, wortwörtlich die des Originals. { $total } ist die
# Summe der abgeglichenen Buchungen, bereits im Währungsformat geschrieben.
account-initial-balance-question =
    Um den abgeglichenen Anfangssaldo im Hinblick auf die auf diesem Konto vorhandenen Buchungen zu berechnen, geben Sie bitte den aktuellen Saldo Ihrer Bank an
    Der abgeglichene Anfangssaldo wird berechnet als:
    { "[" }Aktueller Banksaldo] - [Summe der abgeglichenen Buchungen ({ $total }) ].
    { "" }
    Um diesen Wert nicht erneut eingeben zu müssen, müssen Sie bei der Liste der Bankbuchungen dieses Kontos vollständig auf dem neuesten Stand sein.

account-statistics-none = Keine Transaktion

# Die vierzehn Zeilen seines Info(). Der Tippfehler „pengagés“ des Originals
# ist korrigiert, nach Entscheidung von Fabrice vom 02/08/2026 — wie „Bank
# Identifer Code“ auf ebendiesem Blatt.
account-statistics =
    Gesamtzahl der Transaktionen in diesem Konto: { $count }
    { "" }
    Anzahl der abgeglichenen Transaktionen in diesem Konto: { $pointed }
    Betrag der abgeglichenen Sollbuchungen: { $pointedDebits }
    Betrag der abgeglichenen Habenbuchungen: { $pointedCredits }
    Differenz zwischen abgeglichenen Haben- und Sollbuchungen: { $pointedDifference }
    { "" }
    Anzahl der vorgemerkten Transaktionen in diesem Konto: { $committed }
    Betrag der vorgemerkten Sollbuchungen: { $committedDebits }
    Betrag der vorgemerkten Habenbuchungen: { $committedCredits }
    Differenz zwischen vorgemerkten Haben- und Sollbuchungen: { $committedDifference }
    { "" }
    Anzahl der geplanten Transaktionen in diesem Konto: { $planned }
    Betrag der geplanten Sollbuchungen: { $plannedDebits }
    Betrag der geplanten Habenbuchungen: { $plannedCredits }
    Differenz zwischen geplanten Haben- und Sollbuchungen: { $plannedDifference }
    { "" }
    Älteste Transaktion: { $first }
    Neueste Transaktion: { $last }

# Die doppelte Schranke vor dem Löschen. { $word } ist das „Ja“ der aktuellen
# Sprache — ein Spanischsprachiger, den man OUI schreiben ließe, verstünde
# nicht (Entscheidung von Fabrice, 02/08/2026).
account-delete-operations-question =
    Möchten Sie wirklich alle Buchungen dieses Bankkontos löschen?
    Schreiben Sie zur Bestätigung { $word } in das Feld unten und bestätigen Sie

account-delete-operations-done =
    { $count ->
        [0] Keine Transaktion gelöscht.
        [one] 1 Transaktion gelöscht.
       *[other] { $count } Transaktionen gelöscht.
    }

# ---------------------------------------------------------------------
# Die Datenbankauswahl und die Wahl der Sprache (02/08/2026)
#
# In der Besprechung mit Fabrice entschieden: Radinus legt keine Datenbank
# mehr ohne Erlaubnis an; steht keine Sprache in der Konfiguration, fragt
# es vor allem anderen nach der Sprache; eine Datenbank ist jeder Ordner
# in databases/, der eine radinus.sqlite enthält, wie er auch heiße.
#
# Das Fenster der Sprachwahl hat hier keinen einzigen Schlüssel: es
# verwendet keinen einzigen Satz, und gerade das erlaubt ihm, verstanden
# zu werden, bevor man weiß, welche Sprache der Benutzer spricht.
# ---------------------------------------------------------------------

window-database-selector-title = Datenbanken
window-database-form-title = Neue Datenbank
database-group-identity = Identifikation der Datenbank
database-group-restore = Datenbank mit den Daten einer Sicherung initialisieren
database-choose-backup = Sicherungsdatei auswählen
database-no-backup = Keine Sicherung gewählt: die Datenbank entsteht leer.

databases-column-label = Datenbank
databases-column-comment = Kommentar
databases-column-folder = Ordner
databases-column-created = Angelegt am

databases-none = Noch keine Datenbank: Legen Sie eine an.
databases-help = Wählen Sie die Datenbank, die Sie öffnen wollen, oder legen Sie eine neue an.
databases-select = Wählen Sie zuerst eine Datenbank in der Liste.
databases-tools = Extras
databases-title-open = Diese Datenbank öffnen

database-created = Die Datenbank „{ $label }“ ist angelegt.
database-field-label = Name der Datenbank
database-field-comment = Kommentar
database-label-required = Geben Sie dieser Datenbank einen Namen: Er unterscheidet sie von den anderen.
database-gone = Diese Datenbank ist nicht mehr da: Sie wurde seit dem Öffnen dieses Fensters verschoben oder gelöscht.

# Das Löschen einer Datenbank (02/08/2026). Der Ordner wandert in den
# Papierkorb des Systems, wie die Anhänge: eine versehentlich gelöschte
# Datenbank holt ein Rechtsklick zurück. Die geöffnete Datenbank wird
# abgelehnt — Radinus hält ihre Datei.
databases-title-delete = Diese Datenbank löschen
database-delete-question =
    Möchten Sie die Datenbank „{ $label }“ wirklich löschen?
    { "" }
    Ihr ganzer Ordner wandert in den Papierkorb: die Buchungen, die Konten und die Anhänge.
    Schreiben Sie zur Bestätigung { $word } in das Feld unten und bestätigen Sie.
database-in-use = Diese Datenbank ist geöffnet: Radinus kann sie nicht löschen. Öffnen Sie zuerst eine andere.
database-deleted = Die Datenbank „{ $label }“ ist im Papierkorb.

# Die Auswahl hat zwei Modi (Fabrice, 02/08/2026). Während der Arbeit
# geöffnet, kann sie nicht mehr öffnen: ein Fenster von Radinus wird einmal
# gebaut und nie zerstört, und nichts könnte es die Datenbank vergessen
# lassen, die es zeigt. Man sieht nach, legt an, löscht — und um die Datenbank
# zu wechseln, beendet man das Programm.
database-quit-first = Um diese Datenbank zu öffnen, beenden Sie Radinus und starten Sie es neu: die Auswahl bietet sie Ihnen beim Start an.


# --- F01 — das Startfenster (Phase 17 bis, 03/08/2026) --------------------
#
# Erste Ergänzung der 2.0.0 gegenüber der 1.9.3: das Startfenster trägt nicht
# mehr nur das Banner. Die Regel, die es bestimmt, steht im Dokument 04 F01:
# es ist die Ansicht OHNE EINEN KLICK, und nichts, was eine Einstellung
# verlangt, kommt hinein.
#
# Die beiden Ringtitel tragen den ganzen Monat, statt vom Fenster Stück an
# Stück gesetzt zu werden: „Ausgaben ... — August 2026“ hat in den drei
# Sprachen nicht dieselbe Wortstellung, und nur Fluent weiß, wo das Loch ist.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Kein Konto offen
    [one] 1 Konto offen
   *[other] { $count } Konten offen
}
welcome-total-bank = Banksaldo
welcome-total-real = Tatsächlicher Saldo
welcome-total-final = Endsaldo
welcome-total-real-detail = abgeglichen + vorgemerkt
welcome-total-final-detail = abgeglichen + vorgemerkt + geplant
welcome-accounts = Ihre Konten
welcome-tile-bank = In der Bank
welcome-tile-real = Tatsächlich
welcome-tile-final = Endgültig
welcome-spending = Ausgaben — { $month }
welcome-earning = Einnahmen — { $month }
ui-legend-budget-lines = Budgetposten
ui-legend-categories = Kategorien
welcome-nothing = Keine Buchung in diesem Monat.
welcome-open-account = Info: Klicken Sie auf ein Konto, um seine Buchungen zu öffnen.
welcome-no-account = Noch kein Bankkonto vorhanden.
welcome-no-account-create = Hier klicken, um ein Bankkonto anzulegen
welcome-previous-month = Voriger Monat
welcome-next-month = Nächster Monat
welcome-refresh = Alles neu einlesen


# --- F39 — die Voreinstellungen (Phase 17 ter, 03/08/2026) ----------------
#
# Die Stellung des Währungszeichens wohnt hier, neben den beiden Trennzeichen:
# sie folgt der Sprache und nicht der Währung. „before“ setzt das Zeichen vor
# die Zahl, jeder andere Wert setzt es dahinter. KEIN Währungszeichen steht in
# dieser Datei: „deutsch“ heißt nicht „Euro“.

ui-money-sign-position = after
window-preferences-title = Voreinstellungen
menu-settings-preferences = Voreinstellungen…
menu-settings-show-main = Hauptfenster anzeigen
menu-settings-folders = Radinus-Ordner
preferences-branch-display = Anzeige
preferences-leaf-language = Sprache
preferences-leaf-currency = Währung
preferences-field-language = Sprache der Software:
preferences-field-currency = Angezeigte Währung:
preferences-field-custom = Währungszeichen:
preferences-currency-system = Systemwährung
preferences-currency-euro = Euro
preferences-currency-dollar = Dollar
preferences-currency-canadian = Kanadische Dollar
preferences-currency-cfa = CFA-Franc
preferences-currency-cfp = CFP-Franc
preferences-currency-swiss = Schweizer Franken
preferences-currency-none = Keine
preferences-currency-custom = Benutzerdefiniert
preferences-currency-system-is = Ihr System meldet:
preferences-currency-system-silent = Ihr System meldet keine Währung: die Beträge werden in Euro angezeigt.
preferences-custom-required = Tippen Sie Ihr Währungszeichen ein, bevor Sie speichern.
preferences-saved = Voreinstellungen gespeichert.
preferences-help = Wählen Sie eine Option im Baum, dann speichern Sie.
preferences-sign-too-long = Ein Währungszeichen umfasst höchstens 8 Zeichen.
preferences-sign-not-a-number = Ein Währungszeichen darf weder Ziffer noch Rechenzeichen noch Komma enthalten: Radinus entfernt sie, wenn es einen Betrag liest, und aus „120“ würde „12“.
preferences-leaf-zoom = Größe der Anzeige
preferences-field-zoom = Vergrößerung:
preferences-zoom-reset = Standardwert
preferences-zoom-hint = Alles wird zusammen größer: der Text, die Symbole, die Spalten. Unter 100 % passt mehr auf den Bildschirm. Die Menüleiste des Systems und seine Dialogfenster dagegen folgen den Einstellungen Ihres Rechners und nicht diesen hier.

# --- Das Banner des Startfensters ----------------------------------------
#
# Diese Sätze standen seit Phase 0 fest in `index.html` und wurden daher nicht
# übersetzt (von Fabrice am 03/08/2026 bemerkt). Der Wahlspruch ist seine
# Stimme: die englische und die spanische Fassung sind Vorschläge, von ihm zu
# berichtigen — ein Slogan wird nicht Wort für Wort übersetzt.
ui-language-tag = de
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — das Eichhörnchen als Maskottchen, im Anzug, umgeben von einem Euro, einem Taschenrechner und Diagrammen
welcome-slogan-one = Eine Software zur Verwaltung persönlicher Finanzen, die Ihnen hilft, weniger auszugeben, um mehr zu gewinnen
welcome-slogan-two = Mit Radinus verstehen Sie, warum kleine Bäche große Flüsse machen.

# --- „Über den Autor“ ----------------------------------------------------
#
# Der Name und die Anschrift stehen in den drei Dateien gleichlautend: sie
# werden nicht übersetzt. Sie stehen trotzdem hier und nicht in der Seite,
# damit die Ansicht keinen einzigen Satz trägt — und damit sie an einer
# einzigen Stelle zu berichtigen sind, wenn der Autor eines Tages umzieht.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Über den Autor
about-author-flag-alt = Flagge Korsikas — der Maurenkopf

# --- „Über Radinus“ ------------------------------------------------------
#
# `about-radinus-version` trägt ein Loch: die Nummer kommt aus der laufenden
# Binärdatei, nie aus einer abgeschriebenen Zeichenkette. Sie steht daher
# nicht im Wörterbuch der Fenster — der Befehl `app_version` füllt sie.
window-about-radinus-title = Über Radinus
about-radinus-name = Radinus
about-radinus-version = Version { $version }
about-radinus-rust-alt = Das Logo der Sprache Rust
about-radinus-tauri-alt = Das Logo von Tauri
about-radinus-built = Radinus ist in Rust geschrieben und mit Tauri gebaut. Das erste berechnet Ihre Konten, das zweite macht daraus eine Desktop-Anwendung.
about-radinus-licence = Freie Software, unter der GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Lizenz
licence-heading = NUTZUNGSLIZENZ DER SOFTWARE RADINUS
licence-logo-alt = Das Logo der GNU General Public License Version 3
licence-name = GNU GPL v3 oder später
licence-intro = Radinus ist freie Software.
licence-freedoms-title = Ihre Lizenz gibt Ihnen vier Freiheiten:
licence-freedom-use = Es zu verwenden, wie und wofür Sie wollen.
licence-freedom-study = Seinen Quellcode zu studieren, der allen offensteht.
licence-freedom-share = Es zu kopieren und weiterzugeben.
licence-freedom-improve = Es zu ändern und Ihre Änderungen weiterzugeben.
licence-read = Den vollständigen Lizenztext lesen

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Dieses Programm wird ohne jede Gewährleistung bereitgestellt, soweit gesetzlich zulässig.
licence-info = Der offizielle Text öffnet sich in Ihrem Browser, auf gnu.org.

