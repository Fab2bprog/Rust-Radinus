# Radinus — core-side messages (Fluent), English.
# Filled in progressively as core modules that produce user-facing messages
# are implemented. See 08_ARCHITECTURE.md §2.1.

# ---------------------------------------------------------------------
# The name of this language, written in this language.
#
# Shown by the Settings menu and by the first-launch selector
# (01_CAHIER_DES_CHARGES.md §3.5). It lives here rather than in the code
# because this is the only place it can be right: adding a language means
# dropping in a file that knows how to name itself.
# ---------------------------------------------------------------------
language-name = English

nomenclature-unspecified = Unspecified

nomenclature-delete-confirm = Some operations (bank transactions) carry the '{ $label }' attribute. Do you confirm you want to reset that attribute?

nomenclature-delete-plain = Do you confirm the deletion of "{ $label }"?

nomenclature-delete-form-open = The form for "{ $label }" is open. Close it before deleting.

nomenclature-duplicate = There is already { $element } with the same name: "{ $label }".

# ---------------------------------------------------------------------
# What the windows say for themselves. Whole sentences, never assembled
# from words: an assembly that is right in French is wrong in English.
# ---------------------------------------------------------------------

ui-loading = Loading…
ui-editing = Editing.
ui-viewing = Viewing.
ui-modified-suffix = — modified
ui-label-required = A label is required.
ui-discard-question = Discard the changes?
ui-yes = Yes
ui-no = No
ui-select-record = Please select a record
ui-key-multiselect = CTRL
ui-multiselect-help = Info: use mouse click + [{ $modifier }] on the table to select several elements
ui-no-match = No label matches the filter.
ui-filter-placeholder = Filter the labels…
ui-column-label = LABEL
ui-field-label = Label
ui-field-budget-line = Budget line
ui-identifier = Identifier
ui-deletion-abandoned = Deletion abandoned: nothing was changed.
ui-unknown-nomenclature = Unknown nomenclature:

ui-title-filter = Filter
ui-title-create = Create
ui-title-update = Edit the selection
ui-title-delete = Delete the selection
ui-title-read = View the selection
ui-title-close = Close
ui-title-save = Save
ui-title-add = Add
ui-title-modify = Edit

ui-load-failed = Could not load:
ui-save-failed = Could not save:
ui-read-failed = Could not read:
ui-delete-failed = Could not delete:
ui-open-failed = Could not open:
ui-close-failed = Could not close:

# --- Sentences of each nomenclature ----------------------------------

nomenclature-identifier = { $kind ->
    [category] Category identifier
    [assignment] Assignment identifier
    [payment-mode] Payment mode identifier
    [payee] Payee identifier
    [project] Project identifier
    [budget-line] Budget line identifier
   *[bank] Bank identifier
}

nomenclature-none = { $kind ->
    [category] No category.
    [assignment] No assignment.
    [payment-mode] No payment mode.
    [payee] No payee.
    [project] No project.
    [budget-line] No budget line.
   *[bank] No bank.
}

nomenclature-nothing-to-show = { $kind ->
    [category] No category to show.
    [assignment] No assignment to show.
    [payment-mode] No payment mode to show.
    [payee] No payee to show.
    [project] No project to show.
    [budget-line] No budget line to show.
   *[bank] No bank to show.
}

nomenclature-gone = { $kind ->
    [category] This category no longer exists.
    [assignment] This assignment no longer exists.
    [payment-mode] This payment mode no longer exists.
    [payee] This payee no longer exists.
    [project] This project no longer exists.
    [budget-line] This budget line no longer exists.
   *[bank] This bank no longer exists.
}

nomenclature-fresh = { $kind ->
    [category] New category.
    [assignment] New assignment.
    [payment-mode] New payment mode.
    [payee] New payee.
    [project] New project.
    [budget-line] New budget line.
   *[bank] New bank.
}

nomenclature-created = { $kind ->
    [category] Category added.
    [assignment] Assignment added.
    [payment-mode] Payment mode added.
    [payee] Payee added.
    [project] Project added.
    [budget-line] Budget line added.
   *[bank] Bank added.
}

nomenclature-updated = { $kind ->
    [category] Category changed.
    [assignment] Assignment changed.
    [payment-mode] Payment mode changed.
    [payee] Payee changed.
    [project] Project changed.
    [budget-line] Budget line changed.
   *[bank] Bank changed.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 category deleted.
       *[other] { $count } categories deleted.
      }
    [assignment] { $count ->
        [one] 1 assignment deleted.
       *[other] { $count } assignments deleted.
      }
    [payment-mode] { $count ->
        [one] 1 payment mode deleted.
       *[other] { $count } payment modes deleted.
      }
    [payee] { $count ->
        [one] 1 payee deleted.
       *[other] { $count } payees deleted.
      }
    [project] { $count ->
        [one] 1 project deleted.
       *[other] { $count } projects deleted.
      }
    [budget-line] { $count ->
        [one] 1 budget line deleted.
       *[other] { $count } budget lines deleted.
      }
   *[bank] { $count ->
        [one] 1 bank deleted.
       *[other] { $count } banks deleted.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] There is already a category with the same name: "{ $label }".
    [assignment] There is already an assignment with the same name: "{ $label }".
    [payment-mode] There is already a payment mode with the same name: "{ $label }".
    [payee] There is already a payee with the same name: "{ $label }".
    [project] There is already a project with the same name: "{ $label }".
    [budget-line] There is already a budget line with the same name: "{ $label }".
   *[bank] There is already a bank with the same name: "{ $label }".
}

# --- Window titles ----------------------------------------------------

window-list-title = { $kind ->
    [category] Categories
    [assignment] Assignments
    [payment-mode] Payment modes
    [payee] Payees and merchants
    [project] Projects
    [budget-line] Budget lines
   *[bank] Banks
}

window-form-title = { $kind ->
    [category] Category
    [assignment] Assignment
    [payment-mode] Payment mode
    [payee] Payee
    [project] Project
    [budget-line] Budget line
   *[bank] Bank
}

# --- Menu bar ---------------------------------------------------------

menu-file = File
menu-file-import-statements = Import bank statements
menu-file-import-excel = Import an Excel file
menu-file-backup = Backup
menu-file-restore = Restore
menu-file-repair = Repair and optimise the database
menu-file-log = Show the log
menu-tools-password = Protect the database with a password
menu-file-disconnect = Disconnect from the current database
menu-file-quit = Quit

menu-accounts = Accounts
menu-accounts-manage = Manage bank accounts
menu-accounts-balances = See your account balances
menu-accounts-operations = Manage an account's operations
menu-accounts-quick-classify = Quick classification of operations
menu-accounts-recurring = Manage recurring operations
menu-accounts-transfer = Transfer an amount between two accounts
menu-accounts-checkbooks = Manage chequebooks

menu-statistics = Statistics
menu-statistics-balance-chart = Balance evolution chart
menu-statistics-balance-analysis = Balance evolution analysis
menu-statistics-by-category = Stats by category
menu-statistics-by-assignment = Stats by assignment
menu-statistics-by-budget-line = Stats by budget line
menu-statistics-by-payment-mode = Stats by payment mode
menu-statistics-by-payee = Stats by payee and merchant
menu-statistics-by-project = Stats by project
menu-statistics-by-verification = Stats by verification
menu-statistics-dashboard = Operations dashboard
menu-statistics-crossed-balance = Crossed balance

menu-budget = Budget
menu-budget-entry = Budget entry
menu-budget-control = Budget control

menu-nomenclatures = Nomenclatures
menu-nomenclature = { $kind ->
    [category] Categories
    [assignment] Assignments
    [payment-mode] Payment modes
    [payee] Payees and merchants
    [project] Projects
    [budget-line] Budget lines
   *[bank] Banks
}
menu-nomenclatures-templates = Operation templates

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Tools
menu-settings = Settings
menu-settings-about-author = About the author
menu-settings-about-radinus = About Radinus
menu-settings-licence = Licence

menu-misc = Miscellaneous
menu-misc-calculator = Calculator
menu-misc-website = Go to the Radinus website
menu-misc-database-folder = Open the database folder

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Open the database folder
database-folder-warning =
    This folder holds all your data. Renaming, moving or deleting a file in it can lose your accounts, corrupt them, or stop Radinus from working.
    Do you really want to open it?
menu-misc-application-folder = Open the application folder
menu-misc-attachments-folder = Open the folder holding the attachments
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Manage the attachments
window-attachments-manager-title = Manage the attachments
attachments-column-document = Document
attachments-column-size = Size
attachments-column-added = Added on
attachments-column-state = State
attachments-state-intact = Intact
attachments-state-altered = Changed since
attachments-state-missing = File missing
attachments-state-unknown = Cannot be checked
attachments-state-orphan = Orphan
attachments-no-operation = No operation
attachments-orphan-remove-question = This file is attached to no operation. Move it to the trash?
attachments-manager-help = Double-click a line to open the document.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Show the operation
attachments-reveal = Reveal in the file manager
attachments-manager-summary = { $count } attachments, { $size } in all.
attachments-disk-name = Name on disk: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Open the attachments folder
attachments-folder-warning =
    This folder holds the files you attached to your operations. Radinus stores them under a name of its own choosing: renaming, moving or deleting one does not detach it — the operation will still announce it, and it will no longer open.
    Do you really want to open it?

# --- Bank accounts — F04, F06, F07, F08 -------------------------------

window-accounts-title = Bank accounts
window-accounts-select-title = Accounts
window-balances-title = Your account balances
window-account-title = Account

accounts-none = No account.
accounts-nothing-to-show = No account to show.
accounts-gone = This account no longer exists.
accounts-fresh = New account.
accounts-created = Account added.
accounts-updated = Account changed.
accounts-deleted = { $count ->
    [one] 1 account deleted.
   *[other] { $count } accounts deleted.
}
accounts-duplicate-name = There is already an account with the same name: "{ $label }".
accounts-multiselect-help = Info: use mouse click + [{ $modifier }] on the table to select several accounts
accounts-select-question = Which bank accounts should the statistics be based on?

accounts-column-label = LABEL
accounts-column-bank = Bank
accounts-column-type = Account type
accounts-column-number = Account no.
accounts-column-account = Account
accounts-column-bank-balance = At the bank
accounts-column-real-balance = Real
accounts-column-final-balance = Final
accounts-total = TOTAL

accounts-delete-plain = Do you confirm the deletion of the account "{ $label }"?
accounts-delete-with-operations = The account "{ $label }" holds { $count } operations, which will be deleted with it. Do you confirm the deletion?
accounts-delete-form-open = The form for the account "{ $label }" is open. Close it before deleting.

account-group-bank = Account and bank
account-group-holder = Holder
account-group-rib = Bank details
account-group-activity = Activity
account-group-balances = Balances

account-field-label = Account title
account-field-bank = Bank
account-field-type = Account type
account-field-branch-address = Branch address
account-field-holder-name = Name
account-field-holder-address = Address
account-field-rib-bank = Bank code
account-field-rib-branch = Branch code
account-field-rib-number = Account number
account-field-rib-key = Check digits
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Opening date
account-field-closing-date = Closing date
account-field-closed = Closed
account-field-opening-pointed = Opening pointed balance
account-field-opening-committed = Opening committed balance
account-field-opening-planned = Opening planned balance

account-label-required = The account title is required.
account-iban-invalid = This IBAN is not valid: check its control digits.
account-control-line = Opening pointed balance ({ $opening }) + Total of operations ({ $operations }) = Current balance at the bank: { $balance }.

amount-not-readable = "{ $field }" does not hold a valid amount.

ui-thousands-separator = ,
ui-decimal-separator = .

# --- Operations list (F02) -------------------------------------------

window-operations-title = Operations of account: { $account }

operations-none = No operation in this period.
operations-bad-period = The bounds of the period are not valid dates.
operations-from = From
operations-to = To
operations-delete-confirm = { $count ->
    [one] Do you confirm the deletion of this operation?
   *[other] Do you confirm the deletion of these { $count } lines? The sub-operations of the selected operations go with them.
}
operations-deleted = { $count ->
    [one] 1 operation deleted.
   *[other] { $count } operations deleted.
}
operations-selection-total = Total of the selected operations: { $amount }

operations-column-date = Date
operations-column-clearing-date = Cleared on
operations-column-status = Operation status
operation-status-pointed = Cleared
operation-status-committed = Committed
operation-status-planned = Planned
operations-column-verification = Verification
operation-verification-to-verify = To verify
operation-verification-verified = Verified
operation-verification-doubtful = Doubtful
operation-verification-disputed = Disputed
operations-column-label = Label
operations-column-category = Category
operations-column-assignment = Assignment
operations-column-payment-mode = Mode
operations-column-payee = Payee
operations-column-project = Projects
operations-column-month = Month
operations-column-debit = Debit
operations-column-credit = Credit
operations-column-balance = Balance
operations-column-comments = Comments
operations-column-attachments = Attachments
operations-column-check = Cheque no.

operations-foot-debit = Debit:
operations-foot-credit = Credit:
operations-foot-total = Total:
operations-foot-bank = At the bank:
operations-foot-real = Real:
operations-foot-final = Final:

operations-menu-export = Export
operations-menu-print = Print
operations-menu-filter = Filter
operations-menu-period = Period
operations-menu-misc = More

operations-title-point = Clear the selection
operations-title-sub = Add a sub-operation
operations-title-duplicate = Duplicate the selection
operations-not-yet = This window does not exist yet: it comes later in the plan.

accounts-choose-question = Which account do you want to work on?
ui-title-select = Choose the selection

month-january = January
month-february = February
month-march = March
month-april = April
month-may = May
month-june = June
month-july = July
month-august = August
month-september = September
month-october = October
month-november = November
month-december = December

operations-period-year = This year

# --- The Period menu of F02 -------------------------------------------

period-all = All
period-last-year = Last year
period-this-year = This year
period-whole-year = The whole year
period-last-month = Last month
period-this-month = This month
period-last-week = Last week
period-this-week = This week
period-yesterday = Yesterday
period-today = Today

# --- The Filter menu of F02 -------------------------------------------

filter-all = All operations
filter-pointed = Cleared operations only
filter-committed = Committed operations only
filter-planned = Planned operations only
filter-by-status = Status filter
filter-by-verification = Verification filter
filter-show-all = Show all

# --- Operation form (F03) ---------------------------------------------

window-operation-title = Operation on account: { $account }

operation-menu-identification = Identification
operation-menu-options = Options
operation-fitid-edit = Edit the FITID…
operation-fitid-delete = Delete the FITID
operation-fitid-question = FITID of this transaction:
operation-fitid-delete-question = Delete the FITID of this transaction?
operation-fitid-written = FITID saved.
operation-fitid-removed = FITID deleted.

operation-group-identification = Identifying the operation
operation-group-amount = Amount of the operation
operation-group-status = Status of the operation
operation-group-classification = Classifying the operation for the statistics
operation-group-check = Cheque tied to the operation
operation-group-comment = Comment

operation-field-label = Label
operation-field-reference = Payment reference
operation-field-date = Date
operation-field-direction = Operation type:
operation-field-amount = Amount
operation-field-status = Operation status
operation-field-clearing-date = Clearing date
operation-field-verification = Verification
operation-field-category = Category
operation-field-assignment = Assignment
operation-field-payment-mode = Mode
operation-field-payee = Payee
operation-field-project = Project
operation-field-check = Tied cheque

operation-direction-debit = Debit
operation-direction-credit = Credit

operation-check-info = Info.
operation-check-link = Tie
operation-check-unlink = Untie

operation-fresh = New operation.
operation-created = Operation added.
operation-updated = Operation changed.
operation-gone = This operation no longer exists.
operation-nothing-to-show = No operation to show.
operation-label-required = The label of the operation is required.
operation-date-required = The date of the operation is required.
operation-clearing-date-invalid = The clearing date is not a valid date.
operation-clearing-date-required = A pointed operation must carry a clearing date.
operation-clearing-date-question =
    A pointed operation must carry a clearing date.
    Do you want to save with the operation's own date, { $date }?
operation-is-a-sub = This line is a sub-operation: it is changed from its own form.
operation-delete-form-open = The form of “{ $label }” is open. Close it before deleting.

operation-attachments = { $count ->
    [0] No attachment
    [one] 1 attachment
   *[other] { $count } attachments
}

operation-title-comment = Comment on the operation
operation-title-sub = Create a sub-operation
operation-title-template = Operation templates
operation-title-attachment = Attachments

# --- Sub-operation form (F04) -----------------------------------------

window-sub-operation-title = Sub-operation

sub-operation-group-amount = Amount of the sub-operation
sub-operation-field-label = Name
sub-operation-fresh = New sub-operation.
sub-operation-created = Sub-operation added.
sub-operation-updated = Sub-operation changed.
sub-operation-gone = This sub-operation no longer exists.
sub-operation-nothing-to-show = No sub-operation to show.
sub-operation-label-required = The name of the sub-operation is required.
sub-operation-parent-gone = The operation to split no longer exists.
sub-operation-is-the-complement = This is the Complement: what is left to split. Renaming it or changing its amount makes it an ordinary sub-operation.
sub-operation-of = Splitting “{ $label }” ({ $amount })

operations-pointed = { $count ->
    [0] No operation to clear: the selection is already cleared.
    [one] 1 operation cleared.
   *[other] { $count } operations cleared.
}
operations-select-one = Please select a single operation.

# --- Duplicating, and showing the sub-operations (F02) ----------------

operation-copy = A copy to be saved: nothing has been created yet.
operations-show-children = Show every sub-operation
operations-hide-children = Hide every sub-operation
operations-recurring-from = Create a recurring operation from this operation

# --- Second confirmation of a grave deletion --------------------------

accounts-delete-second-question = This deletion is final and takes the whole history of the account with it. Type “{ $word }” to confirm it.

# --- F20 — Statistics by category -------------------------------------

# --- F20-F24 — The six statistics --------------------------------------

window-statistics-title = { $kind ->
    [assignment] Statistics by assignment
    [budget-line] Statistics by budget line
    [payment-mode] Statistics by payment mode
    [payee] Statistics by payee
    [project] Statistics by project
    [verification] Statistics by verification
   *[category] Statistics by category
}

statistics-axis-column = { $kind ->
    [assignment] Assignment
    [budget-line] Budget line
    [payment-mode] Payment mode
    [payee] Payee
    [project] Project
    [verification] Verification
   *[category] Category
}

statistics-unclassified = { $kind ->
    [assignment] No assignment
    [budget-line] No budget line
    [payment-mode] No payment mode
    [payee] No payee
    [project] No project
    [verification] To verify
   *[category] No category
}
statistics-total = Total
statistics-sum = Sum
statistics-cumulative = Running total

statistics-switch-pointed = Cleared operations { $state }
statistics-switch-committed = Committed operations { $state }
statistics-switch-planned = Planned operations { $state }
statistics-switch-debits = Debit amounts { $state }
statistics-switch-credits = Credit amounts { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = No account was chosen: the statistic covers nothing.
statistics-no-data = No operation this year for the chosen accounts.
statistics-detail-empty = Click a figure to see the operations behind it.
statistics-detail-none = No operation behind this cell.
statistics-accounts = { $count ->
    [one] 1 account
   *[other] { $count } accounts
}
statistics-year-next = Next year
statistics-year-previous = Previous year

statistics-column-date = Date
statistics-column-clearing-date = Cleared on
statistics-column-label = Label
statistics-column-amount = Amount
statistics-column-comments = Comments

accounts-stats-multiselect-help = Tip: use mouse click + [{ $modifier }] on the table to choose several accounts

statistics-year-question = Which year do you want to work on? Radinus goes from { $first } to { $last }.
statistics-year-choose = Choose the year

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Crossed balance
crossed-balance-window-name = Crossed balance
crossed-balance-column = Category
crossed-balance-no-data = No operation in this month for the chosen accounts.
crossed-balance-month-question = Which month do you want to work on? A number between { $first } and { $last }.
crossed-balance-month-choose = Choose the month
crossed-balance-next = Next month
crossed-balance-previous = Previous month

# --- Exporting a table (right click) ----------------------------------

export-to-excel = Export to Excel (.xlsx)
export-to-word = Export to Word (.docx)
export-to-tsv = Export to TSV (.tsv)
export-to-ini = Export to INI (.ini)
export-to-toml = Export to TOML (.toml)
export-to-yaml = Export to YAML (.yaml)
export-to-ofx = Export to OFX (.ofx)
export-to-qif = Export to QIF (.qif)
export-to-ods = Export to LibreOffice Calc (.ods)
export-to-csv = Export to CSV (.csv)
export-to-xml = Export to XML (.xml)
export-menu = Export
export-to = Export to
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Copy cell
copy-rows = Copy selected rows
copy-failed = Copying to the clipboard failed.
export-all-years-excel = Export every year to Excel
export-all-years-ods = Export every year to LibreOffice Calc
export-all-months-excel = Export every month of the shown year to Excel
export-all-months-ods = Export every month of the shown year to LibreOffice Calc
export-no-year = No year holds any operation: there is nothing to export.
export-years-done = { $years } years exported to “{ $file }”.
export-to-json = Export to JSON (.json)
export-done = Exported to “{ $file }”.
export-failed = Export failed: { $reason }
export-nothing = There is nothing to export.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Statistics by assignment
    [budget-line] Statistics by budget line
    [payment-mode] Statistics by payment mode
    [payee] Statistics by payee
    [project] Statistics by project
    [verification] Statistics by verification
   *[category] Statistics by category
}
statistics-detail-name = Statistics detail

# --- F19 — Dashboard ---------------------------------------------------

window-dashboard-title = Dashboard
dashboard-menu-period = Period
dashboard-menu-misc = Misc
dashboard-from = From:
dashboard-to = To:
dashboard-switch-pointed = Include cleared operations
dashboard-switch-committed = Include committed operations
dashboard-switch-planned = Include planned operations
dashboard-spending = Spending
dashboard-earning = Earnings
dashboard-debits = Sum of debited operations
dashboard-credits = Sum of credited operations
dashboard-balance = Balance
dashboard-unclassified = No budget line
dashboard-nothing = No operation over this period.
dashboard-no-account = No account was chosen: the dashboard is about nothing.
dashboard-enlarge = Open large

# --- F25 — Balance evolution -------------------------------------------

window-curve-title = Balance evolution
curve-heading = Balance evolution, day by day
curve-menu-period = Period
curve-total = Total
curve-from = From:
curve-to = To:
curve-axis-balance = balance
curve-nothing = No account was chosen: there is no curve to draw.
curve-empty = No operation over this period.

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Balance evolution analysis
analysis-heading = Balance evolution analysis
analysis-hint = Drag across the chart, mouse button held down, to see the operations of that period.
analysis-zone = Zone:
analysis-opening = Opening balance:
analysis-closing = Closing balance:
analysis-variation = Change:
analysis-detail-name = Balance analysis
analysis-detail-none = No operation in this zone.

# --- F05 — Quick classification of operations --------------------------

window-quick-classification-title = Quick classification of operations: { $account }
quick-dates-title = Start and end dates of the list.
quick-from = From
quick-to = To
quick-menu-period = Period
quick-change-title = Change the selection's characteristics to:
quick-check-category = Category
quick-check-assignment = Assignment
quick-check-payment-mode = Mode
quick-check-payee = Payee
quick-check-project = Project
quick-check-status = Status
quick-check-verification = Verification
quick-column-date = Date
quick-column-label = Label
quick-column-amount = Amount
quick-column-category = Category
quick-column-assignment = Assignment
quick-column-payment-mode = Payment mode
quick-column-payee = Payee
quick-column-project = Projects
quick-column-status = Status
quick-column-verification = Verification
quick-multiselect-help = Tip: mouse click + [{ $modifier }] on the table selects several rows
quick-none = No operation over this period.
quick-select-lines = Select at least one row, and tick at least one characteristic.
quick-applied = { $count ->
    [0] Nothing changed: those rows already carried that classification.
    [one] 1 row classified. Nothing is saved yet.
   *[other] { $count } rows classified. Nothing is saved yet.
}
quick-pending = { $count ->
    [0] No pending change.
    [one] 1 row changed, not saved.
   *[other] { $count } rows changed, not saved.
}
quick-save-question = { $count ->
    [one] Save the pending change?
   *[other] Save the { $count } pending changes?
}
quick-saved = { $count ->
    [0] There was nothing to save.
    [one] 1 row saved.
   *[other] { $count } rows saved.
}
quick-nothing-to-save = No pending change.
quick-leave-question = Some changes are not saved. What do you want to do?
quick-leave-save = Save and leave
quick-leave-discard = Discard and leave
quick-leave-stay = Stay
quick-title-apply = Apply to the selected rows ( in memory )
quick-title-save = Save to disk

# --- F17 / F18 — Importing a bank statement ----------------------------

window-statement-import-title = Importing bank statements: { $account }
window-statement-form-title = Reconcile a transaction (adds an operation to your account's history)
statement-menu-filter = Filter
statement-filter-all = Every line
statement-filter-pending = To be added
statement-filter-known = Already added
statement-column-id = ID
statement-column-reconciled = Added
statement-column-fitid = FITID
statement-column-date = Date
statement-column-label = Label
statement-column-debit = Debit
statement-column-credit = Credit
statement-account = Account
statement-file = File
statement-difference = Difference
statement-none = No statement is open: click the yellow folder to choose a file.
statement-empty = This statement holds no operation.
statement-no-match = No line matches the filter.
statement-help = Tip: mouse click + [{ $modifier }] on the table selects several lines
statement-choose-account = This file holds several accounts. Which one do you want to import?
statement-select-line = Select at least one line of the statement.
statement-title-open = Open a statement file (OFX, QIF, CSV)
statement-title-info = About the open file
statement-title-integrate = Add the selection to the account
statement-title-validate = Add this operation to the account
statement-duplicate = Duplicate warning: this transaction seems to be in your account already (its Financial Institution Transaction ID exists)
statement-no-fitid = Warning: this file gives no identifier (FITID) for this line. A duplicate could not be detected.
statement-loaded = { $count ->
    [0] This file holds no operation for this account.
   *[other] { $count } lines read, { $known } of which are already in your account.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } lines read; none looks like an operation already in your account.
    [one] { $count } lines read, one of which looks like an operation already in your account (same date, same label, same amount).
   *[other] { $count } lines read, { $alike } of which look like operations already in your account (same date, same label, same amount).
}
statement-loaded-also-alike = { $alike ->
    [one] One other looks like an operation already there (same date, same label, same amount).
   *[other] { $alike } others look like operations already there (same date, same label, same amount).
}
statement-integrated = { $count ->
    [0] Nothing was added: those lines are in your account already.
    [one] 1 operation added.
   *[other] { $count } operations added.
}
statement-mass-question =
    Are you sure you want to add several operations to your account at once?
    You will have to classify and characterise them afterwards for the statistics to be precise
    For Ofx files: if duplicates are found you will have to choose what the program does
    For other file types: watch out for duplicates yourself
statement-duplicate-question =
    The transaction: { $date } { $label }: { $amount }
    seems to be in your account's history already.
    Do you really want to add it?
statement-already-reconciled = You have already added this transaction: it is in your account's history
statement-integration-report =
    Import finished.
    Records added: { $added }
    Records skipped: { $ignored }
statement-integration-abandoned =
    Import abandoned!
    Records added: { $added }
    Records skipped: { $ignored }
statement-yes = Yes
statement-no = No
statement-cancel = Cancel
statement-file-info =
    Account in the file: { $account }
    Period: { $from } to { $to }
    Balance stated by the bank: { $balance }
statement-qif-question = Nothing in this file says whether the date “{ $date }” is written day/month or month/day. It means:
statement-qif-day-month = Day { $day }, month { $month } (day/month)
statement-qif-month-day = Day { $day }, month { $month } (month/day)
statement-qif-dates-mixed = This file writes its dates in two ways: “{ $first }” reads day/month, “{ $second }” month/day. It is not imported, so that no date is wrong.
statement-qif-amounts-mixed = This file writes its amounts in two ways: “{ $first }” with a point, “{ $second }” with a comma. It is not imported, so that no amount is wrong.
statement-qif-opening = Opening balance of { $amount } on { $date }: it is not a transaction, it is not imported.
statement-qif-opening-undated = Opening balance of { $amount }: it is not a transaction, it is not imported.
statement-qif-suspect = Line { $rank }, “{ $label }” ({ $amount }), looks like an opening balance: check it before integrating it.
statement-qif-rejected = { $count ->
    [one] One unreadable line is not imported: { $lines }.
   *[other] { $count } unreadable lines are not imported: { $lines }.
}
statement-qif-reason-date = date
statement-qif-reason-amount = amount
statement-qif-reason-differ = conflicting amounts
statement-qif-no-account = This account is no longer in the file: open the file again.
statement-balance-unknown = not given in the file
statement-group-identification = Identifying the operation
statement-group-amount = Amount of the operation
statement-group-classification = Classification, for the statistics
statement-group-status = Status of the operation
statement-field-date = Date
statement-field-label = Label
statement-field-type = Operation type
statement-field-amount = Amount
statement-field-mode = Payment mode
statement-field-category = Category
statement-field-assignment = Assignment
statement-field-payee = Payee
statement-field-project = Project
statement-field-status = Status
statement-field-clearing = Clearing date

# --- Cutting a CSV statement into fields --------------------------------

window-csv-statement-title = Importing data from a csv file
csv-preview-title = The file as it is:
csv-settings-title = How to cut the file into fields:
csv-extraction-title = What those settings produce ( check that the data makes sense ):
csv-column-line = Line no.
csv-column-content = Content
csv-header-lines = Header lines to skip
csv-separator = Columns are separated by:
csv-date-at = Date field position
csv-label-at = Label field position
csv-debit-at = Debit amount position
csv-credit-at = Credit amount position
csv-test = Test the settings
csv-separator-semicolon = Semicolon   ;
csv-separator-comma = Comma   ,
csv-separator-tab = Tab
csv-separator-pipe = Pipe   |
csv-separator-space = Space
csv-help = Set, test, look: only lines carrying a readable date and amount will be imported.
csv-none = The file is empty.
csv-not-tested = Click "Test the settings" to see what the cutting produces.
csv-extraction = { $count ->
    [0] The settings produce no line at all: check the number of header lines and the separator.
   *[other] { $count } lines cut: { $valid } will be imported, { $dropped } left out for want of a readable date or amount.
}
csv-nothing-valid = No line carries both a readable date and a readable amount: there is nothing to import. Check the number of header lines, the separator and the field positions.
csv-title-validate = Send the valid lines to the import window

# --- F13 / F31 / F14 / F12 — Chequebooks and cheques (phase 9) ----------
# Ported from the author's five WinDev sources and seven captures, supplied
# on 28/07/2026.

window-chequebooks-title = Chequebooks
window-chequebook-title = Chequebook settings
window-cheques-title = Chequebook contents: list of cheques.
window-cheque-title = Cheque
window-cheque-operations-title = Operations.

chequebooks-column-reference = REFERENCE
chequebooks-column-date = Date
chequebooks-column-account = Account
chequebooks-column-account-number = Account no.
chequebooks-column-comments = Comments
chequebooks-none = No chequebook has been recorded.
chequebooks-nothing-to-show = No chequebook matches this search.
chequebooks-title-composition = Show the contents of the chequebook
chequebooks-delete-question = Operations (bank transactions) linked to this chequebook were found. Do you confirm that you want to delete this chequebook?
chequebooks-deleted = { $count ->
    [one] One chequebook deleted.
   *[other] { $count } chequebooks deleted.
}
chequebooks-gone = This chequebook no longer exists.
chequebooks-created = Chequebook saved, with all its cheques.
chequebooks-updated = Chequebook updated.
chequebook-refusal-duplicate = A chequebook with the same reference already exists
chequebook-refusal-reference-required = A reference is required
chequebook-refusal-number-too-big = The first and/or last cheque numbers are too large (maximum value 999 999 999)
chequebook-refusal-date = Please enter a valid reception date
chequebook-refusal-numbers-required = Please fill in the first and last cheque numbers
chequebook-refusal-order = The first cheque number must be lower than the last cheque number
chequebook-refusal-account = You must select the bank account this chequebook belongs to
chequebook-refusal-too-many = Maximum number of cheques for one chequebook: 1000, limit reached
chequebook-creation-question =
    Creating the chequebook with the following characteristics:
    - Number of cheques to generate:{ $count }
    - Cheques numbered from { $first } to { $last }
    Warning: this data cannot be changed after creation!

chequebook-field-id = Chequebook identifier
chequebook-field-reference = Reference
chequebook-field-received = Made or received on
chequebook-field-first = First cheque number
chequebook-field-last = Last cheque number
chequebook-field-quantity = Number of cheques
chequebook-field-account = Link to bank account:
chequebook-field-comments = Comments
chequebook-locked = The cheques of this book already exist: its numbering can no longer be changed.
chequebook-account-missing = The bank account this chequebook was linked to is missing or has been deleted!

cheques-column-number = Cheque no.
cheques-column-date = Date
cheques-column-place = Place
cheques-column-payee = Payee
cheques-column-amount = Amount
cheques-column-status = Status
cheques-column-comments = Comments
cheques-column-operations = Linked operations
cheques-none = This chequebook holds no cheque.
cheques-nothing-to-show = No cheque matches this search.
cheques-help = Click the Status cell to change it; the magnifier shows the linked operations, the link attaches one.
cheques-title-linked = Show the operations already linked to this cheque
cheques-title-link = Link an operation to this cheque
cheques-status-changed = Cheque status changed.

cheque-field-id = Cheque identifier
cheque-field-number = Cheque number
cheque-field-issued = Issue date
cheque-field-place = Issue place
cheque-field-payee = Payee
cheque-field-amount = Amount
cheque-field-comments = Comments
cheque-field-status = Cheque status
cheque-gone = This cheque no longer exists.
cheque-updated = Cheque updated.

cheque-operations-linked-title = Operations already linked to this cheque.
cheque-operations-choose-title = Choose an operation to link to the cheque
cheque-operations-column-account = Account
cheque-operations-column-label = Name
cheque-operations-column-date = Date
cheque-operations-column-clearing = Clearing date
cheque-operations-column-amount = Amount
cheque-operations-column-cheque = Linked cheque
cheque-operations-none-linked = No operation is linked to this cheque.
cheque-operations-none = This account holds no operation.
cheque-operations-nothing-to-show = No operation matches this search.
cheque-operations-help = Operations in bold already carry a cheque.
cheque-operations-linked-help = The red cross detaches the cheque from the operation: nothing is deleted.
cheque-operations-linked = Operation linked to the cheque.
cheque-operations-dissociated = Cheque detached from the operation.
cheque-operations-menu-filter = Filter
cheque-title-associate = Link this operation to the cheque
cheque-title-dissociate = Detach the cheque from this operation

chequebooks-select-question = Choose the chequebook
cheques-select-question = Choose the cheque to link to the operation
operation-check-save-first = Save the operation first: a cheque is linked to an operation that exists.
operation-check-none = This operation carries no cheque.

# --- F36 / F37 — Operation templates (phase 10) -------------------------

window-operation-templates-title = Operation templates
window-operation-template-title = Operation template

operation-templates-none = No operation template has been recorded.
operation-templates-nothing-to-show = No template matches this search.
operation-templates-select-question = Choose the template to apply
operation-templates-delete-question = Do you confirm the deletion of the selected templates?
operation-templates-deleted = { $count ->
    [one] One template deleted.
   *[other] { $count } templates deleted.
}
operation-template-gone = This template no longer exists.
operation-template-fresh = New template.
operation-template-created = Template saved.
operation-template-updated = Template updated.
operation-template-label-required = A name is required
operation-template-duplicate = A template with the same name already exists

operation-template-field-id = Template identifier
operation-template-group-name = Default name of the future operation once the template is applied
operation-template-field-label = Name
operation-template-group-amount = Default amount of the operation predefined in this template
operation-template-field-direction = Operation type
operation-template-field-amount = Amount
operation-template-group-status = Default status of the operation in this template
operation-template-field-status = Operation status
operation-template-group-classification = Template information for statistics classification
operation-template-field-category = Category
operation-template-field-assignment = Assignment
operation-template-field-mode = Mode
operation-template-field-payee = Payee
operation-template-field-project = Project

operation-template-question = What do you want to do with operation templates?
operation-template-apply = Apply a template
operation-template-save-as = Save as a template
operation-template-applied = Template applied. Validate the form to save it.
operation-template-saved-as = Operation saved as a template.
operation-template-needs-label = Give the operation a name before making a template of it.

# --- F26 / F27 — Budget (phase 11) --------------------------------------

window-budget-entry-title = Budget entry: expenses(-) and income(+) planned over a year
window-budget-control-title = Budget control

budget-column-line = Budget line
budget-none = No budget line has been recorded: the budget is entered per line.
budget-planned = Planned
budget-actual = Actual
budget-sum = Sum
budget-cumulative = Running total
budget-total = Total
budget-sign-warning = You must enter expenses with a negative sign and planned income with positive amounts
budget-entry-help = Type the amounts into the cells, then save.
budget-saved = Budget saved.
budget-nothing-changed = Nothing to save.
budget-discard-question = Discard the budget changes?

budget-menu-display = Display
budget-display-money = Values
budget-display-percent = Percentages
budget-control-help = Green: at least as good as planned. Red: worse.

# --- F09 — Transfer between two accounts (phase 12) ----------------------

window-transfer-title = Transfer an amount between two accounts

transfer-group-source = Debit the amount from this source account
transfer-group-target = Credit the amount to this destination account
transfer-group-description = Operation details
transfer-group-nomenclature = Classification
transfer-group-amount = Amount to transfer
transfer-field-source = Source account
transfer-field-target = Destination account
transfer-field-label = Label
transfer-field-reference = Payment reference
transfer-field-date = Date
transfer-field-status = Operation status
transfer-field-clearing = Clearing date
transfer-field-category = Category
transfer-field-mode = Payment mode
transfer-field-assignment = Assignment
transfer-field-payee = Payee / merchant
transfer-field-project = Project
transfer-field-amount = Amount

# Le seul bouton des panneaux qui annoncent au lieu de demander.
ui-ok = OK
transfer-help = Choose the two accounts: their balances appear here.
transfer-title-validate = Make the transfer
transfer-balances = { $account } — Bank: { $bank } · Real: { $real } · Final: { $final }
transfer-done = Transfer done. { $amount } from account { $source } to account { $target }, on { $date }.

transfer-refusal-accounts-required = Choose the source account and the destination account
transfer-refusal-same-account = The source and destination accounts cannot be the same: a transfer goes from one account to another
transfer-refusal-account-gone = One of the two accounts no longer exists
transfer-refusal-label-required = The label is required
transfer-refusal-date-required = The date is required
transfer-refusal-amount = The amount to transfer must be strictly positive

# ---------------------------------------------------------------------------
# Phase 13 — importing an Excel sheet (F34, F35, data association).
# ---------------------------------------------------------------------------

window-excel-import-title = Excel sheet import [ Step 1/3 ]: defining the capture area
window-excel-fields-title = Excel sheet import [ Step 2/3 ]: field mapping
window-excel-association-title = Excel sheet import: data association

excel-backup-question = An Excel sheet is made by hand: it may hold dates that are valid but wrong, amounts in the right format with the wrong sign — and no check can see that. The import will write those lines into your account. Would you like to back up your data before starting?

excel-group-file = 1 - Choose the Excel file to import
excel-pick = Choose the Excel file
excel-sheet = Workbook sheet:
excel-group-header = 2 - Define: cell coordinates of the header row where the column names are written.
excel-header-row = Number of the first row holding the column names
excel-first-column = Header start column ( leftmost column ):
excel-column-count = Number of columns in the table
excel-group-rows = 3 - Define: first and last row numbers of the list holding the table data ( below the header, not including it )
excel-first-data-row = First row holding data
excel-last-data-row = Last row holding data:
excel-group-shape = 4 - Define: how your file writes amounts
excel-shape-single = One single signed amount column ( expenses negative )
excel-shape-debit-credit = Two separate columns: a Debit column and a Credit column
excel-shape-note = In two-column mode, the sign written in the Debit column is ignored: a debit always takes money out, whether it reads "-50" or "50".
excel-group-test = 5 - Test render: look at what your settings capture
excel-test = Test the settings you defined in steps 2, 3 and 4.
excel-test-note = Note: the header names and the table content below must match those of your Excel table. The capture area must not spill outside the table.

excel-help = Go down the five groups in order, then test: you can only move to step 2 once you have looked at what the area captures.
excel-no-file = Choose the Excel file to import first.
excel-not-tested = Settings changed: run the test render again before validating.
excel-tested = Area captured: { $rows } rows, { $columns } columns. Check that the table below looks like your sheet.
excel-empty-capture = The area you declared captures no row at all: check the row and column numbers.
excel-title-next = Go to the next step
excel-into-account = Importing into account { $account }.

excel-tab-links = Field links
excel-tab-settings = Import settings
excel-column-excel = Excel_Header
excel-column-radinus = Radinus_Field
excel-links-help = Facing each column of your sheet, say which Radinus field it feeds. Columns left at [IGNORE] are not imported.
excel-group-category = Categories with no match
excel-group-payment-mode = Payment modes with no match
excel-group-assignment = Assignments with no match
excel-policy-create = { $kind ->
    [payment-mode] Automatically create the missing payment modes
    [assignment] Automatically create the missing assignments
   *[category] Automatically create the missing categories
}
excel-policy-ask = { $kind ->
    [payment-mode] Ask for each missing payment mode where to move the data
    [assignment] Ask for each missing assignment where to move the data
   *[category] Ask for each missing category where to move the data
}
excel-policy-blank = { $kind ->
    [payment-mode] Leave the payment mode blank
    [assignment] Leave the assignment blank
   *[category] Leave the category blank
}
excel-policy-default = { $kind ->
    [payment-mode] Move the missing payment modes into a default payment mode
    [assignment] Move the missing assignments into a default assignment
   *[category] Move the missing categories into a default category
}
excel-define-destination = Set destination
excel-not-linked = { $kind ->
    [payment-mode] No column feeds the payment mode: this setting does not apply.
    [assignment] No column feeds the assignment: this setting does not apply.
   *[category] No column feeds the category: this setting does not apply.
}
excel-fields-help = Set the field links, then the three policies, before starting the import.
excel-title-import = Start the import

excel-refusal-required = The Date, Libelle and Montant fields must point at Excel columns
excel-refusal-column-twice = Different Radinus fields point at the same Excel column: a column can feed only one field
excel-refusal-field-twice = The same Radinus field is linked to two Excel columns: it can only have one
excel-refusal-ask-unset = { $kind ->
    [payment-mode] You chose to be asked where to move unknown payment modes: press "Set destination" before starting the import.
    [assignment] You chose to be asked where to move unknown assignments: press "Set destination" before starting the import.
   *[category] You chose to be asked where to move unknown categories: press "Set destination" before starting the import.
}

excel-column-data = Excel_Data
excel-column-destination = { $kind ->
    [payment-mode] PaymentMode_Radinus
    [assignment] Assignment_Radinus
   *[category] Category_Radinus
}
excel-association-help = Facing each value from your sheet, choose the Radinus one it should be filed under. A line left empty stays unclassified.
excel-association-none = No unknown value: everything your sheet carries already exists in Radinus.

excel-imported = Import finished: { $count } operations written, { $refused } lines refused, { $created } nomenclature values created.
excel-report-title = Import report
excel-column-row = Excel row
excel-column-content = Content
excel-column-reason = Reason for refusal
excel-nothing-refused = Every line of your sheet went in: nothing refused.

excel-refused-date = Date missing or unreadable
excel-refused-amount = Amount missing or unreadable
excel-refused-amount-both = An amount in the Debit column and another in the Credit column: no way to choose
excel-refused-amount-missing = Neither debit nor credit on this line

# ---------------------------------------------------------------------------
# Phase 16 — recurring operations (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = List of recurring operations
window-recurring-form-title = Rule defining the generation of a recurring operation
window-recurring-calendar-title = Proposed calendar of operations to insert into your accounts

recurring-column-label = LABEL
recurring-none = No recurring rule recorded.
recurring-help = Choose a rule, then the calendar to see the occurrences it proposes.
recurring-title-calendar = Propose the calendar of occurrences
recurring-deleted = { $count ->
    [0] No rule deleted.
    [one] One rule deleted. Its operations stay in the account.
   *[other] { $count } rules deleted. Their operations stay in the accounts.
}
recurring-gone = This rule no longer exists.
recurring-delete-question = Delete the selected rules? The operations they already inserted will stay in your accounts.

recurring-group-identity = Identification and account concerned
recurring-group-nomenclature = Nomenclature
recurring-group-amount = The operation's amount
recurring-group-period = The period
recurring-group-ending = How the period ends
recurring-group-produced = About operations already inserted ( for consultation only )

recurring-field-id = Operation identifier
recurring-field-account = Target account
recurring-field-label = Label
recurring-field-category = Category
recurring-field-mode = Payment mode
recurring-field-assignment = Assignment
recurring-field-payee = Payees / merchants
recurring-field-project = Project
recurring-field-direction = Operation type
recurring-field-amount = Amount
recurring-field-next = Next operation date
recurring-field-every = Then every
recurring-field-end-date = End date
recurring-field-repeat = Repeat count
recurring-field-guid = Operation GUID
recurring-field-produced-count = Operations inserted
recurring-field-produced-last = Date of the last one inserted
recurring-field-produced-total = Total amount generated

recurring-unit-day = Day
recurring-unit-week = Week
recurring-unit-month = Month
recurring-unit-quarter = Quarter
recurring-unit-year = Year
recurring-ending-no-limit = No limit
recurring-ending-until-date = With an end date
recurring-ending-repeat-count = Repeat count

recurring-title-erase = Erase the operations this rule has already inserted
recurring-erase-question = { $count ->
    [one] This rule has inserted one operation into your accounts. Erase it? Balances will be recomputed, and the rule will not move back.
   *[other] This rule has inserted { $count } operations into your accounts. Erase them all? Balances will be recomputed, and the rule will not move back.
}
recurring-erase-none = This rule has not inserted any operation yet.
recurring-erased = { $count ->
    [0] No operation erased.
    [one] One operation erased, balances recomputed.
   *[other] { $count } operations erased, balances recomputed.
}

recurring-calendar-help = Remove with the wastebasket the occurrences you do not want, then validate to insert them.
recurring-calendar-none = No occurrence to propose: check the next operation date and the account of your rules.
recurring-calendar-column-account = Account
recurring-calendar-column-date = Date
recurring-calendar-column-label = Description
recurring-calendar-column-amount = Amount
recurring-calendar-column-category = Category
recurring-calendar-column-assignment = Assignment
recurring-calendar-column-mode = Payment mode
recurring-calendar-column-payee = Payee
recurring-calendar-column-project = Projects
recurring-calendar-removed = { $count ->
    [one] One occurrence removed from the proposal.
   *[other] { $count } occurrences removed from the proposal.
}
recurring-title-insert = Insert the kept occurrences into the accounts
recurring-nothing = No occurrence left to insert.
recurring-insert-question = { $count ->
    [one] Insert this occurrence into your account? One operation will be created and balances recomputed.
   *[other] Insert these { $count } occurrences into your accounts? That many operations will be created and balances recomputed.
}
recurring-inserted = { $count ->
    [one] One operation inserted. The rule restarts after the last occurrence inserted.
   *[other] { $count } operations inserted. The rules restart after their last occurrence inserted.
}

recurring-refusal-label-required = A label is required
recurring-refusal-date-required = The next operation date is required
recurring-refusal-date-too-old = The next operation date must be on or after the year 2000
recurring-refusal-account-gone = The account specified cannot be found; please choose another one so the rule can apply
recurring-refusal-end-required = When an end date is chosen, it must be filled in
recurring-refusal-end-before-start = The end date cannot be earlier than the next operation date
recurring-refusal-end-too-far = The gap between the next operation date and the end date cannot exceed 10,000 days

# --- Phase 15 — printing and reports -----------------------------------
print-operations-title = List of bank transactions and sub-operations
print-menu-operations-pdf = Print to a PDF file
print-recap-title = Summary by category
print-recap-count = Rows
print-row-count = Number of rows:
print-total-debit = Total debit:
print-total-credit = Total credit:
print-final-balance = Closing balance:
print-licence = Radinus is free software distributed under the GNU GPL v3 or later
print-nothing = There is nothing to print.
print-done = Report printed and opened: "{ $file }".
print-failed = Printing failed: { $reason }
print-not-opened = Report written to "{ $file }", but your system could not open it on its own.

# --- The RIB report (F32) ----------------------------------------------
rib-title = BANK ACCOUNT DETAILS
rib-bank = Bank:
rib-national = RIB - National account identifier
rib-establishment = ESTABLISHMENT
rib-branch = BRANCH
rib-number = ACCOUNT NUMBER
rib-key = RIB KEY
rib-domiciliation = HELD AT
rib-iban = IBAN - International account identifier
rib-bic = BIC - International bank identifier
rib-holder = Account holder

# --- Window F32 --------------------------------------------------------
window-rib-title = Bank account details ( RIB )
rib-group-bank = Bank
rib-group-holder = Account holder
rib-group-details = Bank details
rib-field-bank = Bank name
rib-field-domiciliation = Held at
rib-field-holder = Holder name
rib-field-address = Address
rib-field-establishment = Establishment
rib-field-branch = Branch
rib-field-number = Account number
rib-field-key = RIB key
rib-field-bic = BIC (Bank Identifier Code)
rib-field-iban = IBAN (International Bank Account Number)
rib-conditions = Important conditions that must be met before printing
rib-declaration = I, the user of this software, declare on my honour:
rib-declaration-first = - That I have checked with my bank that the details shown in this window are correct and as I intend them. Likewise, that I undertake to check that the details shown on the printed report are correct and as I intend them. Printing and using these details is entirely my own responsibility.
rib-declaration-second = - That I am the holder of the account whose details will be printed, and that I will not use this software for any unlawful purpose.
rib-title-print = Print on a printer
rib-title-pdf = Print to a PDF file
rib-declaration-required = Tick the declaration on your honour before printing.
rib-help = Check your details, tick the declaration, then print.
rib-account-gone = This bank account no longer exists.
rib-fields-read-only = These details come from the account record: correct them there to change them here.
rib-printed = Details sent to your default printer.
rib-print-failed = Printing failed: { $reason }
rib-pdf-done = Details printed and opened: "{ $file }".
rib-pdf-not-opened = Details written to "{ $file }", but your system could not open it on its own.
menu-accounts-bank-details = Print bank account details

print-choose-printer = Which printer should print this?
print-do-print = Print
rib-printed-on = Details sent to printer "{ $printer }".
ui-cancel = Cancel

print-printers-unknown = Your system could not name any printer: the document went to the default printer.

print-menu-operations-printer = Print on a printer
print-sent-on = Report sent to printer "{ $printer }".
print-sent-default = Report sent to your default printer.

# --- Phase 17 — database operations ------------------------------------
backup-archive = Radinus archive
backup-no-database = No database is open.
backup-done = Backup written to "{ $file }".
backup-failed = Backup failed: { $reason }
backup-not-started = The backup could not be started:
restore-unreadable = This file is not a readable Radinus archive: { $reason }
restore-question = Restore "{ $file }"? Everything your database currently holds will be erased and replaced, and what is in it will be lost.
restore-done = Restore complete: { $accounts } accounts and { $operations } operations.
restore-failed = Restore failed: { $reason }
restore-empty-fields = Empty fields read as a neutral value: { $count }.


# --- The technical journal (phase 17) ----------------------------------
journal-status-success = SUCCESS
journal-status-failure = FAILURE
journal-status-repaired = REPAIRED
journal-step-reindex = Database table repair
journal-step-refill = Empty system list: default values restored
journal-step-table-created = Table missing from the database: recreated empty
journal-step-column-added = Column missing from the table: added with its default value

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Password protection
window-password-form-title = Password protection
password-ask = This database is protected. Enter its password.
password-group-database = Database concerned
password-group-password = Password
password-group-warning = Before you confirm
password-field-old = Old password
password-field-new = New password
password-field-repeat = Repeat the new password
password-hint = Leave the old one empty if the database is not protected yet. Leave both new ones empty to remove the protection.
password-lost-warning = A lost password is a lost database: nothing can recover it. Backups, however, stay unencrypted.
password-show = Show the password
password-remove-question = Remove the protection from this database?
password-mismatch = The two entries of the new password are different
password-wrong = The password does not fit
database-too-recent = This database was saved by a more recent version of Radinus (database version { $found }; this version reads up to version { $supported }). Update Radinus to open it.
database-not-radinus = This file is not a Radinus database.
database-unreadable = The database could not be read: { $reason }
password-close-first = Close this database before changing its password
password-now-protected = The database is protected by a password
password-now-clear = The database is no longer protected
journal-step-date-fixed = Correcting an operation with no date
journal-step-circular = Deleting an inconsistent operation: circular reference
journal-step-flag-parent-true = Wrong EstParent=False flag on a top-level operation
journal-step-flag-parent-false = Wrong EstParent=True flag on a top-level operation
journal-step-flag-child = Wrong EstParent=True flag on a sub-operation
journal-step-orphan = Deleting an orphaned sub-operation
journal-step-third-level = Deleting a sub-operation attached to another sub-operation
journal-step-coherence = Overall recomputation of sub-operation consistency
journal-step-balances = Recomputing every balance of every account
journal-step-vacuum = Compacting the database file
journal-step-analyze = Updating search statistics
journal-step-backup-begin = Backup started
journal-step-backup-end = Backup finished
journal-step-restore-begin = Restore from archive started
journal-step-restore-end = Restore from archive finished
journal-step-restore-read = Reading the archive

# --- The journal window (⌘H) -------------------------------------------
window-journal-title = Log of the last technical operation
journal-column-step = Step
journal-column-file = File
journal-column-table = Table
journal-column-status = Status
journal-column-error = Error
journal-column-comments = Comments
journal-empty = No technical operation has been carried out since the software was opened.
journal-help = The log only keeps the last technical operation: backup, restore, repair, erase or opening a database.

# --- Repair -------------------------------------------------------------
menu-file-repair-running = Repairing and optimising…
repair-done = { $anomalies ->
    [0] Repair complete: no anomaly found. { $lines } steps logged.
    [one] Repair complete: one anomaly repaired. { $lines } steps logged.
   *[other] Repair complete: { $anomalies } anomalies repaired. { $lines } steps logged.
}
repair-failed = Repair failed: { $reason }

journal-status-started = IN PROGRESS
journal-status-finished = FINISHED
journal-step-backup-table = Writing the table into the archive
journal-step-backup-write = Writing the archive
journal-step-backup-verified = Checking the archive just written: files reread / expected, rows reread / written
journal-step-backup-total = Total backed up: rows, data, file size
journal-step-restore-table = Reading the table from the archive
journal-step-restore-missing = File missing from the archive: this table will not be restored
journal-step-restore-wipe = Erasing everything the database holds before restoring
journal-step-restore-write = Writing into the database
journal-step-restore-total = Total restored: accounts, operations
journal-step-restore-empty-fields = Empty fields filled in while reading
backup-verify-mismatch = The archive just written does not read back the way it was written: do not rely on it, make the backup again.

# --- Attachments of an operation (F28, phase 17) ------------------------
window-attachments-title = Attachments of the operation
attachment-filter = Accepted documents
attachment-none = This operation carries no attachment.
attachment-title-add = Attach a document to this operation
attachment-title-open = Open the attachment
attachment-title-remove = Remove the attachment and send its file to the trash
attachment-state-ok = Intact
attachment-state-changed = Changed
attachment-state-missing = File missing
attachment-state-unknown = Cannot be checked
attachment-added = "{ $name }" was attached to the operation.
attachment-removed = Attachment removed, its file is in the trash.
attachment-removed-kept = Attachment removed, but its file could not be sent to the trash.
attachment-remove-question = Remove "{ $name }" from this operation? Its file will be sent to the trash.
attachment-opened = "{ $name }" was opened.
attachment-opened-changed = "{ $name }" was opened, but its contents have changed since it was attached.
attachment-gone = This attachment no longer exists.
attachment-file-missing = The file of "{ $name }" cannot be found on disk.
attachment-failed = Operation failed: { $reason }
attachment-save-first = Save the operation first: an attachment belongs to an operation that exists.
attachment-refusal-missing = This file does not exist.
attachment-refusal-extension = This kind of file is not accepted. Accepted: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = The operation to attach this document to does not exist.
journal-step-backup-attachments = Attachments added to the archive
journal-step-backup-attachment-missing = Attachment missing from disk: it will not be in the archive
journal-step-restore-attachments = Attachments taken out of the archive
attachment-title-replace = Replace the document of this attachment
attachment-replaced = The document was replaced by "{ $name }".

# ---------------------------------------------------------------------
# F08 — the account fiche's "Outils" menu.
# ---------------------------------------------------------------------

account-tools = Tools
account-tools-initial-balance = Set the opening pointed balance
account-tools-statistics = Account statistics
account-tools-delete-operations = Delete every transaction of this account

account-initial-balance-question =
    To work out the opening pointed balance against the operations this account already holds, please enter your bank's current balance
    The opening pointed balance will be computed as:
    { "[" }current bank balance] - [total of pointed operations ({ $total })].
    { "" }
    So that you never have to enter this figure again, you must be completely up to date with this account's bank operations.

account-statistics-none = No transaction

account-statistics =
    Total number of transactions in this account: { $count }
    { "" }
    Number of pointed transactions in this account: { $pointed }
    Pointed debits: { $pointedDebits }
    Pointed credits: { $pointedCredits }
    Difference between pointed credits and debits: { $pointedDifference }
    { "" }
    Number of committed transactions in this account: { $committed }
    Committed debits: { $committedDebits }
    Committed credits: { $committedCredits }
    Difference between committed credits and debits: { $committedDifference }
    { "" }
    Number of planned transactions in this account: { $planned }
    Planned debits: { $plannedDebits }
    Planned credits: { $plannedCredits }
    Difference between planned credits and debits: { $plannedDifference }
    { "" }
    Oldest transaction: { $first }
    Most recent transaction: { $last }

account-delete-operations-question =
    Are you sure you want to delete every operation this bank account holds?
    To confirm it, write { $word } in the field below and validate

account-delete-operations-done =
    { $count ->
        [0] No transaction deleted.
        [one] 1 transaction deleted.
       *[other] { $count } transactions deleted.
    }

# ---------------------------------------------------------------------
# The database selector and the language choice (02/08/2026)
#
# Fabrice's rulings, taken in discussion: Radinus no longer creates a
# database without permission; with no language in the config it asks for
# the language before anything else; a database is any folder of
# databases/ holding a radinus.sqlite, whatever its name.
#
# The language window has no key here: it uses no sentence at all, which
# is what lets it be understood before anyone knows which language the
# user speaks.
# ---------------------------------------------------------------------

window-database-selector-title = Databases
window-database-form-title = New database
database-group-identity = Database identification
database-group-restore = Initialise the database with the contents of a backup
database-choose-backup = Choose a backup file
database-no-backup = No backup chosen: the database will be born empty.

databases-column-label = Database
databases-column-comment = Comment
databases-column-folder = Folder
databases-column-created = Created on

databases-none = No database yet: create one.
databases-help = Choose the database to open, or create a new one.
databases-select = Choose a database from the list first.
databases-tools = Tools
databases-title-open = Open this database

database-created = The database “{ $label }” is created.
database-field-label = Database name
database-field-comment = Comment
database-label-required = Give this database a name: it is what will tell it apart from the others.
database-gone = This database is gone: it was moved or deleted since this window was opened.

# Deleting a database (02/08/2026). The folder goes to the system trash, as
# attachments do: a database deleted by mistake is put back with one click.
# The open database is refused — Radinus is holding its file.
databases-title-delete = Delete this database
database-delete-question =
    Are you sure you want to delete the database “{ $label }”?
    { "" }
    Its whole folder goes to the trash: the operations, the accounts and the attachments.
    To confirm, write { $word } in the field below and validate.
database-in-use = This database is open: Radinus cannot delete it. Open another one first.
database-deleted = The database “{ $label }” is in the trash.

# The selector has two modes (Fabrice, 02/08/2026). Opened while Radinus is
# running, it can no longer open: a Radinus window is built once and never
# destroyed, and nothing could make it forget the database it is showing. You
# read, create and delete — and to change database, you quit.
database-quit-first = To open this database, quit Radinus and start it again: the selector will offer it to you at launch.


# --- F01 — the welcome window (phase 17 bis, 03/08/2026) ------------------
#
# The first thing 2.0.0 has that 1.9.3 did not: the welcome window carries more
# than its banner. The rule that governs it is in the dossier, document 04 F01:
# it is the NO-CLICK view, and nothing that needs a setting belongs on it.
#
# The two ring titles carry the whole month rather than being glued together by
# the window: "Spending ... — August 2026" does not put its words in the same
# order in all three languages, and only Fluent knows where the hole is.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] No open account
    [one] 1 open account
   *[other] { $count } open accounts
}
welcome-total-bank = Bank balance
welcome-total-real = Real balance
welcome-total-final = Final balance
welcome-total-real-detail = cleared + committed
welcome-total-final-detail = cleared + committed + planned
welcome-accounts = Your accounts
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Accounts counted in the totals: { $count } of { $total }
welcome-tile-counted = Count this account in the totals
welcome-tile-bank = In bank
welcome-tile-real = Real
welcome-tile-final = Final
welcome-spending = Spending — { $month }
welcome-earning = Earnings — { $month }
ui-legend-budget-lines = Budget lines
ui-legend-categories = Categories
welcome-nothing = No operation this month.
welcome-open-account = Info: click an account to open its operations.
welcome-no-account = No bank account yet.
welcome-no-account-create = Create a bank account by clicking here
welcome-previous-month = Previous month
welcome-next-month = Next month
welcome-refresh = Read everything again


# --- F39 — preferences (phase 17 ter, 03/08/2026) -------------------------
#
# Where the currency sign sits lives here, beside the two separators: it
# follows the language, not the currency. "before" puts the sign in front of
# the number, anything else puts it after. NO currency sign is ever written in
# this file: "English" does not mean "dollar" — the reader may be American,
# British, Canadian or Australian.

ui-money-sign-position = before
window-preferences-title = Preferences
menu-settings-preferences = Preferences…
menu-settings-show-main = Show the main window
menu-settings-folders = Radinus folders
preferences-branch-display = Display
preferences-leaf-language = Language
preferences-leaf-currency = Currency
preferences-field-language = Software language:
preferences-field-currency = Currency shown:
preferences-field-custom = Currency sign:
preferences-currency-system = System currency
preferences-currency-euro = Euros
preferences-currency-dollar = Dollars
preferences-currency-canadian = Canadian dollars
preferences-currency-cfa = CFA francs
preferences-currency-cfp = CFP francs
preferences-currency-swiss = Swiss francs
preferences-currency-none = None
preferences-currency-custom = Custom
preferences-currency-system-is = Your system reports:
preferences-currency-system-silent = Your system reports no currency: amounts will show in euros.
preferences-custom-required = Type your currency sign before saving.
preferences-saved = Preferences saved.
preferences-help = Pick an option in the tree, then save.
preferences-sign-too-long = A currency sign is 8 characters at most.
preferences-sign-not-a-number = A currency sign may hold no digit, no sign of arithmetic and no separator: Radinus strips them when reading an amount, and "120" would become "12".
preferences-leaf-zoom = Display size
preferences-field-zoom = Magnification:
preferences-zoom-reset = Default value
preferences-zoom-hint = Everything grows together: text, icons, columns. Below 100%, more fits on screen. The system's own menu bar and dialogs follow your computer's settings, not these.
preferences-branch-import = Import
preferences-leaf-verification = Verification
preferences-field-verification = Imported operations:
preferences-verification-hint = “Verified”: you trust your bank, an imported operation is taken as correct. “To verify”: every imported operation waits for your check; you then set it to “Verified” yourself in the operations list. This setting only applies to future imports.
preferences-leaf-qif = QIF statements
preferences-field-qif-order = Order of day and month:
preferences-qif-order-ask = Ask me every time
preferences-qif-order-day-month = Always day/month (05/03 = 5 March)
preferences-qif-order-month-day = Always month/day (05/03 = 3 May)
preferences-qif-order-help = Only used when no date in the file settles it. As soon as a date such as 24/11 proves the order, the file decides, whatever this setting.
preferences-field-qif-label = Transaction label:
preferences-qif-label-both = Payee + memo
preferences-qif-label-payee = Payee only
preferences-qif-label-memo = Memo only
preferences-qif-label-help = When a transaction carries both a payee and a memo. If it carries only one, that one is used, whatever this setting.
preferences-qif-hint = These settings apply to every QIF statement, whatever database is open. “Ask me every time” is the safest: a file with ambiguous dates is never read by guesswork.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Restore default columns
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Show/Hide
columns-colour = Colour column:
columns-colour-none = No colour
columns-colour-red = Red
columns-colour-orange = Orange
columns-colour-pink = Pink
columns-colour-pastel-green = Pastel green
columns-colour-green = Green
columns-colour-pastel-blue = Pastel blue
columns-colour-blue = Blue
columns-colour-pastel-yellow = Pastel yellow
columns-colour-yellow = Yellow
preferences-leaf-columns = Table columns
preferences-table-operations-list = Operations list
preferences-columns-reset = Reset
preferences-columns-reset-all = Reset all
preferences-columns-done = The columns are back to their original layout.
preferences-columns-hint = Each table remembers the order of its columns, the ones you hide and their width. “Reset” gives it back its original layout, at once.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Reset
preferences-leaf-comfort = Comfort settings
preferences-comfort-reset = Reset the comfort settings
preferences-comfort-hint = Puts back the columns of every table, the order and the tick boxes of the accounts on the home window, and the display size. The language, the currency and the verification of imported operations are not touched.
preferences-comfort-question = Reset the comfort settings? The table columns, the home window and the display size will go back to their original state.
preferences-comfort-done = The comfort settings have been reset.

# --- Le bandeau de l'accueil ---------------------------------------------
#
# Ces phrases étaient écrites en dur dans `index.html` depuis la phase 0 et
# ne se traduisaient donc pas (relevé par Fabrice le 03/08/2026). La devise
# est sa voix : les versions anglaise et espagnole sont des propositions, à
# corriger par lui — un slogan ne se traduit pas mot à mot.
ui-language-tag = en
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — the squirrel mascot, in a suit, among a euro sign, a calculator and charts
welcome-slogan-one = A personal finance manager that helps you spend less to earn more
welcome-slogan-two = With Radinus you will see why little streams make great rivers.

# --- « À propos de l'auteur » --------------------------------------------
#
# Le nom et l'adresse sont écrits à l'identique dans les trois fichiers : ils
# ne se traduisent pas. Ils sont ici malgré tout, et non dans la page, pour que
# la vue ne porte aucune phrase — et pour qu'ils se corrigent à un seul endroit
# le jour où l'auteur déménage.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = About the author
about-author-flag-alt = Flag of Corsica — the Moor's head

# --- « À propos de Radinus » ---------------------------------------------
#
# `about-radinus-version` porte un trou : le numéro vient du binaire qui
# tourne, jamais d'une chaîne recopiée. Elle n'est donc pas dans le
# dictionnaire des fenêtres — c'est la commande `app_version` qui la remplit.
window-about-radinus-title = About Radinus
about-radinus-name = Radinus
about-radinus-version = Version { $version }
about-radinus-rust-alt = The Rust language logo
about-radinus-tauri-alt = The Tauri logo
about-radinus-built = Radinus is written in Rust and built with Tauri. The first works out your accounts, the second turns it into a desktop application.
about-radinus-licence = Free software, under the GNU GPL v3 licence.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Licence
licence-heading = RADINUS SOFTWARE LICENCE
licence-logo-alt = The logo of the GNU General Public License version 3
licence-name = GNU GPL v3 or later
licence-intro = Radinus is free software.
licence-freedoms-title = Its licence gives you four freedoms:
licence-freedom-use = Use it as you wish, for whatever you wish.
licence-freedom-study = Study its source code, which is open to everyone.
licence-freedom-share = Copy it and pass it on to others.
licence-freedom-improve = Change it, and share the changes you make.
licence-read = Read the full text of the licence

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = This program comes with no warranty, to the extent permitted by law.
licence-info = The official text opens in your browser, on gnu.org.

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Loan simulation
window-loan-title = Loan simulation
loan-tab-credit = The loan
loan-tab-afford = Can I repay it?
loan-field-kind = Type of loan
loan-kind-consumer = Consumer loan
loan-kind-mortgage = Mortgage
loan-field-amount = Amount borrowed
loan-field-payment = Monthly payment
loan-field-months = Term
loan-field-rate = Fixed interest rate
loan-field-fees = Arrangement fees
loan-field-insurance = Insurance per month
loan-unit-months = months
loan-unit-percent = %
loan-invalid-field = This value is not a number: correct it to run the calculation again.
loan-report-button = PDF report
loan-monthly-table = Month-by-month table
loan-months-count = { $count ->
        [one] { $count } month
       *[other] { $count } months
    }
loan-percent = { $value }%
loan-notice-payment-too-low = This payment does not cover the interest: the loan would never be repaid. The term stays at 600 months.
loan-notice-too-long = This payment would take more than 600 months: the term stays at 600 months.
loan-figure-payment = Monthly payment
loan-figure-payment-insured = Payment including insurance
loan-figure-taeg = APR
loan-figure-interest = Interest cost
loan-figure-insurance = Insurance cost
loan-figure-cost = Total cost of the loan
loan-figure-total-due = Total amount owed
loan-figure-all-in = Total repaid, insurance included
loan-part-capital = Amount borrowed
loan-part-interest = Interest
loan-part-fees = Arrangement fees
loan-part-insurance = Insurance
loan-donut-cost-caption = in total
loan-chart-cost = What this loan costs
loan-chart-capital = Outstanding principal
loan-schedule-title = Repayment schedule
loan-schedule-yearly = Repayment schedule, year by year
loan-column-number = No.
loan-column-year = Year
loan-column-date = Due date
loan-column-payment = Payment
loan-column-payments = Payments
loan-column-interest = Interest
loan-column-capital = Principal
loan-column-insurance = Insurance
loan-column-remaining = Outstanding principal
loan-history-label = Period studied
loan-period-last-12 = Last 12 months
loan-accounts-title = Accounts studied
loan-period-title = Period
loan-column-account = Account
loan-column-bank = Bank
loan-column-balance = Real balance
loan-unavailable-no-account = Tick at least one account to study your history.
loan-unavailable-no-month = This period has no complete month yet: choose another one.
loan-verdict-title = In short
loan-verdict-green = Feasible
loan-verdict-orange = Tight
loan-verdict-red = Risky
loan-verdict-no-income = No income over this period: the debt ratio cannot be calculated.
loan-check-debt-green = Debt ratio of { $ratio }: below this method's threshold of { $green }.
loan-check-debt-orange = Debt ratio of { $ratio }: between { $green } and { $red }, at the limit.
loan-check-debt-red = Debt ratio of { $ratio }: above { $red }.
loan-check-effort = The payment of { $payment } takes { $share } of what you put aside in { $kind ->
        [good] a good month
        [hard] a difficult month
       *[usual] an ordinary month
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] A good month
        [hard] A difficult month
       *[usual] An ordinary month
    } leaves you nothing aside: the payment of { $payment } would come out of your reserve.
loan-check-reserve-green = Your balance stays positive until the end of the loan.
loan-check-reserve-red = Your balance would fall below zero in { $month }, because of this loan.
loan-check-reserve-sooner = Your balance would fall below zero in { $month }, { $count ->
        [one] one month
       *[other] { $count } months
    } earlier than without this loan.
loan-check-reserve-anyway = Your balance would fall below zero around { $month } even without this loan, which hardly changes it.
loan-check-reserve-floor-green = Your balance stays above your safety reserve ({ $floor }) until the end of the loan.
loan-check-reserve-floor-red = Your balance would fall below your safety reserve ({ $floor }) in { $month }, because of this loan.
loan-check-reserve-floor-sooner = Your balance would fall below your safety reserve ({ $floor }) in { $month }, { $count ->
        [one] one month
       *[other] { $count } months
    } earlier than without this loan.
loan-check-reserve-floor-anyway = Your balance would fall below your safety reserve ({ $floor }) around { $month } even without this loan, which hardly changes it.
loan-warning-deficit = Note: over this period, your spending already exceeds your income by { $amount } a month on average, before any loan.
loan-figure-reference = Savings in { $kind ->
        [good] a good month
        [hard] a difficult month
       *[usual] an ordinary month
    }
loan-figure-tipped = Months the loan would put in the red
loan-gauge-caption = debt ratio
loan-figure-income = Average income per month
loan-figure-spending = Average spending per month
loan-figure-saving = Average savings per month
loan-figure-running = Current loans per month
loan-figure-new = New payment, insurance included
loan-figure-rest = Left to live on per month
loan-figure-debt = Debt ratio
loan-red-months-value = { $count } of { $total }
loan-figure-balance-now = Real balance today
loan-figure-balance-end = Projected balance at the end of the loan
loan-chart-income = Where your average income goes
loan-donut-income-caption = average income
loan-part-spending = Everyday spending
loan-part-running = Current loans
loan-part-new = New loan
loan-part-rest = Left over
loan-part-missing = Shortfall
loan-chart-history = Your history with this loan
loan-chart-history-hint = What would have been left each month, with the payment made. Bright red: the months the loan would put in the red; pale red: those already in the red without it.
loan-chart-projection = Your projected balance
loan-mark-loan-end = End: { $label }
loan-mark-negative = In the red
loan-mark-floor = Below the reserve
loan-mark-floor-line = Safety reserve
loan-running-title = Current loans taken into account
loan-running-column-label = Recurring operation
loan-running-column-monthly = Per month
loan-running-column-end = Last payment
loan-no-running = No current loan recognised among your recurring operations.
loan-period-caption = from { $from } to { $to } ({ $count ->
        [one] { $count } month
       *[other] { $count } months
    })
loan-transfers = { $count ->
        [0] No transfer between your ticked accounts was recognised.
        [one] One transfer between your ticked accounts was recognised and set aside.
       *[other] { $count } transfers between your ticked accounts were recognised and set aside.
    }
loan-method = Averages over the complete months of the period, cleared and committed operations, without the transfers between your ticked accounts.
loan-report-title = Loan simulation
loan-report-made-on = simulation of { $date }
loan-disclaimer = Indicative simulation, not contractually binding. Only the bank's offer is binding.
loan-tab-rules = Judgement settings
loan-method-optimistic = Optimistic
loan-method-neutral = Neutral
loan-method-severe = Severe
loan-method-line = Judgement method: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = The verdict answers three questions, and each method sets its own requirements. Choose the one that suits you: the verdict of the « Can I repay it? » tab follows it. The last line assumes your spending rises every year by the percentage given; the payment does not move.
loan-rule-row-debt = Accepted debt ratio
loan-rule-row-reference = Reference savings
loan-rule-row-share = Share of those savings the payment may take
loan-rule-row-floor = Level the balance must not fall below
loan-rule-row-sooner = If the balance falls below it even without the loan
loan-rule-row-growth = Rise in your spending per year
loan-rule-limits = green up to { $green }, orange up to { $red }
loan-rule-reference = { $kind ->
        [good] a good month
        [hard] a difficult month
       *[usual] an ordinary month
    }: { $amount }
loan-rule-floor-zero = zero
loan-rule-floor-cushion = one month of spending: { $amount }
loan-rule-sooner = orange if it brings it forward by { $orange }, red by { $red }
loan-unit-percent-year = % a year
loan-method-optimistic-explain = The optimistic method assumes a good month, accepts a debt ratio up to 40% and keeps no reserve: it says what is possible if all goes well.
loan-method-neutral-explain = The neutral method assumes an ordinary month and follows the banks' rule, a debt ratio of 33 to 35%: it is the reference judgement.
loan-method-severe-explain = The severe method assumes a difficult month and keeps one month of spending in reserve for the unexpected: it says what holds even if things go badly.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Electrical appliance consumption
window-appliance-title = Electrical appliance consumption
appliance-device-title = The appliance
appliance-on-title = Switched on
appliance-standby-title = On standby
appliance-field-on-watts = Power when running
appliance-field-on-hours = Running time per day
appliance-field-days = Days of use per week
appliance-field-share = Share of running time in off-peak hours
appliance-field-standby-watts = Standby power
appliance-field-standby-hours = Standby time per day of use
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = out of 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Left empty, standby lasts the rest of the day. On days without use the appliance stays plugged in: all that time counts as standby. Unplugged, its standby is 0 W.
appliance-contract-title = Your contract
appliance-field-option = Tariff option
appliance-option-base = Base (single price)
appliance-option-off-peak = Peak / Off-peak hours
appliance-field-base = Price per kWh
appliance-field-peak = Price per kWh in peak hours
appliance-field-off-peak = Price per kWh in off-peak hours
appliance-field-off-peak-hours = Off-peak hours per day
appliance-contract-hint = These prices apply to this calculation only. The saved tariff is set in Settings › Preferences › Tools.
appliance-contract-reset = Use the saved tariff again
appliance-period-day = Per day
appliance-period-month = Per month
appliance-period-year = Per year
appliance-energy = { $value } kWh
appliance-less-than = less than { $amount }
appliance-detail-title = One year in detail
appliance-column-part = Item
appliance-column-energy = Energy
appliance-column-cost = Cost
appliance-column-share = Share
appliance-line-on = Switched on
appliance-line-standby = On standby
appliance-line-on-peak = Switched on, peak hours
appliance-line-on-off-peak = Switched on, off-peak hours
appliance-line-standby-peak = On standby, peak hours
appliance-line-standby-off-peak = On standby, off-peak hours
appliance-line-total = Total
appliance-chart-title = Where the money goes
appliance-chart-caption = per year
appliance-standby-sentence = Standby alone costs { $amount } a year: { $share } of what the appliance costs.
appliance-note-plate = The power written on the appliance or in its manual is a maximum: when running, most appliances use less. For a real figure, measure it with a plug-in power meter and enter what it shows.
appliance-note-subscription = The standing charge is not counted: you pay it whether the appliance is plugged in or not.
appliance-invalid-watts = Please enter a power from 0 to 100,000 W.
appliance-invalid-hours = Please enter a time from 0 to 24 hours per day.
appliance-invalid-days = Please enter a whole number of days, from 0 to 7.
appliance-invalid-share = Please enter a share from 0 to 100%.
appliance-invalid-day-overflow = Running time and standby add up to more than 24 hours a day.
appliance-invalid-price = Please enter a price per kWh from 0 to 100.
appliance-invalid-off-peak-hours = Please enter a whole number of off-peak hours, from 0 to 24.
preferences-branch-tools = Tools
preferences-leaf-electricity = Electricity tariff
preferences-electricity-blue = Back to EDF Tarif Bleu
preferences-electricity-hint = Your contract's tariff, used by the “Electrical appliance consumption” tool. By default: EDF's Tarif Bleu (France) on 1 August 2026, prices including tax, 3 to 6 kVA meter. These prices often change in February and August: copy those on your bill.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = My safety cushion
window-cushion-title = My safety cushion
cushion-question = If your income stopped tomorrow, how many months could your savings carry you?
cushion-accounts-title = Your accounts
cushion-column-account = Account
cushion-column-balance = Real balance
cushion-column-savings = Savings
cushion-column-spending = Spending
cushion-accounts-hint = “Savings”: the money you would rely on if things went wrong. “Spending”: the accounts your everyday spending comes from.
cushion-history-label = Period studied
cushion-backup-label = Fallback income per month
cushion-backup-hint = What would keep coming in: unemployment benefit, a partner's salary… Empty: no income.
cushion-categories-title = Spending taken into account
cushion-categories-hint = Untick what you would cut if things went wrong.
cushion-categories-empty = No spending in this period.
cushion-verdict-title = Your cushion
cushion-targets-title = The safety thresholds
cushion-projection-title = Your savings if things went wrong
cushion-projection-hint = What would be left each month if your income stopped today.
cushion-note = An estimate based on your history: spending in a difficult month may differ from the average.
cushion-invalid-backup = This amount cannot be read: correct it to run the calculation again.
cushion-no-spending-account = Tick at least one “Spending” account.
cushion-no-month = This period has no complete month yet.
cushion-months = { $value } months
cushion-per-month = { $amount } per month
cushion-figure-holds = No limit
cushion-gauge-caption = of spending covered
cushion-verdict-short = Less than three months: a hard blow would quickly put you in difficulty.
cushion-verdict-fair = Between three and six months: a fair cushion, worth building up if you can.
cushion-verdict-solid = Six months or more: your cushion is solid.
cushion-verdict-holds = Your fallback income covers your spending: your savings would not shrink.
cushion-verdict-nothing = No spending taken into account over the period: there is nothing to cover.
cushion-tile-savings = Available savings
cushion-tile-spending = Spending taken into account
cushion-tile-backup = Fallback income
cushion-tile-burn = Savings would shrink by
cushion-tile-rhythm = Saving pace
cushion-burn-none = Nothing
cushion-target-title = { $months } months of spending: { $amount }
cushion-target-reached = Reached.
cushion-target-date = { $missing } short. At your saving pace, reached around { $month }.
cushion-target-never = { $missing } short. Your savings did not grow over the period: at this pace, this threshold will not be reached.
cushion-mark-empty = Empty: { $month }
cushion-period = Average of { $count ->
        [one] { $count } complete month
       *[other] { $count } complete months
    }, from { $from } to { $to }. { $transfers ->
        [0] No transfer between your accounts.
        [one] One transfer between your accounts, not counted as spending.
       *[other] { $transfers } transfers between your accounts, not counted as spending.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Savings goal
window-goal-title = Savings goal
goal-accounts-title = Accounts followed
goal-column-account = Account
goal-column-balance = Real balance
goal-accounts-hint = A transfer between two followed accounts cancels out; a transfer to an account not followed counts as money going out.
goal-period-label = Reference period
goal-period-range = Range of years…
goal-range-from = from
goal-range-to = to
goal-question-title = Your question
goal-question-when = When will I have this amount?
goal-question-amount = How much will I have on this date?
goal-question-effort = How much to save to have this amount on this date?
goal-field-target = Target amount
goal-field-date = Target date
goal-field-rate = Annual savings rate
goal-field-extra = And if I saved more, per month
goal-options-hint = Empty: no interest, nothing more.
goal-answer-title = The answer
goal-chart-title = Your balance, yesterday and tomorrow
goal-chart-hint = Solid line: the real balance of the last twelve months; dashed: the projection; shaded: the range depending on the months.
goal-disclaimer = A projection from your history, not a promise: one unexpected event can change everything.
goal-no-account = Tick at least one account to follow.
goal-no-month = This period has no complete month yet.
goal-invalid-target = Please enter an amount to reach.
goal-invalid-date = Please choose a future date within the next fifty years.
goal-invalid-rate = Please enter a rate from 0 to 100%.
goal-invalid-extra = This amount cannot be read: correct it to run the calculation again.
goal-per-month = { $amount } per month
goal-tile-balance = Balance today
goal-tile-rhythm = Average pace
goal-tile-target = Goal
goal-tile-reached = Reached around
goal-tile-date = Target date
goal-tile-projected = Projected balance
goal-tile-saved = Saved by then
goal-tile-interest = Of which interest
goal-tile-needed = To save
goal-when-already = You already have { $amount }: your followed accounts total { $balance }.
goal-when-reached = You will have { $amount } around { $month }, in { $months ->
        [one] one month
       *[other] { $months } months
    }.
goal-when-range = Depending on the months, between { $early } and { $late }.
goal-when-range-open = Around { $early } at the earliest; with weak months, the goal would not be reached.
goal-when-never = At this pace, you will not reach { $amount }.
goal-zero = Your balance would fall to zero around { $month }.
goal-amount = In { $month }, you would have about { $amount }.
goal-amount-range = Depending on the months, between { $low } and { $high }.
goal-effort-more = To have { $amount } in { $month }, you would need to save { $monthly } a month on average, { $gap } more than today.
goal-effort-less = To have { $amount } in { $month }, { $monthly } a month would be enough, { $gap } less than today: you are ahead.
goal-effort-range = Depending on the months, the gap with your pace would range from { $low } to { $high } a month.
goal-chart-target = Goal: { $amount }
goal-chart-today = Today
goal-note-seasons = The projection follows the seasons: each coming month takes the average of the same months in the period.
goal-note-range = The range comes from the weak and strong months of the period: the lowest quarter and the highest quarter.
goal-note-loan = The loan “{ $label }” ends in { $month }: { $amount } more per month afterwards.
goal-note-interest = Interest counted every month at { $rate }% a year: an approximation of the fortnight rule of savings accounts.
goal-period = Pace calculated over { $count ->
        [one] { $count } complete month
       *[other] { $count } complete months
    }, from { $from } to { $to }. { $transfers ->
        [0] No transfer between your followed accounts.
        [one] One transfer between your followed accounts, cancelled out.
       *[other] { $transfers } transfers between your followed accounts, cancelled out.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = What if I cut back…?
window-cut-title = What if I cut back…?
cut-axis-label = Group by
cut-axis-category = Categories
cut-axis-payee = Payees
cut-axis-budget-line = Budget lines
cut-table-title = Your spending, item by item
cut-table-hint = Type a cut in % or in { $sign } per month on the items you would like to trim. A cut cannot exceed the spending itself.
cut-column-monthly = Per month
cut-column-cut = Cut
cut-column-after = After
cut-column-yearly = Gain per year
cut-total = Total
cut-horizon-label = Horizon
cut-settings-title = Settings
cut-options-hint = The rate and the target amount are optional.
cut-report-button = PDF report
cut-chart-title = Your balance, without and with the cuts
cut-chart-hint = Solid line: the real balance of the last twelve months; grey dashes: the projection without cuts; blue: with them; green: the money gained.
cut-donut-title = Your monthly spending after the cuts
cut-donut-caption = after cuts
cut-donut-others = Other items
cut-donut-saved = Saved
cut-legend-with = With the cuts
cut-legend-without = Without cuts
cut-years = { $years ->
        [one] { $years } year
       *[other] { $years } years
    }
cut-headline-none = Type a cut in the table to see its effect.
cut-headline = By cutting { $count ->
        [one] this item
       *[other] these { $count } items
    }, you would put aside { $monthly } more per month, { $yearly } a year.
cut-tile-monthly = Gain per month
cut-tile-yearly = Gain per year
cut-tile-horizon = Gain over { $years ->
        [one] { $years } year
       *[other] { $years } years
    }
cut-tile-spending = Spending per month
cut-target-already = You already have { $amount }.
cut-target-sooner = You would reach { $amount } around { $with } instead of { $without }: { $months ->
        [0] no sooner
        [one] one month sooner
       *[other] { $months } months sooner
    }.
cut-target-only-with = With these cuts, you would reach { $amount } around { $with }; without them, at your current pace, never.
cut-target-never = Even with these cuts, you would not reach { $amount } at your current pace.
cut-note-seasons = Each cut follows the seasons of its item: an item that weighs mostly in summer saves mostly in summer.
cut-note-capped = A cut that was typed exceeded the spending: it has been brought down to the spending itself.
cut-invalid-cut = This cut cannot be read: a percentage from 0 to 100, or an amount per month.
cut-report-settings = The settings
cut-report-result = The result
cut-report-accounts = Followed accounts

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Plan my holidays
window-holiday-title = Plan my holidays
holiday-trip-title = The trip
holiday-field-trip = Type of trip
holiday-trip-stay = Stay
holiday-trip-cruise = Cruise
holiday-field-adults = Adults
holiday-field-children = Children
holiday-field-nights = Length of stay, in nights
holiday-field-days = Days
holiday-field-months = Months before departure
holiday-field-stops = Number of ports of call
holiday-saved-title = Already saved
holiday-saved-hint = Tick the accounts where the holiday money is already put aside: their real balance counts as already saved.
holiday-budget-title = The budget
holiday-budget-hint = For each item, an amount, who it applies to and for how long. An empty item does not count.
holiday-optional-title = Optional lines
holiday-result-title = The result
holiday-donut-title = Where the trip money goes
holiday-donut-caption = for the trip
holiday-child-label = Child price
holiday-count-label = Cabins
holiday-open = Open a project…
holiday-save = Save the project…
holiday-pdf = PDF report
holiday-excel = Export to Excel
holiday-file-filter = Holiday project
holiday-replace-question = Opening this project will replace what is typed in the window. Continue?
holiday-file-saved = Project saved: { $file }
holiday-file-opened = Project opened: { $file }
holiday-file-not-project = This file is not a Radinus holiday project.
holiday-file-too-recent = This project comes from a newer version of Radinus: update Radinus to open it.
holiday-file-failed = The file could not be read or written: { $reason }
holiday-line-transport = Return transport
holiday-line-lodging = Accommodation
holiday-line-meals = Meals and everyday spending
holiday-line-visits = Visits and leisure
holiday-line-port = Getting to the port
holiday-line-cabins = Cabins
holiday-line-service = Service charge (tips)
holiday-line-drinks = Drinks package
holiday-line-excursions = Shore excursions
holiday-line-port-taxes = Port taxes
holiday-line-wifi = On-board wifi
holiday-line-onboard = Spending on board and ashore
holiday-line-other = Other costs and contingencies
holiday-line-insurance = Cancellation insurance
holiday-line-stay-tax = Tourist tax
holiday-line-car = Car on site, fuel and tolls
holiday-line-parking = Airport or station parking
holiday-line-bank = Bank fees abroad
holiday-line-formalities = Formalities (passport, visa, vaccines)
holiday-line-pets = Pet care
holiday-span-trip = for the stay
holiday-span-night = per night
holiday-span-day = per day
holiday-span-stop = per port of call
holiday-who-all = for everyone
holiday-who-person = per person
holiday-who-adults = per adult
holiday-cabins-count = { $count ->
        [one] { $count } cabin
       *[other] { $count } cabins
    }
holiday-days = { $days ->
        [one] { $days } day
       *[other] { $days } days
    }
holiday-invalid-count = Please enter a whole number.
holiday-invalid-amount = This amount cannot be read: a positive number, or a percentage from 0 to 100.
holiday-headline-empty = Type the budget amounts to see what the trip will cost.
holiday-headline-stay = This stay would cost { $total } for { $people ->
        [one] one person
       *[other] { $people } people
    } and { $nights ->
        [0] no night
        [one] one night
       *[other] { $nights } nights
    }.
holiday-headline-cruise = This cruise would cost { $total } for { $people ->
        [one] one person
       *[other] { $people } people
    } and { $nights ->
        [0] no night
        [one] one night
       *[other] { $nights } nights
    }.
holiday-tile-total = Total cost
holiday-tile-person = Per person
holiday-tile-person-day = Per person per day
holiday-tile-saved = Already saved
holiday-tile-remaining = Still to fund
holiday-tile-monthly = Saving needed
holiday-remaining-none = Nothing: it is covered
holiday-monthly-none = Nothing to put aside
holiday-monthly-now = Leaving this month
holiday-note-days = Days are nights plus one: seven nights make eight days.
holiday-note-child = Per person, a child pays the child price if one is given; left empty, a child pays like an adult.
holiday-note-percent = An insurance percentage applies to the main items of the trip; the bank fees percentage to the spending on site.
holiday-sheet-budget = Budget
holiday-sheet-result = Result
holiday-column-line = Item
holiday-column-amount = Amount
holiday-column-child = Child price
holiday-column-who = For whom
holiday-column-span = For how long
holiday-column-cost = Cost
holiday-disclaimer = An estimate from your own amounts: real prices may vary.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Cut-back project
cut-file-not-project = This file is not a Radinus cut-back project.
cut-file-too-recent = This project comes from a newer version of Radinus: update Radinus to open it.
cut-sheet-items = Items

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = My car logbook
window-car-title = My car logbook
car-unnamed = My car
car-sheet-title = The car
car-field-plate = Registration number
car-field-make = Make
car-field-model = Model
car-field-engine = Powertrain
car-field-first-hand = First owner
car-field-registered = First registration
car-field-acquired = Date acquired
car-field-acquired-km = Mileage when acquired
car-field-service = Service every
car-field-service-or = or every
car-unit-months-short = months
car-unit-km = km
car-tariff-title = Home charging tariff
car-tariff-hint = This tariff is kept in the car's logbook: it does not change the one in the preferences.
car-tariff-reset = Use the tariff from the preferences
car-engine-petrol = Petrol
car-engine-diesel = Diesel
car-engine-lpg = LPG
car-engine-e85 = E85 (flex-fuel)
car-engine-hybrid = Hybrid
car-engine-plug-in = Plug-in hybrid
car-engine-electric = Electric
car-engine-hydrogen = Hydrogen
car-energy-petrol = Petrol
car-energy-diesel = Diesel
car-energy-lpg = LPG
car-energy-e85 = E85
car-energy-electricity = Electricity
car-energy-hydrogen = Hydrogen
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energy
car-rubric-upkeep = Routine maintenance
car-rubric-service = Service
car-rubric-wear = Wear parts
car-rubric-tyres = Tyres
car-rubric-breakdown = Breakdowns
car-rubric-insurance = Insurance
car-rubric-inspection = Roadworthiness test
car-part-brake-pads = Brake pads
car-part-brake-discs = Brake discs
car-part-timing-belt = Timing belt
car-part-clutch = Clutch
car-part-battery-12v = 12 V battery
car-part-shock-absorbers = Shock absorbers
car-part-wipers = Wiper blades
car-part-spark-plugs = Spark plugs
car-part-glow-plugs = Glow plugs
car-part-particulate-filter = Particulate filter
car-part-catalytic-converter = Catalytic converter
car-part-fuel-cell-filter = Fuel cell filter
car-part-exhaust = Exhaust
car-part-other = Other part…
car-axle-all = All four tyres
car-axle-front = Front tyres
car-axle-rear = Rear tyres
car-verdict-pass = Pass
car-verdict-counter = Retest required
car-charge-station = At a charging station
car-charge-home = At home
car-slot-peak = Peak hours
car-slot-off-peak = Off-peak hours
car-entry-new = New entry
car-entry-edit = Edit the entry
car-field-date = Date
car-field-km = Odometer
car-field-rubric = Category
car-field-amount = Amount
car-field-garage = Garage or station
car-field-note = Note
car-field-energy = Energy
car-field-quantity = Quantity
car-field-charge = Charging
car-field-slot = Charging time
car-field-part = Part
car-field-part-name = Part name
car-field-axle = Tyres changed
car-field-verdict = Result
car-field-months = Months covered
car-field-battery = Battery health
car-home-amount-hint = The amount of a home charge is worked out from the car's tariff.
car-entry-add = Add to the logbook
car-entry-update = Save the entry
car-entry-cancel = Cancel
car-entry-delete = Delete the entry
car-delete-question = Delete this entry from the logbook?
car-from-operation = Take a transaction…
car-pick-account = Which account is the expense from?
car-pick-operation = Which transaction?
car-pick-take = Take
car-pick-none = No expense in this account.
car-pick-taken = Transaction taken: fill in the odometer and the category, then add the entry.
car-history-title = The history
car-filter-all = All categories
car-history-empty = No entries yet.
car-history-hint = Click an entry to edit it.
car-column-date = Date
car-column-km = Km
car-column-rubric = Category
car-column-detail = Detail
car-column-amount = Amount
car-column-garage = Garage
car-column-note = Note
car-column-share = Share
car-column-per-km = Per km
car-column-energy = Energy
car-column-quantity = Quantity
car-column-price = Average price
car-column-consumption = Consumption
car-column-part = Part
car-column-changes = Changes
car-column-last = Last change
car-column-life = Lifetime
car-column-next = Next change
car-total = Total
car-summary-title = What the car costs
car-headline-empty = Fill in the car's details, then add a first entry: a fill-up, a service, a garage bill…
car-headline = Since { $since }, your car has cost you { $total }.
car-headline-km = Since { $since }, your car has cost you { $total } over { $km }: { $cost } per kilometre.
car-tile-total = Total cost
car-tile-month = Per month
car-tile-km = Per kilometre
car-tile-driven = Kilometres driven
car-tile-consumption = Consumption
car-tile-energy-km = Energy per kilometre
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } month
       *[other] { $months } months
    }
car-detail-battery = Battery: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = By category
car-energy-title = Energy
car-parts-title = Wear parts
car-tyres-title = Tyres
car-battery-title = Battery health
car-years-title = What the car cost each year
car-donut-title = Where the money goes
car-donut-caption = in all
car-deadlines-title = Upcoming dates
car-deadlines-empty = Nothing due yet: note a service, a roadworthiness test, an insurance premium, or two changes of the same part.
car-deadline-service = Service
car-deadline-inspection = Roadworthiness test
car-deadline-counter = Roadworthiness retest
car-deadline-insurance = Insurance renewal
car-when-date = on { $date }
car-when-km = at { $km }
car-when-km-reached = at { $km }, around { $month } at your pace
car-when-date-km = on { $date } or at { $km }, whichever comes first
car-when-inspection-unknown = Note the last roadworthiness test to know the date of the next one.
car-tone-late = Overdue
car-tone-soon = Soon
car-note-since = Everything counts from the acquisition: the date and the odometer noted in the car's details.
car-note-consumption = Consumption is measured from one full tank to the next: fill up completely and note the odometer every time.
car-note-e85 = An E85 car drinks whatever it is given: the kilometres after a fill-up count for that fuel.
car-note-home = A home charge is priced at the car's tariff on the day it is noted, and keeps that cost.
car-note-inspection = The roadworthiness test follows the French rule: the first within four years of first registration, then every two years; a retest within two months.
car-disclaimer = Due dates and lifetimes are estimates drawn from the logbook: only the manufacturer's service book is authoritative.
car-invalid-date = A valid date, not in the future, please.
car-invalid-acquired = The date acquired cannot come before the first registration.
car-invalid-km = An odometer reading in whole kilometres, please.
car-invalid-amount = This amount cannot be read.
car-invalid-quantity = Type the quantity: litres, kWh or kilos.
car-invalid-part = Choose the part changed, or type its name.
car-invalid-rubric = Choose a category.
car-invalid-months = A whole number of months, please.
car-invalid-battery = A battery health from 0 to 100 %, please.
car-open = Open a logbook…
car-save = Save the logbook…
car-report-button = PDF file
car-file-filter = Car logbook
car-file-saved = Logbook saved: { $file }
car-file-opened = Logbook opened: { $file }
car-file-not-logbook = This file is not a Radinus car logbook.
car-file-too-recent = This logbook comes from a newer version of Radinus: update Radinus to open it.
car-replace-question = Opening this logbook will replace the one in the window. Continue?
car-sheet-history = Logbook
car-sheet-summary = Summary

analysis-history-hint = The longer your history, the better this analysis will be: ideally, you should have at least one year of operations.

# --- F48 — Split an expense (Fabrice, 11/10/2026, P-71) -------------------------------
menu-tools-sharing = Split an expense
window-sharing-title = Split an expense
sharing-question = Who pays what?
sharing-setup-title = The split
sharing-field-label = Label
sharing-label-hint = For example “Dinner on 12/10” or “Brittany trip 2027”: it names the files and the reports.
sharing-field-total = Total
sharing-total-hint = Left empty, the total is the sum of the items and of everyone's extras.
sharing-field-rule = Rule
sharing-field-rounding = Rounding
sharing-field-people = People
sharing-mode-whole = One rule for the whole expense
sharing-mode-item = One rule per item
sharing-rule-equal = Equal shares
sharing-rule-parts = By parts
sharing-rule-percent = By percentages
sharing-rule-income = In proportion to income
sharing-rounding-cent = To the cent
sharing-rounding-euro = To the whole unit
sharing-round-euro = Round to whole units
sharing-hide-incomes = Hide incomes in the reports and the export
sharing-people-title = The people
sharing-people-hint = One row per person, one column per item: tick who takes part in what. Everything else is optional. Someone who drops out and leaves their deposit: an exact amount equal to what they paid, and no box ticked.
sharing-add-person = Add a person
sharing-person-default = Person { $number }
sharing-items-title = The items
sharing-items-hint = Only what does not concern everyone, like the wine. The rest of the total goes to the common item.
sharing-add-item = Add an item
sharing-common = Common
sharing-payments-title = The payments
sharing-payments-hint = Who paid, how much, and when. A row without an amount does not count yet.
sharing-payments-none = No payment yet.
sharing-add-payment = Add a payment
sharing-result-title = The result
sharing-balances-title = Where the payments stand
sharing-transfers-title = Suggested transfers
sharing-delete = Delete
sharing-delete-person-question = This person has payments: delete them along with the person?
sharing-disclaimer = Radinus suggests a split: between friends, everyone remains free to settle it otherwise.
sharing-column-person = Person
sharing-column-household = Household
sharing-column-income = Income
sharing-column-parts = Parts
sharing-column-percent = %
sharing-column-floor = At minimum
sharing-column-cap = At maximum
sharing-column-fixed = Exact amount
sharing-column-alone = Their extras
sharing-column-gift = Surplus given
sharing-column-share = Share
sharing-column-typed = % typed
sharing-column-constraint = What applied
sharing-column-due = To pay
sharing-column-item = Item
sharing-column-amount = Amount
sharing-column-rule = Rule
sharing-column-participants = Participants
sharing-column-unit = Household or person
sharing-column-members = Members
sharing-column-paid = Paid
sharing-column-balance = Balance
sharing-column-date = Date
sharing-column-who = Who
sharing-column-label = Label
sharing-help-household = People in the same household settle together: their payments and what they owe are added up, and they get a single statement. Example: “Martin family” for the parents and the children.
sharing-help-income = Only used by the rule “in proportion to income”: the higher the income, the bigger the share. Type the monthly income.
sharing-help-parts = A person with 2 parts pays twice as much as a person with 1 part. Example: adult 1, child 0.5.
sharing-help-percent = The share of the expense the person pays. The percentages must make 100 % in all.
sharing-help-floor = The person will pay at least this amount, even if their calculated share is smaller. The difference lightens the others' load.
sharing-help-cap = The person will never pay more than this amount. What they do not pay falls on the other participants of their items.
sharing-help-fixed = The person pays this amount, whatever happens, and the rest is split among the others. Example: someone who drops out and leaves their deposit.
sharing-help-alone = What the person had for themselves alone, like a dessert or a coffee. They pay it in full, on top of their share.
sharing-help-gift = If the person paid more than their share: ticked, the surplus is a gift to the group; unticked, it is paid back to them.
sharing-help-items = Tick the people who take part in this item. The Common item is what is left of the total once the other items are taken out.
sharing-help-due = What the person owes in all: their share of the items, their extras and the rounding.
sharing-help-share = What their share represents, as a percentage of the sum split.
sharing-help-typed = The percentage you typed. It can differ from the actual share when a minimum, a maximum or an exact amount applied.
sharing-help-constraint = Shows whether the person's share was changed by a minimum, a maximum, an exact amount or a surplus given.
sharing-help-item = Only what does not concern everyone, like the wine. The rest of the total goes to the Common item, split among those ticked in it.
sharing-help-rule = How this item is split: equal shares, by parts, by percentages or in proportion to income.
sharing-help-paid = What the household or person has already paid, according to the payments entered.
sharing-help-balance = What is still to pay, or what was paid beyond the share. Example: “Still to pay: 61.54 €”.
sharing-advice-equal = { $count ->
        [one] { $total } for a single person.
       *[other] { $total } ÷ { $count } people = { $amount } each.
    }
sharing-advice-equal-varied = In equal shares among those who take part, allowing for the limits and exclusions.
sharing-advice-parts = { $parts } shares in all: one share is worth { $amount }.
sharing-advice-parts-varied = Each pays according to their shares, allowing for the limits and exclusions. An empty box counts as 1 share.
sharing-advice-percent-rest = { $rest } % is missing to reach 100 %.
sharing-advice-percent-over = The percentages go over 100 % by { $over } %.
sharing-advice-percent-ok = The percentages add up to 100 %.
sharing-advice-percent-nobody = The percentages already make 100 %: { $count ->
        [one] { $names } would pay nothing.
       *[other] { $names } would all pay nothing.
    }
sharing-advice-income = Each pays { $rate } % of their income.
sharing-advice-income-missing = Type everyone's income to split in proportion to incomes.
sharing-advice-income-varied = Each pays the same proportion of their income, allowing for the limits and exclusions.
sharing-advice-empty = Type the amount to split.
sharing-apply-advice = Use the suggested values
sharing-help-apply-advice = Fills the empty boxes with the grey values. Boxes already filled do not change.
sharing-from-incomes = Percentages from incomes
sharing-help-from-incomes = Replaces the percentages with each income's share of all incomes. They add up to 100 %.
sharing-reset-percents = Share everything out again
sharing-help-reset-percents = Clears the percentages and shares them out equally among everyone. Useful after adding a person.
sharing-reset-percents-question = Clear all the percentages and share them out equally?
sharing-open = Open a project…
sharing-save = Save the project…
sharing-pdf-distribution = Split (PDF)
sharing-pdf-payments = Payment status (PDF)
sharing-pdf-statements = Individual statements (PDF)…
sharing-statements-everyone = Everyone
sharing-excel = Export to Excel
sharing-file-filter = Split project
sharing-replace-question = Opening this project will replace what is entered in the window. Continue?
sharing-file-saved = Project saved: { $file }
sharing-file-opened = Project opened: { $file }
sharing-file-not-project = This file is not a Radinus split project.
sharing-file-too-recent = This project comes from a newer version of Radinus: update Radinus to open it.
sharing-file-failed = The file could not be read or written: { $reason }
sharing-statements-replace-question = { $count ->
        [one] A statement already exists in this folder. Replace it?
       *[other] { $count } statements already exist in this folder. Replace them?
    }
sharing-statements-written = { $count ->
        [one] One statement written in “{ $folder }”.
       *[other] { $count } statements written in “{ $folder }”.
    }
sharing-too-many-people = A split has at most 40 people.
sharing-too-many-items = A split has at most 20 items.
sharing-too-many-payments = A split has at most 400 payments.
sharing-invalid-amount = This amount cannot be read: a positive number.
sharing-invalid-number = This number cannot be read: a positive number.
sharing-invalid-percent = A percentage goes from 0 to 100.
sharing-invalid-date = This date cannot be read.
sharing-name-missing = Every person must have a name.
sharing-name-duplicate = There is already “{ $name }”: tell them apart, for example with an initial.
sharing-floor-above-cap = The minimum is above the maximum.
sharing-item-label-missing = This item has no name.
sharing-items-above-total = The items and everyone's extras exceed the total by { $amount }.
sharing-payment-person = Choose who paid.
sharing-percent-total = The percentages add up to { $sum } %: they must make 100 %.
sharing-percent-total-item = “{ $item }”: the percentages add up to { $sum } %: they must make 100 %.
sharing-item-nobody = Nobody takes part in “{ $item }”.
sharing-item-no-weight = Nobody carries any weight in “{ $item }”: all its participants are at zero.
sharing-income-missing = The income of { $name } is missing.
sharing-fixed-above = The exact amounts exceed the sum to split by { $amount }.
sharing-floors-above = The minimums exceed the sum to split by { $amount }.
sharing-cap-alone = { $name } is the only one taking part in “{ $item }”: their maximum cannot be respected.
sharing-caps-short = The maximums are not enough to cover the sum: { $amount } is missing.
sharing-impossible = These conditions cannot all be respected: loosen a minimum or a maximum.
sharing-constraint-floor = Minimum reached
sharing-constraint-cap = Maximum reached
sharing-constraint-fixed = Exact amount
sharing-constraint-gift = Surplus given
sharing-and = { $first } and { $last }
sharing-outside = Outside their items
sharing-alone = Their extras
sharing-rounding = Rounding
sharing-headline-empty = Add the people who share the expense.
sharing-headline-no-amount = Type the total, or the items to split.
sharing-headline-equal = { $total } to split: each pays { $amount }.
sharing-headline-range = { $total } to split: from { $min } to { $max } depending on the person.
sharing-participants = { $count ->
        [0] No participant
        [one] One participant
       *[other] { $count } participants
    }
sharing-balance-due = Still to pay: { $amount }
sharing-balance-over = Paid { $amount } more than their share
sharing-balance-even = Settled
sharing-summary-collected = { $collected } paid out of { $total }.
sharing-summary-owing = { $count ->
        [0] Everyone is settled.
        [one] Only one still owes { $amount }.
       *[other] { $count } still owe { $amount } in all.
    }
sharing-remaining-outside = Still to pay on the expense: { $amount }
sharing-remaining-reimburse = To pay back to { $name }: { $amount }
sharing-all-settled = Everything is settled: nobody owes anybody anything.
sharing-transfer = { $from } owes { $amount } to { $to }
sharing-warning-over-paid = The payments exceed the expense by { $amount }: check the amounts.
sharing-note-income-zero = { $name } pays nothing on { $items }: their income is 0.
sharing-note-excluded = { $name } does not take part in “{ $item }”: their share is spread among the others.
sharing-note-gift = The surplus given by { $giver } lowers the others' share: { $name } has now paid more than their share.
sharing-note-outside = { $name } pays { $amount } outside their items: the sum is taken off what the others share.
sharing-note-keeper = Rounded to whole units: { $name } keeps the cents, so that the total comes out exactly.
sharing-report-distribution = Split
sharing-report-sharing = The split
sharing-report-who-pays = Who pays what
sharing-report-items = Detail by item
sharing-report-payments = Payment status
sharing-report-as-of = Status on { $date }
sharing-report-balances = Share, paid, balance
sharing-report-statement = Statement — { $name }
sharing-report-your-share = Your share
sharing-statement-total = Total for the household: { $amount }
sharing-statement-pay = To pay to { $name }: { $amount }
sharing-statement-receive = To receive from { $name }: { $amount }
sharing-sheet-people = People
sharing-sheet-items = Items
sharing-sheet-result = Result
sharing-sheet-payments = Payments
sharing-sheet-balances = Repayments
