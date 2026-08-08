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
menu-statistics-by-category = Stats by category
menu-statistics-by-assignment = Stats by assignment
menu-statistics-by-budget-line = Stats by budget line
menu-statistics-by-payment-mode = Stats by payment mode
menu-statistics-by-payee = Stats by payee and merchant
menu-statistics-by-project = Stats by project
menu-statistics-dashboard = Operations dashboard

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
    [one] 1 operation cleared.
   *[other] { $count } operations cleared.
}
operations-select-one = Please select a single operation.

# --- Duplicating, and showing the sub-operations (F02) ----------------

operation-copy = A copy to be saved: nothing has been created yet.
operations-show-children = Show every sub-operation
operations-hide-children = Hide every sub-operation

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
   *[category] Statistics by category
}

statistics-axis-column = { $kind ->
    [assignment] Assignment
    [budget-line] Budget line
    [payment-mode] Payment mode
    [payee] Payee
    [project] Project
   *[category] Category
}

statistics-unclassified = { $kind ->
    [assignment] No assignment
    [budget-line] No budget line
    [payment-mode] No payment mode
    [payee] No payee
    [project] No project
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
export-all-years-excel = Export every year to Excel
export-all-years-ods = Export every year to LibreOffice Calc
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
quick-column-date = Date
quick-column-label = Label
quick-column-amount = Amount
quick-column-category = Category
quick-column-assignment = Assignment
quick-column-payment-mode = Payment mode
quick-column-payee = Payee
quick-column-project = Projects
quick-column-status = Status
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
statement-title-open = Open a statement file (.ofx)
statement-title-info = About the open file
statement-title-integrate = Add the selection to the account
statement-title-validate = Add this operation to the account
statement-duplicate = Duplicate warning: this transaction seems to be in your account already (its Financial Institution Transaction ID exists)
statement-no-fitid = Warning: this file gives no identifier (FITID) for this line. A duplicate could not be detected.
statement-loaded = { $count ->
    [0] This file holds no operation for this account.
   *[other] { $count } lines read, { $known } of which are already in your account.
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
    { $count } operations, { $known } of which are already in your account.
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
excel-backup-later = Backup is not wired up yet in this version of Radinus 2. In the meantime, close Radinus and copy your database file yourself: you can then import with nothing at risk.

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
restore-unreadable = This file is not a readable Radinus archive: { $reason }
restore-question = Restore "{ $file }"? Everything your database currently holds will be erased and replaced, and what is in it will be lost.
restore-done = Restore complete: { $accounts } accounts and { $operations } operations.
restore-failed = Restore failed: { $reason }


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
