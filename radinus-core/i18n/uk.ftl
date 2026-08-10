# Radinus — повідомлення ядра (Fluent), українська.
# Заповнюється поступово, у міру реалізації модулів ядра, які видають
# повідомлення користувачеві. Див. 08_ARCHITECTURE.md §2.1.

# Службове «0 = Не вказано», яке використовує кожне необов'язкове посилання
# на довідник (02_BASE_DE_DONNEES.md §7 rule 2). Перший рядок кожного списку.
# ---------------------------------------------------------------------
# Назва мови, написана її власною мовою.
#
# Саме її показують меню «Налаштування» та вибір мови під час першого
# запуску (01_CAHIER_DES_CHARGES.md §3.5: «кожна мова написана власною
# мовою»). Вона тут, а не в коді, бо це єдине місце, де вона може бути
# правильною: додати мову — це покласти файл, який уміє себе назвати.
# ---------------------------------------------------------------------
language-name = Українська

nomenclature-unspecified = Не вказано

# Запитується перед видаленням елемента довідника, який ще використовують
# операції (02_BASE_DE_DONNEES.md §7 rule 5). Відтворено слово в слово з
# початкового коду WinDev (Enreg_Supprimer), разом із типографікою — це
# формулювання автора, а не переклад.
nomenclature-delete-confirm = Виявлено операції (банківські транзакції), що мають атрибут типу '{ $label }'. Ви підтверджуєте, що хочете скинути цей атрибут?

# Запитується перед видаленням елемента довідника, який ніде не
# використовується. Оригінал видаляв такий елемент одразу, без жодного слова;
# 25/07/2026 Fabrice попросив, щоб видалення завжди підтверджувалося, — свідомий
# відступ від його ж коду, єдиний у цьому модулі.
nomenclature-delete-plain = Ви підтверджуєте видалення «{ $label }»?

# Відмова, яку показують, коли елемент, що його збираються видалити, — саме
# той, який показує його картка. Рішення Fabrice від 25/07/2026: елемент не
# видаляють з-під його ж відкритої картки — спочатку картку закривають, а не
# лишають її показувати запис, якого більше немає.
nomenclature-delete-form-open = Картка «{ $label }» відкрита. Закрийте її перед видаленням.

# Відмова, яку показують, коли опис, що зберігається, уже носить інший елемент
# того самого довідника (рішення автора, 25/07/2026: два елементи одного
# довідника не повинні мати однакову назву — віднести операцію до одного з двох
# однакових описів означає кинути монету). `element` — іменник у своєму роді,
# «категорія», «контрагент»; `label` — наявний опис, як він збережений, щоб
# користувач бачив, що саме заважає.
nomenclature-duplicate = Уже існує { $element } з такою самою назвою: «{ $label }».

# ---------------------------------------------------------------------
# Те, що вікна кажуть про самих себе.
#
# Тут усе, зокрема й те, що залежить від показаного довідника: фрази
# написані повністю, мова за мовою, а не зібрані зі слів і родів. Складання,
# правильне у французькій, виявляється хибним у наступній мові, і зрештою
# код мусить знати, що буває жіночий рід, — а це не його робота (правило
# автора, 25/07/2026: «програма працює з Fluent французькою та англійською
# від самого початку»).
# ---------------------------------------------------------------------

ui-loading = Завантаження…
ui-editing = Редагування.
ui-viewing = Перегляд.
ui-modified-suffix = — змінено
ui-label-required = Опис обов'язковий.
ui-discard-question = Відмовитися від змін?
ui-yes = Так
ui-no = Ні
ui-select-record = Виберіть запис
ui-key-multiselect = CTRL
ui-multiselect-help = Інфо: використовуйте клацання мишею + клавішу [{ $modifier }] на таблиці, щоб вибрати кілька елементів
ui-no-match = Жоден опис не відповідає фільтру.
ui-filter-placeholder = Фільтрувати описи…
ui-column-label = ОПИС
ui-field-label = Опис
ui-field-budget-line = Стаття бюджету
ui-identifier = Ідентифікатор
ui-deletion-abandoned = Видалення скасовано: нічого не змінено.
ui-unknown-nomenclature = Невідомий довідник:

ui-title-filter = Фільтрувати
ui-title-create = Створити
ui-title-update = Змінити вибране
ui-title-delete = Видалити вибране
ui-title-read = Переглянути вибране
ui-title-close = Закрити
ui-title-save = Зберегти
ui-title-add = Додати
ui-title-modify = Змінити

ui-load-failed = Не вдалося завантажити:
ui-save-failed = Не вдалося зберегти:
ui-read-failed = Не вдалося прочитати:
ui-delete-failed = Не вдалося видалити:
ui-open-failed = Не вдалося відкрити:
ui-close-failed = Не вдалося закрити:

# --- Фрази, властиві кожному довіднику -------------------------------

nomenclature-identifier = { $kind ->
    [category] Ідентифікатор категорії
    [assignment] Ідентифікатор призначення
    [payment-mode] Ідентифікатор способу оплати
    [payee] Ідентифікатор контрагента
    [project] Ідентифікатор проєкту
    [budget-line] Ідентифікатор статті бюджету
   *[bank] Ідентифікатор банку
}

nomenclature-none = { $kind ->
    [category] Немає категорій.
    [assignment] Немає призначень.
    [payment-mode] Немає способів оплати.
    [payee] Немає контрагентів.
    [project] Немає проєктів.
    [budget-line] Немає статей бюджету.
   *[bank] Немає банків.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Немає категорій для відображення.
    [assignment] Немає призначень для відображення.
    [payment-mode] Немає способів оплати для відображення.
    [payee] Немає контрагентів для відображення.
    [project] Немає проєктів для відображення.
    [budget-line] Немає статей бюджету для відображення.
   *[bank] Немає банків для відображення.
}

nomenclature-gone = { $kind ->
    [category] Цієї категорії більше не існує.
    [assignment] Цього призначення більше не існує.
    [payment-mode] Цього способу оплати більше не існує.
    [payee] Цього контрагента більше не існує.
    [project] Цього проєкту більше не існує.
    [budget-line] Цієї статті бюджету більше не існує.
   *[bank] Цього банку більше не існує.
}

nomenclature-fresh = { $kind ->
    [category] Нова категорія.
    [assignment] Нове призначення.
    [payment-mode] Новий спосіб оплати.
    [payee] Новий контрагент.
    [project] Новий проєкт.
    [budget-line] Нова стаття бюджету.
   *[bank] Новий банк.
}

nomenclature-created = { $kind ->
    [category] Категорію додано.
    [assignment] Призначення додано.
    [payment-mode] Спосіб оплати додано.
    [payee] Контрагента додано.
    [project] Проєкт додано.
    [budget-line] Статтю бюджету додано.
   *[bank] Банк додано.
}

nomenclature-updated = { $kind ->
    [category] Категорію змінено.
    [assignment] Призначення змінено.
    [payment-mode] Спосіб оплати змінено.
    [payee] Контрагента змінено.
    [project] Проєкт змінено.
    [budget-line] Статтю бюджету змінено.
   *[bank] Банк змінено.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] Видалено { $count } категорію.
        [few] Видалено { $count } категорії.
        [many] Видалено { $count } категорій.
       *[other] Видалено { $count } категорії.
      }
    [assignment] { $count ->
        [one] Видалено { $count } призначення.
        [few] Видалено { $count } призначення.
        [many] Видалено { $count } призначень.
       *[other] Видалено { $count } призначення.
      }
    [payment-mode] { $count ->
        [one] Видалено { $count } спосіб оплати.
        [few] Видалено { $count } способи оплати.
        [many] Видалено { $count } способів оплати.
       *[other] Видалено { $count } способи оплати.
      }
    [payee] { $count ->
        [one] Видалено { $count } контрагента.
        [few] Видалено { $count } контрагенти.
        [many] Видалено { $count } контрагентів.
       *[other] Видалено { $count } контрагенти.
      }
    [project] { $count ->
        [one] Видалено { $count } проєкт.
        [few] Видалено { $count } проєкти.
        [many] Видалено { $count } проєктів.
       *[other] Видалено { $count } проєкти.
      }
    [budget-line] { $count ->
        [one] Видалено { $count } статтю бюджету.
        [few] Видалено { $count } статті бюджету.
        [many] Видалено { $count } статей бюджету.
       *[other] Видалено { $count } статті бюджету.
      }
   *[bank] { $count ->
        [one] Видалено { $count } банк.
        [few] Видалено { $count } банки.
        [many] Видалено { $count } банків.
       *[other] Видалено { $count } банки.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Уже існує категорія з такою самою назвою: «{ $label }».
    [assignment] Уже існує призначення з такою самою назвою: «{ $label }».
    [payment-mode] Уже існує спосіб оплати з такою самою назвою: «{ $label }».
    [payee] Уже існує контрагент з такою самою назвою: «{ $label }».
    [project] Уже існує проєкт з такою самою назвою: «{ $label }».
    [budget-line] Уже існує стаття бюджету з такою самою назвою: «{ $label }».
   *[bank] Уже існує банк з такою самою назвою: «{ $label }».
}

# --- Заголовки вікон, без діакритики, як у початкових вікнах ----------

window-list-title = { $kind ->
    [category] Список категорій
    [assignment] Список призначень
    [payment-mode] Список способів оплати
    [payee] Список контрагентів і продавців
    [project] Список проєктів
    [budget-line] Список статей бюджету
   *[bank] Список банків
}

window-form-title = { $kind ->
    [category] Картка категорії
    [assignment] Картка призначення
    [payment-mode] Картка способу оплати
    [payee] Картка контрагента
    [project] Картка проєкту
    [budget-line] Картка статті бюджету
   *[bank] Картка банку
}

# --- Рядок меню (01_CAHIER_DES_CHARGES.md §6) -------------------------

menu-file = Файл
menu-file-import-statements = Імпорт банківських виписок
menu-file-import-excel = Імпорт файлу Excel
menu-file-backup = Резервна копія
menu-file-restore = Відновлення
menu-file-repair = Відновлення цілісності та оптимізація бази даних
menu-file-log = Показати журнал
menu-tools-password = Захистити базу даних паролем
menu-file-disconnect = Від'єднатися від поточної бази
menu-file-quit = Вихід

menu-accounts = Рахунки
menu-accounts-manage = Керування банківськими рахунками
menu-accounts-balances = Перегляд балансів ваших рахунків
menu-accounts-operations = Керування операціями рахунку
menu-accounts-quick-classify = Швидка класифікація операцій
menu-accounts-recurring = Керування періодичними операціями
menu-accounts-transfer = Переказ суми між двома рахунками
menu-accounts-checkbooks = Керування чековими книжками

menu-statistics = Статистика
menu-statistics-balance-chart = Графік зміни балансу
menu-statistics-by-category = Статистика за категоріями
menu-statistics-by-assignment = Статистика за призначеннями
menu-statistics-by-budget-line = Статистика за статтями бюджету
menu-statistics-by-payment-mode = Статистика за способами оплати
menu-statistics-by-payee = Статистика за контрагентами та продавцями
menu-statistics-by-project = Статистика за проєктами
menu-statistics-dashboard = Зведена панель операцій

menu-budget = Бюджет
menu-budget-entry = Введення бюджету
menu-budget-control = Контроль бюджету

menu-nomenclatures = Довідники
menu-nomenclature = { $kind ->
    [category] Категорії
    [assignment] Призначення
    [payment-mode] Способи оплати
    [payee] Контрагенти та продавці
    [project] Проєкти
    [budget-line] Статті бюджету
   *[bank] Банки
}
menu-nomenclatures-templates = Шаблони операцій

menu-settings = Налаштування
menu-settings-about-author = Про автора
menu-settings-about-radinus = Про Radinus
menu-settings-licence = Ліцензія

menu-misc = Різне
menu-misc-calculator = Калькулятор
menu-misc-website = Перейти на сайт Radinus
menu-misc-database-folder = Доступ до теки з базою даних

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Відкрити теку бази даних
database-folder-warning =
    У цій теці зберігаються всі ваші дані. Перейменування, переміщення або вилучення файлу може призвести до втрати рахунків, їх пошкодження або до непрацездатності Radinus.
    Sправді відкрити її?
menu-misc-application-folder = Доступ до теки з програмою
menu-misc-attachments-folder = Доступ до теки з долученнями
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Керування долученнями
window-attachments-manager-title = Керування долученнями
attachments-column-document = Документ
attachments-column-size = Розмір
attachments-column-added = Додано
attachments-column-state = Стан
attachments-state-intact = Не змінено
attachments-state-altered = Змінено відтоді
attachments-state-missing = Файл відсутній
attachments-state-unknown = Неможливо перевірити
attachments-state-orphan = Осиротілий
attachments-no-operation = Немає операції
attachments-orphan-remove-question = Цей файл не пов'язаний із жодною операцією. Надіслати його до смітника?
attachments-manager-help = Двічі клацніть рядок, щоб відкрити документ.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Показати операцію
attachments-reveal = Показати у файловому менеджері
attachments-manager-summary = Долучень: { $count }, разом { $size }.
attachments-disk-name = Ім'я на диску: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Відкрити теку долучень
attachments-folder-warning =
    У цій теці зберігаються файли, долучені вами до операцій. Radinus зберігає їх під іменем, яке обрав сам: перейменування, переміщення або вилучення файлу не від'єднує його від операції — вона й далі його показуватиме, а він більше не відкриється.
    Sправді відкрити її?

# ---------------------------------------------------------------------
# Банківські рахунки — F04, F06, F07, F08.
# Друкарські помилки версії 1.9.3 («Bank Identifer Code», «Solde
# initial prevu», «Est Cloturé», пробіл перед дужкою в IBAN)
# виправлено: рішення Fabrice від 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Керування банківськими рахунками
window-accounts-select-title = Список рахунків
window-balances-title = Баланси ваших рахунків
window-account-title = Картка рахунку

accounts-none = Немає рахунків.
accounts-nothing-to-show = Немає рахунків для показу.
accounts-gone = Цей рахунок більше не існує.
accounts-fresh = Новий рахунок.
accounts-created = Рахунок додано.
accounts-updated = Рахунок змінено.
accounts-deleted = { $count ->
    [one] Видалено { $count } рахунок.
    [few] Видалено { $count } рахунки.
    [many] Видалено { $count } рахунків.
   *[other] Видалено { $count } рахунки.
}
accounts-duplicate-name = Рахунок із такою назвою вже існує: «{ $label }».
accounts-multiselect-help = Інформація: використовуйте клацання мишею + клавішу [{ $modifier }] у таблиці, щоб вибрати кілька рахунків
accounts-select-question = На яких банківських рахунках слід базувати статистику?

accounts-column-label = НАЗВА
accounts-column-bank = Банк
accounts-column-type = Тип рахунку
accounts-column-number = Номер рахунку
accounts-column-account = Рахунок
accounts-column-bank-balance = У банку
accounts-column-real-balance = Реальний
accounts-column-final-balance = Підсумковий
accounts-total = РАЗОМ

# Видалення рахунку забирає із собою його операції: це єдине місце
# у програмі, де видалення знищує історію.
accounts-delete-plain = Ви підтверджуєте видалення рахунку «{ $label }»?
accounts-delete-with-operations = Рахунок «{ $label }» містить { $count } операцій, які буде видалено разом із ним. Ви підтверджуєте видалення?
accounts-delete-form-open = Картку рахунку «{ $label }» відкрито. Закрийте її перед видаленням.

account-group-bank = Відомості про рахунок і банк
account-group-holder = Власник
account-group-rib = Банківські реквізити (RIB)
account-group-activity = Активність
account-group-balances = Баланси

account-field-label = Назва рахунку
account-field-bank = Банк
account-field-type = Тип рахунку
account-field-branch-address = Адреса відділення банку
account-field-holder-name = Ім'я
account-field-holder-address = Адреса
account-field-rib-bank = Код банку
account-field-rib-branch = Код відділення
account-field-rib-number = Номер рахунку
account-field-rib-key = Ключ RIB
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Дата відкриття
account-field-closing-date = Дата закриття
account-field-closed = Закритий
account-field-opening-pointed = Початковий звірений баланс
account-field-opening-committed = Початковий зарезервований баланс
account-field-opening-planned = Початковий запланований баланс

account-label-required = Назва рахунку обов'язкова.
account-iban-invalid = Цей IBAN недійсний: перевірте контрольний ключ.
# Синій рядок унизу картки, слово в слово як у 1.9.3 — лише суми
# тепер відповідають французькому формату інших полів.
account-control-line = Початковий звірений баланс ({ $opening }) + Разом за операціями ({ $operations }) = Поточний банківський баланс: { $balance }.

amount-not-readable = «{ $field }» не містить допустимої суми.

ui-thousands-separator =  
ui-decimal-separator = ,

# --- Список операцій (F02) -------------------------------------------

window-operations-title = Список операцій рахунку: { $account }

operations-none = Немає операцій за цей період.
operations-bad-period = Межі періоду не є дійсними датами.
operations-from = Дата початку
operations-to = Дата закінчення
operations-delete-confirm = { $count ->
    [one] Ви підтверджуєте видалення цієї операції?
    [few] Ви підтверджуєте видалення цих { $count } рядків? Підоперації вибраних операцій видаляються разом із ними.
    [many] Ви підтверджуєте видалення цих { $count } рядків? Підоперації вибраних операцій видаляються разом із ними.
   *[other] Ви підтверджуєте видалення цих { $count } рядків? Підоперації вибраних операцій видаляються разом із ними.
}
operations-deleted = { $count ->
    [one] Видалено { $count } операцію.
    [few] Видалено { $count } операції.
    [many] Видалено { $count } операцій.
   *[other] Видалено { $count } операції.
}
operations-selection-total = Загальна сума вибраних операцій: { $amount }

operations-column-date = Дата
operations-column-clearing-date = Дата звірки
operations-column-label = Опис
operations-column-category = Категорія
operations-column-assignment = Призначення
operations-column-payment-mode = СпосібОп
operations-column-payee = Контрагент
operations-column-project = Проєкти
operations-column-month = Місяць
operations-column-debit = Витрата
operations-column-credit = Надходження
operations-column-balance = Баланс
operations-column-comments = Коментарі
operations-column-attachments = Вкладення
operations-column-check = Номер чека

operations-foot-debit = Витрата:
operations-foot-credit = Надходження:
operations-foot-total = Разом:
operations-foot-bank = Банківський баланс:
operations-foot-real = Реальний баланс:
operations-foot-final = Підсумковий баланс:

operations-menu-export = Експорт
operations-menu-print = Друк
operations-menu-filter = Фільтр
operations-menu-period = Період
operations-menu-misc = Різне

operations-title-point = Звірити вибране
operations-title-sub = Додати підоперацію
operations-title-duplicate = Дублювати вибране
operations-not-yet = Цього вікна ще немає: воно з'явиться далі за планом.

accounts-choose-question = З яким рахунком ви хочете працювати?
ui-title-select = Вибрати виділене

month-january = січень
month-february = лютий
month-march = березень
month-april = квітень
month-may = травень
month-june = червень
month-july = липень
month-august = серпень
month-september = вересень
month-october = жовтень
month-november = листопад
month-december = грудень

operations-period-year = Поточний рік

# --- Меню «Період» вікна F02 -----------------------------------------
# Дев'ять пунктів, два з яких відкривають підменю з дванадцятьма місяцями.
# Кожен робить лише одне: визначає дату початку та дату закінчення, які
# вікно підставляє у свої два поля (прохання Fabrice, 25/07/2026).

period-all = Усі
period-last-year = Минулий рік
period-this-year = Поточний рік
period-whole-year = Увесь рік
period-last-month = Минулий місяць
period-this-month = Поточний місяць
period-last-week = Минулий тиждень
period-this-week = Поточний тиждень
period-yesterday = Учора
period-today = Сьогодні

# --- Меню «Фільтр» вікна F02 ------------------------------------------
# Фільтрує рядки за характером операції (запит Fabrice, 25/07/2026).
# Три статуси — це статуси бази: 1 звірено, 2 зарезервовано, 3 заплановано
# (02_BASE_DE_DONNEES.md §5.2).

filter-all = Усі операції
filter-pointed = Лише звірені операції
filter-committed = Лише зарезервовані операції
filter-planned = Лише заплановані операції

# --- Картка операції (F03) --------------------------------------------
# Написи взято зі знімка «Fiche operation transaction.png», друкарські
# помилки оригіналу виправлено (дозвіл Fabrice, 25/07/2026:
# « les coquilles tu les corriges »): «Libelle» стає «Libellé»,
# «Categorie» стає «Catégorie», «Statut Operation» стає
# «Statut opération».

window-operation-title = Операція. Рахунок: { $account }

operation-menu-identification = Ідентифікація
operation-menu-options = Параметри
operation-fitid-edit = Змінити ідентифікатор FITID…
operation-fitid-delete = Видалити ідентифікатор FITID
operation-fitid-question = Ідентифікатор FITID цієї операції:
operation-fitid-delete-question = Видалити ідентифікатор FITID цієї операції?
operation-fitid-written = Ідентифікатор FITID збережено.
operation-fitid-removed = Ідентифікатор FITID видалено.

operation-group-identification = Ідентифікація операції
operation-group-amount = Сума операції
operation-group-status = Статус операції
operation-group-classification = Класифікація операції для обчислення статистики
operation-group-check = Чек, пов’язаний з операцією
operation-group-comment = Коментар

operation-field-label = Опис
operation-field-reference = Референс платежу
operation-field-date = Дата
operation-field-direction = Тип операції:
operation-field-amount = Сума
operation-field-status = Статус операції
operation-field-clearing-date = Дата звірки
operation-field-category = Категорія
operation-field-assignment = Призначення
operation-field-payment-mode = Спосіб
operation-field-payee = Контрагент
operation-field-project = Проєкт
operation-field-check = Пов’язати з чеком

operation-direction-debit = Витрата
operation-direction-credit = Надходження

operation-check-info = Інфо.
operation-check-link = Пов’язати
operation-check-unlink = Видалити

operation-fresh = Нова операція.
operation-created = Операцію додано.
operation-updated = Операцію змінено.
operation-gone = Цієї операції більше не існує.
operation-nothing-to-show = Немає операцій для показу.
operation-label-required = Опис операції обов’язковий.
operation-date-required = Дата операції обов’язкова.
operation-clearing-date-invalid = Дата звірки не є дійсною датою.
operation-is-a-sub = Цей рядок — підоперація: її змінюють у її власній картці.
operation-delete-form-open = Картку «{ $label }» відкрито. Закрийте її перед видаленням.

operation-attachments = { $count ->
    [0] Немає вкладень
    [one] { $count } вкладення
    [few] { $count } вкладення
    [many] { $count } вкладень
   *[other] { $count } вкладення
}

operation-title-comment = Коментар до операції
operation-title-sub = Створити підоперацію
operation-title-template = Шаблони операцій
operation-title-attachment = Вкладення

# --- Картка підоперації (F04) -----------------------------------------
# Скорочений варіант F03: без Способу, без Статусу, без Дати — підоперація
# успадковує їх від своєї материнської операції (`Maj_ProprieteSousOp`,
# підтверджено Fabrice 26/07/2026: « dans une sous-opération, comme est le
# complément, on ne peut pas toucher au mode de paiement, cela serait
# illogique »).

window-sub-operation-title = Картка підоперації

sub-operation-group-amount = Сума підоперації
sub-operation-field-label = Назва
sub-operation-fresh = Нова підоперація.
sub-operation-created = Підоперацію додано.
sub-operation-updated = Підоперацію змінено.
sub-operation-gone = Цієї підоперації більше не існує.
sub-operation-nothing-to-show = Немає підоперацій для показу.
sub-operation-label-required = Назва підоперації обов’язкова.
sub-operation-parent-gone = Операції, яку потрібно розподілити, більше не існує.
# Що каже картка, коли показує Залишок. Він не захищений: його можна
# змінити, але треба розуміти, що саме береш (рішення Fabrice,
# 26/07/2026).
sub-operation-is-the-complement = Це Залишок: те, що лишилося розподілити. Якщо його перейменувати або змінити його суму, він стане звичайною підоперацією.
sub-operation-of = Розподіл «{ $label }» ({ $amount })

operations-pointed = { $count ->
    [one] Звірено { $count } операцію.
    [few] Звірено { $count } операції.
    [many] Звірено { $count } операцій.
   *[other] Звірено { $count } операції.
}
operations-select-one = Виберіть лише одну операцію.

# --- Дублювання та показ підоперацій (F02) ----------------------------
# Дублювання відкриває заздалегідь заповнену картку, яку користувач
# підтверджує сам (рішення Fabrice, 26/07/2026): поки він не зберіг,
# нічого не записано, і він може виправити дату або суму заздалегідь.

operation-copy = Копію ще не збережено: поки що нічого не створено.
operations-show-children = Показати всі підоперації
operations-hide-children = Приховати всі підоперації

# --- Друге підтвердження небезпечного видалення -----------------------
# Видалення банківського рахунку забирає всю його історію: «Так/Ні»
# натискають не читаючи, тому ми просимо написати слово (рішення Fabrice,
# 26/07/2026). Слово береться зі словника — тут «Так», англійською «Yes» —
# отже, перекладати тут двічі нічого.

accounts-delete-second-question = Це видалення остаточне і забирає всю історію рахунку. Напишіть «{ $word }», щоб його підтвердити.

# --- F20-F24 — Шість видів статистики ---------------------------------
# Спільний шаблон, розгорнутий за шістьма осями. Та, що за категоріями,
# послужила зразком, і Fabrice затвердив її 26/07/2026, ще до того як
# з’явилися решта п’ять, — назви стовпців узято з оригіналу.

window-statistics-title = { $kind ->
    [assignment] Статистика за призначеннями
    [budget-line] Статистика за статтями бюджету
    [payment-mode] Статистика за способами оплати
    [payee] Статистика за контрагентами та продавцями
    [project] Статистика за проєктами
   *[category] Статистика за категоріями
}

statistics-axis-column = { $kind ->
    [assignment] Призначення
    [budget-line] СтаттяБюджету
    [payment-mode] СпосібОперації
    [payee] Контрагент
    [project] Проєкти
   *[category] НазваКатегорії
}

statistics-unclassified = { $kind ->
    [assignment] Без призначення
    [budget-line] Без статті бюджету
    [payment-mode] Без способу оплати
    [payee] Без контрагента
    [project] Без проєкту
   *[category] Без категорії
}
statistics-total = Разом
statistics-sum = Сума
statistics-cumulative = Наростаючий підсумок

# П’ять перемикачів панелі. Напис перемикається ON/OFF, як в оригіналі:
# сам перемикач каже, у якому він положенні.
statistics-switch-pointed = Звірені операції { $state }
statistics-switch-committed = Зарезервовані операції { $state }
statistics-switch-planned = Заплановані операції { $state }
statistics-switch-debits = Суми витрат { $state }
statistics-switch-credits = Суми надходжень { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Не вибрано жодного рахунку: статистиці немає що рахувати.
statistics-no-data = За цей рік за вибраними рахунками немає жодної операції.
statistics-detail-empty = Натисніть на клітинку з числом, щоб побачити операції, які вона рахує.
statistics-detail-none = За цією клітинкою немає жодної операції.
statistics-accounts = { $count ->
    [one] { $count } рахунок
    [few] { $count } рахунки
    [many] { $count } рахунків
   *[other] { $count } рахунка
}
statistics-year-next = Наступний рік
statistics-year-previous = Попередній рік

statistics-column-date = Дата
statistics-column-clearing-date = ДатаЗвірки
statistics-column-label = Опис
statistics-column-amount = Сума
statistics-column-comments = Коментарі

accounts-stats-multiselect-help = Інфо: використовуйте клацання мишею + клавішу [{ $modifier }] на таблиці, щоб вибрати кілька рахунків

# Рік статистики: на нього клацають і вводять рік. Межі ті самі, що й у
# «Усі» в меню «Період» — рік у Radinus це ціле число від 1950 до 2550
# (Fabrice, 26/07/2026).
statistics-year-question = За який рік ви хочете працювати? Radinus іде від { $first } до { $last }.
statistics-year-choose = Вибрати рік

# --- Експорт таблиць (клацання правою кнопкою) ------------------------
# Це функція таблиці, а не вікна: вона є в усіх списків.

export-to-excel = Експорт до Excel (.xlsx)
export-to-word = Експорт до Word (.docx)
export-to-tsv = Експорт до TSV (.tsv)
export-to-ini = Експорт до INI (.ini)
export-to-toml = Експорт до TOML (.toml)
export-to-yaml = Експорт до YAML (.yaml)
export-to-ofx = Експорт до OFX (.ofx)
export-to-qif = Експорт до QIF (.qif)
export-to-ods = Експорт до LibreOffice Calc (.ods)
export-to-csv = Експорт до CSV (.csv)
export-to-xml = Експорт до XML (.xml)
# Меню «Експорт» вікна статистики: по одній вкладці на рік, з назвою
# AN_2026. Порожніх років — за заданих положень перемикачів — там немає.
export-menu = Експорт
export-all-years-excel = Експортувати всі роки до Excel
export-all-years-ods = Експортувати всі роки до LibreOffice Calc
export-no-year = Жоден рік не містить операцій: експортувати нічого.
export-years-done = Експортовано років: { $years } — до «{ $file }».
export-to-json = Експорт до JSON (.json)
export-done = Експортовано до «{ $file }».
export-failed = Експорт неможливий: { $reason }
export-nothing = Експортувати нічого.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Статистика за призначеннями
    [budget-line] Статистика за статтями бюджету
    [payment-mode] Статистика за способами оплати
    [payee] Статистика за контрагентами та продавцями
    [project] Статистика за проєктами
   *[category] Статистика за категоріями
}
statistics-detail-name = Деталізація статистики

# --- F19 — Панель керування --------------------------------------------
# Один період і три перемикачі; дві кільцеві діаграми на кожну статтю
# бюджету; три великі числа. Кольори секторів — ті самі, що в оригіналі,
# зняті зі знімка екрана Фабріса.

window-dashboard-title = Панель керування
dashboard-menu-period = Період
dashboard-menu-misc = Різне
dashboard-from = Дата початку:
dashboard-to = Дата кінця:
dashboard-switch-pointed = Включати звірені операції
dashboard-switch-committed = Включати зарезервовані операції
dashboard-switch-planned = Включати заплановані операції
dashboard-spending = Витрати
dashboard-earning = Надходження
dashboard-debits = Сума видаткових операцій
dashboard-credits = Сума прибуткових операцій
dashboard-balance = Баланс
dashboard-unclassified = Без статті бюджету
dashboard-nothing = Немає операцій за цей період.
dashboard-no-account = Не вибрано жодного рахунку: панель керування нічого не показує.
dashboard-enlarge = Відкрити на весь екран

# --- F25 — Динаміка балансу ---------------------------------------------
# По одному графіку на кожен вибраний рахунок, плюс графік загальної суми —
# який існує лише починаючи з двох рахунків (правило Фабріса, 26/07/2026).
# Графіки східчасті: баланс зберігає своє значення до наступної операції.

window-curve-title = Динаміка балансу
curve-heading = Динаміка балансу за днями
curve-menu-period = Період
curve-total = Разом
curve-from = Дата початку:
curve-to = Дата кінця:
curve-axis-balance = баланс
curve-nothing = Не вибрано жодного рахунку: графік будувати нема з чого.
curve-empty = Немає операцій за цей період.

# --- F05 — Швидка класифікація операцій ---------------------------------
# Вікно, у якому класифікують **масово**: виділяють рядки, позначають
# ознаки, які треба змінити, і застосовують їх разом — у пам'яті.
# Нічого не записується, доки не збережено, а збереження записує лише те,
# що відрізняється від прочитаного (правила Фабріса, 27/07/2026).

window-quick-classification-title = Швидка класифікація операцій: { $account }
quick-dates-title = Дати початку та кінця списку.
quick-from = Дата початку
quick-to = Дата кінця
quick-menu-period = Період
quick-change-title = Змінити ознаки виділеного на:
quick-check-category = Категорія
quick-check-assignment = Призначення
quick-check-payment-mode = Спосіб
quick-check-payee = Контрагент
quick-check-project = Проєкт
quick-check-status = Статус
quick-column-date = Дата
quick-column-label = Опис
quick-column-amount = Сума
quick-column-category = Категорія
quick-column-assignment = Призначення
quick-column-payment-mode = Спосіб оплати
quick-column-payee = Контрагент
quick-column-project = Проєкти
quick-column-status = Статус
# На Mac Ctrl + клацання — це клацання правою кнопкою: клавіша, що додає
# до виділення, тут ⌘, і підказка має називати ту, яка справді працює.
quick-multiselect-help = Інфо: використовуйте клацання мишею + клавішу [{ $modifier }] у таблиці, щоб вибрати кілька елементів
quick-none = Немає операцій за цей період.
quick-select-lines = Виберіть щонайменше один рядок і позначте щонайменше одну ознаку.
quick-applied = { $count ->
    [0] Нічого не змінилося: ці рядки вже мали таку класифікацію.
    [one] Класифіковано { $count } рядок. Ще нічого не збережено.
    [few] Класифіковано { $count } рядки. Ще нічого не збережено.
    [many] Класифіковано { $count } рядків. Ще нічого не збережено.
   *[other] Класифіковано { $count } рядка. Ще нічого не збережено.
}
quick-pending = { $count ->
    [0] Немає незбережених змін.
    [one] Змінено { $count } рядок, не збережено.
    [few] Змінено { $count } рядки, не збережено.
    [many] Змінено { $count } рядків, не збережено.
   *[other] Змінено { $count } рядка, не збережено.
}
quick-save-question = { $count ->
    [one] Зберегти { $count } зміну, що очікує?
    [few] Зберегти { $count } зміни, що очікують?
    [many] Зберегти { $count } змін, що очікують?
   *[other] Зберегти { $count } зміни, що очікують?
}
quick-saved = { $count ->
    [0] Не було чого зберігати.
    [one] Збережено { $count } рядок.
    [few] Збережено { $count } рядки.
    [many] Збережено { $count } рядків.
   *[other] Збережено { $count } рядка.
}
quick-nothing-to-save = Немає незбережених змін.
quick-leave-question = Деякі зміни не збережено. Що ви хочете зробити?
quick-leave-save = Зберегти і вийти
quick-leave-discard = Вийти без збереження
quick-leave-stay = Залишитися
quick-title-apply = Застосувати до вибраних рядків ( у пам'яті )
quick-title-save = Зберегти на диск

# --- F17 / F18 — Імпорт банківської виписки -----------------------------
# Вибирають рахунок, відкривають файл OFX — який залишається в оперативній
# пам'яті, — рядки, уже відомі базі, показуються пастельним кольором, а
# третя піктограма їх додає: масово, якщо вибрано кілька, інакше по одному
# через картку звірки (порядок дій Фабріса, 27/07/2026).

window-statement-import-title = Імпорт виписок за банківськими рахунками: { $account }
window-statement-form-title = Звірити транзакцію (Додає операцію до історії вашого рахунку)
statement-menu-filter = Фільтр
statement-filter-all = Усі рядки
statement-filter-pending = До додавання
statement-filter-known = Уже додані
statement-column-id = ID
statement-column-reconciled = Звірено
statement-column-fitid = FITID
statement-column-date = Дата
statement-column-label = Опис
statement-column-debit = Витрата
statement-column-credit = Надходження
statement-account = Рахунок
statement-file = Файл
statement-difference = Різниця
statement-none = Жодної виписки не відкрито: натисніть на жовту теку, щоб вибрати файл.
statement-empty = Ця виписка не містить жодної операції.
statement-no-match = Жоден рядок не відповідає фільтру.
statement-help = Інфо: використовуйте клацання мишею + клавішу [{ $modifier }] у таблиці, щоб вибрати кілька рядків
statement-choose-account = Цей файл містить кілька рахунків. Який з них ви хочете імпортувати?
statement-select-line = Виберіть щонайменше один рядок виписки.
statement-title-open = Відкрити файл виписки (.ofx)
statement-title-info = Відомості про відкритий файл
statement-title-integrate = Додати вибране до рахунку
statement-title-validate = Додати цю операцію до рахунку
statement-duplicate = Увага, дублікат: ця транзакція, схоже, вже була додана до бази (Financial Institution Transaction ID існує)
statement-no-fitid = Увага: цей файл не дає жодного ідентифікатора (FITID) для цього рядка. Дублікат не вдасться виявити.
statement-loaded = { $count ->
    [0] Цей файл не містить жодної операції для цього рахунку.
    [one] Прочитано { $count } рядок, з них { $known } уже є на вашому рахунку.
    [few] Прочитано { $count } рядки, з них { $known } уже є на вашому рахунку.
    [many] Прочитано { $count } рядків, з них { $known } уже є на вашому рахунку.
   *[other] Прочитано { $count } рядка, з них { $known } уже є на вашому рахунку.
}
statement-integrated = { $count ->
    [0] Нічого не додано: ці рядки вже є на вашому рахунку.
    [one] Додано { $count } операцію.
    [few] Додано { $count } операції.
    [many] Додано { $count } операцій.
   *[other] Додано { $count } операції.
}
# **Повідомлення оригіналу, слово в слово** (вказівка Фабріса, 28/07/2026:
# лишатися вірним початковому коду). Його програма попереджає перед
# пакетною обробкою, питає рядок за рядком перед дублікатом і звітує
# наприкінці.

statement-mass-question =
    Ви впевнені, що хочете додати до вашого рахунку одночасно кілька операцій?
    Вам доведеться пізніше розподілити їх за категоріями та ознаками, щоб робити точну статистику
    У випадку файлів Ofx: якщо буде виявлено дублікати, вам доведеться вибрати поведінку програми
    Для інших типів файлів: вам доведеться стежити за дублікатами
statement-duplicate-question =
    Транзакція: { $date } { $label }: { $amount }
    схоже, вже була додана до історії транзакцій вашого банківського рахунку.
    Ви справді хочете виконати звірку?
statement-already-reconciled = Ви вже звірили цю транзакцію: вона вже додана до історії транзакцій вашого рахунку
statement-integration-report =
    Додавання завершено.
    Кількість доданих записів: { $added }
    Кількість пропущених записів: { $ignored }
statement-integration-abandoned =
    Додавання перервано!
    Кількість доданих записів: { $added }
    Кількість пропущених записів: { $ignored }
statement-yes = Так
statement-no = Ні
statement-cancel = Скасувати
statement-file-info =
    Рахунок із файлу: { $account }
    Період: з { $from } до { $to }
    Баланс, заявлений банком: { $balance }
    { $count } операцій, з них { $known } уже є на вашому рахунку.
statement-group-identification = Ідентифікація операції
statement-group-amount = Сума операції
statement-group-classification = Класифікація операції для розрахунку статистики
statement-group-status = Статус операції
statement-field-date = Дата
statement-field-label = Опис
statement-field-type = Тип операції
statement-field-amount = Сума
statement-field-mode = Спосіб оплати
statement-field-category = Категорія
statement-field-assignment = Призначення
statement-field-payee = Контрагент
statement-field-project = Проєкт
statement-field-status = Статус
statement-field-clearing = Дата звірки

# --- Вікно розбору виписки CSV ------------------------------------------
# CSV не несе жодних надійних назв полів: налаштовують, перевіряють,
# дивляться, починають спочатку. Попередній перегляд показує все, разом із
# абракадаброю, — саме так і видно, що помилилися, — але у вікно додавання
# переходять лише правильні рядки (правило Фабріса, 27/07/2026).

window-csv-statement-title = Імпорт даних із файлу csv
csv-preview-title = Попередній перегляд файлу:
csv-settings-title = Параметри розбору файлу для видобування даних:
csv-extraction-title = Перегляд видобутих даних згідно з параметрами розбору  ( перевірте узгодженість даних ):
csv-column-line = № рядка
csv-column-content = Вміст
csv-header-lines = Кількість рядків заголовка файлу, які треба пропустити
csv-separator = Дані (стовпці) розділені символом:
csv-date-at = Позиція поля дати
csv-label-at = Позиція поля опису
csv-debit-at = Позиція поля суми витрати
csv-credit-at = Позиція поля суми надходження
csv-test = Перевірити параметри
csv-separator-semicolon = Крапка з комою   ;
csv-separator-comma = Кома   ,
csv-separator-tab = Табуляція
csv-separator-pipe = Вертикальна риска   |
csv-separator-space = Пробіл
csv-help = Налаштуйте, перевірте, подивіться: імпортовано буде лише рядки з читабельною датою та читабельною сумою.
csv-none = Файл порожній.
csv-not-tested = Натисніть «Перевірити параметри», щоб побачити, що дає розбір.
csv-extraction = { $count ->
    [0] Розбір не дає жодного рядка: перевірте кількість рядків заголовка та роздільник.
    [one] Розібрано { $count } рядок: { $valid } буде імпортовано, { $dropped } відкинуто через нечитабельну дату або суму.
    [few] Розібрано { $count } рядки: { $valid } буде імпортовано, { $dropped } відкинуто через нечитабельну дату або суму.
    [many] Розібрано { $count } рядків: { $valid } буде імпортовано, { $dropped } відкинуто через нечитабельну дату або суму.
   *[other] Розібрано { $count } рядка: { $valid } буде імпортовано, { $dropped } відкинуто через нечитабельну дату або суму.
}
csv-nothing-valid = Жоден рядок не має водночас читабельної дати та читабельної суми: імпортувати нічого. Перевірте кількість рядків заголовка, роздільник і позиції полів.
csv-title-validate = Перевести правильні рядки до імпорту

# --- F13 / F31 / F14 / F12 — Чекові книжки та чеки (етап 9) -------------
# Портування його п’яти кодів WinDev і семи знімків екрана, наданих
# 28/07/2026. Його точні фрази там, де вони в нього є; мої — в інших місцях.
#
# Три вірності, які він визначив того дня і які чути у словах: про повторне
# позначення не повідомляється (його `Existe_Reference` ніколи не
# викликається), кількість чеків не звіряється з межами, а лічильник операцій
# рахує дочірні, які списки відкидають.

window-chequebooks-title = Список чекових книжок
window-chequebook-title = Параметри чекової книжки
window-cheques-title = Склад чекової книжки: список чеків.
window-cheque-title = Картка чеків
window-cheque-operations-title = Список операцій.

# Список чекових книжок (F13) — усі книжки, з усіх рахунків разом: його два
# стовпці рахунку були б ні до чого, якби рахунок був один.
chequebooks-column-reference = ОПИС
chequebooks-column-date = Дата
chequebooks-column-account = НазваРахунку
chequebooks-column-account-number = Номер рахунку
chequebooks-column-comments = Коментарі
chequebooks-none = Не зареєстровано жодної чекової книжки.
chequebooks-nothing-to-show = Жодна чекова книжка не відповідає цьому запиту.
chequebooks-title-composition = Переглянути склад чекової книжки
chequebooks-delete-question = Виявлено операції (банківські транзакції), пов’язані з чековою книжкою. Ви підтверджуєте, що хочете видалити цю чекову книжку?
chequebooks-deleted = { $count ->
    [one] Видалено { $count } чекову книжку.
    [few] Видалено { $count } чекові книжки.
    [many] Видалено { $count } чекових книжок.
   *[other] Видалено { $count } чекової книжки.
}
chequebooks-gone = Цієї чекової книжки більше не існує.
chequebooks-created = Чекову книжку збережено разом з усіма її чеками.
chequebooks-updated = Чекову книжку змінено.
# Мовчання його `HAjoute`: вікно не каже, що позначення вже зайняте. Воно
# каже лише, що нічого не збережено — інакше можна було б подумати, що
# книжку створено.
# Вісім застережень з його «Precauttion enregistrement cheque.txt», слово в
# слово і в його порядку. Перші сім — це `Erreur()`, восьме — `Info()`, і
# саме порядок вирішує, що буде видно, коли дві речі йдуть не так разом.
chequebook-refusal-duplicate = Позначення з такою самою назвою вже існує
chequebook-refusal-reference-required = Введення позначення є обов’язковим
chequebook-refusal-number-too-big = Номери першого та/або останнього чека завеликі (максимальне значення 999 999 999)
chequebook-refusal-date = Введіть правильну дату отримання
chequebook-refusal-numbers-required = Заповніть номери першого та останнього чека
chequebook-refusal-order = Номер першого чека має бути меншим за номер останнього чека
chequebook-refusal-account = Обов’язково виберіть рахунок, пов’язаний із цією чековою книжкою
chequebook-refusal-too-many = Максимальна кількість чеків для однієї чекової книжки: 1000, обмеження досягнуто
# Його запит підтвердження, що ставиться лише при додаванні: він перелічує
# те, що буде створено, і попереджає, що потім нічого з цього не зміниш.
chequebook-creation-question =
    Створення чекової книжки з такими характеристиками:
    - Кількість чеків для створення:{ $count }
    - Чеки з номерами від { $first } до { $last }
    Увага, ці дані не можна буде змінити після створення!

# Картка чекової книжки (F31). Перші п’ять полів стають неактивними, щойно
# книжка існує: її чеки вже створені.
chequebook-field-id = Ідентифікатор чекової книжки
chequebook-field-reference = Позначення
chequebook-field-received = Виготовлено або отримано
chequebook-field-first = Номер першого чека
chequebook-field-last = Номер останнього чека
chequebook-field-quantity = Кількість чеків
chequebook-field-account = Пов’язати з банківським рахунком:
chequebook-field-comments = Коментарі
chequebook-locked = Чеки цієї книжки вже створені: її нумерація більше не змінюється.
# Його фраза, слово в слово (`Enreg_Lire`).
chequebook-account-missing = Банківський рахунок, з яким було пов’язано цю чекову книжку, відсутній або був видалений!

# Склад чекової книжки (F14). Статус змінюється просто в клітинці.
cheques-column-number = Номер чека
cheques-column-date = Дата
cheques-column-place = Місце
cheques-column-payee = Отримувач
cheques-column-amount = Сума
cheques-column-status = Статус
cheques-column-comments = Коментарі
cheques-column-operations = К-ть пов’яз. операцій
cheques-none = Ця чекова книжка не містить жодного чека.
cheques-nothing-to-show = Жоден чек не відповідає цьому запиту.
cheques-help = Натисніть у клітинці «Статус», щоб змінити його; лупа показує пов’язані операції, ланка пов’язує ще одну.
cheques-title-linked = Переглянути операції, уже пов’язані з цим чеком
cheques-title-link = Пов’язати операцію з цим чеком
cheques-status-changed = Статус чека змінено.

# Картка чека (F12).
cheque-field-id = Ідентифікатор чека
cheque-field-number = Номер чека
cheque-field-issued = Дата виписування
cheque-field-place = Місце виписування
cheque-field-payee = Отримувач
cheque-field-amount = Сума
cheque-field-comments = Коментарі
cheque-field-status = Статус чека
cheque-gone = Цього чека більше не існує.
cheque-updated = Чек змінено.

# Два обличчя вікна прив’язки.
cheque-operations-linked-title = Список операцій, уже пов’язаних із цим чеком.
cheque-operations-choose-title = Виберіть операцію, яку прив’язати до чека
cheque-operations-column-account = Рахунок
cheque-operations-column-label = Назва
cheque-operations-column-date = Дата
cheque-operations-column-clearing = Дата звірки
cheque-operations-column-amount = Сума
cheque-operations-column-cheque = Пов’язаний чек
cheque-operations-none-linked = З цим чеком не пов’язано жодної операції.
cheque-operations-none = Цей рахунок не містить жодної операції.
cheque-operations-nothing-to-show = Жодна операція не відповідає цьому запиту.
cheque-operations-help = Операції, виділені жирним, уже мають чек.
cheque-operations-linked-help = Червоний хрестик відв’язує чек від операції: нічого не видаляється.
cheque-operations-linked = Операцію пов’язано з чеком.
cheque-operations-dissociated = Чек відв’язано від операції.
cheque-operations-menu-filter = Фільтр
cheque-title-associate = Пов’язати цю операцію з чеком
cheque-title-dissociate = Відв’язати чек від цієї операції

# Смуга «Чек, пов’язаний з операцією» у картці операції, і два кроки
# полювання на чек — спочатку книжка, потім чек.
chequebooks-select-question = Виберіть чекову книжку
cheques-select-question = Виберіть чек, який прив’язати до операції
operation-check-save-first = Спочатку збережіть операцію: чек пов’язується з операцією, яка вже існує.
operation-check-none = Ця операція не має жодного чека.

# --- F36 / F37 — Шаблони операцій (етап 10) -----------------------------
# Шаблон — це готовий запис: його застосовують, щоб не набирати заново, і він
# **перезаписує** те, що є в картці. На диск нічого не потрапляє, доки картку
# операції не підтверджено (правило Fabrice, 29/07/2026).

window-operation-templates-title = Список шаблонів операцій
window-operation-template-title = Картка шаблону операції

operation-templates-none = Не зареєстровано жодного шаблону операції.
operation-templates-nothing-to-show = Жоден шаблон не відповідає цьому запиту.
operation-templates-select-question = Виберіть шаблон для застосування
operation-templates-delete-question = Ви підтверджуєте видалення вибраних шаблонів?
operation-templates-deleted = { $count ->
    [one] Видалено { $count } шаблон.
    [few] Видалено { $count } шаблони.
    [many] Видалено { $count } шаблонів.
   *[other] Видалено { $count } шаблона.
}
operation-template-gone = Цього шаблону більше не існує.
operation-template-fresh = Новий шаблон.
operation-template-created = Шаблон збережено.
operation-template-updated = Шаблон змінено.
operation-template-label-required = Введення назви є обов’язковим
operation-template-duplicate = Шаблон з такою самою назвою вже існує

# Картка F36, розділ за розділом — його точні заголовки.
operation-template-field-id = ID шаблону операції
operation-template-group-name = Назва майбутньої операції за замовчуванням після застосування шаблону
operation-template-field-label = Назва
operation-template-group-amount = Сума операції за замовчуванням, задана в цьому шаблоні
operation-template-field-direction = Тип операції
operation-template-field-amount = Сума
operation-template-group-status = Статус операції за замовчуванням у цьому шаблоні
operation-template-field-status = Статус операції
operation-template-group-classification = Дані шаблону для класифікації та розрахунку статистики
operation-template-field-category = Категорія
operation-template-field-assignment = Призначення
operation-template-field-mode = Спосіб
operation-template-field-payee = Контрагент
operation-template-field-project = Проєкт

# Кнопка «Шаблон» у картці операції: один значок, дві дії.
operation-template-question = Що ви хочете зробити з шаблонами операцій?
operation-template-apply = Застосувати шаблон
operation-template-save-as = Зберегти як шаблон
operation-template-applied = Шаблон застосовано. Підтвердіть картку, щоб зберегти її.
operation-template-saved-as = Операцію збережено як шаблон.
operation-template-needs-label = Дайте операції назву, перш ніж робити з неї шаблон.

# --- F26 / F27 — Бюджет (етап 11) ---------------------------------------
# Двоє дверей, два питання: або вводять свій бюджет, або перевіряють, чи його
# дотримано. Вісь — стаття бюджету, одиниця — рік, а угода про знак така
# сама, що й в операціях: витрата пишеться від’ємною.

window-budget-entry-title = Введення бюджету: заплановані витрати(-) і доходи(+) за рік
window-budget-control-title = Контроль бюджету

budget-column-line = Стаття бюджету
budget-none = Не зареєстровано жодної статті бюджету: бюджет вводиться за статтями.
budget-planned = План
budget-actual = Факт
budget-sum = Сума
budget-cumulative = Накопичено
budget-total = Разом
# Нагадування про угоду щодо знака, червоним під таблицею введення.
# Його фраза, слово в слово і разом із пробілами (знімок «POINT 004 saisie
# budget.png»): вона червоним під таблицею, а заголовок вікна повторює її
# скорочено. Без неї про цю угоду ніхто б не здогадався.
budget-sign-warning = Обов’язково вводьте витрати  зі знаком мінус, а заплановані доходи — додатними сумами
budget-entry-help = Введіть суми в клітинки, потім збережіть.
budget-saved = Бюджет збережено.
budget-nothing-changed = Немає змін для збереження.
budget-discard-question = Скасувати зміни бюджету?

# Меню «Вигляд» у контролі: два способи прочитати те саме відхилення.
budget-menu-display = Вигляд
budget-display-money = Значення
budget-display-percent = Відсотки
budget-control-help = Зелений: не гірше, ніж заплановано. Червоний: гірше.

# --- F09 — Переказ суми між двома рахунками (етап 12) --------------------
# Переказ — це не одна операція, а дві: витрата на рахунку-джерелі і
# надходження на рахунку призначення. Вони йдуть разом або не йдуть зовсім.

window-transfer-title = Переказати суму між двома рахунками

transfer-group-source = Списати суму з цього рахунку-джерела
transfer-group-target = Зарахувати суму на цей рахунок призначення
transfer-group-description = Опис операції
transfer-group-nomenclature = Дані довідника
transfer-group-amount = Сума для переказу
transfer-field-source = Рахунок-джерело
transfer-field-target = Рахунок призначення
transfer-field-label = Опис
transfer-field-reference = Референс платежу
transfer-field-date = Дата
transfer-field-status = Статус операції
transfer-field-clearing = Дата звірки
transfer-field-category = Категорія
transfer-field-mode = Спосіб оплати
transfer-field-assignment = Призначення
transfer-field-payee = Контрагент / продавці
transfer-field-project = Проєкт
transfer-field-amount = Сума

# Єдина кнопка панелей, які повідомляють, а не запитують.
ui-ok = OK
transfer-help = Виберіть обидва рахунки: тут відображаються їхні баланси.
transfer-title-validate = Виконати переказ
# Три баланси вибраного рахунку, щоб знати, що спричиняє переказ.
transfer-balances = { $account } — У банку: { $bank } · Реальний: { $real } · Підсумковий: { $final }
# Панель, яка підсумовує щойно записане.
transfer-done = Переказ виконано. { $amount } з рахунку { $source } на рахунок { $target }, { $date }.

transfer-refusal-accounts-required = Виберіть рахунок-джерело та рахунок-отримувач
transfer-refusal-same-account = Рахунок-джерело та рахунок-отримувач не можуть бути одним і тим самим: переказ іде з одного рахунку на інший
transfer-refusal-account-gone = Одного з двох рахунків більше не існує
transfer-refusal-label-required = Опис є обов'язковим
transfer-refusal-date-required = Дата є обов'язковою
transfer-refusal-amount = Сума переказу має бути строго додатною

# ---------------------------------------------------------------------------
# Фаза 13 — імпортування аркуша Excel (F34, F35, зіставлення).
# ---------------------------------------------------------------------------

window-excel-import-title = Імпортування аркуша excel [ Крок 1/3 ]: визначення зони захоплення
window-excel-fields-title = Імпортування аркуша excel [ Крок 2/3 ]: зіставлення полів
window-excel-association-title = Імпортування аркуша excel: зіставлення даних

# Питання, яке ставиться при відкритті. Файл Excel зроблено вручну:
# він містить те, що містить, і частину безладу, який він несе,
# виявити неможливо. Тому ми пропонуємо страхувальну сітку перед стрибком.
excel-backup-question = Аркуш Excel зроблено вручну: він може містити правильні за виглядом, але хибні дати, суми правильного формату та неправильного знака — і цього не побачить жодна перевірка. Імпортування запише ці рядки до вашого рахунку. Бажаєте зберегти резервну копію даних, перш ніж почати?
excel-backup-later = Резервне копіювання ще не підключене в цій версії Radinus 2. Поки що закрийте Radinus і скопіюйте файл своєї бази даних самостійно: тоді ви зможете імпортувати, нічим не ризикуючи.

excel-group-file = 1 - Вказати файл Excel для імпортування
excel-pick = Вказати файл Excel
excel-sheet = Аркуш книги:
excel-group-header = 2 - Визначити: координати комірок для рядка заголовка таблиці, де записані назви стовпців.
excel-header-row = Номер першого рядка, де розташовані назви стовпців
excel-first-column = Початковий стовпець заголовка ( найлівіший стовпець ):
excel-column-count = Кількість стовпців таблиці
excel-group-rows = 3 - Визначити: номери першого та останнього рядків списку з даними таблиці ( під заголовком і без нього )
excel-first-data-row = Перший рядок, що містить дані
excel-last-data-row = Останній рядок, що містить дані:
excel-group-shape = 4 - Визначити: як ваш файл записує суми
excel-shape-single = Один стовпець сум зі знаком ( витрати від'ємні )
excel-shape-debit-credit = Два окремі стовпці: стовпець Витрата і стовпець Надходження
excel-shape-note = У режимі з двома стовпцями знак, записаний у стовпці Витрата, не враховується: витрата завжди забирає гроші, хай вона позначена «-50» чи «50».
excel-group-test = 5 - Тестовий вигляд: перегляньте виконане захоплення відповідно до ваших налаштувань
excel-test = Перевірте параметри, які ви визначили на кроках 2, 3 і 4.
excel-test-note = Підказка: назви заголовків і вміст наведеної нижче таблиці мають відповідати вашій таблиці Excel. Зона захоплення не повинна виходити за межі таблиці.

excel-help = Пройдіть п'ять груп по порядку, потім перевірте: ви зможете перейти до кроку 2 лише після того, як подивитеся, що захоплює зона.
excel-no-file = Спочатку вкажіть файл Excel для імпортування.
excel-not-tested = Налаштування змінено: перезапустіть тестовий вигляд перед підтвердженням.
excel-tested = Зону захоплено: { $rows } рядків, { $columns } стовпців. Перевірте, чи схожа наведена нижче таблиця на ваш аркуш.
excel-empty-capture = Зона, яку ви вказали, не захоплює жодного рядка: перевірте номери рядків і стовпців.
excel-title-next = Перейти до наступного кроку
excel-into-account = Імпортування до рахунку { $account }.

excel-tab-links = Зв'язки між полями
excel-tab-settings = Параметри імпортування
excel-column-excel = Заголовок_Excel
excel-column-radinus = Рубрика_Radinus
excel-links-help = Навпроти кожного стовпця вашого аркуша вкажіть, яку рубрику Radinus він наповнює. Стовпці, залишені як [IGNORE], не імпортуються.
excel-group-category = Категорії без відповідників
excel-group-payment-mode = Спосіб оплати без відповідників
excel-group-assignment = Призначення без відповідників
excel-policy-create = { $kind ->
    [payment-mode] Автоматично створювати неіснуючі способи оплати
    [assignment] Автоматично створювати неіснуючі призначення
   *[category] Автоматично створювати неіснуючі категорії
}
excel-policy-ask = { $kind ->
    [payment-mode] Запитувати для кожного неіснуючого способу оплати, куди переносити дані
    [assignment] Запитувати для кожного неіснуючого призначення, куди переносити дані
   *[category] Запитувати для кожної неіснуючої категорії, куди переносити дані
}
excel-policy-blank = { $kind ->
    [payment-mode] Залишати спосіб оплати порожнім
    [assignment] Залишати призначення порожнім
   *[category] Залишати категорію порожньою
}
excel-policy-default = { $kind ->
    [payment-mode] Переносити неіснуючі способи оплати до типового способу оплати
    [assignment] Переносити неіснуючі призначення до типового призначення
   *[category] Переносити неіснуючі категорії до типової категорії
}
excel-define-destination = Визначити ціль
excel-not-linked = { $kind ->
    [payment-mode] Жоден стовпець не наповнює спосіб оплати: це налаштування не застосовується.
    [assignment] Жоден стовпець не наповнює призначення: це налаштування не застосовується.
   *[category] Жоден стовпець не наповнює категорію: це налаштування не застосовується.
}
excel-fields-help = Налаштуйте відповідності, а потім три правила, перш ніж запускати імпортування.
excel-title-import = Запустити імпортування

excel-refusal-required = Рубрики Дата, Опис і Сума обов'язково мають вказувати на стовпці excel
excel-refusal-column-twice = Різні рубрики Radinus вказують на той самий стовпець excel: один стовпець може наповнювати лише одну рубрику
excel-refusal-field-twice = Одна й та сама рубрика Radinus пов'язана з двома стовпцями excel: вона може мати лише один
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Ви обрали запитувати, куди переносити невідомі способи оплати: натисніть «Визначити ціль» перед запуском імпортування.
    [assignment] Ви обрали запитувати, куди переносити невідомі призначення: натисніть «Визначити ціль» перед запуском імпортування.
   *[category] Ви обрали запитувати, куди переносити невідомі категорії: натисніть «Визначити ціль» перед запуском імпортування.
}

excel-column-data = Дані_Excel
excel-column-destination = { $kind ->
    [payment-mode] СпосібОплати_Radinus
    [assignment] Призначення_Radinus
   *[category] Категорія_Radinus
}
excel-association-help = Навпроти кожного значення з вашого аркуша виберіть те значення Radinus, до якого воно має бути віднесене. Рядок, залишений порожнім, лишиться без класифікації.
excel-association-none = Немає невідомих значень: усе, що містить ваш аркуш, уже існує в Radinus.

excel-imported = Імпортування завершено: записано операцій — { $count }, відхилено рядків — { $refused }, створено значень довідника — { $created }.
excel-report-title = Звіт про імпортування
excel-column-row = Рядок Excel
excel-column-content = Вміст
excel-column-reason = Причина відхилення
excel-nothing-refused = Усі рядки вашого аркуша внесено: жодного відхилення.

excel-refused-date = Дата відсутня або нечитабельна
excel-refused-amount = Сума відсутня або нечитабельна
excel-refused-amount-both = Одна сума у стовпці Витрата, інша у стовпці Надходження: неможливо обрати
excel-refused-amount-missing = У цьому рядку немає ні витрати, ні надходження

# ---------------------------------------------------------------------------
# Фаза 16 — періодичні операції (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Список періодичних операцій
window-recurring-form-title = Картка, що визначає правило генерування періодичної операції
window-recurring-calendar-title = Пропозиція календаря операцій для вставлення до ваших банківських рахунків

recurring-column-label = ОПИС
recurring-none = Немає збережених періодичних правил.
recurring-help = Виберіть правило, а потім календар, щоб побачити терміни, які воно пропонує.
recurring-title-calendar = Запропонувати календар термінів
recurring-deleted = { $count ->
    [0] Жодного правила не видалено.
    [one] Видалено { $count } правило. Його операції залишаються на рахунку.
    [few] Видалено { $count } правила. Їхні операції залишаються на рахунках.
    [many] Видалено { $count } правил. Їхні операції залишаються на рахунках.
   *[other] Видалено { $count } правила. Їхні операції залишаються на рахунках.
}
recurring-gone = Цього правила більше не існує.
recurring-delete-question = Видалити вибрані правила? Операції, які вони вже вставили, залишаться на ваших рахунках.

recurring-group-identity = Ідентифікація та відповідний банківський рахунок
recurring-group-nomenclature = Довідник
recurring-group-amount = Визначення суми операції
recurring-group-period = Визначення періоду
recurring-group-ending = Умови завершення періоду
recurring-group-produced = Відомості про вже вставлені операції ( лише для перегляду )

recurring-field-id = Ідентифікатор операції
recurring-field-account = Цільовий рахунок
recurring-field-label = Опис
recurring-field-category = Категорія
recurring-field-mode = Спосіб оплати
recurring-field-assignment = Призначення
recurring-field-payee = Контрагент / продавці
recurring-field-project = Проєкт
recurring-field-direction = Тип операції
recurring-field-amount = Сума
recurring-field-next = Дата наступної операції
recurring-field-every = Потім кожні
recurring-field-end-date = Дата завершення
recurring-field-repeat = Кількість повторень
recurring-field-guid = GUID операції
recurring-field-produced-count = Кількість вставлених операцій
recurring-field-produced-last = Дата останньої вставленої операції
recurring-field-produced-total = Загальна сума згенерованих операцій

recurring-unit-day = День
recurring-unit-week = Тиждень
recurring-unit-month = Місяць
recurring-unit-quarter = Квартал
recurring-unit-year = Рік
recurring-ending-no-limit = Без обмеження
recurring-ending-until-date = З датою завершення
recurring-ending-repeat-count = Кількість повторень

recurring-title-erase = Видалити операції, вже вставлені цим правилом
recurring-erase-question = { $count ->
    [one] Це правило вставило { $count } операцію до ваших рахунків. Бажаєте її видалити? Баланси буде перераховано, а правило не відкотиться назад.
    [few] Це правило вставило { $count } операції до ваших рахунків. Бажаєте видалити їх усі? Баланси буде перераховано, а правило не відкотиться назад.
    [many] Це правило вставило { $count } операцій до ваших рахунків. Бажаєте видалити їх усі? Баланси буде перераховано, а правило не відкотиться назад.
   *[other] Це правило вставило { $count } операції до ваших рахунків. Бажаєте видалити їх усі? Баланси буде перераховано, а правило не відкотиться назад.
}
recurring-erase-none = Це правило ще не вставило жодної операції.
recurring-erased = { $count ->
    [0] Жодної операції не видалено.
    [one] Видалено { $count } операцію, баланси перераховано.
    [few] Видалено { $count } операції, баланси перераховано.
    [many] Видалено { $count } операцій, баланси перераховано.
   *[other] Видалено { $count } операції, баланси перераховано.
}

recurring-calendar-help = Приберіть кошиком терміни, яких ви не хочете, потім підтвердьте, щоб їх вставити.
recurring-calendar-none = Немає термінів для пропозиції: перевірте дату наступної операції та рахунок ваших правил.
recurring-calendar-column-account = Рахунок
recurring-calendar-column-date = Дата
recurring-calendar-column-label = Опис
recurring-calendar-column-amount = Сума
recurring-calendar-column-category = Категорія
recurring-calendar-column-assignment = Призначення
recurring-calendar-column-mode = Спосіб оплати
recurring-calendar-column-payee = Контрагент
recurring-calendar-column-project = Проєкти
recurring-calendar-removed = { $count ->
    [one] Прибрано { $count } термін із пропозиції.
    [few] Прибрано { $count } терміни з пропозиції.
    [many] Прибрано { $count } термінів із пропозиції.
   *[other] Прибрано { $count } терміни з пропозиції.
}
recurring-title-insert = Вставити вибрані терміни до рахунків
recurring-nothing = Не залишилося жодного терміну для вставлення.
# Питання, яке ставиться перед записом: вставлення календаря створює справжні
# операції на справжніх рахунках, і це не робиться неуважним клацанням.
recurring-insert-question = { $count ->
    [one] Вставити { $count } термін до вашого рахунку? Буде створено операцію, а баланси перераховано.
    [few] Вставити ці { $count } терміни до ваших рахунків? Буде створено стільки ж операцій, а баланси перераховано.
    [many] Вставити ці { $count } термінів до ваших рахунків? Буде створено стільки ж операцій, а баланси перераховано.
   *[other] Вставити ці { $count } терміни до ваших рахунків? Буде створено стільки ж операцій, а баланси перераховано.
}
recurring-inserted = { $count ->
    [one] Вставлено { $count } операцію. Правило продовжиться після останнього вставленого терміну.
    [few] Вставлено { $count } операції. Правила продовжаться після свого останнього вставленого терміну.
    [many] Вставлено { $count } операцій. Правила продовжаться після свого останнього вставленого терміну.
   *[other] Вставлено { $count } операції. Правила продовжаться після свого останнього вставленого терміну.
}

recurring-refusal-label-required = Введення опису є обов'язковим
recurring-refusal-date-required = Введення дати наступної операції є обов'язковим
recurring-refusal-date-too-old = Дата наступної операції має бути не раніше 2000 року
recurring-refusal-account-gone = Вказаний банківський рахунок не знайдено, виберіть новий, щоб правило можна було застосувати
recurring-refusal-end-required = Якщо задано дату завершення, її потрібно ввести
recurring-refusal-end-before-start = Дата завершення не може бути раніше дати наступної операції
recurring-refusal-end-too-far = Різниця між датою наступної операції та датою завершення не може перевищувати 10 000 днів

# --- Фаза 15 — друк і звіти ---------------------------------------------
# Великий заголовок банера, узятий слово в слово з початкового звіту WinDev.
print-operations-title = Список банківських транзакцій і підоперацій
print-menu-operations-pdf = Друк у файл PDF
print-recap-title = Підсумок за категоріями
print-recap-count = Рядки
print-row-count = Кількість рядків:
print-total-debit = Разом витрат:
print-total-credit = Разом надходжень:
print-final-balance = Підсумковий баланс:
print-licence = Radinus — вільна програма, що поширюється за ліцензією GNU GPL v3 або новішою
print-nothing = Немає чого друкувати.
print-done = Звіт надруковано та відкрито: «{ $file }».
print-failed = Друк неможливий: { $reason }
# PDF таки записано, але система не змогла його відкрити: кажемо про це, не
# вдаючи невдачу, адже файл на місці.
print-not-opened = Звіт надруковано у «{ $file }», але ваша система не змогла відкрити його сама.

# --- Звіт RIB (F32) -----------------------------------------------------
# Назви полів банківських реквізитів, узяті з початкового документа.
rib-title = БАНКІВСЬКІ РЕКВІЗИТИ
rib-bank = Банк:
rib-national = RIB - Національний ідентифікатор рахунку
rib-establishment = УСТАНОВА
rib-branch = ВІДДІЛЕННЯ
rib-number = НОМЕР РАХУНКУ
rib-key = КЛЮЧ RIB
rib-domiciliation = МІСЦЕ ВЕДЕННЯ РАХУНКУ
rib-iban = IBAN - Міжнародний ідентифікатор рахунку
rib-bic = BIC - Міжнародний ідентифікатор установи
rib-holder = Власник рахунку

# --- Вікно F32 ----------------------------------------------------------
window-rib-title = Друк RIB ( банківські реквізити )
rib-group-bank = Банк
rib-group-holder = Власник рахунку
rib-group-details = Банківські реквізити
rib-field-bank = Назва банку
rib-field-domiciliation = Місце ведення рахунку
rib-field-holder = Ім'я власника
rib-field-address = Адреса
rib-field-establishment = Установа
rib-field-branch = Відділення
rib-field-number = Номер рахунку
rib-field-key = Ключ RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Важливі умови використання, обов'язкові до дотримання в разі друку
rib-declaration = Я, користувач програми, що нижче підписався, заявляю під слово честі:
rib-declaration-first = - Підтверджую, що перевірив у своєму банку, що банківські відомості, наведені в цьому вікні, правильні та відповідають моїй волі . Так само підтверджую, що зобов'язуюся перевірити, що відомості, наведені в друкованому звіті RIB, правильні та відповідають моїй волі. Цей друк і використання RIB відбуватимуться під мою повну відповідальність
rib-declaration-second = - Що я є власником рахунку, RIB якого буде надруковано, і не використовую функції цієї програми з метою, що суперечить закону.
rib-title-print = Друк на принтері
rib-title-pdf = Друк у файл PDF
# Ця позначка не є декоративним попередженням: доки її не поставлено, обидві
# кнопки вимкнені (рішення Fabrice, 01/08/2026).
rib-declaration-required = Позначте заяву під слово честі, щоб можна було друкувати.
rib-help = Перевірте свої реквізити, позначте заяву, потім друкуйте.
rib-account-gone = Цей банківський рахунок не знайдено.
rib-fields-read-only = Ці реквізити беруться з картки рахунку: щоб змінити їх тут, виправте їх у картці.
rib-printed = RIB надіслано на ваш типовий принтер.
rib-print-failed = Друк неможливий: { $reason }
rib-pdf-done = RIB надруковано та відкрито: «{ $file }».
rib-pdf-not-opened = RIB надруковано у «{ $file }», але ваша система не змогла відкрити його сама.
menu-accounts-bank-details = Надрукувати банківські реквізити

# Вибір принтера. Radinus сам ставить це запитання: жоден із трьох
# webview не відкриває системного діалогу друку.
print-choose-printer = На якому принтері ви хочете друкувати?
print-do-print = Друкувати
rib-printed-on = RIB надіслано на принтер «{ $printer }».
ui-cancel = Скасувати

# Система не змогла назвати жодного принтера: усе одно друкуємо на типовому,
# аби не блокувати користувача.
print-printers-unknown = Ваша система не змогла назвати жодного принтера: документ пішов на типовий принтер.

print-menu-operations-printer = Друк на принтері
print-sent-on = Звіт надіслано на принтер «{ $printer }».
print-sent-default = Звіт надіслано на ваш типовий принтер.

# --- Фаза 17 — операції з базою даних -----------------------------------
backup-archive = Архів Radinus
backup-no-database = Жодної бази даних не відкрито.
backup-done = Резервну копію записано у «{ $file }».
backup-failed = Резервне копіювання неможливе: { $reason }
restore-unreadable = Цей файл не є придатним для читання архівом Radinus: { $reason }
# Запитання каже, що буде втрачено, перш ніж це втратити. Архів на цей момент
# уже прочитано: те, що воно повідомляє, є достеменним.
restore-question = Відновити «{ $file }»? Увесь поточний вміст вашої бази буде стерто й замінено, а те, що в ній є, буде втрачено.
restore-done = Відновлення завершено: { $accounts } рахунків і { $operations } операцій.
restore-failed = Відновлення неможливе: { $reason }
restore-empty-fields = Порожні поля, прочитані як нульове значення: { $count }.


# --- Журнал технічних операцій (фаза 17) --------------------------------
# Три статуси його Ajoute_Log, великими літерами, як у нього.
journal-status-success = УСПІХ
journal-status-failure = НЕВДАЧА
journal-status-repaired = ВИПРАВЛЕНО
journal-step-reindex = Відновлення цілісності таблиці БД
journal-step-refill = Системний довідник порожній: типові значення відновлено
journal-step-table-created = Таблиця відсутня в базі: створена заново порожньою
journal-step-column-added = Стовпець відсутній у таблиці: додано зі значенням за умовчанням

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Захист паролем
window-password-form-title = Захист паролем
password-ask = Ця база захищена. Введіть її пароль.
password-group-database = Задіяна база
password-group-password = Пароль
password-group-warning = Перш ніж підтвердити
password-field-old = Старий пароль
password-field-new = Новий пароль
password-field-repeat = Повторіть новий пароль
password-hint = Залиште старий порожнім, якщо база ще не захищена. Залиште обидва нові порожніми, щоб зняти захист.
password-lost-warning = Втрачений пароль — втрачена база: відновити її неможливо. Резервні копії натомість залишаються незашифрованими.
password-show = Показати пароль
password-remove-question = Зняти захист із цієї бази?
password-mismatch = Два введення нового пароля різняться
password-wrong = Пароль не підходить
password-close-first = Закрийте цю базу, перш ніж міняти її пароль
password-now-protected = База захищена паролем
password-now-clear = База більше не захищена
journal-step-date-fixed = Виправлення операції без дати
journal-step-circular = Видалення суперечливої операції: циклічне посилання
journal-step-flag-parent-true = Неправильний прапорець EstParent=Faux в основній операції
journal-step-flag-parent-false = Неправильний прапорець EstParent=Vrai в основній операції
journal-step-flag-child = Неправильний прапорець EstParent=Vrai в підоперації
journal-step-orphan = Видалення осиротілої підоперації
journal-step-third-level = Видалення підоперації, прив'язаної до іншої підоперації
journal-step-coherence = Загальний перерахунок узгодженості між підопераціями та основними операціями
journal-step-balances = Перерахунок усіх балансів усіх рахунків
journal-step-vacuum = Оптимізація файлу бази даних
journal-step-analyze = Оновлення статистики пошуку
journal-step-backup-begin = Початок резервного копіювання бази
journal-step-backup-end = Кінець резервного копіювання бази
journal-step-restore-begin = Початок відновлення бази з архіву
journal-step-restore-end = Кінець відновлення бази з архіву
journal-step-restore-read = Читання архіву

# --- Вікно журналу (⌘H) -------------------------------------------------
window-journal-title = Журнал останньої технічної операції
journal-column-step = Етап
journal-column-file = Файл
journal-column-table = Таблиця
journal-column-status = Статус
journal-column-error = Помилка
journal-column-comments = Коментарі
journal-empty = Від часу запуску програми ще не виконано жодної технічної операції.
journal-help = Журнал зберігає лише останню технічну операцію: резервне копіювання, відновлення, відновлення цілісності, стирання або відкриття бази.

# --- Відновлення цілісності ---------------------------------------------
menu-file-repair-running = Триває відновлення цілісності та оптимізація…
repair-done = { $anomalies ->
    [0] Відновлення цілісності завершено: аномалій не знайдено. Записано етапів у журнал: { $lines }.
    [one] Відновлення цілісності завершено: виправлено { $anomalies } аномалію. Записано етапів у журнал: { $lines }.
    [few] Відновлення цілісності завершено: виправлено { $anomalies } аномалії. Записано етапів у журнал: { $lines }.
    [many] Відновлення цілісності завершено: виправлено { $anomalies } аномалій. Записано етапів у журнал: { $lines }.
   *[other] Відновлення цілісності завершено: виправлено { $anomalies } аномалії. Записано етапів у журнал: { $lines }.
}
repair-failed = Відновлення цілісності неможливе: { $reason }

journal-status-started = ВИКОНУЄТЬСЯ
journal-status-finished = ЗАВЕРШЕНО
journal-step-backup-table = Запис таблиці в архів
journal-step-backup-write = Запис архіву
journal-step-backup-verified = Перевірка записаного архіву: файлів перечитано / очікувалося, записів перечитано / записано
journal-step-backup-total = Усього збережено: записів, даних, розмір файлу
journal-step-restore-table = Читання таблиці з архіву
journal-step-restore-missing = Файл відсутній в архіві: цю таблицю не буде відновлено
journal-step-restore-wipe = Повне стирання вмісту бази перед відновленням
journal-step-restore-write = Запис у базу
journal-step-restore-total = Усього відновлено: рахунків, операцій
journal-step-restore-empty-fields = Порожні поля, заповнені під час читання
backup-verify-mismatch = Записаний архів читається не таким, яким його було записано: не покладайтеся на нього, зробіть резервну копію заново.

# --- Вкладення операції (F28, фаза 17) ----------------------------------
window-attachments-title = Вкладення операції
attachment-filter = Дозволені документи
attachment-none = Ця операція не має жодного вкладення.
attachment-title-add = Долучити документ до цієї операції
attachment-title-open = Відкрити вкладення
attachment-title-remove = Вилучити вкладення та надіслати його файл до кошика
# Стан файлу на диску. «Невідомо» — не марне зізнання в незнанні: контрольні
# суми, що прийшли з Radinus 1.9.3, урізані форматом збереження, і судити за
# ними про файл означало б звинувачувати навмання.
attachment-state-ok = Незмінене
attachment-state-changed = Змінене
attachment-state-missing = Файл відсутній
attachment-state-unknown = Не перевіряється
attachment-added = «{ $name }» долучено до операції.
attachment-removed = Вкладення вилучено, його файл у кошику.
attachment-removed-kept = Вкладення вилучено, але його файл не вдалося помістити до кошика.
attachment-remove-question = Вилучити «{ $name }» з цієї операції? Його файл буде надіслано до кошика.
attachment-opened = «{ $name }» відкрито.
attachment-opened-changed = «{ $name }» відкрито, але його вміст змінився відтоді, як його було долучено.
attachment-gone = Цього вкладення більше не існує.
attachment-file-missing = Файл «{ $name }» не знайдено на диску.
attachment-failed = Операція неможлива: { $reason }
attachment-save-first = Спочатку збережіть операцію: вкладення долучається до операції, яка існує.
attachment-refusal-missing = Цей файл не існує.
attachment-refusal-extension = Цей тип файлу не приймається. Приймаються: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Операція, до якої треба долучити цей документ, не існує.
journal-step-backup-attachments = Вкладення додано до архіву
journal-step-backup-attachment-missing = Вкладення не знайдено на диску: його бракуватиме в архіві
journal-step-restore-attachments = Вкладення видобуто з архіву
attachment-title-replace = Замінити документ цього вкладення
attachment-replaced = Документ замінено на «{ $name }».

# ---------------------------------------------------------------------
# F08 — меню «Інструменти» картки рахунку.
#
# Три його пункти — це перенесення WLangage від Fabrice (тека
# « Information import export base piece jointe »): обчислення
# початкового звіреного балансу, статистика рахунку та видалення всіх
# його транзакцій. Меню діє лише в режимі зміни (рішення від
# 02/08/2026): при створенні нема чого рахувати, у режимі перегляду
# картка лише показує.
# ---------------------------------------------------------------------

account-tools = Інструменти
account-tools-initial-balance = Задати початковий звірений баланс
account-tools-statistics = Статистика банківського рахунку
account-tools-delete-operations = Видалити всі транзакції рахунку

# Запитання розрахунку, слово в слово як в оригіналі. { $total } — це
# підсумок звірених операцій, уже записаний у грошовому форматі.
account-initial-balance-question =
    Щоб обчислити початковий звірений баланс з огляду на операції, наявні на цьому рахунку, укажіть поточний баланс у вашому банку
    Початковий звірений баланс буде обчислено як:
    { "[" }Поточний банківський баланс] - [Підсумок звірених операцій ({ $total }) ].
    { "" }
    Щоб не вводити це значення заново, список банківських операцій на цьому рахунку має бути повністю актуальним.

account-statistics-none = Немає транзакцій

# Чотирнадцять рядків його Info(). Друкарську помилку «pengagés» в оригіналі
# виправлено за рішенням Fabrice від 02/08/2026 — як і «Bank
# Identifer Code» на цій самій картці.
account-statistics =
    Загальна кількість транзакцій на цьому рахунку: { $count }
    { "" }
    Кількість звірених транзакцій на цьому рахунку: { $pointed }
    Сума звірених витрат: { $pointedDebits }
    Сума звірених надходжень: { $pointedCredits }
    Різниця між звіреними надходженнями та витратами: { $pointedDifference }
    { "" }
    Кількість зарезервованих транзакцій на цьому рахунку: { $committed }
    Сума зарезервованих витрат: { $committedDebits }
    Сума зарезервованих надходжень: { $committedCredits }
    Різниця між зарезервованими надходженнями та витратами: { $committedDifference }
    { "" }
    Кількість запланованих транзакцій на цьому рахунку: { $planned }
    Сума запланованих витрат: { $plannedDebits }
    Сума запланованих надходжень: { $plannedCredits }
    Різниця між запланованими надходженнями та витратами: { $plannedDifference }
    { "" }
    Найдавніша транзакція: { $first }
    Найновіша транзакція: { $last }

# Подвійний бар'єр під час видалення. { $word } — це «так» повсякденною мовою
# користувача: іспаномовний, якого попросили б написати OUI, не
# зрозумів би (рішення Fabrice, 02/08/2026).
account-delete-operations-question =
    Ви впевнені, що хочете видалити всі операції, які містяться в банківському рахунку?
    Для підтвердження напишіть { $word } у полі нижче та підтвердьте

account-delete-operations-done =
    { $count ->
        [0] Жодної транзакції не видалено.
        [one] Видалено { $count } транзакцію.
        [few] Видалено { $count } транзакції.
        [many] Видалено { $count } транзакцій.
       *[other] Видалено { $count } транзакції.
    }

# ---------------------------------------------------------------------
# Селектор бази та вибір мови (02/08/2026)
#
# Рішення, ухвалені в обговоренні з Fabrice: Radinus більше не створює
# базу без дозволу; без мови в конфігурації він запитує мову
# перед усім іншим; базою є будь-яка тека з databases/, яка
# містить radinus.sqlite, хоч би яка була її назва.
#
# У вікна вибору мови тут немає жодного ключа: воно не вживає
# жодної фрази, і саме це дозволяє зрозуміти його перш ніж
# стане відомо, якою мовою говорить користувач.
# ---------------------------------------------------------------------

window-database-selector-title = Бази даних
window-database-form-title = Нова база даних
database-group-identity = Ідентифікація бази даних
database-group-restore = Ініціалізувати базу даними з резервної копії
database-choose-backup = Вибрати файл резервної копії
database-no-backup = Резервну копію не вибрано: база буде створена порожньою.

databases-column-label = База
databases-column-comment = Коментар
databases-column-folder = Тека
databases-column-created = Створена

databases-none = Поки що немає жодної бази: створіть її.
databases-help = Виберіть базу, яку відкрити, або створіть нову.
databases-select = Спершу виберіть базу зі списку.
databases-tools = Інструменти
databases-title-open = Відкрити цю базу

database-created = Базу «{ $label }» створено.
database-field-label = Назва бази
database-field-comment = Коментар
database-label-required = Дайте цій базі назву: саме вона відрізнятиме її від інших.
database-gone = Цієї бази більше немає: її переміщено або видалено після відкриття цього вікна.

# Видалення бази (02/08/2026). Її тека вирушає до системного кошика, як і
# вкладення: базу, видалену помилково, можна повернути правою кнопкою миші.
# Відкриту базу видалити не можна — Radinus тримає її файл.
databases-title-delete = Видалити цю базу
database-delete-question =
    Ви впевнені, що хочете видалити базу «{ $label }»?
    { "" }
    Уся її тека вирушить до кошика: операції, рахунки та вкладення.
    Для підтвердження напишіть { $word } у полі нижче та підтвердьте.
database-in-use = Ця база відкрита: Radinus не може її видалити. Спершу відкрийте іншу.
database-deleted = База «{ $label }» у кошику.

# Селектор має два режими (Fabrice, 02/08/2026). Відкритий під час роботи, він
# більше не вміє відкривати: вікно Radinus будується один раз і ніколи не
# знищується, і ніщо не змусить його забути базу, яку воно показує.
# Її переглядають, створюють, видаляють — а щоб змінити базу, виходять із
# програми.
database-quit-first = Щоб відкрити цю базу, вийдіть із Radinus і запустіть його знову: селектор запропонує її вам під час запуску.


# --- F01 — вікно привітання (фаза 17 bis, 03/08/2026) --------------------
#
# Перше доповнення 2.0.0 до 1.9.3: вікно привітання більше не несе саму лише
# шапку. Правило, що ним керує, записане в документі 04 F01:
# це вигляд БЕЗ ЄДИНОГО КЛАЦАННЯ, і ніщо, що потребує налаштування, туди не входить.
#
# Обидві назви кільцевих діаграм несуть увесь місяць, замість того щоб вікно
# склеювало їх встик: «Витрати ... — серпень 2026» не має того самого порядку
# слів у трьох мовах, і лише Fluent знає, де підстановка.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Немає відкритих рахунків
    [one] { $count } відкритий рахунок
    [few] { $count } відкриті рахунки
    [many] { $count } відкритих рахунків
   *[other] { $count } відкриті рахунки
}
welcome-total-bank = Банківський баланс
welcome-total-real = Реальний баланс
welcome-total-final = Підсумковий баланс
welcome-total-real-detail = звірено + зарезервовано
welcome-total-final-detail = звірено + зарезервовано + заплановано
welcome-accounts = Ваші рахунки
welcome-tile-bank = У банку
welcome-tile-real = Реальний
welcome-tile-final = Підсумковий
welcome-spending = Витрати — { $month }
welcome-earning = Надходження — { $month }
ui-legend-budget-lines = Статті бюджету
ui-legend-categories = Категорії
welcome-nothing = Цього місяця немає жодної операції.
welcome-open-account = Інформація: клацніть на рахунку, щоб відкрити його операції.
welcome-no-account = Поки немає жодного банківського рахунку.
welcome-no-account-create = Створіть банківський рахунок, натиснувши тут
welcome-previous-month = Попередній місяць
welcome-next-month = Наступний місяць
welcome-refresh = Перечитати все


# --- F39 — параметри (фаза 17 ter, 03/08/2026) ---------------------------
#
# Місце знака валюти живе тут, поряд із двома роздільниками: воно залежить від
# мови, а не від валюти. «before» ставить знак перед числом, будь-яке інше
# значення ставить його після. ЖОДНОГО знака валюти не записано в цьому
# файлі: «українська» не означає «гривня».

ui-money-sign-position = after
window-preferences-title = Параметри
menu-settings-preferences = Параметри…
menu-settings-show-main = Показати головне вікно
menu-settings-folders = Теки Radinus
preferences-branch-display = Відображення
preferences-leaf-language = Мова
preferences-leaf-currency = Валюта
preferences-field-language = Мова програми:
preferences-field-currency = Валюта відображення:
preferences-field-custom = Знак валюти:
preferences-currency-system = Системна валюта
preferences-currency-euro = Євро
preferences-currency-dollar = Долари
preferences-currency-canadian = Канадські долари
preferences-currency-cfa = Франки КФА
preferences-currency-cfp = Тихоокеанські франки
preferences-currency-swiss = Швейцарські франки
preferences-currency-none = Жодної
preferences-currency-custom = Власний
preferences-currency-system-is = Ваша система повідомляє:
preferences-currency-system-silent = Ваша система не повідомляє жодної валюти: суми відображатимуться в євро.
preferences-custom-required = Введіть знак вашої валюти перед збереженням.
preferences-saved = Параметри збережено.
preferences-help = Виберіть пункт у дереві, потім збережіть.
preferences-sign-too-long = Знак валюти вміщується щонайбільше у 8 символів.
preferences-sign-not-a-number = Знак валюти не може містити ні цифри, ні знака дії, ні коми: Radinus прибирає їх, коли читає суму, і «120» перетворилося б на «12».
preferences-leaf-zoom = Розмір відображення
preferences-field-zoom = Збільшення:
preferences-zoom-reset = Значення за замовчуванням
preferences-zoom-hint = Усе збільшується разом: текст, піктограми, стовпці. Нижче 100 % на екрані вміщується більше. А рядок меню системи та його діалогові вікна підпорядковуються налаштуванням вашого комп'ютера, а не цим.

# --- Шапка вікна привітання ----------------------------------------------
#
# Ці фрази були жорстко записані в `index.html` від фази 0 і тому не
# перекладалися (помічено Fabrice 03/08/2026). Девіз — це його голос:
# англійська та іспанська версії є пропозиціями, які йому належить
# виправити — слоган не перекладається слово в слово.
ui-language-tag = uk
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — білка-талісман у костюмі, в оточенні євро, калькулятора та графіків
welcome-slogan-one = Програма для керування особистими фінансами, яка допомагає вам витрачати менше, щоб заробляти більше
welcome-slogan-two = З Radinus ви зрозумієте, чому з малих струмків постають великі річки.

# --- «Про автора» --------------------------------------------------------
#
# Ім'я та адреса записані однаково у трьох файлах: вони не перекладаються. Вони
# все ж тут, а не на сторінці, щоб вигляд не ніс жодної фрази — і щоб їх можна
# було виправити в одному-єдиному місці того дня, коли автор переїде.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Про автора
about-author-flag-alt = Прапор Корсики — голова мавра

# --- «Про Radinus» -------------------------------------------------------
#
# `about-radinus-version` несе підстановку: номер приходить від двійкового
# файлу, що працює, а ніколи від переписаного рядка. Тому її немає у
# словнику вікон — заповнює її команда `app_version`.
window-about-radinus-title = Про Radinus
about-radinus-name = Radinus
about-radinus-version = Версія { $version }
about-radinus-rust-alt = Логотип мови Rust
about-radinus-tauri-alt = Логотип Tauri
about-radinus-built = Radinus написаний на Rust і побудований за допомогою Tauri. Перший обчислює ваші рахунки, другий робить із цього застосунок для комп'ютера.
about-radinus-licence = Вільне програмне забезпечення, ліцензія GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Ліцензія
licence-heading = ЛІЦЕНЗІЯ НА ВИКОРИСТАННЯ ПРОГРАМИ RADINUS
licence-logo-alt = Логотип GNU General Public License версії 3
licence-name = GNU GPL v3 або новіша
licence-intro = Radinus — вільна програма.
licence-freedoms-title = Її ліцензія дає вам чотири свободи:
licence-freedom-use = Використовувати її як завгодно і для чого завгодно.
licence-freedom-study = Вивчати її вихідний код, відкритий для всіх.
licence-freedom-share = Копіювати її та передавати іншим.
licence-freedom-improve = Змінювати її та ділитися своїми змінами.
licence-read = Прочитати повний текст ліцензії

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Ця програма надається без жодних гарантій, у межах, дозволених законом.
licence-info = Офіційний текст відкриється у вашому браузері, на gnu.org.

