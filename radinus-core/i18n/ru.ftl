# Radinus — сообщения ядра (Fluent), русский.
# Заполняется постепенно, по мере реализации модулей ядра, которые выдают
# сообщения пользователю. См. 08_ARCHITECTURE.md §2.1.

# Служебное «0 = Не указано», которое использует каждая необязательная ссылка
# на справочник (02_BASE_DE_DONNEES.md §7 rule 2). Первая строка каждого списка.
# ---------------------------------------------------------------------
# Название языка, написанное на нём самом.
#
# Именно его показывают меню «Настройки» и выбор языка при первом запуске
# (01_CAHIER_DES_CHARGES.md §3.5: «каждый язык написан на своём языке»).
# Оно здесь, а не в коде, потому что это единственное место, где оно может
# быть верным: добавить язык — значит положить файл, который умеет себя
# назвать.
# ---------------------------------------------------------------------
language-name = Русский

nomenclature-unspecified = Не указано

# Спрашивается перед удалением элемента справочника, который ещё используют
# операции (02_BASE_DE_DONNEES.md §7 rule 5). Воспроизведено слово в слово из
# исходного кода WinDev (Enreg_Supprimer), вместе с типографикой — формулировка
# принадлежит автору, это не перевод.
nomenclature-delete-confirm = Обнаружены операции (банковские транзакции), обладающие атрибутом типа '{ $label }'. Вы подтверждаете, что хотите сбросить этот атрибут?

# Спрашивается перед удалением элемента справочника, который нигде не
# используется. Оригинал удалял такой элемент сразу, без единого слова;
# 25/07/2026 Fabrice попросил, чтобы удаление всегда подтверждалось, — принятое
# отступление от его собственного кода, единственное в этом модуле.
nomenclature-delete-plain = Вы подтверждаете удаление «{ $label }»?

# Отказ, показываемый, когда удаляемый элемент — тот самый, который сейчас
# показывает его карточка. Решение Fabrice от 25/07/2026: элемент не удаляют
# из-под его же открытой карточки — сначала карточку закрывают, а не оставляют
# показывать запись, которой больше нет.
nomenclature-delete-form-open = Карточка «{ $label }» открыта. Закройте её перед удалением.

# Отказ, показываемый, когда сохраняемое описание уже носит другой элемент того
# же справочника (решение автора, 25/07/2026: два элемента одного справочника
# не должны носить одно имя — отнести операцию к одному из двух одинаковых
# описаний значит бросить монету). `element` — существительное в своём роде,
# «категория», «контрагент»; `label` — существующее описание, как оно хранится,
# чтобы пользователь видел, что именно мешает.
nomenclature-duplicate = Уже существует { $element } с таким же названием: «{ $label }».

# ---------------------------------------------------------------------
# То, что окна говорят о самих себе.
#
# Здесь всё, в том числе зависящее от показываемого справочника: фразы
# написаны целиком, язык за языком, а не собраны из слов и родов. Сборка,
# верная во французском, оказывается ложной в следующем языке, и в итоге
# код вынужден знать, что бывает женский род, — а это не его работа
# (правило автора, 25/07/2026: «программа работает с Fluent на французском
# и английском с самого начала»).
# ---------------------------------------------------------------------

ui-loading = Загрузка…
ui-editing = Изменение.
ui-viewing = Просмотр.
ui-modified-suffix = — изменено
ui-label-required = Описание обязательно.
ui-discard-question = Отказаться от изменений?
ui-yes = Да
ui-no = Нет
ui-select-record = Выберите запись
ui-key-multiselect = CTRL
ui-multiselect-help = Инфо: используйте щелчок мышью + клавишу [{ $modifier }] в таблице, чтобы выбрать несколько элементов
ui-no-match = Ни одно описание не соответствует фильтру.
ui-filter-placeholder = Фильтровать описания…
ui-column-label = ОПИСАНИЕ
ui-field-label = Описание
ui-field-budget-line = Статья бюджета
ui-identifier = Идентификатор
ui-deletion-abandoned = Удаление отменено: ничего не изменено.
ui-unknown-nomenclature = Неизвестный справочник:

ui-title-filter = Фильтровать
ui-title-create = Создать
ui-title-update = Изменить выбранное
ui-title-delete = Удалить выбранное
ui-title-read = Просмотреть выбранное
ui-title-close = Закрыть
ui-title-save = Сохранить
ui-title-add = Добавить
ui-title-modify = Изменить

ui-load-failed = Не удалось загрузить:
ui-save-failed = Не удалось сохранить:
ui-read-failed = Не удалось прочитать:
ui-delete-failed = Не удалось удалить:
ui-open-failed = Не удалось открыть:
ui-close-failed = Не удалось закрыть:

# --- Фразы, свойственные каждому справочнику -------------------------

nomenclature-identifier = { $kind ->
    [category] Идентификатор категории
    [assignment] Идентификатор назначения
    [payment-mode] Идентификатор способа оплаты
    [payee] Идентификатор контрагента
    [project] Идентификатор проекта
    [budget-line] Идентификатор статьи бюджета
   *[bank] Идентификатор банка
}

nomenclature-none = { $kind ->
    [category] Нет категорий.
    [assignment] Нет назначений.
    [payment-mode] Нет способов оплаты.
    [payee] Нет контрагентов.
    [project] Нет проектов.
    [budget-line] Нет статей бюджета.
   *[bank] Нет банков.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Нет категорий для показа.
    [assignment] Нет назначений для показа.
    [payment-mode] Нет способов оплаты для показа.
    [payee] Нет контрагентов для показа.
    [project] Нет проектов для показа.
    [budget-line] Нет статей бюджета для показа.
   *[bank] Нет банков для показа.
}

nomenclature-gone = { $kind ->
    [category] Этой категории больше не существует.
    [assignment] Этого назначения больше не существует.
    [payment-mode] Этого способа оплаты больше не существует.
    [payee] Этого контрагента больше не существует.
    [project] Этого проекта больше не существует.
    [budget-line] Этой статьи бюджета больше не существует.
   *[bank] Этого банка больше не существует.
}

nomenclature-fresh = { $kind ->
    [category] Новая категория.
    [assignment] Новое назначение.
    [payment-mode] Новый способ оплаты.
    [payee] Новый контрагент.
    [project] Новый проект.
    [budget-line] Новая статья бюджета.
   *[bank] Новый банк.
}

nomenclature-created = { $kind ->
    [category] Категория добавлена.
    [assignment] Назначение добавлено.
    [payment-mode] Способ оплаты добавлен.
    [payee] Контрагент добавлен.
    [project] Проект добавлен.
    [budget-line] Статья бюджета добавлена.
   *[bank] Банк добавлен.
}

nomenclature-updated = { $kind ->
    [category] Категория изменена.
    [assignment] Назначение изменено.
    [payment-mode] Способ оплаты изменён.
    [payee] Контрагент изменён.
    [project] Проект изменён.
    [budget-line] Статья бюджета изменена.
   *[bank] Банк изменён.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] Удалена { $count } категория.
        [few] Удалено { $count } категории.
        [many] Удалено { $count } категорий.
       *[other] Удалено { $count } категории.
      }
    [assignment] { $count ->
        [one] Удалено { $count } назначение.
        [few] Удалено { $count } назначения.
        [many] Удалено { $count } назначений.
       *[other] Удалено { $count } назначения.
      }
    [payment-mode] { $count ->
        [one] Удалён { $count } способ оплаты.
        [few] Удалено { $count } способа оплаты.
        [many] Удалено { $count } способов оплаты.
       *[other] Удалено { $count } способа оплаты.
      }
    [payee] { $count ->
        [one] Удалён { $count } контрагент.
        [few] Удалено { $count } контрагента.
        [many] Удалено { $count } контрагентов.
       *[other] Удалено { $count } контрагента.
      }
    [project] { $count ->
        [one] Удалён { $count } проект.
        [few] Удалено { $count } проекта.
        [many] Удалено { $count } проектов.
       *[other] Удалено { $count } проекта.
      }
    [budget-line] { $count ->
        [one] Удалена { $count } статья бюджета.
        [few] Удалено { $count } статьи бюджета.
        [many] Удалено { $count } статей бюджета.
       *[other] Удалено { $count } статьи бюджета.
      }
   *[bank] { $count ->
        [one] Удалён { $count } банк.
        [few] Удалено { $count } банка.
        [many] Удалено { $count } банков.
       *[other] Удалено { $count } банка.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Уже существует категория с таким же названием: «{ $label }».
    [assignment] Уже существует назначение с таким же названием: «{ $label }».
    [payment-mode] Уже существует способ оплаты с таким же названием: «{ $label }».
    [payee] Уже существует контрагент с таким же названием: «{ $label }».
    [project] Уже существует проект с таким же названием: «{ $label }».
    [budget-line] Уже существует статья бюджета с таким же названием: «{ $label }».
   *[bank] Уже существует банк с таким же названием: «{ $label }».
}

# --- Заголовки окон, без диакритики, как в исходных окнах -------------

window-list-title = { $kind ->
    [category] Список категорий
    [assignment] Список назначений
    [payment-mode] Список способов оплаты
    [payee] Список контрагентов и продавцов
    [project] Список проектов
    [budget-line] Список статей бюджета
   *[bank] Список банков
}

window-form-title = { $kind ->
    [category] Карточка категории
    [assignment] Карточка назначения
    [payment-mode] Карточка способа оплаты
    [payee] Карточка контрагента
    [project] Карточка проекта
    [budget-line] Карточка статьи бюджета
   *[bank] Карточка банка
}

# --- Строка меню (01_CAHIER_DES_CHARGES.md §6) ------------------------

menu-file = Файл
menu-file-import-statements = Импорт банковских выписок
menu-file-import-excel = Импорт файла Excel
menu-file-backup = Резервная копия
menu-file-restore = Восстановление
menu-file-repair = Восстановление целостности и оптимизация базы данных
menu-file-log = Показать журнал
menu-tools-password = Защитить базу данных паролем
menu-file-disconnect = Отключиться от текущей базы
menu-file-quit = Выход

menu-accounts = Счета
menu-accounts-manage = Управление банковскими счетами
menu-accounts-balances = Просмотр балансов ваших счетов
menu-accounts-operations = Управление операциями счёта
menu-accounts-quick-classify = Быстрая классификация операций
menu-accounts-recurring = Управление периодическими операциями
menu-accounts-transfer = Перевод суммы между двумя счетами
menu-accounts-checkbooks = Управление чековыми книжками

menu-statistics = Статистика
menu-statistics-balance-chart = График изменения баланса
menu-statistics-by-category = Статистика по категориям
menu-statistics-by-assignment = Статистика по назначениям
menu-statistics-by-budget-line = Статистика по статьям бюджета
menu-statistics-by-payment-mode = Статистика по способам оплаты
menu-statistics-by-payee = Статистика по контрагентам и продавцам
menu-statistics-by-project = Статистика по проектам
menu-statistics-dashboard = Сводная панель операций

menu-budget = Бюджет
menu-budget-entry = Ввод бюджета
menu-budget-control = Контроль бюджета

menu-nomenclatures = Справочники
menu-nomenclature = { $kind ->
    [category] Категории
    [assignment] Назначения
    [payment-mode] Способы оплаты
    [payee] Контрагенты и продавцы
    [project] Проекты
    [budget-line] Статьи бюджета
   *[bank] Банки
}
menu-nomenclatures-templates = Шаблоны операций

menu-settings = Настройки
menu-settings-about-author = Об авторе
menu-settings-about-radinus = О Radinus
menu-settings-licence = Лицензия

menu-misc = Разное
menu-misc-calculator = Калькулятор
menu-misc-website = Перейти на сайт Radinus
menu-misc-database-folder = Доступ к папке с базой данных

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Открыть папку базы данных
database-folder-warning =
    В этой папке хранятся все ваши данные. Переименование, перемещение или удаление файла может привести к потере счетов, их повреждению или к неработоспособности Radinus.
    Действительно открыть её?
menu-misc-application-folder = Доступ к папке с приложением

# ---------------------------------------------------------------------
# Банковские счета — F04, F06, F07, F08.
# Опечатки версии 1.9.3 («Bank Identifer Code», «Solde initial prevu»,
# «Est Cloturé», пробел перед скобкой в IBAN) исправлены: решение Fabrice
# от 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Управление банковскими счетами
window-accounts-select-title = Список счетов
window-balances-title = Балансы ваших счетов
window-account-title = Карточка счёта

accounts-none = Нет счетов.
accounts-nothing-to-show = Нет счетов для отображения.
accounts-gone = Этот счёт больше не существует.
accounts-fresh = Новый счёт.
accounts-created = Счёт добавлен.
accounts-updated = Счёт изменён.
accounts-deleted = { $count ->
    [one] Удалён { $count } счёт.
    [few] Удалено { $count } счёта.
    [many] Удалено { $count } счетов.
   *[other] Удалено { $count } счёта.
}
accounts-duplicate-name = Счёт с таким названием уже существует: «{ $label }».
accounts-multiselect-help = Информация: используйте щелчок мыши + клавишу [{ $modifier }] в таблице, чтобы выбрать несколько счетов
accounts-select-question = По каким банковским счетам строить статистику?

accounts-column-label = НАЗВАНИЕ
accounts-column-bank = Банк
accounts-column-type = Тип счёта
accounts-column-number = Номер счёта
accounts-column-account = Счёт
accounts-column-bank-balance = В банке
accounts-column-real-balance = Реальный
accounts-column-final-balance = Итоговый
accounts-total = ИТОГО

# Удаление счёта уносит с собой его операции: это единственное место
# в программе, где удаление уничтожает историю.
accounts-delete-plain = Подтверждаете удаление счёта «{ $label }»?
accounts-delete-with-operations = Счёт «{ $label }» содержит { $count } операций, которые будут удалены вместе с ним. Подтверждаете удаление?
accounts-delete-form-open = Карточка счёта «{ $label }» открыта. Закройте её перед удалением.

account-group-bank = Сведения о счёте и банке
account-group-holder = Владелец
account-group-rib = Банковские реквизиты (RIB)
account-group-activity = Активность
account-group-balances = Балансы

account-field-label = Название счёта
account-field-bank = Банк
account-field-type = Тип счёта
account-field-branch-address = Адрес отделения банка
account-field-holder-name = Имя
account-field-holder-address = Адрес
account-field-rib-bank = Код банка
account-field-rib-branch = Код отделения
account-field-rib-number = Номер счёта
account-field-rib-key = Ключ RIB
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Дата открытия
account-field-closing-date = Дата закрытия
account-field-closed = Закрыт
account-field-opening-pointed = Начальный сверенный баланс
account-field-opening-committed = Начальный зарезервированный баланс
account-field-opening-planned = Начальный запланированный баланс

account-label-required = Название счёта обязательно.
account-iban-invalid = Этот IBAN недействителен: проверьте контрольный ключ.
# Синяя строка внизу карточки, слово в слово как в 1.9.3 — только суммы
# теперь следуют французскому формату остальных полей.
account-control-line = Начальный сверенный баланс ({ $opening }) + Итого по операциям ({ $operations }) = Текущий банковский баланс: { $balance }.

amount-not-readable = «{ $field }» не содержит допустимой суммы.

ui-thousands-separator =  
ui-decimal-separator = ,

# --- Список операций (F02) -------------------------------------------

window-operations-title = Список операций по счёту: { $account }

operations-none = Нет операций за этот период.
operations-bad-period = Границы периода не являются допустимыми датами.
operations-from = Дата начала
operations-to = Дата окончания
operations-delete-confirm = { $count ->
    [one] Подтверждаете удаление этой операции?
    [few] Подтверждаете удаление этих { $count } строк? Подоперации выбранных операций удаляются вместе с ними.
    [many] Подтверждаете удаление этих { $count } строк? Подоперации выбранных операций удаляются вместе с ними.
   *[other] Подтверждаете удаление этих { $count } строк? Подоперации выбранных операций удаляются вместе с ними.
}
operations-deleted = { $count ->
    [one] Удалена { $count } операция.
    [few] Удалено { $count } операции.
    [many] Удалено { $count } операций.
   *[other] Удалено { $count } операции.
}
operations-selection-total = Общая сумма выбранных операций: { $amount }

operations-column-date = Дата
operations-column-clearing-date = Дата сверки
operations-column-label = Описание
operations-column-category = Категория
operations-column-assignment = Назначение
operations-column-payment-mode = СпособОпл
operations-column-payee = Контрагент
operations-column-project = Проекты
operations-column-month = Месяц
operations-column-debit = Расход
operations-column-credit = Приход
operations-column-balance = Баланс
operations-column-comments = Комментарии
operations-column-attachments = Вложения
operations-column-check = Номер чека

operations-foot-debit = Расход:
operations-foot-credit = Приход:
operations-foot-total = Итого:
operations-foot-bank = Банковский баланс:
operations-foot-real = Реальный баланс:
operations-foot-final = Итоговый баланс:

operations-menu-export = Экспорт
operations-menu-print = Печать
operations-menu-filter = Фильтр
operations-menu-period = Период
operations-menu-misc = Разное

operations-title-point = Сверить выбранное
operations-title-sub = Добавить подоперацию
operations-title-duplicate = Дублировать выбранное
operations-not-yet = Этого окна пока нет: оно появится дальше по плану.

accounts-choose-question = С каким счётом вы хотите работать?
ui-title-select = Выбрать выделение

month-january = январь
month-february = февраль
month-march = март
month-april = апрель
month-may = май
month-june = июнь
month-july = июль
month-august = август
month-september = сентябрь
month-october = октябрь
month-november = ноябрь
month-december = декабрь

operations-period-year = Текущий год

# --- Меню «Период» окна F02 ------------------------------------------
# Девять пунктов, два из которых открывают подменю с двенадцатью месяцами.
# Каждый из них делает лишь одно: выводит дату начала и дату окончания,
# которые окно подставляет в свои два поля (просьба Fabrice, 25/07/2026).

period-all = Все
period-last-year = Прошлый год
period-this-year = Текущий год
period-whole-year = Весь год
period-last-month = Прошлый месяц
period-this-month = Текущий месяц
period-last-week = Прошлая неделя
period-this-week = Текущая неделя
period-yesterday = Вчера
period-today = Сегодня

# --- Меню «Фильтр» окна F02 ------------------------------------------
# Фильтрует строки по характеру операции (просьба Fabrice, 25/07/2026).
# Три статуса — те же, что в базе: 1 сверено, 2 зарезервировано,
# 3 запланировано (02_BASE_DE_DONNEES.md §5.2).

filter-all = Все операции
filter-pointed = Только сверенные операции
filter-committed = Только зарезервированные операции
filter-planned = Только запланированные операции

# --- Карточка операции (F03) -----------------------------------------
# Названия полей взяты со снимка « Fiche operation transaction.png »,
# опечатки оригинала исправлены (разрешение Fabrice, 25/07/2026:
# « les coquilles tu les corriges »): « Libelle » становится « Libellé »,
# « Categorie » становится « Catégorie », « Statut Operation » становится
# « Statut opération ».

window-operation-title = Операция по счёту: { $account }

operation-menu-identification = Идентификация
operation-menu-options = Параметры
operation-fitid-edit = Изменить идентификатор FITID…
operation-fitid-delete = Удалить идентификатор FITID
operation-fitid-question = Идентификатор FITID этой операции:
operation-fitid-delete-question = Удалить идентификатор FITID этой операции?
operation-fitid-written = Идентификатор FITID сохранён.
operation-fitid-removed = Идентификатор FITID удалён.

operation-group-identification = Идентификация операции
operation-group-amount = Сумма операции
operation-group-status = Статус операции
operation-group-classification = Классификация операции для расчёта статистики
operation-group-check = Чек, связанный с операцией
operation-group-comment = Комментарий

operation-field-label = Описание
operation-field-reference = Ссылка платежа
operation-field-date = Дата
operation-field-direction = Тип операции:
operation-field-amount = Сумма
operation-field-status = Статус операции
operation-field-clearing-date = Дата сверки
operation-field-category = Категория
operation-field-assignment = Назначение
operation-field-payment-mode = Способ
operation-field-payee = Контрагент
operation-field-project = Проект
operation-field-check = Связать с чеком

operation-direction-debit = Расход
operation-direction-credit = Приход

operation-check-info = Инфо.
operation-check-link = Связать
operation-check-unlink = Удалить

operation-fresh = Новая операция.
operation-created = Операция добавлена.
operation-updated = Операция изменена.
operation-gone = Этой операции больше не существует.
operation-nothing-to-show = Нет операций для показа.
operation-label-required = Описание операции обязательно.
operation-date-required = Дата операции обязательна.
operation-clearing-date-invalid = Дата сверки не является допустимой датой.
operation-is-a-sub = Эта строка — подоперация: она изменяется в своей собственной карточке.
operation-delete-form-open = Карточка «{ $label }» открыта. Закройте её перед удалением.

operation-attachments = { $count ->
    [0] Нет вложений
    [one] { $count } вложение
    [few] { $count } вложения
    [many] { $count } вложений
   *[other] { $count } вложения
}

operation-title-comment = Комментарий операции
operation-title-sub = Создать подоперацию
operation-title-template = Шаблоны операций
operation-title-attachment = Вложения

# --- Карточка подоперации (F04) --------------------------------------
# Сокращённый вариант F03: ни Способа, ни Статуса, ни Даты — подоперация
# берёт их у своей матери (`Maj_ProprieteSousOp`, подтверждено Fabrice
# 26/07/2026: « dans une sous-opération, comme est le complément, on ne peut
# pas toucher au mode de paiement, cela serait illogique »).

window-sub-operation-title = Карточка подоперации

sub-operation-group-amount = Сумма подоперации
sub-operation-field-label = Название
sub-operation-fresh = Новая подоперация.
sub-operation-created = Подоперация добавлена.
sub-operation-updated = Подоперация изменена.
sub-operation-gone = Этой подоперации больше не существует.
sub-operation-nothing-to-show = Нет подопераций для показа.
sub-operation-label-required = Название подоперации обязательно.
sub-operation-parent-gone = Операции, которую нужно разнести, больше не существует.
# Что говорит карточка, когда показывает Остаток. Он не защищён: его можно
# изменить, но надо понимать, что берёшь (решение Fabrice, 26/07/2026).
sub-operation-is-the-complement = Это Остаток: то, что осталось разнести. Если его переименовать или изменить его сумму, он становится обычной подоперацией.
sub-operation-of = Разнесение «{ $label }» ({ $amount })

operations-pointed = { $count ->
    [one] Сверена { $count } операция.
    [few] Сверено { $count } операции.
    [many] Сверено { $count } операций.
   *[other] Сверено { $count } операции.
}
operations-select-one = Выберите только одну операцию.

# --- Дублирование и показ подопераций (F02) ---------------------------
# Дублирование открывает предзаполненную карточку, которую пользователь
# подтверждает сам (решение Fabrice, 26/07/2026): пока он не сохранил,
# ничего не записано, и он может исправить дату или сумму заранее.

operation-copy = Копия ещё не сохранена: пока ничего не создано.
operations-show-children = Показать все подоперации
operations-hide-children = Скрыть все подоперации

# --- Второе подтверждение опасного удаления ---------------------------
# Удаление банковского счёта уносит всю его историю: Да/Нет нажимают не
# читая, поэтому мы просим написать слово (решение Fabrice, 26/07/2026).
# Слово берётся из словаря — здесь « Да », по-английски « Yes » — так что
# переводить тут дважды нечего.

accounts-delete-second-question = Это удаление окончательно и уносит всю историю счёта. Напишите «{ $word }», чтобы его подтвердить.

# --- F20-F24 — Шесть видов статистики ---------------------------------
# Общий шаблон, разложенный по шести осям. Та, что по категориям, послужила
# образцом, и Fabrice утвердил её 26/07/2026, ещё до того как появились
# остальные пять, — названия столбцов взяты из оригинала.

window-statistics-title = { $kind ->
    [assignment] Статистика по назначениям
    [budget-line] Статистика по статьям бюджета
    [payment-mode] Статистика по способам оплаты
    [payee] Статистика по контрагентам и продавцам
    [project] Статистика по проектам
   *[category] Статистика по категориям
}

statistics-axis-column = { $kind ->
    [assignment] Назначение
    [budget-line] СтатьяБюджета
    [payment-mode] СпособОперации
    [payee] Контрагент
    [project] Проекты
   *[category] НазваниеКатегории
}

statistics-unclassified = { $kind ->
    [assignment] Без назначения
    [budget-line] Без статьи бюджета
    [payment-mode] Без способа оплаты
    [payee] Без контрагента
    [project] Без проекта
   *[category] Без категории
}
statistics-total = Итого
statistics-sum = Сумма
statistics-cumulative = Нарастающий итог

# Пять переключателей панели. Надпись переключается ON/OFF, как в
# оригинале: сам переключатель говорит, в каком он положении.
statistics-switch-pointed = Сверенные операции { $state }
statistics-switch-committed = Зарезервированные операции { $state }
statistics-switch-planned = Запланированные операции { $state }
statistics-switch-debits = Суммы расходов { $state }
statistics-switch-credits = Суммы приходов { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Не выбран ни один счёт: статистике не по чему считать.
statistics-no-data = За этот год по выбранным счетам нет ни одной операции.
statistics-detail-empty = Нажмите на ячейку с числом, чтобы увидеть операции, которые она считает.
statistics-detail-none = За этой ячейкой нет ни одной операции.
statistics-accounts = { $count ->
    [one] { $count } счёт
    [few] { $count } счёта
    [many] { $count } счетов
   *[other] { $count } счёта
}
statistics-year-next = Следующий год
statistics-year-previous = Предыдущий год

statistics-column-date = Дата
statistics-column-clearing-date = ДатаСверки
statistics-column-label = Описание
statistics-column-amount = Сумма
statistics-column-comments = Комментарии

accounts-stats-multiselect-help = Инфо: используйте щелчок мыши + клавишу [{ $modifier }] на таблице, чтобы выбрать несколько счетов

# Год статистики: по нему щёлкают и вводят год. Границы те же, что у
# « Все » в меню Период — год в Radinus это целое число от 1950 до 2550
# (Fabrice, 26/07/2026).
statistics-year-question = За какой год вы хотите работать? Radinus идёт от { $first } до { $last }.
statistics-year-choose = Выбрать год

# --- Экспорт таблиц (правый щелчок) -----------------------------------
# Это функция таблицы, а не окна: она есть у всех списков.

export-to-excel = Экспорт в Excel (.xlsx)
export-to-word = Экспорт в Word (.docx)
export-to-tsv = Экспорт в TSV (.tsv)
export-to-ini = Экспорт в INI (.ini)
export-to-toml = Экспорт в TOML (.toml)
export-to-yaml = Экспорт в YAML (.yaml)
export-to-ofx = Экспорт в OFX (.ofx)
export-to-qif = Экспорт в QIF (.qif)
export-to-ods = Экспорт в LibreOffice Calc (.ods)
export-to-csv = Экспорт в CSV (.csv)
export-to-xml = Экспорт в XML (.xml)
# Меню Экспорт окна статистики: по одной вкладке на год, с именем AN_2026.
# Пустых лет — при заданных положениях переключателей — там нет.
export-menu = Экспорт
export-all-years-excel = Экспортировать все годы в Excel
export-all-years-ods = Экспортировать все годы в LibreOffice Calc
export-no-year = Ни в одном году нет операций: экспортировать нечего.
export-years-done = Экспортировано лет: { $years } — в «{ $file }».
export-to-json = Экспорт в JSON (.json)
export-done = Экспортировано в «{ $file }».
export-failed = Экспорт невозможен: { $reason }
export-nothing = Экспортировать нечего.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Статистика по назначениям
    [budget-line] Статистика по статьям бюджета
    [payment-mode] Статистика по способам оплаты
    [payee] Статистика по контрагентам и продавцам
    [project] Статистика по проектам
   *[category] Статистика по категориям
}
statistics-detail-name = Детализация статистики

# --- F19 — Панель управления -------------------------------------------
# Один период и три переключателя; две кольцевые диаграммы по статьям
# бюджета; три крупные цифры. Цвета секторов — те же, что в оригинале,
# снятые со скриншота Фабриса.

window-dashboard-title = Панель управления
dashboard-menu-period = Период
dashboard-menu-misc = Разное
dashboard-from = Дата начала:
dashboard-to = Дата окончания:
dashboard-switch-pointed = Включить сверенные операции
dashboard-switch-committed = Включить зарезервированные операции
dashboard-switch-planned = Включить запланированные операции
dashboard-spending = Расходы
dashboard-earning = Доходы
dashboard-debits = Сумма расходных операций
dashboard-credits = Сумма приходных операций
dashboard-balance = Баланс
dashboard-unclassified = Без статьи бюджета
dashboard-nothing = Нет операций за этот период.
dashboard-no-account = Не выбран ни один счёт: панели управления не по чему строиться.
dashboard-enlarge = Открыть во весь экран

# --- F25 — Динамика баланса ---------------------------------------------
# По одному графику на каждый выбранный счёт плюс график итога — который
# существует только начиная с двух счетов (правило Фабриса, 26/07/2026).
# Графики ступенчатые: баланс сохраняет своё значение до следующей операции.

window-curve-title = Динамика баланса
curve-heading = Динамика баланса по дням
curve-menu-period = Период
curve-total = Итого
curve-from = Дата начала:
curve-to = Дата окончания:
curve-axis-balance = баланс
curve-nothing = Не выбран ни один счёт: график строить не по чему.
curve-empty = Нет операций за этот период.

# --- F05 — Быстрая классификация операций -------------------------------
# Окно, в котором классифицируют **массово**: выделяют строки, отмечают
# признаки, которые нужно изменить, и применяют их разом — в памяти.
# Ничего не записывается, пока не сохранено, а сохранение записывает
# только то, что отличается от прочитанного (правила Фабриса,
# 27/07/2026).

window-quick-classification-title = Быстрая классификация операций: { $account }
quick-dates-title = Даты начала и конца списка.
quick-from = Дата начала
quick-to = Дата окончания
quick-menu-period = Период
quick-change-title = Изменить признаки выделенного на:
quick-check-category = Категория
quick-check-assignment = Назначение
quick-check-payment-mode = Способ
quick-check-payee = Контрагент
quick-check-project = Проект
quick-check-status = Статус
quick-column-date = Дата
quick-column-label = Описание
quick-column-amount = Сумма
quick-column-category = Категория
quick-column-assignment = Назначение
quick-column-payment-mode = Способ оплаты
quick-column-payee = Контрагент
quick-column-project = Проекты
quick-column-status = Статус
# На Mac Ctrl + щелчок — это правый щелчок: клавиша, добавляющая к
# выделению, здесь ⌘, и подсказка должна называть ту, которая работает.
quick-multiselect-help = Инфо: используйте щелчок мышью + клавишу [{ $modifier }] в таблице, чтобы выделить несколько элементов
quick-none = Нет операций за этот период.
quick-select-lines = Выделите хотя бы одну строку и отметьте хотя бы один признак.
quick-applied = { $count ->
    [0] Ничего не изменилось: эти строки уже имели такую классификацию.
    [one] Классифицирована { $count } строка. Пока ничего не сохранено.
    [few] Классифицировано { $count } строки. Пока ничего не сохранено.
    [many] Классифицировано { $count } строк. Пока ничего не сохранено.
   *[other] Классифицировано { $count } строки. Пока ничего не сохранено.
}
quick-pending = { $count ->
    [0] Нет несохранённых изменений.
    [one] Изменена { $count } строка, не сохранена.
    [few] Изменено { $count } строки, не сохранены.
    [many] Изменено { $count } строк, не сохранены.
   *[other] Изменено { $count } строки, не сохранены.
}
quick-save-question = { $count ->
    [one] Сохранить { $count } ожидающее изменение?
    [few] Сохранить { $count } ожидающих изменения?
    [many] Сохранить { $count } ожидающих изменений?
   *[other] Сохранить { $count } ожидающих изменения?
}
quick-saved = { $count ->
    [0] Сохранять было нечего.
    [one] Сохранена { $count } строка.
    [few] Сохранено { $count } строки.
    [many] Сохранено { $count } строк.
   *[other] Сохранено { $count } строки.
}
quick-nothing-to-save = Нет несохранённых изменений.
quick-leave-question = Некоторые изменения не сохранены. Что вы хотите сделать?
quick-leave-save = Сохранить и выйти
quick-leave-discard = Выйти без сохранения
quick-leave-stay = Остаться
quick-title-apply = Применить к выделенным строкам ( в памяти )
quick-title-save = Сохранить на диск

# --- F17 / F18 — Импорт банковской выписки ------------------------------
# Выбирают счёт, открывают файл OFX — который остаётся в оперативной
# памяти, — строки, уже известные базе, показываются пастельным цветом, а
# третья иконка их включает: массово, если выбрано несколько, иначе по
# одной через карточку сверки (порядок действий Фабриса, 27/07/2026).

window-statement-import-title = Импорт выписок по банковским счетам: { $account }
window-statement-form-title = Сверить транзакцию (Включает операцию в историю вашего счёта)
statement-menu-filter = Фильтр
statement-filter-all = Все строки
statement-filter-pending = К включению
statement-filter-known = Уже включены
statement-column-id = ID
statement-column-reconciled = Сверено
statement-column-fitid = FITID
statement-column-date = Дата
statement-column-label = Описание
statement-column-debit = Расход
statement-column-credit = Приход
statement-account = Счёт
statement-file = Файл
statement-difference = Разница
statement-none = Ни одна выписка не открыта: нажмите на жёлтую папку, чтобы выбрать файл.
statement-empty = Эта выписка не содержит ни одной операции.
statement-no-match = Ни одна строка не подходит под фильтр.
statement-help = Инфо: используйте щелчок мышью + клавишу [{ $modifier }] в таблице, чтобы выделить несколько строк
statement-choose-account = Этот файл содержит несколько счетов. Какой из них вы хотите импортировать?
statement-select-line = Выделите хотя бы одну строку выписки.
statement-title-open = Открыть файл выписки (.ofx)
statement-title-info = Сведения об открытом файле
statement-title-integrate = Включить выделенное в счёт
statement-title-validate = Включить эту операцию в счёт
statement-duplicate = Внимание, дубликат: эта транзакция, похоже, уже была включена в базу (Financial Institution Transaction ID существует)
statement-no-fitid = Внимание: этот файл не даёт никакого идентификатора (FITID) для этой строки. Дубликат обнаружить не удастся.
statement-loaded = { $count ->
    [0] Этот файл не содержит ни одной операции по этому счёту.
    [one] Прочитана { $count } строка, из них { $known } уже есть в вашем счёте.
    [few] Прочитано { $count } строки, из них { $known } уже есть в вашем счёте.
    [many] Прочитано { $count } строк, из них { $known } уже есть в вашем счёте.
   *[other] Прочитано { $count } строки, из них { $known } уже есть в вашем счёте.
}
statement-integrated = { $count ->
    [0] Ничего не внесено: эти строки уже есть в вашем счёте.
    [one] Включена { $count } операция.
    [few] Включено { $count } операции.
    [many] Включено { $count } операций.
   *[other] Включено { $count } операции.
}
# **Сообщения оригинала, слово в слово** (указание Фабриса, 28/07/2026:
# оставаться верным исходному коду). Оригинал предупреждает перед пакетной
# обработкой, спрашивает построчно при дубликате и отчитывается в конце.

statement-mass-question =
    Вы уверены, что хотите включить в ваш счёт сразу несколько операций?
    Вам придётся позже разнести их по категориям и признакам, чтобы делать точную статистику
    В случае файлов Ofx: если будут обнаружены дубликаты, вам придётся выбрать поведение программы
    Для других типов файлов: вам придётся следить за дубликатами
statement-duplicate-question =
    Транзакция: { $date } { $label }: { $amount }
    похоже, уже была включена в историю транзакций вашего банковского счёта.
    Вы действительно хотите выполнить сверку?
statement-already-reconciled = Вы уже сверили эту транзакцию: она уже включена в историю транзакций вашего счёта
statement-integration-report =
    Включение завершено.
    Число включённых записей: { $added }
    Число пропущенных записей: { $ignored }
statement-integration-abandoned =
    Включение прервано!
    Число включённых записей: { $added }
    Число пропущенных записей: { $ignored }
statement-yes = Да
statement-no = Нет
statement-cancel = Отменить
statement-file-info =
    Счёт из файла: { $account }
    Период: с { $from } по { $to }
    Баланс, заявленный банком: { $balance }
    { $count } операций, из них { $known } уже есть в вашем счёте.
statement-group-identification = Идентификация операции
statement-group-amount = Сумма операции
statement-group-classification = Классификация операции для расчёта статистики
statement-group-status = Статус операции
statement-field-date = Дата
statement-field-label = Описание
statement-field-type = Тип операции
statement-field-amount = Сумма
statement-field-mode = Способ оплаты
statement-field-category = Категория
statement-field-assignment = Назначение
statement-field-payee = Контрагент
statement-field-project = Проект
statement-field-status = Статус
statement-field-clearing = Дата сверки

# --- Окно разбора выписки CSV -------------------------------------------
# CSV не несёт никаких надёжных имён полей: настраивают, проверяют,
# смотрят, начинают заново. Предварительный просмотр показывает всё,
# включая абракадабру, — так и видно, что ошиблись, — но в окно включения
# переходят только правильные строки (правило Фабриса, 27/07/2026).

window-csv-statement-title = Импорт данных из файла csv
csv-preview-title = Предварительный просмотр файла:
csv-settings-title = Параметры разбора файла для извлечения данных:
csv-extraction-title = Просмотр извлечённых данных согласно параметрам разбора  ( проверьте согласованность данных ):
csv-column-line = № строки
csv-column-content = Содержимое
csv-header-lines = Число строк заголовка файла, которые нужно пропустить
csv-separator = Данные (столбцы) разделены символом:
csv-date-at = Позиция поля даты
csv-label-at = Позиция поля описания
csv-debit-at = Позиция поля суммы расхода
csv-credit-at = Позиция поля суммы прихода
csv-test = Проверить параметры
csv-separator-semicolon = Точка с запятой   ;
csv-separator-comma = Запятая   ,
csv-separator-tab = Табуляция
csv-separator-pipe = Вертикальная черта   |
csv-separator-space = Пробел
csv-help = Настройте, проверьте, посмотрите: импортированы будут только строки с читаемой датой и читаемой суммой.
csv-none = Файл пуст.
csv-not-tested = Нажмите «Проверить параметры», чтобы увидеть, что даёт разбор.
csv-extraction = { $count ->
    [0] Разбор не даёт ни одной строки: проверьте число строк заголовка и разделитель.
    [one] Разобрана { $count } строка: импортировано будет { $valid }, отброшено { $dropped } из-за нечитаемой даты или суммы.
    [few] Разобрано { $count } строки: импортировано будет { $valid }, отброшено { $dropped } из-за нечитаемой даты или суммы.
    [many] Разобрано { $count } строк: импортировано будет { $valid }, отброшено { $dropped } из-за нечитаемой даты или суммы.
   *[other] Разобрано { $count } строки: импортировано будет { $valid }, отброшено { $dropped } из-за нечитаемой даты или суммы.
}
csv-nothing-valid = Ни в одной строке нет одновременно читаемой даты и читаемой суммы: импортировать нечего. Проверьте число строк заголовка, разделитель и позиции полей.
csv-title-validate = Перевести правильные строки в импорт

# --- F13 / F31 / F14 / F12 — Чековые книжки и чеки (этап 9) -------------
# Перенос его пяти кодов WinDev и семи снимков экрана, переданных
# 28/07/2026. Его точные фразы там, где они у него есть; мои — в остальных
# местах.
#
# Три решения о точности, которые он принял в тот день и которые слышны в
# словах: о повторяющемся обозначении не сообщается (его `Existe_Reference`
# никогда не вызывается), количество чеков не сверяется с границами, а
# счётчик операций считает подоперации, которые списки не показывают.

window-chequebooks-title = Список чековых книжек
window-chequebook-title = Параметры чековой книжки
window-cheques-title = Состав чековой книжки: список чеков.
window-cheque-title = Карточка чеков
window-cheque-operations-title = Список операций.

# Список чековых книжек (F13) — все книжки по всем счетам сразу: его два
# столбца со счётом были бы бесполезны в пределах одного счёта.
chequebooks-column-reference = ОПИСАНИЕ
chequebooks-column-date = Дата
chequebooks-column-account = ИмяСчёта
chequebooks-column-account-number = Номер счёта
chequebooks-column-comments = Комментарии
chequebooks-none = Ни одной чековой книжки не зарегистрировано.
chequebooks-nothing-to-show = Ни одна чековая книжка не соответствует этому запросу.
chequebooks-title-composition = Посмотреть состав чековой книжки
chequebooks-delete-question = Обнаружены операции (банковские транзакции), связанные с чековой книжкой. Вы подтверждаете, что хотите удалить эту чековую книжку?
chequebooks-deleted = { $count ->
    [one] Удалена { $count } чековая книжка.
    [few] Удалено { $count } чековые книжки.
    [many] Удалено { $count } чековых книжек.
   *[other] Удалено { $count } чековой книжки.
}
chequebooks-gone = Этой чековой книжки больше не существует.
chequebooks-created = Чековая книжка сохранена вместе со всеми её чеками.
chequebooks-updated = Чековая книжка изменена.
# Молчание его `HAjoute`: окно не говорит, что обозначение уже занято. Оно
# говорит лишь, что ничего не сохранено — иначе можно было бы подумать, что
# книжка создана.
# Восемь предосторожностей из его «Precauttion enregistrement cheque.txt»,
# слово в слово и в его порядке. Первые семь — это `Erreur()`, восьмая —
# `Info()`, и порядок решает, что видно, когда две вещи идут не так
# одновременно.
chequebook-refusal-duplicate = Обозначение с таким же названием уже существует
chequebook-refusal-reference-required = Ввод обозначения обязателен
chequebook-refusal-number-too-big = Номера первого и/или последнего чека слишком большие (максимальное значение 999 999 999)
chequebook-refusal-date = Введите правильную дату получения
chequebook-refusal-numbers-required = Заполните номера первого и последнего чека
chequebook-refusal-order = Номер первого чека должен быть меньше номера последнего чека
chequebook-refusal-account = Обязательно выберите счёт, связанный с этой чековой книжкой
chequebook-refusal-too-many = Максимальное количество чеков для одной чековой книжки: 1000, ограничение достигнуто
# Его запрос подтверждения, задаваемый только при добавлении: он
# перечисляет то, что будет создано, и предупреждает, что после этого
# ничего изменить нельзя.
chequebook-creation-question =
    Создание чековой книжки со следующими характеристиками:
    - Количество создаваемых чеков:{ $count }
    - Чеки с номерами от { $first } до { $last }
    Внимание, эти данные нельзя будет изменить после создания!

# Карточка чековой книжки (F31). Первые пять полей становятся неактивными,
# как только книжка существует: её чеки уже созданы.
chequebook-field-id = Идентификатор чековой книжки
chequebook-field-reference = Обозначение
chequebook-field-received = Изготовлена или получена
chequebook-field-first = Номер первого чека
chequebook-field-last = Номер последнего чека
chequebook-field-quantity = Количество чеков
chequebook-field-account = Связать с банковским счётом:
chequebook-field-comments = Комментарии
chequebook-locked = Чеки этой книжки уже созданы: её нумерация больше не изменяется.
# Его фраза, слово в слово (`Enreg_Lire`).
chequebook-account-missing = Банковский счёт, с которым была связана эта чековая книжка, отсутствует или был удалён!

# Состав чековой книжки (F14). Статус меняется прямо в ячейке.
cheques-column-number = Номер чека
cheques-column-date = Дата
cheques-column-place = Место
cheques-column-payee = Получатель
cheques-column-amount = Сумма
cheques-column-status = Статус
cheques-column-comments = Комментарии
cheques-column-operations = Кол-во связ. операций
cheques-none = Эта чековая книжка не содержит ни одного чека.
cheques-nothing-to-show = Ни один чек не соответствует этому запросу.
cheques-help = Нажмите на ячейку Статус, чтобы изменить его; лупа показывает связанные операции, звено связывает операцию.
cheques-title-linked = Посмотреть операции, уже связанные с этим чеком
cheques-title-link = Связать операцию с этим чеком
cheques-status-changed = Статус чека изменён.

# Карточка чека (F12).
cheque-field-id = Идентификатор чека
cheque-field-number = Номер чека
cheque-field-issued = Дата выписки
cheque-field-place = Место выписки
cheque-field-payee = Получатель
cheque-field-amount = Сумма
cheque-field-comments = Комментарии
cheque-field-status = Статус чека
cheque-gone = Этого чека больше не существует.
cheque-updated = Чек изменён.

# Два облика окна связывания.
cheque-operations-linked-title = Список операций, уже связанных с этим чеком.
cheque-operations-choose-title = Выберите операцию для связывания с чеком
cheque-operations-column-account = Счёт
cheque-operations-column-label = Название
cheque-operations-column-date = Дата
cheque-operations-column-clearing = Дата сверки
cheque-operations-column-amount = Сумма
cheque-operations-column-cheque = Связанный чек
cheque-operations-none-linked = С этим чеком не связана ни одна операция.
cheque-operations-none = Этот счёт не содержит ни одной операции.
cheque-operations-nothing-to-show = Ни одна операция не соответствует этому запросу.
cheque-operations-help = Операции, выделенные жирным, уже связаны с чеком.
cheque-operations-linked-help = Красный крестик отвязывает чек от операции: ничего не удаляется.
cheque-operations-linked = Операция связана с чеком.
cheque-operations-dissociated = Чек отвязан от операции.
cheque-operations-menu-filter = Фильтр
cheque-title-associate = Связать эту операцию с чеком
cheque-title-dissociate = Отвязать чек от этой операции

# Полоса «Чек, связанный с операцией» в карточке операции и два шага поиска
# чека — сначала книжка, потом чек.
chequebooks-select-question = Выберите чековую книжку
cheques-select-question = Выберите чек для связывания с операцией
operation-check-save-first = Сначала сохраните операцию: чек связывается с уже существующей операцией.
operation-check-none = С этой операцией не связан ни один чек.

# --- F36 / F37 — Шаблоны операций (этап 10) -----------------------------
# Шаблон — это готовый ввод: его применяют, чтобы не набирать заново, и он
# **перезаписывает** то, что есть в карточке. На диск ничего не попадает,
# пока карточка операции не подтверждена (правило Fabrice, 29/07/2026).

window-operation-templates-title = Список шаблонов операций
window-operation-template-title = Карточка шаблона операции

operation-templates-none = Ни одного шаблона операции не зарегистрировано.
operation-templates-nothing-to-show = Ни один шаблон не соответствует этому запросу.
operation-templates-select-question = Выберите шаблон для применения
operation-templates-delete-question = Вы подтверждаете удаление выбранных шаблонов?
operation-templates-deleted = { $count ->
    [one] Удалён { $count } шаблон.
    [few] Удалено { $count } шаблона.
    [many] Удалено { $count } шаблонов.
   *[other] Удалено { $count } шаблона.
}
operation-template-gone = Этого шаблона больше не существует.
operation-template-fresh = Новый шаблон.
operation-template-created = Шаблон сохранён.
operation-template-updated = Шаблон изменён.
operation-template-label-required = Ввод названия обязателен
operation-template-duplicate = Шаблон с таким же названием уже существует

# Карточка F36, раздел за разделом — его точные заголовки.
operation-template-field-id = ID шаблона операции
operation-template-group-name = Название по умолчанию будущей операции после применения шаблона
operation-template-field-label = Название
operation-template-group-amount = Сумма операции по умолчанию, заданная в этом шаблоне
operation-template-field-direction = Тип операции
operation-template-field-amount = Сумма
operation-template-group-status = Статус операции по умолчанию в этом шаблоне
operation-template-field-status = Статус операции
operation-template-group-classification = Данные шаблона для классификации и расчёта статистики
operation-template-field-category = Категория
operation-template-field-assignment = Назначение
operation-template-field-mode = Способ
operation-template-field-payee = Контрагент
operation-template-field-project = Проект

# Кнопка «Шаблон» в карточке операции: одна иконка, два действия.
operation-template-question = Что вы хотите сделать с шаблонами операций?
operation-template-apply = Применить шаблон
operation-template-save-as = Сохранить как шаблон
operation-template-applied = Шаблон применён. Подтвердите карточку, чтобы сохранить её.
operation-template-saved-as = Операция сохранена как шаблон.
operation-template-needs-label = Дайте операции название, прежде чем делать из неё шаблон.

# --- F26 / F27 — Бюджет (этап 11) ---------------------------------------
# Две двери, два вопроса: либо вводят свой бюджет, либо проверяют, был ли он
# соблюдён. Ось — статья бюджета, единица — год, а соглашение о знаке — то
# же, что у операций: расход пишется отрицательным.

window-budget-entry-title = Ввод бюджета: планируемые расходы(-) и доходы(+) за год
window-budget-control-title = Контроль бюджета

budget-column-line = Статья бюджета
budget-none = Ни одной статьи бюджета не зарегистрировано: бюджет вводится по статьям.
budget-planned = План
budget-actual = Факт
budget-sum = Сумма
budget-cumulative = Накопительно
budget-total = Итого
# Напоминание о соглашении о знаке, красным под таблицей ввода.
# Его фраза, слово в слово и вместе с пробелами (снимок «POINT 004 saisie
# budget.png»): она выведена красным под таблицей, а заголовок окна
# повторяет её сокращённо. Без неё соглашение никто бы не угадал.
budget-sign-warning = Обязательно вводите расходы  с отрицательным знаком, а планируемые доходы — с положительными суммами
budget-entry-help = Введите суммы в ячейки, затем сохраните.
budget-saved = Бюджет сохранён.
budget-nothing-changed = Нет изменений для сохранения.
budget-discard-question = Отменить изменения бюджета?

# Меню «Вид» в контроле: два способа прочитать одно и то же отклонение.
budget-menu-display = Вид
budget-display-money = Значения
budget-display-percent = Проценты
budget-control-help = Зелёный: не хуже, чем планировалось. Красный: хуже.

# --- F09 — Перевод суммы между двумя счетами (этап 12) ------------------
# Перевод — это не одна операция, а две: расход по счёту-источнику и приход
# по счёту назначения. Они уходят вместе или не уходят вовсе.

window-transfer-title = Перевести сумму между двумя счетами

transfer-group-source = Списать сумму с этого счёта-источника
transfer-group-target = Зачислить сумму на этот счёт назначения
transfer-group-description = Описание операции
transfer-group-nomenclature = Данные справочника
transfer-group-amount = Сумма перевода
transfer-field-source = Счёт-источник
transfer-field-target = Счёт назначения
transfer-field-label = Описание
transfer-field-reference = Референс платежа
transfer-field-date = Дата
transfer-field-status = Статус операции
transfer-field-clearing = Дата сверки
transfer-field-category = Категория
transfer-field-mode = Способ оплаты
transfer-field-assignment = Назначение
transfer-field-payee = Контрагент / продавец
transfer-field-project = Проект
transfer-field-amount = Сумма

# Единственная кнопка панелей, которые сообщают, а не спрашивают.
ui-ok = OK
transfer-help = Выберите два счёта: их балансы отобразятся здесь.
transfer-title-validate = Выполнить перевод
# Три баланса выбранного счёта, чтобы понимать, к чему приведёт перевод.
transfer-balances = { $account } — В банке: { $bank } · Реальный: { $real } · Итоговый: { $final }
# Панель, которая подводит итог тому, что было только что записано.
transfer-done = Перевод выполнен. { $amount } со счёта { $source } на счёт { $target }, { $date }.

transfer-refusal-accounts-required = Выберите счёт-источник и счёт-получатель
transfer-refusal-same-account = Счёт-источник и счёт-получатель не могут быть одним и тем же: перевод идёт с одного счёта на другой
transfer-refusal-account-gone = Одного из двух счетов больше не существует
transfer-refusal-label-required = Описание обязательно
transfer-refusal-date-required = Дата обязательна
transfer-refusal-amount = Сумма перевода должна быть строго положительной

# ---------------------------------------------------------------------------
# Фаза 13 — импорт листа Excel (F34, F35, сопоставление).
# ---------------------------------------------------------------------------

window-excel-import-title = Импорт листа excel [ Шаг 1/3 ]: определение области захвата
window-excel-fields-title = Импорт листа excel [ Шаг 2/3 ]: сопоставление полей
window-excel-association-title = Импорт листа excel: сопоставление данных

# Вопрос, задаваемый при открытии. Файл Excel сделан вручную:
# в нём то, что в нём есть, и часть той чепухи, которую он несёт,
# обнаружить невозможно. Поэтому мы предлагаем страховку перед прыжком.
excel-backup-question = Лист Excel делается вручную: в нём могут быть даты правильного вида, но неверные, суммы правильного формата, но с неверным знаком — и этого не увидит никакая проверка. Импорт запишет эти строки на ваш счёт. Хотите сохранить резервную копию данных перед началом?
excel-backup-later = Резервное копирование ещё не подключено в этой версии Radinus 2. А пока закройте Radinus и скопируйте файл базы данных сами: тогда вы сможете импортировать, ничем не рискуя.

excel-group-file = 1 - Указать файл Excel для импорта
excel-pick = Указать файл Excel
excel-sheet = Лист книги:
excel-group-header = 2 - Определить: координаты ячеек строки заголовка таблицы, где написаны названия столбцов.
excel-header-row = Номер первой строки, где находятся названия столбцов
excel-first-column = Столбец начала заголовка ( самый левый столбец ):
excel-column-count = Количество столбцов таблицы
excel-group-rows = 3 - Определить: номера первой и последней строк списка с данными таблицы ( под заголовком и не включая его )
excel-first-data-row = Первая строка, содержащая данные
excel-last-data-row = Последняя строка, содержащая данные:
excel-group-shape = 4 - Определить: как ваш файл записывает суммы
excel-shape-single = Один столбец сумм со знаком ( расходы отрицательные )
excel-shape-debit-credit = Два отдельных столбца: столбец Расход и столбец Приход
excel-shape-note = В режиме с двумя столбцами знак, записанный в столбце Расход, не учитывается: расход всегда уносит деньги, записан ли он как «-50» или «50».
excel-group-test = 5 - Тестовый вывод: посмотрите на захват, выполненный согласно вашим настройкам
excel-test = Проверьте параметры, заданные вами на шагах 2, 3 и 4.
excel-test-note = Указание: названия заголовков и содержимое таблицы ниже должны соответствовать вашей таблице Excel. Область захвата не должна выходить за пределы таблицы.

excel-help = Пройдите пять групп по порядку, затем протестируйте: перейти к шагу 2 можно только после того, как вы посмотрите, что захватывает область.
excel-no-file = Сначала укажите файл Excel для импорта.
excel-not-tested = Настройки изменены: перед подтверждением запустите тестовый вывод заново.
excel-tested = Захвачена область: { $rows } строк, { $columns } столбцов. Проверьте, что таблица ниже похожа на ваш лист.
excel-empty-capture = Объявленная вами область не захватывает ни одной строки: проверьте номера строк и столбцов.
excel-title-next = Перейти к следующему шагу
excel-into-account = Импорт на счёт { $account }.

excel-tab-links = Связи между полями
excel-tab-settings = Параметры импорта
excel-column-excel = Заголовок_Excel
excel-column-radinus = Рубрика_Radinus
excel-links-help = Напротив каждого столбца вашего листа укажите, какую рубрику Radinus он заполняет. Столбцы, оставленные как [IGNORE], не импортируются.
excel-group-category = Категории без соответствий
excel-group-payment-mode = Способ оплаты без соответствий
excel-group-assignment = Назначение без соответствий
excel-policy-create = { $kind ->
    [payment-mode] Автоматически создавать несуществующие способы оплаты
    [assignment] Автоматически создавать несуществующие назначения
   *[category] Автоматически создавать несуществующие категории
}
excel-policy-ask = { $kind ->
    [payment-mode] Спрашивать для каждого несуществующего способа оплаты, куда переносить данные
    [assignment] Спрашивать для каждого несуществующего назначения, куда переносить данные
   *[category] Спрашивать для каждой несуществующей категории, куда переносить данные
}
excel-policy-blank = { $kind ->
    [payment-mode] Оставить способ оплаты пустым
    [assignment] Оставить назначение пустым
   *[category] Оставить категорию пустой
}
excel-policy-default = { $kind ->
    [payment-mode] Переносить несуществующие способы оплаты в способ оплаты по умолчанию
    [assignment] Переносить несуществующие назначения в назначение по умолчанию
   *[category] Переносить несуществующие категории в категорию по умолчанию
}
excel-define-destination = Задать цель
excel-not-linked = { $kind ->
    [payment-mode] Ни один столбец не заполняет способ оплаты: эта настройка не применяется.
    [assignment] Ни один столбец не заполняет назначение: эта настройка не применяется.
   *[category] Ни один столбец не заполняет категорию: эта настройка не применяется.
}
excel-fields-help = Настройте соответствия, затем три правила, прежде чем запускать импорт.
excel-title-import = Запустить импорт

excel-refusal-required = Рубрики Дата, Описание и Сумма обязательно должны указывать на столбцы excel
excel-refusal-column-twice = Разные рубрики Radinus указывают на один и тот же столбец excel: столбец может заполнять только одну рубрику
excel-refusal-field-twice = Одна и та же рубрика Radinus связана с двумя столбцами excel: у неё может быть только один
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Вы выбрали спрашивать, куда переносить неизвестные способы оплаты: нажмите «Задать цель» перед запуском импорта.
    [assignment] Вы выбрали спрашивать, куда переносить неизвестные назначения: нажмите «Задать цель» перед запуском импорта.
   *[category] Вы выбрали спрашивать, куда переносить неизвестные категории: нажмите «Задать цель» перед запуском импорта.
}

excel-column-data = Данные_Excel
excel-column-destination = { $kind ->
    [payment-mode] СпособОплаты_Radinus
    [assignment] Назначение_Radinus
   *[category] Категория_Radinus
}
excel-association-help = Напротив каждого значения из вашего листа выберите то значение Radinus, в которое оно должно быть отнесено. Строка, оставленная пустой, останется без классификации.
excel-association-none = Неизвестных значений нет: всё, что содержит ваш лист, уже существует в Radinus.

excel-imported = Импорт завершён: { $count } операций записано, { $refused } строк отклонено, { $created } значений справочника создано.
excel-report-title = Отчёт об импорте
excel-column-row = Строка Excel
excel-column-content = Содержимое
excel-column-reason = Причина отказа
excel-nothing-refused = Все строки вашего листа приняты: отказов нет.

excel-refused-date = Дата отсутствует или нечитаема
excel-refused-amount = Сумма отсутствует или нечитаема
excel-refused-amount-both = Одна сумма в столбце Расход и другая в столбце Приход: выбрать невозможно
excel-refused-amount-missing = В этой строке нет ни расхода, ни прихода

# ---------------------------------------------------------------------------
# Фаза 16 — периодические операции (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Список периодических операций
window-recurring-form-title = Карточка, определяющая правило создания периодической операции
window-recurring-calendar-title = Предлагаемый календарь операций для вставки в ваши банковские счета

recurring-column-label = ОПИСАНИЕ
recurring-none = Периодические правила не записаны.
recurring-help = Выберите правило, затем календарь, чтобы увидеть предлагаемые им сроки.
recurring-title-calendar = Предложить календарь сроков
recurring-deleted = { $count ->
    [0] Ни одно правило не удалено.
    [one] Удалено одно правило. Его операции остаются на счёте.
    [few] Удалено { $count } правила. Их операции остаются на счетах.
    [many] Удалено { $count } правил. Их операции остаются на счетах.
   *[other] Удалено { $count } правила. Их операции остаются на счетах.
}
recurring-gone = Этого правила больше не существует.
recurring-delete-question = Удалить выбранные правила? Операции, которые они уже вставили, останутся на ваших счетах.

recurring-group-identity = Идентификация и соответствующий банковский счёт
recurring-group-nomenclature = Справочник
recurring-group-amount = Определение суммы операции
recurring-group-period = Определение периода
recurring-group-ending = Условия окончания периода
recurring-group-produced = Сведения об уже вставленных операциях ( только для просмотра )

recurring-field-id = Идентификатор операции
recurring-field-account = Целевой счёт
recurring-field-label = Описание
recurring-field-category = Категория
recurring-field-mode = Способ оплаты
recurring-field-assignment = Назначение
recurring-field-payee = Контрагент / продавец
recurring-field-project = Проект
recurring-field-direction = Тип операции
recurring-field-amount = Сумма
recurring-field-next = Дата следующей операции
recurring-field-every = Затем каждые
recurring-field-end-date = Дата окончания
recurring-field-repeat = Число повторений
recurring-field-guid = GUID операции
recurring-field-produced-count = Число вставленных операций
recurring-field-produced-last = Дата последней вставленной операции
recurring-field-produced-total = Итого созданных сумм

recurring-unit-day = День
recurring-unit-week = Неделя
recurring-unit-month = Месяц
recurring-unit-quarter = Квартал
recurring-unit-year = Год
recurring-ending-no-limit = Без ограничения
recurring-ending-until-date = С датой окончания
recurring-ending-repeat-count = Число повторений

recurring-title-erase = Удалить операции, уже вставленные этим правилом
recurring-erase-question = { $count ->
    [one] Это правило вставило { $count } операцию на ваши счета. Хотите её удалить? Балансы будут пересчитаны, а правило не откатится назад.
    [few] Это правило вставило { $count } операции на ваши счета. Хотите удалить их все? Балансы будут пересчитаны, а правило не откатится назад.
    [many] Это правило вставило { $count } операций на ваши счета. Хотите удалить их все? Балансы будут пересчитаны, а правило не откатится назад.
   *[other] Это правило вставило { $count } операции на ваши счета. Хотите удалить их все? Балансы будут пересчитаны, а правило не откатится назад.
}
recurring-erase-none = Это правило ещё не вставило ни одной операции.
recurring-erased = { $count ->
    [0] Ни одна операция не удалена.
    [one] Удалена { $count } операция, балансы пересчитаны.
    [few] Удалено { $count } операции, балансы пересчитаны.
    [many] Удалено { $count } операций, балансы пересчитаны.
   *[other] Удалено { $count } операции, балансы пересчитаны.
}

recurring-calendar-help = Уберите в корзину сроки, которые вам не нужны, затем подтвердите, чтобы вставить остальные.
recurring-calendar-none = Нет сроков для предложения: проверьте дату следующей операции и счёт в ваших правилах.
recurring-calendar-column-account = Счёт
recurring-calendar-column-date = Дата
recurring-calendar-column-label = Описание
recurring-calendar-column-amount = Сумма
recurring-calendar-column-category = Категория
recurring-calendar-column-assignment = Назначение
recurring-calendar-column-mode = Способ оплаты
recurring-calendar-column-payee = Контрагент
recurring-calendar-column-project = Проекты
recurring-calendar-removed = { $count ->
    [one] Из предложения убран { $count } срок.
    [few] Из предложения убрано { $count } срока.
    [many] Из предложения убрано { $count } сроков.
   *[other] Из предложения убрано { $count } срока.
}
recurring-title-insert = Вставить выбранные сроки в счета
recurring-nothing = Не осталось ни одного срока для вставки.
# Вопрос, задаваемый перед записью: вставка календаря создаёт настоящие
# операции на настоящих счетах, и это не делается рассеянным щелчком.
recurring-insert-question = { $count ->
    [one] Вставить { $count } срок на ваш счёт? Будет создана операция и пересчитаны балансы.
    [few] Вставить эти { $count } срока на ваши счета? Будет создано столько же операций и пересчитаны балансы.
    [many] Вставить эти { $count } сроков на ваши счета? Будет создано столько же операций и пересчитаны балансы.
   *[other] Вставить эти { $count } срока на ваши счета? Будет создано столько же операций и пересчитаны балансы.
}
recurring-inserted = { $count ->
    [one] Вставлена { $count } операция. Правило продолжится после последнего вставленного срока.
    [few] Вставлено { $count } операции. Правила продолжатся после своего последнего вставленного срока.
    [many] Вставлено { $count } операций. Правила продолжатся после своего последнего вставленного срока.
   *[other] Вставлено { $count } операции. Правила продолжатся после своего последнего вставленного срока.
}

recurring-refusal-label-required = Ввод описания обязателен
recurring-refusal-date-required = Ввод даты следующей операции обязателен
recurring-refusal-date-too-old = Дата следующей операции должна быть не раньше 2000 года
recurring-refusal-account-gone = Указанный банковский счёт не найден, выберите новый, чтобы правило снова стало применимым
recurring-refusal-end-required = Если задана дата окончания, эту дату необходимо ввести
recurring-refusal-end-before-start = Дата окончания не может быть раньше даты следующей операции
recurring-refusal-end-too-far = Разрыв между датой следующей операции и датой окончания не может превышать 10 000 дней

# --- Фаза 15 — печать и отчёты -----------------------------------------
# Крупный заголовок шапки, дословно взятый из исходного отчёта WinDev.
print-operations-title = Список банковских транзакций и подопераций
print-menu-operations-pdf = Печать в файл PDF
print-recap-title = Сводка по категориям
print-recap-count = Строки
print-row-count = Количество строк:
print-total-debit = Итого расход:
print-total-credit = Итого приход:
print-final-balance = Итоговый баланс:
print-licence = Radinus — свободная программа, распространяемая по лицензии GNU GPL v3 или новее
print-nothing = Печатать нечего.
print-done = Отчёт напечатан и открыт: «{ $file }».
print-failed = Печать невозможна: { $reason }
# PDF записан как надо, но система не смогла его открыть: говорим об этом, не
# создавая впечатления неудачи, ведь файл на месте.
print-not-opened = Отчёт напечатан в «{ $file }», но ваша система не смогла открыть его сама.

# --- Отчёт RIB (F32) ---------------------------------------------------
# Заголовки банковских реквизитов, взятые из исходного документа.
rib-title = БАНКОВСКИЕ РЕКВИЗИТЫ
rib-bank = Банк:
rib-national = RIB - Национальный идентификатор счёта
rib-establishment = УЧРЕЖДЕНИЕ
rib-branch = ОТДЕЛЕНИЕ
rib-number = НОМЕР СЧЁТА
rib-key = КЛЮЧ RIB
rib-domiciliation = МЕСТО ВЕДЕНИЯ СЧЁТА
rib-iban = IBAN - Международный идентификатор счёта
rib-bic = BIC - Международный идентификатор учреждения
rib-holder = Владелец счёта

# --- Окно F32 ----------------------------------------------------------
window-rib-title = Печать RIB ( банковские реквизиты )
rib-group-bank = Банк
rib-group-holder = Владелец счёта
rib-group-details = Банковские реквизиты
rib-field-bank = Название банка
rib-field-domiciliation = Место ведения счёта
rib-field-holder = Имя владельца
rib-field-address = Адрес
rib-field-establishment = Учреждение
rib-field-branch = Отделение
rib-field-number = Номер счёта
rib-field-key = Ключ RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Важные условия использования, обязательные к соблюдению при печати
rib-declaration = Я, нижеподписавшийся пользователь программы, заявляю под свою честь:
rib-declaration-first = - Подтверждаю, что проверил в своём банке, что банковские сведения, содержащиеся в этом окне, верны и соответствуют моей воле . Подтверждаю точно так же, что обязуюсь проверить, что сведения, содержащиеся в печатном отчёте RIB, верны и соответствуют моей воле. Эта печать и использование RIB будут производиться под мою полную ответственность
rib-declaration-second = - Являюсь владельцем счёта, RIB которого будет напечатан, и не использую функции этой программы в целях, противоречащих закону.
rib-title-print = Печать на принтере
rib-title-pdf = Печать в файл PDF
# Этот флажок — не декоративное предупреждение: пока он не отмечен, обе
# кнопки выключены (решение Fabrice, 01/08/2026).
rib-declaration-required = Отметьте заявление под честное слово, чтобы можно было печатать.
rib-help = Проверьте свои реквизиты, отметьте заявление, затем печатайте.
rib-account-gone = Этот банковский счёт не найден.
rib-fields-read-only = Эти реквизиты берутся из карточки счёта: чтобы изменить их здесь, исправьте их в карточке.
rib-printed = RIB отправлен на ваш принтер по умолчанию.
rib-print-failed = Печать невозможна: { $reason }
rib-pdf-done = RIB напечатан и открыт: «{ $file }».
rib-pdf-not-opened = RIB напечатан в «{ $file }», но ваша система не смогла открыть его сама.
menu-accounts-bank-details = Напечатать банковские реквизиты

# Выбор принтера. Radinus задаёт вопрос сам: ни один из трёх webview не
# открывает системный диалог печати.
print-choose-printer = На каком принтере вы хотите напечатать?
print-do-print = Напечатать
rib-printed-on = RIB отправлен на принтер «{ $printer }».
ui-cancel = Отменить

# Система не смогла назвать ни одного принтера: всё равно печатаем на принтере
# по умолчанию, а не блокируем пользователя.
print-printers-unknown = Ваша система не смогла назвать ни одного принтера: документ отправлен на принтер по умолчанию.

print-menu-operations-printer = Печать на принтере
print-sent-on = Отчёт отправлен на принтер «{ $printer }».
print-sent-default = Отчёт отправлен на ваш принтер по умолчанию.

# --- Фаза 17 — операции с базой данных ----------------------------------
backup-archive = Архив Radinus
backup-no-database = Ни одна база данных не открыта.
backup-done = Резервная копия записана в «{ $file }».
backup-failed = Резервное копирование невозможно: { $reason }
restore-unreadable = Этот файл не является читаемым архивом Radinus: { $reason }
# Вопрос говорит, что будет потеряно, прежде чем это потеряется. Архив к этому
# моменту уже прочитан: то, о чём он сообщает, достоверно.
restore-question = Восстановить «{ $file }»? Всё текущее содержимое вашей базы будет стёрто и заменено, и то, что в ней находится, будет потеряно.
restore-done = Восстановление завершено: { $accounts } счетов и { $operations } операций.
restore-failed = Восстановление невозможно: { $reason }


# --- Журнал технических операций (фаза 17) ------------------------------
# Три статуса его Ajoute_Log, заглавными буквами, как у него.
journal-status-success = УСПЕХ
journal-status-failure = ОШИБКА
journal-status-repaired = ИСПРАВЛЕНО
journal-step-reindex = Восстановление целостности таблицы БД
journal-step-refill = Системный справочник пуст: значения по умолчанию восстановлены
journal-step-table-created = Таблица отсутствует в базе: создана заново пустой
journal-step-column-added = Столбец отсутствует в таблице: добавлен со значением по умолчанию

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Защита паролем
window-password-form-title = Защита паролем
password-ask = Эта база защищена. Введите её пароль.
password-group-database = Затрагиваемая база
password-group-password = Пароль
password-group-warning = Прежде чем подтвердить
password-field-old = Старый пароль
password-field-new = Новый пароль
password-field-repeat = Повторите новый пароль
password-hint = Оставьте старый пустым, если база ещё не защищена. Оставьте оба новых пустыми, чтобы снять защиту.
password-lost-warning = Потерянный пароль — потерянная база: восстановить её невозможно. Резервные копии, напротив, остаются незашифрованными.
password-show = Показать пароль
password-remove-question = Снять защиту с этой базы?
password-mismatch = Два ввода нового пароля различаются
password-wrong = Пароль не подходит
password-close-first = Закройте эту базу, прежде чем менять её пароль
password-now-protected = База защищена паролем
password-now-clear = База больше не защищена
journal-step-date-fixed = Исправление операции без даты
journal-step-circular = Удаление противоречивой операции: циклическая ссылка
journal-step-flag-parent-true = Неверный флаг EstParent=Faux у основной операции
journal-step-flag-parent-false = Неверный флаг EstParent=Vrai у основной операции
journal-step-flag-child = Неверный флаг EstParent=Vrai у подоперации
journal-step-orphan = Удаление осиротевшей подоперации
journal-step-third-level = Удаление подоперации, привязанной к другой подоперации
journal-step-coherence = Общий пересчёт согласованности между подоперациями и основными операциями
journal-step-balances = Пересчёт всех балансов всех счетов
journal-step-vacuum = Оптимизация файла базы данных
journal-step-analyze = Обновление статистики поиска
journal-step-backup-begin = Начало резервного копирования базы
journal-step-backup-end = Конец резервного копирования базы
journal-step-restore-begin = Начало восстановления базы из архива
journal-step-restore-end = Конец восстановления базы из архива
journal-step-restore-read = Чтение архива

# --- Окно журнала (⌘H) ---------------------------------------------------
window-journal-title = Журнал последней технической операции
journal-column-step = Этап
journal-column-file = Файл
journal-column-table = Таблица
journal-column-status = Статус
journal-column-error = Ошибка
journal-column-comments = Комментарии
journal-empty = С момента запуска программы не было выполнено ни одной технической операции.
journal-help = Журнал хранит только последнюю техническую операцию: резервное копирование, восстановление, восстановление целостности, стирание или открытие базы.

# --- Восстановление целостности -----------------------------------------
menu-file-repair-running = Идёт восстановление целостности и оптимизация…
repair-done = { $anomalies ->
    [0] Восстановление целостности завершено: аномалий не найдено. В журнал записано этапов: { $lines }.
    [one] Восстановление целостности завершено: исправлена { $anomalies } аномалия. В журнал записано этапов: { $lines }.
    [few] Восстановление целостности завершено: исправлено { $anomalies } аномалии. В журнал записано этапов: { $lines }.
    [many] Восстановление целостности завершено: исправлено { $anomalies } аномалий. В журнал записано этапов: { $lines }.
   *[other] Восстановление целостности завершено: исправлено { $anomalies } аномалии. В журнал записано этапов: { $lines }.
}
repair-failed = Восстановление целостности невозможно: { $reason }

journal-status-started = ВЫПОЛНЯЕТСЯ
journal-status-finished = ЗАВЕРШЕНО
journal-step-backup-table = Запись таблицы в архив
journal-step-backup-write = Запись архива
journal-step-backup-verified = Проверка записанного архива: файлов перечитано / ожидалось, записей перечитано / записано
journal-step-backup-total = Всего сохранено: записей, данных, размер файла
journal-step-restore-table = Чтение таблицы из архива
journal-step-restore-missing = Файл отсутствует в архиве: эта таблица не будет восстановлена
journal-step-restore-wipe = Полное стирание содержимого базы перед восстановлением
journal-step-restore-write = Запись в базу
journal-step-restore-total = Всего восстановлено: счетов, операций
backup-verify-mismatch = Записанный архив читается не таким, каким он был записан: не полагайтесь на него, сделайте резервную копию заново.

# --- Вложения операции (F28, фаза 17) -----------------------------------
window-attachments-title = Вложения операции
attachment-filter = Допустимые документы
attachment-none = У этой операции нет ни одного вложения.
attachment-title-add = Приложить документ к этой операции
attachment-title-open = Открыть вложение
attachment-title-remove = Удалить вложение и отправить его файл в корзину
# Состояние файла на диске. «Не проверяется» — не праздное признание в
# незнании: контрольные суммы, пришедшие из Radinus 1.9.3, урезаны форматом
# сохранения, и судить по ним о файле значило бы обвинять наугад.
attachment-state-ok = Не изменено
attachment-state-changed = Изменено
attachment-state-missing = Файл отсутствует
attachment-state-unknown = Не проверяется
attachment-added = «{ $name }» приложено к операции.
attachment-removed = Вложение удалено, его файл в корзине.
attachment-removed-kept = Вложение удалено, но его файл не удалось поместить в корзину.
attachment-remove-question = Удалить «{ $name }» из этой операции? Его файл будет отправлен в корзину.
attachment-opened = «{ $name }» открыто.
attachment-opened-changed = «{ $name }» открыто, но его содержимое изменилось с тех пор, как оно было приложено.
attachment-gone = Этого вложения больше не существует.
attachment-file-missing = Файл «{ $name }» не найден на диске.
attachment-failed = Операция невозможна: { $reason }
attachment-save-first = Сначала сохраните операцию: вложение прикрепляется к операции, которая существует.
attachment-refusal-missing = Этот файл не существует.
attachment-refusal-extension = Этот тип файла не принимается. Принимаются: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Операция, к которой нужно приложить этот документ, не существует.
journal-step-backup-attachments = Вложения добавлены в архив
journal-step-backup-attachment-missing = Вложение не найдено на диске: его не будет в архиве
journal-step-restore-attachments = Вложения извлечены из архива
attachment-title-replace = Заменить документ этого вложения
attachment-replaced = Документ заменён на «{ $name }».

# ---------------------------------------------------------------------
# F08 — меню «Инструменты» карточки счёта.
#
# Три его пункта — это переносы кода WLangage Fabrice (папка
# « Information import export base piece jointe »): расчёт начального
# сверенного баланса, статистика счёта и удаление всех его транзакций.
# Меню работает только в режиме изменения (решение от 02/08/2026): при
# создании считать нечего, в режиме просмотра карточка только показывает.
# ---------------------------------------------------------------------

account-tools = Инструменты
account-tools-initial-balance = Задать начальный сверенный баланс
account-tools-statistics = Статистика банковского счёта
account-tools-delete-operations = Удалить все транзакции счёта

# Вопрос расчёта, дословно как в оригинале. { $total } — итог сверенных
# операций, уже записанный в денежном формате.
account-initial-balance-question =
    Чтобы рассчитать начальный сверенный баланс с учётом операций, имеющихся на этом счёте, укажите текущий баланс в вашем банке
    Начальный сверенный баланс будет рассчитан как:
    { "[" }Текущий банковский баланс] - [Итог сверенных операций ({ $total }) ].
    { "" }
    Чтобы не вводить это значение заново, список банковских операций по этому счёту должен быть полностью актуальным.

account-statistics-none = Нет транзакций

# Четырнадцать строк его Info(). Опечатка «pengagés» из оригинала исправлена
# по решению Fabrice от 02/08/2026 — как и «Bank Identifer Code» на этой же
# карточке.
account-statistics =
    Общее количество транзакций на этом счёте: { $count }
    { "" }
    Количество сверенных транзакций на этом счёте: { $pointed }
    Сумма сверенных расходов: { $pointedDebits }
    Сумма сверенных приходов: { $pointedCredits }
    Разница между сверенными приходами и расходами: { $pointedDifference }
    { "" }
    Количество зарезервированных транзакций на этом счёте: { $committed }
    Сумма зарезервированных расходов: { $committedDebits }
    Сумма зарезервированных приходов: { $committedCredits }
    Разница между зарезервированными приходами и расходами: { $committedDifference }
    { "" }
    Количество запланированных транзакций на этом счёте: { $planned }
    Сумма запланированных расходов: { $plannedDebits }
    Сумма запланированных приходов: { $plannedCredits }
    Разница между запланированными приходами и расходами: { $plannedDifference }
    { "" }
    Самая старая транзакция: { $first }
    Самая новая транзакция: { $last }

# Двойной барьер при удалении. { $word } — это «да» на обиходном языке
# пользователя: испаноговорящий, которого попросили бы написать OUI, не
# понял бы (решение Fabrice, 02/08/2026).
account-delete-operations-question =
    Вы уверены, что хотите удалить все операции, содержащиеся в банковском счёте?
    Для подтверждения напишите { $word } в поле ниже и подтвердите

account-delete-operations-done =
    { $count ->
        [0] Ни одна транзакция не удалена.
        [one] Удалена { $count } транзакция.
        [few] Удалено { $count } транзакции.
        [many] Удалено { $count } транзакций.
       *[other] Удалено { $count } транзакции.
    }

# ---------------------------------------------------------------------
# Селектор базы и выбор языка (02/08/2026)
#
# Решения, принятые в обсуждении с Fabrice: Radinus больше не создаёт
# базу без разрешения; без языка в конфигурации он спрашивает язык
# прежде всего остального; базой является любая папка из databases/,
# которая содержит radinus.sqlite, каким бы ни было её имя.
#
# У окна выбора языка здесь нет ни одного ключа: оно не употребляет
# ни одной фразы, и именно это позволяет ему быть понятым прежде, чем
# станет известно, на каком языке говорит пользователь.
# ---------------------------------------------------------------------

window-database-selector-title = Базы данных
window-database-form-title = Новая база данных
database-group-identity = Идентификация базы данных
database-group-restore = Инициализировать базу данными из резервной копии
database-choose-backup = Выбрать файл резервной копии
database-no-backup = Резервная копия не выбрана: база будет создана пустой.

databases-column-label = База
databases-column-comment = Комментарий
databases-column-folder = Папка
databases-column-created = Создана

databases-none = Пока нет ни одной базы: создайте её.
databases-help = Выберите базу для открытия или создайте новую.
databases-select = Сначала выберите базу в списке.
databases-tools = Инструменты
databases-title-open = Открыть эту базу

database-created = База «{ $label }» создана.
database-field-label = Название базы
database-field-comment = Комментарий
database-label-required = Дайте этой базе название: именно оно отличит её от других.
database-gone = Этой базы больше нет: она была перемещена или удалена после открытия этого окна.

# Удаление базы (02/08/2026). Папка отправляется в системную корзину, как и
# вложения: базу, удалённую по ошибке, можно вернуть правым щелчком мыши.
# Открытая база не удаляется — Radinus держит её файл.
databases-title-delete = Удалить эту базу
database-delete-question =
    Вы уверены, что хотите удалить базу «{ $label }»?
    { "" }
    Вся её папка отправится в корзину: операции, счета и вложения.
    Для подтверждения напишите { $word } в поле ниже и подтвердите.
database-in-use = Эта база открыта: Radinus не может её удалить. Сначала откройте другую.
database-deleted = База «{ $label }» в корзине.

# У селектора два режима (Fabrice, 02/08/2026). Открытый во время работы, он
# больше не умеет открывать: окно Radinus строится один раз и никогда не
# уничтожается, и ничто не заставит его забыть базу, которую оно показывает.
# Её смотрят, создают, удаляют — а чтобы сменить базу, из программы выходят.
database-quit-first = Чтобы открыть эту базу, выйдите из Radinus и запустите его снова: селектор предложит её вам при запуске.


# --- F01 — окно приветствия (фаза 17 bis, 03/08/2026) --------------------
#
# Первое добавление 2.0.0 поверх 1.9.3: окно приветствия несёт уже не только
# баннер. Правило, которое им управляет, записано в документе 04 F01: это вид
# БЕЗ ЕДИНОГО ЩЕЛЧКА, и ничто, требующее настройки, сюда не входит.
#
# Оба заголовка кольцевых диаграмм несут месяц целиком, вместо того чтобы окно
# склеивало их встык: у «Расходы ... — август 2026» не тот же порядок слов в
# трёх языках, и только Fluent знает, где находится подстановка.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Нет открытых счетов
    [one] { $count } открытый счёт
    [few] { $count } открытых счёта
    [many] { $count } открытых счетов
   *[other] { $count } открытых счёта
}
welcome-total-bank = Банковский баланс
welcome-total-real = Реальный баланс
welcome-total-final = Итоговый баланс
welcome-total-real-detail = сверено + зарезервировано
welcome-total-final-detail = сверено + зарезервировано + запланировано
welcome-accounts = Ваши счета
welcome-tile-bank = В банке
welcome-tile-real = Реальный
welcome-tile-final = Итоговый
welcome-spending = Расходы — { $month }
welcome-earning = Доходы — { $month }
ui-legend-budget-lines = Статьи бюджета
ui-legend-categories = Категории
welcome-nothing = В этом месяце нет ни одной операции.
welcome-open-account = Информация: щёлкните по счёту, чтобы открыть его операции.
welcome-no-account = Пока нет ни одного банковского счёта.
welcome-no-account-create = Создайте банковский счёт, нажав здесь
welcome-previous-month = Предыдущий месяц
welcome-next-month = Следующий месяц
welcome-refresh = Перечитать всё


# --- F39 — параметры (фаза 17 ter, 03/08/2026) ---------------------------
#
# Положение знака валюты живёт здесь, рядом с двумя разделителями: оно следует
# языку, а не валюте. «before» ставит знак перед числом, любое другое значение
# ставит его после. НИКАКОЙ знак валюты не записан в этом файле: «русский» не
# значит «рубль».

ui-money-sign-position = after
window-preferences-title = Параметры
menu-settings-preferences = Параметры…
menu-settings-show-main = Показать главное окно
preferences-branch-display = Отображение
preferences-leaf-language = Язык
preferences-leaf-currency = Валюта
preferences-field-language = Язык программы:
preferences-field-currency = Отображаемая валюта:
preferences-field-custom = Знак валюты:
preferences-currency-system = Системная валюта
preferences-currency-euro = Евро
preferences-currency-dollar = Доллары
preferences-currency-canadian = Канадские доллары
preferences-currency-cfa = Франки КФА
preferences-currency-cfp = Тихоокеанские франки
preferences-currency-swiss = Швейцарские франки
preferences-currency-none = Никакая
preferences-currency-custom = Своя
preferences-currency-system-is = Ваша система сообщает:
preferences-currency-system-silent = Ваша система не сообщает никакой валюты: суммы будут показаны в евро.
preferences-custom-required = Введите знак вашей валюты перед сохранением.
preferences-saved = Параметры сохранены.
preferences-help = Выберите пункт в дереве, затем сохраните.
preferences-sign-too-long = Знак валюты занимает не более 8 символов.
preferences-sign-not-a-number = Знак валюты не может содержать ни цифры, ни знака действия, ни запятой: Radinus убирает их, когда читает сумму, и «120» превратилось бы в «12».
preferences-leaf-zoom = Размер отображения
preferences-field-zoom = Увеличение:
preferences-zoom-reset = Значение по умолчанию
preferences-zoom-hint = Всё увеличивается вместе: текст, значки, столбцы. Ниже 100 % на экране помещается больше. А строка меню системы и её диалоговые окна следуют настройкам вашего компьютера, а не этим.

# --- Баннер окна приветствия ---------------------------------------------
#
# Эти фразы были жёстко записаны в `index.html` с фазы 0 и потому не
# переводились (замечено Fabrice 03/08/2026). Девиз — это его голос:
# английская и испанская версии являются предложениями, которые ему предстоит
# поправить — слоган не переводится слово в слово.
ui-language-tag = ru
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — белка-талисман в костюме, в окружении евро, калькулятора и графиков
welcome-slogan-one = Программа для управления личными финансами, которая помогает вам тратить меньше, чтобы зарабатывать больше
welcome-slogan-two = С Radinus вы поймёте, почему из маленьких ручейков рождаются большие реки.

# --- «Об авторе» ---------------------------------------------------------
#
# Имя и адрес записаны одинаково в трёх файлах: они не переводятся. Они всё же
# здесь, а не на странице, чтобы вид не нёс ни одной фразы — и чтобы их можно
# было поправить в одном-единственном месте в тот день, когда автор переедет.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Об авторе
about-author-flag-alt = Флаг Корсики — голова мавра

# --- «О Radinus» ---------------------------------------------------------
#
# `about-radinus-version` несёт подстановку: номер приходит от работающего
# двоичного файла, а никогда не от переписанной строки. Поэтому её нет в
# словаре окон — заполняет её команда `app_version`.
window-about-radinus-title = О Radinus
about-radinus-name = Radinus
about-radinus-version = Версия { $version }
about-radinus-rust-alt = Логотип языка Rust
about-radinus-tauri-alt = Логотип Tauri
about-radinus-built = Radinus написан на Rust и построен с помощью Tauri. Первый считает ваши счета, второй делает из этого настольное приложение.
about-radinus-licence = Свободное программное обеспечение, лицензия GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Лицензия
licence-heading = ЛИЦЕНЗИЯ НА ИСПОЛЬЗОВАНИЕ ПРОГРАММЫ RADINUS
licence-logo-alt = Логотип GNU General Public License версии 3
licence-name = GNU GPL v3 или новее
licence-intro = Radinus — свободная программа.
licence-freedoms-title = Её лицензия даёт вам четыре свободы:
licence-freedom-use = Использовать её как угодно и для чего угодно.
licence-freedom-study = Изучать её исходный код, открытый для всех.
licence-freedom-share = Копировать её и передавать другим.
licence-freedom-improve = Изменять её и делиться своими изменениями.
licence-read = Прочитать полный текст лицензии

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Эта программа предоставляется без каких-либо гарантий, в пределах, допускаемых законом.
licence-info = Официальный текст откроется в вашем браузере, на gnu.org.

