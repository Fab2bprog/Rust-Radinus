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
menu-statistics-by-category = סטטיסטיקה לפי קטגוריות
menu-statistics-by-assignment = סטטיסטיקה לפי הקצאות
menu-statistics-by-budget-line = סטטיסטיקה לפי סעיפי תקציב
menu-statistics-by-payment-mode = סטטיסטיקה לפי אמצעי תשלום
menu-statistics-by-payee = סטטיסטיקה לפי צדדים נגדיים וסוחרים
menu-statistics-by-project = סטטיסטיקה לפי פרויקטים
menu-statistics-dashboard = לוח מחוונים של התנועות

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

menu-settings = הגדרות
menu-settings-about-author = אודות המחבר
menu-settings-about-radinus = אודות Radinus
menu-settings-licence = רישיון שימוש

menu-misc = שונות
menu-misc-calculator = מחשבון
menu-misc-website = מעבר לאתר של Radinus
menu-misc-database-folder = גישה לתיקייה המכילה את מסד הנתונים
menu-misc-application-folder = גישה לתיקייה המכילה את היישום

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
operations-column-label = תיאור
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
   *[category] סטטיסטיקה לפי קטגוריה
}

statistics-axis-column = { $kind ->
    [assignment] הקצאה
    [budget-line] סעיף תקציב
    [payment-mode] אמצעי תנועה
    [payee] צד נגדי
    [project] פרויקטים
   *[category] שם קטגוריה
}

statistics-unclassified = { $kind ->
    [assignment] ללא הקצאה
    [budget-line] ללא סעיף תקציב
    [payment-mode] ללא אמצעי תשלום
    [payee] ללא צד נגדי
    [project] ללא פרויקט
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
export-all-years-excel = ייצוא כל השנים ל-Excel
export-all-years-ods = ייצוא כל השנים ל-LibreOffice Calc
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
quick-column-date = תאריך
quick-column-label = תיאור
quick-column-amount = סכום
quick-column-category = קטגוריה
quick-column-assignment = הקצאה
quick-column-payment-mode = אמצעי תשלום
quick-column-payee = צד נגדי
quick-column-project = פרויקטים
quick-column-status = סטטוס
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
statement-column-debit = חובה
statement-column-credit = זכות
statement-account = חשבון
statement-file = קובץ
statement-difference = הפרש
statement-none = לא נפתח אף דף חשבון: יש ללחוץ על התיקייה הצהובה כדי לבחור קובץ.
statement-empty = דף חשבון זה אינו מכיל אף תנועה.
statement-no-match = אף שורה אינה תואמת את הסינון.
statement-help = מידע: יש להשתמש בלחיצת עכבר + מקש [{ $modifier }] בטבלה כדי לבחור כמה שורות
statement-choose-account = קובץ זה מכיל כמה חשבונות. איזה מהם לייבא?
statement-select-line = יש לבחור לפחות שורה אחת מדף החשבון.
statement-title-open = פתיחת קובץ דף חשבון (.ofx)
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
    { $count } תנועות, מתוכן { $known } כבר קיימות בחשבון שלך.
statement-group-identification = זיהוי התנועה
statement-group-amount = סכום התנועה
statement-group-classification = סיווג התנועה לצורך חישוב סטטיסטיקה
statement-group-status = סטטוס התנועה
statement-field-date = תאריך
statement-field-label = תיאור
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
excel-backup-later = הגיבוי עדיין אינו מחובר בגרסה הזו של Radinus 2. בינתיים, סגור את Radinus והעתק בעצמך את קובץ מסד הנתונים: כך תוכל לייבא בלי להסתכן.

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
backup-done = הגיבוי נכתב אל "{ $file }".
backup-failed = הגיבוי נכשל: { $reason }
restore-unreadable = קובץ זה אינו ארכיון Radinus קריא: { $reason }
# השאלה אומרת מה יאבד לפני שהוא אובד. הארכיון כבר נקרא
# ברגע הזה: מה שהוא מכריז הוא ודאי.
restore-question = לשחזר את "{ $file }"? כל התוכן הנוכחי של מסד הנתונים שלך יימחק ויוחלף, ומה שנמצא בו יאבד.
restore-done = השחזור הסתיים: { $accounts } חשבונות ו-{ $operations } תנועות.
restore-failed = השחזור נכשל: { $reason }


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
    [0] התיקון הסתיים: לא נמצאה אף תקלה. { $lines } שלבים נרשמו ביומן.
    [one] התיקון הסתיים: תקלה אחת תוקנה. { $lines } שלבים נרשמו ביומן.
    [two] התיקון הסתיים: שתי תקלות תוקנו. { $lines } שלבים נרשמו ביומן.
   *[other] התיקון הסתיים: { $anomalies } תקלות תוקנו. { $lines } שלבים נרשמו ביומן.
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

