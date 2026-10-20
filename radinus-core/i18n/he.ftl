# Radinus — הודעות של צד הליבה (Fluent), עברית.
# מתמלא בהדרגה, ככל שמיושמים מודולי הליבה שמפיקים הודעות למשתמש.
# ראה 08_ARCHITECTURE.md §2.1.

# ערך הסימון "0 = לא צוין" שבו משתמש כל קישור אופציונלי לנתוני יסוד
# (02_BASE_DE_DONNEES.md §7 כלל 2). מוצג בראש כל רשימה נפתחת.
# ---------------------------------------------------------------------
# שם השפה, כתוב בשפה עצמה.
#
# זה מה שמציגים תפריט ההגדרות ובורר השפה של ההפעלה הראשונה
# (01_CAHIER_DES_CHARGES.md §3.5: "כל שפה כתובה בשפה שלה"). הוא נמצא כאן,
# ולא בקוד, משום שזה המקום היחיד שבו הוא יכול להיות נכון: להוסיף שפה פירושו
# להניח קובץ שיודע לקרוא לעצמו בשם.
# ---------------------------------------------------------------------
language-name = עברית

nomenclature-unspecified = לא צוין

# נשאלת לפני מחיקת פריט נתוני יסוד שתנועות עדיין משתמשות בו
# (02_BASE_DE_DONNEES.md §7 כלל 5). משוחזרת מילה במילה מהמקור של
# WinDev (Enreg_Supprimer), כולל הטיפוגרפיה — הניסוח הוא של המחבר,
# ואינו תרגום.
nomenclature-delete-confirm = זוהו תנועות (תנועות בנקאיות) בעלות תכונה מסוג '{ $label }'. האם לאפס את התכונה הזאת?

# נשאלת לפני מחיקת פריט נתוני יסוד שאיש אינו משתמש בו. המקור מחק פריט כזה
# מיד, בלי מילה; Fabrice ביקש ב-25/07/2026 שכל מחיקה תאושר — סטייה מודעת
# מהקוד שלו עצמו, והיחידה במודול הזה.
nomenclature-delete-plain = האם למחוק את "{ $label }"?

# סירוב שמוצג כאשר הפריט שעומדים למחוק הוא בדיוק זה שהכרטיס שלו פתוח.
# החלטת Fabrice מ-25/07/2026: פריט אינו נמחק מתחת לכרטיס הפתוח שלו — קודם
# סוגרים את הכרטיס, במקום להשאיר אותו מציג רשומה שכבר אינה קיימת.
nomenclature-delete-form-open = הכרטיס של "{ $label }" פתוח. יש לסגור אותו לפני המחיקה.

# סירוב שמוצג כאשר התיאור הנשמר כבר נושא פריט אחר של אותם נתוני יסוד
# (החלטת המחבר, 25/07/2026: שני פריטים של אותם נתוני יסוד לא יישאו שם זהה —
# שיוך תנועה לאחד משני תיאורים זהים הוא הטלת מטבע). `element` הוא שם העצם
# במין שלו, "קטגוריה", "צד נגדי"; `label` הוא התיאור הקיים, כפי שנשמר, כדי
# שהמשתמש יראה מה עומד בדרך.
nomenclature-duplicate = כבר קיים { $element } בשם זהה: "{ $label }".

# ---------------------------------------------------------------------
# מה שהחלונות אומרים על עצמם.
#
# הכול נמצא כאן, לרבות מה שתלוי בנתוני היסוד המוצגים: המשפטים כתובים
# במלואם, שפה אחר שפה, ולא מורכבים מהדבקת מילים ומינים. הרכבה נכונה
# בצרפתית שגויה בשפה הבאה, ובסופו של דבר הקוד הוא שיודע שקיים מין נקבה —
# וזו אינה עבודתו (כלל של המחבר, 25/07/2026: "התוכנה עובדת עם Fluent
# בצרפתית ובאנגלית כבר מההתחלה").
# ---------------------------------------------------------------------

ui-loading = טעינה…
ui-editing = עריכה.
ui-viewing = עיון.
ui-modified-suffix = — שונה
ui-label-required = יש להזין תיאור.
ui-discard-question = האם לבטל את השינויים?
ui-yes = כן
ui-no = לא
ui-select-record = יש לבחור רשומה
ui-key-multiselect = CTRL
ui-multiselect-help = מידע: יש להשתמש בלחיצת עכבר + מקש [{ $modifier }] על הטבלה כדי לבחור מספר פריטים
ui-no-match = אין תיאור שתואם את הסינון.
ui-filter-placeholder = סינון התיאורים…
ui-column-label = תיאור
ui-field-label = תיאור
ui-field-budget-line = סעיף תקציב
ui-identifier = מזהה
ui-deletion-abandoned = המחיקה בוטלה: דבר לא שונה.
ui-unknown-nomenclature = נתוני יסוד לא מוכרים:

ui-title-filter = סינון
ui-title-create = יצירה
ui-title-update = עריכת הפריט הנבחר
ui-title-delete = מחיקת הפריט הנבחר
ui-title-read = עיון בפריט הנבחר
ui-title-close = סגירה
ui-title-save = שמירה
ui-title-add = הוספה
ui-title-modify = עריכה

ui-load-failed = הטעינה נכשלה:
ui-save-failed = השמירה נכשלה:
ui-read-failed = הקריאה נכשלה:
ui-delete-failed = המחיקה נכשלה:
ui-open-failed = הפתיחה נכשלה:
ui-close-failed = הסגירה נכשלה:

# --- משפטים ייחודיים לכל סוג של נתוני יסוד ---------------------------

nomenclature-identifier = { $kind ->
    [category] מזהה קטגוריה
    [assignment] מזהה הקצאה
    [payment-mode] מזהה אמצעי תשלום
    [payee] מזהה צד נגדי
    [project] מזהה פרויקט
    [budget-line] מזהה סעיף תקציב
   *[bank] מזהה בנק
}

nomenclature-none = { $kind ->
    [category] אין קטגוריה.
    [assignment] אין הקצאה.
    [payment-mode] אין אמצעי תשלום.
    [payee] אין צד נגדי.
    [project] אין פרויקט.
    [budget-line] אין סעיף תקציב.
   *[bank] אין בנק.
}

nomenclature-nothing-to-show = { $kind ->
    [category] אין קטגוריות להצגה.
    [assignment] אין הקצאות להצגה.
    [payment-mode] אין אמצעי תשלום להצגה.
    [payee] אין צדדים נגדיים להצגה.
    [project] אין פרויקטים להצגה.
    [budget-line] אין סעיפי תקציב להצגה.
   *[bank] אין בנקים להצגה.
}

nomenclature-gone = { $kind ->
    [category] הקטגוריה הזאת אינה קיימת עוד.
    [assignment] ההקצאה הזאת אינה קיימת עוד.
    [payment-mode] אמצעי התשלום הזה אינו קיים עוד.
    [payee] הצד הנגדי הזה אינו קיים עוד.
    [project] הפרויקט הזה אינו קיים עוד.
    [budget-line] סעיף התקציב הזה אינו קיים עוד.
   *[bank] הבנק הזה אינו קיים עוד.
}

nomenclature-fresh = { $kind ->
    [category] קטגוריה חדשה.
    [assignment] הקצאה חדשה.
    [payment-mode] אמצעי תשלום חדש.
    [payee] צד נגדי חדש.
    [project] פרויקט חדש.
    [budget-line] סעיף תקציב חדש.
   *[bank] בנק חדש.
}

nomenclature-created = { $kind ->
    [category] הקטגוריה נוספה.
    [assignment] ההקצאה נוספה.
    [payment-mode] אמצעי התשלום נוסף.
    [payee] הצד הנגדי נוסף.
    [project] הפרויקט נוסף.
    [budget-line] סעיף התקציב נוסף.
   *[bank] הבנק נוסף.
}

nomenclature-updated = { $kind ->
    [category] הקטגוריה עודכנה.
    [assignment] ההקצאה עודכנה.
    [payment-mode] אמצעי התשלום עודכן.
    [payee] הצד הנגדי עודכן.
    [project] הפרויקט עודכן.
    [budget-line] סעיף התקציב עודכן.
   *[bank] הבנק עודכן.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] נמחקה קטגוריה אחת.
        [two] נמחקו שתי קטגוריות.
       *[other] נמחקו { $count } קטגוריות.
      }
    [assignment] { $count ->
        [one] נמחקה הקצאה אחת.
        [two] נמחקו שתי הקצאות.
       *[other] נמחקו { $count } הקצאות.
      }
    [payment-mode] { $count ->
        [one] נמחק אמצעי תשלום אחד.
        [two] נמחקו שני אמצעי תשלום.
       *[other] נמחקו { $count } אמצעי תשלום.
      }
    [payee] { $count ->
        [one] נמחק צד נגדי אחד.
        [two] נמחקו שני צדדים נגדיים.
       *[other] נמחקו { $count } צדדים נגדיים.
      }
    [project] { $count ->
        [one] נמחק פרויקט אחד.
        [two] נמחקו שני פרויקטים.
       *[other] נמחקו { $count } פרויקטים.
      }
    [budget-line] { $count ->
        [one] נמחק סעיף תקציב אחד.
        [two] נמחקו שני סעיפי תקציב.
       *[other] נמחקו { $count } סעיפי תקציב.
      }
   *[bank] { $count ->
        [one] נמחק בנק אחד.
        [two] נמחקו שני בנקים.
       *[other] נמחקו { $count } בנקים.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] כבר קיימת קטגוריה בשם זהה: "{ $label }".
    [assignment] כבר קיימת הקצאה בשם זהה: "{ $label }".
    [payment-mode] כבר קיים אמצעי תשלום בשם זהה: "{ $label }".
    [payee] כבר קיים צד נגדי בשם זהה: "{ $label }".
    [project] כבר קיים פרויקט בשם זהה: "{ $label }".
    [budget-line] כבר קיים סעיף תקציב בשם זהה: "{ $label }".
   *[bank] כבר קיים בנק בשם זהה: "{ $label }".
}

# --- כותרות החלונות, בלי ניקוד כמו בחלונות המקוריים ------------------

window-list-title = { $kind ->
    [category] רשימת הקטגוריות
    [assignment] רשימת ההקצאות
    [payment-mode] רשימת אמצעי התשלום
    [payee] רשימת הצדדים הנגדיים והסוחרים
    [project] רשימת הפרויקטים
    [budget-line] רשימת סעיפי התקציב
   *[bank] רשימת הבנקים
}

window-form-title = { $kind ->
    [category] כרטיס קטגוריה
    [assignment] כרטיס הקצאה
    [payment-mode] כרטיס אמצעי תשלום
    [payee] כרטיס צד נגדי
    [project] כרטיס פרויקט
    [budget-line] כרטיס סעיף תקציב
   *[bank] כרטיס בנק
}

# --- שורת התפריטים (01_CAHIER_DES_CHARGES.md §6) ---------------------

menu-file = קובץ
menu-file-import-statements = ייבוא דפי חשבון בנק
menu-file-import-excel = ייבוא קובץ Excel
menu-file-backup = גיבוי
menu-file-restore = שחזור
menu-file-repair = תיקון ואופטימיזציה של מסד הנתונים
menu-file-log = הצגת הלוג
menu-tools-password = הגנה על מסד הנתונים בסיסמה
menu-file-disconnect = התנתק ממסד הנתונים הנוכחי
menu-file-quit = יציאה

menu-accounts = חשבונות
menu-accounts-manage = ניהול חשבונות בנק
menu-accounts-balances = הצגת היתרות בחשבונות שלך
menu-accounts-operations = ניהול התנועות של חשבון
menu-accounts-quick-classify = סיווג מהיר של תנועות
menu-accounts-recurring = ניהול תנועות חוזרות
menu-accounts-transfer = העברת סכום בין שני חשבונות
menu-accounts-checkbooks = ניהול פנקסי צ'קים

menu-statistics = סטטיסטיקה
menu-statistics-balance-chart = גרף התפתחות היתרה
menu-statistics-balance-analysis = ניתוח התפתחות היתרה
menu-statistics-by-category = סטטיסטיקה לפי קטגוריות
menu-statistics-by-assignment = סטטיסטיקה לפי הקצאות
menu-statistics-by-budget-line = סטטיסטיקה לפי סעיפי תקציב
menu-statistics-by-payment-mode = סטטיסטיקה לפי אמצעי תשלום
menu-statistics-by-payee = סטטיסטיקה לפי צדדים נגדיים וסוחרים
menu-statistics-by-project = סטטיסטיקה לפי פרויקטים
menu-statistics-by-verification = סטטיסטיקה לפי אימות
menu-statistics-dashboard = לוח מחוונים של התנועות
menu-statistics-crossed-balance = מאזן מוצלב

menu-budget = תקציב
menu-budget-entry = הזנת תקציב
menu-budget-control = בקרת תקציב

menu-nomenclatures = נתוני יסוד
menu-nomenclature = { $kind ->
    [category] קטגוריות
    [assignment] הקצאות
    [payment-mode] אמצעי תשלום
    [payee] צדדים נגדיים וסוחרים
    [project] פרויקטים
    [budget-line] סעיפי תקציב
   *[bank] בנקים
}
menu-nomenclatures-templates = תבניות תנועות

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = כלים
menu-settings = הגדרות
menu-settings-about-author = אודות המחבר
menu-settings-about-radinus = אודות Radinus
menu-settings-licence = רישיון שימוש

menu-misc = שונות
menu-misc-calculator = מחשבון
menu-misc-website = מעבר לאתר של Radinus
menu-misc-database-folder = גישה לתיקייה המכילה את מסד הנתונים

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = פתיחת התיקייה של מסד הנתונים
database-folder-warning =
    תיקייה זו מכילה את כל הנתונים שלך. שינוי שם, העברה או מחיקה של קובץ עלולים לאבד את החשבונות שלך, לפגוע בהם או למנוע מ-Radinus לפעול.
    לפתוח אותה?
menu-misc-application-folder = גישה לתיקייה המכילה את היישום
menu-misc-attachments-folder = גישה לתיקייה המכילה את הקבצים המצורפים
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = ניהול הקבצים המצורפים
window-attachments-manager-title = ניהול הקבצים המצורפים
attachments-column-document = מסמך
attachments-column-size = גודל
attachments-column-added = נוסף בתאריך
attachments-column-state = מצב
attachments-state-intact = תקין
attachments-state-altered = שונה מאז
attachments-state-missing = הקובץ חסר
attachments-state-unknown = לא ניתן לאימות
attachments-state-orphan = יתום
attachments-no-operation = אין פעולה
attachments-orphan-remove-question = קובץ זה אינו מקושר לאף פעולה. להעביר לאשפה?
attachments-manager-help = לחיצה כפולה על שורה תפתח את המסמך.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = הצגת הפעולה
attachments-reveal = הצגה במנהל הקבצים
attachments-manager-summary = { $count } קבצים מצורפים, { $size } בסך הכול.
attachments-disk-name = שם בדיסק: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = פתיחת תיקיית הקבצים המצורפים
attachments-folder-warning =
    תיקייה זו מכילה את הקבצים שצירפת לפעולות שלך. Radinus שומר אותם בשם שהוא בחר: שינוי שם, העברה או מחיקה של קובץ אינם מנתקים אותו מהפעולה, שתמשיך להציג אותו והוא לא ייפתח עוד.
    לפתוח אותה?

# ---------------------------------------------------------------------
# חשבונות בנק — F04, F06, F07, F08.
# שגיאות הכתיב של גרסה 1.9.3 ("Bank Identifer Code", "Solde
# initial prevu", "Est Cloturé", הרווח לפני הסוגריים של ה-IBAN)
# תוקנו: החלטה של Fabrice מ-25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = ניהול חשבונות בנק
window-accounts-select-title = רשימת החשבונות
window-balances-title = היתרות בחשבונות שלך
window-account-title = כרטיס חשבון

accounts-none = אין חשבונות.
accounts-nothing-to-show = אין חשבונות להצגה.
accounts-gone = החשבון הזה כבר לא קיים.
accounts-fresh = חשבון חדש.
accounts-created = החשבון נוסף.
accounts-updated = החשבון עודכן.
accounts-deleted = { $count ->
    [one] נמחק חשבון אחד.
    [two] נמחקו שני חשבונות.
   *[other] נמחקו { $count } חשבונות.
}
accounts-duplicate-name = כבר קיים חשבון באותו שם: "{ $label }".
accounts-multiselect-help = מידע: השתמש בלחיצת עכבר + מקש [{ $modifier }] על הטבלה כדי לבחור מספר חשבונות
accounts-select-question = על אילו חשבונות בנק יש לבסס את הסטטיסטיקה?

accounts-column-label = תיאור
accounts-column-bank = בנק
accounts-column-type = סוג חשבון
accounts-column-number = מספר חשבון
accounts-column-account = חשבון
accounts-column-bank-balance = בבנק
accounts-column-real-balance = בפועל
accounts-column-final-balance = סופית
accounts-total = סה"כ

# מחיקת חשבון גוררת איתה את התנועות שלו: זה המקום היחיד בתוכנה
# שבו מחיקה מוחקת היסטוריה.
accounts-delete-plain = האם לאשר את מחיקת החשבון "{ $label }"?
accounts-delete-with-operations = החשבון "{ $label }" מכיל { $count } תנועות, שיימחקו יחד איתו. האם אתה מאשר את המחיקה?
accounts-delete-form-open = כרטיס החשבון "{ $label }" פתוח. סגור אותו לפני המחיקה.

account-group-bank = פרטי החשבון והבנק
account-group-holder = בעל החשבון
account-group-rib = פרטי בנק (RIB)
account-group-activity = פעילות
account-group-balances = יתרות

account-field-label = שם החשבון
account-field-bank = בנק
account-field-type = סוג חשבון
account-field-branch-address = כתובת סניף הבנק
account-field-holder-name = שם
account-field-holder-address = כתובת
account-field-rib-bank = קוד מוסד
account-field-rib-branch = קוד סניף
account-field-rib-number = מספר חשבון
account-field-rib-key = ספרת ביקורת RIB
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = תאריך פתיחה
account-field-closing-date = תאריך סגירה
account-field-closed = סגור
account-field-opening-pointed = יתרת פתיחה מותאמת
account-field-opening-committed = יתרת פתיחה משוריינת
account-field-opening-planned = יתרת פתיחה מתוכננת

account-label-required = שם החשבון הוא שדה חובה.
account-iban-invalid = ה-IBAN הזה אינו תקין: בדוק את ספרת הביקורת.
# השורה הכחולה בתחתית הכרטיס, מילה במילה כמו זו של 1.9.3 — רק
# הסכומים מוצגים מעתה בפורמט הצרפתי של שאר השדות.
account-control-line = יתרת פתיחה מותאמת ({ $opening }) + סך התנועות ({ $operations }) = יתרה בבנק נוכחית: { $balance }.

amount-not-readable = "{ $field }" אינו מכיל סכום תקין.

ui-thousands-separator = ,
ui-decimal-separator = .

# --- רשימת התנועות (F02) --------------------------------------------

window-operations-title = רשימת התנועות של החשבון: { $account }

operations-none = אין תנועות בתקופה הזו.
operations-bad-period = גבולות התקופה אינם תאריכים תקינים.
operations-from = תאריך התחלה
operations-to = תאריך סיום
operations-delete-confirm = { $count ->
    [one] האם לאשר את מחיקת התנועה הזו?
    [two] האם לאשר את מחיקת שתי השורות האלה? תת-התנועות של התנועות שנבחרו נמחקות יחד איתן.
   *[other] האם לאשר את מחיקת { $count } השורות האלה? תת-התנועות של התנועות שנבחרו נמחקות יחד איתן.
}
operations-deleted = { $count ->
    [one] נמחקה תנועה אחת.
    [two] נמחקו שתי תנועות.
   *[other] נמחקו { $count } תנועות.
}
operations-selection-total = סכום כולל של התנועות שנבחרו: { $amount }

operations-column-date = תאריך
operations-column-clearing-date = תאריך התאמה
operations-column-status = סטטוס תנועה
operation-status-pointed = מותאמת
operation-status-committed = משוריינת
operation-status-planned = מתוכננת
operations-column-verification = אימות
operation-verification-to-verify = לבדיקה
operation-verification-verified = אומתה
operation-verification-doubtful = מפוקפקת
operation-verification-disputed = במחלוקת
operations-column-label = תיאור
operations-column-reference = אסמכתת תשלום
operations-column-category = קטגוריה
operations-column-assignment = הקצאה
operations-column-payment-mode = אמצעי
operations-column-payee = צד נגדי
operations-column-project = פרויקטים
operations-column-month = חודש
operations-column-debit = חובה
operations-column-credit = זכות
operations-column-balance = יתרה
operations-column-comments = הערות
operations-column-attachments = קבצים מצורפים
operations-column-check = מספר צ'ק

operations-foot-debit = חובה:
operations-foot-credit = זכות:
operations-foot-total = סה"כ:
operations-foot-bank = יתרה בבנק:
operations-foot-real = יתרה בפועל:
operations-foot-final = יתרה סופית:

operations-menu-export = ייצוא
operations-menu-print = הדפסה
operations-menu-filter = סינון
operations-menu-period = תקופה
operations-menu-misc = שונות

operations-title-point = התאמת הבחירה
operations-title-sub = הוספת תת-תנועה
operations-title-duplicate = שכפול הבחירה
operations-not-yet = המסך הזה עדיין לא קיים: הוא מגיע בהמשך התוכנית.

accounts-choose-question = על איזה חשבון ברצונך לעבוד?
ui-title-select = בחירת הפריטים

month-january = ינואר
month-february = פברואר
month-march = מרץ
month-april = אפריל
month-may = מאי
month-june = יוני
month-july = יולי
month-august = אוגוסט
month-september = ספטמבר
month-october = אוקטובר
month-november = נובמבר
month-december = דצמבר

operations-period-year = השנה הנוכחית

# --- תפריט התקופה של F02 ---------------------------------------------
# תשע כניסות, ושתיים מהן פותחות תת-תפריט של שנים עשר החודשים. כל אחת
# עושה רק דבר אחד: להסיק ממנה תאריך התחלה ותאריך סיום, שהמסך מחזיר
# לשני השדות שלו (בקשה של Fabrice, 25/07/2026).

period-all = הכול
period-last-year = השנה שעברה
period-this-year = השנה הנוכחית
period-whole-year = כל השנה
period-last-month = החודש שעבר
period-this-month = החודש הנוכחי
period-last-week = השבוע שעבר
period-this-week = השבוע הנוכחי
period-yesterday = אתמול
period-today = היום

# --- תפריט הסינון של F02 ----------------------------------------------
# מסנן את השורות לפי סוג התנועה (בקשה של Fabrice, 25/07/2026). שלושת
# הסטטוסים הם אלה של מסד הנתונים: 1 מותאם, 2 משוריין, 3 מתוכנן
# (02_BASE_DE_DONNEES.md §5.2).

filter-all = כל התנועות
filter-pointed = רק תנועות מותאמות
filter-committed = רק תנועות משוריינות
filter-planned = רק תנועות מתוכננות
filter-by-status = סינון לפי סטטוס
filter-by-verification = סינון לפי אימות
filter-show-all = הצגת הכול

# --- כרטיס תנועה (F03) -------------------------------------------
# התוויות הן אלה של צילום המסך "Fiche operation transaction.png",
# עם תיקון שגיאות הכתיב של המקור (אישור של Fabrice, 25/07/2026:
# "את שגיאות הכתיב אתה מתקן"): "Libelle" הופך ל"Libellé",
# "Categorie" הופך ל"Catégorie", "Statut Operation" הופך
# ל"Statut opération".

window-operation-title = תנועה חשבון: { $account }

operation-menu-identification = זיהוי
operation-menu-options = אפשרויות
operation-fitid-edit = עריכת מזהה FITID…
operation-fitid-delete = מחיקת מזהה FITID
operation-fitid-question = מזהה FITID של תנועה זו:
operation-fitid-delete-question = למחוק את מזהה FITID של תנועה זו?
operation-fitid-written = מזהה FITID נשמר.
operation-fitid-removed = מזהה FITID נמחק.

operation-group-identification = זיהוי התנועה
operation-group-amount = סכום התנועה
operation-group-status = סטטוס התנועה
operation-group-classification = סיווג התנועה לצורך חישוב הסטטיסטיקה
operation-group-check = צ'ק הקשור לתנועה
operation-group-comment = הערה

operation-field-label = תיאור
operation-field-reference = אסמכתת תשלום
operation-field-date = תאריך
operation-field-direction = סוג תנועה:
operation-field-amount = סכום
operation-field-status = סטטוס תנועה
operation-field-clearing-date = תאריך התאמה
operation-field-verification = אימות
operation-field-category = קטגוריה
operation-field-assignment = הקצאה
operation-field-payment-mode = אמצעי
operation-field-payee = צד נגדי
operation-field-project = פרויקט
operation-field-check = שיוך לצ'ק

operation-direction-debit = חובה
operation-direction-credit = זכות

operation-check-info = מידע.
operation-check-link = שיוך
operation-check-unlink = מחיקה

operation-fresh = תנועה חדשה.
operation-created = התנועה נוספה.
operation-updated = התנועה עודכנה.
operation-gone = התנועה הזאת כבר לא קיימת.
operation-nothing-to-show = אין תנועות להצגה.
operation-label-required = תיאור התנועה הוא שדה חובה.
operation-date-required = תאריך התנועה הוא שדה חובה.
operation-clearing-date-invalid = תאריך ההתאמה אינו תאריך תקין.
operation-clearing-date-required = פעולה מסומנת חייבת לשאת תאריך סימון.
operation-clearing-date-question =
    פעולה מסומנת חייבת לשאת תאריך סימון.
    לשמור עם תאריך הפעולה, { $date }?
operation-is-a-sub = השורה הזאת היא תת-תנועה: היא נערכת מהכרטיס שלה עצמה.
operation-delete-form-open = הכרטיס של "{ $label }" פתוח. יש לסגור אותו לפני המחיקה.

operation-attachments = { $count ->
    [0] אין קבצים מצורפים
    [one] קובץ מצורף אחד
    [two] שני קבצים מצורפים
   *[other] { $count } קבצים מצורפים
}

operation-title-comment = הערת התנועה
operation-title-sub = יצירת תת-תנועה
operation-title-template = תבניות תנועה
operation-title-attachment = קבצים מצורפים

# --- כרטיס תת-תנועה (F04) --------------------------------------
# גרסה מצומצמת של F03: בלי אמצעי, בלי סטטוס, בלי תאריך — תת-תנועה
# יורשת אותם מהתנועה שממנה היא נגזרת (`Maj_ProprieteSousOp`, אושר
# על ידי Fabrice ב-26/07/2026: "בתת-תנועה, בהיותה ההשלמה, אי אפשר
# לגעת באמצעי התשלום, זה לא יהיה הגיוני").

window-sub-operation-title = כרטיס תת-תנועה

sub-operation-group-amount = סכום תת-התנועה
sub-operation-field-label = שם
sub-operation-fresh = תת-תנועה חדשה.
sub-operation-created = תת-התנועה נוספה.
sub-operation-updated = תת-התנועה עודכנה.
sub-operation-gone = תת-התנועה הזאת כבר לא קיימת.
sub-operation-nothing-to-show = אין תת-תנועות להצגה.
sub-operation-label-required = שם תת-התנועה הוא שדה חובה.
sub-operation-parent-gone = התנועה לפיצול כבר לא קיימת.
# מה שהכרטיס אומר כשהוא מציג את ההשלמה. היא אינה מוגנת:
# אפשר לערוך אותה, אבל צריך לדעת מה לוקחים (החלטה של
# Fabrice, 26/07/2026).
sub-operation-is-the-complement = זוהי ההשלמה: מה שנותר לפצל. שינוי שמה או שינוי סכומה הופך אותה לתת-תנועה רגילה.
sub-operation-of = פיצול של "{ $label }" ({ $amount })

operations-pointed = { $count ->
    [0] אין תנועה להתאמה: הבחירה כבר הותאמה.
    [one] תנועה אחת הותאמה.
    [two] שתי תנועות הותאמו.
   *[other] { $count } תנועות הותאמו.
}
operations-select-one = יש לבחור תנועה אחת בלבד.

# --- שכפול והצגת תת-התנועות (F02) ---------------------
# שכפול פותח כרטיס מלא מראש שהמשתמש מאשר בעצמו
# (החלטה של Fabrice, 26/07/2026): שום דבר אינו נכתב כל עוד לא שמר,
# והוא יכול לתקן את התאריך או את הסכום לפני כן.

operation-copy = עותק לשמירה: עדיין לא נוצר דבר.
operations-show-children = הצגת כל תת-התנועות
operations-hide-children = הסתרת כל תת-התנועות
operations-recurring-from = יצירת תנועה מחזורית מתוך תנועה זו

# --- אישור שני למחיקה חמורה ---------------------
# מחיקת חשבון בנק גוררת את כל ההיסטוריה שלו: על כפתור כן/לא לוחצים
# בלי לקרוא, ולכן מבקשים להקליד את המילה (החלטה של Fabrice,
# 26/07/2026). המילה היא זו של המילון — "כן" כאן, "Yes" באנגלית —
# ולכן אין לתרגם כאן דבר פעמיים.

accounts-delete-second-question = המחיקה הזאת סופית וגוררת את כל היסטוריית החשבון. יש להקליד "{ $word }" כדי לאשר אותה.

# --- F20-F24 — שש הסטטיסטיקות -----------------------------------
# תבנית משותפת, בשישה צירים. זו שלפי קטגוריות שימשה מודל ו-Fabrice
# אישר אותה ב-26/07/2026 לפני שחמש האחרות היו קיימות — שמות
# העמודות הם אלה של המקור.

window-statistics-title = { $kind ->
    [assignment] סטטיסטיקה לפי הקצאה
    [budget-line] סטטיסטיקה לפי סעיף תקציב
    [payment-mode] סטטיסטיקה לפי אמצעי תשלום
    [payee] סטטיסטיקה לפי צד נגדי וסוחר
    [project] סטטיסטיקה לפי פרויקט
    [verification] סטטיסטיקה לפי אימות
   *[category] סטטיסטיקה לפי קטגוריה
}

statistics-axis-column = { $kind ->
    [assignment] הקצאה
    [budget-line] סעיף תקציב
    [payment-mode] אמצעי תנועה
    [payee] צד נגדי
    [project] פרויקטים
    [verification] אימות
   *[category] שם קטגוריה
}

statistics-unclassified = { $kind ->
    [assignment] ללא הקצאה
    [budget-line] ללא סעיף תקציב
    [payment-mode] ללא אמצעי תשלום
    [payee] ללא צד נגדי
    [project] ללא פרויקט
    [verification] לבדיקה
   *[category] ללא קטגוריה
}
statistics-total = סך הכול
statistics-sum = סכום
statistics-cumulative = מצטבר

# חמשת המתגים של הסרגל. התווית מתחלפת ON/OFF, כמו במקור:
# המתג עצמו הוא שאומר היכן הוא נמצא.
statistics-switch-pointed = תנועות מותאמות { $state }
statistics-switch-committed = תנועות משוריינות { $state }
statistics-switch-planned = תנועות מתוכננות { $state }
statistics-switch-debits = סכומי חובה { $state }
statistics-switch-credits = סכומי זכות { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = לא נבחר אף חשבון: הסטטיסטיקה אינה מתייחסת לדבר.
statistics-no-data = אין תנועות בשנה הזאת בחשבונות שנבחרו.
statistics-detail-empty = יש ללחוץ על תא עם מספר כדי לראות את התנועות שהוא סופר.
statistics-detail-none = אין תנועות מאחורי התא הזה.
statistics-accounts = { $count ->
    [one] חשבון אחד
    [two] שני חשבונות
   *[other] { $count } חשבונות
}
statistics-year-next = השנה הבאה
statistics-year-previous = השנה הקודמת

statistics-column-date = תאריך
statistics-column-clearing-date = תאריך התאמה
statistics-column-label = תיאור
statistics-column-amount = סכום
statistics-column-comments = הערות

accounts-stats-multiselect-help = מידע: יש להשתמש בלחיצת עכבר + מקש [{ $modifier }] על הטבלה כדי לבחור כמה חשבונות

# שנת הסטטיסטיקה: לוחצים עליה ומקלידים שנה. הגבולות הם אלה של
# "הכול" בתפריט תקופה — שנה ב-Radinus היא מספר שלם בין 1950
# ל-2550 (Fabrice, 26/07/2026).
statistics-year-question = על איזו שנה ברצונך לעבוד? Radinus נע בין { $first } ל-{ $last }.
statistics-year-choose = בחירת שנה

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = מאזן מוצלב
crossed-balance-window-name = מאזן מוצלב
crossed-balance-column = קטגוריה
crossed-balance-no-data = אין תנועה בחודש זה בחשבונות שנבחרו.
crossed-balance-month-question = על איזה חודש ברצונך לעבוד? מספר בין { $first } ל־{ $last }.
crossed-balance-month-choose = בחירת חודש
crossed-balance-next = החודש הבא
crossed-balance-previous = החודש הקודם

# --- ייצוא הטבלאות (לחיצה ימנית) ---------------------------------
# פונקציה של הטבלה, לא של חלון: היא קיימת בכל הרשימות.

export-to-excel = ייצוא ל-Excel (.xlsx)
export-to-word = ייצוא ל-Word (.docx)
export-to-tsv = ייצוא ל-TSV (.tsv)
export-to-ini = ייצוא ל-INI (.ini)
export-to-toml = ייצוא ל-TOML (.toml)
export-to-yaml = ייצוא ל-YAML (.yaml)
export-to-ofx = ייצוא ל-OFX (.ofx)
export-to-qif = ייצוא ל-QIF (.qif)
export-to-ods = ייצוא ל-LibreOffice Calc (.ods)
export-to-csv = ייצוא ל-CSV (.csv)
export-to-xml = ייצוא ל-XML (.xml)
# תפריט הייצוא של חלון הסטטיסטיקה: לשונית לכל שנה, בשם
# AN_2026. השנים הריקות — לפי המתגים שנקבעו — אינן נכללות.
export-menu = ייצוא
export-to = ייצוא אל
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = העתקת התא
copy-rows = העתקת השורות שנבחרו
copy-failed = ההעתקה ללוח נכשלה.
export-all-years-excel = ייצוא כל השנים ל-Excel
export-all-years-ods = ייצוא כל השנים ל-LibreOffice Calc
export-all-months-excel = ייצוא כל חודשי השנה המוצגת ל־Excel
export-all-months-ods = ייצוא כל חודשי השנה המוצגת ל־LibreOffice Calc
export-no-year = אין שנה שיש בה תנועות: אין מה לייצא.
export-years-done = { $years } שנים יוצאו לקובץ "{ $file }".
export-to-json = ייצוא ל-JSON (.json)
export-done = יוצא לקובץ "{ $file }".
export-failed = לא ניתן לייצא: { $reason }
export-nothing = אין מה לייצא.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] סטטיסטיקה לפי הקצאה
    [budget-line] סטטיסטיקה לפי סעיף תקציב
    [payment-mode] סטטיסטיקה לפי אמצעי תשלום
    [payee] סטטיסטיקה לפי צד נגדי וסוחר
    [project] סטטיסטיקה לפי פרויקט
    [verification] סטטיסטיקה לפי אימות
   *[category] סטטיסטיקה לפי קטגוריה
}
statistics-detail-name = פירוט הסטטיסטיקה

# --- F19 — לוח מחוונים ------------------------------------------------
# תקופה ושלושה מתגים; שני תרשימי טבעת לכל סעיף תקציב;
# שלושה מספרים גדולים. צבעי הגזרות הם אלה של המקור,
# שנלקחו מצילום המסך של Fabrice.

window-dashboard-title = לוח מחוונים
dashboard-menu-period = תקופה
dashboard-menu-misc = שונות
dashboard-from = תאריך התחלה:
dashboard-to = תאריך סיום:
dashboard-switch-pointed = הכללת תנועות מותאמות
dashboard-switch-committed = הכללת תנועות משוריינות
dashboard-switch-planned = הכללת תנועות מתוכננות
dashboard-spending = הוצאות
dashboard-earning = הכנסות
dashboard-debits = סכום תנועות החובה
dashboard-credits = סכום תנועות הזכות
dashboard-balance = מאזן
dashboard-unclassified = ללא סעיף תקציב
dashboard-nothing = אין תנועות בתקופה זו.
dashboard-no-account = לא נבחר אף חשבון: לוח המחוונים אינו מציג דבר.
dashboard-enlarge = פתיחה מוגדלת

# --- F25 — התפתחות היתרה ----------------------------------------------
# גרף אחד לכל חשבון שנבחר, ועוד גרף של הסך הכול — שקיים רק
# משני חשבונות ומעלה (כלל של Fabrice, 26/07/2026). הגרפים
# מדורגים: היתרה שומרת על ערכה עד לתנועה הבאה.

window-curve-title = התפתחות היתרה
curve-heading = התפתחות היתרה לפי יום
curve-menu-period = תקופה
curve-total = סך הכול
curve-from = תאריך התחלה:
curve-to = תאריך סיום:
curve-axis-balance = יתרה
curve-nothing = לא נבחר אף חשבון: אין גרף לשרטט.
curve-empty = אין תנועות בתקופה זו.

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = ניתוח התפתחות היתרה
analysis-heading = ניתוח התפתחות היתרה
analysis-hint = גררו על הגרף בלחיצה ממושכת על לחצן העכבר כדי לראות את התנועות של אותה תקופה.
analysis-zone = אזור:
analysis-opening = יתרת פתיחה:
analysis-closing = יתרת סגירה:
analysis-variation = שינוי:
analysis-detail-name = ניתוח היתרה
analysis-detail-none = אין תנועות באזור הזה.

# --- F05 — סיווג מהיר של תנועות ---------------------------------------
# החלון שבו מסווגים **בכמות גדולה**: בוחרים שורות, מסמנים את
# המאפיינים שיש לשנות, ומחילים אותם בבת אחת — בזיכרון.
# דבר אינו נכתב עד לשמירה, והשמירה כותבת רק את מה ששונה ממה
# שנקרא (כללים של Fabrice, 27/07/2026).

window-quick-classification-title = סיווג מהיר של תנועות: { $account }
quick-dates-title = תאריכי התחלה וסיום של הרשימה.
quick-from = תאריך התחלה
quick-to = תאריך סיום
quick-menu-period = תקופה
quick-change-title = שינוי מאפייני הבחירה ל:
quick-check-category = קטגוריה
quick-check-assignment = הקצאה
quick-check-payment-mode = אמצעי
quick-check-payee = צד נגדי
quick-check-project = פרויקט
quick-check-status = סטטוס
quick-check-verification = אימות
quick-column-date = תאריך
quick-column-label = תיאור
quick-column-amount = סכום
quick-column-category = קטגוריה
quick-column-assignment = הקצאה
quick-column-payment-mode = אמצעי תשלום
quick-column-payee = צד נגדי
quick-column-project = פרויקטים
quick-column-status = סטטוס
quick-column-verification = אימות
# ב-Mac, Ctrl + לחיצה היא לחיצה ימנית: המקש שמוסיף לבחירה הוא
# ⌘, והעזרה צריכה לציין את המקש שעובד.
quick-multiselect-help = מידע: יש להשתמש בלחיצת עכבר + מקש [{ $modifier }] בטבלה כדי לבחור כמה פריטים
quick-none = אין תנועות בתקופה זו.
quick-select-lines = יש לבחור לפחות שורה אחת ולסמן לפחות מאפיין אחד.
quick-applied = { $count ->
    [0] דבר לא השתנה: שורות אלו כבר נשאו סיווג זה.
    [one] שורה אחת סווגה. עדיין לא נשמר דבר.
    [two] שתי שורות סווגו. עדיין לא נשמר דבר.
   *[other] { $count } שורות סווגו. עדיין לא נשמר דבר.
}
quick-pending = { $count ->
    [0] אין שינויים ממתינים.
    [one] שורה אחת שונתה, ללא שמירה.
    [two] שתי שורות שונו, ללא שמירה.
   *[other] { $count } שורות שונו, ללא שמירה.
}
quick-save-question = { $count ->
    [one] לשמור את השינוי הממתין?
    [two] לשמור את שני השינויים הממתינים?
   *[other] לשמור את { $count } השינויים הממתינים?
}
quick-saved = { $count ->
    [0] לא היה דבר לשמור.
    [one] שורה אחת נשמרה.
    [two] שתי שורות נשמרו.
   *[other] { $count } שורות נשמרו.
}
quick-nothing-to-save = אין שינויים ממתינים.
quick-leave-question = ישנם שינויים שלא נשמרו. מה ברצונך לעשות?
quick-leave-save = שמירה ויציאה
quick-leave-discard = יציאה ללא שמירה
quick-leave-stay = הישארות
quick-title-apply = החלה על השורות שנבחרו ( בזיכרון )
quick-title-save = שמירה לדיסק

# --- F17 / F18 — ייבוא דף חשבון בנקאי ---------------------------------
# בוחרים חשבון, פותחים קובץ OFX — שנשאר ב-RAM —, השורות שמסד
# הנתונים כבר מכיר מוצגות בגוון פסטל, והסמל השלישי משלב אותן:
# בכמות גדולה אם נבחרו כמה שורות, אחת-אחת דרך כרטיס ההתאמה
# אחרת (דרך הפעולה של Fabrice, 27/07/2026).

window-statement-import-title = ייבוא דפי חשבון של חשבונות בנק: { $account }
window-statement-form-title = התאמת תנועה (משלבת תנועה בהיסטוריית החשבון שלך)
statement-menu-filter = סינון
statement-filter-all = כל השורות
statement-filter-pending = לשילוב
statement-filter-known = כבר שולבו
statement-column-id = ID
statement-column-reconciled = הותאם
statement-column-fitid = FITID
statement-column-date = תאריך
statement-column-label = תיאור
statement-column-reference = אסמכתת תשלום
statement-column-debit = חובה
statement-column-credit = זכות
statement-account = חשבון
statement-file = קובץ
statement-difference = הפרש
statement-none = לא נפתח אף דף חשבון: יש ללחוץ על התיקייה הצהובה כדי לבחור קובץ (OFX, CSV, QIF).
statement-empty = דף חשבון זה אינו מכיל אף תנועה.
statement-no-match = אף שורה אינה תואמת את הסינון.
statement-help = מידע: יש להשתמש בלחיצת עכבר + מקש [{ $modifier }] בטבלה כדי לבחור כמה שורות
statement-choose-account = קובץ זה מכיל כמה חשבונות. איזה מהם לייבא?
statement-select-line = יש לבחור לפחות שורה אחת מדף החשבון.
statement-title-open = פתיחת קובץ דף חשבון (OFX, QIF, CSV)
statement-title-info = מידע על הקובץ הפתוח
statement-title-integrate = שילוב הבחירה בחשבון
statement-title-validate = שילוב תנועה זו בחשבון
statement-duplicate = שים לב, כפילות: נראה שתנועה זו כבר שולבה במסד הנתונים (Financial Institution Transaction ID קיים)
statement-no-fitid = שים לב: קובץ זה אינו מספק מזהה (FITID) לשורה זו. לא ניתן יהיה לזהות כפילות.
statement-loaded = { $count ->
    [0] קובץ זה אינו מכיל אף תנועה עבור חשבון זה.
    [one] נקראה שורה אחת. מספר השורות שכבר קיימות בחשבון שלך: { $known }.
    [two] נקראו שתי שורות. מספר השורות שכבר קיימות בחשבון שלך: { $known }.
   *[other] נקראו { $count } שורות. מספר השורות שכבר קיימות בחשבון שלך: { $known }.
}
statement-loaded-unidentified = { $alike ->
    [0] נקראו { $count } שורות. אף אחת מהן אינה דומה לתנועה שכבר קיימת בחשבון שלך.
    [one] נקראו { $count } שורות. אחת מהן דומה לתנועה שכבר קיימת בחשבון שלך (אותו תאריך, אותו תיאור, אותו סכום).
    [two] נקראו { $count } שורות. שתיים מהן דומות לתנועות שכבר קיימות בחשבון שלך (אותו תאריך, אותו תיאור, אותו סכום).
   *[other] נקראו { $count } שורות. { $alike } מהן דומות לתנועות שכבר קיימות בחשבון שלך (אותו תאריך, אותו תיאור, אותו סכום).
}
statement-loaded-also-alike = { $alike ->
    [one] שורה נוספת דומה לתנועה שכבר קיימת (אותו תאריך, אותו תיאור, אותו סכום).
    [two] שתי שורות נוספות דומות לתנועות שכבר קיימות (אותו תאריך, אותו תיאור, אותו סכום).
   *[other] { $alike } שורות נוספות דומות לתנועות שכבר קיימות (אותו תאריך, אותו תיאור, אותו סכום).
}
statement-integrated = { $count ->
    [0] דבר לא נקלט: שורות אלו כבר נמצאות בחשבון שלך.
    [one] תנועה אחת שולבה.
    [two] שתי תנועות שולבו.
   *[other] { $count } תנועות שולבו.
}
# **ההודעות של המקור, מילה במילה** (הנחיה של Fabrice,
# 28/07/2026: להישאר נאמן לקוד המקורי). שלו מזהיר לפני האצווה,
# שואל שורה אחר שורה מול כפילות, ומדווח בסוף.

statement-mass-question =
    האם אתה בטוח שברצונך לשלב בחשבונך כמה תנועות בבת אחת?
    יהיה עליך לסווג ולאפיין אותן בהמשך כדי להפיק סטטיסטיקה מדויקת
    במקרה של קובצי Ofx: אם יתגלו כפילויות יהיה עליך לבחור את התנהגות התוכנית
    לסוגי קבצים אחרים: יהיה עליך להיזהר מכפילויות
statement-duplicate-question =
    התנועה: { $date } { $label }: { $amount }
    נראה שכבר שולבה בהיסטוריית התנועות של חשבון הבנק שלך.
    האם באמת ברצונך לבצע את ההתאמה?
statement-already-reconciled = כבר התאמת תנועה זו: היא כבר משולבת בהיסטוריית התנועות של חשבונך
statement-integration-report =
    סיום השילוב.
    מספר הרשומות ששולבו: { $added }
    מספר הרשומות שדולגו: { $ignored }
statement-integration-abandoned =
    הפסקת השילוב!
    מספר הרשומות ששולבו: { $added }
    מספר הרשומות שדולגו: { $ignored }
statement-yes = כן
statement-no = לא
statement-cancel = ביטול
statement-file-info =
    חשבון הקובץ: { $account }
    תקופה: מ-{ $from } עד { $to }
    יתרה שהודיע עליה הבנק: { $balance }
statement-qif-question = שום דבר בקובץ זה אינו מציין אם התאריך "{ $date }" כתוב יום/חודש או חודש/יום. משמעותו:
statement-qif-day-month = יום { $day }, חודש { $month } (יום/חודש)
statement-qif-month-day = יום { $day }, חודש { $month } (חודש/יום)
statement-qif-dates-mixed = קובץ זה כותב את התאריכים שלו בשתי דרכים: "{ $first }" נקרא יום/חודש, "{ $second }" חודש/יום. הוא אינו מיובא, כדי שאף תאריך לא ישתבש.
statement-qif-amounts-mixed = קובץ זה כותב את הסכומים שלו בשתי דרכים: "{ $first }" עם נקודה, "{ $second }" עם פסיק. הוא אינו מיובא, כדי שאף סכום לא ישתבש.
statement-qif-opening = יתרת פתיחה של { $amount } ב-{ $date }: זו אינה תנועה, היא אינה מיובאת.
statement-qif-opening-undated = יתרת פתיחה של { $amount }: זו אינה תנועה, היא אינה מיובאת.
statement-qif-suspect = שורה { $rank }, "{ $label }" ({ $amount }), נראית כמו יתרת פתיחה: יש לבדוק אותה לפני שילובה.
statement-qif-rejected = { $count ->
    [one] שורה אחת בלתי קריאה אינה מיובאת: { $lines }.
    [two] שתי שורות בלתי קריאות אינן מיובאות: { $lines }.
   *[other] { $count } שורות בלתי קריאות אינן מיובאות: { $lines }.
}
statement-qif-reason-date = תאריך
statement-qif-reason-amount = סכום
statement-qif-reason-differ = סכומים סותרים
statement-qif-no-account = חשבון זה כבר אינו נמצא בקובץ: יש לפתוח את הקובץ מחדש.
statement-balance-unknown = לא צוין בקובץ
statement-group-identification = זיהוי התנועה
statement-group-amount = סכום התנועה
statement-group-classification = סיווג התנועה לצורך חישוב סטטיסטיקה
statement-group-status = סטטוס התנועה
statement-field-date = תאריך
statement-field-label = תיאור
statement-field-reference = אסמכתת תשלום
statement-field-type = סוג תנועה
statement-field-amount = סכום
statement-field-mode = אופן התנועה
statement-field-category = קטגוריה
statement-field-assignment = הקצאה
statement-field-payee = צד נגדי
statement-field-project = פרויקט
statement-field-status = סטטוס
statement-field-clearing = תאריך התאמה

# --- חלון פיצול דף חשבון בפורמט CSV -----------------------------------
# קובץ CSV אינו נושא שום שם שדה אמין: מכווננים, בודקים, מסתכלים,
# ומתחילים מחדש. התצוגה המקדימה מציגה הכול, כולל ג'יבריש — כך
# רואים שטעינו — אך רק השורות התקינות עוברות לחלון השילוב
# (כלל של Fabrice, 27/07/2026).

window-csv-statement-title = ייבוא נתונים מקובץ csv
csv-preview-title = תצוגה מקדימה של הקובץ:
csv-settings-title = פרמטרים לפיצול הקובץ לצורך חילוץ הנתונים:
csv-extraction-title = הצגת חילוץ הנתונים לפי פרמטרי הפיצול  ( יש לבדוק את עקביות הנתונים ):
csv-column-line = מס' שורה
csv-column-content = תוכן
csv-header-lines = מספר שורות הכותרת של הקובץ שיש להתעלם מהן
csv-separator = הנתונים (העמודות) מופרדים בתו:
csv-date-at = מיקום שדה התאריך
csv-label-at = מיקום שדה התיאור
csv-debit-at = מיקום שדה סכום החובה
csv-credit-at = מיקום שדה סכום הזכות
csv-test = בדיקת הפרמטרים
csv-separator-semicolon = נקודה-פסיק   ;
csv-separator-comma = פסיק   ,
csv-separator-tab = טאב
csv-separator-pipe = קו אנכי   |
csv-separator-space = רווח
csv-help = יש לכוונן, לבדוק ולהסתכל: רק שורות הנושאות תאריך וסכום קריאים ייובאו.
csv-none = הקובץ ריק.
csv-not-tested = יש ללחוץ על "בדיקת הפרמטרים" כדי לראות מה מניב הפיצול.
csv-extraction = { $count ->
    [0] הפיצול אינו מפיק אף שורה: יש לבדוק את מספר שורות הכותרת ואת התו המפריד.
    [one] פוצלה שורה אחת. לייבוא: { $valid }; נדחו בהיעדר תאריך או סכום קריא: { $dropped }.
    [two] פוצלו שתי שורות. לייבוא: { $valid }; נדחו בהיעדר תאריך או סכום קריא: { $dropped }.
   *[other] פוצלו { $count } שורות. לייבוא: { $valid }; נדחו בהיעדר תאריך או סכום קריא: { $dropped }.
}
csv-nothing-valid = אף שורה אינה נושאת גם תאריך וגם סכום קריאים: אין מה לייבא. יש לבדוק את מספר שורות הכותרת, את התו המפריד ואת מיקום השדות.
csv-title-validate = העברת השורות התקינות לייבוא

# --- F13 / F31 / F14 / F12 — פנקסי צ'קים וצ'קים (שלב 9) -------------
# העברה של חמשת קודי WinDev שלו ושל שבעת צילומי המסך שלו, שנמסרו ב-
# 28/07/2026. המשפטים המדויקים שלו היכן שיש לו כאלה; שלי בכל מקום אחר.
#
# שלוש נאמנויות שהוא הכריע בהן באותו יום ושנשמעות מתוך
# המילים: אסמכתא כפולה אינה מוכרזת (ה-`Existe_Reference` שלו
# לעולם אינה נקראת), מספר הצ'קים אינו נבדק מול הגבולות,
# ומונה התנועות סופר גם את תת-התנועות שהרשימות דוחות.

window-chequebooks-title = רשימת פנקסי הצ'קים
window-chequebook-title = הגדרות פנקס צ'קים
window-cheques-title = הרכב פנקס הצ'קים: רשימת הצ'קים.
window-cheque-title = כרטיס צ'קים
window-cheque-operations-title = רשימת התנועות.

# רשימת פנקסי הצ'קים (F13) — כל הפנקסים, מכל החשבונות יחד:
# שתי עמודות החשבון שלו לא היו מועילות בחשבון יחיד.
chequebooks-column-reference = תיאור
chequebooks-column-date = תאריך
chequebooks-column-account = שם החשבון
chequebooks-column-account-number = מס' חשבון
chequebooks-column-comments = הערות
chequebooks-none = לא נשמר אף פנקס צ'קים.
chequebooks-nothing-to-show = אף פנקס צ'קים אינו תואם את החיפוש הזה.
chequebooks-title-composition = הצגת הרכב פנקס הצ'קים
chequebooks-delete-question = זוהו תנועות (תנועות בנקאיות) המשויכות לפנקס הצ'קים. האם לאשר את מחיקת פנקס הצ'קים הזה?
chequebooks-deleted = { $count ->
    [one] נמחק פנקס צ'קים אחד.
    [two] נמחקו שני פנקסי צ'קים.
   *[other] נמחקו { $count } פנקסי צ'קים.
}
chequebooks-gone = פנקס הצ'קים הזה אינו קיים עוד.
chequebooks-created = פנקס הצ'קים נשמר, על כל צ'קיו.
chequebooks-updated = פנקס הצ'קים עודכן.
# השתיקה של ה-`HAjoute` שלו: החלון אינו אומר שהאסמכתא
# תפוסה. הוא אומר רק ששום דבר לא נשמר — אחרת היינו סבורים
# שהפנקס נוצר.
# שמונה אמצעי הזהירות מתוך "Precauttion enregistrement cheque.txt"
# שלו, מילה במילה ולפי סדרו. שבעת הראשונים הם `Erreur()`,
# השמיני הוא `Info()` — והסדר קובע מה רואים כששני דברים
# משתבשים יחד.
chequebook-refusal-duplicate = כבר קיימת אסמכתא בשם זהה
chequebook-refusal-reference-required = הזנת אסמכתא היא חובה
chequebook-refusal-number-too-big = מספרי הצ'ק הראשון ו/או האחרון גדולים מדי (ערך מרבי 999 999 999)
chequebook-refusal-date = יש להזין תאריך קבלה תקין
chequebook-refusal-numbers-required = יש למלא את מספרי הצ'ק הראשון והאחרון
chequebook-refusal-order = מספר הצ'ק הראשון חייב להיות קטן ממספר הצ'ק האחרון
chequebook-refusal-account = חובה לבחור את החשבון המשויך לפנקס הצ'קים הזה
chequebook-refusal-too-many = מספר הצ'קים המרבי בפנקס צ'קים: 1000, המגבלה הושגה
# בקשת האישור שלו, המוצגת בעת ההוספה בלבד: היא מסכמת את מה שעומד להיווצר
# ומזהירה ששום דבר מכך לא יהיה ניתן לשינוי לאחר מכן.
chequebook-creation-question =
    יצירת פנקס הצ'קים עם המאפיינים הבאים:
    - מספר הצ'קים שייווצרו:{ $count }
    - צ'קים ממוספרים מ-{ $first } עד { $last }
    שים לב, נתונים אלה לא יהיו ניתנים לשינוי לאחר היצירה!

# כרטיס פנקס הצ'קים (F31). חמשת השדות הראשונים מעומעמים ברגע שהפנקס קיים:
# הצ'קים שלו כבר נמצאים שם.
chequebook-field-id = מזהה פנקס צ'קים
chequebook-field-reference = אסמכתא
chequebook-field-received = יוצר או התקבל בתאריך
chequebook-field-first = מספר הצ'ק הראשון
chequebook-field-last = מספר הצ'ק האחרון
chequebook-field-quantity = מספר הצ'קים
chequebook-field-account = שיוך לחשבון הבנק:
chequebook-field-comments = הערות
chequebook-locked = הצ'קים של הפנקס הזה כבר נוצרו: המספור שלו אינו ניתן עוד לשינוי.
# המשפט שלו, מילה במילה (`Enreg_Lire`).
chequebook-account-missing = חשבון הבנק שאליו שויך פנקס הצ'קים הזה חסר או נמחק!

# הרכב פנקס הצ'קים (F14). הסטטוס משתנה בתוך התא.
cheques-column-number = מס' צ'ק
cheques-column-date = תאריך
cheques-column-place = מקום
cheques-column-payee = מוטב
cheques-column-amount = סכום
cheques-column-status = סטטוס
cheques-column-comments = הערות
cheques-column-operations = מס' תנועות משויכות
cheques-none = פנקס הצ'קים הזה אינו מכיל אף צ'ק.
cheques-nothing-to-show = אף צ'ק אינו תואם את החיפוש הזה.
cheques-help = יש ללחוץ בתא הסטטוס כדי לשנותו; זכוכית המגדלת מציגה את התנועות המשויכות, והחוליה משייכת תנועה.
cheques-title-linked = הצגת התנועות שכבר משויכות לצ'ק הזה
cheques-title-link = שיוך תנועה לצ'ק הזה
cheques-status-changed = סטטוס הצ'ק עודכן.

# כרטיס הצ'ק (F12).
cheque-field-id = מזהה צ'ק
cheque-field-number = מספר צ'ק
cheque-field-issued = תאריך הנפקה
cheque-field-place = מקום הנפקה
cheque-field-payee = מוטב
cheque-field-amount = סכום
cheque-field-comments = הערות
cheque-field-status = סטטוס הצ'ק
cheque-gone = הצ'ק הזה אינו קיים עוד.
cheque-updated = הצ'ק עודכן.

# שני פניו של חלון השיוך.
cheque-operations-linked-title = רשימת התנועות שכבר משויכות לצ'ק הזה.
cheque-operations-choose-title = יש לבחור תנועה לשיוך לצ'ק
cheque-operations-column-account = חשבון
cheque-operations-column-label = שם
cheque-operations-column-date = תאריך
cheque-operations-column-clearing = תאריך התאמה
cheque-operations-column-amount = סכום
cheque-operations-column-cheque = צ'ק משויך
cheque-operations-none-linked = אף תנועה אינה משויכת לצ'ק הזה.
cheque-operations-none = החשבון הזה אינו מכיל אף תנועה.
cheque-operations-nothing-to-show = אף תנועה אינה תואמת את החיפוש הזה.
cheque-operations-help = התנועות המודגשות נושאות כבר צ'ק.
cheque-operations-linked-help = הצלב האדום מנתק את הצ'ק מהתנועה: שום דבר אינו נמחק.
cheque-operations-linked = התנועה שויכה לצ'ק.
cheque-operations-dissociated = הצ'ק נותק מהתנועה.
cheque-operations-menu-filter = סינון
cheque-title-associate = שיוך התנועה הזו לצ'ק
cheque-title-dissociate = ניתוק הצ'ק מהתנועה הזו

# הכותרת "צ'ק הקשור לתנועה" שבכרטיס התנועה, ושני השלבים של איתור הצ'ק —
# תחילה הפנקס, ואחר כך הצ'ק.
chequebooks-select-question = יש לבחור את פנקס הצ'קים
cheques-select-question = יש לבחור את הצ'ק לשיוך לתנועה
operation-check-save-first = יש לשמור תחילה את התנועה: צ'ק משויך לתנועה שכבר קיימת.
operation-check-none = התנועה הזו אינה נושאת אף צ'ק.

# --- F36 / F37 — תבניות התנועה (שלב 10) ---------------------
# תבנית היא הזנה מוכנה מראש: מיישמים אותה כדי לא להקליד מחדש, והיא **דורסת**
# את מה שנמצא בכרטיס. שום דבר אינו יוצא לדיסק כל עוד כרטיס התנועה לא אושר
# (כלל של Fabrice, 29/07/2026).

window-operation-templates-title = רשימת תבניות התנועה
window-operation-template-title = כרטיס תבנית תנועה

operation-templates-none = לא נשמרה אף תבנית תנועה.
operation-templates-nothing-to-show = אף תבנית אינה תואמת את החיפוש הזה.
operation-templates-select-question = יש לבחור את התבנית ליישום
operation-templates-delete-question = האם לאשר את מחיקת התבניות שנבחרו?
operation-templates-deleted = { $count ->
    [one] נמחקה תבנית אחת.
    [two] נמחקו שתי תבניות.
   *[other] נמחקו { $count } תבניות.
}
operation-template-gone = התבנית הזו אינה קיימת עוד.
operation-template-fresh = תבנית חדשה.
operation-template-created = התבנית נשמרה.
operation-template-updated = התבנית עודכנה.
operation-template-label-required = הזנת שם היא חובה
operation-template-duplicate = כבר קיימת תבנית בשם זהה

# כרטיס F36, מקטע אחר מקטע — הכותרות המדויקות שלו.
operation-template-field-id = מזהה תבנית תנועה
operation-template-group-name = שם ברירת המחדל של התנועה העתידית לאחר יישום התבנית
operation-template-field-label = שם
operation-template-group-amount = סכום ברירת המחדל של התנועה כפי שהוגדר מראש בתבנית הזו
operation-template-field-direction = סוג תנועה
operation-template-field-amount = סכום
operation-template-group-status = סטטוס ברירת המחדל של התנועה בתבנית הזו
operation-template-field-status = סטטוס תנועה
operation-template-group-classification = נתוני התבנית לצורך סיווג וחישוב הסטטיסטיקה
operation-template-field-category = קטגוריה
operation-template-field-assignment = הקצאה
operation-template-field-mode = אמצעי
operation-template-field-payee = צד נגדי
operation-template-field-project = פרויקט

# כפתור "תבנית" שבכרטיס התנועה: סמל אחד, שתי פעולות.
operation-template-question = מה ברצונך לעשות עם תבניות התנועה?
operation-template-apply = יישום תבנית
operation-template-save-as = שמירה כתבנית
operation-template-applied = התבנית יושמה. יש לאשר את הכרטיס כדי לשמור אותה.
operation-template-saved-as = התנועה נשמרה כתבנית.
operation-template-needs-label = יש לתת שם לתנועה לפני הפיכתה לתבנית.

# --- F26 / F27 — התקציב (שלב 11) -----------------------------------
# שני פתחים, שתי שאלות: מזינים את התקציב, או בודקים אם הוא נשמר. הציר הוא
# סעיף התקציב, היחידה היא השנה, ומוסכמת הסימן היא זו של התנועות — הוצאה
# נכתבת בסימן שלילי.

window-budget-entry-title = הזנת תקציב: הוצאות(-) והכנסות(+) מתוכננות לשנה
window-budget-control-title = בקרת התקציב

budget-column-line = סעיף תקציב
budget-none = לא נשמר אף סעיף תקציב: התקציב מוזן לפי סעיף.
budget-planned = מתוכנן
budget-actual = בפועל
budget-sum = סיכום
budget-cumulative = מצטבר
budget-total = סך הכול
# התזכורת למוסכמת הסימן, באדום מתחת לטבלת ההזנה.
# המשפט שלו, מילה במילה וכולל הרווחים (צילום המסך "POINT 004 saisie
# budget.png"): הוא מופיע באדום מתחת לטבלה, וכותרת החלון חוזרת עליו בקיצור.
# איש לא היה מנחש את המוסכמת בלעדיו.
budget-sign-warning = חובה להזין את ההוצאות  בסימן שלילי ואת ההכנסות המתוכננות בסכומים חיוביים
budget-entry-help = יש להקליד את הסכומים בתאים, ולאחר מכן לשמור.
budget-saved = התקציב נשמר.
budget-nothing-changed = אין שינויים לשמירה.
budget-discard-question = האם לבטל את השינויים בתקציב?

# תפריט התצוגה של הבקרה: שתי הדרכים לקרוא את אותו הפרש.
budget-menu-display = תצוגה
budget-display-money = ערכים
budget-display-percent = אחוזים
budget-control-help = ירוק: לפחות כמו המתוכנן. אדום: פחות טוב.

# --- F09 — העברת סכום בין שני חשבונות (שלב 12) ----------
# העברה אינה תנועה אחת, היא שתיים: חובה בחשבון המקור, זכות בחשבון היעד.
# הן נשמרות יחד או שאינן נשמרות כלל.

window-transfer-title = העברת סכום בין שני חשבונות

transfer-group-source = חיוב הסכום בחשבון המקור הזה
transfer-group-target = זיכוי הסכום בחשבון היעד הזה
transfer-group-description = תיאור התנועה
transfer-group-nomenclature = נתוני יסוד
transfer-group-amount = סכום הכסף להעברה
transfer-field-source = חשבון מקור
transfer-field-target = חשבון יעד
transfer-field-label = תיאור
transfer-field-reference = אסמכתת תשלום
transfer-field-date = תאריך
transfer-field-status = סטטוס תנועה
transfer-field-clearing = תאריך התאמה
transfer-field-category = קטגוריה
transfer-field-mode = אמצעי תשלום
transfer-field-assignment = הקצאה
transfer-field-payee = צד נגדי / סוחרים
transfer-field-project = פרויקט
transfer-field-amount = סכום

# הכפתור היחיד בפאנלים שמודיעים במקום לשאול.
ui-ok = אישור
transfer-help = בחר את שני החשבונות: היתרות שלהם מוצגות כאן.
transfer-title-validate = ביצוע ההעברה
# שלוש היתרות של החשבון הנבחר, כדי לדעת מה ההעברה גוררת.
transfer-balances = { $account } — בבנק: { $bank } · בפועל: { $real } · סופית: { $final }
# הפאנל שמסכם את מה שנכתב זה עתה.
transfer-done = ההעברה בוצעה. { $amount } מהחשבון { $source } לחשבון { $target }, בתאריך { $date }.

transfer-refusal-accounts-required = בחר את חשבון המקור ואת חשבון היעד
transfer-refusal-same-account = חשבון המקור וחשבון היעד אינם יכולים להיות אותו חשבון: העברה עוברת מחשבון אחד לאחר
transfer-refusal-account-gone = אחד משני החשבונות אינו קיים עוד
transfer-refusal-label-required = התיאור הוא שדה חובה
transfer-refusal-date-required = התאריך הוא שדה חובה
transfer-refusal-amount = הסכום להעברה חייב להיות חיובי ממש

# ---------------------------------------------------------------------------
# שלב 13 — ייבוא גיליון Excel (F34, F35, שיוך).
# ---------------------------------------------------------------------------

window-excel-import-title = ייבוא גיליון excel [ שלב 1/3 ]: הגדרת אזור הלכידה
window-excel-fields-title = ייבוא גיליון excel [ שלב 2/3 ]: שיוך השדות
window-excel-association-title = ייבוא גיליון excel: שיוך הנתונים

# השאלה הנשאלת בפתיחה. קובץ Excel נעשה ביד:
# הוא מכיל את מה שהוא מכיל, וחלק מהשטויות שהוא נושא
# אינו ניתן לגילוי. לכן מציעים את הרשת לפני הקפיצה.
excel-backup-question = גיליון Excel נעשה ביד: הוא עשוי להכיל תאריכים תקינים אך שגויים, סכומים בפורמט הנכון ובסימן ההפוך — ואת זה שום בדיקה אינה יכולה לראות. הייבוא יכתוב את השורות האלה בחשבון שלך. האם לגבות את הנתונים לפני שמתחילים?

excel-group-file = 1 - ציון קובץ ה-Excel לייבוא
excel-pick = ציון קובץ ה-Excel
excel-sheet = גיליון בחוברת:
excel-group-header = 2 - הגדרה: נקודות התאים של שורת הכותרת בטבלה שבה כתובים שמות העמודות.
excel-header-row = מספר השורה הראשונה שבה נמצאים שמות העמודות
excel-first-column = עמודת תחילת הכותרת ( העמודה הראשונה משמאל ):
excel-column-count = מספר העמודות בטבלה
excel-group-rows = 3 - הגדרה: מספרי שורת ההתחלה ושורת הסיום של הרשימה המכילה את נתוני הטבלה ( מתחת לכותרת ובלי לכלול אותה )
excel-first-data-row = השורה הראשונה המכילה נתונים
excel-last-data-row = השורה האחרונה המכילה נתונים:
excel-group-shape = 4 - הגדרה: כיצד הקובץ שלך כותב את הסכומים
excel-shape-single = עמודת סכומים אחת בלבד, עם סימן ( ההוצאות בשלילי )
excel-shape-debit-credit = שתי עמודות נפרדות: עמודת חובה ועמודת זכות
excel-shape-note = במצב שתי העמודות, הסימן הכתוב בעמודת החובה אינו נלקח בחשבון: חובה תמיד מוציאה כסף, בין אם נרשמה "-50" ובין אם נרשמה "50".
excel-group-test = 5 - תצוגת בדיקה: הצג את הלכידה שבוצעה לפי ההגדרות שלך
excel-test = בדוק את ההגדרות שקבעת בשלבים 2, 3 ו-4.
excel-test-note = הערה: שמות הכותרות ותוכן הטבלה שלהלן צריכים להתאים לאלה שבטבלת ה-Excel שלך. אזור הלכידה אינו צריך לחרוג מחוץ לאזור הטבלה.

excel-help = עבור על חמש הקבוצות לפי הסדר, ואז בדוק: לא תוכל לעבור לשלב 2 לפני שתראה מה האזור לוכד.
excel-no-file = ציין קודם את קובץ ה-Excel לייבוא.
excel-not-tested = ההגדרות שונו: הפעל שוב את תצוגת הבדיקה לפני האישור.
excel-tested = אזור נלכד: { $rows } שורות, { $columns } עמודות. ודא שהטבלה שלהלן דומה לגיליון שלך.
excel-empty-capture = האזור שהגדרת אינו לוכד אף שורה: בדוק את מספרי השורות והעמודות.
excel-title-next = מעבר לשלב הבא
excel-into-account = ייבוא לחשבון { $account }.

excel-tab-links = קישורים בין שדות
excel-tab-settings = פרמטרים לייבוא
excel-column-excel = כותרת_Excel
excel-column-radinus = שדה_Radinus
excel-links-help = מול כל עמודה בגיליון שלך, ציין איזה שדה של Radinus היא מזינה. עמודות שנשארו ב-[IGNORE] אינן מיובאות.
excel-group-category = קטגוריות ללא התאמה
excel-group-payment-mode = אמצעי תשלום ללא התאמה
excel-group-assignment = הקצאה ללא התאמה
excel-policy-create = { $kind ->
    [payment-mode] ליצור אוטומטית אמצעי תשלום שאינם קיימים
    [assignment] ליצור אוטומטית הקצאות שאינן קיימות
   *[category] ליצור אוטומטית קטגוריות שאינן קיימות
}
excel-policy-ask = { $kind ->
    [payment-mode] לשאול עבור כל אמצעי תשלום שאינו קיים לאן להעביר את הנתונים
    [assignment] לשאול עבור כל הקצאה שאינה קיימת לאן להעביר את הנתונים
   *[category] לשאול עבור כל קטגוריה שאינה קיימת לאן להעביר את הנתונים
}
excel-policy-blank = { $kind ->
    [payment-mode] להשאיר את אמצעי התשלום ריק
    [assignment] להשאיר את ההקצאה ריקה
   *[category] להשאיר את הקטגוריה ריקה
}
excel-policy-default = { $kind ->
    [payment-mode] להעביר אמצעי תשלום שאינם קיימים לאמצעי תשלום ברירת מחדל
    [assignment] להעביר הקצאות שאינן קיימות להקצאת ברירת מחדל
   *[category] להעביר קטגוריות שאינן קיימות לקטגוריית ברירת מחדל
}
excel-define-destination = הגדרת יעד
excel-not-linked = { $kind ->
    [payment-mode] אף עמודה אינה מזינה את אמצעי התשלום: ההגדרה הזו אינה חלה.
    [assignment] אף עמודה אינה מזינה את ההקצאה: ההגדרה הזו אינה חלה.
   *[category] אף עמודה אינה מזינה את הקטגוריה: ההגדרה הזו אינה חלה.
}
excel-fields-help = כוונן את ההתאמות, ואז את שלושת כללי המדיניות, לפני הפעלת הייבוא.
excel-title-import = הפעלת הייבוא

excel-refusal-required = השדות תאריך, תיאור וסכום חייבים להצביע על עמודות excel
excel-refusal-column-twice = שדות Radinus שונים מצביעים על אותה עמודת excel: עמודה יכולה להזין שדה אחד בלבד
excel-refusal-field-twice = אותו שדה Radinus משויך לשתי עמודות excel: יכולה להיות לו רק עמודה אחת
excel-refusal-ask-unset = { $kind ->
    [payment-mode] בחרת לשאול לאן להעביר את אמצעי התשלום הלא מוכרים: לחץ על "הגדרת יעד" לפני הפעלת הייבוא.
    [assignment] בחרת לשאול לאן להעביר את ההקצאות הלא מוכרות: לחץ על "הגדרת יעד" לפני הפעלת הייבוא.
   *[category] בחרת לשאול לאן להעביר את הקטגוריות הלא מוכרות: לחץ על "הגדרת יעד" לפני הפעלת הייבוא.
}

excel-column-data = נתונים_Excel
excel-column-destination = { $kind ->
    [payment-mode] אמצעי-תשלום_Radinus
    [assignment] הקצאה_Radinus
   *[category] קטגוריה_Radinus
}
excel-association-help = מול כל ערך שהגיע מהגיליון שלך, בחר את הערך של Radinus שאליו יש לשייך אותו. שורה שתישאר ריקה תישאר ללא סיווג.
excel-association-none = אין אף ערך לא מוכר: כל מה שהגיליון שלך נושא כבר קיים ב-Radinus.

excel-imported = הייבוא הסתיים: { $count } תנועות נכתבו, { $refused } שורות נדחו, { $created } ערכי נתוני יסוד נוצרו.
excel-report-title = דוח הייבוא
excel-column-row = שורת Excel
excel-column-content = תוכן
excel-column-reason = סיבת הדחייה
excel-nothing-refused = כל השורות בגיליון שלך נכנסו: אין אף דחייה.

excel-refused-date = תאריך חסר או בלתי קריא
excel-refused-amount = סכום חסר או בלתי קריא
excel-refused-amount-both = סכום בעמודת החובה וסכום אחר בעמודת הזכות: לא ניתן לבחור
excel-refused-amount-missing = אין חובה ואין זכות בשורה הזו

# ---------------------------------------------------------------------------
# שלב 16 — התנועות החוזרות (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = רשימת התנועות החוזרות
window-recurring-form-title = כרטיס המגדיר את כלל יצירת התנועה החוזרת
window-recurring-calendar-title = הצעת לוח זמנים של התנועות להכנסה לחשבונות הבנק שלך

recurring-column-label = תיאור
recurring-none = לא נשמר אף כלל חוזר.
recurring-help = בחר כלל, ואז את לוח הזמנים כדי לראות את תאריכי הפירעון שהוא מציע.
recurring-title-calendar = הצעת לוח זמנים של תאריכי הפירעון
recurring-deleted = { $count ->
    [0] לא נמחק אף כלל.
    [one] כלל אחד נמחק. התנועות שלו נשארות בחשבון.
    [two] שני כללים נמחקו. התנועות שלהם נשארות בחשבונות.
   *[other] { $count } כללים נמחקו. התנועות שלהם נשארות בחשבונות.
}
recurring-gone = הכלל הזה אינו קיים עוד.
recurring-delete-question = האם למחוק את הכללים שנבחרו? התנועות שהם כבר הכניסו יישארו בחשבונות שלך.

recurring-group-identity = זיהוי וחשבון הבנק הנוגע בדבר
recurring-group-nomenclature = נתוני יסוד
recurring-group-amount = הגדרת סכום התנועה
recurring-group-period = הגדרת התקופה
recurring-group-ending = תנאי סיום התקופה
recurring-group-produced = מידע על תנועות שכבר הוכנסו ( לעיון בלבד )

recurring-field-id = מזהה התנועה
recurring-field-account = חשבון היעד
recurring-field-label = תיאור
recurring-field-category = קטגוריה
recurring-field-mode = אמצעי תשלום
recurring-field-assignment = הקצאה
recurring-field-payee = צד נגדי / סוחרים
recurring-field-project = פרויקט
recurring-field-direction = סוג התנועה
recurring-field-amount = סכום
recurring-field-next = תאריך התנועה הבאה
recurring-field-every = ואז כל
recurring-field-end-date = תאריך סיום
recurring-field-repeat = מספר חזרות
recurring-field-guid = GUID של התנועה
recurring-field-produced-count = מספר התנועות שהוכנסו
recurring-field-produced-last = תאריך התנועה האחרונה שהוכנסה
recurring-field-produced-total = סך הסכומים שנוצרו

recurring-unit-day = יום
recurring-unit-week = שבוע
recurring-unit-month = חודש
recurring-unit-quarter = רבעון
recurring-unit-year = שנה
recurring-ending-no-limit = ללא הגבלה
recurring-ending-until-date = עם תאריך סיום
recurring-ending-repeat-count = מספר חזרות

recurring-title-erase = מחיקת התנועות שכבר הוכנסו על ידי הכלל הזה
recurring-erase-question = { $count ->
    [one] הכלל הזה הכניס תנועה אחת לחשבונות שלך. האם למחוק אותה? היתרות יחושבו מחדש, והכלל לא ייסוג.
    [two] הכלל הזה הכניס שתי תנועות לחשבונות שלך. האם למחוק את שתיהן? היתרות יחושבו מחדש, והכלל לא ייסוג.
   *[other] הכלל הזה הכניס { $count } תנועות לחשבונות שלך. האם למחוק את כולן? היתרות יחושבו מחדש, והכלל לא ייסוג.
}
recurring-erase-none = הכלל הזה עדיין לא הכניס אף תנועה.
recurring-erased = { $count ->
    [0] לא נמחקה אף תנועה.
    [one] תנועה אחת נמחקה, היתרות חושבו מחדש.
    [two] שתי תנועות נמחקו, היתרות חושבו מחדש.
   *[other] { $count } תנועות נמחקו, היתרות חושבו מחדש.
}

recurring-calendar-help = הסר בעזרת סל המיחזור את תאריכי הפירעון שאינך רוצה, ואז אשר כדי להכניס אותם.
recurring-calendar-none = אין אף תאריך פירעון להצעה: בדוק את תאריך התנועה הבאה ואת החשבון של הכללים שלך.
recurring-calendar-column-account = חשבון
recurring-calendar-column-date = תאריך
recurring-calendar-column-label = תיאור
recurring-calendar-column-amount = סכום
recurring-calendar-column-category = קטגוריה
recurring-calendar-column-assignment = הקצאה
recurring-calendar-column-mode = אמצעי תשלום
recurring-calendar-column-payee = צד נגדי
recurring-calendar-column-project = פרויקטים
recurring-calendar-removed = { $count ->
    [one] תאריך פירעון אחד הוסר מההצעה.
    [two] שני תאריכי פירעון הוסרו מההצעה.
   *[other] { $count } תאריכי פירעון הוסרו מההצעה.
}
recurring-title-insert = הכנסת תאריכי הפירעון שנבחרו לחשבונות
recurring-nothing = לא נותר אף תאריך פירעון להכנסה.
# השאלה הנשאלת לפני הכתיבה: הכנסת לוח זמנים יוצרת תנועות אמיתיות
# בחשבונות אמיתיים, וזה לא נעשה בלחיצה מוסחת.
recurring-insert-question = { $count ->
    [one] האם להכניס את תאריך הפירעון הזה לחשבון שלך? תיווצר תנועה אחת והיתרות יחושבו מחדש.
    [two] האם להכניס את שני תאריכי הפירעון האלה לחשבונות שלך? ייווצרו שתי תנועות והיתרות יחושבו מחדש.
   *[other] האם להכניס את { $count } תאריכי הפירעון האלה לחשבונות שלך? ייווצרו תנועות באותו מספר והיתרות יחושבו מחדש.
}
recurring-inserted = { $count ->
    [one] תנועה אחת הוכנסה. הכלל ממשיך אחרי תאריך הפירעון האחרון שהוכנס.
    [two] שתי תנועות הוכנסו. הכללים ממשיכים אחרי תאריך הפירעון האחרון שהוכנס.
   *[other] { $count } תנועות הוכנסו. הכללים ממשיכים אחרי תאריך הפירעון האחרון שהוכנס.
}

recurring-refusal-label-required = הזנת תיאור היא חובה
recurring-refusal-date-required = הזנת תאריך התנועה הבאה היא חובה
recurring-refusal-date-too-old = תאריך התנועה הבאה חייב להיות שווה לשנת 2000 או מאוחר ממנה
recurring-refusal-account-gone = חשבון הבנק שצוין אינו נמצא, יש לבחור חשבון חדש כדי שהכלל יהיה בר-יישום
recurring-refusal-end-required = אם נבחר תאריך סיום, יש להזין את התאריך
recurring-refusal-end-before-start = תאריך הסיום אינו יכול להיות מוקדם מתאריך התנועה הבאה
recurring-refusal-end-too-far = ההפרש בין תאריך התנועה הבאה לתאריך הסיום אינו יכול לעלות על 10 000 ימים

# --- שלב 15 — ההדפסות והדוחות -------------------------------
# הכותרת הגדולה של הכרזה, מועתקת מילה במילה מדוח WinDev המקורי.
print-operations-title = רשימת התנועות הבנקאיות ותת-התנועות
print-menu-operations-pdf = הדפסה לקובץ PDF
print-recap-title = סיכום לפי קטגוריה
print-recap-count = שורות
print-row-count = מספר שורות:
print-total-debit = סך החובה:
print-total-credit = סך הזכות:
print-final-balance = יתרה סופית:
print-licence = Radinus היא תוכנה חופשית המופצת ברישיון GNU GPL v3 או מאוחר יותר
print-nothing = אין מה להדפיס.
print-done = הדוח הודפס ונפתח: "{ $file }".
print-failed = ההדפסה נכשלה: { $reason }
# ה-PDF אכן נכתב, אך המערכת לא ידעה לפתוח אותו: אומרים זאת בלי
# ליצור רושם של כישלון, שכן הקובץ נמצא שם.
print-not-opened = הדוח הודפס אל "{ $file }", אך המערכת שלך לא ידעה לפתוח אותו בעצמה.

# --- דוח פרטי הזיהוי הבנקאי (F32) --------------------------------------
# הכיתובים של דף פרטי הזיהוי הבנקאי, מועתקים מהמסמך המקורי.
rib-title = פרטי זיהוי בנקאי
rib-bank = בנק:
rib-national = RIB - מזהה לאומי של חשבון
rib-establishment = מוסד
rib-branch = סניף
rib-number = מספר חשבון
rib-key = ספרת ביקורת RIB
rib-domiciliation = כתובת הסניף
rib-iban = IBAN - מזהה בינלאומי של חשבון
rib-bic = BIC - מזהה בינלאומי של המוסד
rib-holder = בעל החשבון

# --- החלון F32 ----------------------------------------------------
window-rib-title = הדפסת RIB ( פרטי זיהוי בנקאי )
rib-group-bank = בנק
rib-group-holder = בעל החשבון
rib-group-details = פרטי חשבון בנק
rib-field-bank = שם הבנק
rib-field-domiciliation = כתובת הסניף
rib-field-holder = שם בעל החשבון
rib-field-address = כתובת
rib-field-establishment = מוסד
rib-field-branch = סניף
rib-field-number = מספר חשבון
rib-field-key = ספרת ביקורת RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = תנאי שימוש חשובים שיש להקפיד עליהם בהכרח בעת ההדפסה
rib-declaration = אני החתום מטה, המשתמש בתוכנה, מצהיר בזאת:
rib-declaration-first = - מאשר כי בדקתי מול הבנק שלי שפרטי החשבון המופיעים בחלון זה נכונים ותואמים את רצוני. מאשר באותו אופן כי אני מתחייב לבדוק שהפרטים המופיעים בדוח ההדפסה של פרטי הזיהוי הבנקאי נכונים ותואמים את רצוני. הדפסה זו והשימוש בפרטי הזיהוי הבנקאי ייעשו באחריותי המלאה
rib-declaration-second = - להיות בעל החשבון שפרטי הזיהוי הבנקאי שלו יודפסו, ולא להשתמש בפונקציות של תוכנה זו למטרה הנוגדת את החוק.
rib-title-print = הדפסה במדפסת
rib-title-pdf = הדפסה לקובץ PDF
# התיבה אינה אזהרה דקורטיבית: כל עוד היא אינה מסומנת,
# שני הכפתורים כבויים (החלטת Fabrice, 01/08/2026).
rib-declaration-required = יש לסמן את הצהרת הכבוד כדי לאפשר הדפסה.
rib-help = יש לבדוק את הפרטים, לסמן את ההצהרה, ואז להדפיס.
rib-account-gone = חשבון בנק זה אינו נמצא.
rib-fields-read-only = פרטים אלה מגיעים מכרטיס החשבון: יש לתקן אותם בכרטיס כדי לשנות אותם כאן.
rib-printed = פרטי הזיהוי הבנקאי נשלחו למדפסת ברירת המחדל שלך.
rib-print-failed = ההדפסה נכשלה: { $reason }
rib-pdf-done = פרטי הזיהוי הבנקאי הודפסו ונפתחו: "{ $file }".
rib-pdf-not-opened = פרטי הזיהוי הבנקאי הודפסו אל "{ $file }", אך המערכת שלך לא ידעה לפתוח אותם בעצמה.
menu-accounts-bank-details = הפקת דף פרטי זיהוי בנקאי

# בחירת המדפסת. Radinus שואל את השאלה בעצמו: אף אחד משלושת
# ה-webviews אינו פותח את תיבת ההדפסה של המערכת.
print-choose-printer = באיזו מדפסת להדפיס?
print-do-print = הדפסה
rib-printed-on = פרטי הזיהוי הבנקאי נשלחו למדפסת "{ $printer }".
ui-cancel = ביטול

# המערכת לא ידעה לנקוב בשמה של אף מדפסת: מדפיסים בכל זאת במדפסת
# ברירת המחדל במקום לחסום את המשתמש.
print-printers-unknown = המערכת שלך לא ידעה לנקוב בשמה של אף מדפסת: המסמך נשלח למדפסת ברירת המחדל.

print-menu-operations-printer = הדפסה במדפסת
print-sent-on = הדוח נשלח למדפסת "{ $printer }".
print-sent-default = הדוח נשלח למדפסת ברירת המחדל שלך.

# --- שלב 17 — הפעולות על מסד הנתונים -------------------
backup-archive = ארכיון Radinus
backup-no-database = אין מסד נתונים פתוח.
backup-done = הגיבוי של מסד הנתונים "{ $base }" נכתב אל "{ $file }". מסדי הנתונים האחרים אינם מושפעים.
backup-failed = הגיבוי נכשל: { $reason }
backup-not-started = לא ניתן היה להתחיל את הגיבוי:
restore-unreadable = קובץ זה אינו ארכיון Radinus קריא: { $reason }
# השאלה אומרת מה יאבד לפני שהוא אובד. הארכיון כבר נקרא
# ברגע הזה: מה שהוא מכריז הוא ודאי.
restore-question = לשחזר את "{ $file }" לתוך מסד הנתונים "{ $base }"? כל התוכן הנוכחי של מסד נתונים זה יימחק ויוחלף, ומה שנמצא בו יאבד. לא נוגעים במסדי הנתונים האחרים.
restore-done = מסד הנתונים "{ $base }" שוחזר: { $accounts } חשבונות ו-{ $operations } תנועות. לא נוגעים במסדי הנתונים האחרים.
restore-failed = השחזור נכשל: { $reason }
restore-empty-fields = שדות ריקים שנקראו כערך אפס: { $count }.


# --- יומן הפעולות הטכניות (שלב 17) --------------------
# שלושת הסטטוסים של Ajoute_Log שלו, באותיות גדולות כמו אצלו.
journal-status-success = הצלחה
journal-status-failure = כישלון
journal-status-repaired = תוקן
journal-step-reindex = תיקון טבלה במסד הנתונים
journal-step-refill = נתוני יסוד של המערכת ריקים: ערכי ברירת המחדל שוחזרו
journal-step-table-created = טבלה חסרה במסד הנתונים: נוצרה מחדש ריקה
journal-step-column-added = עמודה חסרה בטבלה: נוספה עם ערך ברירת המחדל שלה

# --- Protection par mot de passe (05/08/2026) ---
password-protect = הגנה בסיסמה
window-password-form-title = הגנה בסיסמה
password-ask = מסד הנתונים הזה מוגן. הזן את הסיסמה שלו.
password-group-database = מסד הנתונים הנוגע בדבר
password-group-password = סיסמה
password-group-warning = לפני האישור
password-field-old = סיסמה ישנה
password-field-new = סיסמה חדשה
password-field-repeat = חזור על הסיסמה החדשה
password-hint = השאר את הישנה ריקה אם מסד הנתונים עדיין אינו מוגן. השאר את שתי החדשות ריקות כדי להסיר את ההגנה.
password-lost-warning = סיסמה אבודה היא מסד נתונים אבוד: דבר אינו מאפשר לשחזר אותו. הגיבויים, לעומת זאת, נשארים לא מוצפנים.
password-show = הצג את הסיסמה
password-remove-question = להסיר את ההגנה ממסד נתונים זה?
password-mismatch = שתי ההקלדות של הסיסמה החדשה שונות
password-wrong = הסיסמה אינה מתאימה
database-too-recent = מסד נתונים זה נשמר בגרסה חדשה יותר של Radinus (גרסת מסד { $found }; גרסה זו קוראת עד גרסה { $supported }). עדכנו את Radinus כדי לפתוח אותו.
database-not-radinus = קובץ זה אינו מסד נתונים של Radinus.
database-unreadable = לא ניתן היה לקרוא את מסד הנתונים: { $reason }
password-close-first = סגור מסד נתונים זה לפני שינוי הסיסמה שלו
password-now-protected = מסד הנתונים מוגן בסיסמה
password-now-clear = מסד הנתונים אינו מוגן עוד
journal-step-date-fixed = תיקון תנועה ללא תאריך
journal-step-circular = מחיקת תנועה לא עקבית: הפניה מעגלית
journal-step-flag-parent-true = דגל שגוי EstParent=Faux על תנועה ראשית
journal-step-flag-parent-false = דגל שגוי EstParent=Vrai על תנועה ראשית
journal-step-flag-child = דגל שגוי EstParent=Vrai על תת-תנועה
journal-step-orphan = מחיקת תת-תנועה יתומה
journal-step-third-level = מחיקת תת-תנועה המשויכת לתת-תנועה אחרת
journal-step-coherence = חישוב מחדש כללי של העקביות בין תת-התנועות לתנועות הראשיות
journal-step-balances = חישוב מחדש של כל היתרות בכל החשבונות
journal-step-vacuum = ייעול קובץ מסד הנתונים
journal-step-analyze = עדכון סטטיסטיקות החיפוש
journal-step-backup-begin = תחילת הגיבוי של מסד הנתונים
journal-step-backup-end = סיום הגיבוי של מסד הנתונים
journal-step-restore-begin = תחילת השחזור של מסד הנתונים מתוך הארכיון
journal-step-restore-end = סיום השחזור של מסד הנתונים מתוך הארכיון
journal-step-restore-read = קריאת הארכיון

# --- חלון היומן (⌘H) -----------------------------------------
window-journal-title = יומן הפעולה הטכנית האחרונה
journal-column-step = שלב
journal-column-file = קובץ
journal-column-table = טבלה
journal-column-status = סטטוס
journal-column-error = שגיאה
journal-column-comments = הערות
journal-empty = טרם בוצעה שום פעולה טכנית מאז פתיחת התוכנה.
journal-help = היומן שומר רק את הפעולה הטכנית האחרונה: גיבוי, שחזור, תיקון, מחיקה או פתיחת מסד נתונים.

# --- התיקון ------------------------------------------------------
menu-file-repair-running = תיקון וייעול מתבצעים…
repair-done = { $anomalies ->
    [0] התיקון של מסד הנתונים "{ $base }" הסתיים: לא נמצאה אף תקלה. { $lines } שלבים נרשמו ביומן. מסדי הנתונים האחרים אינם מושפעים.
    [one] התיקון של מסד הנתונים "{ $base }" הסתיים: תקלה אחת תוקנה. { $lines } שלבים נרשמו ביומן. מסדי הנתונים האחרים אינם מושפעים.
    [two] התיקון של מסד הנתונים "{ $base }" הסתיים: שתי תקלות תוקנו. { $lines } שלבים נרשמו ביומן. מסדי הנתונים האחרים אינם מושפעים.
   *[other] התיקון של מסד הנתונים "{ $base }" הסתיים: { $anomalies } תקלות תוקנו. { $lines } שלבים נרשמו ביומן. מסדי הנתונים האחרים אינם מושפעים.
}
repair-failed = התיקון נכשל: { $reason }

journal-status-started = בביצוע
journal-status-finished = הסתיים
journal-step-backup-table = כתיבת הטבלה אל הארכיון
journal-step-backup-write = כתיבת הארכיון
journal-step-backup-verified = אימות הארכיון שנכתב: קבצים שנקראו מחדש / צפויים, רשומות שנקראו מחדש / נכתבו
journal-step-backup-total = סך הכול גובה: רשומות, נתונים, גודל הקובץ
journal-step-restore-table = קריאת הטבלה מתוך הארכיון
journal-step-restore-missing = הקובץ חסר בארכיון: טבלה זו לא תשוחזר
journal-step-restore-wipe = מחיקה מוחלטת של תוכן מסד הנתונים לפני השחזור
journal-step-restore-write = כתיבה אל מסד הנתונים
journal-step-restore-total = סך הכול שוחזר: חשבונות, תנועות
journal-step-restore-empty-fields = שדות ריקים שהושלמו בעת הקריאה
backup-verify-mismatch = הארכיון שנכתב אינו נקרא מחדש כפי שנכתב: אין להסתמך עליו, יש לבצע את הגיבוי מחדש.

# --- הקבצים המצורפים של תנועה (F28, שלב 17) -----------------
window-attachments-title = קבצים מצורפים של התנועה
attachment-filter = מסמכים מותרים
attachment-none = לתנועה זו אין שום קובץ מצורף.
attachment-title-add = צירוף מסמך לתנועה זו
attachment-title-open = פתיחת הקובץ המצורף
attachment-title-remove = הסרת הקובץ המצורף ושליחת הקובץ שלו לסל המיחזור
# מצב הקובץ בדיסק. "לא ניתן לאימות" אינו הודאה שרירותית בבורות:
# הטביעות שהגיעו מ-Radinus 1.9.3 קטועות בשל פורמט
# הגיבוי, ושיפוט קובץ על פיהן היה כמו האשמה אקראית.
attachment-state-ok = תקין
attachment-state-changed = שונה
attachment-state-missing = הקובץ חסר
attachment-state-unknown = לא ניתן לאימות
attachment-added = "{ $name }" צורף לתנועה.
attachment-removed = הקובץ המצורף הוסר, הקובץ שלו נמצא בסל המיחזור.
attachment-removed-kept = הקובץ המצורף הוסר, אך לא ניתן היה להעביר את הקובץ שלו לסל המיחזור.
attachment-remove-question = להסיר את "{ $name }" מתנועה זו? הקובץ שלו יישלח לסל המיחזור.
attachment-opened = "{ $name }" נפתח.
attachment-opened-changed = "{ $name }" נפתח, אך התוכן שלו השתנה מאז שצורף.
attachment-gone = קובץ מצורף זה אינו קיים עוד.
attachment-file-missing = הקובץ של "{ $name }" אינו נמצא בדיסק.
attachment-failed = הפעולה נכשלה: { $reason }
attachment-save-first = יש לשמור תחילה את התנועה: קובץ מצורף משויך לתנועה שקיימת.
attachment-refusal-missing = קובץ זה אינו קיים.
attachment-refusal-extension = סוג קובץ זה אינו מותר. הסוגים המותרים: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = התנועה שאליה יש לצרף מסמך זה אינה קיימת.
journal-step-backup-attachments = קבצים מצורפים נוספו לארכיון
journal-step-backup-attachment-missing = קובץ מצורף אינו נמצא בדיסק: הוא יחסר בארכיון
journal-step-restore-attachments = קבצים מצורפים חולצו מהארכיון
attachment-title-replace = החלפת המסמך של הקובץ המצורף הזה
attachment-replaced = המסמך הוחלף ב-"{ $name }".

# ---------------------------------------------------------------------
# F08 — תפריט "כלים" של כרטיס החשבון.
#
# שלוש הכניסות שלו הן הסבות של קוד ה-WLangage של Fabrice (תיקייה
# "Information import export base piece jointe"): חישוב היתרה
# ההתחלתית המותאמת, הסטטיסטיקה של החשבון, ומחיקת כל
# התנועות שלו. התפריט פועל רק במצב עריכה (החלטת
# 02/08/2026): ביצירה אין מה לספור, בצפייה
# הכרטיס רק מציג.
# ---------------------------------------------------------------------

account-tools = כלים
account-tools-initial-balance = הגדרת היתרה ההתחלתית המותאמת
account-tools-statistics = סטטיסטיקה של חשבון הבנק
account-tools-delete-operations = מחיקת כל התנועות של החשבון

# שאלת החישוב, מילה במילה כמו במקור. { $total } הוא
# סך התנועות המותאמות, כבר כתוב בפורמט כספי.
account-initial-balance-question =
    כדי לחשב את היתרה ההתחלתית המותאמת ביחס לתנועות הקיימות בחשבון זה, נא להזין את היתרה הנוכחית בבנק שלך
    היתרה ההתחלתית המותאמת תחושב כשווה ל:
    { "[" }יתרה נוכחית בבנק] - [סך התנועות המותאמות ({ $total }) ].
    { "" }
    כדי לא להידרש להזין ערך זה שוב, עליך להיות מעודכן לחלוטין ברשימת התנועות הבנקאיות בחשבון זה.

account-statistics-none = אין תנועות

# ארבע-עשרה השורות של ה-Info() שלו. שגיאת הכתיב "pengagés" שבמקור
# מתוקנת, לפי החלטת Fabrice מ-02/08/2026 — כמו "Bank
# Identifer Code" באותו כרטיס.
account-statistics =
    מספר התנועות הכולל בחשבון זה: { $count }
    { "" }
    מספר התנועות המותאמות בחשבון זה: { $pointed }
    סכום החובות המותאמים: { $pointedDebits }
    סכום הזכויות המותאמות: { $pointedCredits }
    ההפרש בין הזכויות לחובות המותאמים: { $pointedDifference }
    { "" }
    מספר התנועות המשוריינות בחשבון זה: { $committed }
    סכום החובות המשוריינים: { $committedDebits }
    סכום הזכויות המשוריינות: { $committedCredits }
    ההפרש בין הזכויות לחובות המשוריינים: { $committedDifference }
    { "" }
    מספר התנועות המתוכננות בחשבון זה: { $planned }
    סכום החובות המתוכננים: { $plannedDebits }
    סכום הזכויות המתוכננות: { $plannedCredits }
    ההפרש בין הזכויות לחובות המתוכננים: { $plannedDifference }
    { "" }
    התנועה הישנה ביותר: { $first }
    התנועה החדשה ביותר: { $last }

# המחסום הכפול של המחיקה. { $word } הוא ה"כן" של השפה המדוברת — דובר
# ספרדית שיתבקש לכתוב OUI לא יבין על מה מדובר (החלטת Fabrice,
# 02/08/2026).
account-delete-operations-question =
    האם אתה בטוח שברצונך למחוק את כל התנועות שבחשבון הבנק?
    לאישור כתוב { $word } בשדה שלמטה ואשר

account-delete-operations-done =
    { $count ->
        [0] לא נמחקה אף תנועה.
        [one] נמחקה תנועה אחת.
        [two] נמחקו שתי תנועות.
       *[other] נמחקו { $count } תנועות.
    }

# ---------------------------------------------------------------------
# בורר מסדי הנתונים ובחירת השפה (02/08/2026)
#
# החלטות שהתקבלו בשיחה עם Fabrice: Radinus אינו יוצר עוד מסד נתונים
# ללא רשות; בלי שפה בהגדרות הוא שואל לשפה לפני כל דבר אחר; מסד נתונים
# הוא כל תיקייה בתוך databases/ שיש בה radinus.sqlite, יהיה שמה אשר
# יהיה.
#
# לחלון בחירת השפה אין כאן שום מפתח: הוא אינו משתמש בשום משפט, וזה מה
# שמאפשר להבין אותו עוד לפני שיודעים באיזו שפה המשתמש מדבר.
# ---------------------------------------------------------------------

window-database-selector-title = מסדי נתונים
window-database-form-title = מסד נתונים חדש
database-group-identity = זיהוי מסד הנתונים
database-group-restore = אתחול מסד הנתונים בעזרת נתונים מגיבוי
database-choose-backup = בחירת קובץ גיבוי
database-no-backup = לא נבחר גיבוי: מסד הנתונים ייווצר ריק.

databases-column-label = מסד
databases-column-comment = הערה
databases-column-folder = תיקייה
databases-column-created = נוצר בתאריך

databases-none = אין עדיין שום מסד נתונים: צור אחד.
databases-help = בחר את המסד לפתיחה, או צור מסד חדש.
databases-select = בחר תחילה מסד נתונים מתוך הרשימה.
databases-tools = כלים
databases-title-open = פתיחת מסד זה

database-created = מסד הנתונים "{ $label }" נוצר.
database-field-label = שם המסד
database-field-comment = הערה
database-label-required = תן שם למסד הזה: הוא שיבדיל אותו מן האחרים.
database-gone = המסד הזה אינו כאן עוד: הוא הועבר או נמחק מאז שנפתח החלון הזה.

# מחיקת מסד נתונים (02/08/2026). התיקייה עוברת לסל המיחזור של המערכת,
# כמו הקבצים המצורפים: מסד שנמחק בטעות חוזר בלחיצה ימנית. המסד הפתוח
# נדחה — Radinus מחזיק בקובץ שלו.
databases-title-delete = מחיקת מסד זה
database-delete-question =
    האם אתה בטוח שברצונך למחוק את מסד הנתונים "{ $label }"?
    { "" }
    כל התיקייה שלו עוברת לסל המיחזור: התנועות, החשבונות והקבצים המצורפים.
    לאישור, כתוב { $word } בשדה שלמטה ואשר.
database-in-use = מסד הנתונים הזה פתוח: Radinus אינו יכול למחוק אותו. פתח תחילה מסד אחר.
database-deleted = מסד הנתונים "{ $label }" נמצא בסל המיחזור.

# לבורר יש שני מצבים (Fabrice, 02/08/2026). כשהוא נפתח תוך כדי עבודה,
# הוא אינו יודע עוד לפתוח: חלון של Radinus נבנה פעם אחת ולעולם אינו
# נהרס, ושום דבר לא יגרום לו לשכוח את המסד שהוא מציג. מעיינים, יוצרים,
# מוחקים — וכדי להחליף מסד, יוצאים.
database-quit-first = כדי לפתוח את המסד הזה, צא מ-Radinus והפעל אותו מחדש: הבורר יציע לך אותו בהפעלה.


# --- F01 — חלון הפתיחה (שלב 17 bis, 03/08/2026) ---------------------------
#
# התוספת הראשונה של 2.0.0 על 1.9.3: חלון הפתיחה אינו נושא עוד את הכרזה
# בלבד. הכלל השולט בו כתוב במסמך 04 F01: זוהי התצוגה ללא ולו לחיצה אחת,
# ושום דבר שדורש כוונון אינו נכנס אליה.
#
# שתי כותרות תרשימי הטבעת נושאות את החודש כולו במקום שהחלון ידביק אותן זו
# לזו: ל"הוצאות ... — אוגוסט 2026" אין אותו סדר מילים בשלוש השפות, ורק
# Fluent יודעת היכן נמצא החור.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] אין חשבון פתוח
    [one] חשבון פתוח אחד
    [two] שני חשבונות פתוחים
   *[other] { $count } חשבונות פתוחים
}
welcome-total-bank = יתרה בבנק
welcome-total-real = יתרה בפועל
welcome-total-final = יתרה סופית
welcome-total-real-detail = מותאם + משוריין
welcome-total-final-detail = מותאם + משוריין + מתוכנן
welcome-accounts = החשבונות שלך
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = חשבונות שנספרים בסיכומים: { $count } מתוך { $total }
welcome-tile-counted = לספור את החשבון הזה בסיכומים
welcome-tile-bank = בבנק
welcome-tile-real = בפועל
welcome-tile-final = סופי
welcome-spending = הוצאות — { $month }
welcome-earning = הכנסות — { $month }
ui-legend-budget-lines = סעיפי תקציב
ui-legend-categories = קטגוריות
welcome-nothing = אין שום תנועה בחודש הזה.
welcome-open-account = מידע: לחץ על חשבון כדי לפתוח את התנועות שלו.
welcome-no-account = אין עדיין חשבון בנק.
welcome-no-account-create = ליצירת חשבון בנק יש ללחוץ כאן
welcome-previous-month = החודש הקודם
welcome-next-month = החודש הבא
welcome-refresh = קריאה מחדש של הכול


# --- F39 — ההעדפות (שלב 17 ter, 03/08/2026) ------------------------------
#
# מקומו של סימן המטבע שוכן כאן, לצד שני המפרידים: הוא הולך אחר השפה ולא
# אחר המטבע. "before" ממקם את הסימן לפני המספר, וכל ערך אחר ממקם אותו
# אחריו. שום סימן מטבע אינו כתוב בקובץ הזה: "צרפתית" אינה אומרת "אירו".

ui-money-sign-position = after
window-preferences-title = העדפות
menu-settings-preferences = העדפות…
menu-settings-show-main = הצגת החלון הראשי
menu-settings-folders = תיקיות Radinus
preferences-branch-display = תצוגה
preferences-leaf-language = שפה
preferences-leaf-currency = מטבע
preferences-field-language = שפת התוכנה:
preferences-field-currency = המטבע המוצג:
preferences-field-custom = סימן המטבע:
preferences-currency-system = מטבע המערכת
preferences-currency-euro = אירו
preferences-currency-dollar = דולר
preferences-currency-canadian = דולר קנדי
preferences-currency-cfa = פרנק CFA
preferences-currency-cfp = פרנק פסיפיק
preferences-currency-swiss = פרנק שוויצרי
preferences-currency-none = ללא
preferences-currency-custom = מותאם אישית
preferences-currency-system-is = המערכת שלך מודיעה:
preferences-currency-system-silent = המערכת שלך אינה מודיעה על שום מטבע: הסכומים יוצגו באירו.
preferences-custom-required = הקלד את סימן המטבע שלך לפני השמירה.
preferences-saved = ההעדפות נשמרו.
preferences-help = בחר אפשרות בעץ, ולאחר מכן שמור.
preferences-sign-too-long = סימן של מטבע מכיל 8 תווים לכל היותר.
preferences-sign-not-a-number = סימן של מטבע אינו יכול להכיל ספרה, סימן חשבוני או פסיק: Radinus מסיר אותם כשהוא קורא סכום, ו"120" היה נעשה "12".
preferences-leaf-zoom = גודל התצוגה
preferences-field-zoom = הגדלה:
preferences-zoom-reset = ערך ברירת המחדל
preferences-zoom-hint = הכול גדל יחד: הטקסט, הסמלים, העמודות. מתחת ל-100%, נכנס יותר אל המסך. שורת התפריטים של המערכת ותיבות הדו-שיח שלה, לעומת זאת, הולכות אחר ההגדרות של המחשב שלך ולא אחר אלה.
preferences-branch-import = ייבוא
preferences-leaf-verification = אימות
preferences-field-verification = תנועות מיובאות:
preferences-verification-hint = «אומתה»: אתם סומכים על הבנק שלכם, תנועה מיובאת נחשבת תקינה. «לבדיקה»: כל תנועה מיובאת ממתינה לבדיקתכם; לאחר מכן אתם מעבירים אותה בעצמכם ל«אומתה» ברשימת התנועות. הגדרה זו חלה רק על ייבואים עתידיים.
preferences-leaf-ofx = דפי חשבון OFX
preferences-field-ofx-label = תיאור התנועה:
preferences-field-ofx-reference = אסמכתת תשלום:
preferences-ofx-choice-name = שם התנועה
preferences-ofx-choice-memo = ההערה של הבנק
preferences-ofx-choice-name-and-memo = השם ואחריו ההערה
preferences-ofx-choice-empty = כלום (להשאיר ריק)
preferences-ofx-label-help = מה מקבל התיאור של תנועה מיובאת. השם הוא זה שהבנק מציג, למשל «PRLV SEPA»; חלק מהבנקים מוסיפים הערה מפורטת: הגוף הגובה בהוראת קבע, המוטב ומטרת ההעברה בהעברה. כשלתנועה אין הערה, התיאור שלה שומר על השם.
preferences-ofx-reference-help = מה מקבלת אסמכתת התשלום של תנועה מיובאת, שם תוכלו לראות אותה ולסנן לפיה. כשלתנועה אין הערה, האפשרות «ההערה של הבנק» משאירה את האסמכתה ריקה. אם ההערה כבר חוזרת על השם, היא אינה נכתבת פעמיים.
preferences-ofx-hint = הגדרות אלה חלות על כל דפי החשבון בפורמט OFX, יהיה מסד הנתונים הפתוח אשר יהיה. הן ייכנסו לתוקף בדף החשבון הבא שייפתח.
preferences-leaf-qif = דפי חשבון QIF
preferences-field-qif-order = סדר היום והחודש:
preferences-qif-order-ask = לשאול אותי בכל פעם
preferences-qif-order-day-month = תמיד יום/חודש (05/03 = 5 במרץ)
preferences-qif-order-month-day = תמיד חודש/יום (05/03 = 3 במאי)
preferences-qif-order-help = משמש רק כאשר אף תאריך בקובץ אינו מכריע. ברגע שתאריך כמו 24/11 מוכיח את הסדר, הקובץ הוא שמחליט, תהיה הגדרה זו אשר תהיה.
preferences-field-qif-label = תיאור התנועה:
preferences-qif-label-both = צד נגדי + הערה
preferences-qif-label-payee = צד נגדי בלבד
preferences-qif-label-memo = הערה בלבד
preferences-qif-label-help = כאשר תנועה נושאת גם צד נגדי וגם הערה. אם היא נושאת רק אחד מהם, בו נעשה שימוש, תהיה הגדרה זו אשר תהיה.
preferences-qif-hint = הגדרות אלה חלות על כל דפי החשבון בפורמט QIF, יהיה מסד הנתונים הפתוח אשר יהיה. «לשאול אותי בכל פעם» היא האפשרות הבטוחה ביותר: קובץ שתאריכיו דו-משמעיים לעולם אינו נקרא על סמך ניחוש.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = שחזור עמודות ברירת המחדל
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = הצגה/הסתרה
columns-colour = צביעת העמודה:
columns-colour-none = ללא צבע
columns-colour-red = אדום
columns-colour-orange = כתום
columns-colour-pink = ורוד
columns-colour-pastel-green = ירוק פסטל
columns-colour-green = ירוק
columns-colour-pastel-blue = כחול פסטל
columns-colour-blue = כחול
columns-colour-pastel-yellow = צהוב פסטל
columns-colour-yellow = צהוב
preferences-leaf-columns = עמודות הטבלאות
preferences-table-operations-list = רשימת התנועות
preferences-columns-reset = איפוס
preferences-columns-reset-all = איפוס הכול
preferences-columns-done = העמודות חזרו לסידור המקורי.
preferences-columns-hint = כל טבלה זוכרת את סדר העמודות שלה, את העמודות שהסתרתם ואת רוחבן. «איפוס» מחזיר לה מיד את הסידור המקורי.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = איפוס
preferences-leaf-comfort = הגדרות נוחות
preferences-comfort-reset = איפוס הגדרות הנוחות
preferences-comfort-hint = מחזיר למצב המקורי את העמודות של כל הטבלאות, את הסדר ואת תיבות הסימון של החשבונות בחלון הפתיחה ואת גודל התצוגה. השפה, המטבע ואימות התנועות המיובאות אינם משתנים.
preferences-comfort-question = לאפס את הגדרות הנוחות? עמודות הטבלאות, חלון הפתיחה וגודל התצוגה יחזרו למצבם המקורי.
preferences-comfort-done = הגדרות הנוחות אופסו.

# --- כרזת הפתיחה ---------------------------------------------------------
#
# המשפטים האלה היו כתובים קשיח בתוך `index.html` מאז שלב 0 ולכן לא היו
# מתורגמים (הבחין בכך Fabrice ב-03/08/2026). הסיסמה היא קולו: הגרסאות
# האנגלית והספרדית הן הצעות שעליו לתקן — סיסמה אינה מתורגמת מילה במילה.
ui-language-tag = he
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — הסנאי הקמע, בחליפה, מוקף באירו, במחשבון ובגרפים
welcome-slogan-one = תוכנה לניהול כספים אישיים שעוזרת לך להוציא פחות כדי להרוויח יותר
welcome-slogan-two = עם Radinus תבין למה פרוטה לפרוטה מצטרפת לחשבון גדול.

# --- "על אודות המחבר" ----------------------------------------------------
#
# השם והכתובת כתובים באופן זהה בשלושת הקבצים: הם אינם מתורגמים. הם כאן
# למרות הכול, ולא בדף עצמו, כדי שהתצוגה לא תישא שום משפט — וכדי שיתוקנו
# במקום אחד ביום שבו המחבר יעבור דירה.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = על אודות המחבר
about-author-flag-alt = דגל קורסיקה — ראש המורי

# --- "על אודות Radinus" --------------------------------------------------
#
# `about-radinus-version` נושא חור: המספר מגיע מן הקובץ הבינרי שרץ, לעולם
# לא ממחרוזת שהועתקה. לכן היא אינה במילון החלונות — הפקודה `app_version`
# היא שממלאת אותה.
window-about-radinus-title = על אודות Radinus
about-radinus-name = Radinus
about-radinus-version = גרסה { $version }
about-radinus-rust-alt = הלוגו של שפת Rust
about-radinus-tauri-alt = הלוגו של Tauri
about-radinus-built = Radinus כתובה ב-Rust ובנויה עם Tauri. הראשונה מחשבת את החשבונות שלך, השנייה הופכת אותה ליישום שולחן עבודה.
about-radinus-licence = תוכנה חופשית, ברישיון GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = רישיון שימוש
licence-heading = רישיון השימוש בתוכנת RADINUS
licence-logo-alt = הלוגו של GNU General Public License גרסה 3
licence-name = GNU GPL v3 או מאוחר יותר
licence-intro = Radinus היא תוכנה חופשית.
licence-freedoms-title = הרישיון שלה מעניק לך ארבע חירויות:
licence-freedom-use = להשתמש בה כרצונך, לכל מטרה.
licence-freedom-study = ללמוד את קוד המקור שלה, הפתוח לכול.
licence-freedom-share = להעתיק אותה ולהעביר אותה לאחרים.
licence-freedom-improve = לשנות אותה ולשתף את השינויים שלך.
licence-read = קריאת הנוסח המלא של הרישיון

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = תוכנה זו מסופקת ללא כל אחריות, ככל שהחוק מתיר.
licence-info = הנוסח הרשמי נפתח בדפדפן שלך, באתר gnu.org.

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = סימולציית הלוואה
window-loan-title = סימולציית הלוואה
loan-tab-credit = ההלוואה
loan-tab-afford = האם אוכל להחזיר אותה?
loan-field-kind = סוג ההלוואה
loan-kind-consumer = הלוואה צרכנית
loan-kind-mortgage = משכנתה
loan-field-amount = סכום ההלוואה
loan-field-payment = החזר חודשי
loan-field-months = תקופה
loan-field-rate = ריבית קבועה
loan-field-fees = דמי פתיחת תיק
loan-field-insurance = ביטוח לחודש
loan-unit-months = חודשים
loan-unit-percent = %
loan-invalid-field = הערך אינו מספר: תקנו אותו כדי לחשב מחדש.
loan-report-button = דוח PDF
loan-monthly-table = טבלה חודש אחר חודש
loan-months-count = { $count ->
        [one] חודש אחד
        [two] חודשיים
       *[other] { $count } חודשים
    }
loan-percent = { $value }%
loan-notice-payment-too-low = החזר זה אינו מכסה את הריבית: ההלוואה לא תיפרע לעולם. התקופה נשארת 600 חודשים.
loan-notice-too-long = החזר זה ידרוש יותר מ־600 חודשים: התקופה נשארת 600 חודשים.
loan-figure-payment = החזר חודשי
loan-figure-payment-insured = החזר כולל ביטוח
loan-figure-taeg = ריבית אפקטיבית
loan-figure-interest = עלות הריבית
loan-figure-insurance = עלות הביטוח
loan-figure-cost = העלות הכוללת של ההלוואה
loan-figure-total-due = הסכום הכולל לתשלום
loan-figure-all-in = סך הכול הוחזר, כולל ביטוח
loan-part-capital = סכום ההלוואה
loan-part-interest = ריבית
loan-part-fees = דמי פתיחת תיק
loan-part-insurance = ביטוח
loan-donut-cost-caption = בסך הכול
loan-chart-cost = כמה עולה ההלוואה
loan-chart-capital = יתרת הקרן
loan-schedule-title = לוח סילוקין
loan-schedule-yearly = לוח סילוקין, שנה אחר שנה
loan-column-number = מס׳
loan-column-year = שנה
loan-column-date = מועד
loan-column-payment = החזר
loan-column-payments = החזרים
loan-column-interest = ריבית
loan-column-capital = קרן
loan-column-insurance = ביטוח
loan-column-remaining = יתרת הקרן
loan-history-label = התקופה הנבדקת
loan-period-last-12 = 12 החודשים האחרונים
loan-accounts-title = החשבונות הנבדקים
loan-period-title = תקופה
loan-column-account = חשבון
loan-column-bank = בנק
loan-column-balance = יתרה ריאלית
loan-unavailable-no-account = סמנו לפחות חשבון אחד כדי לבחון את ההיסטוריה שלכם.
loan-unavailable-no-month = לתקופה זו אין עדיין אף חודש מלא: בחרו תקופה אחרת.
loan-verdict-title = בקצרה
loan-verdict-green = אפשרי
loan-verdict-orange = על הגבול
loan-verdict-red = מסוכן
loan-verdict-no-income = אין הכנסות בתקופה זו: אי אפשר לחשב את יחס החוב.
loan-check-debt-green = יחס חוב של { $ratio }: מתחת לסף של שיטה זו ({ $green }).
loan-check-debt-orange = יחס חוב של { $ratio }: בין { $green } ל־{ $red }, על הגבול.
loan-check-debt-red = יחס חוב של { $ratio }: מעל { $red }.
loan-check-effort = ההחזר של { $payment } לוקח { $share } ממה שאתם חוסכים { $kind ->
        [good] בחודש טוב
        [hard] בחודש קשה
       *[usual] בחודש רגיל
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] חודש טוב
        [hard] חודש קשה
       *[usual] חודש רגיל
    } לא משאיר לכם דבר בצד: ההחזר של { $payment } יילקח מהעתודה שלכם.
loan-check-reserve-green = היתרה שלכם נשארת חיובית עד סוף ההלוואה.
loan-check-reserve-red = היתרה שלכם הייתה יורדת מתחת לאפס ב{ $month }, בגלל ההלוואה הזו.
loan-check-reserve-sooner = היתרה שלכם הייתה יורדת מתחת לאפס ב{ $month }, { $count ->
        [one] חודש אחד
        [two] חודשיים
       *[other] { $count } חודשים
    } מוקדם יותר מאשר בלי ההלוואה.
loan-check-reserve-anyway = היתרה שלכם הייתה יורדת מתחת לאפס בסביבות { $month } גם בלי ההלוואה, שכמעט אינה משנה זאת.
loan-check-reserve-floor-green = היתרה שלכם נשארת מעל עתודת הביטחון ({ $floor }) עד סוף ההלוואה.
loan-check-reserve-floor-red = היתרה שלכם הייתה יורדת מתחת לעתודת הביטחון ({ $floor }) ב{ $month }, בגלל ההלוואה הזו.
loan-check-reserve-floor-sooner = היתרה שלכם הייתה יורדת מתחת לעתודת הביטחון ({ $floor }) ב{ $month }, { $count ->
        [one] חודש אחד
        [two] חודשיים
       *[other] { $count } חודשים
    } מוקדם יותר מאשר בלי ההלוואה.
loan-check-reserve-floor-anyway = היתרה שלכם הייתה יורדת מתחת לעתודת הביטחון ({ $floor }) בסביבות { $month } גם בלי ההלוואה, שכמעט אינה משנה זאת.
loan-warning-deficit = שימו לב: בתקופה זו ההוצאות שלכם כבר עולות על ההכנסות ב־{ $amount } בחודש בממוצע, עוד לפני כל הלוואה.
loan-figure-reference = חיסכון { $kind ->
        [good] בחודש טוב
        [hard] בחודש קשה
       *[usual] בחודש רגיל
    }
loan-figure-tipped = חודשים שההלוואה הייתה מכניסה למינוס
loan-gauge-caption = יחס חוב
loan-figure-income = הכנסה ממוצעת לחודש
loan-figure-spending = הוצאה ממוצעת לחודש
loan-figure-saving = חיסכון ממוצע לחודש
loan-figure-running = הלוואות קיימות לחודש
loan-figure-new = החזר חדש, כולל ביטוח
loan-figure-rest = למחיה בחודש
loan-figure-debt = יחס חוב
loan-red-months-value = { $count } מתוך { $total }
loan-figure-balance-now = יתרה ריאלית היום
loan-figure-balance-end = יתרה צפויה בסוף ההלוואה
loan-chart-income = לאן הולכת ההכנסה הממוצעת שלכם
loan-donut-income-caption = הכנסה ממוצעת
loan-part-spending = הוצאות שוטפות
loan-part-running = הלוואות קיימות
loan-part-new = הלוואה חדשה
loan-part-rest = נשאר
loan-part-missing = חסר
loan-chart-history = ההיסטוריה שלכם עם ההלוואה הזו
loan-chart-history-hint = מה היה נשאר בכל חודש אחרי ההחזר. באדום בוהק — החודשים שההלוואה הייתה מכניסה למינוס; באדום חיוור — אלה שהיו במינוס גם בלעדיה.
loan-chart-projection = היתרה הצפויה שלכם
loan-mark-loan-end = סיום: { $label }
loan-mark-negative = במינוס
loan-mark-floor = מתחת לעתודה
loan-mark-floor-line = עתודת ביטחון
loan-running-title = הלוואות קיימות שנלקחו בחשבון
loan-running-column-label = פעולה מחזורית
loan-running-column-monthly = לחודש
loan-running-column-end = החזר אחרון
loan-no-running = לא זוהתה אף הלוואה קיימת בין הפעולות המחזוריות שלכם.
loan-period-caption = מ־{ $from } עד { $to } ({ $count ->
        [one] חודש אחד
        [two] חודשיים
       *[other] { $count } חודשים
    })
loan-transfers = { $count ->
        [0] לא זוהתה אף העברה בין החשבונות המסומנים שלכם.
        [one] העברה אחת בין החשבונות המסומנים שלכם זוהתה והוצאה מהחישוב.
       *[other] { $count } העברות בין החשבונות המסומנים שלכם זוהו והוצאו מהחישוב.
    }
loan-method = ממוצעים על פני החודשים המלאים של התקופה, פעולות מותאמות ומחויבות, ללא ההעברות בין החשבונות המסומנים שלכם.
loan-report-title = סימולציית הלוואה
loan-report-made-on = סימולציה מ־{ $date }
loan-disclaimer = סימולציה להמחשה בלבד, ללא תוקף חוזי. רק הצעת הבנק מחייבת.
loan-tab-rules = הגדרות השיפוט
loan-method-optimistic = אופטימית
loan-method-neutral = ניטרלית
loan-method-severe = מחמירה
loan-method-line = שיטת השיפוט: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = פסק הדין עונה על שלוש שאלות, וכל שיטה מציבה דרישות משלה. בחרו את זו שמתאימה לכם: פסק הדין בלשונית „האם אוכל להחזיר אותה?” הולך אחריה. השורה האחרונה מניחה שההוצאות שלכם עולות מדי שנה באחוז שצוין; ההחזר אינו משתנה.
loan-rule-row-debt = יחס חוב מקובל
loan-rule-row-reference = חיסכון ייחוס
loan-rule-row-share = החלק מהחיסכון הזה שההחזר רשאי לקחת
loan-rule-row-floor = סף שהיתרה אסור שתרד מתחתיו
loan-rule-row-sooner = אם היתרה יורדת מתחתיו גם בלי ההלוואה
loan-rule-row-growth = עלייה בהוצאות שלכם בשנה
loan-rule-limits = ירוק עד { $green }, כתום עד { $red }
loan-rule-reference = { $kind ->
        [good] חודש טוב
        [hard] חודש קשה
       *[usual] חודש רגיל
    }: { $amount }
loan-rule-floor-zero = אפס
loan-rule-floor-cushion = חודש של הוצאות: { $amount }
loan-rule-sooner = כתום אם ההלוואה מקדימה זאת ב־{ $orange }, אדום ב־{ $red }
loan-unit-percent-year = % בשנה
loan-method-optimistic-explain = השיטה האופטימית מניחה חודש טוב, מקבלת יחס חוב עד 40% ואינה שומרת עתודה: היא מראה מה אפשרי אם הכול ילך טוב.
loan-method-neutral-explain = השיטה הניטרלית מניחה חודש רגיל ופועלת לפי כלל הבנקים, יחס חוב של 33 עד 35%: זה שיפוט הייחוס.
loan-method-severe-explain = השיטה המחמירה מניחה חודש קשה ושומרת חודש של הוצאות כעתודה לבלתי צפוי: היא מראה מה מחזיק גם אם הדברים ילכו רע.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = צריכת מכשיר חשמלי
window-appliance-title = צריכת מכשיר חשמלי
appliance-device-title = המכשיר
appliance-on-title = פועל
appliance-standby-title = במצב המתנה
appliance-field-on-watts = הספק בזמן פעולה
appliance-field-on-hours = זמן פעולה ביום
appliance-field-days = ימי שימוש בשבוע
appliance-field-share = חלק זמן הפעולה בשעות שפל
appliance-field-standby-watts = הספק במצב המתנה
appliance-field-standby-hours = זמן המתנה ביום שימוש
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = מתוך 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = אם השדה נשאר ריק, מצב ההמתנה נמשך בשאר היום. בימים ללא שימוש המכשיר נשאר מחובר: כל הזמן הזה נחשב כהמתנה. כשהמכשיר מנותק, הספק ההמתנה שלו הוא 0 W.
appliance-contract-title = החוזה שלך
appliance-field-option = מסלול תעריף
appliance-option-base = בסיסי (מחיר אחיד)
appliance-option-off-peak = שעות שיא / שעות שפל
appliance-field-base = מחיר ל-kWh
appliance-field-peak = מחיר ל-kWh בשעות שיא
appliance-field-off-peak = מחיר ל-kWh בשעות שפל
appliance-field-off-peak-hours = שעות שפל ביום
appliance-contract-hint = מחירים אלה חלים על חישוב זה בלבד. את התעריף השמור מגדירים בהגדרות › העדפות › כלים.
appliance-contract-reset = חזרה לתעריף השמור
appliance-period-day = ליום
appliance-period-month = לחודש
appliance-period-year = לשנה
appliance-energy = { $value } kWh
appliance-less-than = פחות מ-{ $amount }
appliance-detail-title = פירוט לשנה אחת
appliance-column-part = סעיף
appliance-column-energy = אנרגיה
appliance-column-cost = עלות
appliance-column-share = חלק
appliance-line-on = פועל
appliance-line-standby = במצב המתנה
appliance-line-on-peak = פועל, שעות שיא
appliance-line-on-off-peak = פועל, שעות שפל
appliance-line-standby-peak = במצב המתנה, שעות שיא
appliance-line-standby-off-peak = במצב המתנה, שעות שפל
appliance-line-total = סה״כ
appliance-chart-title = לאן הולך הכסף
appliance-chart-caption = לשנה
appliance-standby-sentence = מצב ההמתנה לבדו עולה { $amount } בשנה: { $share } מעלות המכשיר.
appliance-note-plate = ההספק הרשום על המכשיר או בהוראות השימוש שלו הוא ערך מרבי: בזמן פעולה רוב המכשירים צורכים פחות. לקבלת נתון אמיתי, מדדו אותו במד צריכה המחובר לשקע והזינו את מה שהוא מציג.
appliance-note-subscription = התשלום הקבוע אינו נכלל: משלמים אותו בין שהמכשיר מחובר ובין שלא.
appliance-invalid-watts = נא להזין הספק בין 0 ל-100,000 W.
appliance-invalid-hours = נא להזין זמן בין 0 ל-24 שעות ביום.
appliance-invalid-days = נא להזין מספר שלם של ימים, בין 0 ל-7.
appliance-invalid-share = נא להזין חלק בין 0 ל-100%.
appliance-invalid-day-overflow = זמן הפעולה וזמן ההמתנה יחד עולים על 24 שעות ביום.
appliance-invalid-price = נא להזין מחיר ל-kWh בין 0 ל-100.
appliance-invalid-off-peak-hours = נא להזין מספר שלם של שעות שפל, בין 0 ל-24.
preferences-branch-tools = כלים
preferences-leaf-electricity = תעריף חשמל
preferences-electricity-blue = חזרה ל-Tarif Bleu של EDF
preferences-electricity-hint = התעריף שבחוזה שלך, שבו משתמש הכלי "צריכת מכשיר חשמלי". ברירת מחדל: Tarif Bleu של EDF (צרפת) נכון ל-1 באוגוסט 2026, מחירים כולל מסים, מונה 3 עד 6 kVA. מחירים אלה משתנים לעיתים קרובות בפברואר ובאוגוסט: העתיקו את המחירים מהחשבון.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = כרית הביטחון שלי
window-cushion-title = כרית הביטחון שלי
cushion-question = אם ההכנסות שלך ייפסקו מחר, לכמה חודשים יספיקו החסכונות שלך?
cushion-accounts-title = החשבונות שלך
cushion-column-account = חשבון
cushion-column-balance = יתרה ריאלית
cushion-column-savings = חיסכון
cushion-column-spending = הוצאות
cushion-accounts-hint = "חיסכון": הכסף שעליו אפשר לסמוך בעת משבר. "הוצאות": החשבונות שמהם יוצאות ההוצאות השוטפות.
cushion-history-label = תקופת הבדיקה
cushion-backup-label = הכנסת גיבוי לחודש
cushion-backup-hint = מה שימשיך להיכנס: דמי אבטלה, משכורת של בן או בת הזוג… ריק: אין הכנסה.
cushion-categories-title = ההוצאות שנלקחו בחשבון
cushion-categories-hint = בטלו את הסימון של מה שהייתם מקצצים בעת משבר.
cushion-categories-empty = אין הוצאות בתקופה זו.
cushion-verdict-title = כרית הביטחון שלך
cushion-targets-title = ספי הזהירות
cushion-projection-title = החיסכון שלך בעת משבר
cushion-projection-hint = מה שהיה נשאר בכל חודש אם ההכנסות שלך היו נפסקות היום.
cushion-note = הערכה המבוססת על ההיסטוריה שלך: ההוצאות בחודש קשה עשויות להיות שונות מהממוצע.
cushion-invalid-backup = לא ניתן לקרוא את הסכום הזה: תקנו אותו כדי להפעיל מחדש את החישוב.
cushion-no-spending-account = סמנו לפחות חשבון "הוצאות" אחד.
cushion-no-month = בתקופה זו אין עדיין אף חודש מלא.
cushion-months = { $value } חודשים
cushion-per-month = { $amount } לחודש
cushion-figure-holds = ללא הגבלה
cushion-gauge-caption = של הוצאות מכוסות
cushion-verdict-short = פחות משלושה חודשים: משבר יכניס אותך במהירות לקשיים.
cushion-verdict-fair = בין שלושה לשישה חודשים: כרית סבירה, כדאי להגדיל אותה אם אפשר.
cushion-verdict-solid = שישה חודשים או יותר: כרית הביטחון שלך יציבה.
cushion-verdict-holds = הכנסת הגיבוי שלך מכסה את ההוצאות: החיסכון שלך לא יישחק.
cushion-verdict-nothing = אין הוצאות שנלקחו בחשבון בתקופה: אין מה לכסות.
cushion-tile-savings = חיסכון זמין
cushion-tile-spending = הוצאות שנלקחו בחשבון
cushion-tile-backup = הכנסת גיבוי
cushion-tile-burn = שחיקת החיסכון
cushion-tile-rhythm = קצב החיסכון
cushion-burn-none = אין
cushion-target-title = { $months } חודשי הוצאות: { $amount }
cushion-target-reached = הושג.
cushion-target-date = חסרים { $missing }. בקצב החיסכון שלך, הסף יושג בסביבות { $month }.
cushion-target-never = חסרים { $missing }. החיסכון שלך לא גדל בתקופה: בקצב הזה, הסף לא יושג.
cushion-mark-empty = החיסכון אוזל: { $month }
cushion-period = ממוצע של { $count ->
        [one] { $count } חודש מלא
        [two] { $count } חודשים מלאים
       *[other] { $count } חודשים מלאים
    }, מ־{ $from } עד { $to }. { $transfers ->
        [0] אין העברות בין החשבונות שלך.
        [one] העברה אחת בין החשבונות שלך, שהוצאה מהחישוב.
        [two] שתי העברות בין החשבונות שלך, שהוצאו מהחישוב.
       *[other] { $transfers } העברות בין החשבונות שלך, שהוצאו מהחישוב.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = יעד חיסכון
window-goal-title = יעד חיסכון
goal-accounts-title = החשבונות במעקב
goal-column-account = חשבון
goal-column-balance = יתרה ריאלית
goal-accounts-hint = העברה בין שני חשבונות שבמעקב מתקזזת; העברה לחשבון שאינו במעקב נחשבת כהוצאה.
goal-period-label = תקופת ייחוס
goal-period-range = טווח שנים…
goal-range-from = משנת
goal-range-to = עד
goal-question-title = השאלה שלך
goal-question-when = מתי יהיה לי הסכום הזה?
goal-question-amount = כמה יהיה לי בתאריך הזה?
goal-question-effort = כמה לחסוך כדי שיהיה לי הסכום הזה בתאריך הזה?
goal-field-target = סכום היעד
goal-field-date = תאריך היעד
goal-field-rate = ריבית שנתית על החיסכון
goal-field-extra = ואם אחסוך יותר, לחודש
goal-options-hint = ריק: ללא ריבית, ללא תוספת.
goal-answer-title = התשובה
goal-chart-title = היתרה שלך, אתמול ומחר
goal-chart-hint = קו רציף: היתרה הריאלית בשנים־עשר החודשים האחרונים; קו מקווקו: התחזית; אזור בהיר: הטווח לפי החודשים.
goal-disclaimer = תחזית המבוססת על ההיסטוריה שלך, לא הבטחה: אירוע בלתי צפוי יכול לשנות הכול.
goal-no-account = סמנו לפחות חשבון אחד למעקב.
goal-no-month = בתקופה זו אין עדיין אף חודש מלא.
goal-invalid-target = נא להזין סכום יעד.
goal-invalid-date = נא לבחור תאריך עתידי, בתוך חמישים השנים הבאות.
goal-invalid-rate = נא להזין ריבית בין 0 ל־100%.
goal-invalid-extra = לא ניתן לקרוא את הסכום הזה: תקנו אותו כדי להפעיל מחדש את החישוב.
goal-per-month = { $amount } לחודש
goal-tile-balance = יתרה היום
goal-tile-rhythm = קצב ממוצע
goal-tile-target = יעד
goal-tile-reached = יושג בסביבות
goal-tile-date = תאריך היעד
goal-tile-projected = יתרה צפויה
goal-tile-saved = ייחסך עד אז
goal-tile-interest = מתוכם ריבית
goal-tile-needed = סכום לחיסכון
goal-when-already = כבר יש לך { $amount }: סך היתרות בחשבונות שבמעקב הוא { $balance }.
goal-when-reached = יהיה לך { $amount } בסביבות { $month }, בעוד { $months ->
        [one] חודש אחד
        [two] חודשיים
       *[other] { $months } חודשים
    }.
goal-when-range = לפי החודשים, בין { $early } לבין { $late }.
goal-when-range-open = לכל המוקדם בסביבות { $early }; עם חודשים חלשים, היעד לא יושג.
goal-when-never = בקצב הזה, הסכום { $amount } לא יושג.
goal-zero = היתרה שלך תרד לאפס בסביבות { $month }.
goal-amount = ב־{ $month } יהיה לך בערך { $amount }.
goal-amount-range = לפי החודשים, בין { $low } לבין { $high }.
goal-effort-more = כדי שיהיה לך { $amount } ב־{ $month }, יש לחסוך בממוצע { $monthly } לחודש, כלומר { $gap } יותר מהיום.
goal-effort-less = כדי שיהיה לך { $amount } ב־{ $month }, יספיקו { $monthly } לחודש, כלומר { $gap } פחות מהיום: החיסכון שלך מקדים את התוכנית.
goal-effort-range = לפי החודשים, הפער מהקצב שלך ינוע בין { $low } לבין { $high } לחודש.
goal-chart-target = יעד: { $amount }
goal-chart-today = היום
goal-note-seasons = התחזית עוקבת אחר עונות השנה: כל חודש עתידי מקבל את הממוצע של אותם חודשים בתקופה.
goal-note-range = הטווח נגזר מהחודשים החלשים והחזקים בתקופה: הרבע הנמוך ביותר והרבע הגבוה ביותר.
goal-note-loan = ההלוואה "{ $label }" מסתיימת ב־{ $month }: לאחר מכן { $amount } נוספים בכל חודש.
goal-note-interest = הריבית מחושבת מדי חודש בשיעור של { $rate }% לשנה: קירוב לכלל חישוב הריבית לפי חצאי חודש בחשבונות חיסכון.
goal-period = הקצב חושב על פני { $count ->
        [one] { $count } חודש מלא
        [two] { $count } חודשים מלאים
       *[other] { $count } חודשים מלאים
    }, מ־{ $from } עד { $to }. { $transfers ->
        [0] אין העברות בין החשבונות שבמעקב.
        [one] העברה אחת בין החשבונות שבמעקב, שקוזזה.
        [two] שתי העברות בין החשבונות שבמעקב, שקוזזו.
       *[other] { $transfers } העברות בין החשבונות שבמעקב, שקוזזו.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = ומה אם אצמצם…?
window-cut-title = ומה אם אצמצם…?
cut-axis-label = קיבוץ לפי
cut-axis-category = קטגוריות
cut-axis-payee = צדדים נגדיים
cut-axis-budget-line = סעיפי תקציב
cut-table-title = ההוצאות שלך, פריט אחר פריט
cut-table-hint = יש להזין צמצום ב־% או ב־{ $sign } לחודש בפריטים שברצונך להקל בהם. צמצום אינו יכול לעלות על ההוצאה עצמה.
cut-column-monthly = לחודש
cut-column-cut = צמצום
cut-column-after = אחרי
cut-column-yearly = חיסכון בשנה
cut-total = סך הכול
cut-horizon-label = טווח זמן
cut-settings-title = הגדרות
cut-options-hint = הריבית וסכום היעד אינם חובה.
cut-report-button = דוח PDF
cut-chart-title = היתרה שלך, בלי ועם הצמצומים
cut-chart-hint = קו רציף: היתרה הריאלית בשנים־עשר החודשים האחרונים; קו מקווקו אפור: התחזית ללא צמצום; בכחול: עם הצמצומים; בירוק: הכסף שנחסך.
cut-donut-title = ההוצאות החודשיות שלך אחרי הצמצום
cut-donut-caption = לחודש אחרי הצמצום
cut-donut-others = פריטים אחרים
cut-donut-saved = נחסך
cut-legend-with = עם הצמצומים
cut-legend-without = ללא צמצום
cut-years = { $years ->
        [one] שנה אחת
        [two] שנתיים
       *[other] { $years } שנים
    }
cut-headline-none = יש להזין צמצום בטבלה כדי לראות את השפעתו.
cut-headline = צמצום { $count ->
        [one] הפריט הזה
        [two] שני הפריטים האלה
       *[other] { $count } הפריטים האלה
    } יאפשר לחסוך עוד { $monthly } בחודש, כלומר { $yearly } בשנה.
cut-tile-monthly = חיסכון בחודש
cut-tile-yearly = חיסכון בשנה
cut-tile-horizon = חיסכון על פני { $years ->
        [one] שנה אחת
        [two] שנתיים
       *[other] { $years } שנים
    }
cut-tile-spending = הוצאות בחודש
cut-target-already = כבר יש לך { $amount }.
cut-target-sooner = הסכום { $amount } יושג בסביבות { $with } במקום { $without }: { $months ->
        [0] לא מוקדם יותר
        [one] חודש אחד מוקדם יותר
        [two] חודשיים מוקדם יותר
       *[other] { $months } חודשים מוקדם יותר
    }.
cut-target-only-with = עם הצמצומים האלה, הסכום { $amount } יושג בסביבות { $with }; בלעדיהם, בקצב הנוכחי שלך, לעולם לא.
cut-target-never = גם עם הצמצומים האלה, הסכום { $amount } לא יושג בקצב הנוכחי שלך.
cut-note-seasons = כל צמצום עוקב אחר העונות של הפריט שלו: פריט שמשקלו בעיקר בקיץ חוסך בעיקר בקיץ.
cut-note-capped = צמצום שהוזן עלה על ההוצאה: הוא הוגבל לגובה ההוצאה עצמה.
cut-invalid-cut = לא ניתן לקרוא את הצמצום הזה: אחוז בין 0 ל־100, או סכום לחודש.
cut-report-settings = ההגדרות
cut-report-result = התוצאה
cut-report-accounts = החשבונות במעקב

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = תכנון החופשה שלי
window-holiday-title = תכנון החופשה שלי
holiday-trip-title = הטיול
holiday-field-trip = סוג הטיול
holiday-trip-stay = חופשה ביעד
holiday-trip-cruise = שייט
holiday-field-adults = מבוגרים
holiday-field-children = ילדים
holiday-field-nights = משך השהייה, בלילות
holiday-field-days = ימים
holiday-field-months = חודשים עד היציאה
holiday-field-stops = מספר נמלי עגינה
holiday-saved-title = כבר נחסך
holiday-saved-hint = יש לסמן את החשבונות שבהם כסף החופשה כבר מופרש: היתרה הריאלית שלהם נחשבת לכסף שכבר נחסך.
holiday-budget-title = התקציב
holiday-budget-hint = לכל סעיף: סכום, על מי הוא חל ולכמה זמן. סעיף ריק אינו נספר.
holiday-optional-title = שורות רשות
holiday-result-title = התוצאה
holiday-donut-title = לאן הולך כסף הטיול
holiday-donut-caption = לטיול
holiday-child-label = מחיר לילד
holiday-count-label = תאים
holiday-open = פתיחת פרויקט…
holiday-save = שמירת הפרויקט…
holiday-pdf = דוח PDF
holiday-excel = ייצוא ל־Excel
holiday-file-filter = פרויקט חופשה
holiday-replace-question = פתיחת הפרויקט הזה תחליף את מה שהוקלד בחלון. להמשיך?
holiday-file-saved = הפרויקט נשמר: { $file }
holiday-file-opened = הפרויקט נפתח: { $file }
holiday-file-not-project = קובץ זה אינו פרויקט חופשה של Radinus.
holiday-file-too-recent = פרויקט זה מגיע מגרסה חדשה יותר של Radinus: יש לעדכן את Radinus כדי לפתוח אותו.
holiday-file-failed = לא ניתן היה לקרוא או לכתוב את הקובץ: { $reason }
holiday-line-transport = תחבורה הלוך ושוב
holiday-line-lodging = לינה
holiday-line-meals = ארוחות והוצאות שוטפות
holiday-line-visits = אטרקציות ופנאי
holiday-line-port = הגעה לנמל
holiday-line-cabins = תאים
holiday-line-service = דמי שירות (טיפים)
holiday-line-drinks = חבילת משקאות
holiday-line-excursions = סיורים בנמלי העגינה
holiday-line-port-taxes = מסי נמל
holiday-line-wifi = Wi-Fi על הסיפון
holiday-line-onboard = הוצאות על הסיפון ובנמלי העגינה
holiday-line-other = הוצאות אחרות ובלתי צפויות
holiday-line-insurance = ביטוח ביטול
holiday-line-stay-tax = מס תיירות
holiday-line-car = רכב ביעד, דלק ואגרות
holiday-line-parking = חניה בשדה התעופה או בתחנה
holiday-line-bank = עמלות בנק בחו״ל
holiday-line-formalities = מסמכים ואישורים (דרכון, ויזה, חיסונים)
holiday-line-pets = טיפול בחיות המחמד
holiday-span-trip = לכל השהייה
holiday-span-night = ללילה
holiday-span-day = ליום
holiday-span-stop = לנמל עגינה
holiday-who-all = לכולם
holiday-who-person = לאדם
holiday-who-adults = למבוגר
holiday-cabins-count = { $count ->
        [one] תא אחד
        [two] שני תאים
       *[other] { $count } תאים
    }
holiday-days = { $days ->
        [one] יום אחד
        [two] יומיים
       *[other] { $days } ימים
    }
holiday-invalid-count = נא להזין מספר שלם.
holiday-invalid-amount = לא ניתן לקרוא את הסכום הזה: מספר חיובי, או אחוז בין 0 ל־100.
holiday-headline-empty = יש להזין את סכומי התקציב כדי לראות כמה יעלה הטיול.
holiday-headline-stay = חופשה זו תעלה { $total } עבור { $people ->
        [one] אדם אחד
        [two] שני אנשים
       *[other] { $people } אנשים
    }, { $nights ->
        [0] ללא לילות
        [one] לילה אחד
        [two] שני לילות
       *[other] { $nights } לילות
    }.
holiday-headline-cruise = שייט זה יעלה { $total } עבור { $people ->
        [one] אדם אחד
        [two] שני אנשים
       *[other] { $people } אנשים
    }, { $nights ->
        [0] ללא לילות
        [one] לילה אחד
        [two] שני לילות
       *[other] { $nights } לילות
    }.
holiday-tile-total = עלות כוללת
holiday-tile-person = לאדם
holiday-tile-person-day = לאדם ליום
holiday-tile-saved = כבר נחסך
holiday-tile-remaining = נותר לממן
holiday-tile-monthly = חיסכון נדרש
holiday-remaining-none = כלום: הכול מכוסה
holiday-monthly-none = אין צורך להפריש דבר
holiday-monthly-now = יציאה החודש
holiday-note-days = הימים הם הלילות ועוד אחד: שבעה לילות הם שמונה ימים.
holiday-note-child = בסעיף לאדם, ילד משלם את מחיר הילד אם צוין; אם השדה ריק, הוא משלם כמו מבוגר.
holiday-note-percent = אחוז ביטוח חל על הסעיפים העיקריים של הטיול; אחוז עמלות הבנק – על ההוצאות ביעד.
holiday-sheet-budget = תקציב
holiday-sheet-result = תוצאה
holiday-column-line = סעיף
holiday-column-amount = סכום
holiday-column-child = מחיר לילד
holiday-column-who = עבור מי
holiday-column-span = לכמה זמן
holiday-column-cost = עלות
holiday-disclaimer = הערכה המבוססת על הסכומים שלך: המחירים בפועל עשויים להשתנות.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = פרויקט צמצום
cut-file-not-project = קובץ זה אינו פרויקט צמצום של Radinus.
cut-file-too-recent = פרויקט זה מגיע מגרסה חדשה יותר של Radinus: יש לעדכן את Radinus כדי לפתוח אותו.
cut-sheet-items = פריטים

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = יומן הרכב שלי
window-car-title = יומן הרכב שלי
car-unnamed = הרכב שלי
car-sheet-title = הרכב
car-field-plate = מספר רישוי
car-field-make = יצרן
car-field-model = דגם
car-field-engine = סוג הנעה
car-field-first-hand = יד ראשונה
car-field-registered = עלייה לכביש
car-field-acquired = תאריך הרכישה
car-field-acquired-km = קילומטראז' ברכישה
car-field-service = טיפול כל
car-field-service-or = או כל
car-unit-months-short = חודשים
car-unit-km = km
car-tariff-title = תעריף הטעינה בבית
car-tariff-hint = תעריף זה נשמר ביומן הרכב: הוא אינו משנה את התעריף שבהעדפות.
car-tariff-reset = שימוש בתעריף מההעדפות
car-engine-petrol = בנזין
car-engine-diesel = דיזל
car-engine-lpg = גז (LPG)
car-engine-e85 = E85 (ביו־אתנול)
car-engine-hybrid = היברידי
car-engine-plug-in = היברידי נטען (פלאג־אין)
car-engine-electric = חשמלי
car-engine-hydrogen = מימן
car-energy-petrol = בנזין
car-energy-diesel = סולר
car-energy-lpg = גז (LPG)
car-energy-e85 = E85
car-energy-electricity = חשמל
car-energy-hydrogen = מימן
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = אנרגיה
car-rubric-upkeep = תחזוקה שוטפת
car-rubric-service = טיפול תקופתי
car-rubric-wear = חלקים מתבלים
car-rubric-tyres = צמיגים
car-rubric-breakdown = תקלות
car-rubric-insurance = ביטוח
car-rubric-inspection = טסט
car-part-brake-pads = רפידות בלמים
car-part-brake-discs = דיסקים של בלמים
car-part-timing-belt = רצועת תזמון
car-part-clutch = מצמד
car-part-battery-12v = מצבר 12 V
car-part-shock-absorbers = בולמי זעזועים
car-part-wipers = מגבים
car-part-spark-plugs = מצתים
car-part-glow-plugs = מצתי להט
car-part-particulate-filter = מסנן חלקיקים
car-part-catalytic-converter = ממיר קטליטי
car-part-fuel-cell-filter = מסנן תא הדלק
car-part-exhaust = מערכת פליטה
car-part-other = חלק אחר…
car-axle-all = ארבעת הצמיגים
car-axle-front = צמיגים קדמיים
car-axle-rear = צמיגים אחוריים
car-verdict-pass = עבר
car-verdict-counter = טסט חוזר
car-charge-station = בעמדת טעינה
car-charge-home = בבית
car-slot-peak = שעות שיא
car-slot-off-peak = שעות שפל
car-entry-new = שורה חדשה
car-entry-edit = עריכת השורה
car-field-date = תאריך
car-field-km = מד אוץ
car-field-rubric = קטגוריה
car-field-amount = סכום
car-field-garage = מוסך או תחנה
car-field-note = הערה
car-field-energy = אנרגיה
car-field-quantity = כמות
car-field-charge = טעינה
car-field-slot = שעת הטעינה
car-field-part = חלק
car-field-part-name = שם החלק
car-field-axle = צמיגים שהוחלפו
car-field-verdict = תוצאה
car-field-months = חודשים מכוסים
car-field-battery = מצב הסוללה
car-home-amount-hint = הסכום של טעינה בבית מחושב לפי התעריף של הרכב.
car-entry-add = הוספה ליומן
car-entry-update = שמירת השורה
car-entry-cancel = ביטול
car-entry-delete = מחיקת השורה
car-delete-question = למחוק את השורה הזו מהיומן?
car-from-operation = לקיחת תנועה…
car-pick-account = מאיזה חשבון באה ההוצאה?
car-pick-operation = איזו תנועה?
car-pick-take = לקיחה
car-pick-none = אין הוצאות בחשבון זה.
car-pick-taken = התנועה נלקחה: יש להשלים את מד האוץ ואת הקטגוריה, ואז להוסיף את השורה.
car-history-title = ההיסטוריה
car-filter-all = כל הקטגוריות
car-history-empty = אין עדיין שורות.
car-history-hint = יש ללחוץ על שורה כדי לערוך אותה.
car-column-date = תאריך
car-column-km = ק״מ
car-column-rubric = קטגוריה
car-column-detail = פירוט
car-column-amount = סכום
car-column-garage = מוסך
car-column-note = הערה
car-column-share = חלק יחסי
car-column-per-km = לק״מ
car-column-energy = אנרגיה
car-column-quantity = כמות
car-column-price = מחיר ממוצע
car-column-consumption = צריכה
car-column-part = חלק
car-column-changes = החלפות
car-column-last = החלפה אחרונה
car-column-life = אורך חיים
car-column-next = ההחלפה הבאה
car-total = סך הכול
car-summary-title = כמה עולה הרכב
car-headline-empty = יש למלא את פרטי הרכב ואז להוסיף שורה ראשונה: תדלוק, טיפול, חשבונית מוסך…
car-headline = מאז { $since }, הרכב שלך עלה לך { $total }.
car-headline-km = מאז { $since }, הרכב שלך עלה לך { $total } עבור { $km } שנסעת: { $cost } לקילומטר.
car-tile-total = עלות כוללת
car-tile-month = לחודש
car-tile-km = לקילומטר
car-tile-driven = קילומטרים שנסעת
car-tile-consumption = צריכה
car-tile-energy-km = אנרגיה לקילומטר
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] חודש אחד
        [two] חודשיים
       *[other] { $months } חודשים
    }
car-detail-battery = סוללה: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = לפי קטגוריה
car-energy-title = האנרגיה
car-parts-title = חלקים מתבלים
car-tyres-title = צמיגים
car-battery-title = מצב הסוללה
car-years-title = כמה עלה הרכב בכל שנה
car-donut-title = לאן הולך הכסף
car-donut-caption = בסך הכול
car-deadlines-title = המועדים הקרובים
car-deadlines-empty = אין עדיין מועדים: יש לרשום טיפול, טסט, ביטוח, או שתי החלפות של אותו חלק.
car-deadline-service = טיפול תקופתי
car-deadline-inspection = טסט
car-deadline-counter = טסט חוזר
car-deadline-insurance = סיום הביטוח
car-when-date = ב־{ $date }
car-when-km = ב־{ $km }
car-when-km-reached = ב־{ $km }, בסביבות { $month } בקצב שלך
car-when-date-km = ב־{ $date } או ב־{ $km }, המוקדם מביניהם
car-when-inspection-unknown = יש לרשום את הטסט האחרון כדי לדעת את מועד הטסט הבא.
car-tone-late = עבר המועד
car-tone-soon = בקרוב
car-note-since = הכול נספר מיום הרכישה: התאריך ומד האוץ שנרשמו בפרטי הרכב.
car-note-consumption = הצריכה נמדדת ממילוי מלא למילוי מלא: יש למלא את המיכל עד הסוף ולרשום את מד האוץ בכל פעם.
car-note-e85 = רכב E85 שותה את מה שנותנים לו: הקילומטרים שאחרי תדלוק נספרים לדלק שתודלק.
car-note-home = טעינה בבית מתומחרת לפי התעריף של הרכב ביום שבו היא נרשמת, ושומרת על עלות זו.
car-note-inspection = הטסט פועל לפי הכלל הצרפתי: הראשון בתוך ארבע שנים מהעלייה לכביש, ולאחר מכן כל שנתיים; טסט חוזר, בתוך חודשיים.
car-disclaimer = המועדים ואורכי החיים הם הערכות שנגזרות מהיומן: רק ספר הטיפולים של היצרן הוא המחייב.
car-invalid-date = יש להזין תאריך תקין שאינו בעתיד.
car-invalid-acquired = תאריך הרכישה אינו יכול להקדים את העלייה לכביש.
car-invalid-km = יש להזין מד אוץ בקילומטרים שלמים.
car-invalid-amount = לא ניתן לקרוא את הסכום הזה.
car-invalid-quantity = יש להקליד את הכמות: ליטרים, kWh או קילוגרמים.
car-invalid-part = יש לבחור את החלק שהוחלף, או להקליד את שמו.
car-invalid-rubric = יש לבחור קטגוריה.
car-invalid-months = יש להזין מספר שלם של חודשים.
car-invalid-battery = יש להזין מצב סוללה בין 0 ל־100 %.
car-open = פתיחת יומן…
car-save = שמירת היומן…
car-report-button = דוח PDF
car-file-filter = יומן רכב
car-file-saved = היומן נשמר: { $file }
car-file-opened = היומן נפתח: { $file }
car-file-not-logbook = קובץ זה אינו יומן רכב של Radinus.
car-file-too-recent = יומן זה מגיע מגרסה חדשה יותר של Radinus: יש לעדכן את Radinus כדי לפתוח אותו.
car-replace-question = פתיחת היומן הזה תחליף את היומן שבחלון. להמשיך?
car-sheet-history = יומן
car-sheet-summary = סיכום

analysis-history-hint = ככל שההיסטוריה שלך ארוכה יותר, כך הניתוח הזה יהיה טוב יותר: האידיאל הוא לפחות שנה של תנועות.

# --- F48 — חלוקת הוצאה (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = חלוקת הוצאה
window-sharing-title = חלוקת הוצאה
sharing-question = מי משלם מה?
sharing-setup-title = החלוקה
sharing-field-label = תיאור
sharing-label-hint = לדוגמה "מסעדה ב-12/10" או "טיול בבריטני 2027": הוא נותן שם לקבצים ולדוחות.
sharing-field-total = סכום כולל
sharing-total-hint = כשהשדה ריק, הסכום הכולל הוא סכום הסעיפים והתוספות האישיות של כל אחד.
sharing-field-rule = כלל
sharing-field-rounding = עיגול
sharing-field-people = אנשים
sharing-mode-whole = כלל אחד לכל ההוצאה
sharing-mode-item = כלל אחד לכל סעיף
sharing-rule-equal = חלקים שווים
sharing-rule-parts = לפי חלקים
sharing-rule-percent = לפי אחוזים
sharing-rule-income = ביחס להכנסות
sharing-rounding-cent = לסנט
sharing-rounding-euro = ליחידה שלמה
sharing-round-euro = עיגול ליחידות שלמות
sharing-hide-incomes = הסתרת הכנסות בדוחות ובייצוא
sharing-people-title = האנשים
sharing-people-hint = שורה אחת לכל אדם, עמודה אחת לכל סעיף: יש לסמן מי משתתף במה. כל השאר הוא רשות. מי שמבטל ומשאיר את המקדמה שלו: סכום מדויק השווה למה ששילם, וללא סימון באף תיבה.
sharing-add-person = הוספת אדם
sharing-person-default = אדם { $number }
sharing-items-title = הסעיפים
sharing-items-hint = רק מה שלא נוגע לכולם, כמו היין. שאר הסכום הכולל הולך לסעיף המשותף.
sharing-add-item = הוספת סעיף
sharing-common = משותף
sharing-payments-title = התשלומים
sharing-payments-hint = מי שילם, כמה ומתי. שורה ללא סכום עדיין אינה נספרת.
sharing-payments-none = עדיין אין תשלומים.
sharing-add-payment = הוספת תשלום
sharing-result-title = התוצאה
sharing-balances-title = מצב התשלומים
sharing-transfers-title = העברות מוצעות
sharing-delete = מחיקה
sharing-delete-person-question = לאדם הזה יש תשלומים: למחוק אותם יחד איתו?
sharing-disclaimer = Radinus מציע חלוקה: בין חברים, כל אחד חופשי להסתדר אחרת.
sharing-column-person = אדם
sharing-column-household = משק בית
sharing-column-income = הכנסה
sharing-column-parts = חלקים
sharing-column-percent = %
sharing-column-floor = לפחות
sharing-column-cap = לכל היותר
sharing-column-fixed = סכום מדויק
sharing-column-alone = תוספות אישיות
sharing-column-gift = עודף שניתן
sharing-column-share = חלק
sharing-column-typed = % שהוקלד
sharing-column-constraint = מה שהשפיע
sharing-column-due = לתשלום
sharing-column-item = סעיף
sharing-column-amount = סכום
sharing-column-rule = כלל
sharing-column-participants = משתתפים
sharing-column-unit = משק בית או אדם
sharing-column-members = חברים
sharing-column-paid = שולם
sharing-column-balance = יתרה
sharing-column-date = תאריך
sharing-column-who = מי
sharing-column-label = תיאור
sharing-help-household = אנשים באותו משק בית מסדירים את החשבון יחד: התשלומים שלהם והסכומים שהם חבים מצטרפים, והם מקבלים דף חשבון אחד. לדוגמה: "משפחת מרטין" להורים ולילדים.
sharing-help-income = משמש רק בכלל "ביחס להכנסות": ככל שההכנסה גבוהה יותר, החלק גדול יותר. יש להקליד את ההכנסה החודשית.
sharing-help-parts = אדם עם 2 חלקים משלם פי שניים מאדם עם חלק אחד. לדוגמה: מבוגר 1, ילד 0.5.
sharing-help-percent = החלק מההוצאה שהאדם משלם. סך האחוזים חייב להיות 100 %.
sharing-help-floor = האדם ישלם לפחות את הסכום הזה, גם אם החלק שחושב לו קטן יותר. ההפרש מקל על האחרים.
sharing-help-cap = האדם לא ישלם לעולם יותר מהסכום הזה. מה שאינו משלם נופל על שאר המשתתפים בסעיפים שלו.
sharing-help-fixed = האדם משלם את הסכום המדויק הזה, יהי מה, והשאר מתחלק בין האחרים. לדוגמה: מי שמבטל ומשאיר את המקדמה שלו.
sharing-help-alone = מה שהאדם לקח לעצמו בלבד, כמו קינוח או קפה. הוא משלם אותו במלואו, בנוסף לחלקו.
sharing-help-gift = אם האדם שילם יותר מחלקו: כשהתיבה מסומנת, העודף הוא מתנה לקבוצה; כשאינה מסומנת, הוא מוחזר לו.
sharing-help-items = יש לסמן את האנשים שמשתתפים בסעיף הזה. הסעיף המשותף הוא מה שנשאר מהסכום הכולל לאחר הסרת שאר הסעיפים.
sharing-help-due = מה שהאדם חייב בסך הכול: חלקו בסעיפים, התוספות האישיות שלו והעיגול.
sharing-help-share = מה שחלקו מייצג, באחוזים מהסכום המתחלק.
sharing-help-typed = האחוז שהוקלד. הוא יכול להיות שונה מהחלק בפועל כשמינימום, מקסימום או סכום מדויק השפיעו.
sharing-help-constraint = מציין אם חלקו של האדם שונה בגלל מינימום, מקסימום, סכום מדויק או עודף שניתן.
sharing-help-item = רק מה שלא נוגע לכולם, כמו היין. שאר הסכום הכולל הולך לסעיף המשותף, ומתחלק בין המסומנים בו.
sharing-help-rule = כיצד הסעיף הזה מתחלק: בחלקים שווים, לפי חלקים, לפי אחוזים או ביחס להכנסות.
sharing-help-paid = מה שמשק הבית או האדם כבר שילם, לפי התשלומים שהוזנו.
sharing-help-balance = מה שנותר לשלם, או מה ששולם מעבר לחלק. לדוגמה: "נותר לשלם: 61.54 €".
sharing-advice-equal = { $count ->
        [one] { $total } לאדם אחד בלבד.
        [two] { $total } ÷ שני אנשים = { $amount } לכל אחד.
       *[other] { $total } ÷ { $count } אנשים = { $amount } לכל אחד.
    }
sharing-advice-equal-varied = בחלקים שווים בין המשתתפים, בהתחשב במגבלות ובהחרגות.
sharing-advice-parts = { $parts } חלקים בסך הכול: חלק אחד שווה { $amount }.
sharing-advice-parts-varied = כל אחד משלם לפי החלקים שלו, בהתחשב במגבלות ובהחרגות. שדה ריק נחשב לחלק אחד.
sharing-advice-percent-rest = חסרים { $rest } % כדי להגיע ל־100 %.
sharing-advice-percent-over = האחוזים עוברים את 100 % ב־{ $over } %.
sharing-advice-percent-ok = האחוזים מסתכמים בדיוק ב־100 %.
sharing-advice-percent-nobody = האחוזים כבר מגיעים ל־100 %: { $count ->
        [one] { $names } לא ישלם כלום.
        [two] { $names } לא ישלמו כלום.
       *[other] { $names } לא ישלמו כלום.
    }
sharing-advice-income = כל אחד משלם { $rate } % מההכנסה שלו.
sharing-advice-income-missing = יש להקליד את ההכנסה של כל אחד כדי לחלק ביחס להכנסות.
sharing-advice-income-varied = כל אחד משלם אותו שיעור מההכנסה שלו, בהתחשב במגבלות ובהחרגות.
sharing-advice-empty = יש להקליד את הסכום לחלוקה.
sharing-apply-advice = שימוש בערכים המוצעים
sharing-help-apply-advice = ממלא את השדות הריקים בערכים האפורים. שדות שכבר מולאו אינם משתנים.
sharing-from-incomes = אחוזים לפי ההכנסות
sharing-help-from-incomes = מחליף את האחוזים בחלקה של כל הכנסה מסך ההכנסות. יחד הם מגיעים ל־100 %.
sharing-reset-percents = חלוקה מחדש של הכול
sharing-help-reset-percents = מוחק את האחוזים ומחלק אותם שווה בשווה בין כולם. שימושי לאחר הוספת אדם.
sharing-reset-percents-question = למחוק את כל האחוזים ולחלק אותם שווה בשווה?
sharing-open = פתיחת פרויקט…
sharing-save = שמירת הפרויקט…
sharing-pdf-distribution = חלוקה (PDF)
sharing-pdf-payments = מצב התשלומים (PDF)
sharing-pdf-statements = דפי חשבון אישיים (PDF)…
sharing-statements-everyone = כולם
sharing-excel = ייצוא ל־Excel
sharing-file-filter = פרויקט חלוקה
sharing-replace-question = פתיחת הפרויקט הזה תחליף את מה שהוקלד בחלון. להמשיך?
sharing-file-saved = הפרויקט נשמר: { $file }
sharing-file-opened = הפרויקט נפתח: { $file }
sharing-file-not-project = קובץ זה אינו פרויקט חלוקה של Radinus.
sharing-file-too-recent = פרויקט זה מגיע מגרסה חדשה יותר של Radinus: יש לעדכן את Radinus כדי לפתוח אותו.
sharing-file-failed = לא ניתן היה לקרוא או לכתוב את הקובץ: { $reason }
sharing-statements-replace-question = { $count ->
        [one] כבר קיים דף חשבון אחד בתיקייה הזאת. להחליף אותו?
        [two] כבר קיימים שני דפי חשבון בתיקייה הזאת. להחליף אותם?
       *[other] כבר קיימים { $count } דפי חשבון בתיקייה הזאת. להחליף אותם?
    }
sharing-statements-written = { $count ->
        [one] דף חשבון אחד נכתב בתיקייה "{ $folder }".
        [two] שני דפי חשבון נכתבו בתיקייה "{ $folder }".
       *[other] { $count } דפי חשבון נכתבו בתיקייה "{ $folder }".
    }
sharing-too-many-people = חלוקה כוללת 40 אנשים לכל היותר.
sharing-too-many-items = חלוקה כוללת 20 סעיפים לכל היותר.
sharing-too-many-payments = חלוקה כוללת 400 תשלומים לכל היותר.
sharing-invalid-amount = לא ניתן לקרוא את הסכום הזה: מספר חיובי.
sharing-invalid-number = לא ניתן לקרוא את המספר הזה: מספר חיובי.
sharing-invalid-percent = אחוז הוא בין 0 ל־100.
sharing-invalid-date = לא ניתן לקרוא את התאריך הזה.
sharing-name-missing = לכל אדם חייב להיות שם.
sharing-name-duplicate = כבר קיים "{ $name }": יש להבדיל ביניהם, למשל באות ראשונה.
sharing-floor-above-cap = המינימום גבוה מהמקסימום.
sharing-item-label-missing = לסעיף הזה אין שם.
sharing-items-above-total = הסעיפים והתוספות האישיות של כל אחד עולים על הסכום הכולל ב־{ $amount }.
sharing-payment-person = יש לבחור מי שילם.
sharing-percent-total = האחוזים מסתכמים ב־{ $sum } %: הם צריכים להגיע ל־100 %.
sharing-percent-total-item = "{ $item }": האחוזים מסתכמים ב־{ $sum } %: הם צריכים להגיע ל־100 %.
sharing-item-nobody = אף אחד אינו משתתף ב־"{ $item }".
sharing-item-no-weight = אף אחד אינו משפיע על "{ $item }": כל משתתפיו מאופסים.
sharing-income-missing = חסרה ההכנסה של { $name }.
sharing-fixed-above = הסכומים המדויקים עולים על הסכום לחלוקה ב־{ $amount }.
sharing-floors-above = המינימומים עולים על הסכום לחלוקה ב־{ $amount }.
sharing-cap-alone = ב־"{ $item }" משתתף רק { $name }: לא ניתן לכבד את המקסימום שלו.
sharing-caps-short = המקסימומים אינם מספיקים לכיסוי הסכום: חסרים { $amount }.
sharing-impossible = לא ניתן לכבד את כל התנאים האלה: יש להקל על מינימום או על מקסימום.
sharing-constraint-floor = הושג המינימום
sharing-constraint-cap = הושג המקסימום
sharing-constraint-fixed = סכום מדויק
sharing-constraint-gift = עודף שניתן
sharing-and = { $first } ו־{ $last }
sharing-outside = מחוץ לסעיפים
sharing-alone = תוספות אישיות
sharing-rounding = עיגול
sharing-headline-empty = יש להוסיף את האנשים שמתחלקים בהוצאה.
sharing-headline-no-amount = יש להזין את הסכום הכולל, או את הסעיפים לחלוקה.
sharing-headline-equal = { $total } לחלוקה: כל אחד משלם { $amount }.
sharing-headline-range = { $total } לחלוקה: מ־{ $min } עד { $max }, תלוי באדם.
sharing-participants = { $count ->
        [0] אין משתתפים
        [one] משתתף אחד
        [two] שני משתתפים
       *[other] { $count } משתתפים
    }
sharing-balance-due = נותר לשלם: { $amount }
sharing-balance-over = שולמו { $amount } מעבר לחלק
sharing-balance-even = מעודכן
sharing-summary-collected = שולמו { $collected } מתוך { $total }.
sharing-summary-owing = { $count ->
        [0] כולם מעודכנים.
        [one] רק אחד עדיין חייב { $amount }.
        [two] שניים עדיין חייבים { $amount } בסך הכול.
       *[other] { $count } עדיין חייבים { $amount } בסך הכול.
    }
sharing-remaining-outside = נותר לשלם על ההוצאה: { $amount }
sharing-remaining-reimburse = להחזיר ל־{ $name }: { $amount }
sharing-all-settled = הכול שולם: אף אחד אינו חייב דבר לאף אחד.
sharing-transfer = על { $from } להעביר { $amount } אל { $to }
sharing-warning-over-paid = התשלומים עולים על ההוצאה ב־{ $amount }: יש לבדוק את הסכומים.
sharing-note-income-zero = ההכנסה של { $name } היא 0, ולכן אין תשלום על { $items }.
sharing-note-excluded = { $name } אינו משתתף ב־"{ $item }": החלק שלו מתחלק בין האחרים.
sharing-note-gift = העודף שניתן על ידי { $giver } מקטין את חלקם של האחרים: { $name } שילם כעת יותר מחלקו.
sharing-note-outside = { $name } משלם { $amount } מחוץ לסעיפים שלו: הסכום מנוכה ממה שהאחרים מתחלקים בו.
sharing-note-keeper = עיגול ליחידות שלמות: { $name } שומר את הסנטים, כדי שהסכום הכולל ייצא מדויק.
sharing-report-distribution = חלוקה
sharing-report-sharing = החלוקה
sharing-report-who-pays = מי משלם מה
sharing-report-items = פירוט לפי סעיף
sharing-report-payments = מצב התשלומים
sharing-report-as-of = מצב ליום { $date }
sharing-report-balances = חלק, שולם, יתרה
sharing-report-statement = דף חשבון — { $name }
sharing-report-your-share = החלק שלך
sharing-statement-total = סך הכול למשק הבית: { $amount }
sharing-statement-pay = לתשלום ל־{ $name }: { $amount }
sharing-statement-receive = לקבל מ־{ $name }: { $amount }
sharing-sheet-people = אנשים
sharing-sheet-items = סעיפים
sharing-sheet-result = תוצאה
sharing-sheet-payments = תשלומים
sharing-sheet-balances = החזרים

## אשף הייצוא של מסד נתונים (P-74, Fabrice, 19/10/2026).
window-database-export-title = אשף ייצוא של מסד הנתונים "{ $base }"
menu-tools-export = אשף ייצוא של מסד הנתונים…
base-export-only-this = רק מסד הנתונים "{ $base }", שנבחר ברשימה, ייוצא. מסדי הנתונים האחרים אינם מושפעים.
base-export-purpose = אשף זה מעתיק את נתוני המסד לקבצים שתוכנות אחרות יודעות לקרוא: גיליון אלקטרוני, מסד נתונים כמו Access, תוכנה אחרת לניהול כספים אישיים. מסד הנתונים עצמו אינו משתנה.
base-export-step-format = 1. הפורמט
base-export-step-options = 2. האפשרויות
base-export-step-place = 3. המיקום
base-export-step-summary = 4. הסיכום
base-export-format-xlsx = Excel (.xlsx)
base-export-format-xlsx-hint = חוברת עבודה עם גיליון אחד לכל טבלה, שאפשר לפתוח ב-Excel וברוב תוכנות הגיליונות האלקטרוניים.
base-export-format-ods = Calc (.ods)
base-export-format-ods-hint = הפורמט הפתוח של LibreOffice ו-OpenOffice, עם גיליון אחד לכל טבלה.
base-export-format-csv = CSV (.csv)
base-export-format-csv-hint = קובץ טקסט אחד לכל טבלה, עם ערכים המופרדים בנקודה-פסיק (;): הפורמט שכמעט כל תוכנה יודעת לייבא, כולל Access.
base-export-format-json = JSON (.json)
base-export-format-json-hint = למתכנתים וליישומים: כל טבלה תחת שמה, עם כותרת שמתארת את הייצוא.
base-export-format-xml = XML (.xml)
base-export-format-xml-hint = אותו תוכן כמו ב-JSON, כתוב ב-XML.
base-export-format-sql = סקריפט SQL (.sql)
base-export-format-sql-hint = ההוראות שיוצרות מחדש את הטבלאות ואת הנתונים שלהן במסד נתונים אחר (MySQL, PostgreSQL, SQLite…).
base-export-format-sqlite = מסד נתונים SQLite (.sqlite)
base-export-format-sqlite-hint = מסד נתונים עצמאי, ללא סיסמה, שכלים רבים פותחים ישירות.
base-export-format-qif = QIF, קובץ אחד לכל חשבון (.qif)
base-export-format-qif-hint = כדי להעביר את החשבונות שלך לתוכנה אחרת לניהול כספים אישיים (Money, Quicken, GnuCash, Grisbi…).
base-export-format-ofx = OFX, קובץ אחד לכל חשבון (.ofx)
base-export-format-ofx-hint = הפורמט של דפי חשבון בנק, שרוב התוכנות לניהול כספים אישיים יודעות לייבא.
base-export-lossy = שים לב: QIF ו-OFX אינם יכולים לשמור הכול. עוברות רק התנועות של החשבונות, עם הצדדים הנגדיים, הקטגוריות וההערות שלהן; העברה הופכת לתנועה רגילה בכל צד, ושאר הנתונים (תקציבים, תנועות חוזרות, פרויקטים, הקצאות…) אינם עוברים. כדי לשמור הכול, בחר פורמט אחר.
base-export-planned-note = תנועות מתוכננות ותנועות ללא תאריך אינן מיוצאות: הן עדיין לא עברו בבנק. מספרן יוצג בסוף.
base-export-dates-hint = התאריכים נכתבים בסדר שנה-חודש-יום (2026-12-31) והסכומים במטבע של מסד הנתונים: אף תוכנה לא תטעה בקריאתם.
base-export-group-layout = קבצים
base-export-layout-one = הכול בקובץ אחד
base-export-layout-per-table = קובץ אחד לכל טבלה, בתוך תיקייה
base-export-group-decimal = מפריד עשרוני לסכומים
base-export-decimal-point = נקודה (1234.56)
base-export-decimal-comma = פסיק (1234,56)
base-export-group-quotes = מירכאות
base-export-quotes-all = כל ערך בתוך מירכאות
base-export-quotes-none = ללא מירכאות
base-export-csv-replacements-hint = כדי שכל קובץ ייקרא מחדש ללא שגיאה, נקודה-פסיק (;) בתוך טקסט הופכת לסימן קריאה (!), מעבר שורה הופך לרווח, וכשאין מירכאות, מירכאה הופכת לגרש. מספר ההחלפות יוצג בסוף.
base-export-group-qif-order = סדר התאריך
base-export-qif-day-month = היום לפני החודש (31/12/2026)
base-export-qif-month-day = החודש לפני היום (12/31/2026)
base-export-qif-order-hint = בחר את הסדר שמצפה לו התוכנה שתקרא את הקבצים: היום קודם באירופה, החודש קודם בארצות הברית.
base-export-no-option = לפורמט זה אין אפשרויות.
base-export-choose-file = בחירת הקובץ…
base-export-choose-folder = בחירת התיקייה…
base-export-place-file = הייצוא ייכתב לקובץ הזה:
base-export-place-folder = הייצוא ייכתב לתיקייה הזאת, שתיווצר במיוחד לשם כך:
base-export-place-none = עדיין לא נבחר מיקום.
base-export-place-needed = בחר תחילה היכן לכתוב את הייצוא.
base-export-folder-exists = התיקייה "{ $name }" כבר קיימת. קבצים בעלי אותו שם שנמצאים בה יוחלפו. להמשיך?
base-export-summary-base = מסד נתונים
base-export-summary-format = פורמט
base-export-summary-options = אפשרויות
base-export-summary-place = מיקום
base-export-unprotected = מסד נתונים זה מוגן בסיסמה, אך הייצוא לא יהיה מוגן: כל מי שיחזיק בקבצים האלה יוכל לקרוא את החשבונות שלך. שמור אותם במקום בטוח.
base-export-previous = הקודם
base-export-next = הבא
base-export-run = ייצוא
base-export-running = הייצוא מתבצע…
base-export-done = מסד הנתונים "{ $base }" יוצא: { $tables ->
        [one] טבלה אחת
        [two] שתי טבלאות
       *[other] { $tables } טבלאות
    }, { $rows ->
        [one] שורה אחת
        [two] שתי שורות
       *[other] { $rows } שורות
    }.
base-export-done-accounts = מסד הנתונים "{ $base }" יוצא: { $accounts ->
        [one] חשבון אחד
        [two] שני חשבונות
       *[other] { $accounts } חשבונות
    }, { $operations ->
        [one] תנועה אחת
        [two] שתי תנועות
       *[other] { $operations } תנועות
    }.
base-export-done-replacements = { $count ->
        [one] תו אחד הוחלף בקובצי ה-CSV.
        [two] שני תווים הוחלפו בקובצי ה-CSV.
       *[other] { $count } תווים הוחלפו בקובצי ה-CSV.
    }
base-export-done-controls = { $count ->
        [one] { $count } תו בקרה, שפורמט זה אינו יכול להכיל, הוחלף ב-"�".
        [two] שני תווי בקרה, שפורמט זה אינו יכול להכיל, הוחלפו ב-"�".
       *[other] { $count } תווי בקרה, שפורמט זה אינו יכול להכיל, הוחלפו ב-"�".
    }
base-export-done-excel-cut = { $count ->
        [one] { $count } טקסט חרג מ-32,767 תווים, המגבלה של Excel: הוא נחתך בחוברת העבודה. שאר הפורמטים שומרים אותו במלואו.
        [two] שני טקסטים חרגו מ-32,767 תווים, המגבלה של Excel: הם נחתכו בחוברת העבודה. שאר הפורמטים שומרים אותם במלואם.
       *[other] { $count } טקסטים חרגו מ-32,767 תווים, המגבלה של Excel: הם נחתכו בחוברת העבודה. שאר הפורמטים שומרים אותם במלואם.
    }
base-export-done-anomalies = { $count ->
        [one] ערך אחד שאינו קריא הועתק כפי שהוא.
        [two] שני ערכים שאינם קריאים הועתקו כפי שהם.
       *[other] { $count } ערכים שאינם קריאים הועתקו כפי שהם.
    }
base-export-done-planned = { $count ->
        [one] תנועה מתוכננת אחת לא נכללה.
        [two] שתי תנועות מתוכננות לא נכללו.
       *[other] { $count } תנועות מתוכננות לא נכללו.
    }
base-export-done-undated = { $count ->
        [one] תנועה אחת ללא תאריך לא נכללה.
        [two] שתי תנועות ללא תאריך לא נכללו.
       *[other] { $count } תנועות ללא תאריך לא נכללו.
    }
base-export-done-adjusted = { $count ->
        [one] ערך אחד הותאם לפורמט.
        [two] שני ערכים הותאמו לפורמט.
       *[other] { $count } ערכים הותאמו לפורמט.
    }
base-export-too-old = מסד נתונים זה מגיע מגרסה ישנה יותר של Radinus. פתח אותו תחילה פעם אחת ב-Radinus, שיעדכן אותו, ולאחר מכן ייצא אותו.
base-export-too-recent = מסד נתונים זה נשמר בגרסה חדשה יותר של Radinus. עדכן את Radinus כדי לייצא אותו.
base-export-not-radinus = קובץ זה אינו מסד נתונים של Radinus.
base-export-failed = לא ניתן היה לבצע את הייצוא: { $reason }

## תפריט הכלים של חלון מסדי הנתונים מציג את שם המסד (Fabrice, 19/10/2026).
databases-tools-selected = מסד הנתונים הנבחר: "{ $base }"
databases-tools-none = לא נבחר מסד נתונים
menu-tools-backup = גיבוי מסד הנתונים "{ $base }"…
menu-tools-backup-none = גיבוי מסד הנתונים הנבחר…
menu-tools-restore = שחזור מסד הנתונים "{ $base }"…
menu-tools-restore-none = שחזור מסד הנתונים הנבחר…
menu-tools-repair = תיקון ואופטימיזציה של מסד הנתונים "{ $base }"…
menu-tools-repair-none = תיקון ואופטימיזציה של מסד הנתונים הנבחר…
