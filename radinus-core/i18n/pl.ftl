# Radinus — komunikaty jądra (Fluent), polski.
# Uzupełniane stopniowo, w miarę powstawania modułów jądra, które wysyłają
# komunikaty do użytkownika. Zob. 08_ARCHITECTURE.md §2.1.

# Wartość zastępcza „0 = Nie określono”, której używa każde nieobowiązkowe
# odwołanie do słownika (02_BASE_DE_DONNEES.md §7 rule 2). Pokazywana na
# początku każdej listy rozwijanej.
# ---------------------------------------------------------------------
# Nazwa języka, zapisana w tym właśnie języku.
#
# To ją pokazują menu Ustawienia i wybór języka przy pierwszym uruchomieniu
# (01_CAHIER_DES_CHARGES.md §3.5: „każdy język zapisany we własnym języku”).
# Jest tutaj, a nie w kodzie, bo to jedyne miejsce, w którym może być
# poprawna: dodać język to złożyć plik, który potrafi się nazwać.
# ---------------------------------------------------------------------
language-name = Polski

nomenclature-unspecified = Nie określono

# Pytanie zadawane przed usunięciem elementu słownika, którego wciąż używają
# operacje (02_BASE_DE_DONNEES.md §7 rule 5). Odtworzone słowo w słowo z
# oryginalnego źródła WinDev (Enreg_Supprimer), razem z typografią — to
# sformułowanie autora, a nie tłumaczenie.
nomenclature-delete-confirm = Wykryto operacje (transakcje bankowe) posiadające atrybut typu '{ $label }'. Czy potwierdzasz, że chcesz zresetować ten atrybut?

# Pytanie zadawane przed usunięciem elementu słownika, którego nic nie używa.
# Oryginał usuwał taki element od razu, bez słowa; 25/07/2026 Fabrice
# poprosił, aby usunięcie zawsze było potwierdzane — przyjęte odstępstwo od
# jego własnego kodu, jedyne w tym module.
nomenclature-delete-plain = Czy potwierdzasz usunięcie „{ $label }”?

# Odmowa pokazywana, gdy element, który użytkownik zamierza usunąć, jest tym
# samym, który pokazuje jego karta. Rozstrzygnięcie Fabrice'a z 25/07/2026:
# elementu nie usuwa się spod jego własnej otwartej karty — najpierw zamyka
# się kartę, zamiast zostawiać ją pokazującą rekord, który już nie istnieje.
nomenclature-delete-form-open = Karta „{ $label }” jest otwarta. Zamknij ją przed usunięciem.

# Odmowa pokazywana, gdy zapisywany opis nosi już inny element tego samego
# słownika (rozstrzygnięcie autora, 25/07/2026: dwa elementy jednego słownika
# nie mogą nosić tej samej nazwy — zaliczenie operacji do jednego z dwóch
# identycznych opisów to rzut monetą). `element` to rzeczownik w swoim
# rodzaju, „kategoria”, „kontrahent”; `label` to istniejący opis, tak jak
# jest zapisany, żeby użytkownik widział, co stoi na przeszkodzie.
nomenclature-duplicate = Istnieje już { $element } o tej samej nazwie: „{ $label }”.

# ---------------------------------------------------------------------
# To, co okna mówią same o sobie.
#
# Wszystko jest tutaj, łącznie z tym, co zależy od wyświetlanego słownika:
# zdania są napisane w całości, język po języku, a nie składane ze słów i
# rodzajów. Składanka poprawna po francusku jest fałszywa w następnym
# języku, a kod w końcu musi wiedzieć, że istnieje rodzaj żeński — a to nie
# jest jego zadanie (reguła autora, 25/07/2026: „program działa z Fluent po
# francusku i po angielsku od samego początku”).
# ---------------------------------------------------------------------

ui-loading = Wczytywanie…
ui-editing = Edycja.
ui-viewing = Przeglądanie.
ui-modified-suffix = — zmodyfikowano
ui-label-required = Opis jest obowiązkowy.
ui-discard-question = Porzucić zmiany?
ui-yes = Tak
ui-no = Nie
ui-select-record = Wybierz rekord
ui-key-multiselect = CTRL
ui-multiselect-help = Info: Użyj kliknięcia myszą + klawisza [{ $modifier }] na tabeli, aby zaznaczyć kilka elementów
ui-no-match = Żaden opis nie pasuje do filtra.
ui-filter-placeholder = Filtruj opisy…
ui-column-label = OPIS
ui-field-label = Opis
ui-field-budget-line = Pozycja budżetowa
ui-identifier = Identyfikator
ui-deletion-abandoned = Usuwanie przerwane: nic nie zostało zmienione.
ui-unknown-nomenclature = Nieznany słownik:

ui-title-filter = Filtruj
ui-title-create = Utwórz
ui-title-update = Edytuj zaznaczenie
ui-title-delete = Usuń zaznaczenie
ui-title-read = Wyświetl zaznaczenie
ui-title-close = Zamknij
ui-title-save = Zapisz
ui-title-add = Dodaj
ui-title-modify = Edytuj

ui-load-failed = Nie można wczytać:
ui-save-failed = Nie można zapisać:
ui-read-failed = Nie można odczytać:
ui-delete-failed = Nie można usunąć:
ui-open-failed = Nie można otworzyć:
ui-close-failed = Nie można zamknąć:

# --- Zdania właściwe dla każdego słownika ----------------------------

nomenclature-identifier = { $kind ->
    [category] Identyfikator kategorii
    [assignment] Identyfikator przeznaczenia
    [payment-mode] Identyfikator sposobu płatności
    [payee] Identyfikator kontrahenta
    [project] Identyfikator projektu
    [budget-line] Identyfikator pozycji budżetowej
   *[bank] Identyfikator banku
}

nomenclature-none = { $kind ->
    [category] Brak kategorii.
    [assignment] Brak przeznaczeń.
    [payment-mode] Brak sposobów płatności.
    [payee] Brak kontrahentów.
    [project] Brak projektów.
    [budget-line] Brak pozycji budżetowych.
   *[bank] Brak banków.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Brak kategorii do wyświetlenia.
    [assignment] Brak przeznaczeń do wyświetlenia.
    [payment-mode] Brak sposobów płatności do wyświetlenia.
    [payee] Brak kontrahentów do wyświetlenia.
    [project] Brak projektów do wyświetlenia.
    [budget-line] Brak pozycji budżetowych do wyświetlenia.
   *[bank] Brak banków do wyświetlenia.
}

nomenclature-gone = { $kind ->
    [category] Ta kategoria już nie istnieje.
    [assignment] To przeznaczenie już nie istnieje.
    [payment-mode] Ten sposób płatności już nie istnieje.
    [payee] Ten kontrahent już nie istnieje.
    [project] Ten projekt już nie istnieje.
    [budget-line] Ta pozycja budżetowa już nie istnieje.
   *[bank] Ten bank już nie istnieje.
}

nomenclature-fresh = { $kind ->
    [category] Nowa kategoria.
    [assignment] Nowe przeznaczenie.
    [payment-mode] Nowy sposób płatności.
    [payee] Nowy kontrahent.
    [project] Nowy projekt.
    [budget-line] Nowa pozycja budżetowa.
   *[bank] Nowy bank.
}

nomenclature-created = { $kind ->
    [category] Dodano kategorię.
    [assignment] Dodano przeznaczenie.
    [payment-mode] Dodano sposób płatności.
    [payee] Dodano kontrahenta.
    [project] Dodano projekt.
    [budget-line] Dodano pozycję budżetową.
   *[bank] Dodano bank.
}

nomenclature-updated = { $kind ->
    [category] Zmodyfikowano kategorię.
    [assignment] Zmodyfikowano przeznaczenie.
    [payment-mode] Zmodyfikowano sposób płatności.
    [payee] Zmodyfikowano kontrahenta.
    [project] Zmodyfikowano projekt.
    [budget-line] Zmodyfikowano pozycję budżetową.
   *[bank] Zmodyfikowano bank.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] Usunięto { $count } kategorię.
        [few] Usunięto { $count } kategorie.
        [many] Usunięto { $count } kategorii.
       *[other] Usunięto { $count } kategorii.
      }
    [assignment] { $count ->
        [one] Usunięto { $count } przeznaczenie.
        [few] Usunięto { $count } przeznaczenia.
        [many] Usunięto { $count } przeznaczeń.
       *[other] Usunięto { $count } przeznaczenia.
      }
    [payment-mode] { $count ->
        [one] Usunięto { $count } sposób płatności.
        [few] Usunięto { $count } sposoby płatności.
        [many] Usunięto { $count } sposobów płatności.
       *[other] Usunięto { $count } sposobu płatności.
      }
    [payee] { $count ->
        [one] Usunięto { $count } kontrahenta.
        [few] Usunięto { $count } kontrahentów.
        [many] Usunięto { $count } kontrahentów.
       *[other] Usunięto { $count } kontrahenta.
      }
    [project] { $count ->
        [one] Usunięto { $count } projekt.
        [few] Usunięto { $count } projekty.
        [many] Usunięto { $count } projektów.
       *[other] Usunięto { $count } projektu.
      }
    [budget-line] { $count ->
        [one] Usunięto { $count } pozycję budżetową.
        [few] Usunięto { $count } pozycje budżetowe.
        [many] Usunięto { $count } pozycji budżetowych.
       *[other] Usunięto { $count } pozycji budżetowej.
      }
   *[bank] { $count ->
        [one] Usunięto { $count } bank.
        [few] Usunięto { $count } banki.
        [many] Usunięto { $count } banków.
       *[other] Usunięto { $count } banku.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Istnieje już kategoria o tej samej nazwie: „{ $label }”.
    [assignment] Istnieje już przeznaczenie o tej samej nazwie: „{ $label }”.
    [payment-mode] Istnieje już sposób płatności o tej samej nazwie: „{ $label }”.
    [payee] Istnieje już kontrahent o tej samej nazwie: „{ $label }”.
    [project] Istnieje już projekt o tej samej nazwie: „{ $label }”.
    [budget-line] Istnieje już pozycja budżetowa o tej samej nazwie: „{ $label }”.
   *[bank] Istnieje już bank o tej samej nazwie: „{ $label }”.
}

# --- Tytuły okien, bez znaków diakrytycznych jak w oknach oryginalnych -

window-list-title = { $kind ->
    [category] Lista kategorii
    [assignment] Lista przeznaczeń
    [payment-mode] Lista sposobów płatności
    [payee] Lista kontrahentów i sprzedawców
    [project] Lista projektów
    [budget-line] Lista pozycji budżetowych
   *[bank] Lista banków
}

window-form-title = { $kind ->
    [category] Karta kategorii
    [assignment] Karta przeznaczenia
    [payment-mode] Karta sposobu płatności
    [payee] Karta kontrahenta
    [project] Karta projektu
    [budget-line] Karta pozycji budżetowej
   *[bank] Karta banku
}

# --- Pasek menu (01_CAHIER_DES_CHARGES.md §6) -------------------------

menu-file = Plik
menu-file-import-statements = Import wyciągów bankowych
menu-file-import-excel = Import pliku Excel
menu-file-backup = Kopia zapasowa
menu-file-restore = Przywracanie
menu-file-repair = Naprawa i optymalizacja bazy danych
menu-file-log = Pokaż dziennik
menu-tools-password = Zabezpiecz bazę danych hasłem
menu-file-disconnect = Odłącz się od bieżącej bazy
menu-file-quit = Zakończ

menu-accounts = Konta
menu-accounts-manage = Zarządzanie kontami bankowymi
menu-accounts-balances = Zobacz salda swoich kont
menu-accounts-operations = Zarządzaj operacjami konta
menu-accounts-quick-classify = Szybka klasyfikacja operacji
menu-accounts-recurring = Zarządzanie operacjami cyklicznymi
menu-accounts-transfer = Przelej kwotę między dwoma kontami
menu-accounts-checkbooks = Zarządzanie książeczkami czekowymi

menu-statistics = Statystyki
menu-statistics-balance-chart = Wykres zmiany salda
menu-statistics-by-category = Stat. wg kategorii
menu-statistics-by-assignment = Stat. wg przeznaczeń
menu-statistics-by-budget-line = Stat. wg pozycji budżetowych
menu-statistics-by-payment-mode = Stat. wg sposobów płatności
menu-statistics-by-payee = Stat. wg kontrahentów i sprzedawców
menu-statistics-by-project = Stat. wg projektów
menu-statistics-dashboard = Pulpit operacji

menu-budget = Budżet
menu-budget-entry = Wprowadzanie budżetu
menu-budget-control = Kontrola budżetu

menu-nomenclatures = Słowniki
menu-nomenclature = { $kind ->
    [category] Kategorie
    [assignment] Przeznaczenia
    [payment-mode] Rodzaje operacji
    [payee] Kontrahenci i sprzedawcy
    [project] Projekty
    [budget-line] Pozycje budżetowe
   *[bank] Banki
}
menu-nomenclatures-templates = Szablony operacji

menu-settings = Ustawienia
menu-settings-about-author = O autorze
menu-settings-about-radinus = O programie Radinus
menu-settings-licence = Licencja

menu-misc = Różne
menu-misc-calculator = Kalkulator
menu-misc-website = Przejdź na stronę Radinus
menu-misc-database-folder = Dostęp do folderu zawierającego bazę danych

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Otwórz folder bazy danych
database-folder-warning =
    Ten folder zawiera wszystkie twoje dane. Zmiana nazwy, przeniesienie lub usunięcie pliku może spowodować utratę kont, ich uszkodzenie lub uniemożliwić działanie Radinusa.
    Czy na pewno chcesz go otworzyć?
menu-misc-application-folder = Dostęp do folderu zawierającego aplikację
menu-misc-attachments-folder = Dostęp do folderu z załącznikami
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Zarządzanie załącznikami
window-attachments-manager-title = Zarządzanie załącznikami
attachments-column-document = Dokument
attachments-column-size = Rozmiar
attachments-column-added = Dodano
attachments-column-state = Stan
attachments-state-intact = Nienaruszony
attachments-state-altered = Zmieniony od tego czasu
attachments-state-missing = Brak pliku
attachments-state-unknown = Nie do sprawdzenia
attachments-state-orphan = Osierocony
attachments-no-operation = Brak operacji
attachments-orphan-remove-question = Ten plik nie jest powiązany z żadną operacją. Przenieść do kosza?
attachments-manager-help = Kliknij dwukrotnie wiersz, aby otworzyć dokument.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Pokaż operację
attachments-reveal = Pokaż w menedżerze plików
attachments-manager-summary = Załączniki: { $count }, łącznie { $size }.
attachments-disk-name = Nazwa na dysku: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Otwórz folder załączników
attachments-folder-warning =
    Ten folder zawiera pliki dołączone przez ciebie do operacji. Radinus przechowuje je pod nazwą, którą sam wybrał: zmiana nazwy, przeniesienie lub usunięcie pliku nie odłącza go od operacji, która nadal będzie go zapowiadać, a on się już nie otworzy.
    Czy na pewno chcesz go otworzyć?

# ---------------------------------------------------------------------
# Konta bankowe — F04, F06, F07, F08.
# Literówki z wersji 1.9.3 („Bank Identifer Code”, „Solde initial
# prevu”, „Est Cloturé”, spacja przed nawiasem przy IBAN) zostały
# poprawione: decyzja Fabrice'a z 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Zarządzanie kontami bankowymi
window-accounts-select-title = Lista kont
window-balances-title = Salda Twoich kont
window-account-title = Karta konta

accounts-none = Brak kont.
accounts-nothing-to-show = Brak kont do wyświetlenia.
accounts-gone = To konto już nie istnieje.
accounts-fresh = Nowe konto.
accounts-created = Konto dodane.
accounts-updated = Konto zmienione.
accounts-deleted = { $count ->
    [one] Usunięto { $count } konto.
    [few] Usunięto { $count } konta.
    [many] Usunięto { $count } kont.
   *[other] Usunięto { $count } konta.
}
accounts-duplicate-name = Konto o tej samej nazwie już istnieje: „{ $label }”.
accounts-multiselect-help = Informacja: użyj kliknięcia myszą + klawisza [{ $modifier }] na tabeli, aby zaznaczyć kilka kont
accounts-select-question = Na których kontach bankowych mają się opierać statystyki?

accounts-column-label = NAZWA
accounts-column-bank = Bank
accounts-column-type = Typ konta
accounts-column-number = Nr konta
accounts-column-account = Konto
accounts-column-bank-balance = W banku
accounts-column-real-balance = Rzeczywiste
accounts-column-final-balance = Końcowe
accounts-total = RAZEM

# Usunięcie konta pociąga za sobą jego operacje: to jedyne miejsce
# w programie, gdzie usunięcie niszczy historię.
accounts-delete-plain = Czy potwierdzasz usunięcie konta „{ $label }”?
accounts-delete-with-operations = Konto „{ $label }” zawiera { $count } operacji, które zostaną usunięte razem z nim. Czy potwierdzasz usunięcie?
accounts-delete-form-open = Karta konta „{ $label }” jest otwarta. Zamknij ją przed usunięciem.

account-group-bank = Informacje o koncie i banku
account-group-holder = Właściciel
account-group-rib = Dane bankowe (RIB)
account-group-activity = Aktywność
account-group-balances = Salda

account-field-label = Nazwa konta
account-field-bank = Bank
account-field-type = Typ konta
account-field-branch-address = Adres oddziału banku
account-field-holder-name = Nazwisko
account-field-holder-address = Adres
account-field-rib-bank = Instytucja
account-field-rib-branch = Kod oddziału
account-field-rib-number = Numer konta
account-field-rib-key = Klucz RIB
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Data otwarcia
account-field-closing-date = Data zamknięcia
account-field-closed = Jest zamknięte
account-field-opening-pointed = Saldo początkowe uzgodnione
account-field-opening-committed = Saldo początkowe zarezerwowane
account-field-opening-planned = Saldo początkowe planowane

account-label-required = Nazwa konta jest obowiązkowa.
account-iban-invalid = Ten IBAN jest nieprawidłowy: sprawdź cyfry kontrolne.
# Niebieski wiersz na dole karty, słowo w słowo ten z 1.9.3 — jedynie
# kwoty mają teraz francuski format pozostałych pól.
account-control-line = Saldo początkowe uzgodnione ({ $opening }) + Suma operacji ({ $operations }) = Aktualne saldo bankowe: { $balance }.

amount-not-readable = „{ $field }” nie zawiera prawidłowej kwoty.

ui-thousands-separator =  
ui-decimal-separator = ,

# --- Lista operacji (F02) --------------------------------------------

window-operations-title = Lista operacji konta: { $account }

operations-none = Brak operacji w tym okresie.
operations-bad-period = Granice okresu nie są prawidłowymi datami.
operations-from = Data początkowa
operations-to = Data końcowa
operations-delete-confirm = { $count ->
    [one] Czy potwierdzasz usunięcie tej operacji?
    [few] Czy potwierdzasz usunięcie tych { $count } wierszy? Podoperacje zaznaczonych operacji znikną razem z nimi.
    [many] Czy potwierdzasz usunięcie tych { $count } wierszy? Podoperacje zaznaczonych operacji znikną razem z nimi.
   *[other] Czy potwierdzasz usunięcie tych { $count } wierszy? Podoperacje zaznaczonych operacji znikną razem z nimi.
}
operations-deleted = { $count ->
    [one] Usunięto { $count } operację.
    [few] Usunięto { $count } operacje.
    [many] Usunięto { $count } operacji.
   *[other] Usunięto { $count } operacji.
}
operations-selection-total = Łączna kwota zaznaczonych operacji: { $amount }

operations-column-date = Data
operations-column-clearing-date = Data uzgodnienia
operations-column-label = Opis
operations-column-category = Kategoria
operations-column-assignment = Przeznaczenie
operations-column-payment-mode = SposPł
operations-column-payee = Kontrahent
operations-column-project = Projekty
operations-column-month = Miesiąc
operations-column-debit = Rozchód
operations-column-credit = Przychód
operations-column-balance = Saldo
operations-column-comments = Komentarze
operations-column-attachments = Załączniki
operations-column-check = Nr czeku

operations-foot-debit = Rozchód:
operations-foot-credit = Przychód:
operations-foot-total = Razem:
operations-foot-bank = Saldo bankowe:
operations-foot-real = Saldo rzeczywiste:
operations-foot-final = Saldo końcowe:

operations-menu-export = Eksport
operations-menu-print = Drukowanie
operations-menu-filter = Filtr
operations-menu-period = Okres
operations-menu-misc = Różne

operations-title-point = Uzgodnij zaznaczenie
operations-title-sub = Dodaj podoperację
operations-title-duplicate = Powiel zaznaczenie
operations-not-yet = Tego okna jeszcze nie ma: pojawi się dalej w planie.

accounts-choose-question = Na którym koncie chcesz pracować?
ui-title-select = Wybierz zaznaczenie

month-january = styczeń
month-february = luty
month-march = marzec
month-april = kwiecień
month-may = maj
month-june = czerwiec
month-july = lipiec
month-august = sierpień
month-september = wrzesień
month-october = październik
month-november = listopad
month-december = grudzień

operations-period-year = Bieżący rok

# --- Menu Okres w F02 ------------------------------------------------
# Dziewięć pozycji, w tym dwie otwierające podmenu dwunastu miesięcy. Każda
# robi tylko jedno: wyznacza datę początkową i datę końcową, które okno
# wpisuje z powrotem w swoje dwa pola (prośba Fabrice'a, 25/07/2026).

period-all = Wszystkie
period-last-year = Ubiegły Rok
period-this-year = Bieżący Rok
period-whole-year = Cały rok
period-last-month = Ubiegły Miesiąc
period-this-month = Bieżący Miesiąc
period-last-week = Ubiegły Tydzień
period-this-week = Bieżący Tydzień
period-yesterday = Wczoraj
period-today = Dzisiaj

# --- Menu Filtr w F02 ------------------------------------------------
# Filtruje wiersze według rodzaju operacji (prośba Fabrice'a,
# 25/07/2026). Trzy statusy są te z bazy: 1 uzgodniony, 2 zarezerwowany,
# 3 planowany (02_BASE_DE_DONNEES.md §5.2).

filter-all = Wszystkie operacje
filter-pointed = Tylko operacje uzgodnione
filter-committed = Tylko operacje zarezerwowane
filter-planned = Tylko operacje planowane

# --- Karta operacji (F03) --------------------------------------------
# Nazwy pól pochodzą ze zrzutu „Fiche operation transaction.png”,
# literówki oryginału poprawione (zgoda Fabrice'a, 25/07/2026:
# „les coquilles tu les corriges”): „Libelle” staje się „Libellé”,
# „Categorie” staje się „Catégorie”, „Statut Operation” staje się
# „Statut opération”.

window-operation-title = Operacja Konto: { $account }

operation-menu-identification = Identyfikacja
operation-menu-options = Opcje
operation-fitid-edit = Edytuj identyfikator FITID…
operation-fitid-delete = Usuń identyfikator FITID
operation-fitid-question = Identyfikator FITID tej transakcji:
operation-fitid-delete-question = Usunąć identyfikator FITID tej transakcji?
operation-fitid-written = Identyfikator FITID zapisany.
operation-fitid-removed = Identyfikator FITID usunięty.

operation-group-identification = Identyfikacja operacji
operation-group-amount = Kwota operacji
operation-group-status = Status operacji
operation-group-classification = Klasyfikacja operacji do obliczania statystyk
operation-group-check = Czek powiązany z operacją
operation-group-comment = Komentarz

operation-field-label = Opis
operation-field-reference = Referencja płatności
operation-field-date = Data
operation-field-direction = Typ operacji:
operation-field-amount = Kwota
operation-field-status = Status operacji
operation-field-clearing-date = Data uzgodnienia
operation-field-category = Kategoria
operation-field-assignment = Przeznaczenie
operation-field-payment-mode = Sposób
operation-field-payee = Kontrahent
operation-field-project = Projekt
operation-field-check = Powiąż z czekiem

operation-direction-debit = Rozchód
operation-direction-credit = Przychód

operation-check-info = Info.
operation-check-link = Powiąż
operation-check-unlink = Usuń

operation-fresh = Nowa operacja.
operation-created = Operacja dodana.
operation-updated = Operacja zmieniona.
operation-gone = Ta operacja już nie istnieje.
operation-nothing-to-show = Brak operacji do wyświetlenia.
operation-label-required = Opis operacji jest obowiązkowy.
operation-date-required = Data operacji jest obowiązkowa.
operation-clearing-date-invalid = Data uzgodnienia nie jest prawidłową datą.
operation-is-a-sub = Ten wiersz jest podoperacją: edytuje się ją z jej własnej karty.
operation-delete-form-open = Karta „{ $label }” jest otwarta. Zamknij ją przed usunięciem.

operation-attachments = { $count ->
    [0] Brak załączników
    [one] { $count } załącznik
    [few] { $count } załączniki
    [many] { $count } załączników
   *[other] { $count } załącznika
}

operation-title-comment = Komentarz operacji
operation-title-sub = Utwórz podoperację
operation-title-template = Szablony operacji
operation-title-attachment = Załączniki

# --- Karta podoperacji (F04) -----------------------------------------
# Uproszczona wersja F03: bez Sposobu, bez Statusu, bez Daty — podoperacja
# bierze je z operacji nadrzędnej (`Maj_ProprieteSousOp`, potwierdzone przez
# Fabrice'a 26/07/2026: „dans une sous-opération, comme est le complément, on
# ne peut pas toucher au mode de paiement, cela serait illogique”).

window-sub-operation-title = Karta Podoperacji

sub-operation-group-amount = Kwota podoperacji
sub-operation-field-label = Nazwa
sub-operation-fresh = Nowa podoperacja.
sub-operation-created = Podoperacja dodana.
sub-operation-updated = Podoperacja zmieniona.
sub-operation-gone = Ta podoperacja już nie istnieje.
sub-operation-nothing-to-show = Brak podoperacji do wyświetlenia.
sub-operation-label-required = Nazwa podoperacji jest obowiązkowa.
sub-operation-parent-gone = Operacja do rozksięgowania już nie istnieje.
# Co karta mówi, gdy pokazuje Dopełnienie. Nie jest ono chronione:
# można je zmienić, ale trzeba wiedzieć, co się bierze (decyzja
# Fabrice'a, 26/07/2026).
sub-operation-is-the-complement = To jest Dopełnienie: to, co pozostaje do rozksięgowania. Zmiana jego nazwy lub kwoty czyni z niego zwykłą podoperację.
sub-operation-of = Rozksięgowanie „{ $label }” ({ $amount })

operations-pointed = { $count ->
    [one] Uzgodniono { $count } operację.
    [few] Uzgodniono { $count } operacje.
    [many] Uzgodniono { $count } operacji.
   *[other] Uzgodniono { $count } operacji.
}
operations-select-one = Wybierz tylko jedną operację.

# --- Duplikowanie i wyświetlanie podoperacji (F02) --------------------
# Duplikowanie otwiera wstępnie wypełnioną kartę, którą użytkownik sam
# zatwierdza (decyzja Fabrice'a, 26/07/2026): nic nie jest zapisywane, dopóki
# nie zapisze, a wcześniej może poprawić datę lub kwotę.

operation-copy = Kopia do zapisania: nic jeszcze nie zostało utworzone.
operations-show-children = Pokaż wszystkie podoperacje
operations-hide-children = Ukryj wszystkie podoperacje

# --- Drugie potwierdzenie poważnego usunięcia -------------------------
# Usunięcie konta bankowego pociąga za sobą całą jego historię: Tak/Nie
# klika się bez czytania, więc prosimy o wpisanie słowa (decyzja Fabrice'a,
# 26/07/2026). Słowo pochodzi ze słownika — tutaj „Tak”, po angielsku „Yes” —
# więc nic nie trzeba tu tłumaczyć dwa razy.

accounts-delete-second-question = To usunięcie jest nieodwracalne i obejmuje całą historię konta. Wpisz „{ $word }”, aby je potwierdzić.

# --- F20-F24 — Sześć statystyk ----------------------------------------
# Wspólny szablon, odmieniony na sześć osi. Ta według kategorii posłużyła za
# wzór i Fabrice zatwierdził ją 26/07/2026, zanim powstało pozostałe pięć —
# nazwy kolumn są te z oryginału.

window-statistics-title = { $kind ->
    [assignment] Statystyki według przeznaczenia
    [budget-line] Statystyki według pozycji budżetowej
    [payment-mode] Statystyki według sposobu płatności
    [payee] Statystyki według kontrahenta i sprzedawcy
    [project] Statystyki według projektu
   *[category] Statystyki według kategorii
}

statistics-axis-column = { $kind ->
    [assignment] Przeznaczenie
    [budget-line] PozycjaBudżetu
    [payment-mode] SposóbOperacji
    [payee] Kontrahent
    [project] Projekty
   *[category] NazwaKategorii
}

statistics-unclassified = { $kind ->
    [assignment] Bez przeznaczenia
    [budget-line] Bez pozycji budżetowej
    [payment-mode] Bez sposobu płatności
    [payee] Bez kontrahenta
    [project] Bez projektu
   *[category] Bez kategorii
}
statistics-total = Razem
statistics-sum = Suma
statistics-cumulative = Narastająco

# Pięć przełączników paska. Etykieta przełącza się ON/OFF, jak w
# oryginale: to sam przełącznik mówi, w jakim jest położeniu.
statistics-switch-pointed = Operacje uzgodnione { $state }
statistics-switch-committed = Operacje zarezerwowane { $state }
statistics-switch-planned = Operacje planowane { $state }
statistics-switch-debits = Kwoty rozchodów { $state }
statistics-switch-credits = Kwoty przychodów { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Nie wybrano żadnego konta: statystyka nie obejmuje niczego.
statistics-no-data = Brak operacji w tym roku dla wybranych kont.
statistics-detail-empty = Kliknij komórkę z liczbą, aby zobaczyć operacje, które ona zlicza.
statistics-detail-none = Za tą komórką nie ma żadnej operacji.
statistics-accounts = { $count ->
    [one] { $count } konto
    [few] { $count } konta
    [many] { $count } kont
   *[other] { $count } konta
}
statistics-year-next = Następny rok
statistics-year-previous = Poprzedni rok

statistics-column-date = Data
statistics-column-clearing-date = DataUzgodnienia
statistics-column-label = Opis
statistics-column-amount = Kwota
statistics-column-comments = Komentarze

accounts-stats-multiselect-help = Info: użyj kliknięcia myszą + klawisza [{ $modifier }] na tabeli, aby wybrać kilka kont

# Rocznik statystyk: klika się na nim i wpisuje rok. Granice są te same, co
# przy „Wszystkie” w menu Okres — rok w Radinusie to liczba całkowita
# między 1950 a 2550 (Fabrice, 26/07/2026).
statistics-year-question = Z którego roku chcesz korzystać? Radinus obejmuje lata od { $first } do { $last }.
statistics-year-choose = Wybierz rok

# --- Eksport tabel (prawy przycisk myszy) -----------------------------
# Funkcja tabeli, a nie okna: mają ją wszystkie listy.

export-to-excel = Eksportuj do Excela (.xlsx)
export-to-word = Eksportuj do Worda (.docx)
export-to-tsv = Eksportuj do TSV (.tsv)
export-to-ini = Eksportuj do INI (.ini)
export-to-toml = Eksportuj do TOML (.toml)
export-to-yaml = Eksportuj do YAML (.yaml)
export-to-ofx = Eksportuj do OFX (.ofx)
export-to-qif = Eksportuj do QIF (.qif)
export-to-ods = Eksportuj do LibreOffice Calc (.ods)
export-to-csv = Eksportuj do CSV (.csv)
export-to-xml = Eksportuj do XML (.xml)
# Menu Eksport w oknie statystyk: jedna zakładka na rok, nazwana
# AN_2026. Puste lata — przy ustawionych przełącznikach — nie występują.
export-menu = Eksport
export-all-years-excel = Eksportuj wszystkie lata do Excela
export-all-years-ods = Eksportuj wszystkie lata do LibreOffice Calc
export-no-year = Żaden rok nie zawiera operacji: nie ma czego eksportować.
export-years-done = Wyeksportowano lat: { $years } do „{ $file }”.
export-to-json = Eksportuj do JSON (.json)
export-done = Wyeksportowano do „{ $file }”.
export-failed = Eksport niemożliwy: { $reason }
export-nothing = Nie ma czego eksportować.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Statystyki według przeznaczenia
    [budget-line] Statystyki według pozycji budżetowej
    [payment-mode] Statystyki według sposobu płatności
    [payee] Statystyki według kontrahenta i sprzedawcy
    [project] Statystyki według projektu
   *[category] Statystyki według kategorii
}
statistics-detail-name = Szczegóły statystyk

# --- F19 — Panel główny ------------------------------------------------
# Jeden okres i trzy przełączniki; dwa wykresy pierścieniowe na każdą
# pozycję budżetową; trzy duże liczby. Kolory wycinków są te same co
# w oryginale, odczytane ze zrzutu ekranu Fabrice'a.

window-dashboard-title = Panel główny
dashboard-menu-period = Okres
dashboard-menu-misc = Różne
dashboard-from = Data początkowa:
dashboard-to = Data końcowa:
dashboard-switch-pointed = Uwzględnij operacje uzgodnione
dashboard-switch-committed = Uwzględnij operacje zarezerwowane
dashboard-switch-planned = Uwzględnij operacje planowane
dashboard-spending = Wydatki
dashboard-earning = Wpływy
dashboard-debits = Suma operacji rozchodowych
dashboard-credits = Suma operacji przychodowych
dashboard-balance = Bilans
dashboard-unclassified = Bez pozycji budżetowej
dashboard-nothing = Brak operacji w tym okresie.
dashboard-no-account = Nie wybrano żadnego konta: panel główny nie ma czego pokazać.
dashboard-enlarge = Otwórz w powiększeniu

# --- F25 — Zmiana salda ------------------------------------------------
# Jeden wykres na każde wybrane konto plus wykres sumy — który pojawia się
# dopiero przy dwóch kontach (reguła Fabrice'a, 26/07/2026). Wykresy są
# schodkowe: saldo zachowuje swoją wartość aż do następnej operacji.

window-curve-title = Zmiana salda
curve-heading = Zmiana salda w ujęciu dziennym
curve-menu-period = Okres
curve-total = Razem
curve-from = Data początkowa:
curve-to = Data końcowa:
curve-axis-balance = saldo
curve-nothing = Nie wybrano żadnego konta: nie ma czego rysować.
curve-empty = Brak operacji w tym okresie.

# --- F05 — Szybka klasyfikacja operacji --------------------------------
# Okno, w którym klasyfikuje się **masowo**: zaznacza się wiersze, zaznacza
# cechy do zmiany i stosuje je za jednym razem — w pamięci. Nic nie zostaje
# zapisane, dopóki się nie zapisze, a zapis zapisuje tylko to, co różni się
# od tego, co zostało wczytane (reguły Fabrice'a, 27/07/2026).

window-quick-classification-title = Szybka klasyfikacja operacji: { $account }
quick-dates-title = Daty początku i końca listy.
quick-from = Data początkowa
quick-to = Data końcowa
quick-menu-period = Okres
quick-change-title = Zmień cechy zaznaczenia na:
quick-check-category = Kategoria
quick-check-assignment = Przeznaczenie
quick-check-payment-mode = Sposób
quick-check-payee = Kontrahent
quick-check-project = Projekt
quick-check-status = Status
quick-column-date = Data
quick-column-label = Opis
quick-column-amount = Kwota
quick-column-category = Kategoria
quick-column-assignment = Przeznaczenie
quick-column-payment-mode = Sposób płatności
quick-column-payee = Kontrahent
quick-column-project = Projekty
quick-column-status = Status
# Na Macu Ctrl + kliknięcie to kliknięcie prawym przyciskiem: klawiszem,
# który dodaje do zaznaczenia, jest tam ⌘, i pomoc musi podawać ten działający.
quick-multiselect-help = Info: Użyj kliknięcia myszą + klawisza [{ $modifier }] w tabeli, aby zaznaczyć kilka elementów
quick-none = Brak operacji w tym okresie.
quick-select-lines = Zaznacz co najmniej jeden wiersz i co najmniej jedną cechę.
quick-applied = { $count ->
    [0] Nic się nie zmieniło: te wiersze miały już taką klasyfikację.
    [one] Sklasyfikowano { $count } wiersz. Nic jeszcze nie zostało zapisane.
    [few] Sklasyfikowano { $count } wiersze. Nic jeszcze nie zostało zapisane.
    [many] Sklasyfikowano { $count } wierszy. Nic jeszcze nie zostało zapisane.
   *[other] Sklasyfikowano { $count } wiersza. Nic jeszcze nie zostało zapisane.
}
quick-pending = { $count ->
    [0] Brak oczekujących zmian.
    [one] { $count } zmieniony wiersz, niezapisany.
    [few] { $count } zmienione wiersze, niezapisane.
    [many] { $count } zmienionych wierszy, niezapisanych.
   *[other] { $count } zmienionego wiersza, niezapisanego.
}
quick-save-question = { $count ->
    [one] Zapisać oczekującą zmianę?
    [few] Zapisać { $count } oczekujące zmiany?
    [many] Zapisać { $count } oczekujących zmian?
   *[other] Zapisać { $count } oczekującej zmiany?
}
quick-saved = { $count ->
    [0] Nie było nic do zapisania.
    [one] Zapisano { $count } wiersz.
    [few] Zapisano { $count } wiersze.
    [many] Zapisano { $count } wierszy.
   *[other] Zapisano { $count } wiersza.
}
quick-nothing-to-save = Brak oczekujących zmian.
quick-leave-question = Część zmian nie została zapisana. Co chcesz zrobić?
quick-leave-save = Zapisz i wyjdź
quick-leave-discard = Porzuć i wyjdź
quick-leave-stay = Zostań
quick-title-apply = Zastosuj do zaznaczonych wierszy ( w pamięci )
quick-title-save = Zapisz na dysku

# --- F17 / F18 — Import wyciągu bankowego ------------------------------
# Wybiera się konto, otwiera plik OFX — który zostaje w pamięci RAM —,
# wiersze znane już bazie wyświetlają się w kolorach pastelowych, a trzecia
# ikona je włącza: masowo, jeśli wybrano kilka, w przeciwnym razie po jednym
# przez kartę uzgadniania (sposób postępowania Fabrice'a, 27/07/2026).

window-statement-import-title = Import wyciągów z kont bankowych: { $account }
window-statement-form-title = Uzgodnij transakcję (Włącza operację do historii twojego konta)
statement-menu-filter = Filtr
statement-filter-all = Wszystkie wiersze
statement-filter-pending = Do włączenia
statement-filter-known = Już włączone
statement-column-id = ID
statement-column-reconciled = Uzgodniony
statement-column-fitid = FITID
statement-column-date = Data
statement-column-label = Opis
statement-column-debit = Rozchód
statement-column-credit = Przychód
statement-account = Konto
statement-file = Plik
statement-difference = Różnica
statement-none = Żaden wyciąg nie jest otwarty: kliknij żółty folder, aby wybrać plik.
statement-empty = Ten wyciąg nie zawiera żadnej operacji.
statement-no-match = Żaden wiersz nie odpowiada filtrowi.
statement-help = Info: Użyj kliknięcia myszą + klawisza [{ $modifier }] w tabeli, aby zaznaczyć kilka wierszy
statement-choose-account = Ten plik zawiera kilka kont. Które chcesz zaimportować?
statement-select-line = Zaznacz co najmniej jeden wiersz wyciągu.
statement-title-open = Otwórz plik wyciągu (.ofx)
statement-title-info = Informacje o otwartym pliku
statement-title-integrate = Włącz zaznaczenie do konta
statement-title-validate = Włącz tę operację do konta
statement-duplicate = Uwaga, duplikat: ta transakcja wydaje się już włączona do bazy (Financial Institution Transaction ID istnieje)
statement-no-fitid = Uwaga: ten plik nie podaje żadnego identyfikatora (FITID) dla tego wiersza. Duplikat nie będzie mógł zostać wykryty.
statement-loaded = { $count ->
    [0] Ten plik nie zawiera żadnej operacji dla tego konta.
    [one] Wczytano { $count } wiersz; już obecnych na twoim koncie: { $known }.
    [few] Wczytano { $count } wiersze; już obecnych na twoim koncie: { $known }.
    [many] Wczytano { $count } wierszy; już obecnych na twoim koncie: { $known }.
   *[other] Wczytano { $count } wiersza; już obecnych na twoim koncie: { $known }.
}
statement-integrated = { $count ->
    [0] Nic nie zostało wprowadzone: te wiersze są już na twoim koncie.
    [one] Włączono { $count } operację.
    [few] Włączono { $count } operacje.
    [many] Włączono { $count } operacji.
   *[other] Włączono { $count } operacji.
}
# **Komunikaty oryginału, słowo w słowo** (polecenie Fabrice'a,
# 28/07/2026: pozostać wiernym pierwotnemu kodowi). Oryginał ostrzega przed
# operacją masową, pyta wiersz po wierszu przy duplikacie i zdaje sprawę na końcu.

statement-mass-question =
    Czy na pewno chcesz włączyć do swojego konta jednocześnie kilka operacji?
    Będziesz musiał później przypisać im kategorie i cechy, aby robić dokładne statystyki
    W przypadku plików Ofx: jeśli zostaną wykryte duplikaty, będziesz musiał wybrać zachowanie programu
    Dla innych typów plików: będziesz musiał uważać na duplikaty
statement-duplicate-question =
    Transakcja: { $date } { $label }: { $amount }
    wydaje się już włączona do historii transakcji twojego konta bankowego.
    Czy na pewno chcesz przeprowadzić uzgadnianie?
statement-already-reconciled = Ta transakcja została już przez ciebie uzgodniona: jest już włączona do historii transakcji twojego konta
statement-integration-report =
    Koniec włączania.
    Liczba włączonych rekordów: { $added }
    Liczba pominiętych rekordów: { $ignored }
statement-integration-abandoned =
    Przerwano włączanie!
    Liczba włączonych rekordów: { $added }
    Liczba pominiętych rekordów: { $ignored }
statement-yes = Tak
statement-no = Nie
statement-cancel = Anuluj
statement-file-info =
    Konto z pliku: { $account }
    Okres: od { $from } do { $to }
    Saldo podane przez bank: { $balance }
    Operacji: { $count }, w tym { $known } już obecnych na twoim koncie.
statement-group-identification = Identyfikacja operacji
statement-group-amount = Kwota operacji
statement-group-classification = Klasyfikacja operacji do obliczania statystyk
statement-group-status = Status operacji
statement-field-date = Data
statement-field-label = Opis
statement-field-type = Typ operacji
statement-field-amount = Kwota
statement-field-mode = Sposób płatności
statement-field-category = Kategoria
statement-field-assignment = Przeznaczenie
statement-field-payee = Kontrahent
statement-field-project = Projekt
statement-field-status = Status
statement-field-clearing = Data uzgodnienia

# --- Okno podziału wyciągu CSV -----------------------------------------
# Plik CSV nie niesie żadnych wiarygodnych nazw pól: ustawia się, testuje,
# ogląda, zaczyna od nowa. Podgląd pokazuje wszystko, łącznie z bełkotem —
# właśnie po tym widać, że się pomyliliśmy — ale do okna włączania
# przechodzą tylko poprawne wiersze (reguła Fabrice'a, 27/07/2026).

window-csv-statement-title = Import danych z pliku csv
csv-preview-title = Podgląd pliku:
csv-settings-title = Parametry podziału pliku na potrzeby wyodrębnienia danych:
csv-extraction-title = Wizualizacja wyodrębnienia danych według parametrów podziału  ( sprawdź spójność danych ):
csv-column-line = Nr wiersza
csv-column-content = Zawartość
csv-header-lines = Liczba wierszy nagłówka pliku do pominięcia
csv-separator = Dane (kolumny) są oddzielone znakiem:
csv-date-at = Pozycja pola daty
csv-label-at = Pozycja pola opisu
csv-debit-at = Pozycja pola kwoty rozchodu
csv-credit-at = Pozycja pola kwoty przychodu
csv-test = Przetestuj parametry
csv-separator-semicolon = Średnik   ;
csv-separator-comma = Przecinek   ,
csv-separator-tab = Tabulator
csv-separator-pipe = Kreska pionowa   |
csv-separator-space = Spacja
csv-help = Ustaw, przetestuj, sprawdź: zaimportowane zostaną tylko wiersze z czytelną datą i czytelną kwotą.
csv-none = Plik jest pusty.
csv-not-tested = Kliknij „Przetestuj parametry”, aby zobaczyć wynik podziału.
csv-extraction = { $count ->
    [0] Podział nie daje żadnego wiersza: sprawdź liczbę wierszy nagłówka i separator.
    [one] Podzielono { $count } wiersz; do importu: { $valid }, odrzucone: { $dropped } — brak czytelnej daty lub kwoty.
    [few] Podzielono { $count } wiersze; do importu: { $valid }, odrzucone: { $dropped } — brak czytelnej daty lub kwoty.
    [many] Podzielono { $count } wierszy; do importu: { $valid }, odrzucone: { $dropped } — brak czytelnej daty lub kwoty.
   *[other] Podzielono { $count } wiersza; do importu: { $valid }, odrzucone: { $dropped } — brak czytelnej daty lub kwoty.
}
csv-nothing-valid = Żaden wiersz nie ma jednocześnie czytelnej daty i czytelnej kwoty: nie ma czego importować. Sprawdź liczbę wierszy nagłówka, separator i pozycje pól.
csv-title-validate = Przenieś poprawne wiersze do importu

# --- F13 / F31 / F14 / F12 — Książeczki czekowe i czeki (etap 9) --------
# Przeniesienie jego pięciu kodów WinDev i siedmiu zrzutów ekranu, dostarczonych
# 28/07/2026. Jego dokładne zdania tam, gdzie je ma; moje w pozostałych miejscach.
#
# Trzy decyzje o wierności, które podjął tego dnia i które słychać w słowach:
# powtórzone oznaczenie nie jest zgłaszane (jego `Existe_Reference` nigdy nie
# jest wywoływana), liczba czeków nie jest porównywana z granicami, a licznik
# operacji liczy podoperacje, których listy nie pokazują.

window-chequebooks-title = Lista książeczek czekowych
window-chequebook-title = Parametry książeczki czekowej
window-cheques-title = Skład książeczki czekowej: lista czeków.
window-cheque-title = Karta czeków
window-cheque-operations-title = Lista operacji.

# Lista książeczek czekowych (F13) — wszystkie książeczki ze wszystkich kont
# naraz: jego dwie kolumny z kontem nie przydałyby się do niczego przy jednym.
chequebooks-column-reference = OPIS
chequebooks-column-date = Data
chequebooks-column-account = NazwaKonta
chequebooks-column-account-number = Nr konta
chequebooks-column-comments = Komentarze
chequebooks-none = Nie zarejestrowano żadnej książeczki czekowej.
chequebooks-nothing-to-show = Żadna książeczka czekowa nie odpowiada temu wyszukiwaniu.
chequebooks-title-composition = Zobacz skład książeczki czekowej
chequebooks-delete-question = Wykryto operacje (transakcje bankowe) powiązane z książeczką czekową. Czy potwierdzasz, że chcesz usunąć tę książeczkę czekową?
chequebooks-deleted = { $count ->
    [one] Usunięto { $count } książeczkę czekową.
    [few] Usunięto { $count } książeczki czekowe.
    [many] Usunięto { $count } książeczek czekowych.
   *[other] Usunięto { $count } książeczki czekowej.
}
chequebooks-gone = Ta książeczka czekowa już nie istnieje.
chequebooks-created = Książeczka czekowa zapisana wraz ze wszystkimi czekami.
chequebooks-updated = Książeczka czekowa zmieniona.
# Milczenie jego `HAjoute`: okno nie mówi, że oznaczenie jest już zajęte. Mówi
# tylko, że nic nie zostało zapisane — inaczej można by sądzić, że książeczka
# została utworzona.
# Osiem środków ostrożności z jego „Precauttion enregistrement cheque.txt”,
# słowo w słowo i w jego kolejności. Siedem pierwszych to `Erreur()`, ósmy to
# `Info()` — a kolejność decyduje o tym, co widać, gdy dwie rzeczy idą źle naraz.
chequebook-refusal-duplicate = Oznaczenie o tej samej nazwie już istnieje
chequebook-refusal-reference-required = Wprowadzenie oznaczenia jest obowiązkowe
chequebook-refusal-number-too-big = Numer pierwszego i/lub ostatniego czeku jest za duży (wartość maksymalna 999 999 999)
chequebook-refusal-date = Wprowadź prawidłową datę otrzymania
chequebook-refusal-numbers-required = Wypełnij numery pierwszego i ostatniego czeku
chequebook-refusal-order = Numer pierwszego czeku musi być mniejszy od numeru ostatniego czeku
chequebook-refusal-account = Obowiązkowo wybierz konto powiązane z tą książeczką czekową
chequebook-refusal-too-many = Maksymalna liczba czeków w książeczce czekowej: 1000, limit osiągnięty
# Jego pytanie o potwierdzenie, zadawane tylko przy dodawaniu: podsumowuje to,
# co zostanie utworzone, i uprzedza, że nic z tego nie da się później zmienić.
chequebook-creation-question =
    Utworzenie książeczki czekowej o następujących cechach:
    - Liczba czeków do wygenerowania:{ $count }
    - Czeki o numerach od { $first } do { $last }
    Uwaga, tych danych nie będzie można zmienić po utworzeniu!

# Karta książeczki czekowej (F31). Pierwsze pięć pól jest wyszarzone, gdy tylko
# książeczka istnieje: jej czeki są już utworzone.
chequebook-field-id = Identyfikator książeczki czekowej
chequebook-field-reference = Oznaczenie
chequebook-field-received = Wytworzona lub otrzymana dnia
chequebook-field-first = Numer pierwszego czeku
chequebook-field-last = Numer ostatniego czeku
chequebook-field-quantity = Liczba czeków
chequebook-field-account = Powiąż z kontem bankowym:
chequebook-field-comments = Komentarze
chequebook-locked = Czeki tej książeczki są już utworzone: jej numeracji nie można już zmienić.
# Jego zdanie, słowo w słowo (`Enreg_Lire`).
chequebook-account-missing = Konto bankowe, z którym powiązano tę książeczkę czekową, nie istnieje lub zostało usunięte!

# Skład książeczki czekowej (F14). Status zmienia się w komórce.
cheques-column-number = Nr czeku
cheques-column-date = Data
cheques-column-place = Miejsce
cheques-column-payee = Odbiorca
cheques-column-amount = Kwota
cheques-column-status = Status
cheques-column-comments = Komentarze
cheques-column-operations = Liczba powiąz. operacji
cheques-none = Ta książeczka czekowa nie zawiera żadnego czeku.
cheques-nothing-to-show = Żaden czek nie odpowiada temu wyszukiwaniu.
cheques-help = Kliknij w komórkę Status, aby go zmienić; lupa pokazuje powiązane operacje, ogniwo wiąże jedną.
cheques-title-linked = Zobacz operacje już powiązane z tym czekiem
cheques-title-link = Powiąż operację z tym czekiem
cheques-status-changed = Status czeku zmieniony.

# Karta czeku (F12).
cheque-field-id = Identyfikator czeku
cheque-field-number = Numer czeku
cheque-field-issued = Data wystawienia
cheque-field-place = Miejsce wystawienia
cheque-field-payee = Odbiorca
cheque-field-amount = Kwota
cheque-field-comments = Komentarze
cheque-field-status = Status czeku
cheque-gone = Ten czek już nie istnieje.
cheque-updated = Czek zmieniony.

# Dwa oblicza okna powiązania.
cheque-operations-linked-title = Lista operacji już powiązanych z tym czekiem.
cheque-operations-choose-title = Wybierz operację do powiązania z czekiem
cheque-operations-column-account = Konto
cheque-operations-column-label = Nazwa
cheque-operations-column-date = Data
cheque-operations-column-clearing = Data uzgodnienia
cheque-operations-column-amount = Kwota
cheque-operations-column-cheque = Powiązany czek
cheque-operations-none-linked = Żadna operacja nie jest powiązana z tym czekiem.
cheque-operations-none = To konto nie zawiera żadnej operacji.
cheque-operations-nothing-to-show = Żadna operacja nie odpowiada temu wyszukiwaniu.
cheque-operations-help = Operacje pogrubione mają już czek.
cheque-operations-linked-help = Czerwony krzyżyk odłącza czek od operacji: nic nie jest usuwane.
cheque-operations-linked = Operacja powiązana z czekiem.
cheque-operations-dissociated = Czek odłączony od operacji.
cheque-operations-menu-filter = Filtr
cheque-title-associate = Powiąż tę operację z czekiem
cheque-title-dissociate = Odłącz czek od tej operacji

# Pasek „Czek powiązany z operacją” na karcie operacji oraz dwa etapy łowienia
# czeku — najpierw książeczka, potem czek.
chequebooks-select-question = Wybierz książeczkę czekową
cheques-select-question = Wybierz czek do powiązania z operacją
operation-check-save-first = Najpierw zapisz operację: czek wiąże się z operacją, która istnieje.
operation-check-none = Ta operacja nie ma żadnego czeku.

# --- F36 / F37 — Szablony operacji (etap 10) ----------------------------
# Szablon to gotowy wpis: stosuje się go, żeby nie wpisywać wszystkiego od nowa,
# i **nadpisuje** on to, co jest w karcie. Nic nie trafia na dysk, dopóki karta
# operacji nie zostanie zatwierdzona (reguła Fabrice'a, 29/07/2026).

window-operation-templates-title = Lista szablonów operacji
window-operation-template-title = Karta szablonu operacji

operation-templates-none = Nie zarejestrowano żadnego szablonu operacji.
operation-templates-nothing-to-show = Żaden szablon nie odpowiada temu wyszukiwaniu.
operation-templates-select-question = Wybierz szablon do zastosowania
operation-templates-delete-question = Czy potwierdzasz usunięcie zaznaczonych szablonów?
operation-templates-deleted = { $count ->
    [one] Usunięto { $count } szablon.
    [few] Usunięto { $count } szablony.
    [many] Usunięto { $count } szablonów.
   *[other] Usunięto { $count } szablonu.
}
operation-template-gone = Ten szablon już nie istnieje.
operation-template-fresh = Nowy szablon.
operation-template-created = Szablon zapisany.
operation-template-updated = Szablon zmieniony.
operation-template-label-required = Wprowadzenie nazwy jest obowiązkowe
operation-template-duplicate = Szablon o tej samej nazwie już istnieje

# Karta F36, sekcja po sekcji — jego dokładne nagłówki.
operation-template-field-id = ID szablonu operacji
operation-template-group-name = Domyślna nazwa przyszłej operacji po zastosowaniu szablonu
operation-template-field-label = Nazwa
operation-template-group-amount = Domyślna kwota operacji zdefiniowana w tym szablonie
operation-template-field-direction = Typ operacji
operation-template-field-amount = Kwota
operation-template-group-status = Domyślny status operacji w tym szablonie
operation-template-field-status = Status operacji
operation-template-group-classification = Informacje szablonu do klasyfikacji i obliczania statystyk
operation-template-field-category = Kategoria
operation-template-field-assignment = Przeznaczenie
operation-template-field-mode = Sposób
operation-template-field-payee = Kontrahent
operation-template-field-project = Projekt

# Przycisk „Szablon” na karcie operacji: jedna ikona, dwa gesty.
operation-template-question = Co chcesz zrobić z szablonami operacji?
operation-template-apply = Zastosuj szablon
operation-template-save-as = Zapisz jako szablon
operation-template-applied = Szablon zastosowany. Zatwierdź kartę, aby go zapisać.
operation-template-saved-as = Operacja zapisana jako szablon.
operation-template-needs-label = Nadaj operacji nazwę, zanim zrobisz z niej szablon.

# --- F26 / F27 — Budżet (etap 11) ---------------------------------------
# Dwoje drzwi, dwa pytania: albo wprowadza się swój budżet, albo sprawdza, czy
# został dotrzymany. Osią jest pozycja budżetowa, jednostką rok, a konwencja
# znaku jest ta sama co przy operacjach — wydatek zapisuje się jako ujemny.

window-budget-entry-title = Wprowadzanie budżetu: planowane wydatki(-) i przychody(+) w roku
window-budget-control-title = Kontrola budżetu

budget-column-line = Pozycja budżetowa
budget-none = Nie zarejestrowano żadnej pozycji budżetowej: budżet wprowadza się pozycjami.
budget-planned = Plan
budget-actual = Wykonanie
budget-sum = Suma
budget-cumulative = Narastająco
budget-total = Razem
# Przypomnienie o konwencji znaku, na czerwono pod tabelą wprowadzania.
# Jego zdanie, słowo w słowo i wraz ze spacjami (zrzut „POINT 004 saisie
# budget.png”): jest wyświetlone na czerwono pod tabelą, a tytuł okna powtarza
# je w skrócie. Nikt nie odgadłby tej konwencji bez niego.
budget-sign-warning = Obowiązkowo wprowadzaj wydatki  ze znakiem ujemnym, a planowane przychody z kwotami dodatnimi
budget-entry-help = Wpisz kwoty w komórkach, a następnie zapisz.
budget-saved = Budżet zapisany.
budget-nothing-changed = Brak zmian do zapisania.
budget-discard-question = Porzucić zmiany w budżecie?

# Menu Widok w kontroli: dwa sposoby odczytania tej samej różnicy.
budget-menu-display = Widok
budget-display-money = Wartości
budget-display-percent = Procenty
budget-control-help = Zielony: co najmniej tak dobrze, jak planowano. Czerwony: gorzej.

# --- F09 — Przeksięgowanie kwoty między dwoma kontami (etap 12) ----------
# Przelew to nie jedna operacja, to dwie: rozchód na koncie źródłowym i przychód
# na koncie docelowym. Wychodzą razem albo wcale.

window-transfer-title = Przenieś kwotę między dwoma kontami

transfer-group-source = Obciąż kwotą to konto źródłowe
transfer-group-target = Uznaj kwotą to konto docelowe
transfer-group-description = Opis operacji
transfer-group-nomenclature = Informacje słownika
transfer-group-amount = Kwota do przelania
transfer-field-source = Konto źródłowe
transfer-field-target = Konto docelowe
transfer-field-label = Opis
transfer-field-reference = Referencja płatności
transfer-field-date = Data
transfer-field-status = Status operacji
transfer-field-clearing = Data uzgodnienia
transfer-field-category = Kategoria
transfer-field-mode = Sposób płatności
transfer-field-assignment = Przeznaczenie
transfer-field-payee = Kontrahent / sprzedawca
transfer-field-project = Projekt
transfer-field-amount = Kwota

# Jedyny przycisk paneli, które oznajmiają, zamiast pytać.
ui-ok = OK
transfer-help = Wybierz oba konta: ich salda wyświetlą się tutaj.
transfer-title-validate = Wykonaj przelew
# Trzy salda wybranego konta, aby wiedzieć, co pociąga za sobą przelew.
transfer-balances = { $account } — W banku: { $bank } · Rzeczywiste: { $real } · Końcowe: { $final }
# Panel, który podsumowuje to, co właśnie zostało zapisane.
transfer-done = Przelew wykonany. { $amount } z konta { $source } na konto { $target }, dnia { $date }.

transfer-refusal-accounts-required = Wybierz konto źródłowe i konto docelowe
transfer-refusal-same-account = Konto źródłowe i konto docelowe nie mogą być tym samym kontem: przelew idzie z jednego konta na drugie
transfer-refusal-account-gone = Jedno z dwóch kont już nie istnieje
transfer-refusal-label-required = Opis jest obowiązkowy
transfer-refusal-date-required = Data jest obowiązkowa
transfer-refusal-amount = Kwota do przelania musi być ściśle dodatnia

# ---------------------------------------------------------------------------
# Faza 13 — importowanie arkusza Excel (F34, F35, powiązanie).
# ---------------------------------------------------------------------------

window-excel-import-title = Importowanie arkusza excel [ Krok 1/3 ]: określenie obszaru przechwytywania
window-excel-fields-title = Importowanie arkusza excel [ Krok 2/3 ]: powiązanie pól
window-excel-association-title = Importowanie arkusza excel: powiązanie danych

# Pytanie zadawane przy otwarciu. Plik Excel jest robiony ręcznie:
# zawiera to, co zawiera, a część bzdur, które niesie, jest niewykrywalna.
# Proponujemy więc siatkę, zanim się skoczy.
excel-backup-question = Arkusz Excel jest robiony ręcznie: może zawierać daty poprawne w formie, lecz błędne, kwoty o dobrym formacie i złym znaku — a tego żadna kontrola nie zobaczy. Import zapisze te wiersze na twoim koncie. Czy chcesz zrobić kopię zapasową swoich danych przed rozpoczęciem?

excel-group-file = 1 - Wskaż plik Excel do zaimportowania
excel-pick = Wskaż plik Excel
excel-sheet = Arkusz skoroszytu:
excel-group-header = 2 - Określ: współrzędne komórek wiersza nagłówka tabeli, gdzie zapisane są nazwy kolumn.
excel-header-row = Numer pierwszego wiersza, w którym znajdują się nazwy kolumn
excel-first-column = Kolumna początku nagłówka ( kolumna najbardziej z lewej ):
excel-column-count = Liczba kolumn tabeli
excel-group-rows = 3 - Określ: numery pierwszego i ostatniego wiersza listy zawierającej dane tabeli ( pod nagłówkiem i bez niego )
excel-first-data-row = Pierwszy wiersz zawierający dane
excel-last-data-row = Ostatni wiersz zawierający dane:
excel-group-shape = 4 - Określ: jak twój plik zapisuje kwoty
excel-shape-single = Jedna kolumna kwot ze znakiem ( wydatki na minusie )
excel-shape-debit-credit = Dwie oddzielne kolumny: kolumna Rozchód i kolumna Przychód
excel-shape-note = W trybie dwukolumnowym znak zapisany w kolumnie Rozchód nie jest brany pod uwagę: rozchód zawsze zabiera pieniądze, czy zapisano go jako „-50”, czy jako „50”.
excel-group-test = 5 - Wynik testowy: obejrzyj przechwycenie wykonane zgodnie z twoimi ustawieniami
excel-test = Sprawdź parametry, które określiłeś w krokach 2, 3 i 4.
excel-test-note = Wskazówka: nazwy nagłówków i zawartość poniższej tabeli muszą odpowiadać twojej tabeli Excel. Obszar przechwytywania nie może wychodzić poza obszar tabeli.

excel-help = Przejdź kolejno przez pięć grup, a potem przetestuj: do kroku 2 będziesz mógł przejść dopiero po obejrzeniu tego, co obszar przechwytuje.
excel-no-file = Wskaż najpierw plik Excel do zaimportowania.
excel-not-tested = Ustawienia zmienione: uruchom ponownie wynik testowy przed zatwierdzeniem.
excel-tested = Przechwycony obszar: { $rows } wierszy, { $columns } kolumn. Sprawdź, czy poniższa tabela przypomina twój arkusz.
excel-empty-capture = Obszar, który zadeklarowałeś, nie przechwytuje żadnego wiersza: sprawdź numery wierszy i kolumn.
excel-title-next = Przejdź do następnego kroku
excel-into-account = Import na konto { $account }.

excel-tab-links = Powiązania między polami
excel-tab-settings = Parametry importu
excel-column-excel = Nagłówek_Excel
excel-column-radinus = Rubryka_Radinus
excel-links-help = Naprzeciw każdej kolumny twojego arkusza wskaż, którą rubrykę Radinus ona zasila. Kolumny pozostawione na [IGNORE] nie są importowane.
excel-group-category = Kategorie bez odpowiedników
excel-group-payment-mode = Sposób płatności bez odpowiedników
excel-group-assignment = Przeznaczenie bez odpowiedników
excel-policy-create = { $kind ->
    [payment-mode] Automatycznie twórz nieistniejące sposoby płatności
    [assignment] Automatycznie twórz nieistniejące przeznaczenia
   *[category] Automatycznie twórz nieistniejące kategorie
}
excel-policy-ask = { $kind ->
    [payment-mode] Pytaj przy każdym nieistniejącym sposobie płatności, dokąd przenieść dane
    [assignment] Pytaj przy każdym nieistniejącym przeznaczeniu, dokąd przenieść dane
   *[category] Pytaj przy każdej nieistniejącej kategorii, dokąd przenieść dane
}
excel-policy-blank = { $kind ->
    [payment-mode] Pozostaw sposób płatności pusty
    [assignment] Pozostaw przeznaczenie puste
   *[category] Pozostaw kategorię pustą
}
excel-policy-default = { $kind ->
    [payment-mode] Przenieś nieistniejące sposoby płatności do domyślnego sposobu płatności
    [assignment] Przenieś nieistniejące przeznaczenia do domyślnego przeznaczenia
   *[category] Przenieś nieistniejące kategorie do domyślnej kategorii
}
excel-define-destination = Określ cel
excel-not-linked = { $kind ->
    [payment-mode] Żadna kolumna nie zasila sposobu płatności: to ustawienie nie ma zastosowania.
    [assignment] Żadna kolumna nie zasila przeznaczenia: to ustawienie nie ma zastosowania.
   *[category] Żadna kolumna nie zasila kategorii: to ustawienie nie ma zastosowania.
}
excel-fields-help = Ustaw zgodności, a potem trzy zasady, zanim uruchomisz import.
excel-title-import = Uruchom import

excel-refusal-required = Rubryki Data, Opis i Kwota muszą obowiązkowo wskazywać na kolumny excel
excel-refusal-column-twice = Różne rubryki Radinus wskazują na tę samą kolumnę excel: kolumna może zasilać tylko jedną rubrykę
excel-refusal-field-twice = Ta sama rubryka Radinus jest powiązana z dwiema kolumnami excel: może mieć tylko jedną
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Wybrałeś pytanie o to, dokąd przenieść nieznane sposoby płatności: naciśnij „Określ cel” przed uruchomieniem importu.
    [assignment] Wybrałeś pytanie o to, dokąd przenieść nieznane przeznaczenia: naciśnij „Określ cel” przed uruchomieniem importu.
   *[category] Wybrałeś pytanie o to, dokąd przenieść nieznane kategorie: naciśnij „Określ cel” przed uruchomieniem importu.
}

excel-column-data = Dane_Excel
excel-column-destination = { $kind ->
    [payment-mode] SposóbPłatności_Radinus
    [assignment] Przeznaczenie_Radinus
   *[category] Kategoria_Radinus
}
excel-association-help = Naprzeciw każdej wartości pochodzącej z twojego arkusza wybierz tę z Radinus, do której ma zostać przypisana. Wiersz pozostawiony pusty zostanie bez klasyfikacji.
excel-association-none = Brak nieznanych wartości: wszystko, co niesie twój arkusz, już istnieje w Radinus.

excel-imported = Import zakończony: zapisano { $count } operacji, odrzucono { $refused } wierszy, utworzono { $created } wartości słownika.
excel-report-title = Sprawozdanie z importu
excel-column-row = Wiersz Excel
excel-column-content = Zawartość
excel-column-reason = Powód odrzucenia
excel-nothing-refused = Wszystkie wiersze twojego arkusza zostały wprowadzone: brak odrzuceń.

excel-refused-date = Data brakująca lub nieczytelna
excel-refused-amount = Kwota brakująca lub nieczytelna
excel-refused-amount-both = Jedna kwota w kolumnie Rozchód i druga w kolumnie Przychód: nie da się wybrać
excel-refused-amount-missing = Ani rozchodu, ani przychodu w tym wierszu

# ---------------------------------------------------------------------------
# Faza 16 — operacje cykliczne (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Lista operacji cyklicznych
window-recurring-form-title = Karta definiująca regułę generowania operacji cyklicznej
window-recurring-calendar-title = Propozycja kalendarza operacji do wstawienia na twoje konta bankowe

recurring-column-label = OPIS
recurring-none = Nie zapisano żadnej reguły cyklicznej.
recurring-help = Wybierz regułę, a potem kalendarz, aby zobaczyć terminy, które proponuje.
recurring-title-calendar = Zaproponuj kalendarz terminów
recurring-deleted = { $count ->
    [0] Nie usunięto żadnej reguły.
    [one] Usunięto { $count } regułę. Jej operacje pozostają na koncie.
    [few] Usunięto { $count } reguły. Ich operacje pozostają na kontach.
    [many] Usunięto { $count } reguł. Ich operacje pozostają na kontach.
   *[other] Usunięto { $count } reguły. Ich operacje pozostają na kontach.
}
recurring-gone = Ta reguła już nie istnieje.
recurring-delete-question = Usunąć wybrane reguły? Operacje, które już wstawiły, pozostaną na twoich kontach.

recurring-group-identity = Identyfikacja i konto bankowe, którego dotyczy
recurring-group-nomenclature = Słownik
recurring-group-amount = Określenie kwoty operacji
recurring-group-period = Określenie okresu
recurring-group-ending = Warunki zakończenia okresu
recurring-group-produced = Informacje o już wstawionych operacjach ( tylko do wglądu )

recurring-field-id = Identyfikator operacji
recurring-field-account = Konto docelowe
recurring-field-label = Opis
recurring-field-category = Kategoria
recurring-field-mode = Sposób płatności
recurring-field-assignment = Przeznaczenie
recurring-field-payee = Kontrahent / sprzedawca
recurring-field-project = Projekt
recurring-field-direction = Typ operacji
recurring-field-amount = Kwota
recurring-field-next = Data następnej operacji
recurring-field-every = Następnie co
recurring-field-end-date = Data zakończenia
recurring-field-repeat = Liczba powtórzeń
recurring-field-guid = GUID operacji
recurring-field-produced-count = Liczba wstawionych operacji
recurring-field-produced-last = Data ostatniej wstawionej operacji
recurring-field-produced-total = Suma wygenerowanych kwot

recurring-unit-day = Dzień
recurring-unit-week = Tydzień
recurring-unit-month = Miesiąc
recurring-unit-quarter = Kwartał
recurring-unit-year = Rok
recurring-ending-no-limit = Bez ograniczenia
recurring-ending-until-date = Z datą zakończenia
recurring-ending-repeat-count = Liczba powtórzeń

recurring-title-erase = Usuń operacje już wstawione przez tę regułę
recurring-erase-question = { $count ->
    [one] Ta reguła wstawiła { $count } operację na twoje konta. Czy chcesz ją usunąć? Salda zostaną przeliczone, a reguła się nie cofnie.
    [few] Ta reguła wstawiła { $count } operacje na twoje konta. Czy chcesz je wszystkie usunąć? Salda zostaną przeliczone, a reguła się nie cofnie.
    [many] Ta reguła wstawiła { $count } operacji na twoje konta. Czy chcesz je wszystkie usunąć? Salda zostaną przeliczone, a reguła się nie cofnie.
   *[other] Ta reguła wstawiła { $count } operacji na twoje konta. Czy chcesz je wszystkie usunąć? Salda zostaną przeliczone, a reguła się nie cofnie.
}
recurring-erase-none = Ta reguła nie wstawiła jeszcze żadnej operacji.
recurring-erased = { $count ->
    [0] Nie usunięto żadnej operacji.
    [one] Usunięto { $count } operację, salda przeliczone.
    [few] Usunięto { $count } operacje, salda przeliczone.
    [many] Usunięto { $count } operacji, salda przeliczone.
   *[other] Usunięto { $count } operacji, salda przeliczone.
}

recurring-calendar-help = Usuń koszem terminy, których nie chcesz, a potem zatwierdź, aby je wstawić.
recurring-calendar-none = Brak terminów do zaproponowania: sprawdź datę następnej operacji i konto swoich reguł.
recurring-calendar-column-account = Konto
recurring-calendar-column-date = Data
recurring-calendar-column-label = Opis
recurring-calendar-column-amount = Kwota
recurring-calendar-column-category = Kategoria
recurring-calendar-column-assignment = Przeznaczenie
recurring-calendar-column-mode = Sposób płatności
recurring-calendar-column-payee = Kontrahent
recurring-calendar-column-project = Projekty
recurring-calendar-removed = { $count ->
    [one] Usunięto { $count } termin z propozycji.
    [few] Usunięto { $count } terminy z propozycji.
    [many] Usunięto { $count } terminów z propozycji.
   *[other] Usunięto { $count } terminu z propozycji.
}
recurring-title-insert = Wstaw wybrane terminy na konta
recurring-nothing = Nie został już żaden termin do wstawienia.
# Pytanie zadawane przed zapisem: wstawienie kalendarza tworzy prawdziwe
# operacje na prawdziwych kontach, a tego nie robi się jednym roztargnionym kliknięciem.
recurring-insert-question = { $count ->
    [one] Wstawić { $count } termin na twoje konto? Zostanie utworzona jedna operacja, a salda przeliczone.
    [few] Wstawić te { $count } terminy na twoje konta? Zostanie utworzonych tyle samo operacji, a salda przeliczone.
    [many] Wstawić { $count } terminów na twoje konta? Zostanie utworzonych tyle samo operacji, a salda przeliczone.
   *[other] Wstawić { $count } terminu na twoje konta? Zostanie utworzonych tyle samo operacji, a salda przeliczone.
}
recurring-inserted = { $count ->
    [one] Wstawiono { $count } operację. Reguła rusza dalej po ostatnim wstawionym terminie.
    [few] Wstawiono { $count } operacje. Reguły ruszają dalej po swoim ostatnim wstawionym terminie.
    [many] Wstawiono { $count } operacji. Reguły ruszają dalej po swoim ostatnim wstawionym terminie.
   *[other] Wstawiono { $count } operacji. Reguły ruszają dalej po swoim ostatnim wstawionym terminie.
}

recurring-refusal-label-required = Wpisanie opisu jest obowiązkowe
recurring-refusal-date-required = Wpisanie daty następnej operacji jest obowiązkowe
recurring-refusal-date-too-old = Data następnej operacji musi być większa lub równa rokowi 2000
recurring-refusal-account-gone = Wskazane konto bankowe jest nie do odnalezienia, wybierz nowe, aby reguła stała się wykonalna
recurring-refusal-end-required = W przypadku daty zakończenia data musi zostać wpisana
recurring-refusal-end-before-start = Data zakończenia nie może być wcześniejsza niż data następnej operacji
recurring-refusal-end-too-far = Odstęp między datą następnej operacji a datą zakończenia nie może przekraczać 10 000 dni

# --- Faza 15 — wydruki i zestawienia -----------------------------------
# Wielki tytuł belki, przepisany słowo w słowo z pierwotnego zestawienia WinDev.
print-operations-title = Lista transakcji bankowych i podoperacji
print-menu-operations-pdf = Wydruk do pliku PDF
print-recap-title = Podsumowanie według kategorii
print-recap-count = Wiersze
print-row-count = Liczba wierszy:
print-total-debit = Razem rozchód:
print-total-credit = Razem przychód:
print-final-balance = Saldo końcowe:
print-licence = Radinus to wolne oprogramowanie rozpowszechniane na licencji GNU GPL v3 lub nowszej
print-nothing = Nie ma nic do wydrukowania.
print-done = Zestawienie wydrukowane i otwarte: „{ $file }”.
print-failed = Drukowanie niemożliwe: { $reason }
# Plik PDF został poprawnie zapisany, ale system nie potrafił go otworzyć: mówimy
# to tak, aby nie sugerować niepowodzenia, skoro plik jest na miejscu.
print-not-opened = Zestawienie wydrukowane do „{ $file }”, ale twój system nie potrafił go sam otworzyć.

# --- Zestawienie RIB (F32) ---------------------------------------------
# Nagłówki bankowych danych identyfikacyjnych, przejęte z pierwotnego dokumentu.
rib-title = BANKOWE DANE IDENTYFIKACYJNE
rib-bank = Bank:
rib-national = RIB - Krajowy identyfikator konta
rib-establishment = INSTYTUCJA
rib-branch = ODDZIAŁ
rib-number = NUMER KONTA
rib-key = KLUCZ RIB
rib-domiciliation = MIEJSCE PROWADZENIA KONTA
rib-iban = IBAN - Międzynarodowy identyfikator konta
rib-bic = BIC - Międzynarodowy identyfikator instytucji
rib-holder = Właściciel konta

# --- Okno F32 ----------------------------------------------------------
window-rib-title = Wydruk RIB ( Bankowe Dane Identyfikacyjne )
rib-group-bank = Bank
rib-group-holder = Właściciel konta
rib-group-details = Dane bankowe
rib-field-bank = Nazwa banku
rib-field-domiciliation = Miejsce prowadzenia konta
rib-field-holder = Nazwa właściciela
rib-field-address = Adres
rib-field-establishment = Instytucja
rib-field-branch = Oddział
rib-field-number = Numer konta
rib-field-key = Klucz RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Ważne warunki użytkowania, których należy bezwzględnie przestrzegać w razie wydruku
rib-declaration = Ja, niżej podpisany użytkownik oprogramowania, oświadczam pod słowem honoru:
rib-declaration-first = - Potwierdzam, że sprawdziłem w moim banku, iż dane bankowe zawarte w tym oknie są poprawne i zgodne z moją wolą . Potwierdzam tak samo, że zobowiązuję się sprawdzić, iż dane zawarte w wydruku RIB są poprawne i zgodne z moją wolą. Ten wydruk i użycie RIB odbędą się na moją wyłączną odpowiedzialność
rib-declaration-second = - Że jestem właścicielem konta, którego RIB zostanie wydrukowany, i że nie będę używać funkcji tego oprogramowania w celu sprzecznym z prawem.
rib-title-print = Wydruk na drukarce
rib-title-pdf = Wydruk do pliku PDF
# To pole nie jest ozdobnym ostrzeżeniem: dopóki nie jest zaznaczone, oba
# przyciski są wygaszone (rozstrzygnięcie Fabrice'a, 01/08/2026).
rib-declaration-required = Zaznacz oświadczenie pod słowem honoru, aby móc drukować.
rib-help = Sprawdź swoje dane, zaznacz oświadczenie, a potem drukuj.
rib-account-gone = Tego konta bankowego nie można odnaleźć.
rib-fields-read-only = Te dane pochodzą z karty konta: popraw je w karcie, aby zmienić je tutaj.
rib-printed = RIB wysłany na twoją domyślną drukarkę.
rib-print-failed = Drukowanie niemożliwe: { $reason }
rib-pdf-done = RIB wydrukowany i otwarty: „{ $file }”.
rib-pdf-not-opened = RIB wydrukowany do „{ $file }”, ale twój system nie potrafił go sam otworzyć.
menu-accounts-bank-details = Wystaw bankowe dane identyfikacyjne

# Wybór drukarki. Radinus sam zadaje to pytanie: żaden z trzech webview nie
# otwiera systemowego okna drukowania.
print-choose-printer = Na której drukarce chcesz drukować?
print-do-print = Drukuj
rib-printed-on = RIB wysłany na drukarkę „{ $printer }”.
ui-cancel = Anuluj

# System nie potrafił nazwać żadnej drukarki: drukujemy mimo to na drukarce
# domyślnej, zamiast blokować użytkownika.
print-printers-unknown = Twój system nie potrafił nazwać żadnej drukarki: dokument poszedł na drukarkę domyślną.

print-menu-operations-printer = Wydruk na drukarce
print-sent-on = Zestawienie wysłane na drukarkę „{ $printer }”.
print-sent-default = Zestawienie wysłane na twoją domyślną drukarkę.

# --- Faza 17 — operacje na bazie danych ---------------------------------
backup-archive = Archiwum Radinus
backup-no-database = Żadna baza danych nie jest otwarta.
backup-done = Kopia zapasowa zapisana w „{ $file }”.
backup-failed = Kopia zapasowa niemożliwa: { $reason }
backup-not-started = Nie udało się rozpocząć kopii zapasowej:
restore-unreadable = Ten plik nie jest czytelnym archiwum Radinus: { $reason }
# Pytanie mówi, co zostanie utracone, zanim to zostanie utracone. Archiwum jest
# w tym momencie już odczytane: to, co zapowiada, jest pewne.
restore-question = Przywrócić „{ $file }”? Cała obecna zawartość twojej bazy zostanie skasowana i zastąpiona, a to, co się w niej znajduje, zostanie utracone.
restore-done = Przywracanie zakończone: { $accounts } kont i { $operations } operacji.
restore-failed = Przywracanie niemożliwe: { $reason }
restore-empty-fields = Puste pola odczytane jako wartość zerowa: { $count }.


# --- Dziennik operacji technicznych (faza 17) --------------------------
# Trzy statusy jego Ajoute_Log, wielkimi literami, tak jak u niego.
journal-status-success = SUKCES
journal-status-failure = NIEPOWODZENIE
journal-status-repaired = NAPRAWIONO
journal-step-reindex = Naprawa tabeli bazy danych
journal-step-refill = Systemowy słownik pusty: przywrócono wartości domyślne
journal-step-table-created = Brak tabeli w bazie: utworzona ponownie, pusta
journal-step-column-added = Brak kolumny w tabeli: dodana z wartością domyślną

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Ochrona hasłem
window-password-form-title = Ochrona hasłem
password-ask = Ta baza jest chroniona. Wprowadź jej hasło.
password-group-database = Baza, której to dotyczy
password-group-password = Hasło
password-group-warning = Zanim zatwierdzisz
password-field-old = Stare hasło
password-field-new = Nowe hasło
password-field-repeat = Powtórz nowe hasło
password-hint = Zostaw stare puste, jeśli baza nie jest jeszcze chroniona. Zostaw oba nowe puste, aby zdjąć ochronę.
password-lost-warning = Utracone hasło to utracona baza: nic jej nie odzyska. Kopie zapasowe pozostają natomiast niezaszyfrowane.
password-show = Pokaż hasło
password-remove-question = Zdjąć ochronę z tej bazy?
password-mismatch = Dwa wpisy nowego hasła różnią się
password-wrong = Hasło nie pasuje
password-close-first = Zamknij tę bazę przed zmianą jej hasła
password-now-protected = Baza jest chroniona hasłem
password-now-clear = Baza nie jest już chroniona
journal-step-date-fixed = Poprawienie operacji bez daty
journal-step-circular = Usunięcie niespójnej operacji: odwołanie cykliczne
journal-step-flag-parent-true = Zła flaga EstParent=Fałsz na operacji głównej
journal-step-flag-parent-false = Zła flaga EstParent=Prawda na operacji głównej
journal-step-flag-child = Zła flaga EstParent=Prawda na podoperacji
journal-step-orphan = Usunięcie osieroconej podoperacji
journal-step-third-level = Usunięcie podoperacji podpiętej pod inną podoperację
journal-step-coherence = Ogólne przeliczenie spójności między podoperacjami a operacjami głównymi
journal-step-balances = Przeliczenie wszystkich sald wszystkich kont
journal-step-vacuum = Optymalizacja pliku bazy danych
journal-step-analyze = Aktualizacja statystyk wyszukiwania
journal-step-backup-begin = Początek tworzenia kopii zapasowej bazy
journal-step-backup-end = Koniec tworzenia kopii zapasowej bazy
journal-step-restore-begin = Początek przywracania bazy z archiwum
journal-step-restore-end = Koniec przywracania bazy z archiwum
journal-step-restore-read = Odczyt archiwum

# --- Okno dziennika (⌘H) -----------------------------------------------
window-journal-title = Dziennik ostatniej operacji technicznej
journal-column-step = Etap
journal-column-file = Plik
journal-column-table = Tabela
journal-column-status = Status
journal-column-error = Błąd
journal-column-comments = Komentarze
journal-empty = Od uruchomienia programu nie wykonano jeszcze żadnej operacji technicznej.
journal-help = Dziennik zachowuje tylko ostatnią operację techniczną: kopię zapasową, przywracanie, naprawę, skasowanie albo otwarcie bazy.

# --- Naprawa ------------------------------------------------------------
menu-file-repair-running = Trwa naprawa i optymalizacja…
repair-done = { $anomalies ->
    [0] Naprawa zakończona: nie znaleziono żadnej anomalii. Etapów zapisanych w dzienniku: { $lines }.
    [one] Naprawa zakończona: naprawiono jedną anomalię. Etapów zapisanych w dzienniku: { $lines }.
    [few] Naprawa zakończona: naprawiono { $anomalies } anomalie. Etapów zapisanych w dzienniku: { $lines }.
    [many] Naprawa zakończona: naprawiono { $anomalies } anomalii. Etapów zapisanych w dzienniku: { $lines }.
   *[other] Naprawa zakończona: naprawiono { $anomalies } anomalii. Etapów zapisanych w dzienniku: { $lines }.
}
repair-failed = Naprawa niemożliwa: { $reason }

journal-status-started = W TOKU
journal-status-finished = ZAKOŃCZONO
journal-step-backup-table = Zapis tabeli do archiwum
journal-step-backup-write = Zapis archiwum
journal-step-backup-verified = Sprawdzenie zapisanego archiwum: pliki odczytane / oczekiwane, rekordy odczytane / zapisane
journal-step-backup-total = Razem zapisane: rekordy, dane, rozmiar pliku
journal-step-restore-table = Odczyt tabeli z archiwum
journal-step-restore-missing = Brak pliku w archiwum: ta tabela nie zostanie przywrócona
journal-step-restore-wipe = Całkowite skasowanie zawartości bazy przed przywracaniem
journal-step-restore-write = Zapis do bazy
journal-step-restore-total = Razem przywrócone: konta, operacje
journal-step-restore-empty-fields = Puste pola uzupełnione podczas odczytu
backup-verify-mismatch = Zapisane archiwum nie odczytuje się tak, jak zostało zapisane: nie polegaj na nim, zrób kopię zapasową jeszcze raz.

# --- Załączniki operacji (F28, faza 17) ---------------------------------
window-attachments-title = Załączniki operacji
attachment-filter = Akceptowane dokumenty
attachment-none = Ta operacja nie ma żadnego załącznika.
attachment-title-add = Załącz dokument do tej operacji
attachment-title-open = Otwórz załącznik
attachment-title-remove = Usuń załącznik i przenieś jego plik do kosza
# Stan pliku na dysku. „Nie do sprawdzenia” nie jest bezpodstawnym przyznaniem
# się do niewiedzy: odciski przyniesione z Radinus 1.9.3 są okrojone przez format
# kopii zapasowej, a ocenianie pliku na ich podstawie byłoby oskarżaniem na oślep.
attachment-state-ok = Nienaruszony
attachment-state-changed = Zmieniony
attachment-state-missing = Brak pliku
attachment-state-unknown = Nie do sprawdzenia
attachment-added = „{ $name }” został załączony do operacji.
attachment-removed = Załącznik usunięty, jego plik jest w koszu.
attachment-removed-kept = Załącznik usunięty, ale jego pliku nie udało się przenieść do kosza.
attachment-remove-question = Usunąć „{ $name }” z tej operacji? Jego plik zostanie przeniesiony do kosza.
attachment-opened = „{ $name }” został otwarty.
attachment-opened-changed = „{ $name }” został otwarty, ale jego zawartość zmieniła się od chwili załączenia.
attachment-gone = Ten załącznik już nie istnieje.
attachment-file-missing = Pliku „{ $name }” nie można odnaleźć na dysku.
attachment-failed = Operacja niemożliwa: { $reason }
attachment-save-first = Zapisz najpierw operację: załącznik podpina się do operacji, która istnieje.
attachment-refusal-missing = Ten plik nie istnieje.
attachment-refusal-extension = Ten typ pliku nie jest akceptowany. Akceptowane są: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Operacja, do której miałby zostać załączony ten dokument, nie istnieje.
journal-step-backup-attachments = Załączniki dodane do archiwum
journal-step-backup-attachment-missing = Załącznika nie można odnaleźć na dysku: zabraknie go w archiwum
journal-step-restore-attachments = Załączniki wydobyte z archiwum
attachment-title-replace = Zastąp dokument tego załącznika
attachment-replaced = Dokument został zastąpiony przez „{ $name }”.

# ---------------------------------------------------------------------
# F08 — menu „Narzędzia” karty konta.
#
# Jego trzy pozycje są portem WLangage'u Fabrice'a (folder
# „Information import export base piece jointe”): obliczenie uzgodnionego
# salda początkowego, statystyki konta i usunięcie wszystkich jego
# transakcji. Menu działa tylko przy edycji (rozstrzygnięcie z
# 02/08/2026): przy tworzeniu nie ma czego liczyć, a przy podglądzie karta
# tylko pokazuje.
# ---------------------------------------------------------------------

account-tools = Narzędzia
account-tools-initial-balance = Określ uzgodnione saldo początkowe
account-tools-statistics = Statystyki konta bankowego
account-tools-delete-operations = Usuń wszystkie transakcje konta

# Pytanie o obliczenie, słowo w słowo jak w oryginale. { $total } to suma
# uzgodnionych operacji, zapisana już w formacie walutowym.
account-initial-balance-question =
    Aby obliczyć uzgodnione saldo początkowe względem operacji obecnych na tym koncie, podaj aktualne saldo w twoim banku
    Uzgodnione saldo początkowe zostanie obliczone jako równe:
    { "[" }Aktualne saldo bankowe] - [Suma operacji uzgodnionych ({ $total }) ].
    { "" }
    Aby nie musieć wpisywać tej wartości ponownie, musisz mieć całkowicie aktualną listę operacji bankowych na tym koncie.

account-statistics-none = Brak transakcji

# Czternaście wierszy jego Info(). Literówka „pengagés” z oryginału jest
# poprawiona, decyzją Fabrice'a z 02/08/2026 — tak jak „Bank Identifer Code”
# na tej samej karcie.
account-statistics =
    Łączna liczba transakcji na tym koncie: { $count }
    { "" }
    Liczba uzgodnionych transakcji na tym koncie: { $pointed }
    Kwota uzgodnionych rozchodów: { $pointedDebits }
    Kwota uzgodnionych przychodów: { $pointedCredits }
    Różnica między uzgodnionymi przychodami a rozchodami: { $pointedDifference }
    { "" }
    Liczba zarezerwowanych transakcji na tym koncie: { $committed }
    Kwota zarezerwowanych rozchodów: { $committedDebits }
    Kwota zarezerwowanych przychodów: { $committedCredits }
    Różnica między zarezerwowanymi przychodami a rozchodami: { $committedDifference }
    { "" }
    Liczba planowanych transakcji na tym koncie: { $planned }
    Kwota planowanych rozchodów: { $plannedDebits }
    Kwota planowanych przychodów: { $plannedCredits }
    Różnica między planowanymi przychodami a rozchodami: { $plannedDifference }
    { "" }
    Najstarsza transakcja: { $first }
    Najnowsza transakcja: { $last }

# Podwójna bariera przy usuwaniu. { $word } to „tak” w bieżącym języku —
# osoba mówiąca po hiszpańsku, poproszona o napisanie OUI, nie zrozumiałaby
# (decyzja Fabrice'a, 02/08/2026).
account-delete-operations-question =
    Czy na pewno chcesz usunąć wszystkie operacje zawarte w koncie bankowym?
    Aby to potwierdzić, wpisz { $word } w polu poniżej i zatwierdź

account-delete-operations-done =
    { $count ->
        [0] Nie usunięto żadnej transakcji.
        [one] Usunięto { $count } transakcję.
        [few] Usunięto { $count } transakcje.
        [many] Usunięto { $count } transakcji.
       *[other] Usunięto { $count } transakcji.
    }

# ---------------------------------------------------------------------
# Selektor bazy i wybór języka (02/08/2026)
#
# Decyzje podjęte w rozmowie z Fabrice'em: Radinus nie tworzy już bazy
# bez zezwolenia; bez języka w konfiguracji pyta o język przed
# wszystkim innym; bazą jest każdy folder z databases/, który zawiera
# radinus.sqlite, jakakolwiek byłaby jego nazwa.
#
# Okno wyboru języka nie ma tutaj żadnego klucza: nie używa żadnego
# zdania, i właśnie to pozwala mu być zrozumianym, zanim wiadomo, jakim
# językiem mówi użytkownik.
# ---------------------------------------------------------------------

window-database-selector-title = Bazy danych
window-database-form-title = Nowa baza danych
database-group-identity = Identyfikacja bazy danych
database-group-restore = Zainicjuj bazę danymi z kopii zapasowej
database-choose-backup = Wybierz plik kopii zapasowej
database-no-backup = Nie wybrano kopii: baza powstanie pusta.

databases-column-label = Baza
databases-column-comment = Komentarz
databases-column-folder = Folder
databases-column-created = Utworzona

databases-none = Na razie nie ma żadnej bazy: utwórz ją.
databases-help = Wybierz bazę do otwarcia lub utwórz nową.
databases-select = Najpierw wybierz bazę z listy.
databases-tools = Narzędzia
databases-title-open = Otwórz tę bazę

database-created = Baza „{ $label }” została utworzona.
database-field-label = Nazwa bazy
database-field-comment = Komentarz
database-label-required = Nadaj tej bazie nazwę: to ona odróżni ją od pozostałych.
database-gone = Tej bazy już nie ma: została przeniesiona lub usunięta od czasu otwarcia tego okna.

# Usunięcie bazy (02/08/2026). Folder trafia do kosza systemowego, tak jak
# załączniki: bazę usuniętą przez pomyłkę przywraca się prawym kliknięciem.
# Otwarta baza jest odrzucana — Radinus trzyma jej plik.
databases-title-delete = Usuń tę bazę
database-delete-question =
    Czy na pewno chcesz usunąć bazę „{ $label }”?
    { "" }
    Cały jej folder trafi do kosza: operacje, konta i załączniki.
    Aby to potwierdzić, wpisz { $word } w polu poniżej i zatwierdź.
database-in-use = Ta baza jest otwarta: Radinus nie może jej usunąć. Otwórz najpierw inną.
database-deleted = Baza „{ $label }” jest w koszu.

# Selektor ma dwa tryby (Fabrice, 02/08/2026). Otwarty w trakcie pracy, nie
# umie już otwierać: okno programu Radinus jest budowane raz i nigdy nie
# niszczone, i nic nie zdoła sprawić, by zapomniało bazę, którą pokazuje.
# Przegląda się, tworzy, usuwa — a żeby zmienić bazę, wychodzi się z
# programu.
database-quit-first = Aby otworzyć tę bazę, zamknij program Radinus i uruchom go ponownie: selektor zaproponuje ci ją przy starcie.


# --- F01 — okno powitalne (faza 17 bis, 03/08/2026) ----------------------
#
# Pierwszy dodatek 2.0.0 względem 1.9.3: okno powitalne nie niesie już samego
# baneru. Regułę, która nim rządzi, zapisano w dokumencie 04 F01: to jest widok
# BEZ JEDNEGO KLIKNIĘCIA i nie wchodzi do niego nic, co wymaga ustawienia.
#
# Oba tytuły wykresów pierścieniowych niosą cały miesiąc, zamiast być sklejane
# koniec z końcem przez okno: „Wydatki ... — sierpień 2026” nie ma tego samego
# szyku wyrazów w trzech językach, a tylko Fluent wie, gdzie jest dziura.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Brak otwartych kont
    [one] { $count } otwarte konto
    [few] { $count } otwarte konta
    [many] { $count } otwartych kont
   *[other] { $count } otwartego konta
}
welcome-total-bank = Saldo bankowe
welcome-total-real = Saldo rzeczywiste
welcome-total-final = Saldo końcowe
welcome-total-real-detail = uzgodnione + zarezerwowane
welcome-total-final-detail = uzgodnione + zarezerwowane + planowane
welcome-accounts = Twoje konta
welcome-tile-bank = W banku
welcome-tile-real = Rzeczywiste
welcome-tile-final = Końcowe
welcome-spending = Wydatki — { $month }
welcome-earning = Wpływy — { $month }
ui-legend-budget-lines = Pozycje budżetowe
ui-legend-categories = Kategorie
welcome-nothing = Brak operacji w tym miesiącu.
welcome-open-account = Informacja: kliknij konto, aby otworzyć jego operacje.
welcome-no-account = Nie ma jeszcze żadnego konta bankowego.
welcome-no-account-create = Utwórz konto bankowe, klikając tutaj
welcome-previous-month = Poprzedni miesiąc
welcome-next-month = Następny miesiąc
welcome-refresh = Odczytaj wszystko ponownie


# --- F39 — preferencje (faza 17 ter, 03/08/2026) -------------------------
#
# Miejsce znaku waluty mieszka tutaj, obok dwóch separatorów: idzie ono za
# językiem, a nie za walutą. „before” stawia znak przed liczbą, każda inna
# wartość stawia go za nią. ŻADEN znak waluty nie jest zapisany w tym pliku:
# „polski” nie znaczy „złoty”.

ui-money-sign-position = after
window-preferences-title = Preferencje
menu-settings-preferences = Preferencje…
menu-settings-show-main = Pokaż okno główne
menu-settings-folders = Foldery Radinusa
preferences-branch-display = Wyświetlanie
preferences-leaf-language = Język
preferences-leaf-currency = Waluta
preferences-field-language = Język programu:
preferences-field-currency = Wyświetlana waluta:
preferences-field-custom = Znak waluty:
preferences-currency-system = Waluta systemowa
preferences-currency-euro = Euro
preferences-currency-dollar = Dolary
preferences-currency-canadian = Dolary kanadyjskie
preferences-currency-cfa = Franki CFA
preferences-currency-cfp = Franki Pacyfiku
preferences-currency-swiss = Franki szwajcarskie
preferences-currency-none = Brak
preferences-currency-custom = Własny
preferences-currency-system-is = Twój system zgłasza:
preferences-currency-system-silent = Twój system nie zgłasza żadnej waluty: kwoty będą wyświetlane w euro.
preferences-custom-required = Wpisz znak swojej waluty przed zapisaniem.
preferences-saved = Preferencje zapisane.
preferences-help = Wybierz opcję w drzewie, a następnie zapisz.
preferences-sign-too-long = Znak waluty mieści się w najwyżej 8 znakach.
preferences-sign-not-a-number = Znak waluty nie może zawierać ani cyfry, ani znaku działania, ani przecinka: Radinus usuwa je, gdy odczytuje kwotę, a „120” stałoby się „12”.
preferences-leaf-zoom = Rozmiar wyświetlania
preferences-field-zoom = Powiększenie:
preferences-zoom-reset = Wartość domyślna
preferences-zoom-hint = Wszystko powiększa się razem: tekst, ikony, kolumny. Poniżej 100 % więcej mieści się na ekranie. Pasek menu systemu i jego okna dialogowe idą natomiast za ustawieniami twojego komputera, a nie za tymi.

# --- Baner strony powitalnej ---------------------------------------------
#
# Te zdania były zapisane na sztywno w `index.html` od fazy 0 i dlatego się
# nie tłumaczyły (zauważone przez Fabrice'a 03/08/2026). Motto jest jego
# głosem: wersje angielska i hiszpańska są propozycjami, do poprawienia
# przez niego — slogan nie tłumaczy się słowo w słowo.
ui-language-tag = pl
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — wiewiórka maskotka, w garniturze, otoczona przez euro, kalkulator i wykresy
welcome-slogan-one = Program do zarządzania finansami osobistymi, który pomaga ci wydawać mniej, aby zarabiać więcej
welcome-slogan-two = Dzięki programowi Radinus zrozumiesz, dlaczego małe strumyki tworzą wielkie rzeki.

# --- „O autorze” ---------------------------------------------------------
#
# Nazwisko i adres są zapisane identycznie w trzech plikach: nie tłumaczą się.
# Są tu mimo wszystko, a nie na stronie, po to, by widok nie niósł żadnego
# zdania — i by poprawiało się je w jednym tylko miejscu w dniu, w którym
# autor się przeprowadzi.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = O autorze
about-author-flag-alt = Flaga Korsyki — głowa Maura

# --- „O programie Radinus” -----------------------------------------------
#
# `about-radinus-version` niesie dziurę: numer pochodzi z działającego pliku
# binarnego, nigdy z przepisanego ciągu znaków. Nie ma jej zatem w słowniku
# okien — wypełnia ją polecenie `app_version`.
window-about-radinus-title = O programie Radinus
about-radinus-name = Radinus
about-radinus-version = Wersja { $version }
about-radinus-rust-alt = Logo języka Rust
about-radinus-tauri-alt = Logo Tauri
about-radinus-built = Radinus jest napisany w języku Rust i zbudowany za pomocą Tauri. Pierwszy liczy twoje konta, drugi robi z nich aplikację na komputer.
about-radinus-licence = Wolne oprogramowanie, na licencji GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Licencja
licence-heading = LICENCJA UŻYTKOWANIA PROGRAMU RADINUS
licence-logo-alt = Logo GNU General Public License w wersji 3
licence-name = GNU GPL v3 lub nowsza
licence-intro = Radinus to wolne oprogramowanie.
licence-freedoms-title = Jego licencja daje ci cztery wolności:
licence-freedom-use = Używać go jak chcesz i do czego chcesz.
licence-freedom-study = Badać jego kod źródłowy, otwarty dla wszystkich.
licence-freedom-share = Kopiować go i przekazywać innym.
licence-freedom-improve = Zmieniać go i dzielić się swoimi zmianami.
licence-read = Przeczytaj pełny tekst licencji

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Ten program jest dostarczany bez żadnej gwarancji, w zakresie dozwolonym przez prawo.
licence-info = Oficjalny tekst otworzy się w twojej przeglądarce, na gnu.org.

