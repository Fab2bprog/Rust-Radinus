# Radinus — skilaboð kjarnahliðarinnar (Fluent), íslenska.
# Fyllt út smám saman eftir því sem kjarnaeiningarnar sem framleiða skilaboð
# til notandans verða til. Sjá 08_ARCHITECTURE.md §2.1.

# Staðgengillinn „0 = Ekki tilgreint“ sem hver valfrjáls tenging við grunngögn
# notar (02_BASE_DE_DONNEES.md §7 regla 2). Birtist efst í hverjum fellilista.
# ---------------------------------------------------------------------
# Heiti tungumálsins, skrifað á tungumálinu sjálfu.
#
# Það er þetta sem Stillingar-valmyndin og valið við fyrstu ræsingu sýna
# (01_CAHIER_DES_CHARGES.md §3.5: „hvert tungumál skrifað á sínu eigin
# tungumáli“). Það stendur hér, en ekki í kóðanum, því þetta er eini
# staðurinn þar sem það getur verið rétt: að bæta við tungumáli er að leggja
# inn skrá sem kann að nefna sig sjálf.
# ---------------------------------------------------------------------
language-name = Íslenska

nomenclature-unspecified = Ekki tilgreint

# Spurt áður en einingu í grunngögnum er eytt sem færslur nota enn
# (02_BASE_DE_DONNEES.md §7 regla 5). Endurtekið orð fyrir orð úr upprunalega
# WinDev-kóðanum (Enreg_Supprimer), með sömu leturgerð og greinarmerkjum —
# orðalagið er höfundarins, það er engin þýðing.
nomenclature-delete-confirm = Færslur (bankafærslur) sem hafa eigindið af gerðinni '{ $label }' hafa fundist. Staðfestir þú að þú viljir endurstilla þetta eigindi?

# Spurt áður en einingu í grunngögnum er eytt sem ekkert notar. Upprunalega
# útgáfan eyddi slíkri einingu umsvifalaust, án orðs; Fabrice bað 25/07/2026
# um að eyðing væri alltaf staðfest — meðvitað frávik frá hans eigin kóða, og
# það eina í þessari einingu.
nomenclature-delete-plain = Staðfestir þú eyðingu á „{ $label }“?

# Neitun sem birtist þegar einingin sem notandinn ætlar að eyða er einmitt sú
# sem spjald hennar sýnir. Úrskurður Fabrice 25/07/2026: einingu er ekki eytt
# undan sínu eigin opna spjaldi — spjaldinu er lokað fyrst, frekar en að láta
# það standa og sýna skráningu sem er ekki lengur til.
nomenclature-delete-form-open = Spjald „{ $label }“ er opið. Lokaðu því áður en þú eyðir.

# Neitun sem birtist þegar lýsingin sem verið er að vista ber þegar önnur eining
# í sömu grunngögnum (úrskurður höfundar, 25/07/2026: tvær einingar í sömu
# grunngögnum mega ekki deila nafni — að flokka færslu undir aðra af tveimur
# eins lýsingum er hlutkesti). `element` er nafnorðið í sínu eigin kyni,
# „flokkur“, „mótaðili“; `label` er lýsingin sem fyrir er, eins og hún er
# geymd, svo notandinn sjái hvað stendur í veginum.
nomenclature-duplicate = Það er þegar til { $element } með sama nafni: „{ $label }“.

# ---------------------------------------------------------------------
# Það sem gluggarnir segja um sjálfa sig.
#
# Allt stendur hér, líka það sem veltur á þeim grunngögnum sem birtast:
# setningarnar eru skrifaðar í heild sinni, tungumál fyrir tungumál, frekar
# en settar saman úr orðum og kynjum. Samsetning sem er rétt á frönsku er
# röng í næsta tungumáli, og það endar með því að kóðinn veit að til er
# kvenkyn — það er ekki hans verk (regla höfundar, 25/07/2026: „hugbúnaðurinn
# vinnur með Fluent á frönsku og ensku strax frá byrjun“).
# ---------------------------------------------------------------------

ui-loading = Hleð…
ui-editing = Breyting.
ui-viewing = Skoðun.
ui-modified-suffix = — breytt
ui-label-required = Lýsingin er nauðsynleg.
ui-discard-question = Viltu henda breytingunum?
ui-yes = Já
ui-no = Nei
ui-select-record = Veldu skráningu
ui-key-multiselect = CTRL
ui-multiselect-help = Ábending: Notaðu músarsmell + [{ $modifier }] takkann á töflunni til að velja fleiri einingar
ui-no-match = Engin lýsing passar við síuna.
ui-filter-placeholder = Sía lýsingar…
ui-column-label = LÝSING
ui-field-label = Lýsing
ui-field-budget-line = Fjárhagsliður
ui-identifier = Auðkenni
ui-deletion-abandoned = Hætt við eyðingu: engu var breytt.
ui-unknown-nomenclature = Óþekkt grunngögn:

ui-title-filter = Sía
ui-title-create = Búa til
ui-title-update = Breyta valinu
ui-title-delete = Eyða valinu
ui-title-read = Skoða valið
ui-title-close = Loka
ui-title-save = Vista
ui-title-add = Bæta við
ui-title-modify = Breyta

ui-load-failed = Hleðsla ekki möguleg:
ui-save-failed = Vistun ekki möguleg:
ui-read-failed = Lestur ekki mögulegur:
ui-delete-failed = Eyðing ekki möguleg:
ui-open-failed = Opnun ekki möguleg:
ui-close-failed = Lokun ekki möguleg:

# --- Setningar sem heyra hverjum grunngögnum til ----------------------

nomenclature-identifier = { $kind ->
    [category] Auðkenni flokks
    [assignment] Auðkenni úthlutunar
    [payment-mode] Auðkenni greiðslumáta
    [payee] Auðkenni mótaðila
    [project] Auðkenni verkefnis
    [budget-line] Auðkenni fjárhagsliðar
   *[bank] Auðkenni banka
}

nomenclature-none = { $kind ->
    [category] Enginn flokkur.
    [assignment] Engin úthlutun.
    [payment-mode] Enginn greiðslumáti.
    [payee] Enginn mótaðili.
    [project] Ekkert verkefni.
    [budget-line] Enginn fjárhagsliður.
   *[bank] Enginn banki.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Enginn flokkur til að sýna.
    [assignment] Engin úthlutun til að sýna.
    [payment-mode] Enginn greiðslumáti til að sýna.
    [payee] Enginn mótaðili til að sýna.
    [project] Ekkert verkefni til að sýna.
    [budget-line] Enginn fjárhagsliður til að sýna.
   *[bank] Enginn banki til að sýna.
}

nomenclature-gone = { $kind ->
    [category] Þessi flokkur er ekki lengur til.
    [assignment] Þessi úthlutun er ekki lengur til.
    [payment-mode] Þessi greiðslumáti er ekki lengur til.
    [payee] Þessi mótaðili er ekki lengur til.
    [project] Þetta verkefni er ekki lengur til.
    [budget-line] Þessi fjárhagsliður er ekki lengur til.
   *[bank] Þessi banki er ekki lengur til.
}

nomenclature-fresh = { $kind ->
    [category] Nýr flokkur.
    [assignment] Ný úthlutun.
    [payment-mode] Nýr greiðslumáti.
    [payee] Nýr mótaðili.
    [project] Nýtt verkefni.
    [budget-line] Nýr fjárhagsliður.
   *[bank] Nýr banki.
}

nomenclature-created = { $kind ->
    [category] Flokki bætt við.
    [assignment] Úthlutun bætt við.
    [payment-mode] Greiðslumáta bætt við.
    [payee] Mótaðila bætt við.
    [project] Verkefni bætt við.
    [budget-line] Fjárhagslið bætt við.
   *[bank] Banka bætt við.
}

nomenclature-updated = { $kind ->
    [category] Flokki breytt.
    [assignment] Úthlutun breytt.
    [payment-mode] Greiðslumáta breytt.
    [payee] Mótaðila breytt.
    [project] Verkefni breytt.
    [budget-line] Fjárhagslið breytt.
   *[bank] Banka breytt.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] { $count } flokki eytt.
       *[other] { $count } flokkum eytt.
      }
    [assignment] { $count ->
        [one] { $count } úthlutun eytt.
       *[other] { $count } úthlutunum eytt.
      }
    [payment-mode] { $count ->
        [one] { $count } greiðslumáta eytt.
       *[other] { $count } greiðslumátum eytt.
      }
    [payee] { $count ->
        [one] { $count } mótaðila eytt.
       *[other] { $count } mótaðilum eytt.
      }
    [project] { $count ->
        [one] { $count } verkefni eytt.
       *[other] { $count } verkefnum eytt.
      }
    [budget-line] { $count ->
        [one] { $count } fjárhagslið eytt.
       *[other] { $count } fjárhagsliðum eytt.
      }
   *[bank] { $count ->
        [one] { $count } banka eytt.
       *[other] { $count } bönkum eytt.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Það er þegar til flokkur með sama nafni: „{ $label }“.
    [assignment] Það er þegar til úthlutun með sama nafni: „{ $label }“.
    [payment-mode] Það er þegar til greiðslumáti með sama nafni: „{ $label }“.
    [payee] Það er þegar til mótaðili með sama nafni: „{ $label }“.
    [project] Það er þegar til verkefni með sama nafni: „{ $label }“.
    [budget-line] Það er þegar til fjárhagsliður með sama nafni: „{ $label }“.
   *[bank] Það er þegar til banki með sama nafni: „{ $label }“.
}

# --- Gluggatitlar, án kommustafa eins og á upprunalegu gluggunum ------

window-list-title = { $kind ->
    [category] Listi yfir flokka
    [assignment] Listi yfir úthlutanir
    [payment-mode] Listi yfir greiðslumáta
    [payee] Listi yfir mótaðila og söluaðila
    [project] Listi yfir verkefni
    [budget-line] Listi yfir fjárhagsliði
   *[bank] Listi yfir banka
}

window-form-title = { $kind ->
    [category] Spjald flokks
    [assignment] Spjald úthlutunar
    [payment-mode] Spjald greiðslumáta
    [payee] Spjald mótaðila
    [project] Spjald verkefnis
    [budget-line] Spjald fjárhagsliðar
   *[bank] Spjald banka
}

# --- Valmyndastika (01_CAHIER_DES_CHARGES.md §6) ----------------------

menu-file = Skrá
menu-file-import-statements = Innflutningur reikningsyfirlita
menu-file-import-excel = Innflutningur Excel-skráar
menu-file-backup = Öryggisafrit
menu-file-restore = Endurheimt
menu-file-repair = Viðgerð og bestun gagnagrunnsins
menu-file-log = Sýna atburðaskrána
menu-file-disconnect = Aftengjast núverandi gagnagrunni
menu-file-quit = Hætta

menu-accounts = Reikningar
menu-accounts-manage = Umsjón bankareikninga
menu-accounts-balances = Skoða stöðu reikninga þinna
menu-accounts-operations = Sýsla með færslur á reikningi
menu-accounts-quick-classify = Hröð flokkun færslna
menu-accounts-recurring = Umsjón endurtekinna færslna
menu-accounts-transfer = Millifæra upphæð milli tveggja reikninga
menu-accounts-checkbooks = Umsjón tékkhefta

menu-statistics = Tölfræði
menu-statistics-balance-chart = Graf Þróun stöðu
menu-statistics-by-category = Tölfr. eftir flokkum
menu-statistics-by-assignment = Tölfr. eftir úthlutunum
menu-statistics-by-budget-line = Tölfr. eftir fjárhagsliðum
menu-statistics-by-payment-mode = Tölfr. eftir greiðslumátum
menu-statistics-by-payee = Tölfr. eftir mótaðilum og söluaðilum
menu-statistics-by-project = Tölfr. eftir verkefnum
menu-statistics-dashboard = Stjórnborð færslna

menu-budget = Fjárhagsáætlun
menu-budget-entry = Skráning fjárhagsáætlunar
menu-budget-control = Eftirlit fjárhagsáætlunar

menu-nomenclatures = Grunngögn
menu-nomenclature = { $kind ->
    [category] Flokkar
    [assignment] Úthlutanir
    [payment-mode] Greiðslumátar
    [payee] Mótaðilar og söluaðilar
    [project] Verkefni
    [budget-line] Fjárhagsliðir
   *[bank] Bankar
}
menu-nomenclatures-templates = Sniðmát færslna

menu-settings = Stillingar
menu-settings-about-author = Um höfundinn
menu-settings-about-radinus = Um Radinus
menu-settings-licence = Notkunarleyfi

menu-misc = Ýmislegt
menu-misc-calculator = Reiknivél
menu-misc-website = Fara á vefsíðu Radinus
menu-misc-database-folder = Opna möppuna sem inniheldur gagnagrunninn
menu-misc-application-folder = Opna möppuna sem inniheldur forritið

# ---------------------------------------------------------------------
# Bankareikningar — F04, F06, F07, F08.
# Innsláttarvillurnar í útgáfu 1.9.3 („Bank Identifer Code“, „Solde
# initial prevu“, „Est Cloturé“, bilið á undan sviganum við IBAN) hafa
# verið leiðréttar: ákvörðun Fabrice 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Umsjón bankareikninga
window-accounts-select-title = Listi yfir reikninga
window-balances-title = Staða reikninga þinna
window-account-title = Reikningsspjald

accounts-none = Enginn reikningur.
accounts-nothing-to-show = Enginn reikningur til að sýna.
accounts-gone = Þessi reikningur er ekki lengur til.
accounts-fresh = Nýr reikningur.
accounts-created = Reikningi bætt við.
accounts-updated = Reikningi breytt.
accounts-deleted = { $count ->
    [one] { $count } reikningi eytt.
   *[other] { $count } reikningum eytt.
}
accounts-duplicate-name = Það er þegar til reikningur með sama nafni: „{ $label }“.
accounts-multiselect-help = Ábending: Notaðu músarsmell + [{ $modifier }]-lykilinn á töflunni til að velja marga reikninga
accounts-select-question = Á hvaða bankareikningum á tölfræðin að byggjast?

accounts-column-label = LÝSING
accounts-column-bank = Banki
accounts-column-type = Tegund reiknings
accounts-column-number = Reikningsnr.
accounts-column-account = Reikningur
accounts-column-bank-balance = Í banka
accounts-column-real-balance = Raun
accounts-column-final-balance = Loka
accounts-total = SAMTALS

# Þegar reikningi er eytt fylgja færslur hans með: þetta er eini staðurinn
# í hugbúnaðinum þar sem eyðing tortímir sögu.
accounts-delete-plain = Staðfestir þú eyðingu reikningsins „{ $label }“?
accounts-delete-with-operations = Reikningurinn „{ $label }“ inniheldur { $count } færslur, sem verður eytt með honum. Staðfestir þú eyðinguna?
accounts-delete-form-open = Spjald reikningsins „{ $label }“ er opið. Lokaðu því áður en þú eyðir.

account-group-bank = Upplýsingar um reikning og banka
account-group-holder = Reikningseigandi
account-group-rib = Bankaupplýsingar (RIB)
account-group-activity = Virkni
account-group-balances = Staða

account-field-label = Heiti reiknings
account-field-bank = Banki
account-field-type = Tegund reiknings
account-field-branch-address = Heimilisfang bankaútibús
account-field-holder-name = Nafn
account-field-holder-address = Heimilisfang
account-field-rib-bank = Bankastofnun
account-field-rib-branch = Útibúsnúmer
account-field-rib-number = Reikningsnúmer
account-field-rib-key = RIB-eftirlitstala
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Opnunardagsetning
account-field-closing-date = Lokunardagsetning
account-field-closed = Er lokaður
account-field-opening-pointed = Afstemmd upphafsstaða
account-field-opening-committed = Frátekin upphafsstaða
account-field-opening-planned = Áætluð upphafsstaða

account-label-required = Heiti reiknings er skylda.
account-iban-invalid = Þetta IBAN er ekki gilt: athugaðu eftirlitstöluna.
# Bláa línan neðst á spjaldinu, orðrétt sú sama og í 1.9.3 — aðeins
# upphæðirnar fylgja nú franska sniðinu sem hinir reitirnir nota.
account-control-line = Afstemmd upphafsstaða ({ $opening }) + Samtala færslna ({ $operations }) = Núverandi bankastaða: { $balance }.

amount-not-readable = „{ $field }“ inniheldur ekki gilda upphæð.

ui-thousands-separator = .
ui-decimal-separator = ,

# --- Færslulisti (F02) -----------------------------------------------

window-operations-title = Færslulisti reikningsins: { $account }

operations-none = Engin færsla á þessu tímabili.
operations-bad-period = Mörk tímabilsins eru ekki gildar dagsetningar.
operations-from = Upphafsdagur
operations-to = Lokadagur
operations-delete-confirm = { $count ->
    [one] Staðfestir þú eyðingu á { $count } færslu?
   *[other] Staðfestir þú eyðingu á þessum { $count } línum? Undirfærslur valdra færslna fylgja með þeim.
}
operations-deleted = { $count ->
    [one] { $count } færslu eytt.
   *[other] { $count } færslum eytt.
}
operations-selection-total = Heildarupphæð valinna færslna: { $amount }

operations-column-date = Dags.
operations-column-clearing-date = Afstemmingardags.
operations-column-label = Lýsing
operations-column-category = Flokkur
operations-column-assignment = Úthlutun
operations-column-payment-mode = Greiðslum.
operations-column-payee = Mótaðili
operations-column-project = Verkefni
operations-column-month = Mánuður
operations-column-debit = Debet
operations-column-credit = Kredit
operations-column-balance = Staða
operations-column-comments = Athugasemdir
operations-column-attachments = Viðhengi
operations-column-check = Tékkanr.

operations-foot-debit = Debet:
operations-foot-credit = Kredit:
operations-foot-total = Samtals:
operations-foot-bank = Bankastaða:
operations-foot-real = Raunstaða:
operations-foot-final = Lokastaða:

operations-menu-export = Flytja út
operations-menu-print = Prentun
operations-menu-filter = Sía
operations-menu-period = Tímabil
operations-menu-misc = Ýmislegt

operations-title-point = Stemma af valið
operations-title-sub = Bæta við undirfærslu
operations-title-duplicate = Afrita valið
operations-not-yet = Þessi gluggi er ekki til enn: hann kemur síðar í áætluninni.

accounts-choose-question = Á hvaða reikningi viltu vinna?
ui-title-select = Velja valið

month-january = janúar
month-february = febrúar
month-march = mars
month-april = apríl
month-may = maí
month-june = júní
month-july = júlí
month-august = ágúst
month-september = september
month-october = október
month-november = nóvember
month-december = desember

operations-period-year = Yfirstandandi ár

# --- Tímabilsvalmynd F02 ---------------------------------------------
# Níu færslur, þar af tvær sem opna undirvalmynd með mánuðunum tólf. Hver
# þeirra gerir aðeins eitt: að leiða af sér upphafsdag og lokadag, sem
# glugginn setur aftur í reitina sína tvo (beiðni Fabrice, 25/07/2026).

period-all = Allt
period-last-year = Síðasta Ár
period-this-year = Yfirstandandi Ár
period-whole-year = Allt árið
period-last-month = Síðasti Mánuður
period-this-month = Yfirstandandi Mánuður
period-last-week = Síðasta Vika
period-this-week = Yfirstandandi Vika
period-yesterday = Í gær
period-today = Í dag

# --- Síuvalmynd F02 --------------------------------------------------
# Síar línurnar eftir eðli færslunnar (ósk frá Fabrice, 25/07/2026).
# Stöðurnar þrjár eru þær sem eru í gagnagrunninum: 1 afstemmd, 2 frátekin,
# 3 áætluð (02_BASE_DE_DONNEES.md §5.2).

filter-all = Allar færslur
filter-pointed = Aðeins afstemmdar færslur
filter-committed = Aðeins fráteknar færslur
filter-planned = Aðeins áætlaðar færslur

# --- Færsluspjald (F03) ----------------------------------------------
# Heitin eru þau sem sjást á skjámyndinni „Fiche operation transaction.png“,
# með prentvillum frumgerðarinnar leiðréttum (leyfi frá Fabrice, 25/07/2026:
# „prentvillurnar leiðréttir þú“): „Libelle“ verður „Libellé“,
# „Categorie“ verður „Catégorie“, „Statut Operation“ verður
# „Statut opération“.

window-operation-title = Færsla reiknings: { $account }

operation-menu-identification = Auðkenni
operation-menu-options = Valkostir
operation-fitid-edit = Breyta FITID-auðkenni…
operation-fitid-delete = Eyða FITID-auðkenni
operation-fitid-question = FITID-auðkenni þessarar færslu:
operation-fitid-delete-question = Eyða FITID-auðkenni þessarar færslu?
operation-fitid-written = FITID-auðkenni vistað.
operation-fitid-removed = FITID-auðkenni eytt.

operation-group-identification = Auðkenni færslunnar
operation-group-amount = Upphæð færslunnar
operation-group-status = Staða færslunnar
operation-group-classification = Flokkun færslunnar fyrir útreikning tölfræðinnar
operation-group-check = Tékki tengdur færslunni
operation-group-comment = Athugasemd

operation-field-label = Lýsing
operation-field-reference = Greiðslutilvísun
operation-field-date = Dagsetning
operation-field-direction = Tegund færslu:
operation-field-amount = Upphæð
operation-field-status = Staða færslu
operation-field-clearing-date = Afstemmingardagur
operation-field-category = Flokkur
operation-field-assignment = Úthlutun
operation-field-payment-mode = Máti
operation-field-payee = Mótaðili
operation-field-project = Verkefni
operation-field-check = Tengja við tékka

operation-direction-debit = Debet
operation-direction-credit = Kredit

operation-check-info = Uppl.
operation-check-link = Tengja
operation-check-unlink = Eyða

operation-fresh = Ný færsla.
operation-created = Færslu bætt við.
operation-updated = Færslu breytt.
operation-gone = Þessi færsla er ekki lengur til.
operation-nothing-to-show = Engar færslur til að sýna.
operation-label-required = Lýsing færslunnar er nauðsynleg.
operation-date-required = Dagsetning færslunnar er nauðsynleg.
operation-clearing-date-invalid = Afstemmingardagurinn er ekki gild dagsetning.
operation-is-a-sub = Þessi lína er undirfærsla: henni er breytt á hennar eigin spjaldi.
operation-delete-form-open = Spjaldið fyrir „{ $label }“ er opið. Lokaðu því áður en þú eyðir.

operation-attachments = { $count ->
    [0] Ekkert viðhengi
    [one] { $count } viðhengi
   *[other] { $count } viðhengi
}

operation-title-comment = Athugasemd færslunnar
operation-title-sub = Búa til undirfærslu
operation-title-template = Sniðmát færslna
operation-title-attachment = Viðhengi

# --- Undirfærsluspjald (F04) -----------------------------------------
# Minnkuð útgáfa af F03: hvorki Máti, Staða né Dagsetning — undirfærsla
# fær þau frá móðurfærslunni (`Maj_ProprieteSousOp`, staðfest af Fabrice
# 26/07/2026: „í undirfærslu, þar sem hún er viðbótin, er ekki hægt að
# hrófla við greiðslumátanum, það væri órökrétt“).

window-sub-operation-title = Spjald undirfærslu

sub-operation-group-amount = Upphæð undirfærslunnar
sub-operation-field-label = Nafn
sub-operation-fresh = Ný undirfærsla.
sub-operation-created = Undirfærslu bætt við.
sub-operation-updated = Undirfærslu breytt.
sub-operation-gone = Þessi undirfærsla er ekki lengur til.
sub-operation-nothing-to-show = Engar undirfærslur til að sýna.
sub-operation-label-required = Nafn undirfærslunnar er nauðsynlegt.
sub-operation-parent-gone = Færslan sem á að skipta upp er ekki lengur til.
# Það sem spjaldið segir þegar það sýnir Viðbótina. Hún er ekki læst: það má
# breyta henni, en maður verður að vita hvað maður er að taka sér fyrir hendur
# (ákvörðun Fabrice, 26/07/2026).
sub-operation-is-the-complement = Þetta er Viðbótin: það sem eftir er að skipta upp. Ef þú endurnefnir hana eða breytir upphæð hennar verður hún venjuleg undirfærsla.
sub-operation-of = Skipting „{ $label }“ ({ $amount })

operations-pointed = { $count ->
    [one] { $count } færsla afstemmd.
   *[other] { $count } færslur afstemmdar.
}
operations-select-one = Veldu aðeins eina færslu.

# --- Afritun og birting undirfærslna (F02) ---------------------------
# Afritun opnar forútfyllt spjald sem notandinn staðfestir sjálfur
# (ákvörðun Fabrice, 26/07/2026): ekkert er skrifað fyrr en hann hefur vistað,
# og hann getur leiðrétt dagsetninguna eða upphæðina áður.

operation-copy = Afrit sem á eftir að vista: ekkert hefur enn verið búið til.
operations-show-children = Sýna allar undirfærslur
operations-hide-children = Fela allar undirfærslur

# --- Önnur staðfesting á alvarlegri eyðingu --------------------------
# Að eyða bankareikningi tekur alla sögu hans með sér: það er smellt á Já/Nei
# án þess að lesa, svo við biðjum um að orðið sé skrifað (ákvörðun Fabrice,
# 26/07/2026). Orðið er það sem stendur í orðabókinni — „Já“ hér, „Yes“ á
# ensku — svo ekkert þarf að þýða hér tvisvar.

accounts-delete-second-question = Þessi eyðing er endanleg og tekur alla sögu reikningsins með sér. Skrifaðu „{ $word }“ til að staðfesta hana.

# --- F20-F24 — Tölfræðin sex -----------------------------------------
# Sameiginlegt sniðmát, útfært á sex ása. Sú eftir flokkum var fyrirmyndin og
# Fabrice staðfesti hana 26/07/2026 áður en hinar fimm urðu til — dálkanöfnin
# eru þau sömu og í frumgerðinni.

window-statistics-title = { $kind ->
    [assignment] Tölfræði eftir úthlutun
    [budget-line] Tölfræði eftir fjárhagslið
    [payment-mode] Tölfræði eftir greiðslumáta
    [payee] Tölfræði eftir mótaðila og söluaðila
    [project] Tölfræði eftir verkefni
   *[category] Tölfræði eftir flokki
}

statistics-axis-column = { $kind ->
    [assignment] Úthlutun
    [budget-line] FjárhagsLiður
    [payment-mode] FærsluMáti
    [payee] Mótaðili
    [project] Verkefni
   *[category] FlokksNafn
}

statistics-unclassified = { $kind ->
    [assignment] Án úthlutunar
    [budget-line] Án fjárhagsliðar
    [payment-mode] Án greiðslumáta
    [payee] Án mótaðila
    [project] Án verkefnis
   *[category] Án flokks
}
statistics-total = Samtals
statistics-sum = Summa
statistics-cumulative = Uppsafnað

# Rofarnir fimm á borðanum. Heitið skiptist á milli ON og OFF, eins og í
# frumgerðinni: það er rofinn sjálfur sem segir hvar hann stendur.
statistics-switch-pointed = Afstemmdar færslur { $state }
statistics-switch-committed = Fráteknar færslur { $state }
statistics-switch-planned = Áætlaðar færslur { $state }
statistics-switch-debits = Debetupphæðir { $state }
statistics-switch-credits = Kreditupphæðir { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Enginn reikningur var valinn: tölfræðin nær ekki til neins.
statistics-no-data = Engar færslur á þessu ári fyrir valda reikninga.
statistics-detail-empty = Smelltu á reit með tölu til að sjá færslurnar sem hann telur.
statistics-detail-none = Engar færslur að baki þessum reit.
statistics-accounts = { $count ->
    [one] { $count } reikningur
   *[other] { $count } reikningar
}
statistics-year-next = Næsta ár
statistics-year-previous = Fyrra ár

statistics-column-date = Dagsetning
statistics-column-clearing-date = Afstemmingardagur
statistics-column-label = Lýsing
statistics-column-amount = Upphæð
statistics-column-comments = Athugasemdir

accounts-stats-multiselect-help = Uppl.: Notaðu músarsmell + [{ $modifier }]-lykilinn á töflunni til að velja fleiri reikninga

# Ártal tölfræðinnar: það er smellt á það og ár slegið inn. Mörkin eru þau
# sömu og í „Allt“ í Tímabil-valmyndinni — ár í Radinus er heiltala á milli
# 1950 og 2550 (Fabrice, 26/07/2026).
statistics-year-question = Hvaða ár viltu vinna með? Radinus nær frá { $first } til { $last }.
statistics-year-choose = Velja ár

# --- Útflutningur taflna (hægrismellur) ------------------------------
# Aðgerð töflunnar, ekki gluggans: allir listarnir hafa hana.

export-to-excel = Flytja út í Excel (.xlsx)
export-to-word = Flytja út í Word (.docx)
export-to-tsv = Flytja út í TSV (.tsv)
export-to-ini = Flytja út í INI (.ini)
export-to-toml = Flytja út í TOML (.toml)
export-to-yaml = Flytja út í YAML (.yaml)
export-to-ofx = Flytja út í OFX (.ofx)
export-to-qif = Flytja út í QIF (.qif)
export-to-ods = Flytja út í LibreOffice Calc (.ods)
export-to-csv = Flytja út í CSV (.csv)
export-to-xml = Flytja út í XML (.xml)
# Útflutningsvalmynd tölfræðigluggans: einn flipi á hvert ár, nefndur AN_2026.
# Tómu árin — miðað við rofana eins og þeir standa — eru ekki með.
export-menu = Útflutningur
export-all-years-excel = Flytja öll árin út í Excel
export-all-years-ods = Flytja öll árin út í LibreOffice Calc
export-no-year = Ekkert ár ber færslu: það er ekkert til að flytja út.
export-years-done = { $years } ár flutt út í „{ $file }“.
export-to-json = Flytja út í JSON (.json)
export-done = Flutt út í „{ $file }“.
export-failed = Útflutningur ekki mögulegur: { $reason }
export-nothing = Það er ekkert til að flytja út.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Tölfræði eftir úthlutun
    [budget-line] Tölfræði eftir fjárhagslið
    [payment-mode] Tölfræði eftir greiðslumáta
    [payee] Tölfræði eftir mótaðila og söluaðila
    [project] Tölfræði eftir verkefni
   *[category] Tölfræði eftir flokki
}
statistics-detail-name = Nánar um tölfræðina

# --- F19 — Stjórnborð --------------------------------------------------
# Eitt tímabil og þrír rofar; tveir hringir á hvern fjárhagslið;
# þrjár stórar tölur. Litir geiranna eru þeir sömu og í upprunalega
# forritinu, teknir af skjámynd Fabrice.

window-dashboard-title = Stjórnborð
dashboard-menu-period = Tímabil
dashboard-menu-misc = Ýmislegt
dashboard-from = Upphafsdagsetning:
dashboard-to = Lokadagsetning:
dashboard-switch-pointed = Taka með afstemmdar færslur
dashboard-switch-committed = Taka með fráteknar færslur
dashboard-switch-planned = Taka með áætlaðar færslur
dashboard-spending = Útgjöld
dashboard-earning = Tekjur
dashboard-debits = Samtala debetfærslna
dashboard-credits = Samtala kreditfærslna
dashboard-balance = Jöfnuður
dashboard-unclassified = Án fjárhagsliðar
dashboard-nothing = Engar færslur á þessu tímabili.
dashboard-no-account = Enginn reikningur hefur verið valinn: stjórnborðið sýnir ekkert.
dashboard-enlarge = Opna í fullri stærð

# --- F25 — Þróun stöðu -------------------------------------------------
# Eitt graf fyrir hvern valinn reikning, auk grafsins fyrir heildina — sem
# er aðeins til frá og með tveimur reikningum (regla Fabrice, 26/07/2026).
# Gröfin eru þrepalaga: staðan heldur gildi sínu fram að næstu færslu.

window-curve-title = Þróun stöðu
curve-heading = Þróun stöðu eftir dögum
curve-menu-period = Tímabil
curve-total = Samtals
curve-from = Upphafsdagsetning:
curve-to = Lokadagsetning:
curve-axis-balance = staða
curve-nothing = Enginn reikningur hefur verið valinn: það er ekkert graf til að teikna.
curve-empty = Engar færslur á þessu tímabili.

# --- F05 — Hraðflokkun færslna -----------------------------------------
# Glugginn þar sem flokkað er **í hópum**: þú velur línur, hakar við þá
# eiginleika sem á að breyta og beitir þeim í einu lagi — í minni.
# Ekkert er skrifað fyrr en vistað hefur verið, og vistunin skrifar
# aðeins það sem er frábrugðið því sem lesið var (reglur Fabrice,
# 27/07/2026).

window-quick-classification-title = Hraðflokkun færslna: { $account }
quick-dates-title = Upphafs- og lokadagsetning listans.
quick-from = Upphafsdagsetning
quick-to = Lokadagsetning
quick-menu-period = Tímabil
quick-change-title = Breyta eiginleikum valsins í:
quick-check-category = Flokkur
quick-check-assignment = Úthlutun
quick-check-payment-mode = Máti
quick-check-payee = Mótaðili
quick-check-project = Verkefni
quick-check-status = Staða
quick-column-date = Dagsetning
quick-column-label = Lýsing
quick-column-amount = Upphæð
quick-column-category = Flokkur
quick-column-assignment = Úthlutun
quick-column-payment-mode = Greiðslumáti
quick-column-payee = Mótaðili
quick-column-project = Verkefni
quick-column-status = Staða
# Á Mac er Ctrl + smellur hægrismellur: lykillinn sem bætir við val er þar
# ⌘, og hjálpartextinn verður að nefna þann sem virkar í raun.
quick-multiselect-help = Ábending: Notaðu músarsmell + [{ $modifier }]-lykilinn á töflunni til að velja marga hluti
quick-none = Engar færslur á þessu tímabili.
quick-select-lines = Veldu að minnsta kosti eina línu og hakaðu við að minnsta kosti einn eiginleika.
quick-applied = { $count ->
    [0] Ekkert breyttist: þessar línur báru þessa flokkun þegar.
    [one] { $count } lína flokkuð. Ekkert hefur enn verið vistað.
   *[other] { $count } línur flokkaðar. Ekkert hefur enn verið vistað.
}
quick-pending = { $count ->
    [0] Engar breytingar bíða.
    [one] { $count } línu breytt, ekki vistað.
   *[other] { $count } línum breytt, ekki vistað.
}
quick-save-question = { $count ->
    [one] Vista { $count } breytingu sem bíður?
   *[other] Vista { $count } breytingar sem bíða?
}
quick-saved = { $count ->
    [0] Það var ekkert til að vista.
    [one] { $count } lína vistuð.
   *[other] { $count } línur vistaðar.
}
quick-nothing-to-save = Engar breytingar bíða.
quick-leave-question = Breytingar hafa ekki verið vistaðar. Hvað viltu gera?
quick-leave-save = Vista og hætta
quick-leave-discard = Henda og hætta
quick-leave-stay = Vera áfram
quick-title-apply = Beita á valdar línur ( í minni )
quick-title-save = Vista á diskinn

# --- F17 / F18 — Innflutningur bankareikningsyfirlits -------------------
# Þú velur reikning, opnar OFX-skrá — sem helst í vinnsluminni —, línurnar
# sem gagnagrunnurinn þekkir þegar birtast í pastellitum, og þriðja táknið
# fellir þær inn: í hópum ef margar eru valdar, annars eina og eina um
# afstemmingarspjaldið (verklag Fabrice, 27/07/2026).

window-statement-import-title = Innflutningur reikningsyfirlita bankareikninga: { $account }
window-statement-form-title = Afstemma færslu (Fellir færslu inn í sögu reikningsins þíns)
statement-menu-filter = Sía
statement-filter-all = Allar línur
statement-filter-pending = Á eftir að fella inn
statement-filter-known = Þegar felldar inn
statement-column-id = ID
statement-column-reconciled = Afstemmt
statement-column-fitid = FITID
statement-column-date = Dagsetning
statement-column-label = Lýsing
statement-column-debit = Debet
statement-column-credit = Kredit
statement-account = Reikningur
statement-file = Skrá
statement-difference = Mismunur
statement-none = Ekkert reikningsyfirlit er opið: smelltu á gulu möppuna til að velja skrá.
statement-empty = Þetta reikningsyfirlit inniheldur engar færslur.
statement-no-match = Engin lína samsvarar síunni.
statement-help = Ábending: Notaðu músarsmell + [{ $modifier }]-lykilinn á töflunni til að velja margar línur
statement-choose-account = Þessi skrá inniheldur marga reikninga. Hvern viltu flytja inn?
statement-select-line = Veldu að minnsta kosti eina línu í reikningsyfirlitinu.
statement-title-open = Opna reikningsyfirlitsskrá (.ofx)
statement-title-info = Upplýsingar um opnu skrána
statement-title-integrate = Fella valið inn í reikninginn
statement-title-validate = Fella þessa færslu inn í reikninginn
statement-duplicate = Aðvörun, tvítekning: þessi færsla virðist þegar hafa verið felld inn í gagnagrunninn (Financial Institution Transaction ID er til)
statement-no-fitid = Aðvörun: þessi skrá gefur ekkert auðkenni (FITID) fyrir þessa línu. Ekki verður hægt að greina tvítekningu.
statement-loaded = { $count ->
    [0] Þessi skrá inniheldur engar færslur fyrir þennan reikning.
   *[other] { $count } línur lesnar, þar af { $known } þegar til á reikningnum þínum.
}
statement-integrated = { $count ->
    [0] Ekkert var fellt inn: þessar línur eru þegar á reikningnum þínum.
    [one] { $count } færsla felld inn.
   *[other] { $count } færslur felldar inn.
}
# **Skilaboð upprunalega forritsins, orð fyrir orð** (fyrirmæli Fabrice,
# 28/07/2026: halda tryggð við upprunalega kóðann). Hans varar við áður en
# hópvinnslan hefst, spyr línu fyrir línu þegar tvítekning kemur upp og
# gerir upp reikningana í lokin.

statement-mass-question =
    Ertu viss um að þú viljir fella margar færslur inn í reikninginn þinn samtímis?
    Þú verður að flokka þær og einkenna síðar til að fá nákvæma tölfræði
    Þegar um Ofx-skrár er að ræða: ef tvítekningar finnast verður þú að velja hegðun forritsins
    Fyrir aðrar tegundir skráa: þú verður að gæta að tvítekningum
statement-duplicate-question =
    Færslan: { $date } { $label }: { $amount }
    virðist þegar hafa verið felld inn í færslusögu bankareikningsins þíns.
    Viltu virkilega framkvæma afstemminguna?
statement-already-reconciled = Þú hefur þegar afstemmt þessa færslu: hún er þegar felld inn í færslusögu reikningsins þíns
statement-integration-report =
    Innfellingu lokið.
    Fjöldi færslna sem voru felldar inn: { $added }
    Fjöldi færslna sem var sleppt: { $ignored }
statement-integration-abandoned =
    Hætt við innfellinguna!
    Fjöldi færslna sem voru felldar inn: { $added }
    Fjöldi færslna sem var sleppt: { $ignored }
statement-yes = Já
statement-no = Nei
statement-cancel = Hætta við
statement-file-info =
    Reikningur skrárinnar: { $account }
    Tímabil: frá { $from } til { $to }
    Staða samkvæmt bankanum: { $balance }
    { $count } færslur, þar af { $known } þegar til á reikningnum þínum.
statement-group-identification = Auðkenning færslunnar
statement-group-amount = Upphæð færslunnar
statement-group-classification = Flokkun færslunnar til útreiknings á tölfræði
statement-group-status = Staða færslunnar
statement-field-date = Dagsetning
statement-field-label = Lýsing
statement-field-type = Tegund færslu
statement-field-amount = Upphæð
statement-field-mode = Greiðslumáti
statement-field-category = Flokkur
statement-field-assignment = Úthlutun
statement-field-payee = Mótaðili
statement-field-project = Verkefni
statement-field-status = Staða
statement-field-clearing = Afstemmingardagsetning

# --- Glugginn fyrir sundurgreiningu CSV-reikningsyfirlits --------------
# CSV-skrá ber engin áreiðanleg reitaheiti: þú stillir, prófar, skoðar og
# byrjar upp á nýtt. Forskoðunin sýnir allt, líka óskiljanlegan texta — það
# er þannig sem sést að eitthvað hefur farið úrskeiðis — en aðeins gildu
# línurnar færast yfir í innfellingargluggann (regla Fabrice, 27/07/2026).

window-csv-statement-title = Innflutningur gagna úr csv-skrá
csv-preview-title = Forskoðun skrárinnar:
csv-settings-title = Færibreytur fyrir sundurgreiningu skrárinnar í því skyni að draga út gögnin:
csv-extraction-title = Sýn á útdrátt gagnanna samkvæmt sundurgreiningarfæribreytunum  ( athugaðu samræmi gagnanna ):
csv-column-line = Línunr.
csv-column-content = Innihald
csv-header-lines = Fjöldi lína í haus skrárinnar sem á að sleppa
csv-separator = Gögnin (dálkarnir) eru aðgreind með stafnum:
csv-date-at = Staðsetning dagsetningarreits
csv-label-at = Staðsetning lýsingarreits
csv-debit-at = Staðsetning debetupphæðarreits
csv-credit-at = Staðsetning kreditupphæðarreits
csv-test = Prófa færibreyturnar
csv-separator-semicolon = Semíkomma   ;
csv-separator-comma = Komma   ,
csv-separator-tab = Dálkmerki
csv-separator-pipe = Lóðrétt strik   |
csv-separator-space = Bil
csv-help = Stilltu, prófaðu, skoðaðu: aðeins línur með læsilegri dagsetningu og læsilegri upphæð verða fluttar inn.
csv-none = Skráin er tóm.
csv-not-tested = Smelltu á „Prófa færibreyturnar“ til að sjá hvað sundurgreiningin gefur.
csv-extraction = { $count ->
    [0] Sundurgreiningin gefur enga línu: athugaðu fjölda lína í haus og aðgreiningarstafinn.
   *[other] { $count } línur sundurgreindar: { $valid } verða fluttar inn, { $dropped } felldar út vegna ólæsilegrar dagsetningar eða upphæðar.
}
csv-nothing-valid = Engin lína ber bæði læsilega dagsetningu og læsilega upphæð: það er ekkert til að flytja inn. Athugaðu fjölda lína í haus, aðgreiningarstafinn og staðsetningu reitanna.
csv-title-validate = Flytja gildu línurnar yfir í innflutninginn

# --- F13 / F31 / F14 / F12 — Tékkhefti og tékkar (áfangi 9) -------------
# Yfirfærsla á fimm WinDev-kóðunum hans og sjö skjámyndunum, afhentum
# 28/07/2026. Setningarnar hans orðréttar þar sem hann á slíka; mínar annars.
#
# Þrjár tryggðir sem hann skar úr um þennan dag og heyrast í orðunum:
# tvítekin tilvísun er ekki tilkynnt (`Existe_Reference` hans er aldrei
# kölluð), fjöldi tékka er ekki borinn saman við mörkin, og færsluteljarinn
# telur dótturfærslurnar sem listarnir hafna.

window-chequebooks-title = Listi yfir tékkhefti
window-chequebook-title = Stillingar tékkheftis
window-cheques-title = Samsetning tékkheftisins: listi yfir tékka.
window-cheque-title = Tékkaspjald
window-cheque-operations-title = Listi yfir færslur.

# Listi tékkheftanna (F13) — öll heftin, óháð reikningi: dálkarnir tveir um
# reikninginn kæmu að engu gagni ef aðeins einn væri.
chequebooks-column-reference = LÝSING
chequebooks-column-date = Dagsetning
chequebooks-column-account = Heiti reiknings
chequebooks-column-account-number = Nr. reiknings
chequebooks-column-comments = Athugasemdir
chequebooks-none = Ekkert tékkhefti er skráð.
chequebooks-nothing-to-show = Ekkert tékkhefti svarar þessari leit.
chequebooks-title-composition = Sjá samsetningu tékkheftisins
chequebooks-delete-question = Færslur (bankafærslur) tengdar tékkhefti fundust. Staðfestir þú að þú viljir eyða þessu tékkhefti?
chequebooks-deleted = { $count ->
    [one] { $count } tékkhefti eytt.
   *[other] { $count } tékkheftum eytt.
}
chequebooks-gone = Þetta tékkhefti er ekki lengur til.
chequebooks-created = Tékkhefti vistað, með öllum tékkum sínum.
chequebooks-updated = Tékkhefti breytt.
# Þögn `HAjoute` hans: glugginn segir ekki að tilvísunin sé frátekin. Hann
# segir aðeins að ekkert hafi verið vistað — annars héldi maður að heftið
# hefði verið búið til.
# Varúðarreglurnar átta úr „Precauttion enregistrement cheque.txt“ hans, orð
# fyrir orð og í hans röð. Þær sjö fyrstu eru `Erreur()`, sú áttunda `Info()`
# — og röðin ræður því hvað sést þegar tvennt fer úrskeiðis samtímis.
chequebook-refusal-duplicate = Tilvísun með sama nafni er þegar til
chequebook-refusal-reference-required = Skylt er að slá inn tilvísun
chequebook-refusal-number-too-big = Númer fyrsta og/eða síðasta tékka eru of stór (hámarksgildi 999 999 999)
chequebook-refusal-date = Sláðu inn gilda móttökudagsetningu
chequebook-refusal-numbers-required = Fylltu út númer fyrsta og síðasta tékka
chequebook-refusal-order = Númer fyrsta tékka verður að vera lægra en númer síðasta tékka
chequebook-refusal-account = Veldu skilyrðislaust reikninginn sem tengist þessu tékkhefti
chequebook-refusal-too-many = Hámarksfjöldi tékka í tékkhefti: 1000, mörkunum náð
# Staðfestingarbeiðni hans, aðeins sett fram við nýskráningu: hún tekur saman
# það sem verður búið til og varar við að engu af því verði breytt eftir á.
chequebook-creation-question =
    Tékkhefti búið til með eftirfarandi eiginleikum:
    - Fjöldi tékka sem á að búa til:{ $count }
    - Tékkar númeraðir frá { $first } til { $last }
    Athugaðu að þessum gögnum verður ekki hægt að breyta eftir að heftið er búið til!

# Tékkheftisspjaldið (F31). Fimm fyrstu reitirnir verða gráir um leið og
# heftið er til: tékkar þess eru þegar komnir.
chequebook-field-id = Auðkenni tékkheftis
chequebook-field-reference = Tilvísun
chequebook-field-received = Búið til eða móttekið þann
chequebook-field-first = Númer fyrsta tékka
chequebook-field-last = Númer síðasta tékka
chequebook-field-quantity = Fjöldi tékka
chequebook-field-account = Tengja við bankareikning:
chequebook-field-comments = Athugasemdir
chequebook-locked = Tékkar þessa heftis eru þegar búnir til: númeraröð þess breytist ekki lengur.
# Setningin hans, orð fyrir orð (`Enreg_Lire`).
chequebook-account-missing = Bankareikningurinn sem þetta tékkhefti var tengt við vantar eða honum hefur verið eytt!

# Samsetning tékkheftisins (F14). Stöðunni er breytt í reitnum.
cheques-column-number = Tékkanr.
cheques-column-date = Dagsetning
cheques-column-place = Staður
cheques-column-payee = Viðtakandi
cheques-column-amount = Upphæð
cheques-column-status = Staða
cheques-column-comments = Athugasemdir
cheques-column-operations = Fj. tengdra færslna
cheques-none = Þetta tékkhefti inniheldur engan tékka.
cheques-nothing-to-show = Enginn tékki svarar þessari leit.
cheques-help = Smelltu í reitinn Staða til að breyta henni; stækkunarglerið sýnir tengdu færslurnar, hlekkurinn tengir eina.
cheques-title-linked = Sjá færslurnar sem þegar eru tengdar þessum tékka
cheques-title-link = Tengja færslu við þennan tékka
cheques-status-changed = Stöðu tékkans breytt.

# Tékkaspjaldið (F12).
cheque-field-id = Auðkenni tékka
cheque-field-number = Tékkanúmer
cheque-field-issued = Útgáfudagsetning
cheque-field-place = Útgáfustaður
cheque-field-payee = Viðtakandi
cheque-field-amount = Upphæð
cheque-field-comments = Athugasemdir
cheque-field-status = Staða tékkans
cheque-gone = Þessi tékki er ekki lengur til.
cheque-updated = Tékka breytt.

# Tvær ásýndir tengigluggans.
cheque-operations-linked-title = Listi yfir færslur sem þegar eru tengdar þessum tékka.
cheque-operations-choose-title = Veldu færslu til að tengja við tékkann
cheque-operations-column-account = Reikningur
cheque-operations-column-label = Nafn
cheque-operations-column-date = Dagsetning
cheque-operations-column-clearing = Afstemmingardagsetning
cheque-operations-column-amount = Upphæð
cheque-operations-column-cheque = Tengdur tékki
cheque-operations-none-linked = Engin færsla er tengd þessum tékka.
cheque-operations-none = Þessi reikningur inniheldur enga færslu.
cheque-operations-nothing-to-show = Engin færsla svarar þessari leit.
cheque-operations-help = Feitletruðu færslurnar bera þegar tékka.
cheque-operations-linked-help = Rauði krossinn losar tékkann frá færslunni: engu er eytt.
cheque-operations-linked = Færsla tengd tékkanum.
cheque-operations-dissociated = Tékki losaður frá færslunni.
cheque-operations-menu-filter = Sía
cheque-title-associate = Tengja þessa færslu við tékkann
cheque-title-dissociate = Losa tékkann frá þessari færslu

# Borðinn „Tékki tengdur færslunni“ á færsluspjaldinu, og tveir áfangar
# tékkaveiðanna — heftið, síðan tékkinn.
chequebooks-select-question = Veldu tékkheftið
cheques-select-question = Veldu tékkann sem á að tengja við færsluna
operation-check-save-first = Vistaðu færsluna fyrst: tékki tengist færslu sem er til.
operation-check-none = Þessi færsla ber engan tékka.

# --- F36 / F37 — Færslusniðmátin (áfangi 10) ---------------------------
# Sniðmát er tilbúinn innsláttur: það er notað til að þurfa ekki að slá allt
# inn aftur, og það **skrifar yfir** það sem er á spjaldinu. Ekkert fer á
# diskinn fyrr en færsluspjaldið er staðfest (regla Fabrice, 29/07/2026).

window-operation-templates-title = Listi yfir færslusniðmát
window-operation-template-title = Spjald færslusniðmáts

operation-templates-none = Ekkert færslusniðmát er skráð.
operation-templates-nothing-to-show = Ekkert sniðmát svarar þessari leit.
operation-templates-select-question = Veldu sniðmátið sem á að nota
operation-templates-delete-question = Staðfestir þú eyðingu völdu sniðmátanna?
operation-templates-deleted = { $count ->
    [one] { $count } sniðmáti eytt.
   *[other] { $count } sniðmátum eytt.
}
operation-template-gone = Þetta sniðmát er ekki lengur til.
operation-template-fresh = Nýtt sniðmát.
operation-template-created = Sniðmát vistað.
operation-template-updated = Sniðmáti breytt.
operation-template-label-required = Skylt er að slá inn nafn
operation-template-duplicate = Sniðmát með sama nafni er þegar til

# Spjaldið F36, hluta fyrir hluta — nákvæm heiti hans.
operation-template-field-id = Auðkenni færslusniðmáts
operation-template-group-name = Sjálfgefið nafn framtíðarfærslunnar eftir að sniðmátið hefur verið notað
operation-template-field-label = Nafn
operation-template-group-amount = Sjálfgefin upphæð færslunnar, fyrirfram skilgreind í þessu sniðmáti
operation-template-field-direction = Tegund færslu
operation-template-field-amount = Upphæð
operation-template-group-status = Sjálfgefin staða færslunnar í þessu sniðmáti
operation-template-field-status = Staða færslu
operation-template-group-classification = Upplýsingar sniðmátsins til flokkunar og útreiknings tölfræði
operation-template-field-category = Flokkur
operation-template-field-assignment = Úthlutun
operation-template-field-mode = Máti
operation-template-field-payee = Mótaðili
operation-template-field-project = Verkefni

# Hnappurinn „Sniðmát“ á færsluspjaldinu: eitt tákn, tvær aðgerðir.
operation-template-question = Hvað viltu gera við færslusniðmátin?
operation-template-apply = Nota sniðmát
operation-template-save-as = Vista sem sniðmát
operation-template-applied = Sniðmát notað. Staðfestu spjaldið til að vista það.
operation-template-saved-as = Færsla vistuð sem sniðmát.
operation-template-needs-label = Gefðu færslunni nafn áður en þú býrð til sniðmát úr henni.

# --- F26 / F27 — Fjárhagsáætlunin (áfangi 11) --------------------------
# Tvennar dyr, tvær spurningar: annaðhvort slærðu inn fjárhagsáætlun þína eða
# þú athugar hvort hún hafi staðist. Ásinn er fjárhagsliðurinn, einingin er
# árið, og formerkjareglan er sú sama og hjá færslunum — útgjöld eru
# skrifuð neikvæð.

window-budget-entry-title = Innsláttur fjárhagsáætlunar: áætluð útgjöld(-) og tekjur(+) á einu ári
window-budget-control-title = Eftirlit með fjárhagsáætlun

budget-column-line = Fjárhagsliður
budget-none = Enginn fjárhagsliður er skráður: fjárhagsáætlunin er slegin inn eftir liðum.
budget-planned = Áætlað
budget-actual = Raunverulegt
budget-sum = Summa
budget-cumulative = Uppsafnað
budget-total = Samtals
# Áminningin um formerkjaregluna, í rauðu undir innsláttartöflunni.
# Setningin hans, orð fyrir orð og með bilunum líka (skjámyndin „POINT 004
# saisie budget.png“): hún er í rauðu undir töflunni, og titill gluggans
# endurtekur hana í styttri mynd. Enginn myndi geta sér regluna til án hennar.
budget-sign-warning = Sláðu skilyrðislaust inn útgjöldin  með neikvæðu formerki og áætlaðar tekjur með jákvæðum upphæðum
budget-entry-help = Sláðu upphæðirnar inn í reitina og vistaðu síðan.
budget-saved = Fjárhagsáætlun vistuð.
budget-nothing-changed = Engar breytingar til að vista.
budget-discard-question = Hætta við breytingarnar á fjárhagsáætluninni?

# Birtingarvalmynd eftirlitsins: tvær leiðir til að lesa sama frávikið.
budget-menu-display = Birting
budget-display-money = Gildi
budget-display-percent = Prósentur
budget-control-help = Grænt: að minnsta kosti jafn gott og áætlað var. Rautt: verra.

# --- F09 — Millifærsla upphæðar milli tveggja reikninga (áfangi 12) -----
# Millifærsla er ekki ein færsla, hún er tvær: debet á upprunareikninginn,
# kredit á áfangareikninginn. Þær fara saman eða alls ekki.

window-transfer-title = Millifæra upphæð milli tveggja reikninga

transfer-group-source = Debetfæra upphæðina á þennan upprunareikning
transfer-group-target = Kreditfæra upphæðina á þennan áfangareikning
transfer-group-description = Lýsing færslunnar
transfer-group-nomenclature = Upplýsingar úr grunngögnum
transfer-group-amount = Upphæð fjárhæðarinnar sem á að millifæra
transfer-field-source = Upprunareikningur
transfer-field-target = Áfangareikningur
transfer-field-label = Lýsing
transfer-field-reference = Greiðslutilvísun
transfer-field-date = Dagsetning
transfer-field-status = Staða færslu
transfer-field-clearing = Afstemmingardagsetning
transfer-field-category = Flokkur
transfer-field-mode = Greiðslumáti
transfer-field-assignment = Úthlutun
transfer-field-payee = Mótaðilar / seljendur
transfer-field-project = Verkefni
transfer-field-amount = Upphæð

# Eini hnappurinn á spjöldunum sem tilkynna í stað þess að spyrja.
ui-ok = OK
transfer-help = Veldu reikningana tvo: staða þeirra birtist hér.
transfer-title-validate = Framkvæma millifærsluna
# Stöðurnar þrjár á valda reikningnum, til að vita hvað millifærslan hefur í för með sér.
transfer-balances = { $account } — Bankastaða: { $bank } · Raunstaða: { $real } · Lokastaða: { $final }
# Spjaldið sem dregur saman það sem nýbúið er að skrifa.
transfer-done = Millifærsla framkvæmd. { $amount } af reikningnum { $source } yfir á reikninginn { $target }, þann { $date }.

transfer-refusal-accounts-required = Veldu upprunareikning og áfangareikning
transfer-refusal-same-account = Upprunareikningurinn og áfangareikningurinn geta ekki verið sá sami: millifærsla fer af einum reikningi yfir á annan
transfer-refusal-account-gone = Annar reikninganna tveggja er ekki lengur til
transfer-refusal-label-required = Lýsingin er skylda
transfer-refusal-date-required = Dagsetningin er skylda
transfer-refusal-amount = Upphæðin sem á að millifæra verður að vera strangt jákvæð

# ---------------------------------------------------------------------------
# Áfangi 13 — innflutningur á Excel-blaði (F34, F35, tenging).
# ---------------------------------------------------------------------------

window-excel-import-title = Innflutningur á excel-blaði [ Skref 1/3 ]: skilgreining á upptökusvæðinu
window-excel-fields-title = Innflutningur á excel-blaði [ Skref 2/3 ]: tenging reitanna
window-excel-association-title = Innflutningur á excel-blaði: tenging gagnanna

# Spurningin sem spurð er við opnun. Excel-skrá er búin til í höndunum:
# hún inniheldur það sem hún inniheldur, og hluti af öllu ruglinu sem hún ber
# er ógreinanlegur. Því bjóðum við netið áður en stokkið er.
excel-backup-question = Excel-blað er búið til í höndunum: það getur innihaldið dagsetningar sem eru gildar en rangar, upphæðir á réttu sniði en með röngu formerki — og það getur ekkert eftirlit séð. Innflutningurinn skrifar þessar línur inn á reikninginn þinn. Viltu taka öryggisafrit af gögnunum þínum áður en þú byrjar?
excel-backup-later = Öryggisafritun er ekki enn tengd í þessari útgáfu af Radinus 2. Á meðan skaltu loka Radinus og afrita gagnagrunnsskrána þína sjálfur: þá geturðu flutt inn án þess að hætta á neitt.

excel-group-file = 1 - Veldu Excel-skrána sem á að flytja inn
excel-pick = Velja Excel-skrána
excel-sheet = Blað í vinnubókinni:
excel-group-header = 2 - Skilgreindu: Reitastaðsetningu fyrir hauslínu töflunnar þar sem heiti dálkanna eru skrifuð.
excel-header-row = Númer 1. línu þar sem heiti dálkanna standa
excel-first-column = Upphafsdálkur hauss ( dálkurinn lengst til vinstri ):
excel-column-count = Fjöldi dálka í töflunni
excel-group-rows = 3 - Skilgreindu: Línunúmer upphafs og enda listans sem inniheldur gögn töflunnar ( fyrir neðan hausinn og án hans )
excel-first-data-row = Fyrsta lína sem inniheldur gögn
excel-last-data-row = Síðasta lína sem inniheldur gögn:
excel-group-shape = 4 - Skilgreindu: Hvernig skráin þín skrifar upphæðirnar
excel-shape-single = Aðeins einn dálkur með upphæðum, með formerki ( útgjöldin neikvæð )
excel-shape-debit-credit = Tveir aðskildir dálkar: Debet-dálkur og Kredit-dálkur
excel-shape-note = Í tveggja dálka hamnum er ekki tekið tillit til formerkisins sem skrifað er í Debet-dálkinn: debet tekur alltaf peninga út, hvort sem það er skráð „-50“ eða „50“.
excel-group-test = 5 - Prufuskoðun: Skoðaðu upptökuna sem gerð var samkvæmt stillingunum þínum
excel-test = Prófaðu stillingarnar sem þú skilgreindir í skrefum 2, 3 og 4.
excel-test-note = Ábending: Heiti hausanna og innihald töflunnar hér að neðan verða að samsvara þeim í Excel-töflunni þinni. Upptökusvæðið má ekki ná út fyrir svæði töflunnar.

excel-help = Farðu í gegnum hópana fimm í réttri röð og prófaðu síðan: þú kemst ekki í skref 2 fyrr en þú hefur skoðað hvað svæðið grípur.
excel-no-file = Veldu fyrst Excel-skrána sem á að flytja inn.
excel-not-tested = Stillingum breytt: keyrðu prufuskoðunina aftur áður en þú staðfestir.
excel-tested = Svæði tekið upp: { $rows } línur, { $columns } dálkar. Athugaðu að taflan hér að neðan líkist blaðinu þínu.
excel-empty-capture = Svæðið sem þú skilgreindir grípur enga línu: athugaðu línu- og dálknúmerin.
excel-title-next = Fara í næsta skref
excel-into-account = Innflutningur inn á reikninginn { $account }.

excel-tab-links = Tengingar milli reita
excel-tab-settings = Innflutningsstillingar
excel-column-excel = Haus_Excel
excel-column-radinus = Reitur_Radinus
excel-links-help = Á móti hverjum dálki í blaðinu þínu skaltu segja hvaða reit í Radinus hann fyllir. Dálkar sem skildir eru eftir á [IGNORE] eru ekki fluttir inn.
excel-group-category = Flokkar án samsvörunar
excel-group-payment-mode = Greiðslumáti án samsvörunar
excel-group-assignment = Úthlutun án samsvörunar
excel-policy-create = { $kind ->
    [payment-mode] Búa sjálfkrafa til greiðslumáta sem ekki eru til
    [assignment] Búa sjálfkrafa til úthlutanir sem ekki eru til
   *[category] Búa sjálfkrafa til flokka sem ekki eru til
}
excel-policy-ask = { $kind ->
    [payment-mode] Spyrja fyrir hvern greiðslumáta sem ekki er til hvert eigi að flytja gögnin
    [assignment] Spyrja fyrir hverja úthlutun sem ekki er til hvert eigi að flytja gögnin
   *[category] Spyrja fyrir hvern flokk sem ekki er til hvert eigi að flytja gögnin
}
excel-policy-blank = { $kind ->
    [payment-mode] Skilja greiðslumátann eftir auðan
    [assignment] Skilja úthlutunina eftir auða
   *[category] Skilja flokkinn eftir auðan
}
excel-policy-default = { $kind ->
    [payment-mode] Flytja greiðslumáta sem ekki eru til í sjálfgefinn greiðslumáta
    [assignment] Flytja úthlutanir sem ekki eru til í sjálfgefna úthlutun
   *[category] Flytja flokka sem ekki eru til í sjálfgefinn flokk
}
excel-define-destination = Skilgreina áfangastað
excel-not-linked = { $kind ->
    [payment-mode] Enginn dálkur fyllir greiðslumátann: þessi stilling á ekki við.
    [assignment] Enginn dálkur fyllir úthlutunina: þessi stilling á ekki við.
   *[category] Enginn dálkur fyllir flokkinn: þessi stilling á ekki við.
}
excel-fields-help = Stilltu samsvaranirnar og síðan reglurnar þrjár áður en þú ræsir innflutninginn.
excel-title-import = Ræsa innflutninginn

excel-refusal-required = Reitirnir Dagsetning, Lýsing og Upphæð verða skilyrðislaust að vísa á excel-dálka
excel-refusal-column-twice = Ólíkir Radinus-reitir vísa á sama excel-dálkinn: dálkur getur aðeins fyllt einn reit
excel-refusal-field-twice = Sami Radinus-reitur er tengdur tveimur excel-dálkum: hann getur aðeins haft einn
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Þú valdir að láta spyrja hvert eigi að flytja óþekkta greiðslumáta: ýttu á „Skilgreina áfangastað“ áður en þú ræsir innflutninginn.
    [assignment] Þú valdir að láta spyrja hvert eigi að flytja óþekktar úthlutanir: ýttu á „Skilgreina áfangastað“ áður en þú ræsir innflutninginn.
   *[category] Þú valdir að láta spyrja hvert eigi að flytja óþekkta flokka: ýttu á „Skilgreina áfangastað“ áður en þú ræsir innflutninginn.
}

excel-column-data = Gögn_Excel
excel-column-destination = { $kind ->
    [payment-mode] Greiðslumáti_Radinus
    [assignment] Úthlutun_Radinus
   *[category] Flokkur_Radinus
}
excel-association-help = Á móti hverju gildi sem kemur úr blaðinu þínu skaltu velja það gildi í Radinus sem það á að raðast undir. Lína sem skilin er eftir auð verður án flokkunar.
excel-association-none = Ekkert óþekkt gildi: allt sem blaðið þitt ber er þegar til í Radinus.

excel-imported = Innflutningi lokið: { $count } færslur skrifaðar, { $refused } línum hafnað, { $created } grunngagnagildi búin til.
excel-report-title = Skýrsla um innflutninginn
excel-column-row = Excel-lína
excel-column-content = Innihald
excel-column-reason = Ástæða höfnunar
excel-nothing-refused = Allar línur blaðsins þíns komust inn: engri hafnað.

excel-refused-date = Dagsetningu vantar eða hún er ólæsileg
excel-refused-amount = Upphæð vantar eða hún er ólæsileg
excel-refused-amount-both = Ein upphæð í Debet-dálknum og önnur í Kredit-dálknum: ómögulegt að velja
excel-refused-amount-missing = Hvorki debet né kredit á þessari línu

# ---------------------------------------------------------------------------
# Áfangi 16 — endurteknu færslurnar (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Listi yfir endurteknar færslur
window-recurring-form-title = Spjald sem skilgreinir regluna um myndun endurtekinnar færslu
window-recurring-calendar-title = Tillaga að dagatali yfir færslur sem á að setja inn á bankareikningana þína

recurring-column-label = LÝSING
recurring-none = Engin endurtekin regla vistuð.
recurring-help = Veldu reglu og síðan dagatalið til að sjá gjalddagana sem hún leggur til.
recurring-title-calendar = Leggja til dagatal gjalddaga
recurring-deleted = { $count ->
    [0] Engri reglu eytt.
    [one] { $count } reglu eytt. Færslur hennar verða áfram á reikningnum.
   *[other] { $count } reglum eytt. Færslur þeirra verða áfram á reikningunum.
}
recurring-gone = Þessi regla er ekki lengur til.
recurring-delete-question = Eyða völdum reglum? Færslurnar sem þær hafa þegar sett inn verða áfram á reikningunum þínum.

recurring-group-identity = Auðkenning og viðkomandi bankareikningur
recurring-group-nomenclature = Grunngögn
recurring-group-amount = Skilgreining á upphæð færslunnar
recurring-group-period = Skilgreining á tímabilinu
recurring-group-ending = Skilyrði fyrir lok tímabilsins
recurring-group-produced = Upplýsingar um færslur sem þegar hafa verið settar inn ( aðeins til skoðunar )

recurring-field-id = Auðkenni færslu
recurring-field-account = Markreikningur
recurring-field-label = Lýsing
recurring-field-category = Flokkur
recurring-field-mode = Greiðslumáti
recurring-field-assignment = Úthlutun
recurring-field-payee = Mótaðili / söluaðilar
recurring-field-project = Verkefni
recurring-field-direction = Tegund færslu
recurring-field-amount = Upphæð
recurring-field-next = Dagsetning næstu færslu
recurring-field-every = Síðan á hverjum
recurring-field-end-date = Lokadagsetning
recurring-field-repeat = Fjöldi endurtekninga
recurring-field-guid = GUID færslu
recurring-field-produced-count = Fjöldi innsettra færslna
recurring-field-produced-last = Dagsetning síðustu innsettu færslu
recurring-field-produced-total = Samtala mynduðra upphæða

recurring-unit-day = Dagur
recurring-unit-week = Vika
recurring-unit-month = Mánuður
recurring-unit-quarter = Ársfjórðungur
recurring-unit-year = Ár
recurring-ending-no-limit = Án takmarkana
recurring-ending-until-date = Með lokadagsetningu
recurring-ending-repeat-count = Fjöldi endurtekninga

recurring-title-erase = Eyða færslunum sem þessi regla hefur þegar sett inn
recurring-erase-question = { $count ->
    [one] Þessi regla hefur sett { $count } færslu inn á reikningana þína. Viltu eyða henni? Stöðurnar verða endurreiknaðar og reglan færist ekki til baka.
   *[other] Þessi regla hefur sett { $count } færslur inn á reikningana þína. Viltu eyða þeim öllum? Stöðurnar verða endurreiknaðar og reglan færist ekki til baka.
}
recurring-erase-none = Þessi regla hefur ekki enn sett inn neina færslu.
recurring-erased = { $count ->
    [0] Engri færslu eytt.
    [one] { $count } færslu eytt, stöður endurreiknaðar.
   *[other] { $count } færslum eytt, stöður endurreiknaðar.
}

recurring-calendar-help = Fjarlægðu með ruslakörfunni þá gjalddaga sem þú vilt ekki og staðfestu síðan til að setja þá inn.
recurring-calendar-none = Enginn gjalddagi til að leggja til: athugaðu dagsetningu næstu færslu og reikninginn í reglunum þínum.
recurring-calendar-column-account = Reikningur
recurring-calendar-column-date = Dagsetning
recurring-calendar-column-label = Lýsing
recurring-calendar-column-amount = Upphæð
recurring-calendar-column-category = Flokkur
recurring-calendar-column-assignment = Úthlutun
recurring-calendar-column-mode = Greiðslumáti
recurring-calendar-column-payee = Mótaðili
recurring-calendar-column-project = Verkefni
recurring-calendar-removed = { $count ->
    [one] { $count } gjalddagi fjarlægður úr tillögunni.
   *[other] { $count } gjalddagar fjarlægðir úr tillögunni.
}
recurring-title-insert = Setja valda gjalddaga inn á reikningana
recurring-nothing = Enginn gjalddagi er eftir til að setja inn.
# Spurningin sem spurð er áður en skrifað er: að setja inn dagatal býr til alvöru
# færslur á alvöru reikningum, og það gerist ekki með annars hugar smelli.
recurring-insert-question = { $count ->
    [one] Setja { $count } gjalddaga inn á reikninginn þinn? { $count } færsla verður búin til og stöðurnar endurreiknaðar.
   *[other] Setja þessa { $count } gjalddaga inn á reikningana þína? Jafnmargar færslur verða búnar til og stöðurnar endurreiknaðar.
}
recurring-inserted = { $count ->
    [one] { $count } færsla sett inn. Reglan heldur áfram eftir síðasta innsetta gjalddagann.
   *[other] { $count } færslur settar inn. Reglurnar halda áfram eftir síðasta innsetta gjalddaga sinn.
}

recurring-refusal-label-required = Skylt er að slá inn lýsingu
recurring-refusal-date-required = Skylt er að slá inn dagsetningu næstu færslu
recurring-refusal-date-too-old = Dagsetning næstu færslu verður að vera árið 2000 eða síðar
recurring-refusal-account-gone = Tilgreindi bankareikningurinn finnst ekki, veldu nýjan svo reglan verði nothæf
recurring-refusal-end-required = Ef lokadagsetning er valin verður að slá dagsetninguna inn
recurring-refusal-end-before-start = Lokadagsetningin má ekki vera fyrr en dagsetning næstu færslu
recurring-refusal-end-too-far = Bilið milli dagsetningar næstu færslu og lokadagsetningar má ekki fara yfir 10 000 daga

# --- Áfangi 15 — útprentanir og skýrslur --------------------------------
# Stóri titillinn á borðanum, tekinn orðrétt úr upprunalegu WinDev-skýrslunni.
print-operations-title = Listi yfir bankafærslur og undirfærslur
print-menu-operations-pdf = Prentun í PDF-skrá
print-recap-title = Yfirlit eftir flokkum
print-recap-count = Línur
print-row-count = Fjöldi lína:
print-total-debit = Debet samtals:
print-total-credit = Kredit samtals:
print-final-balance = Lokastaða:
print-licence = Radinus er frjáls hugbúnaður sem dreift er samkvæmt GNU GPL v3 eða síðari útgáfu
print-nothing = Það er ekkert til að prenta.
print-done = Skýrsla prentuð og opnuð: „{ $file }“.
print-failed = Prentun ekki möguleg: { $reason }
# PDF-skráin er rétt skrifuð, en kerfið kunni ekki að opna hana: við segjum það
# án þess að láta líta út fyrir að þetta hafi mistekist, því skráin er til.
print-not-opened = Skýrsla prentuð í „{ $file }“, en kerfið þitt kunni ekki að opna hana sjálft.

# --- RIB-skýrslan (F32) ------------------------------------------------
# Heitin á bankareikningsupplýsingunum, tekin úr upprunalega skjalinu.
rib-title = BANKAREIKNINGSUPPLÝSINGAR
rib-bank = Banki:
rib-national = RIB - Innlent auðkenni reiknings
rib-establishment = BANKASTOFNUN
rib-branch = ÚTIBÚ
rib-number = REIKNINGSNÚMER
rib-key = RIB-EFTIRLITSTALA
rib-domiciliation = VIÐSKIPTAÚTIBÚ
rib-iban = IBAN - Alþjóðlegt auðkenni reiknings
rib-bic = BIC - Alþjóðlegt auðkenni bankastofnunarinnar
rib-holder = Reikningseigandi

# --- Glugginn F32 ------------------------------------------------------
window-rib-title = Prentun á RIB ( Relevé d'Identité Bancaire )
rib-group-bank = Banki
rib-group-holder = Reikningseigandi
rib-group-details = Bankaupplýsingar
rib-field-bank = Nafn banka
rib-field-domiciliation = Viðskiptaútibú
rib-field-holder = Nafn eiganda
rib-field-address = Heimilisfang
rib-field-establishment = Bankastofnun
rib-field-branch = Útibú
rib-field-number = Reikningsnúmer
rib-field-key = RIB-eftirlitstala
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Mikilvæg notkunarskilyrði sem skylt er að virða við prentun
rib-declaration = Ég undirritaður, notandi hugbúnaðarins, lýsi því yfir á æru og samvisku:
rib-declaration-first = - Staðfesti að ég hafi gengið úr skugga um það hjá banka mínum að bankaupplýsingarnar í þessum glugga séu réttar og í samræmi við vilja minn . Staðfesti á sama hátt að ég skuldbind mig til að ganga úr skugga um að upplýsingarnar í prentuðu RIB-skýrslunni séu réttar og í samræmi við vilja minn. Þessi prentun og notkun RIB fer fram á minni fullu ábyrgð
rib-declaration-second = - Að vera eigandi reikningsins sem RIB verður prentað fyrir, og að nota ekki aðgerðir þessa hugbúnaðar í tilgangi sem stríðir gegn lögum.
rib-title-print = Prentun á prentara
rib-title-pdf = Prentun í PDF-skrá
# Reiturinn er ekki skrautleg viðvörun: á meðan ekki er hakað við hann eru
# hnapparnir tveir óvirkir (ákvörðun Fabrice, 01/08/2026).
rib-declaration-required = Hakaðu við drengskaparyfirlýsinguna til að geta prentað.
rib-help = Athugaðu upplýsingarnar þínar, hakaðu við yfirlýsinguna og prentaðu síðan.
rib-account-gone = Þessi bankareikningur finnst ekki.
rib-fields-read-only = Þessar upplýsingar koma af reikningsspjaldinu: leiðréttu þær á spjaldinu til að breyta þeim hér.
rib-printed = RIB sent á sjálfgefna prentarann þinn.
rib-print-failed = Prentun ekki möguleg: { $reason }
rib-pdf-done = RIB prentað og opnað: „{ $file }“.
rib-pdf-not-opened = RIB prentað í „{ $file }“, en kerfið þitt kunni ekki að opna það sjálft.
menu-accounts-bank-details = Gefa út bankareikningsupplýsingar (RIB)

# Val á prentara. Radinus spyr sjálfur: enginn af vefsýnunum þremur opnar
# prentgluggann í kerfinu.
print-choose-printer = Á hvaða prentara viltu prenta?
print-do-print = Prenta
rib-printed-on = RIB sent á prentarann „{ $printer }“.
ui-cancel = Hætta við

# Kerfið kunni ekki að nefna neinn prentara: við prentum samt á sjálfgefna
# prentarann frekar en að stöðva notandann.
print-printers-unknown = Kerfið þitt kunni ekki að nefna neinn prentara: skjalið fór á sjálfgefna prentarann.

print-menu-operations-printer = Prentun á prentara
print-sent-on = Skýrsla send á prentarann „{ $printer }“.
print-sent-default = Skýrsla send á sjálfgefna prentarann þinn.

# --- Áfangi 17 — aðgerðirnar á gagnagrunninum ---------------------------
backup-archive = Radinus-safnskrá
backup-no-database = Enginn gagnagrunnur er opinn.
backup-done = Öryggisafrit skrifað í „{ $file }“.
backup-failed = Öryggisafritun ekki möguleg: { $reason }
restore-unreadable = Þessi skrá er ekki læsileg Radinus-safnskrá: { $reason }
# Spurningin segir hverju verður glatað áður en því er glatað. Safnskráin hefur
# þegar verið lesin á þessari stundu: það sem hún boðar er öruggt.
restore-question = Endurheimta „{ $file }“? Öllu núverandi innihaldi gagnagrunnsins þíns verður eytt og skipt út, og það sem þar er glatast.
restore-done = Endurheimt lokið: { $accounts } reikningar og { $operations } færslur.
restore-failed = Endurheimt ekki möguleg: { $reason }


# --- Dagbók tæknilegu aðgerðanna (áfangi 17) ----------------------------
# Stöðurnar þrjár í Ajoute_Log hans, með hástöfum eins og hjá honum.
journal-status-success = TÓKST
journal-status-failure = MISTÓKST
journal-status-repaired = LAGFÆRT
journal-step-reindex = Viðgerð á töflu gagnagrunns
journal-step-refill = Kerfisgrunngögn tóm: sjálfgefin gildi endurheimt
journal-step-table-created = Tafla vantar í gagnagrunninn: endurgerð tóm
journal-step-column-added = Dálk vantar í töfluna: bætt við með sjálfgefnu gildi sínu

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Lykilorðsvernd
window-password-form-title = Lykilorðsvernd
password-ask = Þessi gagnagrunnur er varinn. Sláðu inn lykilorðið.
password-group-database = Viðkomandi gagnagrunnur
password-group-password = Lykilorð
password-group-warning = Áður en þú staðfestir
password-field-old = Gamalt lykilorð
password-field-new = Nýtt lykilorð
password-field-repeat = Endurtaktu nýja lykilorðið
password-hint = Skildu það gamla eftir autt ef gagnagrunnurinn er ekki þegar varinn. Skildu bæði nýju eftir auð til að fjarlægja vörnina.
password-lost-warning = Týnt lykilorð er týndur gagnagrunnur: ekkert getur endurheimt hann. Öryggisafritin haldast hins vegar ódulkóðuð.
password-show = Sýna lykilorðið
password-remove-question = Fjarlægja vörnina af þessum gagnagrunni?
password-mismatch = Innslættirnir tveir á nýja lykilorðinu eru ólíkir
password-wrong = Lykilorðið gengur ekki
password-close-first = Lokaðu þessum gagnagrunni áður en þú breytir lykilorðinu
password-now-protected = Gagnagrunnurinn er varinn með lykilorði
password-now-clear = Gagnagrunnurinn er ekki lengur varinn
journal-step-date-fixed = Leiðrétting á færslu án dagsetningar
journal-step-circular = Eyðing á ósamkvæmri færslu: hringtilvísun
journal-step-flag-parent-true = Rangt flagg EstParent=Faux á aðalfærslu
journal-step-flag-parent-false = Rangt flagg EstParent=Vrai á aðalfærslu
journal-step-flag-child = Rangt flagg EstParent=Vrai á undirfærslu
journal-step-orphan = Eyðing á munaðarlausri undirfærslu
journal-step-third-level = Eyðing á undirfærslu sem tengd er annarri undirfærslu
journal-step-coherence = Almennur endurútreikningur á samræmi milli undirfærslna og aðalfærslna
journal-step-balances = Endurútreikningur á allri stöðu allra reikninga
journal-step-vacuum = Bestun á gagnagrunnsskránni
journal-step-analyze = Uppfærsla á leitartölfræði
journal-step-backup-begin = Upphaf öryggisafritunar gagnagrunnsins
journal-step-backup-end = Lok öryggisafritunar gagnagrunnsins
journal-step-restore-begin = Upphaf endurheimtar gagnagrunnsins úr safnskránni
journal-step-restore-end = Lok endurheimtar gagnagrunnsins úr safnskránni
journal-step-restore-read = Lestur safnskrárinnar

# --- Dagbókarglugginn (⌘H) ----------------------------------------------
window-journal-title = Dagbók síðustu tæknilegu aðgerðar
journal-column-step = Skref
journal-column-file = Skrá
journal-column-table = Tafla
journal-column-status = Staða
journal-column-error = Villa
journal-column-comments = Athugasemdir
journal-empty = Engin tæknileg aðgerð hefur enn verið framkvæmd frá því að hugbúnaðurinn var opnaður.
journal-help = Dagbókin geymir aðeins síðustu tæknilegu aðgerð: öryggisafritun, endurheimt, viðgerð, eyðingu eða opnun gagnagrunns.

# --- Viðgerðin ----------------------------------------------------------
menu-file-repair-running = Viðgerð og bestun í gangi…
repair-done = { $anomalies ->
    [0] Viðgerð lokið: engin frávik fundust. { $lines } skref skráð.
    [one] Viðgerð lokið: { $anomalies } frávik lagfært. { $lines } skref skráð.
   *[other] Viðgerð lokið: { $anomalies } frávik lagfærð. { $lines } skref skráð.
}
repair-failed = Viðgerð ekki möguleg: { $reason }

journal-status-started = Í GANGI
journal-status-finished = LOKIÐ
journal-step-backup-table = Skrifun töflunnar í safnskrána
journal-step-backup-write = Skrifun safnskrárinnar
journal-step-backup-verified = Sannprófun á skrifaðri safnskrá: skrár endurlesnar / væntanlegar, skráningar endurlesnar / skrifaðar
journal-step-backup-total = Samtals afritað: skráningar, gögn, stærð skrár
journal-step-restore-table = Lestur töflunnar úr safnskránni
journal-step-restore-missing = Skrá vantar í safnskrána: þessi tafla verður ekki endurheimt
journal-step-restore-wipe = Algjör eyðing á innihaldi gagnagrunnsins fyrir endurheimt
journal-step-restore-write = Skrifun í gagnagrunninn
journal-step-restore-total = Samtals endurheimt: reikningar, færslur
backup-verify-mismatch = Skrifaða safnskráin les sig ekki eins og hún var skrifuð: treystu henni ekki, taktu öryggisafritið aftur.

# --- Viðhengi færslu (F28, áfangi 17) -----------------------------------
window-attachments-title = Viðhengi færslunnar
attachment-filter = Samþykkt skjöl
attachment-none = Þessi færsla ber ekkert viðhengi.
attachment-title-add = Hengja skjal við þessa færslu
attachment-title-open = Opna viðhengið
attachment-title-remove = Fjarlægja viðhengið og senda skrá þess í ruslakörfuna
# Staða skrárinnar á disknum. „Óvíst“ er ekki tilefnislaus játning á vanþekkingu:
# fingraförin sem koma frá Radinus 1.9.3 eru limlest af sniði öryggisafritsins, og
# að dæma skrá út frá þeim jafngilti því að saka af handahófi.
attachment-state-ok = Óskert
attachment-state-changed = Breytt
attachment-state-missing = Skrá vantar
attachment-state-unknown = Ekki hægt að sannreyna
attachment-added = „{ $name }“ var hengt við færsluna.
attachment-removed = Viðhengið fjarlægt, skrá þess er í ruslakörfunni.
attachment-removed-kept = Viðhengið fjarlægt, en ekki tókst að setja skrá þess í ruslakörfuna.
attachment-remove-question = Fjarlægja „{ $name }“ úr þessari færslu? Skrá þess verður send í ruslakörfuna.
attachment-opened = „{ $name }“ var opnað.
attachment-opened-changed = „{ $name }“ var opnað, en innihald þess hefur breyst frá því að það var hengt við.
attachment-gone = Þetta viðhengi er ekki lengur til.
attachment-file-missing = Skrá „{ $name }“ finnst ekki á disknum.
attachment-failed = Aðgerð ekki möguleg: { $reason }
attachment-save-first = Vistaðu færsluna fyrst: viðhengi tengist færslu sem er til.
attachment-refusal-missing = Þessi skrá er ekki til.
attachment-refusal-extension = Þessi skráargerð er ekki samþykkt. Samþykktar eru: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Færslan sem hengja á þetta skjal við er ekki til.
journal-step-backup-attachments = Viðhengi bætt við safnskrána
journal-step-backup-attachment-missing = Viðhengi finnst ekki á disknum: það mun vanta í safnskrána
journal-step-restore-attachments = Viðhengi sótt úr safnskránni
attachment-title-replace = Skipta út skjali þessa viðhengis
attachment-replaced = Skjalinu var skipt út fyrir „{ $name }“.

# ---------------------------------------------------------------------
# F08 — valmyndin „Verkfæri“ á reikningsspjaldinu.
#
# Liðirnir þrír í henni eru yfirfærslur á WLangage-kóða Fabrice (mappan
# „Information import export base piece jointe“): útreikningur á afstemmdri
# upphafsstöðu, tölfræði reikningsins, og eyðing á öllum
# færslum hans. Valmyndin virkar aðeins í breytingaham (ákvörðun frá
# 02/08/2026): við stofnun er ekkert til að telja, í skoðunarham gerir
# spjaldið ekkert nema sýna.
# ---------------------------------------------------------------------

account-tools = Verkfæri
account-tools-initial-balance = Skilgreina afstemmda upphafsstöðu
account-tools-statistics = Tölfræði bankareiknings
account-tools-delete-operations = Eyða öllum færslum reikningsins

# Spurningin um útreikninginn, orðrétt eins og í frumgerðinni. { $total } er
# samtala afstemmdu færslnanna, þegar skrifuð á myntsniði.
account-initial-balance-question =
    Til að reikna afstemmda upphafsstöðu miðað við færslurnar sem eru á þessum reikningi, vinsamlegast sláðu inn núverandi stöðu í bankanum þínum
    Afstemmda upphafsstaðan verður reiknuð sem:
    { "[" }Núverandi bankastaða] - [Samtala afstemmdra færslna ({ $total }) ].
    { "" }
    Til að þurfa ekki að slá þetta gildi inn aftur verður listinn yfir bankafærslur á þessum reikningi að vera algjörlega uppfærður.

account-statistics-none = Engin færsla

# Línurnar fjórtán í Info() hans. Innsláttarvillan „pengagés“ í frumgerðinni
# er leiðrétt, samkvæmt ákvörðun Fabrice frá 02/08/2026 — eins og „Bank
# Identifer Code“ á þessu sama spjaldi.
account-statistics =
    Heildarfjöldi færslna á þessum reikningi: { $count }
    { "" }
    Fjöldi afstemmdra færslna á þessum reikningi: { $pointed }
    Upphæð afstemmdra debetfærslna: { $pointedDebits }
    Upphæð afstemmdra kreditfærslna: { $pointedCredits }
    Mismunur á afstemmdum kredit- og debetfærslum: { $pointedDifference }
    { "" }
    Fjöldi frátekinna færslna á þessum reikningi: { $committed }
    Upphæð frátekinna debetfærslna: { $committedDebits }
    Upphæð frátekinna kreditfærslna: { $committedCredits }
    Mismunur á fráteknum kredit- og debetfærslum: { $committedDifference }
    { "" }
    Fjöldi áætlaðra færslna á þessum reikningi: { $planned }
    Upphæð áætlaðra debetfærslna: { $plannedDebits }
    Upphæð áætlaðra kreditfærslna: { $plannedCredits }
    Mismunur á áætluðum kredit- og debetfærslum: { $plannedDifference }
    { "" }
    Elsta færsla: { $first }
    Yngsta færsla: { $last }

# Tvöfalda hindrunin við eyðingu. { $word } er „já“ á tungumáli notandans —
# spænskumælandi maður, sem beðinn væri um að skrifa OUI, myndi ekki skilja
# það (ákvörðun Fabrice, 02/08/2026).
account-delete-operations-question =
    Ertu viss um að þú viljir eyða öllum færslum sem eru á bankareikningnum?
    Til að staðfesta það skaltu skrifa { $word } í reitinn hér að neðan og staðfesta

account-delete-operations-done =
    { $count ->
        [0] Engri færslu eytt.
        [one] { $count } færslu eytt.
       *[other] { $count } færslum eytt.
    }

# ---------------------------------------------------------------------
# Gagnagrunnsveljarinn og val á tungumáli (02/08/2026)
#
# Ákvarðanir teknar í samtali við Fabrice: Radinus býr ekki lengur til
# gagnagrunn án leyfis; sé ekkert tungumál í stillingunum spyr hann um
# tungumálið á undan öllu öðru; gagnagrunnur er sérhver mappa í databases/
# sem inniheldur radinus.sqlite, hvað sem hún heitir.
#
# Glugginn fyrir val á tungumáli hefur engan lykil hér: hann notar enga
# setningu, og það er einmitt það sem gerir honum kleift að skiljast áður
# en menn vita hvaða tungumál notandinn talar.
# ---------------------------------------------------------------------

window-database-selector-title = Gagnagrunnar
window-database-form-title = Nýr gagnagrunnur
database-group-identity = Auðkenni gagnagrunnsins
database-group-restore = Frumstilla gagnagrunninn með gögnum úr afriti
database-choose-backup = Velja afritsskrá
database-no-backup = Ekkert afrit valið: gagnagrunnurinn verður tómur.

databases-column-label = Gagnagrunnur
databases-column-comment = Athugasemd
databases-column-folder = Mappa
databases-column-created = Stofnaður þann

databases-none = Enginn gagnagrunnur enn sem komið er: búðu einn til.
databases-help = Veldu gagnagrunninn sem þú vilt opna, eða búðu til nýjan.
databases-select = Veldu fyrst gagnagrunn í listanum.
databases-tools = Verkfæri
databases-title-open = Opna þennan gagnagrunn

database-created = Gagnagrunnurinn „{ $label }“ hefur verið búinn til.
database-field-label = Nafn gagnagrunnsins
database-field-comment = Athugasemd
database-label-required = Gefðu þessum gagnagrunni nafn: það er nafnið sem greinir hann frá hinum.
database-gone = Þessi gagnagrunnur er ekki lengur til staðar: hann hefur verið færður eða honum eytt eftir að þessi gluggi var opnaður.

# Eyðing gagnagrunns (02/08/2026). Mappan fer í ruslakörfu kerfisins, eins og
# viðhengin: gagnagrunni sem eytt er fyrir mistök má skila með hægrismelli.
# Opna gagnagrunninum er hafnað — Radinus heldur í skrána sína.
databases-title-delete = Eyða þessum gagnagrunni
database-delete-question =
    Ertu viss um að þú viljir eyða gagnagrunninum „{ $label }“?
    { "" }
    Öll mappan hans fer í ruslakörfuna: færslurnar, reikningarnir og viðhengin.
    Til að staðfesta það skaltu skrifa { $word } í reitinn hér að neðan og staðfesta.
database-in-use = Þessi gagnagrunnur er opinn: Radinus getur ekki eytt honum. Opnaðu annan fyrst.
database-deleted = Gagnagrunnurinn „{ $label }“ er kominn í ruslakörfuna.

# Veljarinn hefur tvo hætti (Fabrice, 02/08/2026). Sé hann opnaður meðan á
# notkun stendur kann hann ekki lengur að opna: Radinus-gluggi er byggður einu
# sinni og aldrei rifinn, og ekkert fær hann til að gleyma gagnagrunninum sem
# hann sýnir. Menn skoða, búa til, eyða — og til að skipta um gagnagrunn
# hætta menn.
database-quit-first = Til að opna þennan gagnagrunn skaltu loka Radinus og ræsa hann aftur: veljarinn býður þér hann við ræsingu.


# --- F01 — velkomstglugginn (áfangi 17 bis, 03/08/2026) ------------------
#
# Fyrsta viðbótin í 2.0.0 umfram 1.9.3: velkomstglugginn ber ekki lengur
# aðeins borðann. Reglan sem stýrir honum er skrifuð í skjali 04 F01: þetta er
# útsýnið ÁN EINS EINASTA SMELLS, og ekkert sem krefst stillingar kemst þar inn.
#
# Titlarnir tveir á hringritunum bera allan mánuðinn í stað þess að vera límdir
# saman enda á enda af glugganum: „Útgjöld ... — ágúst 2026“ hefur ekki sömu
# orðaröð á tungumálunum þremur, og aðeins Fluent veit hvar gatið er.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Enginn reikningur opinn
    [one] { $count } reikningur opinn
   *[other] { $count } reikningar opnir
}
welcome-total-bank = Bankastaða
welcome-total-real = Raunstaða
welcome-total-final = Lokastaða
welcome-total-real-detail = afstemmt + frátekið
welcome-total-final-detail = afstemmt + frátekið + áætlað
welcome-accounts = Reikningarnir þínir
welcome-tile-bank = Í banka
welcome-tile-real = Raunstaða
welcome-tile-final = Lokastaða
welcome-spending = Útgjöld — { $month }
welcome-earning = Tekjur — { $month }
ui-legend-budget-lines = Fjárhagsliðir
ui-legend-categories = Flokkar
welcome-nothing = Engin færsla í þessum mánuði.
welcome-open-account = Upplýsingar: smelltu á reikning til að opna færslur hans.
welcome-no-account = Enginn bankareikningur enn sem komið er.
welcome-no-account-create = Búðu til bankareikning með því að smella hér
welcome-previous-month = Fyrri mánuður
welcome-next-month = Næsti mánuður
welcome-refresh = Lesa allt aftur


# --- F39 — kjörstillingarnar (áfangi 17 ter, 03/08/2026) -----------------
#
# Staða myntmerkisins á heima hér, við hliðina á aðskiljendunum tveimur: hún
# fylgir tungumálinu en ekki gjaldmiðlinum. „before“ setur merkið á undan
# tölunni, sérhvert annað gildi setur það á eftir. EKKERT myntmerki er skrifað
# í þessa skrá: „íslenska“ þýðir ekki „króna“.

ui-money-sign-position = after
window-preferences-title = Kjörstillingar
menu-settings-preferences = Kjörstillingar…
menu-settings-show-main = Sýna aðalgluggann
preferences-branch-display = Birting
preferences-leaf-language = Tungumál
preferences-leaf-currency = Gjaldmiðill
preferences-field-language = Tungumál hugbúnaðarins:
preferences-field-currency = Gjaldmiðill sem birtist:
preferences-field-custom = Merki gjaldmiðilsins:
preferences-currency-system = Gjaldmiðill kerfisins
preferences-currency-euro = Evrur
preferences-currency-dollar = Dollarar
preferences-currency-canadian = Kanadadollarar
preferences-currency-cfa = CFA-frankar
preferences-currency-cfp = Kyrrahafsfrankar
preferences-currency-swiss = Svissneskir frankar
preferences-currency-none = Enginn
preferences-currency-custom = Sérsniðið
preferences-currency-system-is = Kerfið þitt tilkynnir:
preferences-currency-system-silent = Kerfið þitt tilkynnir engan gjaldmiðil: upphæðirnar birtast í evrum.
preferences-custom-required = Sláðu inn merki gjaldmiðilsins þíns áður en þú vistar.
preferences-saved = Kjörstillingar vistaðar.
preferences-help = Veldu valkost í trénu og vistaðu síðan.
preferences-sign-too-long = Merki gjaldmiðils rúmast í mest 8 stöfum.
preferences-sign-not-a-number = Merki gjaldmiðils má hvorki innihalda tölustaf, reiknimerki né kommu: Radinus fjarlægir þau þegar hann les upphæð, og „120“ yrði að „12“.
preferences-leaf-zoom = Stærð birtingar
preferences-field-zoom = Stækkun:
preferences-zoom-reset = Sjálfgefið gildi
preferences-zoom-hint = Allt stækkar saman: textinn, táknmyndirnar, dálkarnir. Undir 100 % kemst meira fyrir á skjánum. Valmyndastika kerfisins og valgluggar þess fylgja hins vegar stillingum tölvunnar þinnar en ekki þessum.

# --- Borðinn á velkomstsíðunni -------------------------------------------
#
# Þessar setningar voru harðkóðaðar í `index.html` allt frá áfanga 0 og
# þýddust því ekki (Fabrice benti á það 03/08/2026). Einkunnarorðin eru
# hans rödd: enska og spænska útgáfan eru tillögur sem hann verður sjálfur
# að leiðrétta — slagorð þýðist ekki orð fyrir orð.
ui-language-tag = is
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — íkorninn sem lukkudýr, í jakkafötum, umkringdur evru, reiknivél og gröfum
welcome-slogan-one = Hugbúnaður til að halda utan um einkafjármál sem hjálpar þér að eyða minna til að græða meira
welcome-slogan-two = Með Radinus muntu skilja hvers vegna margt smátt gerir eitt stórt.

# --- „Um höfundinn“ ------------------------------------------------------
#
# Nafnið og heimilisfangið eru skrifuð eins í öllum skránum þremur: þau
# þýðast ekki. Þau eru hér engu að síður, en ekki á síðunni, til þess að
# útsýnið beri enga setningu — og til þess að þau leiðréttist á einum einasta
# stað þann dag sem höfundurinn flytur.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Um höfundinn
about-author-flag-alt = Fáni Korsíku — márahöfuðið

# --- „Um Radinus“ --------------------------------------------------------
#
# `about-radinus-version` ber gat: númerið kemur úr keyrsluskránni sem er í
# gangi, aldrei úr afrituðum streng. Hún er því ekki í orðabók glugganna —
# það er skipunin `app_version` sem fyllir í hana.
window-about-radinus-title = Um Radinus
about-radinus-name = Radinus
about-radinus-version = Útgáfa { $version }
about-radinus-rust-alt = Táknmerki forritunarmálsins Rust
about-radinus-tauri-alt = Táknmerki Tauri
about-radinus-built = Radinus er skrifaður í Rust og byggður með Tauri. Hið fyrra reiknar reikningana þína, hið síðara gerir hann að skjáborðsforriti.
about-radinus-licence = Frjáls hugbúnaður, með GNU GPL v3-leyfi.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Notkunarleyfi
licence-logo-alt = Merki GNU General Public License útgáfu 3
licence-name = GNU GPL v3 eða síðari
licence-intro = Radinus er frjáls hugbúnaður.
licence-freedoms-title = Leyfið veitir þér fjögur frelsi:
licence-freedom-use = Að nota hann eins og þú vilt, í hvað sem þú vilt.
licence-freedom-study = Að skoða frumkóðann, sem er opinn öllum.
licence-freedom-share = Að afrita hann og gefa öðrum.
licence-freedom-improve = Að breyta honum og deila breytingunum.
licence-read = Lesa fullan texta leyfisins

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Þessi hugbúnaður er veittur án nokkurrar ábyrgðar, að því marki sem lög leyfa.
licence-info = Opinberi textinn opnast í vafranum þínum, á gnu.org.

