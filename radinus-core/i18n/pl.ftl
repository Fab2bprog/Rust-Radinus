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
menu-statistics-balance-analysis = Analiza zmiany salda
menu-statistics-by-category = Stat. wg kategorii
menu-statistics-by-assignment = Stat. wg przeznaczeń
menu-statistics-by-budget-line = Stat. wg pozycji budżetowych
menu-statistics-by-payment-mode = Stat. wg sposobów płatności
menu-statistics-by-payee = Stat. wg kontrahentów i sprzedawców
menu-statistics-by-project = Stat. wg projektów
menu-statistics-by-verification = Stat. wg weryfikacji
menu-statistics-dashboard = Pulpit operacji
menu-statistics-crossed-balance = Bilans krzyżowy

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

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Narzędzia
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
operations-column-status = Status operacji
operation-status-pointed = Uzgodniona
operation-status-committed = Zarezerwowana
operation-status-planned = Planowana
operations-column-verification = Weryfikacja
operation-verification-to-verify = Do sprawdzenia
operation-verification-verified = Sprawdzona
operation-verification-doubtful = Wątpliwa
operation-verification-disputed = Zakwestionowana
operations-column-label = Opis
operations-column-reference = Referencja płatności
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
filter-by-status = Filtr statusu
filter-by-verification = Filtr weryfikacji
filter-show-all = Pokaż wszystko

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
operation-field-verification = Weryfikacja
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
operation-clearing-date-required = Operacja rozliczona musi obowiązkowo mieć datę rozliczenia.
operation-clearing-date-question =
    Operacja rozliczona musi obowiązkowo mieć datę rozliczenia.
    Czy chcesz zapisać z datą operacji, { $date }?
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
    [0] Brak operacji do uzgodnienia: zaznaczenie jest już uzgodnione.
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
operations-recurring-from = Utwórz operację cykliczną na podstawie tej operacji

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
    [verification] Statystyki według weryfikacji
   *[category] Statystyki według kategorii
}

statistics-axis-column = { $kind ->
    [assignment] Przeznaczenie
    [budget-line] PozycjaBudżetu
    [payment-mode] SposóbOperacji
    [payee] Kontrahent
    [project] Projekty
    [verification] Weryfikacja
   *[category] NazwaKategorii
}

statistics-unclassified = { $kind ->
    [assignment] Bez przeznaczenia
    [budget-line] Bez pozycji budżetowej
    [payment-mode] Bez sposobu płatności
    [payee] Bez kontrahenta
    [project] Bez projektu
    [verification] Do sprawdzenia
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

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Bilans krzyżowy
crossed-balance-window-name = Bilans krzyżowy
crossed-balance-column = Kategoria
crossed-balance-no-data = Brak operacji w tym miesiącu dla wybranych kont.
crossed-balance-month-question = Nad którym miesiącem chcesz pracować? Liczba od { $first } do { $last }.
crossed-balance-month-choose = Wybierz miesiąc
crossed-balance-next = Następny miesiąc
crossed-balance-previous = Poprzedni miesiąc

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
export-to = Eksportuj do
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Kopiuj komórkę
copy-rows = Kopiuj zaznaczone wiersze
copy-failed = Nie udało się skopiować do schowka.
export-all-years-excel = Eksportuj wszystkie lata do Excela
export-all-years-ods = Eksportuj wszystkie lata do LibreOffice Calc
export-all-months-excel = Eksportuj wszystkie miesiące wyświetlanego roku do Excela
export-all-months-ods = Eksportuj wszystkie miesiące wyświetlanego roku do LibreOffice Calc
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
    [verification] Statystyki według weryfikacji
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

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Analiza zmiany salda
analysis-heading = Analiza zmiany salda
analysis-hint = Przeciągnij po wykresie z wciśniętym przyciskiem myszy, aby zobaczyć operacje z tego okresu.
analysis-zone = Strefa:
analysis-opening = Saldo początkowe:
analysis-closing = Saldo końcowe:
analysis-variation = Zmiana:
analysis-detail-name = Analiza salda
analysis-detail-none = Brak operacji w tej strefie.

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
quick-check-verification = Weryfikacja
quick-column-date = Data
quick-column-label = Opis
quick-column-amount = Kwota
quick-column-category = Kategoria
quick-column-assignment = Przeznaczenie
quick-column-payment-mode = Sposób płatności
quick-column-payee = Kontrahent
quick-column-project = Projekty
quick-column-status = Status
quick-column-verification = Weryfikacja
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
statement-column-reference = Referencja płatności
statement-column-debit = Rozchód
statement-column-credit = Przychód
statement-account = Konto
statement-file = Plik
statement-difference = Różnica
statement-none = Żaden wyciąg nie jest otwarty: kliknij żółty folder, aby wybrać plik (OFX, CSV, QIF).
statement-empty = Ten wyciąg nie zawiera żadnej operacji.
statement-no-match = Żaden wiersz nie odpowiada filtrowi.
statement-help = Info: Użyj kliknięcia myszą + klawisza [{ $modifier }] w tabeli, aby zaznaczyć kilka wierszy
statement-choose-account = Ten plik zawiera kilka kont. Które chcesz zaimportować?
statement-select-line = Zaznacz co najmniej jeden wiersz wyciągu.
statement-title-open = Otwórz plik wyciągu (OFX, QIF, CSV)
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
statement-loaded-unidentified = { $alike ->
    [0] Wczytano wierszy: { $count }; żaden nie przypomina operacji już obecnej na twoim koncie.
    [one] Wczytano wierszy: { $count }; jeden z nich przypomina operację już obecną na twoim koncie (ta sama data, ten sam opis, ta sama kwota).
    [few] Wczytano wierszy: { $count }; { $alike } z nich przypominają operacje już obecne na twoim koncie (ta sama data, ten sam opis, ta sama kwota).
    [many] Wczytano wierszy: { $count }; { $alike } z nich przypomina operacje już obecne na twoim koncie (ta sama data, ten sam opis, ta sama kwota).
   *[other] Wczytano wierszy: { $count }; { $alike } z nich przypomina operacje już obecne na twoim koncie (ta sama data, ten sam opis, ta sama kwota).
}
statement-loaded-also-alike = { $alike ->
    [one] Jeszcze jeden przypomina operację już obecną (ta sama data, ten sam opis, ta sama kwota).
    [few] Jeszcze { $alike } przypominają operacje już obecne (ta sama data, ten sam opis, ta sama kwota).
    [many] Jeszcze { $alike } przypomina operacje już obecne (ta sama data, ten sam opis, ta sama kwota).
   *[other] Jeszcze { $alike } przypomina operacje już obecne (ta sama data, ten sam opis, ta sama kwota).
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
statement-qif-question = Nic w tym pliku nie wskazuje, czy data „{ $date }” jest zapisana jako dzień/miesiąc czy miesiąc/dzień. Oznacza ona:
statement-qif-day-month = Dzień { $day }, miesiąc { $month } (dzień/miesiąc)
statement-qif-month-day = Dzień { $day }, miesiąc { $month } (miesiąc/dzień)
statement-qif-dates-mixed = Ten plik zapisuje daty na dwa sposoby: „{ $first }” czyta się jako dzień/miesiąc, „{ $second }” jako miesiąc/dzień. Nie jest importowany, aby nie zafałszować żadnej daty.
statement-qif-amounts-mixed = Ten plik zapisuje kwoty na dwa sposoby: „{ $first }” z kropką, „{ $second }” z przecinkiem. Nie jest importowany, aby nie zafałszować żadnej kwoty.
statement-qif-opening = Saldo początkowe { $amount } na dzień { $date }: to nie jest operacja, nie jest importowane.
statement-qif-opening-undated = Saldo początkowe { $amount }: to nie jest operacja, nie jest importowane.
statement-qif-suspect = Wiersz { $rank }, „{ $label }” ({ $amount }), wygląda na saldo początkowe: sprawdź go przed włączeniem.
statement-qif-rejected = { $count ->
    [one] Jeden nieczytelny wiersz nie jest importowany: { $lines }.
    [few] { $count } nieczytelne wiersze nie są importowane: { $lines }.
    [many] { $count } nieczytelnych wierszy nie jest importowanych: { $lines }.
   *[other] { $count } nieczytelnego wiersza nie jest importowane: { $lines }.
}
statement-qif-reason-date = data
statement-qif-reason-amount = kwota
statement-qif-reason-differ = sprzeczne kwoty
statement-qif-no-account = Tego konta nie ma już w pliku: otwórz plik ponownie.
statement-balance-unknown = nie podano w pliku
statement-group-identification = Identyfikacja operacji
statement-group-amount = Kwota operacji
statement-group-classification = Klasyfikacja operacji do obliczania statystyk
statement-group-status = Status operacji
statement-field-date = Data
statement-field-label = Opis
statement-field-reference = Referencja płatności
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
backup-done = Kopia zapasowa bazy „{ $base }” zapisana w „{ $file }”. Pozostałych baz to nie dotyczy.
backup-failed = Kopia zapasowa niemożliwa: { $reason }
backup-not-started = Nie udało się rozpocząć kopii zapasowej:
restore-unreadable = Ten plik nie jest czytelnym archiwum Radinus: { $reason }
# Pytanie mówi, co zostanie utracone, zanim to zostanie utracone. Archiwum jest
# w tym momencie już odczytane: to, co zapowiada, jest pewne.
restore-question = Przywrócić „{ $file }” do bazy „{ $base }”? Cała obecna zawartość tej bazy zostanie skasowana i zastąpiona, a to, co się w niej znajduje, zostanie utracone. Pozostałe bazy pozostają nienaruszone.
restore-done = Baza „{ $base }” została przywrócona: { $accounts } kont i { $operations } operacji. Pozostałe bazy pozostają nienaruszone.
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
database-too-recent = Ta baza została zapisana przez nowszą wersję programu Radinus (wersja bazy { $found }; ta wersja odczytuje do wersji { $supported }). Zaktualizuj Radinus, aby ją otworzyć.
database-not-radinus = Ten plik nie jest bazą Radinus.
database-unreadable = Nie udało się odczytać bazy: { $reason }
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
    [0] Naprawa bazy „{ $base }” zakończona: nie znaleziono żadnej anomalii. Etapów zapisanych w dzienniku: { $lines }. Pozostałych baz to nie dotyczy.
    [one] Naprawa bazy „{ $base }” zakończona: naprawiono jedną anomalię. Etapów zapisanych w dzienniku: { $lines }. Pozostałych baz to nie dotyczy.
    [few] Naprawa bazy „{ $base }” zakończona: naprawiono { $anomalies } anomalie. Etapów zapisanych w dzienniku: { $lines }. Pozostałych baz to nie dotyczy.
    [many] Naprawa bazy „{ $base }” zakończona: naprawiono { $anomalies } anomalii. Etapów zapisanych w dzienniku: { $lines }. Pozostałych baz to nie dotyczy.
   *[other] Naprawa bazy „{ $base }” zakończona: naprawiono { $anomalies } anomalii. Etapów zapisanych w dzienniku: { $lines }. Pozostałych baz to nie dotyczy.
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
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Konta liczone w sumach: { $count } z { $total }
welcome-tile-counted = Licz to konto w sumach
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
preferences-branch-import = Import
preferences-leaf-verification = Weryfikacja
preferences-field-verification = Operacje importowane:
preferences-verification-hint = „Sprawdzona”: ufasz swojemu bankowi, zaimportowana operacja jest uznawana za poprawną. „Do sprawdzenia”: każda zaimportowana operacja czeka na Twoją kontrolę; potem samodzielnie zmieniasz ją na „Sprawdzona” na liście operacji. To ustawienie dotyczy tylko przyszłych importów.
preferences-leaf-ofx = Wyciągi OFX
preferences-field-ofx-label = Opis operacji:
preferences-field-ofx-reference = Referencja płatności:
preferences-ofx-choice-name = Nazwa operacji
preferences-ofx-choice-memo = Notatka banku
preferences-ofx-choice-name-and-memo = Nazwa, a po niej notatka
preferences-ofx-choice-empty = Nic (pozostaw puste)
preferences-ofx-label-help = Co trafia do opisu importowanej operacji. Nazwa to ta, którą wyświetla bank, na przykład „PRLV SEPA”; niektóre banki dodają do niej szczegółową notatkę: wierzyciela polecenia zapłaty, odbiorcę i tytuł przelewu. Gdy operacja nie ma notatki, jej opis zachowuje nazwę.
preferences-ofx-reference-help = Co trafia do referencji płatności importowanej operacji, gdzie możesz ją zobaczyć i według niej filtrować. Gdy operacja nie ma notatki, „Notatka banku” pozostawia referencję pustą. Jeśli notatka już powtarza nazwę, nie jest zapisywana dwukrotnie.
preferences-ofx-hint = Te ustawienia dotyczą wszystkich wyciągów OFX, niezależnie od otwartej bazy. Obowiązują od następnego otwartego wyciągu.
preferences-leaf-qif = Wyciągi QIF
preferences-field-qif-order = Kolejność dnia i miesiąca:
preferences-qif-order-ask = Pytaj mnie za każdym razem
preferences-qif-order-day-month = Zawsze dzień/miesiąc (05/03 = 5 marca)
preferences-qif-order-month-day = Zawsze miesiąc/dzień (05/03 = 3 maja)
preferences-qif-order-help = Używane tylko wtedy, gdy żadna data w pliku nie pozwala tego rozstrzygnąć. Gdy tylko data taka jak 24/11 dowodzi kolejności, decyduje plik, niezależnie od tego ustawienia.
preferences-field-qif-label = Opis operacji:
preferences-qif-label-both = Kontrahent + notatka
preferences-qif-label-payee = Tylko kontrahent
preferences-qif-label-memo = Tylko notatka
preferences-qif-label-help = Gdy operacja ma jednocześnie kontrahenta i notatkę. Jeśli ma tylko jedno z nich, używane jest właśnie ono, niezależnie od tego ustawienia.
preferences-qif-hint = Te ustawienia dotyczą wszystkich wyciągów QIF, niezależnie od otwartej bazy. „Pytaj mnie za każdym razem” jest najbezpieczniejsze: plik z niejednoznacznymi datami nigdy nie jest odczytywany na chybił trafił.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Przywróć domyślne kolumny
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Pokaż/Ukryj
columns-colour = Pokoloruj kolumnę:
columns-colour-none = Brak koloru
columns-colour-red = Czerwony
columns-colour-orange = Pomarańczowy
columns-colour-pink = Różowy
columns-colour-pastel-green = Pastelowy zielony
columns-colour-green = Zielony
columns-colour-pastel-blue = Pastelowy niebieski
columns-colour-blue = Niebieski
columns-colour-pastel-yellow = Pastelowy żółty
columns-colour-yellow = Żółty
preferences-leaf-columns = Kolumny tabel
preferences-table-operations-list = Lista operacji
preferences-columns-reset = Przywróć
preferences-columns-reset-all = Przywróć wszystko
preferences-columns-done = Kolumny wróciły do pierwotnego układu.
preferences-columns-hint = Każda tabela zapamiętuje kolejność kolumn, te, które ukrywasz, i ich szerokość. „Przywróć” od razu przywraca jej pierwotny układ.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Przywracanie
preferences-leaf-comfort = Ustawienia wygody
preferences-comfort-reset = Przywróć ustawienia wygody
preferences-comfort-hint = Przywraca kolumny wszystkich tabel, kolejność i pola wyboru kont w oknie startowym oraz rozmiar wyświetlania. Język, waluta i weryfikacja importowanych operacji pozostają bez zmian.
preferences-comfort-question = Przywrócić ustawienia wygody? Kolumny tabel, okno startowe i rozmiar wyświetlania wrócą do pierwotnego stanu.
preferences-comfort-done = Ustawienia wygody zostały przywrócone.

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

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Symulacja kredytu
window-loan-title = Symulacja kredytu
loan-tab-credit = Kredyt
loan-tab-afford = Czy dam radę go spłacić?
loan-field-kind = Rodzaj kredytu
loan-kind-consumer = Kredyt konsumpcyjny
loan-kind-mortgage = Kredyt hipoteczny
loan-field-amount = Kwota kredytu
loan-field-payment = Rata miesięczna
loan-field-months = Okres
loan-field-rate = Stałe oprocentowanie
loan-field-fees = Prowizja
loan-field-insurance = Ubezpieczenie miesięcznie
loan-unit-months = mies.
loan-unit-percent = %
loan-invalid-field = Ta wartość nie jest liczbą: popraw ją, aby ponownie obliczyć.
loan-report-button = Raport PDF
loan-monthly-table = Tabela miesiąc po miesiącu
loan-months-count = { $count ->
        [one] { $count } miesiąc
        [few] { $count } miesiące
        [many] { $count } miesięcy
       *[other] { $count } miesiąca
    }
loan-percent = { $value }%
loan-notice-payment-too-low = Ta rata nie pokrywa odsetek: kredyt nigdy nie zostałby spłacony. Okres pozostaje na 600 miesiącach.
loan-notice-too-long = Ta rata wymagałaby ponad 600 miesięcy: okres pozostaje na 600 miesiącach.
loan-figure-payment = Rata miesięczna
loan-figure-payment-insured = Rata z ubezpieczeniem
loan-figure-taeg = RRSO
loan-figure-interest = Koszt odsetek
loan-figure-insurance = Koszt ubezpieczenia
loan-figure-cost = Całkowity koszt kredytu
loan-figure-total-due = Całkowita kwota do zapłaty
loan-figure-all-in = Razem spłacone, z ubezpieczeniem
loan-part-capital = Kwota kredytu
loan-part-interest = Odsetki
loan-part-fees = Prowizja
loan-part-insurance = Ubezpieczenie
loan-donut-cost-caption = łącznie
loan-chart-cost = Ile kosztuje ten kredyt
loan-chart-capital = Pozostały kapitał
loan-schedule-title = Harmonogram spłaty
loan-schedule-yearly = Harmonogram spłaty, rok po roku
loan-column-number = Nr
loan-column-year = Rok
loan-column-date = Termin
loan-column-payment = Rata
loan-column-payments = Raty
loan-column-interest = Odsetki
loan-column-capital = Kapitał
loan-column-insurance = Ubezpieczenie
loan-column-remaining = Pozostały kapitał
loan-history-label = Badany okres
loan-period-last-12 = Ostatnie 12 miesięcy
loan-accounts-title = Badane konta
loan-period-title = Okres
loan-column-account = Konto
loan-column-bank = Bank
loan-column-balance = Saldo rzeczywiste
loan-unavailable-no-account = Zaznacz co najmniej jedno konto, aby zbadać swoją historię.
loan-unavailable-no-month = Ten okres nie ma jeszcze żadnego pełnego miesiąca: wybierz inny.
loan-verdict-title = W skrócie
loan-verdict-green = Wykonalne
loan-verdict-orange = Na styk
loan-verdict-red = Ryzykowne
loan-verdict-no-income = Brak dochodów w tym okresie: wskaźnika zadłużenia nie da się obliczyć.
loan-check-debt-green = Wskaźnik zadłużenia { $ratio }: poniżej progu { $green } tej metody.
loan-check-debt-orange = Wskaźnik zadłużenia { $ratio }: między { $green } a { $red }, na granicy.
loan-check-debt-red = Wskaźnik zadłużenia { $ratio }: powyżej { $red }.
loan-check-effort = Rata { $payment } pochłania { $share } tego, co odkładasz { $kind ->
        [good] w dobrym miesiącu
        [hard] w trudnym miesiącu
       *[usual] w zwykłym miesiącu
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Dobry miesiąc
        [hard] Trudny miesiąc
       *[usual] Zwykły miesiąc
    } nie zostawia nic na boku: rata { $payment } byłaby brana z Twojej rezerwy.
loan-check-reserve-green = Twoje saldo pozostaje dodatnie do końca kredytu.
loan-check-reserve-red = Z powodu tego kredytu Twoje saldo spadłoby poniżej zera: { $month }.
loan-check-reserve-sooner = Twoje saldo spadłoby poniżej zera ({ $month }) o { $count ->
        [one] { $count } miesiąc
        [few] { $count } miesiące
        [many] { $count } miesięcy
       *[other] { $count } miesiąca
    } wcześniej niż bez tego kredytu.
loan-check-reserve-anyway = Twoje saldo spadłoby poniżej zera nawet bez tego kredytu (około: { $month }); kredyt niewiele zmienia.
loan-check-reserve-floor-green = Twoje saldo pozostaje powyżej rezerwy bezpieczeństwa ({ $floor }) do końca kredytu.
loan-check-reserve-floor-red = Z powodu tego kredytu Twoje saldo spadłoby poniżej rezerwy bezpieczeństwa ({ $floor }): { $month }.
loan-check-reserve-floor-sooner = Twoje saldo spadłoby poniżej rezerwy bezpieczeństwa ({ $floor }; { $month }) o { $count ->
        [one] { $count } miesiąc
        [few] { $count } miesiące
        [many] { $count } miesięcy
       *[other] { $count } miesiąca
    } wcześniej niż bez tego kredytu.
loan-check-reserve-floor-anyway = Twoje saldo spadłoby poniżej rezerwy bezpieczeństwa ({ $floor }) nawet bez tego kredytu (około: { $month }); kredyt niewiele zmienia.
loan-warning-deficit = Uwaga: w tym okresie Twoje wydatki już przekraczają dochody średnio o { $amount } miesięcznie, przed jakimkolwiek kredytem.
loan-figure-reference = Oszczędności { $kind ->
        [good] w dobrym miesiącu
        [hard] w trudnym miesiącu
       *[usual] w zwykłym miesiącu
    }
loan-figure-tipped = Miesiące, które kredyt zepchnąłby na minus
loan-gauge-caption = zadłużenia
loan-figure-income = Średnie dochody miesięcznie
loan-figure-spending = Średnie wydatki miesięcznie
loan-figure-saving = Średnie oszczędności miesięcznie
loan-figure-running = Bieżące kredyty miesięcznie
loan-figure-new = Nowa rata, z ubezpieczeniem
loan-figure-rest = Na życie miesięcznie
loan-figure-debt = Wskaźnik zadłużenia
loan-red-months-value = { $count } z { $total }
loan-figure-balance-now = Saldo rzeczywiste dziś
loan-figure-balance-end = Przewidywane saldo na koniec kredytu
loan-chart-income = Na co idzie Twój średni dochód
loan-donut-income-caption = średni dochód
loan-part-spending = Bieżące wydatki
loan-part-running = Bieżące kredyty
loan-part-new = Nowy kredyt
loan-part-rest = Reszta
loan-part-missing = Brakuje
loan-chart-history = Twoja historia z tym kredytem
loan-chart-history-hint = Co zostałoby w każdym miesiącu po zapłaceniu raty. Jaskrawoczerwone: miesiące, które kredyt zepchnąłby na minus; bladoczerwone: te, które były na minusie już bez niego.
loan-chart-projection = Twoje przewidywane saldo
loan-mark-loan-end = Koniec: { $label }
loan-mark-negative = Na minusie
loan-mark-floor = Poniżej rezerwy
loan-mark-floor-line = Rezerwa bezpieczeństwa
loan-running-title = Uwzględnione bieżące kredyty
loan-running-column-label = Operacja cykliczna
loan-running-column-monthly = Miesięcznie
loan-running-column-end = Ostatnia rata
loan-no-running = Wśród Twoich operacji cyklicznych nie rozpoznano żadnego bieżącego kredytu.
loan-period-caption = { $from } – { $to } ({ $count ->
        [one] { $count } miesiąc
        [few] { $count } miesiące
        [many] { $count } miesięcy
       *[other] { $count } miesiąca
    })
loan-transfers = { $count ->
        [0] Nie rozpoznano żadnego przelewu między zaznaczonymi kontami.
        [one] Rozpoznano i pominięto jeden przelew między zaznaczonymi kontami.
        [few] Rozpoznano i pominięto { $count } przelewy między zaznaczonymi kontami.
        [many] Rozpoznano i pominięto { $count } przelewów między zaznaczonymi kontami.
       *[other] Rozpoznano i pominięto { $count } przelewu między zaznaczonymi kontami.
    }
loan-method = Średnie z pełnych miesięcy okresu, operacje rozliczone i zaksięgowane, bez przelewów między zaznaczonymi kontami.
loan-report-title = Symulacja kredytu
loan-report-made-on = symulacja z { $date }
loan-disclaimer = Symulacja orientacyjna, bez mocy umownej. Wiążąca jest wyłącznie oferta banku.
loan-tab-rules = Ustawienia oceny
loan-method-optimistic = Optymistyczna
loan-method-neutral = Neutralna
loan-method-severe = Surowa
loan-method-line = Metoda oceny: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Ocena odpowiada na trzy pytania, a każda metoda stawia im własne wymagania. Wybierz tę, która do Ciebie pasuje: ocena w zakładce „Czy dam radę go spłacić?” podąża za nią. Ostatni wiersz zakłada, że Twoje wydatki rosną co roku o podany procent; rata się nie zmienia.
loan-rule-row-debt = Akceptowane zadłużenie
loan-rule-row-reference = Oszczędności odniesienia
loan-rule-row-share = Część tych oszczędności, którą może zabrać rata
loan-rule-row-floor = Próg, poniżej którego saldo nie może spaść
loan-rule-row-sooner = Jeśli saldo spada poniżej niego nawet bez kredytu
loan-rule-row-growth = Wzrost Twoich wydatków rocznie
loan-rule-limits = zielony do { $green }, pomarańczowy do { $red }
loan-rule-reference = { $kind ->
        [good] dobry miesiąc
        [hard] trudny miesiąc
       *[usual] zwykły miesiąc
    }: { $amount }
loan-rule-floor-zero = zero
loan-rule-floor-cushion = miesiąc wydatków: { $amount }
loan-rule-sooner = pomarańczowy, jeśli kredyt przyspiesza to o { $orange }, czerwony o { $red }
loan-unit-percent-year = % rocznie
loan-method-optimistic-explain = Metoda optymistyczna zakłada dobry miesiąc, akceptuje zadłużenie do 40% i nie trzyma rezerwy: pokazuje, co jest możliwe, jeśli wszystko pójdzie dobrze.
loan-method-neutral-explain = Metoda neutralna zakłada zwykły miesiąc i stosuje regułę banków, 33–35% zadłużenia: to ocena odniesienia.
loan-method-severe-explain = Metoda surowa zakłada trudny miesiąc i trzyma miesiąc wydatków w rezerwie na nieprzewidziane: pokazuje, co wytrzyma nawet wtedy, gdy sprawy pójdą źle.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Zużycie prądu przez urządzenie elektryczne
window-appliance-title = Zużycie prądu przez urządzenie elektryczne
appliance-device-title = Urządzenie
appliance-on-title = Włączone
appliance-standby-title = W trybie czuwania
appliance-field-on-watts = Moc podczas pracy
appliance-field-on-hours = Czas pracy na dobę
appliance-field-days = Dni użytkowania w tygodniu
appliance-field-share = Udział czasu pracy poza szczytem
appliance-field-standby-watts = Moc w trybie czuwania
appliance-field-standby-hours = Czas czuwania na dzień użytkowania
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = z 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Jeśli pole jest puste, tryb czuwania trwa przez resztę doby. W dni bez użytkowania urządzenie pozostaje podłączone: cały ten czas liczy się jako czuwanie. Po odłączeniu z gniazdka czuwanie wynosi 0 W.
appliance-contract-title = Twoja umowa
appliance-field-option = Taryfa
appliance-option-base = Jednostrefowa (jedna cena)
appliance-option-off-peak = Godziny szczytu / Poza szczytem
appliance-field-base = Cena za kWh
appliance-field-peak = Cena za kWh w godzinach szczytu
appliance-field-off-peak = Cena za kWh poza szczytem
appliance-field-off-peak-hours = Godziny poza szczytem na dobę
appliance-contract-hint = Te ceny dotyczą tylko tego obliczenia. Zapisaną taryfę ustawia się w menu Ustawienia › Preferencje › Narzędzia.
appliance-contract-reset = Przywróć zapisaną taryfę
appliance-period-day = Na dobę
appliance-period-month = Na miesiąc
appliance-period-year = Na rok
appliance-energy = { $value } kWh
appliance-less-than = mniej niż { $amount }
appliance-detail-title = Szczegóły za rok
appliance-column-part = Pozycja
appliance-column-energy = Energia
appliance-column-cost = Koszt
appliance-column-share = Udział
appliance-line-on = Włączone
appliance-line-standby = Tryb czuwania
appliance-line-on-peak = Włączone, godziny szczytu
appliance-line-on-off-peak = Włączone, poza szczytem
appliance-line-standby-peak = Tryb czuwania, godziny szczytu
appliance-line-standby-off-peak = Tryb czuwania, poza szczytem
appliance-line-total = Razem
appliance-chart-title = Na co idą pieniądze
appliance-chart-caption = rocznie
appliance-standby-sentence = Roczny koszt samego trybu czuwania: { $amount }. Udział w koszcie urządzenia: { $share }.
appliance-note-plate = Moc podana na urządzeniu lub w instrukcji to wartość maksymalna: podczas pracy większość urządzeń zużywa mniej. Aby poznać rzeczywistą wartość, zmierz ją watomierzem do gniazdka i wpisz to, co pokazuje.
appliance-note-subscription = Opłaty stałe nie są wliczone: płaci się je niezależnie od tego, czy urządzenie jest podłączone.
appliance-invalid-watts = Podaj moc od 0 do 100 000 W.
appliance-invalid-hours = Podaj czas od 0 do 24 godzin na dobę.
appliance-invalid-days = Podaj całkowitą liczbę dni, od 0 do 7.
appliance-invalid-share = Podaj udział od 0 do 100%.
appliance-invalid-day-overflow = Czas pracy i czuwania przekracza łącznie 24 godziny na dobę.
appliance-invalid-price = Podaj cenę za kWh od 0 do 100.
appliance-invalid-off-peak-hours = Podaj całkowitą liczbę godzin poza szczytem, od 0 do 24.
preferences-branch-tools = Narzędzia
preferences-leaf-electricity = Taryfa za prąd
preferences-electricity-blue = Wróć do taryfy Tarif Bleu EDF
preferences-electricity-hint = Taryfa z Twojej umowy, używana przez narzędzie „Zużycie prądu przez urządzenie elektryczne”. Domyślnie: Tarif Bleu EDF (Francja) według stanu na 1 sierpnia 2026, ceny brutto, moc przyłączeniowa od 3 do 6 kVA. Te ceny często zmieniają się w lutym i sierpniu: przepisz je ze swojego rachunku.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Moja poduszka finansowa
window-cushion-title = Moja poduszka finansowa
cushion-question = Gdyby twoje dochody skończyły się jutro, na ile miesięcy wystarczyłyby ci oszczędności?
cushion-accounts-title = Twoje konta
cushion-column-account = Konto
cushion-column-balance = Saldo rzeczywiste
cushion-column-savings = Oszczędności
cushion-column-spending = Wydatki
cushion-accounts-hint = „Oszczędności”: pieniądze, na które liczysz w razie kłopotów. „Wydatki”: konta, z których idą codzienne wydatki.
cushion-history-label = Analizowany okres
cushion-backup-label = Dochód awaryjny miesięcznie
cushion-backup-hint = To, co nadal by wpływało: zasiłek dla bezrobotnych, pensja partnera… Puste: brak dochodu.
cushion-categories-title = Uwzględnione wydatki
cushion-categories-hint = Odznacz wydatki, które można by obciąć w razie kłopotów.
cushion-categories-empty = Brak wydatków w tym okresie.
cushion-verdict-title = Twoja poduszka
cushion-targets-title = Progi bezpieczeństwa
cushion-projection-title = Twoje oszczędności w razie kłopotów
cushion-projection-hint = Co zostałoby co miesiąc, gdyby twoje dochody skończyły się dziś.
cushion-note = Szacunek na podstawie twojej historii: wydatki w trudnym miesiącu mogą odbiegać od średniej.
cushion-invalid-backup = Tej kwoty nie da się odczytać: popraw ją, aby ponownie uruchomić obliczenia.
cushion-no-spending-account = Zaznacz co najmniej jedno konto „Wydatki”.
cushion-no-month = Ten okres nie zawiera jeszcze żadnego pełnego miesiąca.
cushion-months = { $value } mies.
cushion-per-month = { $amount } miesięcznie
cushion-figure-holds = Bez limitu
cushion-gauge-caption = pokrytych wydatków
cushion-verdict-short = Mniej niż trzy miesiące: nagłe kłopoty szybko postawiłyby cię w trudnej sytuacji.
cushion-verdict-fair = Od trzech do sześciu miesięcy: przyzwoita poduszka, warto ją powiększyć, jeśli możesz.
cushion-verdict-solid = Sześć miesięcy lub więcej: twoja poduszka jest solidna.
cushion-verdict-holds = Twój dochód awaryjny pokrywa wydatki: twoje oszczędności by nie topniały.
cushion-verdict-nothing = Brak uwzględnionych wydatków w tym okresie: nie ma czego pokrywać.
cushion-tile-savings = Dostępne oszczędności
cushion-tile-spending = Uwzględnione wydatki
cushion-tile-backup = Dochód awaryjny
cushion-tile-burn = Oszczędności topniałyby o
cushion-tile-rhythm = Tempo oszczędzania
cushion-burn-none = Nic
cushion-target-title = { $months ->
        [one] { $months } miesiąc
        [few] { $months } miesiące
        [many] { $months } miesięcy
       *[other] { $months } mies.
    } wydatków: { $amount }
cushion-target-reached = Osiągnięty.
cushion-target-date = Brakuje { $missing }. Przy twoim tempie oszczędzania przewidywany termin: { $month }.
cushion-target-never = Brakuje { $missing }. Twoje oszczędności nie wzrosły w tym okresie: w tym tempie ten próg nie zostanie osiągnięty.
cushion-mark-empty = Wyczerpane: { $month }
cushion-period = Średnia z { $count ->
        [one] { $count } pełnego miesiąca
        [few] { $count } pełnych miesięcy
        [many] { $count } pełnych miesięcy
       *[other] { $count } pełnego miesiąca
    }, okres: { $from } – { $to }. { $transfers ->
        [0] Brak przelewów między twoimi kontami.
        [one] Pominięto jeden przelew między twoimi kontami.
        [few] Pominięto { $transfers } przelewy między twoimi kontami.
        [many] Pominięto { $transfers } przelewów między twoimi kontami.
       *[other] Pominięto { $transfers } przelewu między twoimi kontami.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Cel oszczędnościowy
window-goal-title = Cel oszczędnościowy
goal-accounts-title = Śledzone konta
goal-column-account = Konto
goal-column-balance = Saldo rzeczywiste
goal-accounts-hint = Przelew między dwoma śledzonymi kontami się znosi; przelew na konto nieśledzone liczy się jako wypływ pieniędzy.
goal-period-label = Okres odniesienia
goal-period-range = Zakres lat…
goal-range-from = od
goal-range-to = do
goal-question-title = Twoje pytanie
goal-question-when = Kiedy będę mieć tę kwotę?
goal-question-amount = Ile będę mieć w tym dniu?
goal-question-effort = Ile oszczędzać, aby mieć tę kwotę w tym dniu?
goal-field-target = Kwota docelowa
goal-field-date = Data docelowa
goal-field-rate = Roczne oprocentowanie oszczędności
goal-field-extra = A gdyby odkładać więcej, miesięcznie
goal-options-hint = Puste: bez odsetek, nic więcej.
goal-answer-title = Odpowiedź
goal-chart-title = Twoje saldo wczoraj i jutro
goal-chart-hint = Linia ciągła: rzeczywiste saldo z ostatnich dwunastu miesięcy; linia przerywana: prognoza; jasny obszar: przedział zależny od miesięcy.
goal-disclaimer = Prognoza oparta na twojej historii, a nie obietnica: jedno nieprzewidziane zdarzenie może wszystko zmienić.
goal-no-account = Zaznacz co najmniej jedno konto do śledzenia.
goal-no-month = Ten okres nie zawiera jeszcze żadnego pełnego miesiąca.
goal-invalid-target = Podaj kwotę do osiągnięcia.
goal-invalid-date = Wybierz przyszłą datę w ciągu najbliższych pięćdziesięciu lat.
goal-invalid-rate = Podaj oprocentowanie od 0 do 100%.
goal-invalid-extra = Tej kwoty nie da się odczytać: popraw ją, aby ponownie uruchomić obliczenia.
goal-per-month = { $amount } miesięcznie
goal-tile-balance = Saldo dziś
goal-tile-rhythm = Średnie tempo
goal-tile-target = Cel
goal-tile-reached = Przewidywany termin
goal-tile-date = Data docelowa
goal-tile-projected = Prognozowane saldo
goal-tile-saved = Zaoszczędzone do tego czasu
goal-tile-interest = W tym odsetki
goal-tile-needed = Do odłożenia
goal-when-already = Masz już { $amount }: twoje śledzone konta mają łącznie { $balance }.
goal-when-reached = Będziesz mieć { $amount } za { $months ->
        [one] miesiąc
        [few] { $months } miesiące
        [many] { $months } miesięcy
       *[other] { $months } miesiąca
    }; przewidywany termin: { $month }.
goal-when-range = Zależnie od miesięcy przewidywany termin: { $early } – { $late }.
goal-when-range-open = Najwcześniejszy termin: { $early }; przy słabych miesiącach cel nie zostałby osiągnięty.
goal-when-never = W tym tempie nie osiągniesz { $amount }.
goal-zero = Twoje saldo spadłoby do zera; przewidywany termin: { $month }.
goal-amount = Termin: { $month }. Prognozowane saldo: około { $amount }.
goal-amount-range = Zależnie od miesięcy: od { $low } do { $high }.
goal-effort-more = Aby mieć { $amount } (termin: { $month }), trzeba by odkładać średnio { $monthly } miesięcznie, czyli o { $gap } więcej niż obecnie.
goal-effort-less = Aby mieć { $amount } (termin: { $month }), wystarczyłoby { $monthly } miesięcznie, czyli o { $gap } mniej niż obecnie: wyprzedzasz plan.
goal-effort-range = Zależnie od miesięcy różnica względem twojego tempa wynosiłaby od { $low } do { $high } miesięcznie.
goal-chart-target = Cel: { $amount }
goal-chart-today = Dziś
goal-note-seasons = Prognoza uwzględnia pory roku: każdy przyszły miesiąc przyjmuje średnią z tych samych miesięcy w okresie.
goal-note-range = Przedział wynika ze słabych i mocnych miesięcy okresu: najniższej i najwyższej ćwiartki.
goal-note-loan = Ostatni miesiąc kredytu „{ $label }”: { $month }; potem { $amount } więcej miesięcznie.
goal-note-interest = Odsetki naliczane co miesiąc według stopy { $rate }% rocznie: przybliżenie zasady półmiesięcznej stosowanej na kontach oszczędnościowych.
goal-period = Tempo obliczone na podstawie { $count ->
        [one] { $count } pełnego miesiąca
        [few] { $count } pełnych miesięcy
        [many] { $count } pełnych miesięcy
       *[other] { $count } pełnego miesiąca
    }, okres: { $from } – { $to }. { $transfers ->
        [0] Brak przelewów między śledzonymi kontami.
        [one] Pominięto jeden przelew między śledzonymi kontami.
        [few] Pominięto { $transfers } przelewy między śledzonymi kontami.
        [many] Pominięto { $transfers } przelewów między śledzonymi kontami.
       *[other] Pominięto { $transfers } przelewu między śledzonymi kontami.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = A gdyby ograniczyć…?
window-cut-title = A gdyby ograniczyć…?
cut-axis-label = Grupuj według
cut-axis-category = Kategorie
cut-axis-payee = Kontrahenci
cut-axis-budget-line = Pozycje budżetowe
cut-table-title = Twoje wydatki, pozycja po pozycji
cut-table-hint = Wpisz ograniczenie w % lub w { $sign } miesięcznie przy pozycjach, które chcesz zmniejszyć. Ograniczenie nie może przekroczyć samego wydatku.
cut-column-monthly = Miesięcznie
cut-column-cut = Ograniczenie
cut-column-after = Po ograniczeniu
cut-column-yearly = Oszczędność rocznie
cut-total = Razem
cut-horizon-label = Horyzont
cut-settings-title = Ustawienia
cut-options-hint = Oprocentowanie i kwota docelowa są opcjonalne.
cut-report-button = Raport PDF
cut-chart-title = Twoje saldo bez ograniczeń i z nimi
cut-chart-hint = Linia ciągła: rzeczywiste saldo z ostatnich dwunastu miesięcy; szara linia przerywana: prognoza bez ograniczeń; niebieski: z ograniczeniami; zielony: zaoszczędzone pieniądze.
cut-donut-title = Twoje miesięczne wydatki po ograniczeniach
cut-donut-caption = miesięcznie po ograniczeniach
cut-donut-others = Pozostałe pozycje
cut-donut-saved = Zaoszczędzone
cut-legend-with = Z ograniczeniami
cut-legend-without = Bez ograniczeń
cut-years = { $years ->
        [one] { $years } rok
        [few] { $years } lata
        [many] { $years } lat
       *[other] { $years } roku
    }
cut-headline-none = Wpisz ograniczenie w tabeli, aby zobaczyć jego efekt.
cut-headline = Ograniczenie { $count ->
        [one] tej pozycji
        [few] tych { $count } pozycji
        [many] tych { $count } pozycji
       *[other] tych { $count } pozycji
    } pozwoliłoby odkładać dodatkowo { $monthly } miesięcznie, czyli { $yearly } rocznie.
cut-tile-monthly = Oszczędność miesięcznie
cut-tile-yearly = Oszczędność rocznie
cut-tile-horizon = Oszczędność w ciągu { $years ->
        [one] { $years } roku
        [few] { $years } lat
        [many] { $years } lat
       *[other] { $years } roku
    }
cut-tile-spending = Wydatki miesięcznie
cut-target-already = Masz już { $amount }.
cut-target-sooner = Przewidywany termin osiągnięcia kwoty { $amount }: { $with } zamiast { $without }, czyli { $months ->
        [0] nie wcześniej
        [one] miesiąc wcześniej
        [few] { $months } miesiące wcześniej
        [many] { $months } miesięcy wcześniej
       *[other] { $months } miesiąca wcześniej
    }.
cut-target-only-with = Z tymi ograniczeniami kwota { $amount } zostałaby osiągnięta (termin: { $with }); bez nich, w obecnym tempie – nigdy.
cut-target-never = Nawet z tymi ograniczeniami kwota { $amount } nie zostałaby osiągnięta w obecnym tempie.
cut-note-seasons = Każde ograniczenie uwzględnia pory roku swojej pozycji: pozycja, która obciąża budżet głównie latem, przynosi oszczędności głównie latem.
cut-note-capped = Wpisane ograniczenie przekraczało wydatek: zostało zmniejszone do wysokości samego wydatku.
cut-invalid-cut = Tego ograniczenia nie da się odczytać: podaj procent od 0 do 100 lub kwotę miesięcznie.
cut-report-settings = Ustawienia
cut-report-result = Wynik
cut-report-accounts = Śledzone konta

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Zaplanuj wakacje
window-holiday-title = Zaplanuj wakacje
holiday-trip-title = Podróż
holiday-field-trip = Rodzaj podróży
holiday-trip-stay = Pobyt
holiday-trip-cruise = Rejs
holiday-field-adults = Dorośli
holiday-field-children = Dzieci
holiday-field-nights = Długość pobytu w nocach
holiday-field-days = Dni
holiday-field-months = Miesiące do wyjazdu
holiday-field-stops = Liczba postojów w portach
holiday-saved-title = Już zaoszczędzone
holiday-saved-hint = Zaznacz konta, na których pieniądze na wakacje są już odłożone: ich rzeczywiste saldo liczy się jako już zaoszczędzone.
holiday-budget-title = Budżet
holiday-budget-hint = Dla każdej pozycji: kwota, kogo dotyczy i na jak długo. Pusta pozycja nie jest liczona.
holiday-optional-title = Pozycje opcjonalne
holiday-result-title = Wynik
holiday-donut-title = Na co idą pieniądze na podróż
holiday-donut-caption = na podróż
holiday-child-label = Cena za dziecko
holiday-count-label = Kabiny
holiday-open = Otwórz projekt…
holiday-save = Zapisz projekt…
holiday-pdf = Raport PDF
holiday-excel = Eksportuj do Excela
holiday-file-filter = Projekt wakacyjny
holiday-replace-question = Otwarcie tego projektu zastąpi dane wpisane w oknie. Kontynuować?
holiday-file-saved = Zapisano projekt: { $file }
holiday-file-opened = Otwarto projekt: { $file }
holiday-file-not-project = Ten plik nie jest projektem wakacyjnym programu Radinus.
holiday-file-too-recent = Ten projekt pochodzi z nowszej wersji programu Radinus: zaktualizuj Radinus, aby go otworzyć.
holiday-file-failed = Nie udało się odczytać ani zapisać pliku: { $reason }
holiday-line-transport = Transport w obie strony
holiday-line-lodging = Zakwaterowanie
holiday-line-meals = Posiłki i bieżące wydatki
holiday-line-visits = Zwiedzanie i rozrywka
holiday-line-port = Dojazd do portu
holiday-line-cabins = Kabiny
holiday-line-service = Opłata serwisowa (napiwki)
holiday-line-drinks = Pakiet napojów
holiday-line-excursions = Wycieczki w portach
holiday-line-port-taxes = Opłaty portowe
holiday-line-wifi = Wi-Fi na pokładzie
holiday-line-onboard = Wydatki na pokładzie i na lądzie
holiday-line-other = Inne koszty i nieprzewidziane wydatki
holiday-line-insurance = Ubezpieczenie kosztów rezygnacji
holiday-line-stay-tax = Opłata miejscowa
holiday-line-car = Samochód na miejscu, paliwo i opłaty drogowe
holiday-line-parking = Parking na lotnisku lub dworcu
holiday-line-bank = Opłaty bankowe za granicą
holiday-line-formalities = Formalności (paszport, wiza, szczepienia)
holiday-line-pets = Opieka nad zwierzętami
holiday-span-trip = za cały pobyt
holiday-span-night = za noc
holiday-span-day = za dzień
holiday-span-stop = za postój w porcie
holiday-who-all = dla wszystkich
holiday-who-person = na osobę
holiday-who-adults = na dorosłego
holiday-cabins-count = { $count ->
        [one] { $count } kabina
        [few] { $count } kabiny
        [many] { $count } kabin
       *[other] { $count } kabiny
    }
holiday-days = { $days ->
        [one] { $days } dzień
        [few] { $days } dni
        [many] { $days } dni
       *[other] { $days } dnia
    }
holiday-invalid-count = Podaj liczbę całkowitą.
holiday-invalid-amount = Tej kwoty nie da się odczytać: podaj liczbę dodatnią lub procent od 0 do 100.
holiday-headline-empty = Wpisz kwoty budżetu, aby zobaczyć, ile będzie kosztować podróż.
holiday-headline-stay = Ten pobyt kosztowałby { $total } dla { $people ->
        [one] jednej osoby
        [few] { $people } osób
        [many] { $people } osób
       *[other] { $people } osoby
    } { $nights ->
        [0] bez noclegu
        [one] na jedną noc
        [few] na { $nights } noce
        [many] na { $nights } nocy
       *[other] na { $nights } nocy
    }.
holiday-headline-cruise = Ten rejs kosztowałby { $total } dla { $people ->
        [one] jednej osoby
        [few] { $people } osób
        [many] { $people } osób
       *[other] { $people } osoby
    } { $nights ->
        [0] bez noclegu
        [one] na jedną noc
        [few] na { $nights } noce
        [many] na { $nights } nocy
       *[other] na { $nights } nocy
    }.
holiday-tile-total = Koszt całkowity
holiday-tile-person = Na osobę
holiday-tile-person-day = Na osobę dziennie
holiday-tile-saved = Już zaoszczędzone
holiday-tile-remaining = Pozostało do sfinansowania
holiday-tile-monthly = Potrzebne oszczędności
holiday-remaining-none = Nic: wszystko pokryte
holiday-monthly-none = Nie trzeba nic odkładać
holiday-monthly-now = Wyjazd w tym miesiącu
holiday-note-days = Dni to noce plus jeden: siedem nocy daje osiem dni.
holiday-note-child = W przeliczeniu na osobę dziecko płaci cenę za dziecko, jeśli ją podano; jeśli pole jest puste, płaci jak dorosły.
holiday-note-percent = Procent ubezpieczenia dotyczy głównych pozycji podróży; procent opłat bankowych – wydatków na miejscu.
holiday-sheet-budget = Budżet
holiday-sheet-result = Wynik
holiday-column-line = Pozycja
holiday-column-amount = Kwota
holiday-column-child = Cena za dziecko
holiday-column-who = Dla kogo
holiday-column-span = Na jak długo
holiday-column-cost = Koszt
holiday-disclaimer = Szacunek oparty na twoich własnych kwotach: rzeczywiste ceny mogą się różnić.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Projekt ograniczenia wydatków
cut-file-not-project = Ten plik nie jest projektem ograniczenia wydatków programu Radinus.
cut-file-too-recent = Ten projekt pochodzi z nowszej wersji programu Radinus: zaktualizuj Radinus, aby go otworzyć.
cut-sheet-items = Pozycje

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Dziennik mojego samochodu
window-car-title = Dziennik mojego samochodu
car-unnamed = Mój samochód
car-sheet-title = Samochód
car-field-plate = Numer rejestracyjny
car-field-make = Marka
car-field-model = Model
car-field-engine = Napęd
car-field-first-hand = Pierwszy właściciel
car-field-registered = Data pierwszej rejestracji
car-field-acquired = Data nabycia
car-field-acquired-km = Przebieg w chwili nabycia
car-field-service = Przegląd co
car-field-service-or = lub co
car-unit-months-short = mies.
car-unit-km = km
car-tariff-title = Taryfa ładowania w domu
car-tariff-hint = Ta taryfa jest przechowywana w dzienniku samochodu: nie zmienia taryfy ustawionej w preferencjach.
car-tariff-reset = Przywróć taryfę z preferencji
car-engine-petrol = Benzyna
car-engine-diesel = Diesel
car-engine-lpg = LPG
car-engine-e85 = E85 (bioetanol)
car-engine-hybrid = Hybryda
car-engine-plug-in = Hybryda plug-in
car-engine-electric = Elektryczny
car-engine-hydrogen = Wodór
car-energy-petrol = Benzyna
car-energy-diesel = Olej napędowy
car-energy-lpg = LPG
car-energy-e85 = E85
car-energy-electricity = Energia elektryczna
car-energy-hydrogen = Wodór
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energia
car-rubric-upkeep = Bieżąca obsługa
car-rubric-service = Przegląd
car-rubric-wear = Części eksploatacyjne
car-rubric-tyres = Opony
car-rubric-breakdown = Awarie
car-rubric-insurance = Ubezpieczenie
car-rubric-inspection = Badanie techniczne
car-part-brake-pads = Klocki hamulcowe
car-part-brake-discs = Tarcze hamulcowe
car-part-timing-belt = Pasek rozrządu
car-part-clutch = Sprzęgło
car-part-battery-12v = Akumulator 12 V
car-part-shock-absorbers = Amortyzatory
car-part-wipers = Wycieraczki
car-part-spark-plugs = Świece zapłonowe
car-part-glow-plugs = Świece żarowe
car-part-particulate-filter = Filtr cząstek stałych
car-part-catalytic-converter = Katalizator
car-part-fuel-cell-filter = Filtr ogniwa paliwowego
car-part-exhaust = Układ wydechowy
car-part-other = Inna część…
car-axle-all = Wszystkie cztery opony
car-axle-front = Opony przednie
car-axle-rear = Opony tylne
car-verdict-pass = Pozytywny
car-verdict-counter = Ponowne badanie
car-charge-station = Na stacji ładowania
car-charge-home = W domu
car-slot-peak = Godziny szczytu
car-slot-off-peak = Poza szczytem
car-entry-new = Nowy wpis
car-entry-edit = Edytuj wpis
car-field-date = Data
car-field-km = Stan licznika
car-field-rubric = Kategoria
car-field-amount = Kwota
car-field-garage = Warsztat lub stacja
car-field-note = Notatka
car-field-energy = Energia
car-field-quantity = Ilość
car-field-charge = Ładowanie
car-field-slot = Pora ładowania
car-field-part = Część
car-field-part-name = Nazwa części
car-field-axle = Wymienione opony
car-field-verdict = Wynik
car-field-months = Liczba objętych miesięcy
car-field-battery = Stan baterii
car-home-amount-hint = Kwota ładowania w domu jest obliczana według taryfy samochodu.
car-entry-add = Dodaj do dziennika
car-entry-update = Zapisz wpis
car-entry-cancel = Anuluj
car-entry-delete = Usuń wpis
car-delete-question = Usunąć ten wpis z dziennika?
car-from-operation = Pobierz operację…
car-pick-account = Z którego konta pochodzi wydatek?
car-pick-operation = Która operacja?
car-pick-take = Pobierz
car-pick-none = Brak wydatków na tym koncie.
car-pick-taken = Operacja pobrana: uzupełnij stan licznika i kategorię, a następnie dodaj wpis.
car-history-title = Historia
car-filter-all = Wszystkie kategorie
car-history-empty = Na razie brak wpisów.
car-history-hint = Kliknij wpis, aby go edytować.
car-column-date = Data
car-column-km = Km
car-column-rubric = Kategoria
car-column-detail = Szczegóły
car-column-amount = Kwota
car-column-garage = Warsztat
car-column-note = Notatka
car-column-share = Udział
car-column-per-km = Za km
car-column-energy = Energia
car-column-quantity = Ilość
car-column-price = Średnia cena
car-column-consumption = Zużycie
car-column-part = Część
car-column-changes = Wymiany
car-column-last = Ostatnia wymiana
car-column-life = Trwałość
car-column-next = Następna wymiana
car-total = Razem
car-summary-title = Ile kosztuje samochód
car-headline-empty = Wypełnij kartę samochodu, a następnie dodaj pierwszy wpis: tankowanie, przegląd, rachunek z warsztatu…
car-headline = Od { $since } samochód kosztował cię { $total }.
car-headline-km = Od { $since } samochód kosztował cię { $total }, przejechany dystans: { $km }, czyli { $cost } za kilometr.
car-tile-total = Koszt całkowity
car-tile-month = Miesięcznie
car-tile-km = Za kilometr
car-tile-driven = Przejechane kilometry
car-tile-consumption = Zużycie
car-tile-energy-km = Energia na kilometr
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } miesiąc
        [few] { $months } miesiące
        [many] { $months } miesięcy
       *[other] { $months } miesiąca
    }
car-detail-battery = Bateria: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Według kategorii
car-energy-title = Energia
car-parts-title = Części eksploatacyjne
car-tyres-title = Opony
car-battery-title = Stan baterii
car-years-title = Ile samochód kosztował w poszczególnych latach
car-donut-title = Na co idą pieniądze
car-donut-caption = łącznie
car-deadlines-title = Terminy
car-deadlines-empty = Na razie brak terminów: zanotuj przegląd, badanie techniczne, ubezpieczenie albo dwie wymiany tej samej części.
car-deadline-service = Przegląd
car-deadline-inspection = Badanie techniczne
car-deadline-counter = Ponowne badanie techniczne
car-deadline-insurance = Koniec ubezpieczenia
car-when-date = dnia { $date }
car-when-km = przy przebiegu { $km }
car-when-km-reached = przy przebiegu { $km }; w obecnym tempie przewidywany termin: { $month }
car-when-date-km = dnia { $date } lub przy przebiegu { $km }, zależnie od tego, co nastąpi wcześniej
car-when-inspection-unknown = Zanotuj ostatnie badanie techniczne, aby poznać termin następnego.
car-tone-late = Po terminie
car-tone-soon = Wkrótce
car-note-since = Wszystko liczy się od nabycia: od daty i stanu licznika zapisanych w karcie samochodu.
car-note-consumption = Zużycie mierzy się od pełnego baku do pełnego baku: tankuj zawsze do pełna i za każdym razem zapisuj stan licznika.
car-note-e85 = Samochód na E85 pije to, co dostanie: kilometry przejechane po tankowaniu liczą się dla tego paliwa.
car-note-home = Ładowanie w domu jest wyceniane według taryfy samochodu z dnia, w którym zostało zapisane, i zachowuje ten koszt.
car-note-inspection = Badanie techniczne odbywa się według zasady francuskiej: pierwsze w ciągu czterech lat od pierwszej rejestracji, potem co dwa lata; ponowne badanie w ciągu dwóch miesięcy.
car-disclaimer = Terminy i trwałość części to szacunki oparte na dzienniku: wiążąca jest wyłącznie książka serwisowa producenta.
car-invalid-date = Podaj prawidłową datę, która nie jest z przyszłości.
car-invalid-acquired = Data nabycia nie może być wcześniejsza niż data pierwszej rejestracji.
car-invalid-km = Podaj stan licznika w pełnych kilometrach.
car-invalid-amount = Tej kwoty nie da się odczytać.
car-invalid-quantity = Wpisz ilość: litry, kWh lub kilogramy.
car-invalid-part = Wybierz wymienioną część albo wpisz jej nazwę.
car-invalid-rubric = Wybierz kategorię.
car-invalid-months = Podaj liczbę miesięcy jako liczbę całkowitą.
car-invalid-battery = Podaj stan baterii od 0 do 100 %.
car-open = Otwórz dziennik…
car-save = Zapisz dziennik…
car-report-button = Raport PDF
car-file-filter = Dziennik samochodu
car-file-saved = Zapisano dziennik: { $file }
car-file-opened = Otwarto dziennik: { $file }
car-file-not-logbook = Ten plik nie jest dziennikiem samochodu programu Radinus.
car-file-too-recent = Ten dziennik pochodzi z nowszej wersji programu Radinus: zaktualizuj Radinus, aby go otworzyć.
car-replace-question = Otwarcie tego dziennika zastąpi dziennik w oknie. Kontynuować?
car-sheet-history = Dziennik
car-sheet-summary = Podsumowanie

analysis-history-hint = Im dłuższa Twoja historia, tym lepsza będzie ta analiza: najlepiej mieć co najmniej rok operacji.

# --- F48 — Podziel wydatek (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Podziel wydatek
window-sharing-title = Podział wydatku
sharing-question = Kto ile płaci?
sharing-setup-title = Podział
sharing-field-label = Nazwa
sharing-label-hint = Na przykład „Restauracja z 12/10” lub „Wyjazd do Bretanii 2027”: nazwa określa nazwy plików i raportów.
sharing-field-total = Suma
sharing-total-hint = Jeśli pole jest puste, suma to łączna wartość pozycji oraz dodatków własnych każdego.
sharing-field-rule = Reguła
sharing-field-rounding = Zaokrąglenie
sharing-field-people = Osoby
sharing-mode-whole = Jedna reguła dla całego wydatku
sharing-mode-item = Jedna reguła na pozycję
sharing-rule-equal = Równe części
sharing-rule-parts = Według części
sharing-rule-percent = W procentach
sharing-rule-income = Proporcjonalnie do dochodów
sharing-rounding-cent = Do centa
sharing-rounding-euro = Do pełnej jednostki
sharing-round-euro = Zaokrąglij do pełnych jednostek
sharing-hide-incomes = Ukryj dochody w raportach i w eksporcie
sharing-people-title = Osoby
sharing-people-hint = Jeden wiersz na osobę, jedna kolumna na pozycję: zaznacz, kto w czym uczestniczy. Cała reszta jest opcjonalna. Ktoś, kto się wycofuje, zostawiając zaliczkę: kwota dokładna równa wpłaconej i żadne pole niezaznaczone.
sharing-add-person = Dodaj osobę
sharing-person-default = Osoba { $number }
sharing-items-title = Pozycje
sharing-items-hint = Tylko to, co nie dotyczy wszystkich, na przykład wino. Reszta sumy trafia do pozycji wspólnej.
sharing-add-item = Dodaj pozycję
sharing-common = Wspólna
sharing-payments-title = Wpłaty
sharing-payments-hint = Kto zapłacił, ile i kiedy. Wiersz bez kwoty jeszcze się nie liczy.
sharing-payments-none = Na razie brak wpłat.
sharing-add-payment = Dodaj wpłatę
sharing-result-title = Wynik
sharing-balances-title = Stan wpłat
sharing-transfers-title = Proponowane przelewy
sharing-delete = Usuń
sharing-delete-person-question = Ta osoba ma wpłaty: usunąć je razem z nią?
sharing-disclaimer = Radinus proponuje podział: między przyjaciółmi każdy może się rozliczyć inaczej.
sharing-column-person = Osoba
sharing-column-household = Gospodarstwo domowe
sharing-column-income = Dochód
sharing-column-parts = Części
sharing-column-percent = %
sharing-column-floor = Co najmniej
sharing-column-cap = Co najwyżej
sharing-column-fixed = Kwota dokładna
sharing-column-alone = Dodatki własne
sharing-column-gift = Oddana nadwyżka
sharing-column-share = Udział
sharing-column-typed = Wpisany %
sharing-column-constraint = Co zadziałało
sharing-column-due = Do zapłaty
sharing-column-item = Pozycja
sharing-column-amount = Kwota
sharing-column-rule = Reguła
sharing-column-participants = Uczestnicy
sharing-column-unit = Gospodarstwo lub osoba
sharing-column-members = Członkowie
sharing-column-paid = Wpłacono
sharing-column-balance = Saldo
sharing-column-date = Data
sharing-column-who = Kto
sharing-column-label = Nazwa
sharing-help-household = Osoby z tego samego gospodarstwa domowego rozliczają się razem: ich wpłaty i to, co są winne, są sumowane, a one dostają jedno rozliczenie. Przykład: „Rodzina Martin” dla rodziców i dzieci.
sharing-help-income = Używany tylko przez regułę „Proporcjonalnie do dochodów”: im wyższy dochód, tym większy udział. Wpisz dochód miesięczny.
sharing-help-parts = Osoba z 2 częściami płaci dwa razy więcej niż osoba z 1 częścią. Przykład: dorosły 1, dziecko 0,5.
sharing-help-percent = Jaką część wydatku płaci osoba. Procenty muszą dawać łącznie 100%.
sharing-help-floor = Osoba zapłaci co najmniej tę kwotę, nawet jeśli obliczony udział jest mniejszy. Różnica zmniejsza obciążenie pozostałych.
sharing-help-cap = Osoba nigdy nie zapłaci więcej niż ta kwota. To, czego nie płaci, spada na pozostałych uczestników jej pozycji.
sharing-help-fixed = Osoba płaci tę kwotę, cokolwiek się stanie, a reszta jest dzielona między pozostałych. Przykład: ktoś, kto się wycofuje i zostawia zaliczkę.
sharing-help-alone = To, co osoba wzięła tylko dla siebie, na przykład deser lub kawę. Płaci to w całości, oprócz swojego udziału.
sharing-help-gift = Jeśli osoba wpłaciła więcej niż jej udział: zaznaczone oznacza, że nadwyżka jest darem dla grupy; niezaznaczone, że zostanie jej zwrócona.
sharing-help-items = Zaznacz osoby, które uczestniczą w tej pozycji. Pozycja wspólna to to, co zostaje z sumy po odjęciu pozostałych pozycji.
sharing-help-due = Ile osoba jest winna łącznie: jej udział w pozycjach, dodatki własne i zaokrąglenie.
sharing-help-share = Jaki procent sumy do podziału stanowi jej udział.
sharing-help-typed = Procent, który wpisano. Może się różnić od rzeczywistego udziału, gdy zadziałało minimum, maksimum lub kwota dokładna.
sharing-help-constraint = Pokazuje, czy udział osoby został zmieniony przez minimum, maksimum, kwotę dokładną lub oddaną nadwyżkę.
sharing-help-item = Tylko to, co nie dotyczy wszystkich, na przykład wino. Reszta sumy trafia do pozycji wspólnej, dzielonej między zaznaczonych w niej.
sharing-help-rule = Jak dzielona jest ta pozycja: na równe części, według części, w procentach lub proporcjonalnie do dochodów.
sharing-help-paid = Ile gospodarstwo domowe lub osoba już wpłaciła, według wpisanych wpłat.
sharing-help-balance = Ile jeszcze zostało do zapłaty lub ile wpłacono ponad udział. Przykład: „Pozostało do wpłaty: 61,54 €”.
sharing-advice-equal = { $count ->
        [one] { $total } dla jednej osoby.
        [few] { $total } ÷ { $count } osoby = { $amount } na osobę.
        [many] { $total } ÷ { $count } osób = { $amount } na osobę.
       *[other] { $total } ÷ { $count } osoby = { $amount } na osobę.
    }
sharing-advice-equal-varied = Po równo między osobami, które uczestniczą, z uwzględnieniem limitów i wykluczeń.
sharing-advice-parts = Łącznie { $parts } części: jedna część to { $amount }.
sharing-advice-parts-varied = Każdy płaci według swoich części, z uwzględnieniem limitów i wykluczeń. Puste pole liczy się jako 1 część.
sharing-advice-percent-rest = Brakuje { $rest }%, aby było 100%.
sharing-advice-percent-over = Procenty przekraczają 100% o { $over }%.
sharing-advice-percent-ok = Procenty dają łącznie 100%.
sharing-advice-percent-nobody = Procenty dają już łącznie 100%: { $count ->
        [one] { $names } nic nie zapłaci.
        [few] { $names } nic nie zapłacą.
        [many] { $names } nic nie zapłacą.
       *[other] { $names } nic nie zapłacą.
    }
sharing-advice-income = Każdy płaci { $rate }% swojego dochodu.
sharing-advice-income-missing = Wpisz dochód każdej osoby, aby podzielić proporcjonalnie do dochodów.
sharing-advice-income-varied = Każdy płaci taką samą część swojego dochodu, z uwzględnieniem limitów i wykluczeń.
sharing-advice-empty = Wpisz kwotę do podziału.
sharing-apply-advice = Użyj proponowanych wartości
sharing-help-apply-advice = Wypełnia puste pola wartościami pokazanymi na szaro. Pola już wypełnione się nie zmieniają.
sharing-from-incomes = Procenty według dochodów
sharing-help-from-incomes = Zastępuje procenty udziałem dochodu każdej osoby w sumie wszystkich dochodów. Dają łącznie 100%.
sharing-reset-percents = Rozdziel wszystko od nowa
sharing-help-reset-percents = Usuwa procenty i rozdziela je po równo między wszystkich. Przydatne po dodaniu osoby.
sharing-reset-percents-question = Usunąć wszystkie procenty i rozdzielić je po równo?
sharing-open = Otwórz projekt…
sharing-save = Zapisz projekt…
sharing-pdf-distribution = Podział (PDF)
sharing-pdf-payments = Stan wpłat (PDF)
sharing-pdf-statements = Rozliczenia indywidualne (PDF)…
sharing-statements-everyone = Wszyscy
sharing-excel = Eksportuj do Excela
sharing-file-filter = Projekt podziału
sharing-replace-question = Otwarcie tego projektu zastąpi dane wpisane w oknie. Kontynuować?
sharing-file-saved = Zapisano projekt: { $file }
sharing-file-opened = Otwarto projekt: { $file }
sharing-file-not-project = Ten plik nie jest projektem podziału wydatku programu Radinus.
sharing-file-too-recent = Ten projekt pochodzi z nowszej wersji programu Radinus: zaktualizuj Radinus, aby go otworzyć.
sharing-file-failed = Nie udało się odczytać ani zapisać pliku: { $reason }
sharing-statements-replace-question = { $count ->
        [one] W tym folderze istnieje już jedno rozliczenie. Zastąpić je?
        [few] W tym folderze istnieją już { $count } rozliczenia. Zastąpić je?
        [many] W tym folderze istnieje już { $count } rozliczeń. Zastąpić je?
       *[other] W tym folderze istnieje już { $count } rozliczenia. Zastąpić je?
    }
sharing-statements-written = { $count ->
        [one] Zapisano jedno rozliczenie w „{ $folder }”.
        [few] Zapisano { $count } rozliczenia w „{ $folder }”.
        [many] Zapisano { $count } rozliczeń w „{ $folder }”.
       *[other] Zapisano { $count } rozliczenia w „{ $folder }”.
    }
sharing-too-many-people = Podział obejmuje najwyżej 40 osób.
sharing-too-many-items = Podział obejmuje najwyżej 20 pozycji.
sharing-too-many-payments = Podział obejmuje najwyżej 400 wpłat.
sharing-invalid-amount = Nie można odczytać tej kwoty: wpisz liczbę dodatnią.
sharing-invalid-number = Nie można odczytać tej liczby: wpisz liczbę dodatnią.
sharing-invalid-percent = Procent mieści się w zakresie od 0 do 100.
sharing-invalid-date = Nie można odczytać tej daty.
sharing-name-missing = Każda osoba musi mieć nazwę.
sharing-name-duplicate = „{ $name }” już istnieje: rozróżnij je, na przykład inicjałem.
sharing-floor-above-cap = Minimum przekracza maksimum.
sharing-item-label-missing = Ta pozycja nie ma nazwy.
sharing-items-above-total = Pozycje oraz dodatki własne każdego przekraczają sumę o { $amount }.
sharing-payment-person = Wybierz, kto zapłacił.
sharing-percent-total = Procenty dają łącznie { $sum }%: powinno być 100%.
sharing-percent-total-item = „{ $item }”: procenty dają łącznie { $sum }%: powinno być 100%.
sharing-item-nobody = Nikt nie uczestniczy w „{ $item }”.
sharing-item-no-weight = Nikt nie ma wagi w „{ $item }”: wszyscy uczestnicy mają zero.
sharing-income-missing = Brakuje dochodu osoby { $name }.
sharing-fixed-above = Kwoty dokładne przekraczają sumę do podziału o { $amount }.
sharing-floors-above = Minima przekraczają sumę do podziału o { $amount }.
sharing-cap-alone = W „{ $item }” uczestniczy tylko { $name }: maksimum nie może zostać zachowane.
sharing-caps-short = Maksima nie wystarczają do pokrycia sumy: brakuje { $amount }.
sharing-impossible = Nie da się spełnić wszystkich tych warunków: poluzuj minimum lub maksimum.
sharing-constraint-floor = Osiągnięte minimum
sharing-constraint-cap = Osiągnięte maksimum
sharing-constraint-fixed = Kwota dokładna
sharing-constraint-gift = Oddana nadwyżka
sharing-and = { $first } i { $last }
sharing-outside = Poza pozycjami
sharing-alone = Dodatki własne
sharing-rounding = Zaokrąglenie
sharing-headline-empty = Dodaj osoby, które dzielą wydatek.
sharing-headline-no-amount = Wpisz sumę lub pozycje do podziału.
sharing-headline-equal = { $total } do podziału: każdy płaci { $amount }.
sharing-headline-range = { $total } do podziału: od { $min } do { $max } w zależności od osoby.
sharing-participants = { $count ->
        [0] Brak uczestników
        [one] Jeden uczestnik
        [few] { $count } uczestników
        [many] { $count } uczestników
       *[other] { $count } uczestnika
    }
sharing-balance-due = Pozostało do wpłaty: { $amount }
sharing-balance-over = Wpłacono o { $amount } więcej niż wynosi udział
sharing-balance-even = Rozliczone
sharing-summary-collected = Wpłacono { $collected } z { $total }.
sharing-summary-owing = { $count ->
        [0] Wszyscy są rozliczeni.
        [one] Tylko jedna osoba jest jeszcze winna { $amount }.
        [few] { $count } osoby są jeszcze winne łącznie { $amount }.
        [many] { $count } osób jest jeszcze winnych łącznie { $amount }.
       *[other] { $count } osoby są jeszcze winne łącznie { $amount }.
    }
sharing-remaining-outside = Pozostało do zapłaty z wydatku: { $amount }
sharing-remaining-reimburse = Do zwrotu (dla: { $name }): { $amount }
sharing-all-settled = Wszystko rozliczone: nikt nikomu nic nie jest winien.
sharing-transfer = { $from } przelewa { $amount } do { $to }
sharing-warning-over-paid = Wpłaty przekraczają wydatek o { $amount }: sprawdź kwoty.
sharing-note-income-zero = { $name } nic nie płaci w pozycjach: { $items }, bo dochód wynosi 0.
sharing-note-excluded = { $name } nie uczestniczy w „{ $item }”: odpowiedni udział jest rozdzielany między pozostałych.
sharing-note-gift = Nadwyżka od { $giver } zmniejsza udział pozostałych: wpłaty { $name } przekraczają teraz należny udział.
sharing-note-outside = { $name } płaci { $amount } poza swoimi pozycjami: ta suma jest odejmowana od tego, co dzielą pozostali.
sharing-note-keeper = Zaokrąglono do pełnych jednostek: { $name } zatrzymuje drobne, aby suma zgadzała się co do grosza.
sharing-report-distribution = Podział
sharing-report-sharing = Podział
sharing-report-who-pays = Kto ile płaci
sharing-report-items = Szczegóły według pozycji
sharing-report-payments = Stan wpłat
sharing-report-as-of = Stan na { $date }
sharing-report-balances = Udział, wpłacono, saldo
sharing-report-statement = Rozliczenie — { $name }
sharing-report-your-share = Twój udział
sharing-statement-total = Razem dla gospodarstwa domowego: { $amount }
sharing-statement-pay = Do przekazania (odbiorca: { $name }): { $amount }
sharing-statement-receive = Do otrzymania (od: { $name }): { $amount }
sharing-sheet-people = Osoby
sharing-sheet-items = Pozycje
sharing-sheet-result = Wynik
sharing-sheet-payments = Wpłaty
sharing-sheet-balances = Zwroty

## Kreator eksportu bazy (P-74, Fabrice, 19/10/2026).
window-database-export-title = Kreator eksportu bazy „{ $base }”
menu-tools-export = Kreator eksportu bazy…
base-export-only-this = Wyeksportowana zostanie tylko baza „{ $base }”, zaznaczona na liście. Pozostałe bazy nie zostaną naruszone.
base-export-purpose = Ten kreator kopiuje dane bazy do plików, które potrafią odczytać inne programy: arkusz kalkulacyjny, baza danych taka jak Access, inny program do finansów osobistych. Sama baza nie zostaje zmieniona.
base-export-step-format = 1. Format
base-export-step-options = 2. Opcje
base-export-step-place = 3. Miejsce zapisu
base-export-step-summary = 4. Podsumowanie
base-export-format-xlsx = Excel (.xlsx)
base-export-format-xlsx-hint = Skoroszyt z jednym arkuszem na każdą tabelę, który otworzy Excel i większość arkuszy kalkulacyjnych.
base-export-format-ods = Calc (.ods)
base-export-format-ods-hint = Otwarty format LibreOffice i OpenOffice, z jednym arkuszem na każdą tabelę.
base-export-format-csv = CSV (.csv)
base-export-format-csv-hint = Jeden plik tekstowy na każdą tabelę, wartości rozdzielone średnikami: format, który potrafi zaimportować niemal każdy program, łącznie z Accessem.
base-export-format-json = JSON (.json)
base-export-format-json-hint = Dla programistów i aplikacji: każda tabela pod własną nazwą, z nagłówkiem opisującym eksport.
base-export-format-xml = XML (.xml)
base-export-format-xml-hint = Ta sama zawartość co w JSON, zapisana w XML.
base-export-format-sql = Skrypt SQL (.sql)
base-export-format-sql-hint = Polecenia, które odtwarzają tabele i ich dane w innej bazie danych (MySQL, PostgreSQL, SQLite…).
base-export-format-sqlite = Baza SQLite (.sqlite)
base-export-format-sqlite-hint = Samodzielna baza danych, bez hasła, którą wiele narzędzi otwiera bezpośrednio.
base-export-format-qif = QIF, jeden plik na konto (.qif)
base-export-format-qif-hint = Aby przenieść swoje konta do innego programu do finansów osobistych (Money, Quicken, GnuCash, Grisbi…).
base-export-format-ofx = OFX, jeden plik na konto (.ofx)
base-export-format-ofx-hint = Format wyciągów bankowych, który potrafi zaimportować większość programów do finansów osobistych.
base-export-lossy = Uwaga: QIF i OFX nie potrafią przenieść wszystkiego. Przechodzą tylko operacje na kontach, wraz z kontrahentami, kategoriami i komentarzami; przelew staje się zwykłą operacją po każdej stronie, a cała reszta (budżety, harmonogramy, projekty, przeznaczenia…) zostaje pominięta. Aby zachować wszystko, wybierz inny format.
base-export-planned-note = Operacje planowane i operacje bez daty nie są eksportowane: nie przeszły jeszcze przez bank. Ich liczba zostanie podana na końcu.
base-export-dates-hint = Daty są zapisywane w kolejności rok-miesiąc-dzień (2026-12-31), a kwoty w walucie bazy: żaden program nie odczyta ich błędnie.
base-export-group-layout = Pliki
base-export-layout-one = Wszystko w jednym pliku
base-export-layout-per-table = Jeden plik na każdą tabelę, w folderze
base-export-group-decimal = Separator dziesiętny w kwotach
base-export-decimal-point = Kropka (1234.56)
base-export-decimal-comma = Przecinek (1234,56)
base-export-group-quotes = Cudzysłowy
base-export-quotes-all = Każda wartość w cudzysłowie
base-export-quotes-none = Bez cudzysłowów
base-export-csv-replacements-hint = Aby każdy plik dał się odczytać bez błędów, średnik w tekście zamienia się w wykrzyknik, przejście do nowej linii w spację, a przy braku cudzysłowów cudzysłów zamienia się w apostrof. Liczba zamian zostanie podana na końcu.
base-export-group-qif-order = Kolejność w datach
base-export-qif-day-month = Dzień przed miesiącem (31/12/2026)
base-export-qif-month-day = Miesiąc przed dniem (12/31/2026)
base-export-qif-order-hint = Wybierz kolejność, której oczekuje program, który odczyta pliki: w Europie najpierw dzień, w Stanach Zjednoczonych najpierw miesiąc.
base-export-no-option = Ten format nie ma żadnych opcji.
base-export-choose-file = Wybierz plik…
base-export-choose-folder = Wybierz folder…
base-export-place-file = Eksport zostanie zapisany w tym pliku:
base-export-place-folder = Eksport zostanie zapisany w tym folderze, utworzonym specjalnie w tym celu:
base-export-place-none = Nie wybrano jeszcze miejsca zapisu.
base-export-place-needed = Najpierw wybierz, gdzie zapisać eksport.
base-export-folder-exists = Folder „{ $name }” już istnieje. Znajdujące się w nim pliki o tej samej nazwie zostaną zastąpione. Kontynuować?
base-export-summary-base = Baza
base-export-summary-format = Format
base-export-summary-options = Opcje
base-export-summary-place = Miejsce zapisu
base-export-unprotected = Ta baza jest chroniona hasłem, ale eksport już nie będzie: każdy, kto zdobędzie te pliki, będzie mógł przeczytać Twoje konta. Przechowuj je w bezpiecznym miejscu.
base-export-previous = Wstecz
base-export-next = Dalej
base-export-run = Eksportuj
base-export-running = Trwa eksport…
base-export-done = Baza „{ $base }” została wyeksportowana: { $tables ->
        [one] { $tables } tabela
        [few] { $tables } tabele
        [many] { $tables } tabel
       *[other] { $tables } tabeli
    }, { $rows ->
        [one] { $rows } wiersz
        [few] { $rows } wiersze
        [many] { $rows } wierszy
       *[other] { $rows } wiersza
    }.
base-export-done-accounts = Baza „{ $base }” została wyeksportowana: { $accounts ->
        [one] { $accounts } konto
        [few] { $accounts } konta
        [many] { $accounts } kont
       *[other] { $accounts } konta
    }, { $operations ->
        [one] { $operations } operacja
        [few] { $operations } operacje
        [many] { $operations } operacji
       *[other] { $operations } operacji
    }.
base-export-done-replacements = { $count ->
        [one] Zastąpiono { $count } znak w plikach CSV.
        [few] Zastąpiono { $count } znaki w plikach CSV.
        [many] Zastąpiono { $count } znaków w plikach CSV.
       *[other] Zastąpiono { $count } znaku w plikach CSV.
    }
base-export-done-controls = { $count ->
        [one] Zastąpiono znakiem „�” { $count } znak sterujący, którego ten format nie może zawierać.
        [few] Zastąpiono znakiem „�” { $count } znaki sterujące, których ten format nie może zawierać.
        [many] Zastąpiono znakiem „�” { $count } znaków sterujących, których ten format nie może zawierać.
       *[other] Zastąpiono znakiem „�” { $count } znaku sterującego, którego ten format nie może zawierać.
    }
base-export-done-excel-cut = { $count ->
        [one] Obcięto w skoroszycie { $count } tekst dłuższy niż 32 767 znaków (limit Excela). Pozostałe formaty zachowują go w całości.
        [few] Obcięto w skoroszycie { $count } teksty dłuższe niż 32 767 znaków (limit Excela). Pozostałe formaty zachowują je w całości.
        [many] Obcięto w skoroszycie { $count } tekstów dłuższych niż 32 767 znaków (limit Excela). Pozostałe formaty zachowują je w całości.
       *[other] Obcięto w skoroszycie { $count } tekstu dłuższego niż 32 767 znaków (limit Excela). Pozostałe formaty zachowują go w całości.
    }
base-export-done-anomalies = { $count ->
        [one] Skopiowano bez zmian { $count } nieczytelną wartość.
        [few] Skopiowano bez zmian { $count } nieczytelne wartości.
        [many] Skopiowano bez zmian { $count } nieczytelnych wartości.
       *[other] Skopiowano bez zmian { $count } nieczytelnej wartości.
    }
base-export-done-planned = { $count ->
        [one] Pominięto { $count } operację planowaną.
        [few] Pominięto { $count } operacje planowane.
        [many] Pominięto { $count } operacji planowanych.
       *[other] Pominięto { $count } operacji planowanej.
    }
base-export-done-undated = { $count ->
        [one] Pominięto { $count } operację bez daty.
        [few] Pominięto { $count } operacje bez daty.
        [many] Pominięto { $count } operacji bez daty.
       *[other] Pominięto { $count } operacji bez daty.
    }
base-export-done-adjusted = { $count ->
        [one] Dostosowano do formatu { $count } wartość.
        [few] Dostosowano do formatu { $count } wartości.
        [many] Dostosowano do formatu { $count } wartości.
       *[other] Dostosowano do formatu { $count } wartości.
    }
base-export-too-old = Ta baza pochodzi ze starszej wersji programu Radinus. Najpierw otwórz ją raz w programie Radinus, który ją zaktualizuje, a potem wyeksportuj.
base-export-too-recent = Ta baza została zapisana przez nowszą wersję programu Radinus. Zaktualizuj program Radinus, aby ją wyeksportować.
base-export-not-radinus = Ten plik nie jest bazą programu Radinus.
base-export-failed = Nie udało się wykonać eksportu: { $reason }

## Menu Narzędzia okna baz podaje nazwę bazy (Fabrice, 19/10/2026).
databases-tools-selected = Wybrana baza: „{ $base }”
databases-tools-none = Nie wybrano żadnej bazy
menu-tools-backup = Utwórz kopię zapasową bazy „{ $base }”…
menu-tools-backup-none = Utwórz kopię zapasową wybranej bazy…
menu-tools-restore = Przywróć bazę „{ $base }”…
menu-tools-restore-none = Przywróć wybraną bazę…
menu-tools-repair = Napraw i zoptymalizuj bazę „{ $base }”…
menu-tools-repair-none = Napraw i zoptymalizuj wybraną bazę…
