# Radinus — رسائل جانب النواة (Fluent)، بالعربية.
# تملأ تدريجيا كلما نفذت وحدات النواة التي تنتج رسائل موجهة للمستخدم.
# انظر 08_ARCHITECTURE.md §2.1.

# القيمة الحارسة "0 = غير محدد" التي يستخدمها كل ارتباط اختياري بالبيانات
# الأساسية (02_BASE_DE_DONNEES.md §7 القاعدة 2). تظهر في أعلى كل قائمة منسدلة.
# ---------------------------------------------------------------------
# اسم اللغة، مكتوبا بلغته الخاصة.
#
# هذا ما تعرضه قائمة الإعدادات وأداة اختيار اللغة عند التشغيل الأول
# (01_CAHIER_DES_CHARGES.md §3.5: "كل لغة مكتوبة بلغتها الخاصة"). وهو هنا،
# لا في الكود، لأنه المكان الوحيد الذي يمكن أن يكون فيه صحيحا: إضافة لغة
# تعني وضع ملف يعرف كيف يسمي نفسه.
# ---------------------------------------------------------------------
language-name = العربية

nomenclature-unspecified = غير محدد

# يسأل قبل حذف عنصر من البيانات الأساسية ما زالت العمليات تستخدمه
# (02_BASE_DE_DONNEES.md §7 القاعدة 5). منقول حرفيا من مصدر WinDev الأصلي
# (Enreg_Supprimer)، بما في ذلك علامات الترقيم — الصياغة من وضع المؤلف،
# وليست ترجمة.
nomenclature-delete-confirm = تم اكتشاف عمليات (عمليات مصرفية) تحمل خاصية من نوع '{ $label }'. هل تؤكد رغبتك في إعادة تعيين هذه الخاصية؟

# يسأل قبل حذف عنصر من البيانات الأساسية لا يستخدمه شيء. النسخة الأصلية كانت
# تحذف مثل هذا العنصر مباشرة، دون كلمة؛ طلب Fabrice في 25/07/2026 أن يؤكد كل
# حذف — خروج مقصود عن الكود الخاص به، وهو الوحيد في هذه الوحدة.
nomenclature-delete-plain = هل تؤكد حذف "{ $label }"؟

# رفض يظهر عندما يكون العنصر المراد حذفه هو نفسه المعروض في بطاقته. قرار
# Fabrice في 25/07/2026: لا يحذف عنصر من تحت بطاقته المفتوحة — تغلق البطاقة
# أولا، بدل تركها تعرض سجلا لم يعد موجودا.
nomenclature-delete-form-open = بطاقة "{ $label }" مفتوحة. يجب إغلاقها قبل الحذف.

# رفض يظهر عندما يكون الوصف الجاري حفظه يحمله عنصر آخر من البيانات الأساسية
# نفسها (قرار المؤلف، 25/07/2026: لا يجوز أن يحمل عنصران من بيانات أساسية
# واحدة الاسم نفسه — تصنيف عملية تحت واحد من وصفين متطابقين ضرب من الحظ).
# `element` هو الاسم بجنسه الخاص، "فئة"، "طرف مقابل"؛ و`label` هو الوصف
# الموجود، كما هو مخزن، حتى يرى المستخدم ما يقف في الطريق.
nomenclature-duplicate = يوجد بالفعل { $element } بالاسم نفسه: "{ $label }".

# ---------------------------------------------------------------------
# ما تقوله النوافذ عن نفسها.
#
# كل شيء هنا، بما في ذلك ما يتوقف على البيانات الأساسية المعروضة: الجمل
# مكتوبة كاملة، لغة بعد لغة، بدل أن تصنع بتجميع الكلمات والأجناس. التجميع
# الصحيح في الفرنسية خاطئ في اللغة التالية، وينتهي الأمر بالكود وهو يعرف أن
# هناك مؤنثا — وليس ذلك من عمله (قاعدة المؤلف، 25/07/2026: "يعمل البرنامج
# مع Fluent بالفرنسية والإنجليزية منذ البداية").
# ---------------------------------------------------------------------

ui-loading = جاري التحميل…
ui-editing = تعديل.
ui-viewing = عرض.
ui-modified-suffix = — معدل
ui-label-required = الوصف إلزامي.
ui-discard-question = هل تريد إلغاء التعديلات؟
ui-yes = نعم
ui-no = لا
ui-select-record = يرجى تحديد سجل
ui-key-multiselect = CTRL
ui-multiselect-help = معلومة: استخدم نقر الفأرة + مفتاح [{ $modifier }] على الجدول لتحديد عدة عناصر
ui-no-match = لا يوجد وصف مطابق للتصفية.
ui-filter-placeholder = تصفية الأوصاف…
ui-column-label = الوصف
ui-field-label = الوصف
ui-field-budget-line = بند الميزانية
ui-identifier = المعرف
ui-deletion-abandoned = تم التخلي عن الحذف: لم يتغير أي شيء.
ui-unknown-nomenclature = بيانات أساسية غير معروفة:

ui-title-filter = تصفية
ui-title-create = إنشاء
ui-title-update = تعديل التحديد
ui-title-delete = حذف التحديد
ui-title-read = عرض التحديد
ui-title-close = إغلاق
ui-title-save = حفظ
ui-title-add = إضافة
ui-title-modify = تعديل

ui-load-failed = تعذر التحميل:
ui-save-failed = تعذر الحفظ:
ui-read-failed = تعذرت القراءة:
ui-delete-failed = تعذر الحذف:
ui-open-failed = تعذر الفتح:
ui-close-failed = تعذر الإغلاق:

# --- جمل خاصة بكل نوع من البيانات الأساسية ---------------------------

nomenclature-identifier = { $kind ->
    [category] معرف الفئة
    [assignment] معرف التخصيص
    [payment-mode] معرف طريقة الدفع
    [payee] معرف الطرف المقابل
    [project] معرف المشروع
    [budget-line] معرف بند الميزانية
   *[bank] معرف البنك
}

nomenclature-none = { $kind ->
    [category] لا توجد فئات.
    [assignment] لا توجد تخصيصات.
    [payment-mode] لا توجد طرق دفع.
    [payee] لا توجد أطراف مقابلة.
    [project] لا توجد مشاريع.
    [budget-line] لا توجد بنود ميزانية.
   *[bank] لا توجد بنوك.
}

nomenclature-nothing-to-show = { $kind ->
    [category] لا توجد فئات للعرض.
    [assignment] لا توجد تخصيصات للعرض.
    [payment-mode] لا توجد طرق دفع للعرض.
    [payee] لا توجد أطراف مقابلة للعرض.
    [project] لا توجد مشاريع للعرض.
    [budget-line] لا توجد بنود ميزانية للعرض.
   *[bank] لا توجد بنوك للعرض.
}

nomenclature-gone = { $kind ->
    [category] لم تعد هذه الفئة موجودة.
    [assignment] لم يعد هذا التخصيص موجودا.
    [payment-mode] لم تعد طريقة الدفع هذه موجودة.
    [payee] لم يعد هذا الطرف المقابل موجودا.
    [project] لم يعد هذا المشروع موجودا.
    [budget-line] لم يعد بند الميزانية هذا موجودا.
   *[bank] لم يعد هذا البنك موجودا.
}

nomenclature-fresh = { $kind ->
    [category] فئة جديدة.
    [assignment] تخصيص جديد.
    [payment-mode] طريقة دفع جديدة.
    [payee] طرف مقابل جديد.
    [project] مشروع جديد.
    [budget-line] بند ميزانية جديد.
   *[bank] بنك جديد.
}

nomenclature-created = { $kind ->
    [category] تمت إضافة الفئة.
    [assignment] تمت إضافة التخصيص.
    [payment-mode] تمت إضافة طريقة الدفع.
    [payee] تمت إضافة الطرف المقابل.
    [project] تمت إضافة المشروع.
    [budget-line] تمت إضافة بند الميزانية.
   *[bank] تمت إضافة البنك.
}

nomenclature-updated = { $kind ->
    [category] تم تعديل الفئة.
    [assignment] تم تعديل التخصيص.
    [payment-mode] تم تعديل طريقة الدفع.
    [payee] تم تعديل الطرف المقابل.
    [project] تم تعديل المشروع.
    [budget-line] تم تعديل بند الميزانية.
   *[bank] تم تعديل البنك.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [zero] لم يتم حذف أي فئة.
        [one] تم حذف فئة واحدة.
        [two] تم حذف فئتين.
        [few] تم حذف { $count } فئات.
        [many] تم حذف { $count } فئة.
       *[other] تم حذف { $count } فئة.
      }
    [assignment] { $count ->
        [zero] لم يتم حذف أي تخصيص.
        [one] تم حذف تخصيص واحد.
        [two] تم حذف تخصيصين.
        [few] تم حذف { $count } تخصيصات.
        [many] تم حذف { $count } تخصيصا.
       *[other] تم حذف { $count } تخصيص.
      }
    [payment-mode] { $count ->
        [zero] لم يتم حذف أي طريقة دفع.
        [one] تم حذف طريقة دفع واحدة.
        [two] تم حذف طريقتي دفع.
        [few] تم حذف { $count } طرق دفع.
        [many] تم حذف { $count } طريقة دفع.
       *[other] تم حذف { $count } طريقة دفع.
      }
    [payee] { $count ->
        [zero] لم يتم حذف أي طرف مقابل.
        [one] تم حذف طرف مقابل واحد.
        [two] تم حذف طرفين مقابلين.
        [few] تم حذف { $count } أطراف مقابلة.
        [many] تم حذف { $count } طرفا مقابلا.
       *[other] تم حذف { $count } طرف مقابل.
      }
    [project] { $count ->
        [zero] لم يتم حذف أي مشروع.
        [one] تم حذف مشروع واحد.
        [two] تم حذف مشروعين.
        [few] تم حذف { $count } مشاريع.
        [many] تم حذف { $count } مشروعا.
       *[other] تم حذف { $count } مشروع.
      }
    [budget-line] { $count ->
        [zero] لم يتم حذف أي بند ميزانية.
        [one] تم حذف بند ميزانية واحد.
        [two] تم حذف بندي ميزانية.
        [few] تم حذف { $count } بنود ميزانية.
        [many] تم حذف { $count } بند ميزانية.
       *[other] تم حذف { $count } بند ميزانية.
      }
   *[bank] { $count ->
        [zero] لم يتم حذف أي بنك.
        [one] تم حذف بنك واحد.
        [two] تم حذف بنكين.
        [few] تم حذف { $count } بنوك.
        [many] تم حذف { $count } بنكا.
       *[other] تم حذف { $count } بنك.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] توجد بالفعل فئة بالاسم نفسه: "{ $label }".
    [assignment] يوجد بالفعل تخصيص بالاسم نفسه: "{ $label }".
    [payment-mode] توجد بالفعل طريقة دفع بالاسم نفسه: "{ $label }".
    [payee] يوجد بالفعل طرف مقابل بالاسم نفسه: "{ $label }".
    [project] يوجد بالفعل مشروع بالاسم نفسه: "{ $label }".
    [budget-line] يوجد بالفعل بند ميزانية بالاسم نفسه: "{ $label }".
   *[bank] يوجد بالفعل بنك بالاسم نفسه: "{ $label }".
}

# --- عناوين النوافذ، بلا تشكيل كما في النوافذ الأصلية -----------------

window-list-title = { $kind ->
    [category] قائمة الفئات
    [assignment] قائمة التخصيصات
    [payment-mode] قائمة طرق الدفع
    [payee] قائمة الأطراف المقابلة والتجار
    [project] قائمة المشاريع
    [budget-line] قائمة بنود الميزانية
   *[bank] قائمة البنوك
}

window-form-title = { $kind ->
    [category] بطاقة الفئة
    [assignment] بطاقة التخصيص
    [payment-mode] بطاقة طريقة الدفع
    [payee] بطاقة الطرف المقابل
    [project] بطاقة المشروع
    [budget-line] بطاقة بند الميزانية
   *[bank] بطاقة البنك
}

# --- شريط القوائم (01_CAHIER_DES_CHARGES.md §6) -----------------------

menu-file = ملف
menu-file-import-statements = استيراد كشوف الحسابات البنكية
menu-file-import-excel = استيراد ملف Excel
menu-file-backup = نسخة احتياطية
menu-file-restore = الاستعادة
menu-file-repair = إصلاح قاعدة البيانات وتحسينها
menu-file-log = عرض السجل
menu-tools-password = حماية قاعدة البيانات بكلمة مرور
menu-file-disconnect = قطع الاتصال بقاعدة البيانات الحالية
menu-file-quit = خروج

menu-accounts = الحسابات
menu-accounts-manage = إدارة الحسابات المصرفية
menu-accounts-balances = عرض أرصدة حساباتك
menu-accounts-operations = إدارة عمليات حساب
menu-accounts-quick-classify = التصنيف السريع للعمليات
menu-accounts-recurring = إدارة العمليات المتكررة
menu-accounts-transfer = تحويل مبلغ بين حسابين
menu-accounts-checkbooks = إدارة دفاتر الشيكات

menu-statistics = الإحصائيات
menu-statistics-balance-chart = الرسم البياني لتطور الرصيد
menu-statistics-by-category = إحصائيات حسب الفئات
menu-statistics-by-assignment = إحصائيات حسب التخصيصات
menu-statistics-by-budget-line = إحصائيات حسب بنود الميزانية
menu-statistics-by-payment-mode = إحصائيات حسب طرق الدفع
menu-statistics-by-payee = إحصائيات حسب الأطراف المقابلة والتجار
menu-statistics-by-project = إحصائيات حسب المشاريع
menu-statistics-dashboard = لوحة معلومات العمليات

menu-budget = الميزانية
menu-budget-entry = إدخال الميزانية
menu-budget-control = مراقبة الميزانية

menu-nomenclatures = البيانات الأساسية
menu-nomenclature = { $kind ->
    [category] الفئات
    [assignment] التخصيصات
    [payment-mode] طرق الدفع
    [payee] الأطراف المقابلة والتجار
    [project] المشاريع
    [budget-line] بنود الميزانية
   *[bank] البنوك
}
menu-nomenclatures-templates = قوالب العمليات

menu-settings = الإعدادات
menu-settings-about-author = حول المؤلف
menu-settings-about-radinus = حول Radinus
menu-settings-licence = رخصة الاستخدام

menu-misc = متفرقات
menu-misc-calculator = آلة حاسبة
menu-misc-website = الانتقال إلى موقع Radinus
menu-misc-database-folder = الوصول إلى المجلد الذي يحتوي قاعدة البيانات

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = فتح مجلد قاعدة البيانات
database-folder-warning =
    يحتوي هذا المجلد على جميع بياناتك. إعادة تسمية ملف أو نقله أو حذفه قد يفقدك حساباتك أو يتلفها أو يمنع Radinus من العمل.
    هل تريد فتحه فعلاً؟
menu-misc-application-folder = الوصول إلى المجلد الذي يحتوي التطبيق
menu-misc-attachments-folder = الوصول إلى المجلد الذي يحتوي على المرفقات
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = إدارة المرفقات
window-attachments-manager-title = إدارة المرفقات
attachments-column-document = مستند
attachments-column-size = الحجم
attachments-column-added = أُضيف في
attachments-column-state = الحالة
attachments-state-intact = سليم
attachments-state-altered = تغيّر منذ ذلك الحين
attachments-state-missing = الملف مفقود
attachments-state-unknown = غير قابل للتحقق
attachments-state-orphan = يتيم
attachments-no-operation = لا عملية
attachments-orphan-remove-question = هذا الملف غير مرتبط بأي عملية. هل تنقله إلى سلة المهملات؟
attachments-manager-help = انقر نقرًا مزدوجًا على سطر لفتح المستند.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = عرض العملية
attachments-reveal = إظهار في مدير الملفات
attachments-manager-summary = { $count } مرفقات، { $size } إجمالاً.
attachments-disk-name = الاسم على القرص: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = فتح مجلد المرفقات
attachments-folder-warning =
    يحتوي هذا المجلد على الملفات التي أرفقتها بعملياتك. يحفظها Radinus باسم يختاره بنفسه: إعادة تسمية ملف أو نقله أو حذفه لا يفصله عن العملية، التي ستظل تعلن عنه ولن يُفتح بعد ذلك.
    هل تريد فتحه فعلاً؟

# ---------------------------------------------------------------------
# الحسابات المصرفية — F04, F06, F07, F08.
# أخطاء الطباعة في الإصدار 1.9.3 ("Bank Identifer Code"، "Solde
# initial prevu"، "Est Cloturé"، المسافة قبل قوس IBAN) تم تصحيحها:
# قرار Fabrice بتاريخ 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = إدارة الحسابات المصرفية
window-accounts-select-title = قائمة الحسابات
window-balances-title = أرصدة حساباتك
window-account-title = بطاقة الحساب

accounts-none = لا يوجد أي حساب.
accounts-nothing-to-show = لا يوجد أي حساب للعرض.
accounts-gone = هذا الحساب لم يعد موجودًا.
accounts-fresh = حساب جديد.
accounts-created = تمت إضافة الحساب.
accounts-updated = تم تعديل الحساب.
accounts-deleted = { $count ->
    [zero] لم يتم حذف أي حساب.
    [one] تم حذف حساب واحد.
    [two] تم حذف حسابين.
    [few] تم حذف { $count } حسابات.
    [many] تم حذف { $count } حسابًا.
   *[other] تم حذف { $count } حساب.
}
accounts-duplicate-name = يوجد بالفعل حساب بنفس الاسم: "{ $label }".
accounts-multiselect-help = معلومة: استخدم نقر الفأرة + مفتاح [{ $modifier }] على الجدول لتحديد عدة حسابات
accounts-select-question = على أي حسابات مصرفية يجب أن تستند الإحصائيات؟

accounts-column-label = الوصف
accounts-column-bank = البنك
accounts-column-type = نوع الحساب
accounts-column-number = رقم الحساب
accounts-column-account = الحساب
accounts-column-bank-balance = في البنك
accounts-column-real-balance = الفعلي
accounts-column-final-balance = النهائي
accounts-total = الإجمالي

# حذف حساب يستلزم حذف عملياته: هذا هو الموضع الوحيد في البرنامج الذي
# يؤدي فيه الحذف إلى إتلاف السجل التاريخي.
accounts-delete-plain = هل تؤكد حذف الحساب "{ $label }"؟
accounts-delete-with-operations = يحتوي الحساب "{ $label }" على { $count } عملية، وسيتم حذفها معه. هل تؤكد الحذف؟
accounts-delete-form-open = بطاقة الحساب "{ $label }" مفتوحة. أغلقها قبل الحذف.

account-group-bank = معلومات الحساب والبنك
account-group-holder = صاحب الحساب
account-group-rib = البيانات المصرفية (RIB)
account-group-activity = النشاط
account-group-balances = الأرصدة

account-field-label = اسم الحساب
account-field-bank = البنك
account-field-type = نوع الحساب
account-field-branch-address = عنوان الفرع المصرفي
account-field-holder-name = الاسم
account-field-holder-address = العنوان
account-field-rib-bank = المؤسسة
account-field-rib-branch = رمز الفرع
account-field-rib-number = رقم الحساب
account-field-rib-key = مفتاح RIB
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = تاريخ الفتح
account-field-closing-date = تاريخ الإغلاق
account-field-closed = مغلق
account-field-opening-pointed = الرصيد الافتتاحي المطابق
account-field-opening-committed = الرصيد الافتتاحي المحجوز
account-field-opening-planned = الرصيد الافتتاحي المخطط

account-label-required = اسم الحساب إلزامي.
account-iban-invalid = رقم IBAN هذا غير صالح: تحقق من رقم التحقق.
# السطر الأزرق في أسفل البطاقة، حرفيًا كما في 1.9.3 — المبالغ وحدها صارت
# تتبع التنسيق الفرنسي المستعمل في بقية الحقول.
account-control-line = الرصيد الافتتاحي المطابق ({ $opening }) + إجمالي العمليات ({ $operations }) = الرصيد البنكي الحالي: { $balance }.

amount-not-readable = "{ $field }" لا يحتوي على مبلغ صالح.

ui-thousands-separator = ,
ui-decimal-separator = .

# --- قائمة العمليات (F02) --------------------------------------------

window-operations-title = قائمة عمليات الحساب: { $account }

operations-none = لا توجد عمليات في هذه الفترة.
operations-bad-period = حدود الفترة ليست تواريخ صالحة.
operations-from = تاريخ البداية
operations-to = تاريخ النهاية
operations-delete-confirm = { $count ->
    [zero] هل تؤكد حذف الصفوف المحددة؟ العمليات الفرعية للعمليات المحددة تُحذف معها.
    [one] هل تؤكد حذف هذه العملية؟
    [two] هل تؤكد حذف هذين الصفين؟ العمليات الفرعية للعمليات المحددة تُحذف معها.
    [few] هل تؤكد حذف { $count } صفوف؟ العمليات الفرعية للعمليات المحددة تُحذف معها.
    [many] هل تؤكد حذف { $count } صفًا؟ العمليات الفرعية للعمليات المحددة تُحذف معها.
   *[other] هل تؤكد حذف { $count } صف؟ العمليات الفرعية للعمليات المحددة تُحذف معها.
}
operations-deleted = { $count ->
    [zero] لم يتم حذف أي عملية.
    [one] تم حذف عملية واحدة.
    [two] تم حذف عمليتين.
    [few] تم حذف { $count } عمليات.
    [many] تم حذف { $count } عملية.
   *[other] تم حذف { $count } عملية.
}
operations-selection-total = المبلغ الإجمالي للعمليات المحددة: { $amount }

operations-column-date = التاريخ
operations-column-clearing-date = تاريخ المطابقة
operations-column-label = الوصف
operations-column-category = الفئة
operations-column-assignment = التخصيص
operations-column-payment-mode = الطريقة
operations-column-payee = الطرف المقابل
operations-column-project = المشاريع
operations-column-month = الشهر
operations-column-debit = مدين
operations-column-credit = دائن
operations-column-balance = الرصيد
operations-column-comments = ملاحظات
operations-column-attachments = المرفقات
operations-column-check = رقم الشيك

operations-foot-debit = مدين:
operations-foot-credit = دائن:
operations-foot-total = الإجمالي:
operations-foot-bank = الرصيد البنكي:
operations-foot-real = الرصيد الفعلي:
operations-foot-final = الرصيد النهائي:

operations-menu-export = تصدير
operations-menu-print = طباعة
operations-menu-filter = تصفية
operations-menu-period = الفترة
operations-menu-misc = متفرقات

operations-title-point = مطابقة التحديد
operations-title-sub = إضافة عملية فرعية
operations-title-duplicate = نسخ التحديد
operations-not-yet = هذه الشاشة غير موجودة بعد: ستأتي لاحقًا في الخطة.

accounts-choose-question = على أي حساب تريد العمل؟
ui-title-select = اختيار التحديد

month-january = يناير
month-february = فبراير
month-march = مارس
month-april = أبريل
month-may = مايو
month-june = يونيو
month-july = يوليو
month-august = أغسطس
month-september = سبتمبر
month-october = أكتوبر
month-november = نوفمبر
month-december = ديسمبر

operations-period-year = السنة الحالية

# --- قائمة الفترة في F02 ---------------------------------------------
# تسعة مدخلات، منها اثنان يفتحان قائمة فرعية بالأشهر الاثني عشر. كل مدخل
# يقوم بشيء واحد: استنتاج تاريخ بداية وتاريخ نهاية، تعيدهما النافذة إلى
# حقليها (طلب Fabrice، 25/07/2026).

period-all = الكل
period-last-year = السنة الماضية
period-this-year = السنة الحالية
period-whole-year = السنة كاملة
period-last-month = الشهر الماضي
period-this-month = الشهر الحالي
period-last-week = الأسبوع الماضي
period-this-week = الأسبوع الحالي
period-yesterday = أمس
period-today = اليوم

# --- قائمة التصفية في F02 ----------------------------------------------
# تصفية الصفوف حسب نوع العملية (طلب من Fabrice، 25/07/2026). الحالات الثلاث
# هي حالات قاعدة البيانات: 1 مطابق، 2 محجوز، 3 مخطط
# (02_BASE_DE_DONNEES.md §5.2).

filter-all = جميع العمليات
filter-pointed = العمليات المطابقة فقط
filter-committed = العمليات المحجوزة فقط
filter-planned = العمليات المخططة فقط

# --- بطاقة العملية (F03) -------------------------------------------
# العناوين هي عناوين لقطة الشاشة "Fiche operation transaction.png"، مع تصحيح
# الأخطاء المطبعية الواردة في الأصل (بإذن من Fabrice، 25/07/2026: "الأخطاء
# المطبعية تصححها"): "Libelle" تصبح "Libellé"، "Categorie" تصبح "Catégorie"،
# "Statut Operation" تصبح "Statut opération".

window-operation-title = عملية الحساب: { $account }

operation-menu-identification = التعريف
operation-menu-options = خيارات
operation-fitid-edit = تعديل معرف FITID…
operation-fitid-delete = حذف معرف FITID
operation-fitid-question = معرف FITID لهذه العملية:
operation-fitid-delete-question = هل تريد حذف معرف FITID لهذه العملية؟
operation-fitid-written = تم حفظ معرف FITID.
operation-fitid-removed = تم حذف معرف FITID.

operation-group-identification = تعريف العملية
operation-group-amount = مبلغ العملية
operation-group-status = حالة العملية
operation-group-classification = تصنيف العملية لحساب الإحصائيات
operation-group-check = الشيك المرتبط بالعملية
operation-group-comment = تعليق

operation-field-label = الوصف
operation-field-reference = مرجع الدفع
operation-field-date = التاريخ
operation-field-direction = نوع العملية:
operation-field-amount = المبلغ
operation-field-status = حالة العملية
operation-field-clearing-date = تاريخ المطابقة
operation-field-category = الفئة
operation-field-assignment = التخصيص
operation-field-payment-mode = الطريقة
operation-field-payee = الطرف المقابل
operation-field-project = المشروع
operation-field-check = ربط بشيك

operation-direction-debit = مدين
operation-direction-credit = دائن

operation-check-info = معلومات.
operation-check-link = ربط
operation-check-unlink = حذف

operation-fresh = عملية جديدة.
operation-created = تمت إضافة العملية.
operation-updated = تم تعديل العملية.
operation-gone = هذه العملية لم تعد موجودة.
operation-nothing-to-show = لا توجد عملية للعرض.
operation-label-required = وصف العملية إلزامي.
operation-date-required = تاريخ العملية إلزامي.
operation-clearing-date-invalid = تاريخ المطابقة ليس تاريخًا صالحًا.
operation-is-a-sub = هذا الصف عملية فرعية: يتم تعديله من بطاقته الخاصة.
operation-delete-form-open = بطاقة "{ $label }" مفتوحة. يجب إغلاقها قبل الحذف.

operation-attachments = { $count ->
    [0] لا توجد مرفقات
    [one] مرفق واحد
    [two] مرفقان
    [few] { $count } مرفقات
    [many] { $count } مرفقًا
   *[other] { $count } مرفق
}

operation-title-comment = تعليق العملية
operation-title-sub = إنشاء عملية فرعية
operation-title-template = قوالب العمليات
operation-title-attachment = المرفقات

# --- بطاقة العملية الفرعية (F04) --------------------------------------
# نسخة مختصرة من F03: لا طريقة دفع، ولا حالة، ولا تاريخ — العملية الفرعية
# ترثها من العملية الأم (`Maj_ProprieteSousOp`، أكده Fabrice في 26/07/2026:
# "في العملية الفرعية، بما أنها المكمل، لا يمكن المساس بطريقة الدفع، فذلك
# سيكون غير منطقي").

window-sub-operation-title = بطاقة العملية الفرعية

sub-operation-group-amount = مبلغ العملية الفرعية
sub-operation-field-label = الاسم
sub-operation-fresh = عملية فرعية جديدة.
sub-operation-created = تمت إضافة العملية الفرعية.
sub-operation-updated = تم تعديل العملية الفرعية.
sub-operation-gone = هذه العملية الفرعية لم تعد موجودة.
sub-operation-nothing-to-show = لا توجد عملية فرعية للعرض.
sub-operation-label-required = اسم العملية الفرعية إلزامي.
sub-operation-parent-gone = العملية المراد توزيعها لم تعد موجودة.
# ما تقوله البطاقة عندما تعرض المكمل. وهو غير محمي: يمكن تعديله، لكن يجب
# معرفة ما يترتب على ذلك (قرار من Fabrice، 26/07/2026).
sub-operation-is-the-complement = هذا هو المكمل: ما تبقى لتوزيعه. تغيير اسمه أو تغيير مبلغه يجعله عملية فرعية عادية.
sub-operation-of = توزيع "{ $label }" ({ $amount })

operations-pointed = { $count ->
    [zero] لم تتم مطابقة أي عملية.
    [one] تمت مطابقة عملية واحدة.
    [two] تمت مطابقة عمليتين.
    [few] تمت مطابقة { $count } عمليات.
    [many] تمت مطابقة { $count } عملية.
   *[other] تمت مطابقة { $count } عملية.
}
operations-select-one = يرجى اختيار عملية واحدة فقط.

# --- النسخ وعرض العمليات الفرعية (F02) ---------------
# النسخ يفتح بطاقة معبأة مسبقًا يؤكدها المستخدم بنفسه (قرار من Fabrice،
# 26/07/2026): لا يُكتب شيء ما دام لم يحفظ، ويمكنه تصحيح التاريخ أو المبلغ
# قبل ذلك.

operation-copy = نسخة بانتظار الحفظ: لم يتم إنشاء أي شيء بعد.
operations-show-children = إظهار جميع العمليات الفرعية
operations-hide-children = إخفاء جميع العمليات الفرعية

# --- تأكيد ثانٍ لحذف خطير ---------------------
# حذف حساب مصرفي يحذف معه كل سجله: زر نعم/لا يُنقر دون قراءة، لذلك نطلب كتابة
# الكلمة (قرار من Fabrice، 26/07/2026). الكلمة هي كلمة القاموس — "نعم" هنا،
# "Yes" بالإنجليزية — فلا شيء يُترجم هنا مرتين.

accounts-delete-second-question = هذا الحذف نهائي ويحذف معه كل سجل الحساب. اكتب "{ $word }" لتأكيده.

# --- F20-F24 — الإحصائيات الست -----------------------------------
# قالب مشترك، موزع على ستة محاور. تلك التي حسب الفئات كانت النموذج وقد أقرها
# Fabrice في 26/07/2026 قبل أن توجد الخمس الأخرى — أسماء الأعمدة هي أسماء
# الأصل.

window-statistics-title = { $kind ->
    [assignment] إحصائيات حسب التخصيص
    [budget-line] إحصائيات حسب بند الميزانية
    [payment-mode] إحصائيات حسب طريقة الدفع
    [payee] إحصائيات حسب الطرف المقابل والتاجر
    [project] إحصائيات حسب المشروع
   *[category] إحصائيات حسب الفئة
}

statistics-axis-column = { $kind ->
    [assignment] التخصيص
    [budget-line] بند الميزانية
    [payment-mode] طريقة الدفع
    [payee] الطرف المقابل
    [project] المشاريع
   *[category] اسم الفئة
}

statistics-unclassified = { $kind ->
    [assignment] بدون تخصيص
    [budget-line] بدون بند ميزانية
    [payment-mode] بدون طريقة دفع
    [payee] بدون طرف مقابل
    [project] بدون مشروع
   *[category] بدون فئة
}
statistics-total = الإجمالي
statistics-sum = المجموع
statistics-cumulative = التراكمي

# المفاتيح الخمسة في الشريط. الوصف يتبدل بين ON وOFF، كما في الأصل: المفتاح
# نفسه هو الذي يقول أين هو.
statistics-switch-pointed = العمليات المطابقة { $state }
statistics-switch-committed = العمليات المحجوزة { $state }
statistics-switch-planned = العمليات المخططة { $state }
statistics-switch-debits = مبالغ المدين { $state }
statistics-switch-credits = مبالغ الدائن { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = لم يتم اختيار أي حساب: الإحصائية لا تشمل شيئًا.
statistics-no-data = لا توجد عملية في هذه السنة للحسابات المختارة.
statistics-detail-empty = انقر على خانة رقمية لعرض العمليات التي تعدها.
statistics-detail-none = لا توجد عملية خلف هذه الخانة.
statistics-accounts = { $count ->
    [zero] لا يوجد حساب
    [one] حساب واحد
    [two] حسابان
    [few] { $count } حسابات
    [many] { $count } حسابًا
   *[other] { $count } حساب
}
statistics-year-next = السنة التالية
statistics-year-previous = السنة السابقة

statistics-column-date = التاريخ
statistics-column-clearing-date = تاريخ المطابقة
statistics-column-label = الوصف
statistics-column-amount = المبلغ
statistics-column-comments = التعليقات

accounts-stats-multiselect-help = معلومة: استخدم نقر الفأرة + مفتاح [{ $modifier }] على الجدول لاختيار عدة حسابات

# سنة الإحصائيات: ينقر عليها وتُكتب سنة. الحدود هي حدود "الكل" في قائمة
# الفترة — سنة Radinus عدد صحيح بين 1950 و2550 (Fabrice، 26/07/2026).
statistics-year-question = على أي سنة تريد العمل؟ Radinus يمتد من { $first } إلى { $last }.
statistics-year-choose = اختيار السنة

# --- تصدير الجداول (النقر الأيمن) ---------------------------------
# وظيفة تخص الجدول، لا النافذة: كل القوائم تملكها.

export-to-excel = تصدير إلى Excel (.xlsx)
export-to-word = تصدير إلى Word (.docx)
export-to-tsv = تصدير إلى TSV (.tsv)
export-to-ini = تصدير إلى INI (.ini)
export-to-toml = تصدير إلى TOML (.toml)
export-to-yaml = تصدير إلى YAML (.yaml)
export-to-ofx = تصدير إلى OFX (.ofx)
export-to-qif = تصدير إلى QIF (.qif)
export-to-ods = تصدير إلى LibreOffice Calc (.ods)
export-to-csv = تصدير إلى CSV (.csv)
export-to-xml = تصدير إلى XML (.xml)
# قائمة التصدير في نافذة الإحصائيات: علامة تبويب لكل سنة، باسم AN_2026.
# السنوات الفارغة — بحسب المفاتيح الموضوعة — ليست فيها.
export-menu = تصدير
export-all-years-excel = تصدير جميع السنوات إلى Excel
export-all-years-ods = تصدير جميع السنوات إلى LibreOffice Calc
export-no-year = لا توجد سنة تحمل عمليات: لا شيء للتصدير.
export-years-done = تم تصدير { $years } سنوات إلى "{ $file }".
export-to-json = تصدير إلى JSON (.json)
export-done = تم التصدير إلى "{ $file }".
export-failed = التصدير غير ممكن: { $reason }
export-nothing = لا يوجد شيء للتصدير.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] إحصائيات حسب التخصيص
    [budget-line] إحصائيات حسب بند الميزانية
    [payment-mode] إحصائيات حسب طريقة الدفع
    [payee] إحصائيات حسب الطرف المقابل والتاجر
    [project] إحصائيات حسب المشروع
   *[category] إحصائيات حسب الفئة
}
statistics-detail-name = تفاصيل الإحصائيات

# --- F19 — لوحة المعلومات --------------------------------------------
# فترة وثلاثة مفاتيح؛ حلقتان لكل بند ميزانية؛ ثلاثة أرقام كبيرة.
# ألوان القطاعات هي ألوان الأصل، المأخوذة من لقطة شاشة Fabrice.

window-dashboard-title = لوحة المعلومات
dashboard-menu-period = الفترة
dashboard-menu-misc = متنوعات
dashboard-from = تاريخ البداية:
dashboard-to = تاريخ النهاية:
dashboard-switch-pointed = تضمين العمليات المطابقة
dashboard-switch-committed = تضمين العمليات المحجوزة
dashboard-switch-planned = تضمين العمليات المخططة
dashboard-spending = النفقات
dashboard-earning = الإيرادات
dashboard-debits = مجموع العمليات المدينة
dashboard-credits = مجموع العمليات الدائنة
dashboard-balance = الحصيلة
dashboard-unclassified = بدون بند ميزانية
dashboard-nothing = لا توجد عمليات في هذه الفترة.
dashboard-no-account = لم يتم اختيار أي حساب: لوحة المعلومات لا تستند إلى شيء.
dashboard-enlarge = فتح بحجم كبير

# --- F25 — تطور الرصيد ------------------------------------------
# رسم بياني لكل حساب مختار، إضافة إلى رسم المجموع — الذي لا يوجد إلا
# ابتداء من حسابين (قاعدة Fabrice، 26/07/2026). الرسوم على شكل
# درجات: يحتفظ الرصيد بقيمته حتى العملية التالية.

window-curve-title = تطور الرصيد
curve-heading = تطور الرصيد يوميا
curve-menu-period = الفترة
curve-total = المجموع
curve-from = تاريخ البداية:
curve-to = تاريخ النهاية:
curve-axis-balance = رصيد
curve-nothing = لم يتم اختيار أي حساب: لا يوجد رسم بياني لرسمه.
curve-empty = لا توجد عمليات في هذه الفترة.

# --- F05 — التصنيف السريع للعمليات ------------------------
# النافذة التي يتم فيها التصنيف **بالجملة**: يتم تحديد صفوف، والإشارة
# إلى الخصائص المراد تغييرها، ثم تطبيقها دفعة واحدة — في الذاكرة.
# لا يكتب شيء ما لم يتم الحفظ، والحفظ لا يكتب إلا ما يختلف عما تمت
# قراءته (قواعد Fabrice، 27/07/2026).

window-quick-classification-title = التصنيف السريع للعمليات: { $account }
quick-dates-title = تاريخا بداية ونهاية القائمة.
quick-from = تاريخ البداية
quick-to = تاريخ النهاية
quick-menu-period = الفترة
quick-change-title = تغيير خصائص التحديد إلى:
quick-check-category = الفئة
quick-check-assignment = التخصيص
quick-check-payment-mode = الطريقة
quick-check-payee = الطرف المقابل
quick-check-project = المشروع
quick-check-status = الحالة
quick-column-date = التاريخ
quick-column-label = الوصف
quick-column-amount = المبلغ
quick-column-category = الفئة
quick-column-assignment = التخصيص
quick-column-payment-mode = طريقة الدفع
quick-column-payee = الطرف المقابل
quick-column-project = المشاريع
quick-column-status = الحالة
# على جهاز Mac، مفتاح Ctrl + النقر هو نقر أيمن: المفتاح الذي يضيف إلى
# التحديد هناك هو ⌘، وعلى المساعدة أن تذكر المفتاح الذي يعمل فعلا.
quick-multiselect-help = معلومة: استخدم نقرة الفأرة + مفتاح [{ $modifier }] على الجدول لتحديد عدة عناصر
quick-none = لا توجد عمليات في هذه الفترة.
quick-select-lines = حدد صفا واحدا على الأقل، وأشر إلى خاصية واحدة على الأقل.
quick-applied = { $count ->
    [0] لم يتغير شيء: هذه الصفوف تحمل هذا التصنيف من قبل.
    [one] تم تصنيف صف واحد. لم يتم حفظ أي شيء بعد.
    [two] تم تصنيف صفين. لم يتم حفظ أي شيء بعد.
    [few] تم تصنيف { $count } صفوف. لم يتم حفظ أي شيء بعد.
    [many] تم تصنيف { $count } صفا. لم يتم حفظ أي شيء بعد.
   *[other] تم تصنيف { $count } صف. لم يتم حفظ أي شيء بعد.
}
quick-pending = { $count ->
    [0] لا توجد تعديلات في الانتظار.
    [one] تم تعديل صف واحد، غير محفوظ.
    [two] تم تعديل صفين، غير محفوظين.
    [few] تم تعديل { $count } صفوف، غير محفوظة.
    [many] تم تعديل { $count } صفا، غير محفوظة.
   *[other] تم تعديل { $count } صف، غير محفوظة.
}
quick-save-question = { $count ->
    [zero] حفظ التعديلات في الانتظار؟
    [one] حفظ التعديل في الانتظار؟
    [two] حفظ التعديلين في الانتظار؟
    [few] حفظ { $count } تعديلات في الانتظار؟
    [many] حفظ { $count } تعديلا في الانتظار؟
   *[other] حفظ { $count } تعديل في الانتظار؟
}
quick-saved = { $count ->
    [0] لم يكن هناك ما يستوجب الحفظ.
    [one] تم حفظ صف واحد.
    [two] تم حفظ صفين.
    [few] تم حفظ { $count } صفوف.
    [many] تم حفظ { $count } صفا.
   *[other] تم حفظ { $count } صف.
}
quick-nothing-to-save = لا توجد تعديلات في الانتظار.
quick-leave-question = هناك تعديلات غير محفوظة. ماذا تريد أن تفعل؟
quick-leave-save = حفظ وخروج
quick-leave-discard = تجاهل وخروج
quick-leave-stay = البقاء
quick-title-apply = تطبيق على الصفوف المحددة ( في الذاكرة )
quick-title-save = الحفظ على القرص

# --- F17 / F18 — استيراد كشف حساب بنكي ----------------------
# يتم اختيار حساب، وفتح ملف OFX — الذي يبقى في الذاكرة —، فتظهر
# الصفوف التي تعرفها قاعدة البيانات من قبل بألوان باهتة، والأيقونة
# الثالثة تدمجها: بالجملة إذا تم اختيار عدة صفوف، وصفا صفا عبر بطاقة
# المطابقة في غير ذلك (طريقة عمل Fabrice، 27/07/2026).

window-statement-import-title = استيراد كشوف الحسابات البنكية: { $account }
window-statement-form-title = مطابقة عملية (تدمج عملية في سجل حسابك)
statement-menu-filter = تصفية
statement-filter-all = كل الصفوف
statement-filter-pending = للدمج
statement-filter-known = مدمجة من قبل
statement-column-id = ID
statement-column-reconciled = مطابق
statement-column-fitid = FITID
statement-column-date = التاريخ
statement-column-label = الوصف
statement-column-debit = مدين
statement-column-credit = دائن
statement-account = الحساب
statement-file = الملف
statement-difference = الفارق
statement-none = لم يتم فتح أي كشف حساب: انقر على المجلد الأصفر لاختيار ملف.
statement-empty = لا يحتوي كشف الحساب هذا على أي عملية.
statement-no-match = لا يوجد صف يطابق التصفية.
statement-help = معلومة: استخدم نقرة الفأرة + مفتاح [{ $modifier }] على الجدول لتحديد عدة صفوف
statement-choose-account = يحتوي هذا الملف على عدة حسابات. أيها تريد استيراده؟
statement-select-line = حدد صفا واحدا على الأقل من كشف الحساب.
statement-title-open = فتح ملف كشف حساب (.ofx)
statement-title-info = معلومات عن الملف المفتوح
statement-title-integrate = دمج التحديد في الحساب
statement-title-validate = دمج هذه العملية في الحساب
statement-duplicate = انتبه، تكرار: يبدو أن هذه العملية قد تم دمجها في قاعدة البيانات من قبل (Financial Institution Transaction ID موجود)
statement-no-fitid = انتبه: لا يعطي هذا الملف أي معرف (FITID) لهذا الصف. لن يمكن كشف أي تكرار.
statement-loaded = { $count ->
    [0] لا يحتوي هذا الملف على أي عملية لهذا الحساب.
    [one] تمت قراءة صف واحد. عدد الصفوف الموجودة في حسابك من قبل: { $known }.
    [two] تمت قراءة صفين. عدد الصفوف الموجودة في حسابك من قبل: { $known }.
    [few] تمت قراءة { $count } صفوف. عدد الصفوف الموجودة في حسابك من قبل: { $known }.
    [many] تمت قراءة { $count } صفا. عدد الصفوف الموجودة في حسابك من قبل: { $known }.
   *[other] تمت قراءة { $count } صف. عدد الصفوف الموجودة في حسابك من قبل: { $known }.
}
statement-integrated = { $count ->
    [0] لم يدخل شيء: هذه الصفوف موجودة في حسابك من قبل.
    [one] تم دمج عملية واحدة.
    [two] تم دمج عمليتين.
    [few] تم دمج { $count } عمليات.
    [many] تم دمج { $count } عملية.
   *[other] تم دمج { $count } عملية.
}
# **رسائل الأصل، كلمة بكلمة** (تعليمات Fabrice،
# 28/07/2026: البقاء وفيا للكود الأصلي). رسالته تحذر قبل الدفعة،
# وتسأل صفا صفا أمام التكرار، وتقدم حصيلتها في النهاية.

statement-mass-question =
    هل أنت متأكد من رغبتك في دمج عدة عمليات في حسابك في آن واحد؟
    سيتعين عليك تصنيفها وتحديد خصائصها لاحقا للحصول على إحصائيات دقيقة
    في حالة ملفات Ofx: إذا تم كشف تكرارات فسيتعين عليك اختيار سلوك البرنامج
    بالنسبة لأنواع الملفات الأخرى: سيتعين عليك الانتباه إلى التكرارات
statement-duplicate-question =
    العملية: { $date } { $label }: { $amount }
    يبدو أنها قد تم دمجها من قبل في سجل عمليات حسابك البنكي.
    هل تريد فعلا القيام بالمطابقة؟
statement-already-reconciled = لقد قمت بمطابقة هذه العملية من قبل: هي مدمجة من قبل في سجل عمليات حسابك
statement-integration-report =
    انتهاء الدمج.
    عدد السجلات المدمجة: { $added }
    عدد السجلات المتجاهلة: { $ignored }
statement-integration-abandoned =
    التخلي عن الدمج!
    عدد السجلات المدمجة: { $added }
    عدد السجلات المتجاهلة: { $ignored }
statement-yes = نعم
statement-no = لا
statement-cancel = إلغاء
statement-file-info =
    حساب الملف: { $account }
    الفترة: من { $from } إلى { $to }
    الرصيد المعلن من البنك: { $balance }
    { $count } عملية، منها { $known } موجودة في حسابك من قبل.
statement-group-identification = تعريف العملية
statement-group-amount = مبلغ العملية
statement-group-classification = تصنيف العملية لحساب الإحصائيات
statement-group-status = حالة العملية
statement-field-date = التاريخ
statement-field-label = الوصف
statement-field-type = نوع العملية
statement-field-amount = المبلغ
statement-field-mode = طريقة العملية
statement-field-category = الفئة
statement-field-assignment = التخصيص
statement-field-payee = الطرف المقابل
statement-field-project = المشروع
statement-field-status = الحالة
statement-field-clearing = تاريخ المطابقة

# --- نافذة تقطيع كشف حساب بصيغة CSV ---------------------------
# لا يحمل ملف CSV أي اسم حقل موثوق: نضبط، ونختبر، وننظر، ثم نعيد
# الكرة. المعاينة تعرض كل شيء، بما في ذلك الطلاسم — هكذا نرى أننا
# أخطأنا — لكن الصفوف الصحيحة وحدها تنتقل إلى نافذة الدمج
# (قاعدة Fabrice، 27/07/2026).

window-csv-statement-title = استيراد بيانات من ملف csv
csv-preview-title = معاينة الملف:
csv-settings-title = معايير تقطيع الملف بهدف استخراج البيانات:
csv-extraction-title = عرض استخراج البيانات حسب معايير التقطيع  ( تحقق من اتساق البيانات ):
csv-column-line = رقم الصف
csv-column-content = المحتوى
csv-header-lines = عدد صفوف ترويسة الملف التي يجب تجاهلها
csv-separator = البيانات (الأعمدة) مفصولة بالحرف:
csv-date-at = موضع حقل التاريخ
csv-label-at = موضع حقل الوصف
csv-debit-at = موضع حقل المبلغ المدين
csv-credit-at = موضع حقل المبلغ الدائن
csv-test = اختبار المعايير
csv-separator-semicolon = فاصلة منقوطة   ;
csv-separator-comma = فاصلة   ,
csv-separator-tab = مسافة جدولة
csv-separator-pipe = شرطة عمودية   |
csv-separator-space = مسافة
csv-help = اضبط واختبر وانظر: لن تستورد إلا الصفوف التي تحمل تاريخا ومبلغا مقروءين.
csv-none = الملف فارغ.
csv-not-tested = انقر على "اختبار المعايير" لرؤية ما يعطيه التقطيع.
csv-extraction = { $count ->
    [0] لا ينتج التقطيع أي صف: تحقق من عدد صفوف الترويسة ومن الفاصل.
    [one] تم تقطيع صف واحد: سيتم استيراد { $valid }، واستبعاد { $dropped } لغياب تاريخ أو مبلغ مقروء.
    [two] تم تقطيع صفين: سيتم استيراد { $valid }، واستبعاد { $dropped } لغياب تاريخ أو مبلغ مقروء.
    [few] تم تقطيع { $count } صفوف: سيتم استيراد { $valid }، واستبعاد { $dropped } لغياب تاريخ أو مبلغ مقروء.
    [many] تم تقطيع { $count } صفا: سيتم استيراد { $valid }، واستبعاد { $dropped } لغياب تاريخ أو مبلغ مقروء.
   *[other] تم تقطيع { $count } صف: سيتم استيراد { $valid }، واستبعاد { $dropped } لغياب تاريخ أو مبلغ مقروء.
}
csv-nothing-valid = لا يحمل أي صف تاريخا ومبلغا مقروءين معا: لا يوجد ما يستورد. تحقق من عدد صفوف الترويسة ومن الفاصل ومن مواضع الحقول.
csv-title-validate = نقل الصفوف الصحيحة إلى الاستيراد

# --- F13 / F31 / F14 / F12 — دفاتر الشيكات والشيكات (المرحلة 9) -------------
# نقل أكواد WinDev الخمسة ولقطات الشاشة السبع التي قدمها في
# 28/07/2026. عباراته الحرفية حيثما وُجدت، وعباراتي في ما عدا ذلك.
#
# ثلاثة أوجه من الوفاء حسمها في ذلك اليوم وتُسمع في
# الألفاظ: المرجع المكرر لا يُعلن عنه (دالته `Existe_Reference`
# لا تُستدعى أبدًا)، وعدد الشيكات لا يُقارن بالحدود،
# وعدّاد العمليات يحسب العمليات الفرعية التي ترفضها القوائم.

window-chequebooks-title = قائمة دفاتر الشيكات
window-chequebook-title = إعدادات دفتر الشيكات
window-cheques-title = محتوى دفتر الشيكات: قائمة الشيكات.
window-cheque-title = بطاقة الشيك
window-cheque-operations-title = قائمة العمليات.

# قائمة دفاتر الشيكات (F13) — كل الدفاتر، من جميع الحسابات معًا:
# عمودا الحساب لديه لا فائدة منهما لو كان الأمر يخص حسابًا واحدًا.
chequebooks-column-reference = الوصف
chequebooks-column-date = التاريخ
chequebooks-column-account = اسم الحساب
chequebooks-column-account-number = رقم الحساب
chequebooks-column-comments = ملاحظات
chequebooks-none = لا يوجد أي دفتر شيكات مسجل.
chequebooks-nothing-to-show = لا يوجد أي دفتر شيكات يطابق هذا البحث.
chequebooks-title-composition = عرض محتوى دفتر الشيكات
chequebooks-delete-question = تم اكتشاف عمليات (عمليات مصرفية) مرتبطة بدفتر الشيكات. هل تؤكد رغبتك في حذف دفتر الشيكات هذا؟
chequebooks-deleted = { $count ->
    [zero] لم يتم حذف أي دفتر شيكات.
    [one] تم حذف دفتر شيكات واحد.
    [two] تم حذف دفترَي شيكات.
    [few] تم حذف { $count } دفاتر شيكات.
    [many] تم حذف { $count } دفتر شيكات.
   *[other] تم حذف { $count } دفتر شيكات.
}
chequebooks-gone = لم يعد دفتر الشيكات هذا موجودًا.
chequebooks-created = تم حفظ دفتر الشيكات مع جميع شيكاته.
chequebooks-updated = تم تعديل دفتر الشيكات.
# صمت دالته `HAjoute`: الشاشة لا تقول إن المرجع مستعمل.
# تقول فقط إنه لم يُحفظ شيء — ولولا ذلك لظُن أن الدفتر
# قد أُنشئ.
# الاحتياطات الثمانية من ملفه "Precauttion enregistrement cheque.txt"، كلمة
# بكلمة وبترتيبه. السبعة الأولى رسائل `Erreur()`، والثامنة
# رسالة `Info()` — والترتيب هو الذي يقرر ما يُرى حين يقع
# خطآن معًا.
chequebook-refusal-duplicate = يوجد بالفعل مرجع بنفس الاسم
chequebook-refusal-reference-required = إدخال المرجع إلزامي
chequebook-refusal-number-too-big = رقم الشيك الأول و/أو الأخير كبير جدًا (القيمة القصوى 999 999 999)
chequebook-refusal-date = يرجى إدخال تاريخ استلام صالح
chequebook-refusal-numbers-required = يرجى إدخال رقمي الشيك الأول والشيك الأخير
chequebook-refusal-order = يجب أن يكون رقم الشيك الأول أصغر من رقم الشيك الأخير
chequebook-refusal-account = يجب اختيار الحساب المصرفي المرتبط بدفتر الشيكات هذا
chequebook-refusal-too-many = الحد الأقصى لعدد الشيكات في دفتر واحد: 1000، تم بلوغ الحد
# طلب التأكيد لديه، ولا يُطرح إلا عند الإضافة: يلخص ما
# سيتم إنشاؤه وينبه إلى أن شيئًا منه لن يكون قابلًا للتعديل بعد ذلك.
chequebook-creation-question =
    إنشاء دفتر الشيكات بالخصائص التالية:
    - عدد الشيكات المراد إنشاؤها:{ $count }
    - شيكات مرقّمة من { $first } إلى { $last }
    تنبيه: لن تكون هذه البيانات قابلة للتعديل بعد الإنشاء!

# بطاقة دفتر الشيكات (F31). الحقول الخمسة الأولى تصبح غير نشطة بمجرد
# وجود الدفتر: شيكاته موجودة بالفعل.
chequebook-field-id = معرّف دفتر الشيكات
chequebook-field-reference = المرجع
chequebook-field-received = تاريخ الإصدار أو الاستلام
chequebook-field-first = رقم الشيك الأول
chequebook-field-last = رقم الشيك الأخير
chequebook-field-quantity = عدد الشيكات
chequebook-field-account = الربط بالحساب المصرفي:
chequebook-field-comments = ملاحظات
chequebook-locked = شيكات هذا الدفتر منشأة بالفعل: لم يعد ترقيمه قابلًا للتعديل.
# عبارته كلمة بكلمة (`Enreg_Lire`).
chequebook-account-missing = الحساب المصرفي المرتبط بدفتر الشيكات هذا غير موجود أو تم حذفه!

# محتوى دفتر الشيكات (F14). تُغيَّر الحالة داخل الخانة.
cheques-column-number = رقم الشيك
cheques-column-date = التاريخ
cheques-column-place = المكان
cheques-column-payee = المستفيد
cheques-column-amount = المبلغ
cheques-column-status = الحالة
cheques-column-comments = ملاحظات
cheques-column-operations = عدد العمليات المرتبطة
cheques-none = لا يحتوي دفتر الشيكات هذا على أي شيك.
cheques-nothing-to-show = لا يوجد أي شيك يطابق هذا البحث.
cheques-help = انقر في خانة الحالة لتغييرها؛ العدسة تعرض العمليات المرتبطة، وحلقة الوصل تربط عملية.
cheques-title-linked = عرض العمليات المرتبطة بالفعل بهذا الشيك
cheques-title-link = ربط عملية بهذا الشيك
cheques-status-changed = تم تعديل حالة الشيك.

# بطاقة الشيك (F12).
cheque-field-id = معرّف الشيك
cheque-field-number = رقم الشيك
cheque-field-issued = تاريخ الإصدار
cheque-field-place = مكان الإصدار
cheque-field-payee = المستفيد
cheque-field-amount = المبلغ
cheque-field-comments = ملاحظات
cheque-field-status = حالة الشيك
cheque-gone = لم يعد هذا الشيك موجودًا.
cheque-updated = تم تعديل الشيك.

# وجها شاشة الربط.
cheque-operations-linked-title = قائمة العمليات المرتبطة بالفعل بهذا الشيك.
cheque-operations-choose-title = اختر عملية لربطها بالشيك
cheque-operations-column-account = الحساب
cheque-operations-column-label = الوصف
cheque-operations-column-date = التاريخ
cheque-operations-column-clearing = تاريخ المطابقة
cheque-operations-column-amount = المبلغ
cheque-operations-column-cheque = الشيك المرتبط
cheque-operations-none-linked = لا توجد أي عملية مرتبطة بهذا الشيك.
cheque-operations-none = لا يحتوي هذا الحساب على أي عملية.
cheque-operations-nothing-to-show = لا توجد أي عملية تطابق هذا البحث.
cheque-operations-help = العمليات المكتوبة بخط عريض مرتبطة بشيك بالفعل.
cheque-operations-linked-help = العلامة الحمراء تفصل الشيك عن العملية: لا يُحذف أي شيء.
cheque-operations-linked = تم ربط العملية بالشيك.
cheque-operations-dissociated = تم فصل الشيك عن العملية.
cheque-operations-menu-filter = تصفية
cheque-title-associate = ربط هذه العملية بالشيك
cheque-title-dissociate = فصل الشيك عن هذه العملية

# شريط "الشيك المرتبط بالعملية" في بطاقة العملية، و
# مرحلتا البحث عن الشيك — الدفتر، ثم الشيك.
chequebooks-select-question = اختر دفتر الشيكات
cheques-select-question = اختر الشيك المراد ربطه بالعملية
operation-check-save-first = احفظ العملية أولًا: الشيك يُربط بعملية موجودة.
operation-check-none = لا يرتبط بهذه العملية أي شيك.

# --- F36 / F37 — قوالب العمليات (المرحلة 10) ---------------------
# القالب إدخال جاهز: يُطبَّق لتفادي إعادة الكتابة، وهو
# **يستبدل** ما في البطاقة. ولا يُكتب شيء على القرص ما لم
# تُؤكَّد بطاقة العملية (قاعدة Fabrice، 29/07/2026).

window-operation-templates-title = قائمة قوالب العمليات
window-operation-template-title = بطاقة قالب العملية

operation-templates-none = لا يوجد أي قالب عملية مسجل.
operation-templates-nothing-to-show = لا يوجد أي قالب يطابق هذا البحث.
operation-templates-select-question = اختر القالب المراد تطبيقه
operation-templates-delete-question = هل تؤكد حذف القوالب المحددة؟
operation-templates-deleted = { $count ->
    [zero] لم يتم حذف أي قالب.
    [one] تم حذف قالب واحد.
    [two] تم حذف قالبين.
    [few] تم حذف { $count } قوالب.
    [many] تم حذف { $count } قالبًا.
   *[other] تم حذف { $count } قالب.
}
operation-template-gone = لم يعد هذا القالب موجودًا.
operation-template-fresh = قالب جديد.
operation-template-created = تم حفظ القالب.
operation-template-updated = تم تعديل القالب.
operation-template-label-required = إدخال الاسم إلزامي
operation-template-duplicate = يوجد بالفعل قالب بنفس الاسم

# بطاقة F36، قسمًا قسمًا — عناوينه الحرفية.
operation-template-field-id = معرّف قالب العملية
operation-template-group-name = الاسم الافتراضي للعملية التي ستنشأ بعد تطبيق القالب
operation-template-field-label = الاسم
operation-template-group-amount = المبلغ الافتراضي للعملية المحدد مسبقًا في هذا القالب
operation-template-field-direction = نوع العملية
operation-template-field-amount = المبلغ
operation-template-group-status = حالة العملية الافتراضية في هذا القالب
operation-template-field-status = حالة العملية
operation-template-group-classification = بيانات القالب المستعملة في التصنيف وحساب الإحصائيات
operation-template-field-category = الفئة
operation-template-field-assignment = التخصيص
operation-template-field-mode = طريقة الدفع
operation-template-field-payee = الطرف المقابل
operation-template-field-project = المشروع

# زر "قالب" في بطاقة العملية: أيقونة واحدة، إجراءان.
operation-template-question = ماذا تريد أن تفعل بقوالب العمليات؟
operation-template-apply = تطبيق قالب
operation-template-save-as = الحفظ كقالب
operation-template-applied = تم تطبيق القالب. أكّد البطاقة لحفظه.
operation-template-saved-as = تم حفظ العملية كقالب.
operation-template-needs-label = أعطِ العملية اسمًا قبل تحويلها إلى قالب.

# --- F26 / F27 — الميزانية (المرحلة 11) -----------------------------------
# بابان وسؤالان: إما إدخال الميزانية، أو التحقق من الالتزام
# بها. المحور هو بند الميزانية، والوحدة هي السنة، و
# اصطلاح الإشارة هو اصطلاح العمليات — المصروف يُكتب بالسالب.

window-budget-entry-title = إدخال الميزانية: المصروفات(-) والإيرادات(+) المتوقعة خلال سنة
window-budget-control-title = مراقبة الميزانية

budget-column-line = بند الميزانية
budget-none = لا يوجد أي بند ميزانية مسجل: تُدخل الميزانية حسب البند.
budget-planned = المخطط
budget-actual = المحقق
budget-sum = المجموع
budget-cumulative = التراكمي
budget-total = الإجمالي
# تذكير باصطلاح الإشارة، بالأحمر تحت جدول الإدخال.
# عبارته كلمة بكلمة بما في ذلك المسافات (لقطة "POINT 004 saisie
# budget.png"): تظهر بالأحمر تحت الجدول، وعنوان الشاشة
# يعيدها مختصرة. لا أحد كان ليخمن الاصطلاح بدونها.
budget-sign-warning = يجب إدخال المصروفات  بإشارة سالبة والإيرادات المتوقعة بمبالغ موجبة
budget-entry-help = اكتب المبالغ في الخانات، ثم احفظ.
budget-saved = تم حفظ الميزانية.
budget-nothing-changed = لا توجد أي تعديلات للحفظ.
budget-discard-question = هل تريد التخلي عن تعديلات الميزانية؟

# قائمة العرض في شاشة المراقبة: طريقتان لقراءة الفارق نفسه.
budget-menu-display = عرض
budget-display-money = القيم
budget-display-percent = النسب المئوية
budget-control-help = الأخضر: مطابق للمخطط أو أفضل منه. الأحمر: أقل منه.

# --- F09 — تحويل مبلغ بين حسابين (المرحلة 12) ----------
# التحويل ليس عملية واحدة بل عمليتان: مدين في الحساب المصدر،
# ودائن في الحساب الوجهة. تُسجلان معًا أو لا تُسجلان إطلاقًا.

window-transfer-title = تحويل مبلغ بين حسابين

transfer-group-source = خصم المبلغ من هذا الحساب المصدر
transfer-group-target = إضافة المبلغ إلى هذا الحساب الوجهة
transfer-group-description = وصف العملية
transfer-group-nomenclature = معلومات البيانات الأساسية
transfer-group-amount = قيمة المبلغ المراد تحويله
transfer-field-source = الحساب المصدر
transfer-field-target = الحساب الوجهة
transfer-field-label = الوصف
transfer-field-reference = مرجع الدفع
transfer-field-date = التاريخ
transfer-field-status = حالة العملية
transfer-field-clearing = تاريخ المطابقة
transfer-field-category = الفئة
transfer-field-mode = طريقة الدفع
transfer-field-assignment = التخصيص
transfer-field-payee = الطرف المقابل / التجار
transfer-field-project = المشروع
transfer-field-amount = المبلغ

# الزر الوحيد في اللوحات التي تُعلن بدل أن تسأل.
ui-ok = موافق
transfer-help = اختر الحسابين: تظهر أرصدتهما هنا.
transfer-title-validate = تنفيذ التحويل
# الأرصدة الثلاثة للحساب المختار، لمعرفة ما يترتب على التحويل.
transfer-balances = { $account } — الرصيد البنكي: { $bank } · الرصيد الفعلي: { $real } · الرصيد النهائي: { $final }
# اللوحة التي تلخص ما تمت كتابته للتو.
transfer-done = تم تنفيذ التحويل. { $amount } من الحساب { $source } إلى الحساب { $target }، بتاريخ { $date }.

transfer-refusal-accounts-required = اختر الحساب المصدر والحساب الوجهة
transfer-refusal-same-account = لا يمكن أن يكون الحساب المصدر والحساب الوجهة نفس الحساب: التحويل يذهب من حساب إلى آخر
transfer-refusal-account-gone = أحد الحسابين لم يعد موجودًا
transfer-refusal-label-required = الوصف إلزامي
transfer-refusal-date-required = التاريخ إلزامي
transfer-refusal-amount = يجب أن يكون المبلغ المراد تحويله موجبًا تمامًا

# ---------------------------------------------------------------------------
# المرحلة 13 — استيراد ورقة Excel (F34، F35، الربط).
# ---------------------------------------------------------------------------

window-excel-import-title = استيراد ورقة excel [ الخطوة 1/3 ]: تحديد منطقة الالتقاط
window-excel-fields-title = استيراد ورقة excel [ الخطوة 2/3 ]: ربط الحقول
window-excel-association-title = استيراد ورقة excel: ربط البيانات

# السؤال المطروح عند الفتح. ملف Excel مصنوع باليد:
# يحتوي على ما يحتوي عليه، وجزء من الفوضى التي يحملها
# لا يمكن كشفه. لذلك نقترح الشبكة قبل القفز.
excel-backup-question = ورقة Excel مصنوعة باليد: قد تحتوي على تواريخ صحيحة الشكل لكنها خاطئة، ومبالغ بالتنسيق الصحيح وبالإشارة الخاطئة — وهذا لا يمكن لأي فحص أن يراه. سيكتب الاستيراد هذه الصفوف في حسابك. هل تريد حفظ نسخة احتياطية من بياناتك قبل البدء؟
excel-backup-later = النسخة الاحتياطية غير موصولة بعد في هذه النسخة من Radinus 2. في انتظار ذلك، أغلق Radinus وانسخ بنفسك ملف قاعدة البيانات: عندئذ يمكنك الاستيراد دون أي مخاطرة.

excel-group-file = 1 - تحديد ملف Excel المراد استيراده
excel-pick = تحديد ملف Excel
excel-sheet = ورقة المصنف:
excel-group-header = 2 - تحديد: إحداثيات الخلايا لصف عنوان الجدول حيث تُكتب أسماء الأعمدة.
excel-header-row = رقم أول صف توجد فيه أسماء الأعمدة
excel-first-column = عمود بداية العنوان ( العمود الأقصى إلى اليسار ):
excel-column-count = عدد أعمدة الجدول
excel-group-rows = 3 - تحديد: رقم صف البداية وصف النهاية للقائمة التي تحتوي على بيانات الجدول ( أسفل العنوان ودون تضمينه )
excel-first-data-row = أول صف يحتوي على بيانات
excel-last-data-row = آخر صف يحتوي على بيانات:
excel-group-shape = 4 - تحديد: كيف يكتب ملفك المبالغ
excel-shape-single = عمود واحد فقط للمبالغ، بإشارة ( المصروفات بالسالب )
excel-shape-debit-credit = عمودان منفصلان: عمود مدين وعمود دائن
excel-shape-note = في وضع العمودين، لا تؤخذ الإشارة المكتوبة في عمود المدين بعين الاعتبار: المدين يُخرج المال دائمًا، سواء كُتب "-50" أو "50".
excel-group-test = 5 - عرض تجريبي: اعرض الالتقاط المنفذ وفق إعداداتك
excel-test = اختبر الإعدادات التي حددتها في الخطوات 2 و3 و4.
excel-test-note = إشارة: يجب أن تطابق أسماء العناوين ومحتوى الجدول أدناه تلك الموجودة في جدول Excel الخاص بك. يجب ألا تتجاوز منطقة الالتقاط حدود منطقة الجدول.

excel-help = انزل عبر المجموعات الخمس بالترتيب، ثم اختبر: لن تتمكن من الانتقال إلى الخطوة 2 إلا بعد أن ترى ما تلتقطه المنطقة.
excel-no-file = حدد أولًا ملف Excel المراد استيراده.
excel-not-tested = تم تعديل الإعدادات: أعد تشغيل العرض التجريبي قبل التأكيد.
excel-tested = المنطقة الملتقطة: { $rows } صفوف، { $columns } أعمدة. تحقق من أن الجدول أدناه يشبه ورقتك.
excel-empty-capture = المنطقة التي حددتها لا تلتقط أي صف: تحقق من أرقام الصفوف والأعمدة.
excel-title-next = الانتقال إلى الخطوة التالية
excel-into-account = استيراد إلى الحساب { $account }.

excel-tab-links = روابط بين الحقول
excel-tab-settings = إعدادات الاستيراد
excel-column-excel = عنوان_Excel
excel-column-radinus = حقل_Radinus
excel-links-help = أمام كل عمود من ورقتك، حدد أي حقل في Radinus يغذيه. الأعمدة المتروكة على [IGNORE] لا تُستورد.
excel-group-category = فئات بلا تطابق
excel-group-payment-mode = طرق دفع بلا تطابق
excel-group-assignment = تخصيصات بلا تطابق
excel-policy-create = { $kind ->
    [payment-mode] إنشاء طرق الدفع غير الموجودة تلقائيًا
    [assignment] إنشاء التخصيصات غير الموجودة تلقائيًا
   *[category] إنشاء الفئات غير الموجودة تلقائيًا
}
excel-policy-ask = { $kind ->
    [payment-mode] السؤال عن مكان نقل البيانات لكل طريقة دفع غير موجودة
    [assignment] السؤال عن مكان نقل البيانات لكل تخصيص غير موجود
   *[category] السؤال عن مكان نقل البيانات لكل فئة غير موجودة
}
excel-policy-blank = { $kind ->
    [payment-mode] ترك طريقة الدفع فارغة
    [assignment] ترك التخصيص فارغًا
   *[category] ترك الفئة فارغة
}
excel-policy-default = { $kind ->
    [payment-mode] نقل طرق الدفع غير الموجودة إلى طريقة دفع افتراضية
    [assignment] نقل التخصيصات غير الموجودة إلى تخصيص افتراضي
   *[category] نقل الفئات غير الموجودة إلى فئة افتراضية
}
excel-define-destination = تحديد الوجهة
excel-not-linked = { $kind ->
    [payment-mode] لا يوجد عمود يغذي طريقة الدفع: هذا الإعداد لا ينطبق.
    [assignment] لا يوجد عمود يغذي التخصيص: هذا الإعداد لا ينطبق.
   *[category] لا يوجد عمود يغذي الفئة: هذا الإعداد لا ينطبق.
}
excel-fields-help = اضبط التطابقات، ثم السياسات الثلاث، قبل تشغيل الاستيراد.
excel-title-import = تشغيل الاستيراد

excel-refusal-required = يجب أن تشير حقول التاريخ والوصف والمبلغ إلزاميًا إلى أعمدة excel
excel-refusal-column-twice = حقول Radinus مختلفة تشير إلى نفس عمود excel: لا يمكن للعمود أن يغذي سوى حقل واحد
excel-refusal-field-twice = نفس حقل Radinus مرتبط بعمودي excel: لا يمكن أن يكون له سوى عمود واحد
excel-refusal-ask-unset = { $kind ->
    [payment-mode] اخترت السؤال عن مكان نقل طرق الدفع غير المعروفة: اضغط "تحديد الوجهة" قبل تشغيل الاستيراد.
    [assignment] اخترت السؤال عن مكان نقل التخصيصات غير المعروفة: اضغط "تحديد الوجهة" قبل تشغيل الاستيراد.
   *[category] اخترت السؤال عن مكان نقل الفئات غير المعروفة: اضغط "تحديد الوجهة" قبل تشغيل الاستيراد.
}

excel-column-data = بيانات_Excel
excel-column-destination = { $kind ->
    [payment-mode] طريقة_الدفع_Radinus
    [assignment] التخصيص_Radinus
   *[category] الفئة_Radinus
}
excel-association-help = أمام كل قيمة آتية من ورقتك، اختر القيمة المقابلة في Radinus التي يجب ترتيبها فيها. الصف المتروك فارغًا يبقى بلا تصنيف.
excel-association-none = لا توجد قيمة غير معروفة: كل ما تحمله ورقتك موجود بالفعل في Radinus.

excel-imported = اكتمل الاستيراد: { $count } عملية مكتوبة، { $refused } صف مرفوض، { $created } قيمة من البيانات الأساسية تم إنشاؤها.
excel-report-title = تقرير الاستيراد
excel-column-row = صف Excel
excel-column-content = المحتوى
excel-column-reason = سبب الرفض
excel-nothing-refused = جميع صفوف ورقتك تم إدخالها: لا يوجد أي رفض.

excel-refused-date = تاريخ غائب أو غير مقروء
excel-refused-amount = مبلغ غائب أو غير مقروء
excel-refused-amount-both = مبلغ في عمود المدين وآخر في عمود الدائن: يتعذر الاختيار
excel-refused-amount-missing = لا مدين ولا دائن في هذا الصف

# ---------------------------------------------------------------------------
# المرحلة 16 — العمليات الدورية (F15، F38، F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = قائمة العمليات الدورية
window-recurring-form-title = بطاقة تحديد قاعدة توليد العملية الدورية
window-recurring-calendar-title = اقتراح جدول العمليات المراد إدراجها في حساباتك المصرفية

recurring-column-label = الوصف
recurring-none = لا توجد قاعدة متكررة مسجلة.
recurring-help = اختر قاعدة، ثم الجدول لرؤية تواريخ الاستحقاق التي تقترحها.
recurring-title-calendar = اقتراح جدول تواريخ الاستحقاق
recurring-deleted = { $count ->
    [0] لم يتم حذف أي قاعدة.
    [one] تم حذف قاعدة واحدة. تبقى عملياتها في الحساب.
    [two] تم حذف قاعدتين. تبقى عملياتهما في الحسابات.
    [few] تم حذف { $count } قواعد. تبقى عملياتها في الحسابات.
    [many] تم حذف { $count } قاعدة. تبقى عملياتها في الحسابات.
   *[other] تم حذف { $count } قاعدة. تبقى عملياتها في الحسابات.
}
recurring-gone = هذه القاعدة لم تعد موجودة.
recurring-delete-question = حذف القواعد المحددة؟ العمليات التي أدرجتها بالفعل ستبقى في حساباتك.

recurring-group-identity = التعريف والحساب المصرفي المعني
recurring-group-nomenclature = البيانات الأساسية
recurring-group-amount = تحديد مبلغ العملية
recurring-group-period = تحديد الفترة
recurring-group-ending = شروط انتهاء الفترة
recurring-group-produced = معلومات عن العمليات المدرجة بالفعل ( للاطلاع فقط )

recurring-field-id = معرف العملية
recurring-field-account = الحساب الهدف
recurring-field-label = الوصف
recurring-field-category = الفئة
recurring-field-mode = طريقة الدفع
recurring-field-assignment = التخصيص
recurring-field-payee = الطرف المقابل / التجار
recurring-field-project = المشروع
recurring-field-direction = نوع العملية
recurring-field-amount = المبلغ
recurring-field-next = تاريخ العملية التالية
recurring-field-every = ثم كل
recurring-field-end-date = تاريخ النهاية
recurring-field-repeat = عدد التكرارات
recurring-field-guid = GUID العملية
recurring-field-produced-count = عدد العمليات المدرجة
recurring-field-produced-last = تاريخ آخر عملية مدرجة
recurring-field-produced-total = إجمالي المبالغ المولدة

recurring-unit-day = يوم
recurring-unit-week = أسبوع
recurring-unit-month = شهر
recurring-unit-quarter = ربع سنة
recurring-unit-year = سنة
recurring-ending-no-limit = بلا حد
recurring-ending-until-date = بتاريخ نهاية
recurring-ending-repeat-count = عدد التكرارات

recurring-title-erase = حذف العمليات التي أدرجتها هذه القاعدة
recurring-erase-question = { $count ->
    [zero] لم تدرج هذه القاعدة أي عملية في حساباتك.
    [one] أدرجت هذه القاعدة عملية واحدة في حساباتك. هل تريد حذفها؟ سيُعاد حساب الأرصدة، ولن تتراجع القاعدة.
    [two] أدرجت هذه القاعدة عمليتين في حساباتك. هل تريد حذفهما؟ سيُعاد حساب الأرصدة، ولن تتراجع القاعدة.
    [few] أدرجت هذه القاعدة { $count } عمليات في حساباتك. هل تريد حذفها كلها؟ سيُعاد حساب الأرصدة، ولن تتراجع القاعدة.
    [many] أدرجت هذه القاعدة { $count } عملية في حساباتك. هل تريد حذفها كلها؟ سيُعاد حساب الأرصدة، ولن تتراجع القاعدة.
   *[other] أدرجت هذه القاعدة { $count } عملية في حساباتك. هل تريد حذفها كلها؟ سيُعاد حساب الأرصدة، ولن تتراجع القاعدة.
}
recurring-erase-none = لم تدرج هذه القاعدة أي عملية بعد.
recurring-erased = { $count ->
    [0] لم يتم حذف أي عملية.
    [one] تم حذف عملية واحدة، وأعيد حساب الأرصدة.
    [two] تم حذف عمليتين، وأعيد حساب الأرصدة.
    [few] تم حذف { $count } عمليات، وأعيد حساب الأرصدة.
    [many] تم حذف { $count } عملية، وأعيد حساب الأرصدة.
   *[other] تم حذف { $count } عملية، وأعيد حساب الأرصدة.
}

recurring-calendar-help = احذف بسلة المهملات تواريخ الاستحقاق التي لا تريدها، ثم أكد لإدراجها.
recurring-calendar-none = لا يوجد تاريخ استحقاق لاقتراحه: تحقق من تاريخ العملية التالية ومن حساب قواعدك.
recurring-calendar-column-account = الحساب
recurring-calendar-column-date = التاريخ
recurring-calendar-column-label = الوصف
recurring-calendar-column-amount = المبلغ
recurring-calendar-column-category = الفئة
recurring-calendar-column-assignment = التخصيص
recurring-calendar-column-mode = طريقة الدفع
recurring-calendar-column-payee = الطرف المقابل
recurring-calendar-column-project = المشاريع
recurring-calendar-removed = { $count ->
    [zero] لم يتم سحب أي تاريخ استحقاق من الاقتراح.
    [one] تم سحب تاريخ استحقاق واحد من الاقتراح.
    [two] تم سحب تاريخي استحقاق من الاقتراح.
    [few] تم سحب { $count } تواريخ استحقاق من الاقتراح.
    [many] تم سحب { $count } تاريخ استحقاق من الاقتراح.
   *[other] تم سحب { $count } تاريخ استحقاق من الاقتراح.
}
recurring-title-insert = إدراج تواريخ الاستحقاق المحددة في الحسابات
recurring-nothing = لم يبق أي تاريخ استحقاق للإدراج.
# السؤال المطروح قبل الكتابة: إدراج جدول ينشئ عمليات حقيقية
# في حسابات حقيقية، وهذا لا يتم بنقرة شاردة.
recurring-insert-question = { $count ->
    [zero] لا يوجد تاريخ استحقاق للإدراج.
    [one] إدراج تاريخ الاستحقاق هذا في حسابك؟ سيتم إنشاء عملية وإعادة حساب الأرصدة.
    [two] إدراج تاريخي الاستحقاق هذين في حساباتك؟ سيتم إنشاء عمليتين وإعادة حساب الأرصدة.
    [few] إدراج تواريخ الاستحقاق هذه البالغة { $count } في حساباتك؟ سيتم إنشاء عدد مماثل من العمليات وإعادة حساب الأرصدة.
    [many] إدراج تواريخ الاستحقاق هذه البالغة { $count } في حساباتك؟ سيتم إنشاء عدد مماثل من العمليات وإعادة حساب الأرصدة.
   *[other] إدراج تواريخ الاستحقاق هذه البالغة { $count } في حساباتك؟ سيتم إنشاء عدد مماثل من العمليات وإعادة حساب الأرصدة.
}
recurring-inserted = { $count ->
    [zero] لم يتم إدراج أي عملية.
    [one] تم إدراج عملية واحدة. تستأنف القاعدة بعد آخر تاريخ استحقاق مدرج.
    [two] تم إدراج عمليتين. تستأنف القواعد بعد آخر تاريخ استحقاق مدرج لها.
    [few] تم إدراج { $count } عمليات. تستأنف القواعد بعد آخر تاريخ استحقاق مدرج لها.
    [many] تم إدراج { $count } عملية. تستأنف القواعد بعد آخر تاريخ استحقاق مدرج لها.
   *[other] تم إدراج { $count } عملية. تستأنف القواعد بعد آخر تاريخ استحقاق مدرج لها.
}

recurring-refusal-label-required = إدخال الوصف إلزامي
recurring-refusal-date-required = إدخال تاريخ العملية التالية إلزامي
recurring-refusal-date-too-old = يجب أن يكون تاريخ العملية التالية أكبر من أو يساوي سنة 2000
recurring-refusal-account-gone = الحساب المصرفي المحدد غير موجود، يرجى اختيار حساب جديد لجعل القاعدة قابلة للتطبيق
recurring-refusal-end-required = في حالة وجود تاريخ نهاية، يجب إدخال التاريخ
recurring-refusal-end-before-start = لا يمكن أن يكون تاريخ النهاية أقل من تاريخ العملية التالية
recurring-refusal-end-too-far = لا يمكن أن يتجاوز الفارق بين تاريخ العملية التالية وتاريخ النهاية 10 000 يوم

# --- المرحلة 15 — المطبوعات والتقارير -------------------------------
# العنوان الكبير للشريط، منقول حرفاً بحرف من تقرير WinDev الأصلي.
print-operations-title = قائمة العمليات المصرفية والعمليات الفرعية
print-menu-operations-pdf = الطباعة في ملف PDF
print-recap-title = ملخص حسب الفئة
print-recap-count = الصفوف
print-row-count = عدد الصفوف:
print-total-debit = إجمالي المدين:
print-total-credit = إجمالي الدائن:
print-final-balance = الرصيد النهائي:
print-licence = Radinus برنامج حر يُوزَّع بموجب رخصة GNU GPL الإصدار 3 أو أحدث
print-nothing = لا يوجد ما يُطبع.
print-done = تمت طباعة التقرير وفتحه: "{ $file }".
print-failed = الطباعة غير ممكنة: { $reason }
# تمت كتابة ملف PDF فعلاً، لكن النظام لم يعرف كيف يفتحه: نقول ذلك دون
# الإيحاء بالفشل، ما دام الملف موجوداً.
print-not-opened = تمت طباعة التقرير في "{ $file }"، لكن نظامك لم يعرف كيف يفتحه وحده.

# --- تقرير RIB (F32) --------------------------------------------------
# عناوين كشف الهوية المصرفية، منقولة من المستند الأصلي.
rib-title = كشف الهوية المصرفية
rib-bank = البنك:
rib-national = RIB - المعرف الوطني للحساب
rib-establishment = المؤسسة
rib-branch = الفرع
rib-number = رقم الحساب
rib-key = مفتاح RIB
rib-domiciliation = عنوان الفرع
rib-iban = IBAN - المعرف الدولي للحساب
rib-bic = BIC - المعرف الدولي للمؤسسة
rib-holder = صاحب الحساب

# --- نافذة F32 ----------------------------------------------------
window-rib-title = طباعة RIB ( كشف الهوية المصرفية )
rib-group-bank = البنك
rib-group-holder = صاحب الحساب
rib-group-details = البيانات المصرفية
rib-field-bank = اسم البنك
rib-field-domiciliation = عنوان الفرع
rib-field-holder = اسم صاحب الحساب
rib-field-address = العنوان
rib-field-establishment = المؤسسة
rib-field-branch = الفرع
rib-field-number = رقم الحساب
rib-field-key = مفتاح RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = شروط استخدام مهمة يجب احترامها إلزامياً في حالة الطباعة
rib-declaration = أنا الموقع أدناه، مستخدم البرنامج، أصرح بشرفي:
rib-declaration-first = - أؤكد أنني تحققت لدى بنكي من أن البيانات المصرفية الواردة في هذه النافذة صحيحة ومطابقة لإرادتي. وأؤكد بالطريقة نفسها أنني ألتزم بالتحقق من أن البيانات الواردة في تقرير طباعة RIB صحيحة ومطابقة لإرادتي. تتم هذه الطباعة ويتم استخدام RIB على مسؤوليتي الكاملة
rib-declaration-second = - أن أكون صاحب الحساب الذي سيُطبع RIB الخاص به، وألا أستعمل وظائف هذا البرنامج لغرض مخالف للقانون.
rib-title-print = الطباعة على الطابعة
rib-title-pdf = الطباعة في ملف PDF
# المربع ليس تحذيراً زخرفياً: ما دام غير محدد، يبقى الزران مطفأين
# (قرار Fabrice، 01/08/2026).
rib-declaration-required = حدد إقرار الشرف لتتمكن من الطباعة.
rib-help = تحقق من بياناتك، وحدد الإقرار، ثم اطبع.
rib-account-gone = هذا الحساب المصرفي غير موجود.
rib-fields-read-only = هذه البيانات تأتي من بطاقة الحساب: صححها في البطاقة لتتغير هنا.
rib-printed = تم إرسال RIB إلى طابعتك الافتراضية.
rib-print-failed = الطباعة غير ممكنة: { $reason }
rib-pdf-done = تمت طباعة RIB وفتحه: "{ $file }".
rib-pdf-not-opened = تمت طباعة RIB في "{ $file }"، لكن نظامك لم يعرف كيف يفتحه وحده.
menu-accounts-bank-details = إصدار كشف الهوية المصرفية

# اختيار الطابعة. يطرح Radinus السؤال بنفسه: لا يفتح أي من طرق العرض
# الثلاثة مربع حوار الطباعة الخاص بالنظام.
print-choose-printer = على أي طابعة تريد الطباعة؟
print-do-print = طباعة
rib-printed-on = تم إرسال RIB إلى الطابعة "{ $printer }".
ui-cancel = إلغاء

# لم يعرف النظام تسمية أي طابعة: نطبع رغم ذلك على الطابعة الافتراضية
# بدلاً من تعطيل المستخدم.
print-printers-unknown = لم يعرف نظامك تسمية أي طابعة: أُرسل المستند إلى الطابعة الافتراضية.

print-menu-operations-printer = الطباعة على الطابعة
print-sent-on = تم إرسال التقرير إلى الطابعة "{ $printer }".
print-sent-default = تم إرسال التقرير إلى طابعتك الافتراضية.

# --- المرحلة 17 — العمليات على قاعدة البيانات -------------------
backup-archive = أرشيف Radinus
backup-no-database = لا توجد قاعدة بيانات مفتوحة.
backup-done = تمت كتابة النسخة الاحتياطية في "{ $file }".
backup-failed = النسخ الاحتياطي غير ممكن: { $reason }
restore-unreadable = هذا الملف ليس أرشيف Radinus قابلاً للقراءة: { $reason }
# يقول السؤال ما الذي سيُفقد قبل أن يُفقد. وقد قُرئ الأرشيف في تلك
# اللحظة: ما يعلنه أمر مؤكد.
restore-question = استعادة "{ $file }"؟ سيُمحى كل المحتوى الحالي لقاعدتك ويُستبدل، وسيُفقد كل ما فيها.
restore-done = انتهت الاستعادة: { $accounts } حسابات و{ $operations } عملية.
restore-failed = الاستعادة غير ممكنة: { $reason }


# --- سجل العمليات التقنية (المرحلة 17) --------------------
# الحالات الثلاث في Ajoute_Log عنده، بحروف كبيرة كما عنده.
journal-status-success = نجاح
journal-status-failure = فشل
journal-status-repaired = تم الإصلاح
journal-step-reindex = إصلاح جدول قاعدة البيانات
journal-step-refill = البيانات الأساسية للنظام فارغة: أُعيدت القيم الافتراضية
journal-step-table-created = جدول مفقود من قاعدة البيانات: أُعيد إنشاؤه فارغًا
journal-step-column-added = عمود مفقود من الجدول: أُضيف بقيمته الافتراضية

# --- Protection par mot de passe (05/08/2026) ---
password-protect = الحماية بكلمة مرور
window-password-form-title = الحماية بكلمة مرور
password-ask = قاعدة البيانات هذه محمية. أدخل كلمة المرور الخاصة بها.
password-group-database = قاعدة البيانات المعنية
password-group-password = كلمة المرور
password-group-warning = قبل التأكيد
password-field-old = كلمة المرور القديمة
password-field-new = كلمة المرور الجديدة
password-field-repeat = أعد كتابة كلمة المرور الجديدة
password-hint = اترك القديمة فارغة إذا لم تكن قاعدة البيانات محمية بعد. اترك الجديدتين فارغتين لإزالة الحماية.
password-lost-warning = كلمة مرور ضائعة تعني قاعدة بيانات ضائعة: لا شيء يسمح باستعادتها. أما النسخ الاحتياطية فتبقى غير مشفَّرة.
password-show = إظهار كلمة المرور
password-remove-question = إزالة الحماية عن قاعدة البيانات هذه؟
password-mismatch = الإدخالان لكلمة المرور الجديدة مختلفان
password-wrong = كلمة المرور غير صحيحة
password-close-first = أغلق قاعدة البيانات هذه قبل تغيير كلمة المرور
password-now-protected = قاعدة البيانات محمية بكلمة مرور
password-now-clear = قاعدة البيانات لم تعد محمية
journal-step-date-fixed = تصحيح عملية بلا تاريخ
journal-step-circular = حذف عملية غير متسقة: مرجع دائري
journal-step-flag-parent-true = علامة خاطئة EstParent=Faux على عملية رئيسية
journal-step-flag-parent-false = علامة خاطئة EstParent=Vrai على عملية رئيسية
journal-step-flag-child = علامة خاطئة EstParent=Vrai على عملية فرعية
journal-step-orphan = حذف عملية فرعية يتيمة
journal-step-third-level = حذف عملية فرعية مرتبطة بعملية فرعية أخرى
journal-step-coherence = إعادة حساب عامة للاتساق بين العمليات الفرعية والعمليات الرئيسية
journal-step-balances = إعادة حساب جميع أرصدة جميع الحسابات
journal-step-vacuum = تحسين ملف قاعدة البيانات
journal-step-analyze = تحديث إحصائيات البحث
journal-step-backup-begin = بداية النسخ الاحتياطي لقاعدة البيانات
journal-step-backup-end = نهاية النسخ الاحتياطي لقاعدة البيانات
journal-step-restore-begin = بداية استعادة قاعدة البيانات من الأرشيف
journal-step-restore-end = نهاية استعادة قاعدة البيانات من الأرشيف
journal-step-restore-read = قراءة الأرشيف

# --- نافذة السجل (⌘H) -----------------------------------------
window-journal-title = سجل آخر عملية تقنية
journal-column-step = الخطوة
journal-column-file = الملف
journal-column-table = الجدول
journal-column-status = الحالة
journal-column-error = الخطأ
journal-column-comments = الملاحظات
journal-empty = لم تُنفَّذ أي عملية تقنية بعد منذ فتح البرنامج.
journal-help = لا يحتفظ السجل إلا بآخر عملية تقنية: نسخ احتياطي أو استعادة أو إصلاح أو محو أو فتح قاعدة بيانات.

# --- الإصلاح ------------------------------------------------------
menu-file-repair-running = جارٍ الإصلاح والتحسين…
repair-done = { $anomalies ->
    [0] انتهى الإصلاح: لم يُعثر على أي اختلال. عدد الخطوات المسجلة: { $lines }.
    [one] انتهى الإصلاح: تم إصلاح اختلال واحد. عدد الخطوات المسجلة: { $lines }.
    [two] انتهى الإصلاح: تم إصلاح اختلالين. عدد الخطوات المسجلة: { $lines }.
    [few] انتهى الإصلاح: تم إصلاح { $anomalies } اختلالات. عدد الخطوات المسجلة: { $lines }.
    [many] انتهى الإصلاح: تم إصلاح { $anomalies } اختلالاً. عدد الخطوات المسجلة: { $lines }.
   *[other] انتهى الإصلاح: تم إصلاح { $anomalies } اختلال. عدد الخطوات المسجلة: { $lines }.
}
repair-failed = الإصلاح غير ممكن: { $reason }

journal-status-started = قيد التنفيذ
journal-status-finished = منتهٍ
journal-step-backup-table = كتابة الجدول في الأرشيف
journal-step-backup-write = كتابة الأرشيف
journal-step-backup-verified = التحقق من الأرشيف المكتوب: ملفات أُعيدت قراءتها / متوقعة، سجلات أُعيدت قراءتها / مكتوبة
journal-step-backup-total = إجمالي ما تم حفظه: السجلات، البيانات، حجم الملف
journal-step-restore-table = قراءة الجدول من الأرشيف
journal-step-restore-missing = الملف غير موجود في الأرشيف: لن يُستعاد هذا الجدول
journal-step-restore-wipe = محو كامل لمحتوى قاعدة البيانات قبل الاستعادة
journal-step-restore-write = الكتابة في قاعدة البيانات
journal-step-restore-total = إجمالي ما تمت استعادته: الحسابات، العمليات
backup-verify-mismatch = لا يُقرأ الأرشيف المكتوب كما كُتب: لا تثق به، وأعد النسخ الاحتياطي.

# --- مرفقات العملية (F28، المرحلة 17) -----------------
window-attachments-title = مرفقات العملية
attachment-filter = المستندات المقبولة
attachment-none = لا تحمل هذه العملية أي مرفق.
attachment-title-add = إرفاق مستند بهذه العملية
attachment-title-open = فتح المرفق
attachment-title-remove = إزالة المرفق وإرسال ملفه إلى سلة المهملات
# حالة الملف على القرص. "غير قابل للتحقق" ليس اعترافاً مجانياً بالجهل:
# البصمات القادمة من Radinus 1.9.3 مبتورة بفعل صيغة النسخة الاحتياطية،
# والحكم على ملف بناءً عليها يعني الاتهام اعتباطاً.
attachment-state-ok = سليم
attachment-state-changed = معدَّل
attachment-state-missing = الملف غير موجود
attachment-state-unknown = غير قابل للتحقق
attachment-added = تم إرفاق "{ $name }" بالعملية.
attachment-removed = أُزيل المرفق، وملفه في سلة المهملات.
attachment-removed-kept = أُزيل المرفق، لكن لم يمكن نقل ملفه إلى سلة المهملات.
attachment-remove-question = إزالة "{ $name }" من هذه العملية؟ سيُرسل ملفه إلى سلة المهملات.
attachment-opened = تم فتح "{ $name }".
attachment-opened-changed = تم فتح "{ $name }"، لكن محتواه تغير منذ إرفاقه.
attachment-gone = هذا المرفق لم يعد موجوداً.
attachment-file-missing = ملف "{ $name }" غير موجود على القرص.
attachment-failed = العملية غير ممكنة: { $reason }
attachment-save-first = احفظ العملية أولاً: المرفق يرتبط بعملية موجودة.
attachment-refusal-missing = هذا الملف غير موجود.
attachment-refusal-extension = هذا النوع من الملفات غير مقبول. المقبول: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = العملية المراد إرفاق هذا المستند بها غير موجودة.
journal-step-backup-attachments = المرفقات المضافة إلى الأرشيف
journal-step-backup-attachment-missing = المرفق غير موجود على القرص: سيغيب عن الأرشيف
journal-step-restore-attachments = المرفقات المستخرجة من الأرشيف
attachment-title-replace = استبدال مستند هذا المرفق
attachment-replaced = تم استبدال المستند بـ "{ $name }".

# ---------------------------------------------------------------------
# F08 — قائمة "أدوات" في بطاقة الحساب.
#
# مدخلاتها الثلاثة منقولة من WLangage الخاص بـ Fabrice (مجلد
# "Information import export base piece jointe"): حساب الرصيد الابتدائي
# المطابق، وإحصائيات الحساب، وحذف جميع عملياته. لا تعمل القائمة إلا في
# وضع التعديل (قرار 02/08/2026): عند الإنشاء لا يوجد ما يُحسب، وفي وضع
# الاطلاع لا تفعل البطاقة سوى العرض.
# ---------------------------------------------------------------------

account-tools = أدوات
account-tools-initial-balance = تحديد الرصيد الابتدائي المطابق
account-tools-statistics = إحصائيات الحساب المصرفي
account-tools-delete-operations = حذف جميع عمليات الحساب

# سؤال الحساب، منقول حرفاً بحرف من الأصل. { $total } هو إجمالي العمليات
# المطابقة، مكتوب مسبقاً بالصيغة النقدية.
account-initial-balance-question =
    لحساب الرصيد الابتدائي المطابق بالنظر إلى العمليات الموجودة في هذا الحساب، يرجى إدخال الرصيد الحالي لدى بنكك
    سيُحسب الرصيد الابتدائي المطابق على أنه يساوي:
    { "[" }الرصيد البنكي الحالي] - [إجمالي العمليات المطابقة ({ $total }) ].
    { "" }
    لتفادي إعادة إدخال هذه القيمة، يجب أن تكون قائمة العمليات المصرفية في هذا الحساب محدثة تماماً.

account-statistics-none = لا توجد عمليات

# الأسطر الأربعة عشر في Info() عنده. الخطأ المطبعي "pengagés" في الأصل
# مصحح، بقرار Fabrice في 02/08/2026 — مثل "Bank Identifer Code" في
# البطاقة نفسها.
account-statistics =
    إجمالي عدد العمليات في هذا الحساب: { $count }
    { "" }
    عدد العمليات المطابقة في هذا الحساب: { $pointed }
    مبلغ المدين المطابق: { $pointedDebits }
    مبلغ الدائن المطابق: { $pointedCredits }
    الفرق بين الدائن والمدين المطابقين: { $pointedDifference }
    { "" }
    عدد العمليات المحجوزة في هذا الحساب: { $committed }
    مبلغ المدين المحجوز: { $committedDebits }
    مبلغ الدائن المحجوز: { $committedCredits }
    الفرق بين الدائن والمدين المحجوزين: { $committedDifference }
    { "" }
    عدد العمليات المخططة في هذا الحساب: { $planned }
    مبلغ المدين المخطط: { $plannedDebits }
    مبلغ الدائن المخطط: { $plannedCredits }
    الفرق بين الدائن والمدين المخططين: { $plannedDifference }
    { "" }
    أقدم عملية: { $first }
    أحدث عملية: { $last }

# الحاجز المزدوج للحذف. { $word } هي كلمة "نعم" في اللغة الجارية — من يتحدث
# الإسبانية ولو طُلب منه كتابة OUI لما فهم (قرار Fabrice، 02/08/2026).
account-delete-operations-question =
    هل أنت متأكد من حذف جميع العمليات الموجودة في الحساب المصرفي؟
    للتأكيد اكتب { $word } في الحقل أدناه ثم أكّد

account-delete-operations-done =
    { $count ->
        [0] لم يتم حذف أي عملية.
        [one] تم حذف عملية واحدة.
        [two] تم حذف عمليتين.
        [few] تم حذف { $count } عمليات.
        [many] تم حذف { $count } عملية.
       *[other] تم حذف { $count } عملية.
    }

# ---------------------------------------------------------------------
# محدد قاعدة البيانات واختيار اللغة (02/08/2026)
#
# قرارات اتُّخذت في نقاش مع Fabrice: لم يعد Radinus ينشئ قاعدة بيانات دون
# إذن؛ ومن دون لغة في الإعدادات يطلب اللغة قبل كل شيء آخر؛ وتُعدّ قاعدة
# بيانات كل مجلد في databases/ يحتوي على radinus.sqlite، أيًّا كان اسمه.
#
# نافذة اختيار اللغة ليس لها أي مفتاح هنا: فهي لا تستعمل أي جملة، وهذا ما
# يتيح فهمها قبل أن نعرف أي لغة يتحدث المستخدم.
# ---------------------------------------------------------------------

window-database-selector-title = قواعد البيانات
window-database-form-title = قاعدة بيانات جديدة
database-group-identity = تعريف قاعدة البيانات
database-group-restore = تهيئة قاعدة البيانات ببيانات من نسخة احتياطية
database-choose-backup = اختيار ملف النسخة الاحتياطية
database-no-backup = لم يتم اختيار نسخة احتياطية: ستُنشأ قاعدة البيانات فارغة.

databases-column-label = القاعدة
databases-column-comment = تعليق
databases-column-folder = المجلد
databases-column-created = تاريخ الإنشاء

databases-none = لا توجد قاعدة بيانات حتى الآن: أنشئ واحدة.
databases-help = اختر قاعدة البيانات المراد فتحها، أو أنشئ واحدة جديدة.
databases-select = اختر أولًا قاعدة بيانات من القائمة.
databases-tools = أدوات
databases-title-open = فتح هذه القاعدة

database-created = تم إنشاء قاعدة البيانات "{ $label }".
database-field-label = اسم قاعدة البيانات
database-field-comment = تعليق
database-label-required = أعطِ اسمًا لهذه القاعدة: فهو ما يميزها عن غيرها.
database-gone = لم تعد هذه القاعدة موجودة: فقد نُقلت أو حُذفت منذ فتح هذه النافذة.

# حذف قاعدة بيانات (02/08/2026). يذهب المجلد إلى سلة مهملات النظام، مثل
# المرفقات: قاعدة حُذفت خطأً تعود بنقرة يمنى. أما القاعدة المفتوحة فمرفوضة
# — Radinus يمسك ملفها.
databases-title-delete = حذف هذه القاعدة
database-delete-question =
    هل أنت متأكد من حذف قاعدة البيانات "{ $label }"؟
    { "" }
    يذهب مجلدها كله إلى سلة المهملات: العمليات والحسابات والمرفقات.
    للتأكيد، اكتب { $word } في الحقل أدناه ثم أكّد.
database-in-use = هذه القاعدة مفتوحة: لا يستطيع Radinus حذفها. افتح واحدة أخرى أولًا.
database-deleted = قاعدة البيانات "{ $label }" في سلة المهملات.

# للمحدد وضعان (Fabrice، 02/08/2026). إذا فُتح أثناء الاستعمال، فهو لا يعرف
# الفتح: نافذة Radinus تُبنى مرة واحدة ولا تُهدم أبدًا، ولا شيء يستطيع أن
# ينسيها القاعدة التي تعرضها. نطّلع، ننشئ، نحذف — ولتغيير القاعدة، نخرج.
database-quit-first = لفتح هذه القاعدة، أغلق Radinus ثم أعد تشغيله: سيعرضها عليك المحدد عند البدء.


# --- F01 — نافذة الاستقبال (المرحلة 17 مكرر، 03/08/2026) ----------------
#
# أول إضافة في 2.0.0 على 1.9.3: لم تعد نافذة الاستقبال تحمل الشريط وحده.
# القاعدة التي تحكمها مكتوبة في الوثيقة 04 F01: إنها العرض بدون نقرة واحدة،
# ولا يدخلها شيء يحتاج إلى ضبط.
#
# يحمل عنوانا المخطط الحلقي الشهر كاملًا بدل أن تلصقهما النافذة طرفًا بطرف:
# "المصروفات ... — أغسطس 2026" ليس لها ترتيب الكلمات نفسه في اللغات الثلاث،
# وFluent وحدها تعرف أين الفراغ.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] لا يوجد حساب مفتوح
    [one] حساب مفتوح واحد
    [two] حسابان مفتوحان
    [few] { $count } حسابات مفتوحة
    [many] { $count } حسابًا مفتوحًا
   *[other] { $count } حساب مفتوح
}
welcome-total-bank = الرصيد البنكي
welcome-total-real = الرصيد الفعلي
welcome-total-final = الرصيد النهائي
welcome-total-real-detail = مطابق + محجوز
welcome-total-final-detail = مطابق + محجوز + مخطط
welcome-accounts = حساباتك
welcome-tile-bank = في البنك
welcome-tile-real = الفعلي
welcome-tile-final = النهائي
welcome-spending = النفقات — { $month }
welcome-earning = الإيرادات — { $month }
ui-legend-budget-lines = بنود الميزانية
ui-legend-categories = الفئات
welcome-nothing = لا توجد أي عملية هذا الشهر.
welcome-open-account = معلومة: انقر على حساب لفتح عملياته.
welcome-no-account = لا يوجد حساب مصرفي حتى الآن.
welcome-no-account-create = أنشئ حسابًا مصرفيًا بالنقر هنا
welcome-previous-month = الشهر السابق
welcome-next-month = الشهر التالي
welcome-refresh = إعادة قراءة الكل


# --- F39 — التفضيلات (المرحلة 17 ثالثًا، 03/08/2026) ---------------------
#
# مكان العلامة النقدية يعيش هنا، إلى جانب الفاصلين: فهو يتبع اللغة لا
# العملة. "before" يضع العلامة أمام الرقم، وأي قيمة أخرى تضعها خلفه. ولا
# تُكتب أي علامة نقدية في هذا الملف: "الفرنسية" لا تعني "اليورو".

ui-money-sign-position = after
window-preferences-title = التفضيلات
menu-settings-preferences = التفضيلات…
menu-settings-show-main = عرض النافذة الرئيسية
menu-settings-folders = مجلدات Radinus
preferences-branch-display = العرض
preferences-leaf-language = اللغة
preferences-leaf-currency = العملة
preferences-field-language = لغة البرنامج:
preferences-field-currency = العملة المعروضة:
preferences-field-custom = علامة العملة:
preferences-currency-system = عملة النظام
preferences-currency-euro = يورو
preferences-currency-dollar = دولار
preferences-currency-canadian = دولار كندي
preferences-currency-cfa = فرنك أفريقي
preferences-currency-cfp = فرنك المحيط الهادئ
preferences-currency-swiss = فرنك سويسري
preferences-currency-none = لا شيء
preferences-currency-custom = مخصص
preferences-currency-system-is = يعلن نظامك:
preferences-currency-system-silent = لا يعلن نظامك أي عملة: ستُعرض المبالغ باليورو.
preferences-custom-required = اكتب علامة عملتك قبل الحفظ.
preferences-saved = تم حفظ التفضيلات.
preferences-help = اختر خيارًا من الشجرة، ثم احفظ.
preferences-sign-too-long = علامة العملة تتسع لـ 8 أحرف على الأكثر.
preferences-sign-not-a-number = لا يمكن أن تحتوي علامة العملة على رقم ولا على علامة حسابية ولا على فاصلة: فـ Radinus يزيلها عند قراءة مبلغ، و"120" تصبح "12".
preferences-leaf-zoom = حجم العرض
preferences-field-zoom = التكبير:
preferences-zoom-reset = القيمة الافتراضية
preferences-zoom-hint = كل شيء يكبر معًا: النص والأيقونات والأعمدة. دون 100 %، يتسع على الشاشة أكثر. أما شريط قوائم النظام وصناديق حواره فتتبع إعدادات حاسوبك لا هذه الإعدادات.

# --- شريط الاستقبال ---------------------------------------------
#
# كانت هذه الجمل مكتوبة بشكل ثابت في `index.html` منذ المرحلة 0 ولم تكن
# تُترجم إذن (لاحظه Fabrice في 03/08/2026). الشعار صوته هو: النسختان
# الإنجليزية والإسبانية اقتراحان، عليه أن يصححهما — فالشعار لا يُترجم كلمة
# بكلمة.
ui-language-tag = ar
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — السنجاب التميمة، ببذلة، محاطًا بيورو وآلة حاسبة ورسوم بيانية
welcome-slogan-one = برنامج لإدارة الشؤون المالية الشخصية يساعدك على أن تنفق أقل لتكسب أكثر
welcome-slogan-two = مع Radinus ستفهم لماذا تصنع الجداول الصغيرة الأنهار الكبيرة.

# --- "عن المؤلف" --------------------------------------------
#
# الاسم والعنوان مكتوبان بالشكل نفسه في الملفات الثلاثة: فهما لا يُترجمان.
# وهما هنا رغم ذلك، لا في الصفحة، كي لا يحمل العرض أي جملة — ولكي يُصحَّحا
# في مكان واحد يوم ينتقل المؤلف.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = عن المؤلف
about-author-flag-alt = علم كورسيكا — رأس المغربي

# --- "عن Radinus" ---------------------------------------------
#
# `about-radinus-version` تحمل فراغًا: رقم الإصدار يأتي من الملف التنفيذي
# الذي يعمل، لا من سلسلة منسوخة. فهي إذن ليست في قاموس النوافذ — الأمر
# `app_version` هو الذي يملؤها.
window-about-radinus-title = عن Radinus
about-radinus-name = Radinus
about-radinus-version = الإصدار { $version }
about-radinus-rust-alt = شعار لغة Rust
about-radinus-tauri-alt = شعار Tauri
about-radinus-built = Radinus مكتوب بلغة Rust ومبني بـ Tauri. الأول يحسب حساباتك، والثاني يجعل منه تطبيق سطح مكتب.
about-radinus-licence = برنامج حر، بترخيص GNU GPL الإصدار 3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = رخصة الاستخدام
licence-heading = رخصة استخدام برنامج RADINUS
licence-logo-alt = شعار رخصة GNU General Public License الإصدار 3
licence-name = GNU GPL الإصدار 3 أو أحدث
licence-intro = Radinus برنامج حر.
licence-freedoms-title = ترخيصه يمنحك أربع حريات:
licence-freedom-use = استخدامه كما تشاء، لما تشاء.
licence-freedom-study = دراسة شفرته المصدرية المفتوحة للجميع.
licence-freedom-share = نسخه وإعطاؤه للآخرين.
licence-freedom-improve = تعديله ومشاركة تعديلاتك.
licence-read = قراءة النص الكامل للرخصة

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = يُقدَّم هذا البرنامج دون أي ضمان، بالقدر الذي يسمح به القانون.
licence-info = يُفتح النص الرسمي في متصفحك، على gnu.org.

