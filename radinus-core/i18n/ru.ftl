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
menu-statistics-balance-analysis = Анализ изменения баланса
menu-statistics-by-category = Статистика по категориям
menu-statistics-by-assignment = Статистика по назначениям
menu-statistics-by-budget-line = Статистика по статьям бюджета
menu-statistics-by-payment-mode = Статистика по способам оплаты
menu-statistics-by-payee = Статистика по контрагентам и продавцам
menu-statistics-by-project = Статистика по проектам
menu-statistics-by-verification = Статистика по проверке
menu-statistics-dashboard = Сводная панель операций
menu-statistics-crossed-balance = Перекрёстный баланс

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

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Инструменты
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
menu-misc-attachments-folder = Доступ к папке с вложениями
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Управление вложениями
window-attachments-manager-title = Управление вложениями
attachments-column-document = Документ
attachments-column-size = Размер
attachments-column-added = Добавлено
attachments-column-state = Состояние
attachments-state-intact = Не изменено
attachments-state-altered = Изменено с тех пор
attachments-state-missing = Файл отсутствует
attachments-state-unknown = Проверить нельзя
attachments-state-orphan = Осиротевший
attachments-no-operation = Нет операции
attachments-orphan-remove-question = Этот файл не связан ни с одной операцией. Отправить его в корзину?
attachments-manager-help = Дважды щёлкните строку, чтобы открыть документ.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Показать операцию
attachments-reveal = Показать в файловом менеджере
attachments-manager-summary = Вложений: { $count }, всего { $size }.
attachments-disk-name = Имя на диске: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Открыть папку вложений
attachments-folder-warning =
    В этой папке хранятся файлы, приложенные вами к операциям. Radinus хранит их под именем, которое выбрал сам: переименование, перемещение или удаление файла не отвязывает его от операции — она по-прежнему будет его показывать, а он больше не откроется.
    Действительно открыть её?

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
operations-column-status = Статус операции
operation-status-pointed = Сверенная
operation-status-committed = Зарезервированная
operation-status-planned = Запланированная
operations-column-verification = Проверка
operation-verification-to-verify = К проверке
operation-verification-verified = Проверена
operation-verification-doubtful = Сомнительная
operation-verification-disputed = Оспорена
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
filter-by-status = Фильтр по статусу
filter-by-verification = Фильтр по проверке
filter-show-all = Показать все

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
operation-field-verification = Проверка
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
operation-clearing-date-required = Проведённая операция обязательно должна иметь дату проведения.
operation-clearing-date-question =
    Проведённая операция обязательно должна иметь дату проведения.
    Сохранить с датой операции — { $date }?
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
    [0] Нет операций для сверки: выделенные уже сверены.
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
operations-recurring-from = Создать периодическую операцию на основе этой операции

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
    [verification] Статистика по проверке
   *[category] Статистика по категориям
}

statistics-axis-column = { $kind ->
    [assignment] Назначение
    [budget-line] СтатьяБюджета
    [payment-mode] СпособОперации
    [payee] Контрагент
    [project] Проекты
    [verification] Проверка
   *[category] НазваниеКатегории
}

statistics-unclassified = { $kind ->
    [assignment] Без назначения
    [budget-line] Без статьи бюджета
    [payment-mode] Без способа оплаты
    [payee] Без контрагента
    [project] Без проекта
    [verification] К проверке
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

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Перекрёстный баланс
crossed-balance-window-name = Перекрёстный баланс
crossed-balance-column = Категория
crossed-balance-no-data = Нет операций за этот месяц по выбранным счетам.
crossed-balance-month-question = С каким месяцем работать? Число от { $first } до { $last }.
crossed-balance-month-choose = Выбрать месяц
crossed-balance-next = Следующий месяц
crossed-balance-previous = Предыдущий месяц

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
export-to = Экспорт в
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Копировать ячейку
copy-rows = Копировать выбранные строки
copy-failed = Не удалось скопировать в буфер обмена.
export-all-years-excel = Экспортировать все годы в Excel
export-all-years-ods = Экспортировать все годы в LibreOffice Calc
export-all-months-excel = Экспортировать все месяцы показанного года в Excel
export-all-months-ods = Экспортировать все месяцы показанного года в LibreOffice Calc
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
    [verification] Статистика по проверке
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

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Анализ динамики баланса
analysis-heading = Анализ динамики баланса
analysis-hint = Проведите по графику, удерживая кнопку мыши, чтобы увидеть операции за этот период.
analysis-zone = Зона:
analysis-opening = Баланс на начало:
analysis-closing = Баланс на конец:
analysis-variation = Изменение:
analysis-detail-name = Анализ баланса
analysis-detail-none = В этой зоне нет ни одной операции.

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
quick-check-verification = Проверка
quick-column-date = Дата
quick-column-label = Описание
quick-column-amount = Сумма
quick-column-category = Категория
quick-column-assignment = Назначение
quick-column-payment-mode = Способ оплаты
quick-column-payee = Контрагент
quick-column-project = Проекты
quick-column-status = Статус
quick-column-verification = Проверка
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
statement-title-open = Открыть файл выписки (OFX, QIF, CSV)
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
statement-loaded-unidentified = { $alike ->
    [0] Прочитано строк: { $count }; ни одна не похожа на операцию, которая уже есть в вашем счёте.
    [one] Прочитано строк: { $count }, из них { $alike } похожа на операцию, которая уже есть в вашем счёте (та же дата, то же описание, та же сумма).
    [few] Прочитано строк: { $count }, из них { $alike } похожи на операции, которые уже есть в вашем счёте (та же дата, то же описание, та же сумма).
    [many] Прочитано строк: { $count }, из них { $alike } похожи на операции, которые уже есть в вашем счёте (та же дата, то же описание, та же сумма).
   *[other] Прочитано строк: { $count }, из них { $alike } похожи на операции, которые уже есть в вашем счёте (та же дата, то же описание, та же сумма).
}
statement-loaded-also-alike = { $alike ->
    [one] Ещё { $alike } похожа на операцию, которая уже есть (та же дата, то же описание, та же сумма).
    [few] Ещё { $alike } похожи на операции, которые уже есть (та же дата, то же описание, та же сумма).
    [many] Ещё { $alike } похожи на операции, которые уже есть (та же дата, то же описание, та же сумма).
   *[other] Ещё { $alike } похожи на операции, которые уже есть (та же дата, то же описание, та же сумма).
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
statement-qif-question = Ничто в этом файле не указывает, записана ли дата «{ $date }» как день/месяц или как месяц/день. Она означает:
statement-qif-day-month = День { $day }, месяц { $month } (день/месяц)
statement-qif-month-day = День { $day }, месяц { $month } (месяц/день)
statement-qif-dates-mixed = В этом файле даты записаны двумя способами: «{ $first }» читается как день/месяц, «{ $second }» — как месяц/день. Файл не импортируется, чтобы ни одна дата не была искажена.
statement-qif-amounts-mixed = В этом файле суммы записаны двумя способами: «{ $first }» с точкой, «{ $second }» с запятой. Файл не импортируется, чтобы ни одна сумма не была искажена.
statement-qif-opening = Начальный баланс { $amount } на { $date }: это не операция, он не импортируется.
statement-qif-opening-undated = Начальный баланс { $amount }: это не операция, он не импортируется.
statement-qif-suspect = Строка { $rank }, «{ $label }» ({ $amount }), похожа на начальный баланс: проверьте её перед включением.
statement-qif-rejected = { $count ->
    [one] { $count } нечитаемая строка не импортируется: { $lines }.
    [few] { $count } нечитаемые строки не импортируются: { $lines }.
    [many] { $count } нечитаемых строк не импортируются: { $lines }.
   *[other] { $count } нечитаемой строки не импортируются: { $lines }.
}
statement-qif-reason-date = дата
statement-qif-reason-amount = сумма
statement-qif-reason-differ = противоречивые суммы
statement-qif-no-account = Этого счёта больше нет в файле: откройте файл заново.
statement-balance-unknown = не указан в файле
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
backup-not-started = Не удалось начать резервное копирование:
restore-unreadable = Этот файл не является читаемым архивом Radinus: { $reason }
# Вопрос говорит, что будет потеряно, прежде чем это потеряется. Архив к этому
# моменту уже прочитан: то, о чём он сообщает, достоверно.
restore-question = Восстановить «{ $file }»? Всё текущее содержимое вашей базы будет стёрто и заменено, и то, что в ней находится, будет потеряно.
restore-done = Восстановление завершено: { $accounts } счетов и { $operations } операций.
restore-failed = Восстановление невозможно: { $reason }
restore-empty-fields = Пустые поля, прочитанные как нулевое значение: { $count }.


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
database-too-recent = Эта база сохранена более новой версией Radinus (версия базы { $found }; эта версия читает до версии { $supported }). Обновите Radinus, чтобы открыть её.
database-not-radinus = Этот файл не является базой Radinus.
database-unreadable = Не удалось прочитать базу: { $reason }
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
journal-step-restore-empty-fields = Пустые поля, заполненные при чтении
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
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Счета, учтённые в итогах: { $count } из { $total }
welcome-tile-counted = Учитывать этот счёт в итогах
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
menu-settings-folders = Папки Radinus
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
preferences-branch-import = Импорт
preferences-leaf-verification = Проверка
preferences-field-verification = Импортированные операции:
preferences-verification-hint = «Проверена»: вы доверяете своему банку, импортированная операция считается верной. «К проверке»: каждая импортированная операция ждёт вашей проверки; затем вы сами переводите её в «Проверена» в списке операций. Эта настройка действует только для будущих импортов.
preferences-leaf-qif = Выписки QIF
preferences-field-qif-order = Порядок дня и месяца:
preferences-qif-order-ask = Спрашивать меня каждый раз
preferences-qif-order-day-month = Всегда день/месяц (05/03 = 5 марта)
preferences-qif-order-month-day = Всегда месяц/день (05/03 = 3 мая)
preferences-qif-order-help = Используется, только если ни одна дата в файле не позволяет определить порядок. Как только дата вроде 24/11 доказывает порядок, решает файл, независимо от этой настройки.
preferences-field-qif-label = Описание операции:
preferences-qif-label-both = Контрагент + примечание
preferences-qif-label-payee = Только контрагент
preferences-qif-label-memo = Только примечание
preferences-qif-label-help = Когда у операции есть и контрагент, и примечание. Если есть только одно из них, используется именно оно, независимо от этой настройки.
preferences-qif-hint = Эти настройки действуют для всех выписок QIF, какая бы база ни была открыта. «Спрашивать меня каждый раз» — самый надёжный вариант: файл с неоднозначными датами никогда не читается наугад.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Восстановить столбцы по умолчанию
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Показать/Скрыть
columns-colour = Раскрасить столбец:
columns-colour-none = Без цвета
columns-colour-red = Красный
columns-colour-orange = Оранжевый
columns-colour-pink = Розовый
columns-colour-pastel-green = Пастельно-зелёный
columns-colour-green = Зелёный
columns-colour-pastel-blue = Пастельно-синий
columns-colour-blue = Синий
columns-colour-pastel-yellow = Пастельно-жёлтый
columns-colour-yellow = Жёлтый
preferences-leaf-columns = Столбцы таблиц
preferences-table-operations-list = Список операций
preferences-columns-reset = Сбросить
preferences-columns-reset-all = Сбросить всё
preferences-columns-done = Столбцы вернулись к исходному расположению.
preferences-columns-hint = Каждая таблица запоминает порядок столбцов, скрытые вами столбцы и их ширину. «Сбросить» сразу возвращает ей исходное расположение.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Сброс
preferences-leaf-comfort = Настройки удобства
preferences-comfort-reset = Сбросить настройки удобства
preferences-comfort-hint = Возвращает к исходному виду столбцы всех таблиц, порядок и флажки счетов в начальном окне и размер отображения. Язык, валюта и проверка импортированных операций не затрагиваются.
preferences-comfort-question = Сбросить настройки удобства? Столбцы таблиц, начальное окно и размер отображения вернутся к исходному состоянию.
preferences-comfort-done = Настройки удобства сброшены.

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

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Расчёт кредита
window-loan-title = Расчёт кредита
loan-tab-credit = Кредит
loan-tab-afford = Смогу ли я его выплатить?
loan-field-kind = Вид кредита
loan-kind-consumer = Потребительский кредит
loan-kind-mortgage = Ипотека
loan-field-amount = Сумма кредита
loan-field-payment = Ежемесячный платёж
loan-field-months = Срок
loan-field-rate = Фиксированная ставка
loan-field-fees = Комиссия за оформление
loan-field-insurance = Страховка в месяц
loan-unit-months = мес.
loan-unit-percent = %
loan-invalid-field = Это значение не является числом: исправьте его, чтобы пересчитать.
loan-report-button = Отчёт PDF
loan-monthly-table = Таблица по месяцам
loan-months-count = { $count ->
        [one] { $count } месяц
        [few] { $count } месяца
        [many] { $count } месяцев
       *[other] { $count } месяца
    }
loan-percent = { $value } %
loan-notice-payment-too-low = Этот платёж не покрывает проценты: кредит никогда не будет погашен. Срок остаётся 600 месяцев.
loan-notice-too-long = Для этого платежа потребовалось бы более 600 месяцев: срок остаётся 600 месяцев.
loan-figure-payment = Ежемесячный платёж
loan-figure-payment-insured = Платёж со страховкой
loan-figure-taeg = Полная стоимость кредита
loan-figure-interest = Стоимость процентов
loan-figure-insurance = Стоимость страховки
loan-figure-cost = Общая стоимость кредита
loan-figure-total-due = Общая сумма к выплате
loan-figure-all-in = Всего выплачено, со страховкой
loan-part-capital = Сумма кредита
loan-part-interest = Проценты
loan-part-fees = Комиссия за оформление
loan-part-insurance = Страховка
loan-donut-cost-caption = всего
loan-chart-cost = Сколько стоит этот кредит
loan-chart-capital = Остаток долга
loan-schedule-title = График платежей
loan-schedule-yearly = График платежей по годам
loan-column-number = №
loan-column-year = Год
loan-column-date = Дата платежа
loan-column-payment = Платёж
loan-column-payments = Платежи
loan-column-interest = Проценты
loan-column-capital = Основной долг
loan-column-insurance = Страховка
loan-column-remaining = Остаток долга
loan-history-label = Изучаемый период
loan-period-last-12 = Последние 12 месяцев
loan-accounts-title = Изучаемые счета
loan-period-title = Период
loan-column-account = Счёт
loan-column-bank = Банк
loan-column-balance = Реальный остаток
loan-unavailable-no-account = Отметьте хотя бы один счёт, чтобы изучить вашу историю.
loan-unavailable-no-month = В этом периоде ещё нет ни одного полного месяца: выберите другой.
loan-verdict-title = Коротко
loan-verdict-green = Посильно
loan-verdict-orange = На пределе
loan-verdict-red = Рискованно
loan-verdict-no-income = За этот период нет доходов: долговую нагрузку рассчитать нельзя.
loan-check-debt-green = Долговая нагрузка { $ratio }: ниже порога этого метода ({ $green }).
loan-check-debt-orange = Долговая нагрузка { $ratio }: между { $green } и { $red }, на пределе.
loan-check-debt-red = Долговая нагрузка { $ratio }: выше { $red }.
loan-check-effort = Платёж { $payment } забирает { $share } того, что вы откладываете { $kind ->
        [good] в хороший месяц
        [hard] в трудный месяц
       *[usual] в обычный месяц
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Хороший месяц
        [hard] Трудный месяц
       *[usual] Обычный месяц
    } ничего не оставляет: платёж { $payment } шёл бы из вашего запаса.
loan-check-reserve-green = Ваш остаток остаётся положительным до конца кредита.
loan-check-reserve-red = Из-за этого кредита ваш остаток ушёл бы в минус: { $month }.
loan-check-reserve-sooner = Ваш остаток ушёл бы в минус ({ $month }) на { $count ->
        [one] { $count } месяц
        [few] { $count } месяца
        [many] { $count } месяцев
       *[other] { $count } месяца
    } раньше, чем без этого кредита.
loan-check-reserve-anyway = Ваш остаток ушёл бы в минус и без этого кредита (около: { $month }); кредит почти ничего не меняет.
loan-check-reserve-floor-green = Ваш остаток остаётся выше страхового резерва ({ $floor }) до конца кредита.
loan-check-reserve-floor-red = Из-за этого кредита ваш остаток опустился бы ниже страхового резерва ({ $floor }): { $month }.
loan-check-reserve-floor-sooner = Ваш остаток опустился бы ниже страхового резерва ({ $floor }; { $month }) на { $count ->
        [one] { $count } месяц
        [few] { $count } месяца
        [many] { $count } месяцев
       *[other] { $count } месяца
    } раньше, чем без этого кредита.
loan-check-reserve-floor-anyway = Ваш остаток опустился бы ниже страхового резерва ({ $floor }) и без этого кредита (около: { $month }); кредит почти ничего не меняет.
loan-warning-deficit = Внимание: за этот период ваши расходы уже превышают доходы в среднем на { $amount } в месяц, до любого кредита.
loan-figure-reference = Сбережения { $kind ->
        [good] в хороший месяц
        [hard] в трудный месяц
       *[usual] в обычный месяц
    }
loan-figure-tipped = Месяцы, которые кредит увёл бы в минус
loan-gauge-caption = долговая нагрузка
loan-figure-income = Средний доход в месяц
loan-figure-spending = Средние расходы в месяц
loan-figure-saving = Средние сбережения в месяц
loan-figure-running = Текущие кредиты в месяц
loan-figure-new = Новый платёж со страховкой
loan-figure-rest = На жизнь в месяц
loan-figure-debt = Долговая нагрузка
loan-red-months-value = { $count } из { $total }
loan-figure-balance-now = Реальный остаток сегодня
loan-figure-balance-end = Прогноз остатка к концу кредита
loan-chart-income = Куда уходит ваш средний доход
loan-donut-income-caption = средний доход
loan-part-spending = Текущие расходы
loan-part-running = Текущие кредиты
loan-part-new = Новый кредит
loan-part-rest = Остаётся
loan-part-missing = Не хватает
loan-chart-history = Ваша история с этим кредитом
loan-chart-history-hint = Что осталось бы каждый месяц после уплаты платежа. Ярко-красным — месяцы, которые кредит увёл бы в минус; бледно-красным — те, что были в минусе и без него.
loan-chart-projection = Прогноз вашего остатка
loan-mark-loan-end = Конец: { $label }
loan-mark-negative = В минусе
loan-mark-floor = Ниже резерва
loan-mark-floor-line = Страховой резерв
loan-running-title = Учтённые текущие кредиты
loan-running-column-label = Периодическая операция
loan-running-column-monthly = В месяц
loan-running-column-end = Последний платёж
loan-no-running = Среди ваших периодических операций не найдено ни одного текущего кредита.
loan-period-caption = { $from } – { $to } ({ $count ->
        [one] { $count } месяц
        [few] { $count } месяца
        [many] { $count } месяцев
       *[other] { $count } месяца
    })
loan-transfers = { $count ->
        [0] Переводов между отмеченными счетами не найдено.
        [one] Найден и исключён { $count } перевод между отмеченными счетами.
        [few] Найдено и исключено { $count } перевода между отмеченными счетами.
        [many] Найдено и исключено { $count } переводов между отмеченными счетами.
       *[other] Найдено и исключено { $count } перевода между отмеченными счетами.
    }
loan-method = Средние по полным месяцам периода, проведённые и подтверждённые операции, без переводов между отмеченными счетами.
loan-report-title = Расчёт кредита
loan-report-made-on = расчёт от { $date }
loan-disclaimer = Ориентировочный расчёт, не имеющий договорной силы. Обязательна только оферта банка.
loan-tab-rules = Настройки оценки
loan-method-optimistic = Оптимистичный
loan-method-neutral = Нейтральный
loan-method-severe = Строгий
loan-method-line = Метод оценки: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Оценка отвечает на три вопроса, и каждый метод ставит свои требования. Выберите тот, что вам ближе: оценка на вкладке «Смогу ли я его выплатить?» следует ему. Последняя строка предполагает, что ваши расходы растут каждый год на указанный процент; платёж не меняется.
loan-rule-row-debt = Допустимая долговая нагрузка
loan-rule-row-reference = Опорные сбережения
loan-rule-row-share = Доля этих сбережений, которую может забрать платёж
loan-rule-row-floor = Порог, ниже которого остаток не должен опускаться
loan-rule-row-sooner = Если остаток опускается ниже и без кредита
loan-rule-row-growth = Рост ваших расходов в год
loan-rule-limits = зелёный до { $green }, оранжевый до { $red }
loan-rule-reference = { $kind ->
        [good] хороший месяц
        [hard] трудный месяц
       *[usual] обычный месяц
    }: { $amount }
loan-rule-floor-zero = ноль
loan-rule-floor-cushion = месяц расходов: { $amount }
loan-rule-sooner = оранжевый, если кредит приближает это на { $orange }, красный — на { $red }
loan-unit-percent-year = % в год
loan-method-optimistic-explain = Оптимистичный метод исходит из хорошего месяца, допускает долговую нагрузку до 40 % и не держит резерва: он показывает, что возможно, если всё пойдёт хорошо.
loan-method-neutral-explain = Нейтральный метод исходит из обычного месяца и следует правилу банков — 33–35 % долговой нагрузки: это опорная оценка.
loan-method-severe-explain = Строгий метод исходит из трудного месяца и держит месяц расходов в резерве на непредвиденное: он показывает, что выдержит, даже если всё пойдёт плохо.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Энергопотребление электроприбора
window-appliance-title = Энергопотребление электроприбора
appliance-device-title = Прибор
appliance-on-title = Включён
appliance-standby-title = В режиме ожидания
appliance-field-on-watts = Мощность в работе
appliance-field-on-hours = Время работы в сутки
appliance-field-days = Дней использования в неделю
appliance-field-share = Доля работы в льготные часы
appliance-field-standby-watts = Мощность в режиме ожидания
appliance-field-standby-hours = Время в режиме ожидания в день использования
appliance-unit-watts = Вт
appliance-unit-hours = ч
appliance-unit-days = из 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/кВт·ч
appliance-standby-hint = Если поле пустое, режим ожидания длится весь остаток дня. В дни без использования прибор остаётся включённым в розетку: всё это время считается режимом ожидания. Если прибор отключён от сети, его потребление в режиме ожидания — 0 Вт.
appliance-contract-title = Ваш договор
appliance-field-option = Тарифный план
appliance-option-base = Однотарифный (одна цена)
appliance-option-off-peak = Пиковые / льготные часы
appliance-field-base = Цена за кВт·ч
appliance-field-peak = Цена за кВт·ч в пиковые часы
appliance-field-off-peak = Цена за кВт·ч в льготные часы
appliance-field-off-peak-hours = Льготных часов в сутки
appliance-contract-hint = Эти цены действуют только для этого расчёта. Сохранённый тариф задаётся в разделе Настройки › Параметры › Инструменты.
appliance-contract-reset = Вернуть сохранённый тариф
appliance-period-day = В день
appliance-period-month = В месяц
appliance-period-year = В год
appliance-energy = { $value } кВт·ч
appliance-less-than = менее { $amount }
appliance-detail-title = Подробно за год
appliance-column-part = Статья
appliance-column-energy = Энергия
appliance-column-cost = Стоимость
appliance-column-share = Доля
appliance-line-on = Включён
appliance-line-standby = В режиме ожидания
appliance-line-on-peak = Включён, пиковые часы
appliance-line-on-off-peak = Включён, льготные часы
appliance-line-standby-peak = В режиме ожидания, пиковые часы
appliance-line-standby-off-peak = В режиме ожидания, льготные часы
appliance-line-total = Итого
appliance-chart-title = Куда уходят деньги
appliance-chart-caption = в год
appliance-standby-sentence = Один только режим ожидания стоит { $amount } в год: { $share } от общей стоимости прибора.
appliance-note-plate = Мощность, указанная на приборе или в его инструкции, — это максимум: в работе большинство приборов потребляют меньше. Чтобы получить реальное значение, измерьте её ваттметром-розеткой и введите его показания.
appliance-note-subscription = Абонентская плата не учитывается: она взимается независимо от того, включён прибор в розетку или нет.
appliance-invalid-watts = Пожалуйста, укажите мощность от 0 до 100 000 Вт.
appliance-invalid-hours = Пожалуйста, укажите время от 0 до 24 часов в сутки.
appliance-invalid-days = Пожалуйста, укажите целое число дней от 0 до 7.
appliance-invalid-share = Пожалуйста, укажите долю от 0 до 100 %.
appliance-invalid-day-overflow = Работа и режим ожидания в сумме превышают 24 часа в сутки.
appliance-invalid-price = Пожалуйста, укажите цену за кВт·ч от 0 до 100.
appliance-invalid-off-peak-hours = Пожалуйста, укажите целое число льготных часов от 0 до 24.
preferences-branch-tools = Инструменты
preferences-leaf-electricity = Тариф на электроэнергию
preferences-electricity-blue = Вернуться к Tarif Bleu EDF
preferences-electricity-hint = Тариф по вашему договору, который использует инструмент «Энергопотребление электроприбора». По умолчанию: Tarif Bleu от EDF (Франция) по состоянию на 1 августа 2026 г., цены с учётом налогов, счётчик от 3 до 6 кВА. Эти цены часто меняются в феврале и августе: перепишите их из своего счёта.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Моя финансовая подушка
window-cushion-title = Моя финансовая подушка
cushion-question = Если бы ваши доходы прекратились завтра, на сколько месяцев хватило бы ваших сбережений?
cushion-accounts-title = Ваши счета
cushion-column-account = Счёт
cushion-column-balance = Реальный остаток
cushion-column-savings = Сбережения
cushion-column-spending = Расходы
cushion-accounts-hint = «Сбережения»: деньги, на которые вы рассчитываете в трудный момент. «Расходы»: счета, с которых оплачиваются повседневные траты.
cushion-history-label = Анализируемый период
cushion-backup-label = Резервный доход в месяц
cushion-backup-hint = То, что продолжало бы поступать: пособие по безработице, зарплата супруга… Пусто: никакого дохода.
cushion-categories-title = Учитываемые расходы
cushion-categories-hint = Снимите отметку с того, от чего вы откажетесь в трудный момент.
cushion-categories-empty = За этот период расходов нет.
cushion-verdict-title = Ваша подушка
cushion-targets-title = Пороги надёжности
cushion-projection-title = Ваши сбережения в трудный момент
cushion-projection-hint = Сколько оставалось бы каждый месяц, если бы ваши доходы прекратились сегодня.
cushion-note = Оценка на основе вашей истории: расходы в трудный месяц могут отличаться от средних.
cushion-invalid-backup = Эту сумму не удаётся прочитать: исправьте её, чтобы пересчитать.
cushion-no-spending-account = Отметьте хотя бы один счёт «Расходы».
cushion-no-month = В этом периоде пока нет ни одного полного месяца.
cushion-months = { $value } мес.
cushion-per-month = { $amount } в месяц
cushion-figure-holds = Без ограничений
cushion-gauge-caption = расходов покрыто
cushion-verdict-short = Меньше трёх месяцев: трудный момент быстро поставит вас в сложное положение.
cushion-verdict-fair = От трёх до шести месяцев: приличная подушка, которую стоит увеличить, если получится.
cushion-verdict-solid = Шесть месяцев и больше: ваша подушка надёжна.
cushion-verdict-holds = Ваш резервный доход покрывает ваши расходы: сбережения не будут таять.
cushion-verdict-nothing = За период нет учитываемых расходов: покрывать нечего.
cushion-tile-savings = Доступные сбережения
cushion-tile-spending = Учитываемые расходы
cushion-tile-backup = Резервный доход
cushion-tile-burn = Сбережения таяли бы на
cushion-tile-rhythm = Темп накоплений
cushion-burn-none = Ничего
cushion-target-title = { $months } мес. расходов: { $amount }
cushion-target-reached = Достигнуто.
cushion-target-date = Не хватает { $missing }. При вашем темпе накоплений будет достигнуто примерно к дате: { $month }.
cushion-target-never = Не хватает { $missing }. Ваши сбережения не выросли за период: при таком темпе этот порог не будет достигнут.
cushion-mark-empty = Сбережения закончатся: { $month }
cushion-period = Среднее за { $count ->
        [one] { $count } полный месяц
        [few] { $count } полных месяца
        [many] { $count } полных месяцев
       *[other] { $count } полных месяцев
    } (период: { $from } — { $to }). { $transfers ->
        [0] Переводов между вашими счетами нет.
        [one] { $transfers } перевод между вашими счетами исключён из расчёта.
        [few] { $transfers } перевода между вашими счетами исключены из расчёта.
        [many] { $transfers } переводов между вашими счетами исключены из расчёта.
       *[other] { $transfers } переводов между вашими счетами исключены из расчёта.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Цель накоплений
window-goal-title = Цель накоплений
goal-accounts-title = Отслеживаемые счета
goal-column-account = Счёт
goal-column-balance = Реальный остаток
goal-accounts-hint = Перевод между двумя отслеживаемыми счетами взаимно компенсируется; перевод на неотслеживаемый счёт считается расходом.
goal-period-label = Базовый период
goal-period-range = Диапазон лет…
goal-range-from = с
goal-range-to = по
goal-question-title = Ваш вопрос
goal-question-when = Когда у меня будет эта сумма?
goal-question-amount = Сколько у меня будет к этой дате?
goal-question-effort = Сколько откладывать, чтобы к этой дате у меня была эта сумма?
goal-field-target = Целевая сумма
goal-field-date = Целевая дата
goal-field-rate = Годовая ставка по сбережениям
goal-field-extra = А если откладывать дополнительно, в месяц
goal-options-hint = Пусто: без процентов, ничего дополнительно.
goal-answer-title = Ответ
goal-chart-title = Ваш остаток: вчера и завтра
goal-chart-hint = Сплошная линия: реальный остаток за последние двенадцать месяцев; пунктир: прогноз; светлая область: диапазон в зависимости от месяцев.
goal-disclaimer = Прогноз на основе вашей истории, а не обещание: любая неожиданность может всё изменить.
goal-no-account = Отметьте хотя бы один счёт для отслеживания.
goal-no-month = В этом периоде пока нет ни одного полного месяца.
goal-invalid-target = Укажите целевую сумму, пожалуйста.
goal-invalid-date = Укажите будущую дату в пределах ближайших пятидесяти лет, пожалуйста.
goal-invalid-rate = Укажите ставку от 0 до 100 %, пожалуйста.
goal-invalid-extra = Эту сумму не удаётся прочитать: исправьте её, чтобы пересчитать.
goal-per-month = { $amount } в месяц
goal-tile-balance = Остаток сегодня
goal-tile-rhythm = Средний темп
goal-tile-target = Цель
goal-tile-reached = Примерный срок достижения
goal-tile-date = Целевая дата
goal-tile-projected = Прогнозный остаток
goal-tile-saved = Накоплено к этому сроку
goal-tile-interest = В том числе проценты
goal-tile-needed = Нужно откладывать
goal-when-already = У вас уже есть { $amount }: на отслеживаемых счетах в сумме { $balance }.
goal-when-reached = У вас будет { $amount } примерно через { $months ->
        [one] { $months } месяц
        [few] { $months } месяца
        [many] { $months } месяцев
       *[other] { $months } месяцев
    } ({ $month }).
goal-when-range = В зависимости от месяцев: { $early } — { $late }.
goal-when-range-open = Самое раннее: примерно { $early }; при слабых месяцах цель не была бы достигнута.
goal-when-never = При таком темпе вы не достигнете суммы { $amount }.
goal-zero = Ваш остаток упал бы до нуля примерно к дате: { $month }.
goal-amount = { $month }: у вас было бы около { $amount }.
goal-amount-range = В зависимости от месяцев: от { $low } до { $high }.
goal-effort-more = Чтобы к указанной дате ({ $month }) у вас было { $amount }, нужно откладывать в среднем { $monthly } в месяц, то есть на { $gap } больше, чем сейчас.
goal-effort-less = Чтобы к указанной дате ({ $month }) у вас было { $amount }, хватило бы { $monthly } в месяц, то есть на { $gap } меньше, чем сейчас: вы опережаете план.
goal-effort-range = В зависимости от месяцев отклонение от вашего темпа составило бы от { $low } до { $high } в месяц.
goal-chart-target = Цель: { $amount }
goal-chart-today = Сегодня
goal-note-seasons = Прогноз учитывает сезонность: для каждого будущего месяца берётся среднее значение тех же месяцев периода.
goal-note-range = Диапазон строится по слабым и сильным месяцам периода: нижней четверти и верхней четверти.
goal-note-loan = Кредит «{ $label }» заканчивается ({ $month }): после этого — плюс { $amount } в месяц.
goal-note-interest = Проценты начисляются каждый месяц по ставке { $rate } % годовых: приближение правила полумесячных периодов для сберегательных счетов.
goal-period = Темп рассчитан за { $count ->
        [one] { $count } полный месяц
        [few] { $count } полных месяца
        [many] { $count } полных месяцев
       *[other] { $count } полных месяцев
    } (период: { $from } — { $to }). { $transfers ->
        [0] Переводов между отслеживаемыми счетами нет.
        [one] { $transfers } перевод между отслеживаемыми счетами исключён из расчёта.
        [few] { $transfers } перевода между отслеживаемыми счетами исключены из расчёта.
        [many] { $transfers } переводов между отслеживаемыми счетами исключены из расчёта.
       *[other] { $transfers } переводов между отслеживаемыми счетами исключены из расчёта.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = А если сократить…?
window-cut-title = А если сократить…?
cut-axis-label = Группировка
cut-axis-category = Категории
cut-axis-payee = Контрагенты
cut-axis-budget-line = Статьи бюджета
cut-table-title = Ваши расходы по статьям
cut-table-hint = Введите сокращение в % или в { $sign } в месяц для статей, которые вы хотели бы уменьшить. Сокращение не может превышать сам расход.
cut-column-monthly = В месяц
cut-column-cut = Сокращение
cut-column-after = После
cut-column-yearly = Экономия в год
cut-total = Итого
cut-horizon-label = Горизонт
cut-settings-title = Настройки
cut-options-hint = Ставка и целевая сумма необязательны.
cut-report-button = Отчёт PDF
cut-chart-title = Ваш остаток без сокращений и с ними
cut-chart-hint = Сплошная линия: реальный остаток за последние двенадцать месяцев; серый пунктир: прогноз без сокращений; синим: с ними; зелёным: сэкономленные деньги.
cut-donut-title = Ваши расходы в месяц после сокращений
cut-donut-caption = в месяц после сокращений
cut-donut-others = Другие статьи
cut-donut-saved = Сэкономлено
cut-legend-with = С сокращениями
cut-legend-without = Без сокращений
cut-years = { $years ->
        [one] { $years } год
        [few] { $years } года
        [many] { $years } лет
       *[other] { $years } года
    }
cut-headline-none = Введите сокращение в таблице, чтобы увидеть его эффект.
cut-headline = Сократив { $count ->
        [one] { $count } статью
        [few] { $count } статьи
        [many] { $count } статей
       *[other] { $count } статьи
    }, вы откладывали бы на { $monthly } больше в месяц, то есть { $yearly } в год.
cut-tile-monthly = Экономия в месяц
cut-tile-yearly = Экономия в год
cut-tile-horizon = Экономия за { $years ->
        [one] { $years } год
        [few] { $years } года
        [many] { $years } лет
       *[other] { $years } года
    }
cut-tile-spending = Расходы в месяц
cut-target-already = У вас уже есть { $amount }.
cut-target-sooner = Вы достигли бы суммы { $amount } примерно к дате: { $with } (без сокращений: { $without }) — { $months ->
        [0] без выигрыша во времени
        [one] на { $months } месяц раньше
        [few] на { $months } месяца раньше
        [many] на { $months } месяцев раньше
       *[other] на { $months } месяца раньше
    }.
cut-target-only-with = С этими сокращениями вы достигли бы суммы { $amount } примерно к дате: { $with }; без них, при нынешнем темпе, — никогда.
cut-target-never = Даже с этими сокращениями вы не достигли бы суммы { $amount } при нынешнем темпе.
cut-note-seasons = Каждое сокращение учитывает сезонность своей статьи: статья, расходы по которой приходятся в основном на лето, и экономию даёт в основном летом.
cut-note-capped = Одно из введённых сокращений превышало расход: оно уменьшено до размера самого расхода.
cut-invalid-cut = Это сокращение не удаётся прочитать: укажите процент от 0 до 100 или сумму в месяц.
cut-report-settings = Настройки
cut-report-result = Результат
cut-report-accounts = Отслеживаемые счета

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Спланировать отпуск
window-holiday-title = Спланировать отпуск
holiday-trip-title = Поездка
holiday-field-trip = Тип поездки
holiday-trip-stay = Отдых
holiday-trip-cruise = Круиз
holiday-field-adults = Взрослые
holiday-field-children = Дети
holiday-field-nights = Продолжительность, в ночах
holiday-field-days = Дни
holiday-field-months = Месяцев до отъезда
holiday-field-stops = Количество портов захода
holiday-saved-title = Уже накоплено
holiday-saved-hint = Отметьте счета, на которых уже отложены деньги на отпуск: их реальный остаток считается уже накопленным.
holiday-budget-title = Бюджет
holiday-budget-hint = Для каждой статьи — сумма, на кого она приходится и на какой срок. Пустая статья не учитывается.
holiday-optional-title = Необязательные статьи
holiday-result-title = Результат
holiday-donut-title = Куда уходят деньги на поездку
holiday-donut-caption = на поездку
holiday-child-label = Детская цена
holiday-count-label = Каюты
holiday-open = Открыть проект…
holiday-save = Сохранить проект…
holiday-pdf = Отчёт PDF
holiday-excel = Экспорт в Excel
holiday-file-filter = Проект отпуска
holiday-replace-question = Открытие этого проекта заменит то, что введено в окне. Продолжить?
holiday-file-saved = Проект сохранён: { $file }
holiday-file-opened = Проект открыт: { $file }
holiday-file-not-project = Этот файл не является проектом отпуска Radinus.
holiday-file-too-recent = Этот проект создан в более новой версии Radinus: обновите Radinus, чтобы открыть его.
holiday-file-failed = Не удалось прочитать или записать файл: { $reason }
holiday-line-transport = Дорога туда и обратно
holiday-line-lodging = Проживание
holiday-line-meals = Питание и текущие расходы
holiday-line-visits = Достопримечательности и досуг
holiday-line-port = Дорога до порта
holiday-line-cabins = Каюты
holiday-line-service = Сервисный сбор (чаевые)
holiday-line-drinks = Пакет напитков
holiday-line-excursions = Экскурсии в портах захода
holiday-line-port-taxes = Портовые сборы
holiday-line-wifi = Wi-Fi на борту
holiday-line-onboard = Расходы на борту и на берегу
holiday-line-other = Прочие и непредвиденные расходы
holiday-line-insurance = Страховка от невыезда
holiday-line-stay-tax = Туристический налог
holiday-line-car = Автомобиль на месте, топливо и платные дороги
holiday-line-parking = Парковка в аэропорту или на вокзале
holiday-line-bank = Банковские комиссии за границей
holiday-line-formalities = Формальности (паспорт, виза, прививки)
holiday-line-pets = Передержка питомцев
holiday-span-trip = за поездку
holiday-span-night = за ночь
holiday-span-day = в день
holiday-span-stop = за порт захода
holiday-who-all = на всех
holiday-who-person = на человека
holiday-who-adults = на взрослого
holiday-cabins-count = { $count ->
        [one] { $count } каюта
        [few] { $count } каюты
        [many] { $count } кают
       *[other] { $count } каюты
    }
holiday-days = { $days ->
        [one] { $days } день
        [few] { $days } дня
        [many] { $days } дней
       *[other] { $days } дня
    }
holiday-invalid-count = Введите целое число.
holiday-invalid-amount = Эту сумму не удаётся прочитать: нужно положительное число или процент от 0 до 100.
holiday-headline-empty = Введите суммы бюджета, чтобы увидеть, во что обойдётся поездка.
holiday-headline-stay = Этот отдых обошёлся бы в { $total } на { $people ->
        [one] { $people } человека
        [few] { $people } человек
        [many] { $people } человек
       *[other] { $people } человека
    } и { $nights ->
        [0] 0 ночей
        [one] { $nights } ночь
        [few] { $nights } ночи
        [many] { $nights } ночей
       *[other] { $nights } ночи
    }.
holiday-headline-cruise = Этот круиз обошёлся бы в { $total } на { $people ->
        [one] { $people } человека
        [few] { $people } человек
        [many] { $people } человек
       *[other] { $people } человека
    } и { $nights ->
        [0] 0 ночей
        [one] { $nights } ночь
        [few] { $nights } ночи
        [many] { $nights } ночей
       *[other] { $nights } ночи
    }.
holiday-tile-total = Общая стоимость
holiday-tile-person = На человека
holiday-tile-person-day = На человека в день
holiday-tile-saved = Уже накоплено
holiday-tile-remaining = Осталось собрать
holiday-tile-monthly = Нужно откладывать
holiday-remaining-none = Ничего: всё покрыто
holiday-monthly-none = Откладывать ничего не нужно
holiday-monthly-now = Отъезд в этом месяце
holiday-note-days = Дней на один больше, чем ночей: семь ночей — это восемь дней.
holiday-note-child = В расчёте на человека ребёнок платит детскую цену, если она указана; если поле пустое, он платит как взрослый.
holiday-note-percent = Процент страховки применяется к основным статьям поездки, процент банковских комиссий — к расходам на месте.
holiday-sheet-budget = Бюджет
holiday-sheet-result = Результат
holiday-column-line = Статья
holiday-column-amount = Сумма
holiday-column-child = Детская цена
holiday-column-who = На кого
holiday-column-span = На какой срок
holiday-column-cost = Стоимость
holiday-disclaimer = Оценка на основе ваших собственных сумм: реальные цены могут отличаться.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Проект сокращения расходов
cut-file-not-project = Этот файл не является проектом сокращения расходов Radinus.
cut-file-too-recent = Этот проект создан в более новой версии Radinus: обновите Radinus, чтобы открыть его.
cut-sheet-items = Статьи

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Журнал моего автомобиля
window-car-title = Журнал моего автомобиля
car-unnamed = Мой автомобиль
car-sheet-title = Автомобиль
car-field-plate = Регистрационный номер
car-field-make = Марка
car-field-model = Модель
car-field-engine = Тип двигателя
car-field-first-hand = Первый владелец
car-field-registered = Первая регистрация
car-field-acquired = Дата покупки
car-field-acquired-km = Пробег при покупке
car-field-service = ТО каждые
car-field-service-or = или каждые
car-unit-months-short = мес.
car-unit-km = km
car-tariff-title = Тариф на зарядку дома
car-tariff-hint = Этот тариф хранится в журнале автомобиля: он не меняет тариф в настройках.
car-tariff-reset = Взять тариф из настроек
car-engine-petrol = Бензин
car-engine-diesel = Дизель
car-engine-lpg = Газ (LPG)
car-engine-e85 = E85 (биоэтанол)
car-engine-hybrid = Гибрид
car-engine-plug-in = Подключаемый гибрид
car-engine-electric = Электромобиль
car-engine-hydrogen = Водород
car-energy-petrol = Бензин
car-energy-diesel = Дизельное топливо
car-energy-lpg = Газ (LPG)
car-energy-e85 = E85
car-energy-electricity = Электроэнергия
car-energy-hydrogen = Водород
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Энергия
car-rubric-upkeep = Текущее обслуживание
car-rubric-service = Плановое ТО
car-rubric-wear = Изнашиваемые детали
car-rubric-tyres = Шины
car-rubric-breakdown = Поломки
car-rubric-insurance = Страховка
car-rubric-inspection = Техосмотр
car-part-brake-pads = Тормозные колодки
car-part-brake-discs = Тормозные диски
car-part-timing-belt = Ремень ГРМ
car-part-clutch = Сцепление
car-part-battery-12v = Аккумулятор 12 В
car-part-shock-absorbers = Амортизаторы
car-part-wipers = Щётки стеклоочистителя
car-part-spark-plugs = Свечи зажигания
car-part-glow-plugs = Свечи накаливания
car-part-particulate-filter = Сажевый фильтр
car-part-catalytic-converter = Каталитический нейтрализатор
car-part-fuel-cell-filter = Фильтр топливного элемента
car-part-exhaust = Выхлопная система
car-part-other = Другая деталь…
car-axle-all = Все четыре шины
car-axle-front = Передние шины
car-axle-rear = Задние шины
car-verdict-pass = Пройден
car-verdict-counter = Повторный осмотр
car-charge-station = На зарядной станции
car-charge-home = Дома
car-slot-peak = Пиковые часы
car-slot-off-peak = Льготные часы
car-entry-new = Новая запись
car-entry-edit = Изменить запись
car-field-date = Дата
car-field-km = Пробег
car-field-rubric = Рубрика
car-field-amount = Сумма
car-field-garage = Сервис или АЗС
car-field-note = Примечание
car-field-energy = Энергия
car-field-quantity = Количество
car-field-charge = Зарядка
car-field-slot = Время зарядки
car-field-part = Деталь
car-field-part-name = Название детали
car-field-axle = Заменённые шины
car-field-verdict = Результат
car-field-months = Месяцев покрытия
car-field-battery = Состояние батареи
car-home-amount-hint = Сумма домашней зарядки рассчитывается по тарифу автомобиля.
car-entry-add = Добавить в журнал
car-entry-update = Сохранить запись
car-entry-cancel = Отмена
car-entry-delete = Удалить запись
car-delete-question = Удалить эту запись из журнала?
car-from-operation = Взять операцию…
car-pick-account = С какого счёта этот расход?
car-pick-operation = Какая операция?
car-pick-take = Взять
car-pick-none = На этом счёте нет расходов.
car-pick-taken = Операция взята: укажите пробег и рубрику, затем добавьте запись.
car-history-title = История
car-filter-all = Все рубрики
car-history-empty = Записей пока нет.
car-history-hint = Щёлкните по записи, чтобы изменить её.
car-column-date = Дата
car-column-km = Км
car-column-rubric = Рубрика
car-column-detail = Подробности
car-column-amount = Сумма
car-column-garage = Сервис
car-column-note = Примечание
car-column-share = Доля
car-column-per-km = На км
car-column-energy = Энергия
car-column-quantity = Количество
car-column-price = Средняя цена
car-column-consumption = Расход
car-column-part = Деталь
car-column-changes = Замены
car-column-last = Последняя замена
car-column-life = Срок службы
car-column-next = Следующая замена
car-total = Итого
car-summary-title = Во что обходится автомобиль
car-headline-empty = Заполните карточку, затем добавьте первую запись: заправку, ТО, счёт из сервиса…
car-headline = С { $since } ваш автомобиль обошёлся вам в { $total }.
car-headline-km = С { $since } ваш автомобиль обошёлся вам в { $total } за { $km } пробега: { $cost } на километр.
car-tile-total = Общая стоимость
car-tile-month = В месяц
car-tile-km = На километр
car-tile-driven = Пройдено километров
car-tile-consumption = Расход
car-tile-energy-km = Энергия на километр
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } месяц
        [few] { $months } месяца
        [many] { $months } месяцев
       *[other] { $months } месяца
    }
car-detail-battery = Батарея: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = По рубрикам
car-energy-title = Энергия
car-parts-title = Изнашиваемые детали
car-tyres-title = Шины
car-battery-title = Состояние батареи
car-years-title = Во что автомобиль обходился каждый год
car-donut-title = Куда уходят деньги
car-donut-caption = всего
car-deadlines-title = Сроки
car-deadlines-empty = Сроков пока нет: отметьте ТО, техосмотр, страховку или две замены одной и той же детали.
car-deadline-service = ТО
car-deadline-inspection = Техосмотр
car-deadline-counter = Повторный техосмотр
car-deadline-insurance = Окончание страховки
car-when-date = дата: { $date }
car-when-km = при пробеге { $km }
car-when-km-reached = при пробеге { $km }; в вашем темпе это примерно: { $month }
car-when-date-km = дата: { $date } или при пробеге { $km }, что наступит раньше
car-when-inspection-unknown = Отметьте последний техосмотр, чтобы узнать дату следующего.
car-tone-late = Просрочено
car-tone-soon = Скоро
car-note-since = Всё считается с момента покупки: по дате и пробегу, указанным в карточке.
car-note-consumption = Расход измеряется от полного бака до полного бака: заправляйтесь до полного и каждый раз записывайте пробег.
car-note-e85 = Автомобиль на E85 пьёт то, что ему нальют: километры после заправки засчитываются на это топливо.
car-note-home = Домашняя зарядка оценивается по тарифу автомобиля на день записи и сохраняет эту стоимость.
car-note-inspection = Техосмотр следует французскому правилу: первый — в течение четырёх лет после первой регистрации, затем каждые два года; повторный осмотр — в течение двух месяцев.
car-disclaimer = Сроки и сроки службы — это оценки по данным журнала: достоверна только сервисная книжка производителя.
car-invalid-date = Введите корректную дату, не позднее сегодняшней.
car-invalid-acquired = Дата покупки не может быть раньше первой регистрации.
car-invalid-km = Введите пробег в целых километрах.
car-invalid-amount = Эту сумму невозможно прочитать.
car-invalid-quantity = Введите количество: литры, кВт·ч или килограммы.
car-invalid-part = Выберите заменённую деталь или введите её название.
car-invalid-rubric = Выберите рубрику.
car-invalid-months = Введите целое число месяцев.
car-invalid-battery = Введите состояние батареи от 0 до 100 %.
car-open = Открыть журнал…
car-save = Сохранить журнал…
car-report-button = Отчёт PDF
car-file-filter = Журнал автомобиля
car-file-saved = Журнал сохранён: { $file }
car-file-opened = Журнал открыт: { $file }
car-file-not-logbook = Этот файл не является журналом автомобиля Radinus.
car-file-too-recent = Этот журнал создан в более новой версии Radinus: обновите Radinus, чтобы открыть его.
car-replace-question = Открытие этого журнала заменит журнал в окне. Продолжить?
car-sheet-history = Журнал
car-sheet-summary = Сводка

analysis-history-hint = Чем длиннее ваша история, тем лучше будет этот анализ: в идеале нужно не менее года операций.

# --- F48 — Разделить расход (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Разделить расход
window-sharing-title = Разделить расход
sharing-question = Кто сколько платит?
sharing-setup-title = Разделение
sharing-field-label = Название
sharing-label-hint = Например, «Ресторан 12/10» или «Поездка в Бретань 2027»: по нему называются файлы и отчёты.
sharing-field-total = Итого
sharing-total-hint = Если поле пустое, итог равен сумме статей и личных трат каждого.
sharing-field-rule = Правило
sharing-field-rounding = Округление
sharing-field-people = Участники
sharing-mode-whole = Одно правило для всего расхода
sharing-mode-item = Одно правило на статью
sharing-rule-equal = Равные доли
sharing-rule-parts = По частям
sharing-rule-percent = В процентах
sharing-rule-income = Пропорционально доходам
sharing-rounding-cent = До цента
sharing-rounding-euro = До целой единицы
sharing-round-euro = Округлять до целых единиц
sharing-hide-incomes = Скрыть доходы в отчётах и экспорте
sharing-people-title = Люди
sharing-people-hint = Одна строка на человека, один столбец на статью: отметьте, кто в чём участвует. Всё остальное необязательно. Если кто-то выходит, оставляя свой аванс: точная сумма, равная внесённой, и ни одной отметки.
sharing-add-person = Добавить человека
sharing-person-default = Человек { $number }
sharing-items-title = Статьи
sharing-items-hint = Только то, что касается не всех, например вино. Остальная часть итога идёт в общую статью.
sharing-add-item = Добавить статью
sharing-common = Общая
sharing-payments-title = Платежи
sharing-payments-hint = Кто заплатил, сколько и когда. Строка без суммы пока не учитывается.
sharing-payments-none = Пока нет платежей.
sharing-add-payment = Добавить платёж
sharing-result-title = Результат
sharing-balances-title = Состояние платежей
sharing-transfers-title = Предлагаемые переводы
sharing-delete = Удалить
sharing-delete-person-question = У этого человека есть платежи: удалить их вместе с ним?
sharing-disclaimer = Radinus предлагает вариант разделения: между друзьями каждый вправе договориться иначе.
sharing-column-person = Человек
sharing-column-household = Домохозяйство
sharing-column-income = Доход
sharing-column-parts = Части
sharing-column-percent = %
sharing-column-floor = Не менее
sharing-column-cap = Не более
sharing-column-fixed = Точная сумма
sharing-column-alone = Личные траты
sharing-column-gift = Отданный излишек
sharing-column-share = Доля
sharing-column-typed = Введённый %
sharing-column-constraint = Что сработало
sharing-column-due = К оплате
sharing-column-item = Статья
sharing-column-amount = Сумма
sharing-column-rule = Правило
sharing-column-participants = Участники
sharing-column-unit = Домохозяйство или человек
sharing-column-members = Члены
sharing-column-paid = Оплачено
sharing-column-balance = Баланс
sharing-column-date = Дата
sharing-column-who = Кто
sharing-column-label = Название
sharing-help-household = Люди из одного домохозяйства рассчитываются вместе: их платежи и то, что они должны, суммируются, и они получают одну выписку. Пример: «Семья Мартен» для родителей и детей.
sharing-help-income = Используется только правилом «Пропорционально доходам»: чем выше доход, тем больше доля. Введите месячный доход.
sharing-help-parts = Человек с 2 частями платит вдвое больше, чем человек с 1 частью. Пример: взрослый 1, ребёнок 0,5.
sharing-help-percent = Какую часть расхода платит человек. Проценты должны в сумме давать 100 %.
sharing-help-floor = Человек заплатит не менее этой суммы, даже если рассчитанная доля меньше. Разница уменьшает нагрузку на остальных.
sharing-help-cap = Человек никогда не заплатит больше этой суммы. То, что он не платит, ложится на остальных участников его статей.
sharing-help-fixed = Человек платит эту сумму, что бы ни случилось, а остальное делится между другими. Пример: кто-то выходит и оставляет аванс.
sharing-help-alone = То, что человек взял только для себя, например десерт или кофе. Он оплачивает это полностью, сверх своей доли.
sharing-help-gift = Если человек внёс больше своей доли: с отметкой излишек становится подарком группе; без отметки его возвращают.
sharing-help-items = Отметьте людей, которые участвуют в этой статье. Общая статья — это то, что остаётся от итога после вычета остальных статей.
sharing-help-due = Сколько человек должен всего: его доля в статьях, личные траты и округление.
sharing-help-share = Какой процент суммы к разделу составляет его доля.
sharing-help-typed = Процент, который вы ввели. Он может отличаться от фактической доли, если сработал минимум, максимум или точная сумма.
sharing-help-constraint = Показывает, изменилась ли доля человека из-за минимума, максимума, точной суммы или отданного излишка.
sharing-help-item = Только то, что касается не всех, например вино. Остальная часть итога идёт в общую статью и делится между теми, кто в ней отмечен.
sharing-help-rule = Как делится эта статья: на равные доли, по частям, в процентах или пропорционально доходам.
sharing-help-paid = Сколько уже оплачено домохозяйством или человеком, по введённым платежам.
sharing-help-balance = Сколько осталось оплатить или сколько внесено сверх доли. Пример: «Осталось оплатить: 61,54 €».
sharing-advice-equal = { $count ->
        [one] { $total } на одного человека.
        [few] { $total } ÷ { $count } человека = { $amount } с каждого.
        [many] { $total } ÷ { $count } человек = { $amount } с каждого.
       *[other] { $total } ÷ { $count } человека = { $amount } с каждого.
    }
sharing-advice-equal-varied = Поровну между участниками, с учётом ограничений и исключений.
sharing-advice-parts = Всего частей: { $parts }. Одна часть — { $amount }.
sharing-advice-parts-varied = Каждый платит по своим частям, с учётом ограничений и исключений. Пустое поле считается за 1 часть.
sharing-advice-percent-rest = До 100 % не хватает { $rest } %.
sharing-advice-percent-over = Проценты превышают 100 % на { $over } %.
sharing-advice-percent-ok = Проценты в сумме дают 100 %.
sharing-advice-percent-nobody = Проценты уже в сумме дают 100 %: { $count ->
        [one] { $names } ничего не заплатит.
        [few] { $names } ничего не заплатят.
        [many] { $names } ничего не заплатят.
       *[other] { $names } ничего не заплатят.
    }
sharing-advice-income = Каждый платит { $rate } % своего дохода.
sharing-advice-income-missing = Введите доход каждого, чтобы разделить пропорционально доходам.
sharing-advice-income-varied = Каждый платит одинаковую долю своего дохода, с учётом ограничений и исключений.
sharing-advice-empty = Введите сумму для разделения.
sharing-apply-advice = Взять предложенные значения
sharing-help-apply-advice = Заполняет пустые поля значениями, показанными серым. Уже заполненные поля не меняются.
sharing-from-incomes = Проценты по доходам
sharing-help-from-incomes = Заменяет проценты долей дохода каждого в общей сумме доходов. В сумме они дают 100 %.
sharing-reset-percents = Распределить всё заново
sharing-help-reset-percents = Стирает проценты и делит их поровну между всеми. Пригодится после добавления человека.
sharing-reset-percents-question = Стереть все проценты и распределить их поровну?
sharing-open = Открыть проект…
sharing-save = Сохранить проект…
sharing-pdf-distribution = Разделение (PDF)
sharing-pdf-payments = Состояние платежей (PDF)
sharing-pdf-statements = Индивидуальные выписки (PDF)…
sharing-statements-everyone = Все
sharing-excel = Экспорт в Excel
sharing-file-filter = Проект разделения
sharing-replace-question = Открытие этого проекта заменит то, что введено в окне. Продолжить?
sharing-file-saved = Проект сохранён: { $file }
sharing-file-opened = Проект открыт: { $file }
sharing-file-not-project = Этот файл не является проектом разделения расхода Radinus.
sharing-file-too-recent = Этот проект создан в более новой версии Radinus: обновите Radinus, чтобы открыть его.
sharing-file-failed = Не удалось прочитать или записать файл: { $reason }
sharing-statements-replace-question = { $count ->
        [one] В этой папке уже есть { $count } выписка. Заменить её?
        [few] В этой папке уже есть { $count } выписки. Заменить их?
        [many] В этой папке уже есть { $count } выписок. Заменить их?
       *[other] В этой папке уже есть { $count } выписки. Заменить их?
    }
sharing-statements-written = { $count ->
        [one] Записана { $count } выписка в «{ $folder }».
        [few] Записано { $count } выписки в «{ $folder }».
        [many] Записано { $count } выписок в «{ $folder }».
       *[other] Записано { $count } выписки в «{ $folder }».
    }
sharing-too-many-people = В разделении может быть не более 40 человек.
sharing-too-many-items = В разделении может быть не более 20 статей.
sharing-too-many-payments = В разделении может быть не более 400 платежей.
sharing-invalid-amount = Не удаётся прочитать эту сумму: нужно положительное число.
sharing-invalid-number = Не удаётся прочитать это число: нужно положительное число.
sharing-invalid-percent = Процент находится в пределах от 0 до 100.
sharing-invalid-date = Не удаётся прочитать эту дату.
sharing-name-missing = У каждого человека должно быть имя.
sharing-name-duplicate = «{ $name }» уже есть: различите их, например, по инициалу.
sharing-floor-above-cap = Минимум превышает максимум.
sharing-item-label-missing = У этой статьи нет названия.
sharing-items-above-total = Статьи и личные траты каждого превышают итог на { $amount }.
sharing-payment-person = Выберите, кто заплатил.
sharing-percent-total = Проценты в сумме дают { $sum } %: должно быть 100 %.
sharing-percent-total-item = «{ $item }»: проценты в сумме дают { $sum } %: должно быть 100 %.
sharing-item-nobody = В «{ $item }» никто не участвует.
sharing-item-no-weight = В «{ $item }» никто не учитывается: у всех участников ноль.
sharing-income-missing = Не указан доход: { $name }.
sharing-fixed-above = Точные суммы превышают сумму к разделу на { $amount }.
sharing-floors-above = Минимумы превышают сумму к разделу на { $amount }.
sharing-cap-alone = В «{ $item }» участвует только { $name }: максимум невозможно соблюсти.
sharing-caps-short = Максимумов не хватает, чтобы покрыть сумму: недостаёт { $amount }.
sharing-impossible = Эти условия нельзя выполнить все сразу: ослабьте минимум или максимум.
sharing-constraint-floor = Минимум достигнут
sharing-constraint-cap = Максимум достигнут
sharing-constraint-fixed = Точная сумма
sharing-constraint-gift = Отданный излишек
sharing-and = { $first } и { $last }
sharing-outside = Вне статей
sharing-alone = Личные траты
sharing-rounding = Округление
sharing-headline-empty = Добавьте людей, которые делят расход.
sharing-headline-no-amount = Введите итог или статьи для разделения.
sharing-headline-equal = { $total } к разделу: каждый платит { $amount }.
sharing-headline-range = { $total } к разделу: от { $min } до { $max } в зависимости от человека.
sharing-participants = { $count ->
        [0] Нет участников
        [one] { $count } участник
        [few] { $count } участника
        [many] { $count } участников
       *[other] { $count } участника
    }
sharing-balance-due = Осталось оплатить: { $amount }
sharing-balance-over = Внесено на { $amount } больше своей доли
sharing-balance-even = Рассчитано
sharing-summary-collected = Оплачено { $collected } из { $total }.
sharing-summary-owing = { $count ->
        [0] Все рассчитались.
        [one] Ещё { $count } человек должен { $amount }.
        [few] Ещё { $count } человека должны в сумме { $amount }.
        [many] Ещё { $count } человек должны в сумме { $amount }.
       *[other] Ещё { $count } человека должны в сумме { $amount }.
    }
sharing-remaining-outside = Осталось оплатить по расходу: { $amount }
sharing-remaining-reimburse = Вернуть (получатель: { $name }): { $amount }
sharing-all-settled = Всё улажено: никто никому ничего не должен.
sharing-transfer = { $from } переводит { $amount } на счёт { $to }
sharing-warning-over-paid = Платежи превышают расход на { $amount }: проверьте суммы.
sharing-note-income-zero = { $name } ничего не платит по статьям: { $items }, так как доход равен 0.
sharing-note-excluded = { $name } не участвует в «{ $item }»: соответствующая доля распределяется между остальными.
sharing-note-gift = Излишек от { $giver } уменьшает долю остальных: платежи { $name } теперь превышают положенную долю.
sharing-note-outside = { $name } платит { $amount } вне своих статей: эта сумма вычитается из того, что делят остальные.
sharing-note-keeper = Округлено до целых единиц: { $name } оставляет себе дробную часть, чтобы итог сошёлся точно.
sharing-report-distribution = Разделение
sharing-report-sharing = Разделение
sharing-report-who-pays = Кто сколько платит
sharing-report-items = Подробно по статьям
sharing-report-payments = Состояние платежей
sharing-report-as-of = Состояние на { $date }
sharing-report-balances = Доля, оплачено, баланс
sharing-report-statement = Выписка — { $name }
sharing-report-your-share = Ваша доля
sharing-statement-total = Итого для домохозяйства: { $amount }
sharing-statement-pay = Перевести (получатель: { $name }): { $amount }
sharing-statement-receive = Получить (от: { $name }): { $amount }
sharing-sheet-people = Люди
sharing-sheet-items = Статьи
sharing-sheet-result = Результат
sharing-sheet-payments = Платежи
sharing-sheet-balances = Возвраты
