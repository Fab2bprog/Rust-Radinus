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
menu-statistics-balance-analysis = Аналіз зміни балансу
menu-statistics-by-category = Статистика за категоріями
menu-statistics-by-assignment = Статистика за призначеннями
menu-statistics-by-budget-line = Статистика за статтями бюджету
menu-statistics-by-payment-mode = Статистика за способами оплати
menu-statistics-by-payee = Статистика за контрагентами та продавцями
menu-statistics-by-project = Статистика за проєктами
menu-statistics-by-verification = Статистика за перевіркою
menu-statistics-dashboard = Зведена панель операцій
menu-statistics-crossed-balance = Перехресний баланс

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

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Інструменти
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
operations-column-status = Статус операції
operation-status-pointed = Звірена
operation-status-committed = Зарезервована
operation-status-planned = Запланована
operations-column-verification = Перевірка
operation-verification-to-verify = До перевірки
operation-verification-verified = Перевірена
operation-verification-doubtful = Сумнівна
operation-verification-disputed = Оскаржена
operations-column-label = Опис
operations-column-reference = Референс платежу
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
filter-by-status = Фільтр за статусом
filter-by-verification = Фільтр за перевіркою
filter-show-all = Показати все

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
operation-field-verification = Перевірка
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
operation-clearing-date-required = Проведена операція обов'язково повинна мати дату проведення.
operation-clearing-date-question =
    Проведена операція обов'язково повинна мати дату проведення.
    Зберегти з датою операції — { $date }?
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
    [0] Немає операцій для звірки: виділені вже звірено.
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
operations-recurring-from = Створити періодичну операцію на основі цієї операції

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
    [verification] Статистика за перевіркою
   *[category] Статистика за категоріями
}

statistics-axis-column = { $kind ->
    [assignment] Призначення
    [budget-line] СтаттяБюджету
    [payment-mode] СпосібОперації
    [payee] Контрагент
    [project] Проєкти
    [verification] Перевірка
   *[category] НазваКатегорії
}

statistics-unclassified = { $kind ->
    [assignment] Без призначення
    [budget-line] Без статті бюджету
    [payment-mode] Без способу оплати
    [payee] Без контрагента
    [project] Без проєкту
    [verification] До перевірки
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

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Перехресний баланс
crossed-balance-window-name = Перехресний баланс
crossed-balance-column = Категорія
crossed-balance-no-data = Немає операцій за цей місяць для обраних рахунків.
crossed-balance-month-question = З яким місяцем працювати? Число від { $first } до { $last }.
crossed-balance-month-choose = Обрати місяць
crossed-balance-next = Наступний місяць
crossed-balance-previous = Попередній місяць

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
export-to = Експорт до
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Копіювати клітинку
copy-rows = Копіювати вибрані рядки
copy-failed = Не вдалося скопіювати до буфера обміну.
export-all-years-excel = Експортувати всі роки до Excel
export-all-years-ods = Експортувати всі роки до LibreOffice Calc
export-all-months-excel = Експортувати всі місяці показаного року в Excel
export-all-months-ods = Експортувати всі місяці показаного року в LibreOffice Calc
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
    [verification] Статистика за перевіркою
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

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Аналіз динаміки балансу
analysis-heading = Аналіз динаміки балансу
analysis-hint = Проведіть по графіку, утримуючи кнопку миші, щоб побачити операції за цей період.
analysis-zone = Зона:
analysis-opening = Баланс на початок:
analysis-closing = Баланс на кінець:
analysis-variation = Зміна:
analysis-detail-name = Аналіз балансу
analysis-detail-none = У цій зоні немає жодної операції.

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
quick-check-verification = Перевірка
quick-column-date = Дата
quick-column-label = Опис
quick-column-amount = Сума
quick-column-category = Категорія
quick-column-assignment = Призначення
quick-column-payment-mode = Спосіб оплати
quick-column-payee = Контрагент
quick-column-project = Проєкти
quick-column-status = Статус
quick-column-verification = Перевірка
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
statement-column-reference = Референс платежу
statement-column-debit = Витрата
statement-column-credit = Надходження
statement-account = Рахунок
statement-file = Файл
statement-difference = Різниця
statement-none = Жодної виписки не відкрито: натисніть на жовту теку, щоб вибрати файл (OFX, CSV, QIF).
statement-empty = Ця виписка не містить жодної операції.
statement-no-match = Жоден рядок не відповідає фільтру.
statement-help = Інфо: використовуйте клацання мишею + клавішу [{ $modifier }] у таблиці, щоб вибрати кілька рядків
statement-choose-account = Цей файл містить кілька рахунків. Який з них ви хочете імпортувати?
statement-select-line = Виберіть щонайменше один рядок виписки.
statement-title-open = Відкрити файл виписки (OFX, QIF, CSV)
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
statement-loaded-unidentified = { $alike ->
    [0] Прочитано рядків: { $count }; жоден не схожий на операцію, яка вже є на вашому рахунку.
    [one] Прочитано рядків: { $count }, з них { $alike } схожий на операцію, яка вже є на вашому рахунку (та сама дата, той самий опис, та сама сума).
    [few] Прочитано рядків: { $count }, з них { $alike } схожі на операції, які вже є на вашому рахунку (та сама дата, той самий опис, та сама сума).
    [many] Прочитано рядків: { $count }, з них { $alike } схожі на операції, які вже є на вашому рахунку (та сама дата, той самий опис, та сама сума).
   *[other] Прочитано рядків: { $count }, з них { $alike } схожі на операції, які вже є на вашому рахунку (та сама дата, той самий опис, та сама сума).
}
statement-loaded-also-alike = { $alike ->
    [one] Ще { $alike } схожий на операцію, яка вже є (та сама дата, той самий опис, та сама сума).
    [few] Ще { $alike } схожі на операції, які вже є (та сама дата, той самий опис, та сама сума).
    [many] Ще { $alike } схожі на операції, які вже є (та сама дата, той самий опис, та сама сума).
   *[other] Ще { $alike } схожі на операції, які вже є (та сама дата, той самий опис, та сама сума).
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
statement-qif-question = Ніщо в цьому файлі не вказує, чи дату «{ $date }» записано як день/місяць чи як місяць/день. Вона означає:
statement-qif-day-month = День { $day }, місяць { $month } (день/місяць)
statement-qif-month-day = День { $day }, місяць { $month } (місяць/день)
statement-qif-dates-mixed = У цьому файлі дати записано двома способами: «{ $first }» читається як день/місяць, «{ $second }» — як місяць/день. Файл не імпортується, щоб жодна дата не була спотворена.
statement-qif-amounts-mixed = У цьому файлі суми записано двома способами: «{ $first }» з крапкою, «{ $second }» з комою. Файл не імпортується, щоб жодна сума не була спотворена.
statement-qif-opening = Початковий баланс { $amount } на { $date }: це не операція, він не імпортується.
statement-qif-opening-undated = Початковий баланс { $amount }: це не операція, він не імпортується.
statement-qif-suspect = Рядок { $rank }, «{ $label }» ({ $amount }), схожий на початковий баланс: перевірте його перед додаванням.
statement-qif-rejected = { $count ->
    [one] { $count } нечитабельний рядок не імпортується: { $lines }.
    [few] { $count } нечитабельні рядки не імпортуються: { $lines }.
    [many] { $count } нечитабельних рядків не імпортуються: { $lines }.
   *[other] { $count } нечитабельного рядка не імпортуються: { $lines }.
}
statement-qif-reason-date = дата
statement-qif-reason-amount = сума
statement-qif-reason-differ = суперечливі суми
statement-qif-no-account = Цього рахунку більше немає у файлі: відкрийте файл знову.
statement-balance-unknown = не вказано у файлі
statement-group-identification = Ідентифікація операції
statement-group-amount = Сума операції
statement-group-classification = Класифікація операції для розрахунку статистики
statement-group-status = Статус операції
statement-field-date = Дата
statement-field-label = Опис
statement-field-reference = Референс платежу
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
backup-done = Резервну копію бази «{ $base }» записано у «{ $file }». Інших баз це не стосується.
backup-failed = Резервне копіювання неможливе: { $reason }
backup-not-started = Не вдалося розпочати резервне копіювання:
restore-unreadable = Цей файл не є придатним для читання архівом Radinus: { $reason }
# Запитання каже, що буде втрачено, перш ніж це втратити. Архів на цей момент
# уже прочитано: те, що воно повідомляє, є достеменним.
restore-question = Відновити «{ $file }» у базу «{ $base }»? Увесь поточний вміст цієї бази буде стерто й замінено, а те, що в ній є, буде втрачено. Інші бази зачеплено не буде.
restore-done = Базу «{ $base }» відновлено: { $accounts } рахунків і { $operations } операцій. Інші бази не зачеплено.
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
database-too-recent = Цю базу збережено новішою версією Radinus (версія бази { $found }; ця версія читає до версії { $supported }). Оновіть Radinus, щоб відкрити її.
database-not-radinus = Цей файл не є базою Radinus.
database-unreadable = Не вдалося прочитати базу: { $reason }
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
    [0] Відновлення цілісності бази «{ $base }» завершено: аномалій не знайдено. Записано етапів у журнал: { $lines }. Інших баз це не стосується.
    [one] Відновлення цілісності бази «{ $base }» завершено: виправлено { $anomalies } аномалію. Записано етапів у журнал: { $lines }. Інших баз це не стосується.
    [few] Відновлення цілісності бази «{ $base }» завершено: виправлено { $anomalies } аномалії. Записано етапів у журнал: { $lines }. Інших баз це не стосується.
    [many] Відновлення цілісності бази «{ $base }» завершено: виправлено { $anomalies } аномалій. Записано етапів у журнал: { $lines }. Інших баз це не стосується.
   *[other] Відновлення цілісності бази «{ $base }» завершено: виправлено { $anomalies } аномалії. Записано етапів у журнал: { $lines }. Інших баз це не стосується.
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
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Рахунки, враховані в підсумках: { $count } з { $total }
welcome-tile-counted = Враховувати цей рахунок у підсумках
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
preferences-branch-import = Імпорт
preferences-leaf-verification = Перевірка
preferences-field-verification = Імпортовані операції:
preferences-verification-hint = «Перевірена»: ви довіряєте своєму банку, імпортована операція вважається правильною. «До перевірки»: кожна імпортована операція чекає на вашу перевірку; потім ви самі переводите її в «Перевірена» у списку операцій. Це налаштування діє лише для майбутніх імпортів.
preferences-leaf-ofx = Виписки OFX
preferences-field-ofx-label = Опис операції:
preferences-field-ofx-reference = Референс платежу:
preferences-ofx-choice-name = Назва операції
preferences-ofx-choice-memo = Примітка банку
preferences-ofx-choice-name-and-memo = Назва, а за нею примітка
preferences-ofx-choice-empty = Нічого (залишити порожнім)
preferences-ofx-label-help = Що потрапляє до опису імпортованої операції. Назва — це те, що показує банк, наприклад «PRLV SEPA»; деякі банки додають до неї докладну примітку: кредитора прямого дебетування, отримувача та призначення переказу. Якщо операція не має примітки, її опис зберігає назву.
preferences-ofx-reference-help = Що потрапляє до референсу платежу імпортованої операції, де ви можете його бачити й фільтрувати за ним. Якщо операція не має примітки, «Примітка банку» залишає референс порожнім. Якщо примітка вже повторює назву, вона не записується двічі.
preferences-ofx-hint = Ці налаштування діють для всіх виписок OFX, незалежно від того, яку базу відкрито. Вони застосовуються до наступної відкритої виписки.
preferences-leaf-qif = Виписки QIF
preferences-field-qif-order = Порядок дня і місяця:
preferences-qif-order-ask = Питати мене щоразу
preferences-qif-order-day-month = Завжди день/місяць (05/03 = 5 березня)
preferences-qif-order-month-day = Завжди місяць/день (05/03 = 3 травня)
preferences-qif-order-help = Використовується, лише якщо жодна дата у файлі не дозволяє визначити порядок. Щойно дата на кшталт 24/11 доводить порядок, вирішує файл, незалежно від цього налаштування.
preferences-field-qif-label = Опис операції:
preferences-qif-label-both = Контрагент + примітка
preferences-qif-label-payee = Лише контрагент
preferences-qif-label-memo = Лише примітка
preferences-qif-label-help = Коли операція має і контрагента, і примітку. Якщо вона має лише одне з них, використовується саме воно, незалежно від цього налаштування.
preferences-qif-hint = Ці налаштування діють для всіх виписок QIF, незалежно від того, яку базу відкрито. «Питати мене щоразу» — найнадійніший варіант: файл із неоднозначними датами ніколи не читається навмання.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Відновити стовпці за замовчуванням
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Показати/Приховати
columns-colour = Розфарбувати стовпець:
columns-colour-none = Без кольору
columns-colour-red = Червоний
columns-colour-orange = Помаранчевий
columns-colour-pink = Рожевий
columns-colour-pastel-green = Пастельно-зелений
columns-colour-green = Зелений
columns-colour-pastel-blue = Пастельно-синій
columns-colour-blue = Синій
columns-colour-pastel-yellow = Пастельно-жовтий
columns-colour-yellow = Жовтий
preferences-leaf-columns = Стовпці таблиць
preferences-table-operations-list = Список операцій
preferences-columns-reset = Скинути
preferences-columns-reset-all = Скинути все
preferences-columns-done = Стовпці повернулися до початкового розташування.
preferences-columns-hint = Кожна таблиця запам'ятовує порядок стовпців, приховані вами стовпці та їхню ширину. «Скинути» одразу повертає їй початкове розташування.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Скидання
preferences-leaf-comfort = Налаштування зручності
preferences-comfort-reset = Скинути налаштування зручності
preferences-comfort-hint = Повертає до початкового стану стовпці всіх таблиць, порядок і прапорці рахунків у початковому вікні та розмір відображення. Мова, валюта й перевірка імпортованих операцій не змінюються.
preferences-comfort-question = Скинути налаштування зручності? Стовпці таблиць, початкове вікно та розмір відображення повернуться до початкового стану.
preferences-comfort-done = Налаштування зручності скинуто.

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

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Розрахунок кредиту
window-loan-title = Розрахунок кредиту
loan-tab-credit = Кредит
loan-tab-afford = Чи зможу я його виплатити?
loan-field-kind = Вид кредиту
loan-kind-consumer = Споживчий кредит
loan-kind-mortgage = Іпотека
loan-field-amount = Сума кредиту
loan-field-payment = Щомісячний платіж
loan-field-months = Строк
loan-field-rate = Фіксована ставка
loan-field-fees = Комісія за оформлення
loan-field-insurance = Страховка на місяць
loan-unit-months = міс.
loan-unit-percent = %
loan-invalid-field = Це значення не є числом: виправте його, щоб перерахувати.
loan-report-button = Звіт PDF
loan-monthly-table = Таблиця по місяцях
loan-months-count = { $count ->
        [one] { $count } місяць
        [few] { $count } місяці
        [many] { $count } місяців
       *[other] { $count } місяця
    }
loan-percent = { $value } %
loan-notice-payment-too-low = Цей платіж не покриває відсотки: кредит ніколи не буде погашено. Строк залишається 600 місяців.
loan-notice-too-long = Для цього платежу знадобилося б понад 600 місяців: строк залишається 600 місяців.
loan-figure-payment = Щомісячний платіж
loan-figure-payment-insured = Платіж зі страховкою
loan-figure-taeg = Реальна річна ставка
loan-figure-interest = Вартість відсотків
loan-figure-insurance = Вартість страховки
loan-figure-cost = Загальна вартість кредиту
loan-figure-total-due = Загальна сума до сплати
loan-figure-all-in = Усього сплачено, зі страховкою
loan-part-capital = Сума кредиту
loan-part-interest = Відсотки
loan-part-fees = Комісія за оформлення
loan-part-insurance = Страховка
loan-donut-cost-caption = усього
loan-chart-cost = Скільки коштує цей кредит
loan-chart-capital = Залишок боргу
loan-schedule-title = Графік платежів
loan-schedule-yearly = Графік платежів за роками
loan-column-number = №
loan-column-year = Рік
loan-column-date = Дата платежу
loan-column-payment = Платіж
loan-column-payments = Платежі
loan-column-interest = Відсотки
loan-column-capital = Основний борг
loan-column-insurance = Страховка
loan-column-remaining = Залишок боргу
loan-history-label = Досліджуваний період
loan-period-last-12 = Останні 12 місяців
loan-accounts-title = Досліджувані рахунки
loan-period-title = Період
loan-column-account = Рахунок
loan-column-bank = Банк
loan-column-balance = Реальний залишок
loan-unavailable-no-account = Позначте хоча б один рахунок, щоб дослідити вашу історію.
loan-unavailable-no-month = У цьому періоді ще немає жодного повного місяця: оберіть інший.
loan-verdict-title = Коротко
loan-verdict-green = Посильно
loan-verdict-orange = На межі
loan-verdict-red = Ризиковано
loan-verdict-no-income = За цей період немає доходів: боргове навантаження розрахувати неможливо.
loan-check-debt-green = Боргове навантаження { $ratio }: нижче порогу цього методу ({ $green }).
loan-check-debt-orange = Боргове навантаження { $ratio }: між { $green } і { $red }, на межі.
loan-check-debt-red = Боргове навантаження { $ratio }: вище { $red }.
loan-check-effort = Платіж { $payment } забирає { $share } того, що ви відкладаєте { $kind ->
        [good] у добрий місяць
        [hard] у важкий місяць
       *[usual] у звичайний місяць
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Добрий місяць
        [hard] Важкий місяць
       *[usual] Звичайний місяць
    } нічого не залишає: платіж { $payment } ішов би з вашого запасу.
loan-check-reserve-green = Ваш залишок лишається додатним до кінця кредиту.
loan-check-reserve-red = Через цей кредит ваш залишок пішов би в мінус: { $month }.
loan-check-reserve-sooner = Ваш залишок пішов би в мінус ({ $month }) на { $count ->
        [one] { $count } місяць
        [few] { $count } місяці
        [many] { $count } місяців
       *[other] { $count } місяця
    } раніше, ніж без цього кредиту.
loan-check-reserve-anyway = Ваш залишок пішов би в мінус і без цього кредиту (приблизно: { $month }); кредит майже нічого не змінює.
loan-check-reserve-floor-green = Ваш залишок лишається вище страхового резерву ({ $floor }) до кінця кредиту.
loan-check-reserve-floor-red = Через цей кредит ваш залишок опустився б нижче страхового резерву ({ $floor }): { $month }.
loan-check-reserve-floor-sooner = Ваш залишок опустився б нижче страхового резерву ({ $floor }; { $month }) на { $count ->
        [one] { $count } місяць
        [few] { $count } місяці
        [many] { $count } місяців
       *[other] { $count } місяця
    } раніше, ніж без цього кредиту.
loan-check-reserve-floor-anyway = Ваш залишок опустився б нижче страхового резерву ({ $floor }) і без цього кредиту (приблизно: { $month }); кредит майже нічого не змінює.
loan-warning-deficit = Увага: за цей період ваші витрати вже перевищують доходи в середньому на { $amount } на місяць, до будь-якого кредиту.
loan-figure-reference = Заощадження { $kind ->
        [good] у добрий місяць
        [hard] у важкий місяць
       *[usual] у звичайний місяць
    }
loan-figure-tipped = Місяці, які кредит відправив би в мінус
loan-gauge-caption = боргове навантаження
loan-figure-income = Середній дохід на місяць
loan-figure-spending = Середні витрати на місяць
loan-figure-saving = Середні заощадження на місяць
loan-figure-running = Поточні кредити на місяць
loan-figure-new = Новий платіж зі страховкою
loan-figure-rest = На життя на місяць
loan-figure-debt = Боргове навантаження
loan-red-months-value = { $count } з { $total }
loan-figure-balance-now = Реальний залишок сьогодні
loan-figure-balance-end = Прогноз залишку наприкінці кредиту
loan-chart-income = Куди йде ваш середній дохід
loan-donut-income-caption = середній дохід
loan-part-spending = Поточні витрати
loan-part-running = Поточні кредити
loan-part-new = Новий кредит
loan-part-rest = Залишається
loan-part-missing = Бракує
loan-chart-history = Ваша історія з цим кредитом
loan-chart-history-hint = Що залишилося б щомісяця після сплати платежу. Яскраво-червоним — місяці, які кредит відправив би в мінус; блідо-червоним — ті, що були в мінусі й без нього.
loan-chart-projection = Прогноз вашого залишку
loan-mark-loan-end = Кінець: { $label }
loan-mark-negative = У мінусі
loan-mark-floor = Нижче резерву
loan-mark-floor-line = Страховий резерв
loan-running-title = Враховані поточні кредити
loan-running-column-label = Періодична операція
loan-running-column-monthly = На місяць
loan-running-column-end = Останній платіж
loan-no-running = Серед ваших періодичних операцій не знайдено жодного поточного кредиту.
loan-period-caption = { $from } – { $to } ({ $count ->
        [one] { $count } місяць
        [few] { $count } місяці
        [many] { $count } місяців
       *[other] { $count } місяця
    })
loan-transfers = { $count ->
        [0] Переказів між позначеними рахунками не знайдено.
        [one] Знайдено й виключено { $count } переказ між позначеними рахунками.
        [few] Знайдено й виключено { $count } перекази між позначеними рахунками.
        [many] Знайдено й виключено { $count } переказів між позначеними рахунками.
       *[other] Знайдено й виключено { $count } переказу між позначеними рахунками.
    }
loan-method = Середні за повні місяці періоду, проведені та підтверджені операції, без переказів між позначеними рахунками.
loan-report-title = Розрахунок кредиту
loan-report-made-on = розрахунок від { $date }
loan-disclaimer = Орієнтовний розрахунок без договірної сили. Обов'язковою є лише пропозиція банку.
loan-tab-rules = Налаштування оцінки
loan-method-optimistic = Оптимістичний
loan-method-neutral = Нейтральний
loan-method-severe = Суворий
loan-method-line = Метод оцінки: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Оцінка відповідає на три запитання, і кожен метод висуває свої вимоги. Оберіть той, що вам ближчий: оцінка на вкладці «Чи зможу я його виплатити?» йде за ним. Останній рядок припускає, що ваші витрати щороку зростають на вказаний відсоток; платіж не змінюється.
loan-rule-row-debt = Допустиме боргове навантаження
loan-rule-row-reference = Опорні заощадження
loan-rule-row-share = Частка цих заощаджень, яку може забрати платіж
loan-rule-row-floor = Поріг, нижче якого залишок не повинен опускатися
loan-rule-row-sooner = Якщо залишок опускається нижче й без кредиту
loan-rule-row-growth = Зростання ваших витрат на рік
loan-rule-limits = зелений до { $green }, помаранчевий до { $red }
loan-rule-reference = { $kind ->
        [good] добрий місяць
        [hard] важкий місяць
       *[usual] звичайний місяць
    }: { $amount }
loan-rule-floor-zero = нуль
loan-rule-floor-cushion = місяць витрат: { $amount }
loan-rule-sooner = помаранчевий, якщо кредит наближає це на { $orange }, червоний — на { $red }
loan-unit-percent-year = % на рік
loan-method-optimistic-explain = Оптимістичний метод виходить із доброго місяця, допускає боргове навантаження до 40 % і не тримає резерву: він показує, що можливо, якщо все піде добре.
loan-method-neutral-explain = Нейтральний метод виходить зі звичайного місяця й дотримується правила банків — 33–35 % боргового навантаження: це опорна оцінка.
loan-method-severe-explain = Суворий метод виходить із важкого місяця й тримає місяць витрат у резерві на непередбачене: він показує, що витримає, навіть якщо все піде погано.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Енергоспоживання електроприладу
window-appliance-title = Енергоспоживання електроприладу
appliance-device-title = Прилад
appliance-on-title = Увімкнено
appliance-standby-title = У режимі очікування
appliance-field-on-watts = Потужність під час роботи
appliance-field-on-hours = Час роботи на добу
appliance-field-days = Днів використання на тиждень
appliance-field-share = Частка роботи в пільгові години
appliance-field-standby-watts = Потужність у режимі очікування
appliance-field-standby-hours = Час у режимі очікування в день використання
appliance-unit-watts = Вт
appliance-unit-hours = год
appliance-unit-days = з 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/кВт·год
appliance-standby-hint = Якщо поле порожнє, режим очікування триває решту дня. У дні без використання прилад лишається увімкненим у розетку: увесь цей час вважається режимом очікування. Якщо прилад вимкнено з розетки, його споживання в режимі очікування — 0 Вт.
appliance-contract-title = Ваш договір
appliance-field-option = Тарифний план
appliance-option-base = Однозонний (одна ціна)
appliance-option-off-peak = Пікові / пільгові години
appliance-field-base = Ціна за кВт·год
appliance-field-peak = Ціна за кВт·год у пікові години
appliance-field-off-peak = Ціна за кВт·год у пільгові години
appliance-field-off-peak-hours = Пільгових годин на добу
appliance-contract-hint = Ці ціни діють лише для цього розрахунку. Збережений тариф задається в розділі Налаштування › Параметри › Інструменти.
appliance-contract-reset = Повернути збережений тариф
appliance-period-day = За день
appliance-period-month = За місяць
appliance-period-year = За рік
appliance-energy = { $value } кВт·год
appliance-less-than = менше ніж { $amount }
appliance-detail-title = Докладно за рік
appliance-column-part = Стаття
appliance-column-energy = Енергія
appliance-column-cost = Вартість
appliance-column-share = Частка
appliance-line-on = Увімкнено
appliance-line-standby = У режимі очікування
appliance-line-on-peak = Увімкнено, пікові години
appliance-line-on-off-peak = Увімкнено, пільгові години
appliance-line-standby-peak = У режимі очікування, пікові години
appliance-line-standby-off-peak = У режимі очікування, пільгові години
appliance-line-total = Разом
appliance-chart-title = Куди йдуть гроші
appliance-chart-caption = на рік
appliance-standby-sentence = Лише режим очікування коштує { $amount } на рік: { $share } від загальної вартості приладу.
appliance-note-plate = Потужність, зазначена на приладі або в його інструкції, — це максимум: під час роботи більшість приладів споживає менше. Щоб отримати реальне значення, виміряйте її ватметром-розеткою та введіть його показання.
appliance-note-subscription = Абонентська плата не враховується: її сплачують незалежно від того, увімкнено прилад у розетку чи ні.
appliance-invalid-watts = Будь ласка, вкажіть потужність від 0 до 100 000 Вт.
appliance-invalid-hours = Будь ласка, вкажіть час від 0 до 24 годин на добу.
appliance-invalid-days = Будь ласка, вкажіть ціле число днів від 0 до 7.
appliance-invalid-share = Будь ласка, вкажіть частку від 0 до 100 %.
appliance-invalid-day-overflow = Робота й режим очікування разом перевищують 24 години на добу.
appliance-invalid-price = Будь ласка, вкажіть ціну за кВт·год від 0 до 100.
appliance-invalid-off-peak-hours = Будь ласка, вкажіть ціле число пільгових годин від 0 до 24.
preferences-branch-tools = Інструменти
preferences-leaf-electricity = Тариф на електроенергію
preferences-electricity-blue = Повернутися до Tarif Bleu EDF
preferences-electricity-hint = Тариф за вашим договором, який використовує інструмент «Енергоспоживання електроприладу». За замовчуванням: Tarif Bleu від EDF (Франція) станом на 1 серпня 2026 р., ціни з податками, лічильник від 3 до 6 кВА. Ці ціни часто змінюються в лютому та серпні: перепишіть їх зі свого рахунку.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Моя фінансова подушка
window-cushion-title = Моя фінансова подушка
cushion-question = Якби ваші доходи припинилися завтра, на скільки місяців вистачило б ваших заощаджень?
cushion-accounts-title = Ваші рахунки
cushion-column-account = Рахунок
cushion-column-balance = Реальний залишок
cushion-column-savings = Заощадження
cushion-column-spending = Витрати
cushion-accounts-hint = «Заощадження»: гроші, на які ви розраховуєте у скрутний час. «Витрати»: рахунки, з яких сплачуються щоденні витрати.
cushion-history-label = Аналізований період
cushion-backup-label = Резервний дохід на місяць
cushion-backup-hint = Те, що й надалі надходило б: допомога по безробіттю, зарплата чоловіка чи дружини… Порожньо: жодного доходу.
cushion-categories-title = Враховані витрати
cushion-categories-hint = Зніміть позначку з того, від чого ви відмовилися б у скрутний час.
cushion-categories-empty = За цей період витрат немає.
cushion-verdict-title = Ваша подушка
cushion-targets-title = Пороги надійності
cushion-projection-title = Ваші заощадження у скрутний час
cushion-projection-hint = Скільки залишалося б щомісяця, якби ваші доходи припинилися сьогодні.
cushion-note = Оцінка на основі вашої історії: витрати у скрутний місяць можуть відрізнятися від середніх.
cushion-invalid-backup = Цю суму не вдається прочитати: виправте її, щоб перерахувати.
cushion-no-spending-account = Позначте хоча б один рахунок «Витрати».
cushion-no-month = У цьому періоді ще немає жодного повного місяця.
cushion-months = { $value } міс.
cushion-per-month = { $amount } на місяць
cushion-figure-holds = Без обмежень
cushion-gauge-caption = витрат покрито
cushion-verdict-short = Менше трьох місяців: скрутний час швидко поставить вас у складне становище.
cushion-verdict-fair = Від трьох до шести місяців: пристойна подушка, яку варто збільшити, якщо зможете.
cushion-verdict-solid = Шість місяців і більше: ваша подушка надійна.
cushion-verdict-holds = Ваш резервний дохід покриває ваші витрати: заощадження не танутимуть.
cushion-verdict-nothing = За період немає врахованих витрат: покривати нічого.
cushion-tile-savings = Доступні заощадження
cushion-tile-spending = Враховані витрати
cushion-tile-backup = Резервний дохід
cushion-tile-burn = Заощадження танули б на
cushion-tile-rhythm = Темп заощаджень
cushion-burn-none = Нічого
cushion-target-title = { $months } міс. витрат: { $amount }
cushion-target-reached = Досягнуто.
cushion-target-date = Бракує { $missing }. За вашого темпу заощаджень буде досягнуто приблизно до дати: { $month }.
cushion-target-never = Бракує { $missing }. Ваші заощадження не зросли за період: за такого темпу цей поріг не буде досягнуто.
cushion-mark-empty = Заощадження закінчаться: { $month }
cushion-period = Середнє за { $count ->
        [one] { $count } повний місяць
        [few] { $count } повні місяці
        [many] { $count } повних місяців
       *[other] { $count } повних місяців
    } (період: { $from } — { $to }). { $transfers ->
        [0] Переказів між вашими рахунками немає.
        [one] { $transfers } переказ між вашими рахунками виключено з розрахунку.
        [few] { $transfers } перекази між вашими рахунками виключено з розрахунку.
        [many] { $transfers } переказів між вашими рахунками виключено з розрахунку.
       *[other] { $transfers } переказів між вашими рахунками виключено з розрахунку.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Мета заощаджень
window-goal-title = Мета заощаджень
goal-accounts-title = Відстежувані рахунки
goal-column-account = Рахунок
goal-column-balance = Реальний залишок
goal-accounts-hint = Переказ між двома відстежуваними рахунками взаємно компенсується; переказ на невідстежуваний рахунок вважається витратою.
goal-period-label = Базовий період
goal-period-range = Діапазон років…
goal-range-from = з
goal-range-to = до
goal-question-title = Ваше запитання
goal-question-when = Коли в мене буде ця сума?
goal-question-amount = Скільки в мене буде на цю дату?
goal-question-effort = Скільки відкладати, щоб на цю дату в мене була ця сума?
goal-field-target = Цільова сума
goal-field-date = Цільова дата
goal-field-rate = Річна ставка за заощадженнями
goal-field-extra = А якщо відкладати додатково, на місяць
goal-options-hint = Порожньо: без відсотків, нічого додатково.
goal-answer-title = Відповідь
goal-chart-title = Ваш залишок: учора й завтра
goal-chart-hint = Суцільна лінія: реальний залишок за останні дванадцять місяців; пунктир: прогноз; світла область: діапазон залежно від місяців.
goal-disclaimer = Прогноз на основі вашої історії, а не обіцянка: будь-яка несподіванка може все змінити.
goal-no-account = Позначте хоча б один рахунок для відстеження.
goal-no-month = У цьому періоді ще немає жодного повного місяця.
goal-invalid-target = Вкажіть цільову суму, будь ласка.
goal-invalid-date = Вкажіть майбутню дату в межах найближчих п'ятдесяти років, будь ласка.
goal-invalid-rate = Вкажіть ставку від 0 до 100%, будь ласка.
goal-invalid-extra = Цю суму не вдається прочитати: виправте її, щоб перерахувати.
goal-per-month = { $amount } на місяць
goal-tile-balance = Залишок сьогодні
goal-tile-rhythm = Середній темп
goal-tile-target = Мета
goal-tile-reached = Орієнтовний термін досягнення
goal-tile-date = Цільова дата
goal-tile-projected = Прогнозний залишок
goal-tile-saved = Заощаджено до того часу
goal-tile-interest = У тому числі відсотки
goal-tile-needed = Потрібно відкладати
goal-when-already = У вас уже є { $amount }: на відстежуваних рахунках загалом { $balance }.
goal-when-reached = У вас буде { $amount } приблизно через { $months ->
        [one] { $months } місяць
        [few] { $months } місяці
        [many] { $months } місяців
       *[other] { $months } місяців
    } ({ $month }).
goal-when-range = Залежно від місяців: { $early } — { $late }.
goal-when-range-open = Найраніше: приблизно { $early }; за слабких місяців мету не було б досягнуто.
goal-when-never = За такого темпу ви не досягнете суми { $amount }.
goal-zero = Ваш залишок упав би до нуля приблизно до дати: { $month }.
goal-amount = { $month }: у вас було б близько { $amount }.
goal-amount-range = Залежно від місяців: від { $low } до { $high }.
goal-effort-more = Щоб на зазначену дату ({ $month }) у вас було { $amount }, потрібно відкладати в середньому { $monthly } на місяць, тобто на { $gap } більше, ніж зараз.
goal-effort-less = Щоб на зазначену дату ({ $month }) у вас було { $amount }, вистачило б { $monthly } на місяць, тобто на { $gap } менше, ніж зараз: ви випереджаєте план.
goal-effort-range = Залежно від місяців відхилення від вашого темпу становило б від { $low } до { $high } на місяць.
goal-chart-target = Мета: { $amount }
goal-chart-today = Сьогодні
goal-note-seasons = Прогноз ураховує сезонність: для кожного майбутнього місяця береться середнє значення тих самих місяців періоду.
goal-note-range = Діапазон будується за слабкими й сильними місяцями періоду: нижньою чвертю та верхньою чвертю.
goal-note-loan = Кредит «{ $label }» закінчується ({ $month }): після цього — плюс { $amount } на місяць.
goal-note-interest = Відсотки нараховуються щомісяця за ставкою { $rate }% річних: наближення правила півмісячних періодів для ощадних рахунків.
goal-period = Темп розраховано за { $count ->
        [one] { $count } повний місяць
        [few] { $count } повні місяці
        [many] { $count } повних місяців
       *[other] { $count } повних місяців
    } (період: { $from } — { $to }). { $transfers ->
        [0] Переказів між відстежуваними рахунками немає.
        [one] { $transfers } переказ між відстежуваними рахунками виключено з розрахунку.
        [few] { $transfers } перекази між відстежуваними рахунками виключено з розрахунку.
        [many] { $transfers } переказів між відстежуваними рахунками виключено з розрахунку.
       *[other] { $transfers } переказів між відстежуваними рахунками виключено з розрахунку.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = А якщо скоротити…?
window-cut-title = А якщо скоротити…?
cut-axis-label = Групування
cut-axis-category = Категорії
cut-axis-payee = Контрагенти
cut-axis-budget-line = Статті бюджету
cut-table-title = Ваші витрати за статтями
cut-table-hint = Введіть скорочення у % або в { $sign } на місяць для статей, які ви хотіли б зменшити. Скорочення не може перевищувати саму витрату.
cut-column-monthly = На місяць
cut-column-cut = Скорочення
cut-column-after = Після
cut-column-yearly = Економія на рік
cut-total = Разом
cut-horizon-label = Горизонт
cut-settings-title = Налаштування
cut-options-hint = Ставка й цільова сума необов'язкові.
cut-report-button = Звіт PDF
cut-chart-title = Ваш залишок без скорочень і з ними
cut-chart-hint = Суцільна лінія: реальний залишок за останні дванадцять місяців; сірий пунктир: прогноз без скорочень; синім: зі скороченнями; зеленим: заощаджені гроші.
cut-donut-title = Ваші витрати на місяць після скорочень
cut-donut-caption = на місяць після скорочень
cut-donut-others = Інші статті
cut-donut-saved = Заощаджено
cut-legend-with = Зі скороченнями
cut-legend-without = Без скорочень
cut-years = { $years ->
        [one] { $years } рік
        [few] { $years } роки
        [many] { $years } років
       *[other] { $years } року
    }
cut-headline-none = Введіть скорочення в таблиці, щоб побачити його ефект.
cut-headline = Скоротивши { $count ->
        [one] { $count } статтю
        [few] { $count } статті
        [many] { $count } статей
       *[other] { $count } статті
    }, ви відкладали б на { $monthly } більше на місяць, тобто { $yearly } на рік.
cut-tile-monthly = Економія на місяць
cut-tile-yearly = Економія на рік
cut-tile-horizon = Економія за { $years ->
        [one] { $years } рік
        [few] { $years } роки
        [many] { $years } років
       *[other] { $years } року
    }
cut-tile-spending = Витрати на місяць
cut-target-already = У вас уже є { $amount }.
cut-target-sooner = Ви досягли б суми { $amount } приблизно до дати: { $with } (без скорочень: { $without }) — { $months ->
        [0] без виграшу в часі
        [one] на { $months } місяць раніше
        [few] на { $months } місяці раніше
        [many] на { $months } місяців раніше
       *[other] на { $months } місяця раніше
    }.
cut-target-only-with = З цими скороченнями ви досягли б суми { $amount } приблизно до дати: { $with }; без них, за нинішнього темпу, — ніколи.
cut-target-never = Навіть із цими скороченнями ви не досягли б суми { $amount } за нинішнього темпу.
cut-note-seasons = Кожне скорочення враховує сезонність своєї статті: стаття, витрати за якою припадають переважно на літо, і економію дає переважно влітку.
cut-note-capped = Одне з введених скорочень перевищувало витрату: його зменшено до розміру самої витрати.
cut-invalid-cut = Це скорочення не вдається прочитати: вкажіть відсоток від 0 до 100 або суму на місяць.
cut-report-settings = Налаштування
cut-report-result = Результат
cut-report-accounts = Відстежувані рахунки

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Спланувати відпустку
window-holiday-title = Спланувати відпустку
holiday-trip-title = Подорож
holiday-field-trip = Тип подорожі
holiday-trip-stay = Відпочинок
holiday-trip-cruise = Круїз
holiday-field-adults = Дорослі
holiday-field-children = Діти
holiday-field-nights = Тривалість, у ночах
holiday-field-days = Дні
holiday-field-months = Місяців до від'їзду
holiday-field-stops = Кількість портів заходу
holiday-saved-title = Уже заощаджено
holiday-saved-hint = Позначте рахунки, на яких уже відкладено гроші на відпустку: їхній реальний залишок вважається вже заощадженим.
holiday-budget-title = Бюджет
holiday-budget-hint = Для кожної статті — сума, на кого вона припадає і на який строк. Порожня стаття не враховується.
holiday-optional-title = Необов'язкові статті
holiday-result-title = Результат
holiday-donut-title = Куди йдуть гроші на подорож
holiday-donut-caption = на подорож
holiday-child-label = Дитяча ціна
holiday-count-label = Каюти
holiday-open = Відкрити проєкт…
holiday-save = Зберегти проєкт…
holiday-pdf = Звіт PDF
holiday-excel = Експорт в Excel
holiday-file-filter = Проєкт відпустки
holiday-replace-question = Відкриття цього проєкту замінить те, що введено у вікні. Продовжити?
holiday-file-saved = Проєкт збережено: { $file }
holiday-file-opened = Проєкт відкрито: { $file }
holiday-file-not-project = Цей файл не є проєктом відпустки Radinus.
holiday-file-too-recent = Цей проєкт створено в новішій версії Radinus: оновіть Radinus, щоб відкрити його.
holiday-file-failed = Не вдалося прочитати або записати файл: { $reason }
holiday-line-transport = Дорога туди й назад
holiday-line-lodging = Проживання
holiday-line-meals = Харчування й поточні витрати
holiday-line-visits = Визначні місця й дозвілля
holiday-line-port = Дорога до порту
holiday-line-cabins = Каюти
holiday-line-service = Сервісний збір (чайові)
holiday-line-drinks = Пакет напоїв
holiday-line-excursions = Екскурсії в портах заходу
holiday-line-port-taxes = Портові збори
holiday-line-wifi = Wi-Fi на борту
holiday-line-onboard = Витрати на борту й на березі
holiday-line-other = Інші й непередбачені витрати
holiday-line-insurance = Страхування від скасування поїздки
holiday-line-stay-tax = Туристичний збір
holiday-line-car = Автомобіль на місці, пальне й платні дороги
holiday-line-parking = Паркування в аеропорту чи на вокзалі
holiday-line-bank = Банківські комісії за кордоном
holiday-line-formalities = Формальності (паспорт, віза, щеплення)
holiday-line-pets = Догляд за тваринами
holiday-span-trip = за поїздку
holiday-span-night = за ніч
holiday-span-day = на день
holiday-span-stop = за порт заходу
holiday-who-all = на всіх
holiday-who-person = на особу
holiday-who-adults = на дорослого
holiday-cabins-count = { $count ->
        [one] { $count } каюта
        [few] { $count } каюти
        [many] { $count } кают
       *[other] { $count } каюти
    }
holiday-days = { $days ->
        [one] { $days } день
        [few] { $days } дні
        [many] { $days } днів
       *[other] { $days } дня
    }
holiday-invalid-count = Введіть ціле число.
holiday-invalid-amount = Цю суму не вдається прочитати: потрібне додатне число або відсоток від 0 до 100.
holiday-headline-empty = Введіть суми бюджету, щоб побачити, скільки коштуватиме подорож.
holiday-headline-stay = Цей відпочинок коштував би { $total } на { $people ->
        [one] { $people } особу
        [few] { $people } особи
        [many] { $people } осіб
       *[other] { $people } особи
    } і { $nights ->
        [0] 0 ночей
        [one] { $nights } ніч
        [few] { $nights } ночі
        [many] { $nights } ночей
       *[other] { $nights } ночі
    }.
holiday-headline-cruise = Цей круїз коштував би { $total } на { $people ->
        [one] { $people } особу
        [few] { $people } особи
        [many] { $people } осіб
       *[other] { $people } особи
    } і { $nights ->
        [0] 0 ночей
        [one] { $nights } ніч
        [few] { $nights } ночі
        [many] { $nights } ночей
       *[other] { $nights } ночі
    }.
holiday-tile-total = Загальна вартість
holiday-tile-person = На особу
holiday-tile-person-day = На особу на день
holiday-tile-saved = Уже заощаджено
holiday-tile-remaining = Залишилося зібрати
holiday-tile-monthly = Потрібно відкладати
holiday-remaining-none = Нічого: усе покрито
holiday-monthly-none = Відкладати нічого не потрібно
holiday-monthly-now = Від'їзд цього місяця
holiday-note-days = Днів на один більше, ніж ночей: сім ночей — це вісім днів.
holiday-note-child = У розрахунку на особу дитина платить дитячу ціну, якщо її вказано; якщо поле порожнє, вона платить як дорослий.
holiday-note-percent = Відсоток страхування застосовується до основних статей подорожі, відсоток банківських комісій — до витрат на місці.
holiday-sheet-budget = Бюджет
holiday-sheet-result = Результат
holiday-column-line = Стаття
holiday-column-amount = Сума
holiday-column-child = Дитяча ціна
holiday-column-who = На кого
holiday-column-span = На який строк
holiday-column-cost = Вартість
holiday-disclaimer = Оцінка на основі ваших власних сум: реальні ціни можуть відрізнятися.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Проєкт скорочення витрат
cut-file-not-project = Цей файл не є проєктом скорочення витрат Radinus.
cut-file-too-recent = Цей проєкт створено в новішій версії Radinus: оновіть Radinus, щоб відкрити його.
cut-sheet-items = Статті

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Журнал мого автомобіля
window-car-title = Журнал мого автомобіля
car-unnamed = Мій автомобіль
car-sheet-title = Автомобіль
car-field-plate = Реєстраційний номер
car-field-make = Марка
car-field-model = Модель
car-field-engine = Тип двигуна
car-field-first-hand = Перший власник
car-field-registered = Перша реєстрація
car-field-acquired = Дата придбання
car-field-acquired-km = Пробіг під час придбання
car-field-service = ТО кожні
car-field-service-or = або кожні
car-unit-months-short = міс.
car-unit-km = km
car-tariff-title = Тариф на заряджання вдома
car-tariff-hint = Цей тариф зберігається в журналі автомобіля: він не змінює тариф у налаштуваннях.
car-tariff-reset = Узяти тариф із налаштувань
car-engine-petrol = Бензин
car-engine-diesel = Дизель
car-engine-lpg = Газ (LPG)
car-engine-e85 = E85 (біоетанол)
car-engine-hybrid = Гібрид
car-engine-plug-in = Підключуваний гібрид
car-engine-electric = Електромобіль
car-engine-hydrogen = Водень
car-energy-petrol = Бензин
car-energy-diesel = Дизельне паливо
car-energy-lpg = Газ (LPG)
car-energy-e85 = E85
car-energy-electricity = Електроенергія
car-energy-hydrogen = Водень
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Енергія
car-rubric-upkeep = Поточне обслуговування
car-rubric-service = Планове ТО
car-rubric-wear = Зношувані деталі
car-rubric-tyres = Шини
car-rubric-breakdown = Поломки
car-rubric-insurance = Страховка
car-rubric-inspection = Техогляд
car-part-brake-pads = Гальмівні колодки
car-part-brake-discs = Гальмівні диски
car-part-timing-belt = Ремінь ГРМ
car-part-clutch = Зчеплення
car-part-battery-12v = Акумулятор 12 В
car-part-shock-absorbers = Амортизатори
car-part-wipers = Щітки склоочисника
car-part-spark-plugs = Свічки запалювання
car-part-glow-plugs = Свічки розжарювання
car-part-particulate-filter = Сажовий фільтр
car-part-catalytic-converter = Каталітичний нейтралізатор
car-part-fuel-cell-filter = Фільтр паливного елемента
car-part-exhaust = Вихлопна система
car-part-other = Інша деталь…
car-axle-all = Усі чотири шини
car-axle-front = Передні шини
car-axle-rear = Задні шини
car-verdict-pass = Пройдено
car-verdict-counter = Повторний огляд
car-charge-station = На зарядній станції
car-charge-home = Удома
car-slot-peak = Пікові години
car-slot-off-peak = Пільгові години
car-entry-new = Новий запис
car-entry-edit = Змінити запис
car-field-date = Дата
car-field-km = Пробіг
car-field-rubric = Рубрика
car-field-amount = Сума
car-field-garage = СТО або АЗС
car-field-note = Примітка
car-field-energy = Енергія
car-field-quantity = Кількість
car-field-charge = Заряджання
car-field-slot = Час заряджання
car-field-part = Деталь
car-field-part-name = Назва деталі
car-field-axle = Замінені шини
car-field-verdict = Результат
car-field-months = Місяців покриття
car-field-battery = Стан батареї
car-home-amount-hint = Сума заряджання вдома розраховується за тарифом автомобіля.
car-entry-add = Додати до журналу
car-entry-update = Зберегти запис
car-entry-cancel = Скасувати
car-entry-delete = Видалити запис
car-delete-question = Видалити цей запис із журналу?
car-from-operation = Узяти операцію…
car-pick-account = З якого рахунку ця витрата?
car-pick-operation = Яка операція?
car-pick-take = Узяти
car-pick-none = На цьому рахунку немає витрат.
car-pick-taken = Операцію взято: укажіть пробіг і рубрику, потім додайте запис.
car-history-title = Історія
car-filter-all = Усі рубрики
car-history-empty = Записів поки немає.
car-history-hint = Клацніть запис, щоб змінити його.
car-column-date = Дата
car-column-km = Км
car-column-rubric = Рубрика
car-column-detail = Подробиці
car-column-amount = Сума
car-column-garage = СТО
car-column-note = Примітка
car-column-share = Частка
car-column-per-km = На км
car-column-energy = Енергія
car-column-quantity = Кількість
car-column-price = Середня ціна
car-column-consumption = Витрата
car-column-part = Деталь
car-column-changes = Заміни
car-column-last = Остання заміна
car-column-life = Термін служби
car-column-next = Наступна заміна
car-total = Разом
car-summary-title = Скільки коштує автомобіль
car-headline-empty = Заповніть картку, потім додайте перший запис: заправку, ТО, рахунок із СТО…
car-headline = З { $since } ваш автомобіль обійшовся вам у { $total }.
car-headline-km = З { $since } ваш автомобіль обійшовся вам у { $total } за { $km } пробігу: { $cost } за кілометр.
car-tile-total = Загальна вартість
car-tile-month = На місяць
car-tile-km = За кілометр
car-tile-driven = Пройдено кілометрів
car-tile-consumption = Витрата
car-tile-energy-km = Енергія на кілометр
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } місяць
        [few] { $months } місяці
        [many] { $months } місяців
       *[other] { $months } місяця
    }
car-detail-battery = Батарея: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = За рубриками
car-energy-title = Енергія
car-parts-title = Зношувані деталі
car-tyres-title = Шини
car-battery-title = Стан батареї
car-years-title = Скільки автомобіль коштував щороку
car-donut-title = Куди йдуть гроші
car-donut-caption = усього
car-deadlines-title = Терміни
car-deadlines-empty = Термінів поки немає: занотуйте ТО, техогляд, страховку або дві заміни однієї й тієї самої деталі.
car-deadline-service = ТО
car-deadline-inspection = Техогляд
car-deadline-counter = Повторний техогляд
car-deadline-insurance = Закінчення страховки
car-when-date = дата: { $date }
car-when-km = при пробігу { $km }
car-when-km-reached = при пробігу { $km }; у вашому темпі це приблизно: { $month }
car-when-date-km = дата: { $date } або при пробігу { $km }, залежно від того, що настане раніше
car-when-inspection-unknown = Занотуйте останній техогляд, щоб дізнатися дату наступного.
car-tone-late = Прострочено
car-tone-soon = Незабаром
car-note-since = Усе рахується від придбання: за датою та пробігом, указаними в картці.
car-note-consumption = Витрата вимірюється від повного бака до повного бака: заправляйтеся до повного й щоразу записуйте пробіг.
car-note-e85 = Автомобіль на E85 п'є те, що йому наллють: кілометри після заправки зараховуються на це паливо.
car-note-home = Заряджання вдома оцінюється за тарифом автомобіля на день запису й зберігає цю вартість.
car-note-inspection = Техогляд відповідає французькому правилу: перший — протягом чотирьох років після першої реєстрації, потім кожні два роки; повторний огляд — протягом двох місяців.
car-disclaimer = Терміни й строки служби — це оцінки за даними журналу: достовірна лише сервісна книжка виробника.
car-invalid-date = Введіть коректну дату, не пізнішу за сьогоднішню.
car-invalid-acquired = Дата придбання не може бути раніше за першу реєстрацію.
car-invalid-km = Введіть пробіг у цілих кілометрах.
car-invalid-amount = Цю суму неможливо прочитати.
car-invalid-quantity = Введіть кількість: літри, кВт·год або кілограми.
car-invalid-part = Виберіть замінену деталь або введіть її назву.
car-invalid-rubric = Виберіть рубрику.
car-invalid-months = Введіть ціле число місяців.
car-invalid-battery = Введіть стан батареї від 0 до 100 %.
car-open = Відкрити журнал…
car-save = Зберегти журнал…
car-report-button = Звіт PDF
car-file-filter = Журнал автомобіля
car-file-saved = Журнал збережено: { $file }
car-file-opened = Журнал відкрито: { $file }
car-file-not-logbook = Цей файл не є журналом автомобіля Radinus.
car-file-too-recent = Цей журнал створено в новішій версії Radinus: оновіть Radinus, щоб відкрити його.
car-replace-question = Відкриття цього журналу замінить журнал у вікні. Продовжити?
car-sheet-history = Журнал
car-sheet-summary = Зведення

analysis-history-hint = Чим довша ваша історія, тим кращим буде цей аналіз: в ідеалі потрібно щонайменше рік операцій.

# --- F48 — Поділити витрату (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Поділити витрату
window-sharing-title = Поділити витрату
sharing-question = Хто скільки платить?
sharing-setup-title = Розподіл
sharing-field-label = Назва
sharing-label-hint = Наприклад «Ресторан 12/10» або «Поїздка до Бретані 2027»: за нею називаються файли та звіти.
sharing-field-total = Усього
sharing-total-hint = Якщо поле порожнє, сума дорівнює сумі позицій і власних додатків кожного.
sharing-field-rule = Правило
sharing-field-rounding = Округлення
sharing-field-people = Люди
sharing-mode-whole = Одне правило для всієї витрати
sharing-mode-item = Одне правило для кожної позиції
sharing-rule-equal = Рівні частки
sharing-rule-parts = За частками
sharing-rule-percent = У відсотках
sharing-rule-income = Пропорційно до доходів
sharing-rounding-cent = До центів
sharing-rounding-euro = До цілої одиниці
sharing-round-euro = Округлити до цілих одиниць
sharing-hide-incomes = Приховати доходи у звітах та експорті
sharing-people-title = Люди
sharing-people-hint = Один рядок на людину, один стовпець на позицію: позначте, хто в чому бере участь. Усе інше необов'язкове. Якщо хтось відмовляється, залишаючи свій аванс: точна сума, що дорівнює внесеному, і жодної позначки.
sharing-add-person = Додати людину
sharing-person-default = Людина { $number }
sharing-items-title = Позиції
sharing-items-hint = Лише те, що стосується не всіх, наприклад вино. Решта суми йде у спільну позицію.
sharing-add-item = Додати позицію
sharing-common = Спільна
sharing-payments-title = Платежі
sharing-payments-hint = Хто заплатив, скільки і коли. Рядок без суми поки не враховується.
sharing-payments-none = Поки що немає платежів.
sharing-add-payment = Додати платіж
sharing-result-title = Результат
sharing-balances-title = Стан розрахунків
sharing-transfers-title = Запропоновані перекази
sharing-delete = Видалити
sharing-delete-person-question = У цієї людини є платежі: видалити їх разом із нею?
sharing-disclaimer = Radinus пропонує розподіл: між друзями кожен вільний домовитися інакше.
sharing-column-person = Людина
sharing-column-household = Домогосподарство
sharing-column-income = Дохід
sharing-column-parts = Частки
sharing-column-percent = %
sharing-column-floor = Щонайменше
sharing-column-cap = Щонайбільше
sharing-column-fixed = Точна сума
sharing-column-alone = Власні додатки
sharing-column-gift = Подарований надлишок
sharing-column-share = Частка
sharing-column-typed = Введені %
sharing-column-constraint = Що спрацювало
sharing-column-due = До сплати
sharing-column-item = Позиція
sharing-column-amount = Сума
sharing-column-rule = Правило
sharing-column-participants = Учасники
sharing-column-unit = Домогосподарство або людина
sharing-column-members = Члени
sharing-column-paid = Сплачено
sharing-column-balance = Баланс
sharing-column-date = Дата
sharing-column-who = Хто
sharing-column-label = Назва
sharing-help-household = Люди з одного домогосподарства розраховуються разом: їхні платежі та борги додаються, і вони отримують один звіт. Приклад: «Сім'я Мартен» для батьків і дітей.
sharing-help-income = Потрібен лише для правила «Пропорційно до доходів»: чим вищий дохід, тим більша частка. Введіть місячний дохід.
sharing-help-parts = Людина з 2 частками платить удвічі більше, ніж людина з 1 часткою. Приклад: дорослий 1, дитина 0,5.
sharing-help-percent = Частка витрати, яку платить людина. Сума відсотків має дорівнювати 100 %.
sharing-help-floor = Людина заплатить щонайменше цю суму, навіть якщо розрахована частка менша. Різниця зменшує частку інших.
sharing-help-cap = Людина ніколи не заплатить більше за цю суму. Те, чого вона не платить, лягає на інших учасників її позицій.
sharing-help-fixed = Точна сума, яку людина платить за будь-яких обставин; решту ділять між собою інші. Приклад: хтось відмовляється і залишає свій аванс.
sharing-help-alone = Те, що людина взяла лише для себе, наприклад десерт або кава. Вона оплачує це повністю, додатково до своєї частки.
sharing-help-gift = Якщо людина внесла більше за свою частку: з позначкою надлишок є подарунком групі, без позначки його повертають.
sharing-help-items = Позначте людей, які беруть участь у цій позиції. Спільна — це те, що залишається від суми після вирахування інших позицій.
sharing-help-due = Скільки людина має сплатити загалом: її частка позицій, власні додатки та округлення.
sharing-help-share = Яку частину становить частка людини, у відсотках від суми, що ділиться.
sharing-help-typed = Відсоток, який ви ввели. Він може відрізнятися від фактичної частки, якщо спрацював мінімум, максимум або точна сума.
sharing-help-constraint = Показує, чи змінили частку людини мінімум, максимум, точна сума або подарований надлишок.
sharing-help-item = Лише те, що стосується не всіх, наприклад вино. Решта суми йде у спільну позицію, яку ділять ті, хто в ній позначений.
sharing-help-rule = Як ділиться ця позиція: рівні частки, за частками, у відсотках або пропорційно до доходів.
sharing-help-paid = Скільки домогосподарство або людина вже внесли, згідно з введеними платежами.
sharing-help-balance = Що ще залишилося сплатити, або скільки внесено понад частку. Приклад: «Залишилося сплатити: 61,54 €».
sharing-advice-equal = { $count ->
        [one] { $total } для однієї людини.
        [few] { $total } ÷ { $count } особи = { $amount } з кожного.
        [many] { $total } ÷ { $count } осіб = { $amount } з кожного.
       *[other] { $total } ÷ { $count } особи = { $amount } з кожного.
    }
sharing-advice-equal-varied = Порівну між учасниками, з урахуванням обмежень і винятків.
sharing-advice-parts = Усього часток: { $parts }. Одна частка — { $amount }.
sharing-advice-parts-varied = Кожен платить за своїми частками, з урахуванням обмежень і винятків. Порожнє поле рахується як 1 частка.
sharing-advice-percent-rest = До 100 % бракує { $rest } %.
sharing-advice-percent-over = Відсотки перевищують 100 % на { $over } %.
sharing-advice-percent-ok = Відсотки дають рівно 100 %.
sharing-advice-percent-nobody = Відсотки вже дають 100 %: { $count ->
        [one] { $names } нічого не заплатить.
        [few] { $names } нічого не заплатять.
        [many] { $names } нічого не заплатять.
       *[other] { $names } нічого не заплатять.
    }
sharing-advice-income = Кожен платить { $rate } % свого доходу.
sharing-advice-income-missing = Введіть дохід кожного, щоб поділити пропорційно до доходів.
sharing-advice-income-varied = Кожен платить однакову частку свого доходу, з урахуванням обмежень і винятків.
sharing-advice-empty = Введіть суму для розподілу.
sharing-apply-advice = Взяти запропоновані значення
sharing-help-apply-advice = Заповнює порожні поля значеннями, показаними сірим. Уже заповнені поля не змінюються.
sharing-from-incomes = Відсотки за доходами
sharing-help-from-incomes = Замінює відсотки часткою доходу кожного в загальній сумі доходів. Разом вони дають 100 %.
sharing-reset-percents = Розподілити все заново
sharing-help-reset-percents = Стирає відсотки й ділить їх порівну між усіма. Корисно після додавання людини.
sharing-reset-percents-question = Стерти всі відсотки й розподілити їх порівну?
sharing-open = Відкрити проєкт…
sharing-save = Зберегти проєкт…
sharing-pdf-distribution = Розподіл (PDF)
sharing-pdf-payments = Стан платежів (PDF)
sharing-pdf-statements = Індивідуальні виписки (PDF)…
sharing-statements-everyone = Усі
sharing-excel = Експорт в Excel
sharing-file-filter = Проєкт розподілу
sharing-replace-question = Відкриття цього проєкту замінить те, що введено у вікні. Продовжити?
sharing-file-saved = Проєкт збережено: { $file }
sharing-file-opened = Проєкт відкрито: { $file }
sharing-file-not-project = Цей файл не є проєктом розподілу Radinus.
sharing-file-too-recent = Цей проєкт створено в новішій версії Radinus: оновіть Radinus, щоб відкрити його.
sharing-file-failed = Не вдалося прочитати або записати файл: { $reason }
sharing-statements-replace-question = { $count ->
        [one] У цій теці вже є { $count } виписка. Замінити?
        [few] У цій теці вже є { $count } виписки. Замінити?
        [many] У цій теці вже є { $count } виписок. Замінити?
       *[other] У цій теці вже є { $count } виписки. Замінити?
    }
sharing-statements-written = { $count ->
        [one] Записано { $count } виписку в «{ $folder }».
        [few] Записано { $count } виписки в «{ $folder }».
        [many] Записано { $count } виписок у «{ $folder }».
       *[other] Записано { $count } виписки в «{ $folder }».
    }
sharing-too-many-people = У розподілі може бути щонайбільше 40 людей.
sharing-too-many-items = У розподілі може бути щонайбільше 20 позицій.
sharing-too-many-payments = У розподілі може бути щонайбільше 400 платежів.
sharing-invalid-amount = Цю суму не вдається прочитати: потрібне додатне число.
sharing-invalid-number = Це число не вдається прочитати: потрібне додатне число.
sharing-invalid-percent = Відсоток може бути від 0 до 100.
sharing-invalid-date = Цю дату не вдається прочитати.
sharing-name-missing = Кожна людина повинна мати ім'я.
sharing-name-duplicate = «{ $name }» уже є: розрізніть їх, наприклад ініціалом.
sharing-floor-above-cap = Мінімум перевищує максимум.
sharing-item-label-missing = Ця позиція не має назви.
sharing-items-above-total = Позиції та власні додатки кожного перевищують суму на { $amount }.
sharing-payment-person = Виберіть, хто заплатив.
sharing-percent-total = Відсотки дають { $sum } %: має бути 100 %.
sharing-percent-total-item = «{ $item }»: відсотки дають { $sum } %: має бути 100 %.
sharing-item-nobody = Ніхто не бере участі в «{ $item }».
sharing-item-no-weight = Ніхто нічого не вносить у «{ $item }»: усі її учасники мають нуль.
sharing-income-missing = Бракує доходу: { $name }.
sharing-fixed-above = Точні суми перевищують суму для розподілу на { $amount }.
sharing-floors-above = Мінімуми перевищують суму для розподілу на { $amount }.
sharing-cap-alone = { $name } — єдиний учасник «{ $item }»: максимум неможливо дотримати.
sharing-caps-short = Максимумів недостатньо, щоб покрити суму: бракує { $amount }.
sharing-impossible = Усі ці умови неможливо дотримати: послабте мінімум або максимум.
sharing-constraint-floor = Мінімум досягнуто
sharing-constraint-cap = Максимум досягнуто
sharing-constraint-fixed = Точна сума
sharing-constraint-gift = Подарований надлишок
sharing-and = { $first } і { $last }
sharing-outside = Поза позиціями
sharing-alone = Власні додатки
sharing-rounding = Округлення
sharing-headline-empty = Додайте людей, які ділять витрату.
sharing-headline-no-amount = Введіть суму або позиції для розподілу.
sharing-headline-equal = { $total } для розподілу: кожен платить { $amount }.
sharing-headline-range = { $total } для розподілу: від { $min } до { $max } залежно від людини.
sharing-participants = { $count ->
        [0] Немає учасників
        [one] { $count } учасник
        [few] { $count } учасники
        [many] { $count } учасників
       *[other] { $count } учасника
    }
sharing-balance-due = Залишилося сплатити: { $amount }
sharing-balance-over = Внесено на { $amount } більше за свою частку
sharing-balance-even = Усе сплачено
sharing-summary-collected = Сплачено { $collected } із { $total }.
sharing-summary-owing = { $count ->
        [0] Усі розрахувалися.
        [one] { $count } ще винен { $amount }.
        [few] { $count } ще винні разом { $amount }.
        [many] { $count } ще винні разом { $amount }.
       *[other] { $count } ще винні разом { $amount }.
    }
sharing-remaining-outside = Залишилося сплатити за витратою: { $amount }
sharing-remaining-reimburse = Повернути { $name }: { $amount }
sharing-all-settled = Усе розраховано: ніхто нікому нічого не винен.
sharing-transfer = { $from } має сплатити { $amount } на користь { $to }
sharing-warning-over-paid = Платежі перевищують витрату на { $amount }: перевірте суми.
sharing-note-income-zero = { $name } нічого не платить за { $items }: дохід дорівнює 0.
sharing-note-excluded = { $name } не бере участі в «{ $item }»: частку розподілено між іншими.
sharing-note-gift = Надлишок, подарований учасником { $giver }, зменшує частку інших: тепер { $name } має внесок більший за свою частку.
sharing-note-outside = { $name } платить { $amount } поза своїми позиціями: цю суму віднято від того, що ділять інші.
sharing-note-keeper = Округлено до цілих одиниць: { $name } залишає центи собі, щоб загальна сума зійшлася.
sharing-report-distribution = Розподіл
sharing-report-sharing = Розподіл
sharing-report-who-pays = Хто скільки платить
sharing-report-items = Деталі за позиціями
sharing-report-payments = Стан платежів
sharing-report-as-of = Станом на { $date }
sharing-report-balances = Частка, сплачено, баланс
sharing-report-statement = Виписка — { $name }
sharing-report-your-share = Ваша частка
sharing-statement-total = Усього для домогосподарства: { $amount }
sharing-statement-pay = До сплати для { $name }: { $amount }
sharing-statement-receive = До отримання від { $name }: { $amount }
sharing-sheet-people = Люди
sharing-sheet-items = Позиції
sharing-sheet-result = Результат
sharing-sheet-payments = Платежі
sharing-sheet-balances = Повернення

## Майстер експорту бази (P-74, Fabrice, 19/10/2026).
window-database-export-title = Майстер експорту бази «{ $base }»
menu-tools-export = Майстер експорту бази…
base-export-only-this = Буде експортовано лише базу «{ $base }», вибрану у списку. Інших баз це не торкнеться.
base-export-purpose = Цей майстер копіює дані бази у файли, які вміють читати інші програми: електронну таблицю, базу даних на кшталт Access, іншу програму обліку особистих фінансів. Сама база не змінюється.
base-export-step-format = 1. Формат
base-export-step-options = 2. Параметри
base-export-step-place = 3. Розташування
base-export-step-summary = 4. Підсумок
base-export-format-xlsx = Excel (.xlsx)
base-export-format-xlsx-hint = Книга з окремим аркушем для кожної таблиці, яку відкривають Excel і більшість табличних редакторів.
base-export-format-ods = Calc (.ods)
base-export-format-ods-hint = Відкритий формат LibreOffice та OpenOffice, з окремим аркушем для кожної таблиці.
base-export-format-csv = CSV (.csv)
base-export-format-csv-hint = Окремий текстовий файл для кожної таблиці, значення розділено крапкою з комою: формат, який уміють імпортувати майже всі програми, зокрема Access.
base-export-format-json = JSON (.json)
base-export-format-json-hint = Для програмістів і застосунків: кожна таблиця під своєю назвою, із заголовком, що описує експорт.
base-export-format-xml = XML (.xml)
base-export-format-xml-hint = Той самий вміст, що й у JSON, але записаний у XML.
base-export-format-sql = SQL-скрипт (.sql)
base-export-format-sql-hint = Команди, які відтворюють таблиці та їхні дані в іншій базі даних (MySQL, PostgreSQL, SQLite…).
base-export-format-sqlite = База SQLite (.sqlite)
base-export-format-sqlite-hint = Самостійна база даних без пароля, яку багато програм відкривають напряму.
base-export-format-qif = QIF, окремий файл для кожного рахунку (.qif)
base-export-format-qif-hint = Щоб перенести свої рахунки до іншої програми обліку фінансів (Money, Quicken, GnuCash, Grisbi…).
base-export-format-ofx = OFX, окремий файл для кожного рахунку (.ofx)
base-export-format-ofx-hint = Формат банківських виписок, який уміє імпортувати більшість програм обліку фінансів.
base-export-lossy = Увага: QIF і OFX передають не все. Переносяться лише операції за рахунками, з контрагентами, категоріями та коментарями; переказ стає звичайною операцією з кожного боку, а все інше (бюджети, графіки платежів, проєкти, призначення…) не переноситься. Щоб зберегти все, виберіть інший формат.
base-export-planned-note = Заплановані операції та операції без дати не експортуються: вони ще не пройшли через банк. Їхню кількість буде вказано наприкінці.
base-export-dates-hint = Дати записуються в порядку рік-місяць-день (2026-12-31), а суми — у валюті бази: жодна програма не прочитає їх хибно.
base-export-group-layout = Файли
base-export-layout-one = Усе в одному файлі
base-export-layout-per-table = Окремий файл для кожної таблиці, у теці
base-export-group-decimal = Десятковий роздільник у сумах
base-export-decimal-point = Крапка (1234.56)
base-export-decimal-comma = Кома (1234,56)
base-export-group-quotes = Лапки
base-export-quotes-all = Кожне значення в лапках
base-export-quotes-none = Без лапок
base-export-csv-replacements-hint = Щоб кожен файл читався без помилок, крапка з комою в тексті замінюється знаком оклику, перенесення рядка — пробілом, а якщо лапки не використовуються, лапки замінюються апострофом. Кількість замін буде вказано наприкінці.
base-export-group-qif-order = Порядок у датах
base-export-qif-day-month = День перед місяцем (31/12/2026)
base-export-qif-month-day = Місяць перед днем (12/31/2026)
base-export-qif-order-hint = Виберіть порядок, на який очікує програма, що читатиме файли: у Європі спершу день, у США спершу місяць.
base-export-no-option = Цей формат не має параметрів.
base-export-choose-file = Вибрати файл…
base-export-choose-folder = Вибрати теку…
base-export-place-file = Експорт буде записано в цей файл:
base-export-place-folder = Експорт буде записано в цю теку, створену спеціально для нього:
base-export-place-none = Розташування ще не вибрано.
base-export-place-needed = Спершу виберіть, куди записати експорт.
base-export-folder-exists = Тека «{ $name }» уже існує. Файли з такими самими назвами в ній буде замінено. Продовжити?
base-export-summary-base = База
base-export-summary-format = Формат
base-export-summary-options = Параметри
base-export-summary-place = Розташування
base-export-unprotected = Ця база захищена паролем, але експорт захищений не буде: будь-хто, у кого опиняться ці файли, зможе прочитати ваші рахунки. Зберігайте їх у надійному місці.
base-export-previous = Назад
base-export-next = Далі
base-export-run = Експортувати
base-export-running = Триває експорт…
base-export-done = Базу «{ $base }» експортовано: { $tables ->
        [one] { $tables } таблиця
        [few] { $tables } таблиці
        [many] { $tables } таблиць
       *[other] { $tables } таблиці
    }, { $rows ->
        [one] { $rows } рядок
        [few] { $rows } рядки
        [many] { $rows } рядків
       *[other] { $rows } рядка
    }.
base-export-done-accounts = Базу «{ $base }» експортовано: { $accounts ->
        [one] { $accounts } рахунок
        [few] { $accounts } рахунки
        [many] { $accounts } рахунків
       *[other] { $accounts } рахунку
    }, { $operations ->
        [one] { $operations } операція
        [few] { $operations } операції
        [many] { $operations } операцій
       *[other] { $operations } операції
    }.
base-export-done-replacements = { $count ->
        [one] У файлах CSV замінено { $count } символ.
        [few] У файлах CSV замінено { $count } символи.
        [many] У файлах CSV замінено { $count } символів.
       *[other] У файлах CSV замінено { $count } символу.
    }
base-export-done-controls = { $count ->
        [one] { $count } керівний символ, який цей формат не може містити, замінено на «�».
        [few] { $count } керівні символи, які цей формат не може містити, замінено на «�».
        [many] { $count } керівних символів, які цей формат не може містити, замінено на «�».
       *[other] { $count } керівного символу, які цей формат не може містити, замінено на «�».
    }
base-export-done-excel-cut = { $count ->
        [one] { $count } текст, довший за 32 767 символів (межа Excel), обрізано в книзі. Інші формати зберігають його повністю.
        [few] { $count } тексти, довші за 32 767 символів (межа Excel), обрізано в книзі. Інші формати зберігають їх повністю.
        [many] { $count } текстів, довших за 32 767 символів (межа Excel), обрізано в книзі. Інші формати зберігають їх повністю.
       *[other] { $count } тексту, довшого за 32 767 символів (межа Excel), обрізано в книзі. Інші формати зберігають його повністю.
    }
base-export-done-anomalies = { $count ->
        [one] { $count } нечитабельне значення скопійовано як є.
        [few] { $count } нечитабельні значення скопійовано як є.
        [many] { $count } нечитабельних значень скопійовано як є.
       *[other] { $count } нечитабельного значення скопійовано як є.
    }
base-export-done-planned = { $count ->
        [one] Пропущено { $count } заплановану операцію.
        [few] Пропущено { $count } заплановані операції.
        [many] Пропущено { $count } запланованих операцій.
       *[other] Пропущено { $count } запланованої операції.
    }
base-export-done-undated = { $count ->
        [one] Пропущено { $count } операцію без дати.
        [few] Пропущено { $count } операції без дати.
        [many] Пропущено { $count } операцій без дати.
       *[other] Пропущено { $count } операції без дати.
    }
base-export-done-adjusted = { $count ->
        [one] { $count } значення скориговано під формат.
        [few] { $count } значення скориговано під формат.
        [many] { $count } значень скориговано під формат.
       *[other] { $count } значення скориговано під формат.
    }
base-export-too-old = Ця база походить зі старішої версії Radinus. Спершу відкрийте її один раз у Radinus — він її оновить, — а потім експортуйте.
base-export-too-recent = Цю базу збережено новішою версією Radinus. Оновіть Radinus, щоб її експортувати.
base-export-not-radinus = Цей файл не є базою Radinus.
base-export-failed = Не вдалося виконати експорт: { $reason }

## Меню «Інструменти» вікна баз називає базу (Fabrice, 19/10/2026).
databases-tools-selected = Вибрана база: «{ $base }»
databases-tools-none = Базу не вибрано
menu-tools-backup = Створити резервну копію бази «{ $base }»…
menu-tools-backup-none = Створити резервну копію вибраної бази…
menu-tools-restore = Відновити базу «{ $base }»…
menu-tools-restore-none = Відновити вибрану базу…
menu-tools-repair = Відновити цілісність та оптимізувати базу «{ $base }»…
menu-tools-repair-none = Відновити цілісність та оптимізувати вибрану базу…
