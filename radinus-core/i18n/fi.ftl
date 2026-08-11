# Radinus — core-puolen viestit (Fluent), suomi.
# Täydennetään sitä mukaa kuin käyttäjälle näkyviä viestejä tuottavat
# core-moduulit toteutetaan. Katso 08_ARCHITECTURE.md §2.1.

# Oletusarvo ”0 = Ei määritelty”, jota jokainen valinnainen perustietoviittaus
# käyttää (02_BASE_DE_DONNEES.md §7 sääntö 2). Näkyy jokaisen alasvetoluettelon
# ylimpänä.
# ---------------------------------------------------------------------
# Kielen nimi, kirjoitettuna omalla kielellään.
#
# Tämän näyttävät Asetukset-valikko ja ensimmäisen käynnistyksen kielivalinta
# (01_CAHIER_DES_CHARGES.md §3.5: ”jokainen kieli kirjoitettuna omalla
# kielellään”). Se on täällä eikä koodissa, koska tämä on ainoa paikka, jossa
# se voi olla oikein: kielen lisääminen on sellaisen tiedoston tuomista, joka
# osaa nimetä itsensä.
# ---------------------------------------------------------------------
language-name = Suomi

nomenclature-unspecified = Ei määritelty

# Kysytään ennen kuin poistetaan perustietoelementti, jota tapahtumat vielä
# käyttävät (02_BASE_DE_DONNEES.md §7 sääntö 5). Toistettu sanasta sanaan
# alkuperäisestä WinDev-lähteestä (Enreg_Supprimer), typografia mukaan lukien —
# sanamuoto on tekijän, ei käännös.
nomenclature-delete-confirm = Löytyi tapahtumia (pankkitapahtumia), joiden ominaisuuden tyyppi on '{ $label }'. Vahvistatko, että haluat nollata tämän ominaisuuden?

# Kysytään ennen kuin poistetaan perustietoelementti, jota mikään ei käytä.
# Alkuperäinen poisti sellaisen elementin suoraan, sanaakaan sanomatta; Fabrice
# pyysi 25/07/2026, että poisto vahvistetaan aina — tietoinen poikkeama hänen
# omasta koodistaan, ja tämän moduulin ainoa.
nomenclature-delete-plain = Vahvistatko, että ”{ $label }” poistetaan?

# Kieltäytyminen, joka näytetään, kun poistettava elementti on juuri se, jota
# sen kortti näyttää. Fabricen päätös 25/07/2026: elementtiä ei poisteta sen
# oman avoimen kortin alta — kortti suljetaan ensin, sen sijaan että se jäisi
# näyttämään tietuetta, jota ei enää ole.
nomenclature-delete-form-open = Kortti ”{ $label }” on auki. Sulje se ennen poistamista.

# Kieltäytyminen, joka näytetään, kun tallennettava kuvaus on jo jollakin
# toisella saman perustietoryhmän elementillä (tekijän päätös 25/07/2026: saman
# perustietoryhmän kaksi elementtiä eivät saa jakaa nimeä — tapahtuman
# luokitteleminen jommankumman kahdesta samanlaisesta kuvauksesta alle on
# kolikonheittoa). `element` on substantiivi omassa suvussaan, ”une catégorie”,
# ”un tiers”; `label` on olemassa oleva kuvaus sellaisena kuin se on
# tallennettu, jotta käyttäjä näkee, mikä on esteenä.
nomenclature-duplicate = Samanniminen { $element } on jo olemassa: ”{ $label }”.

# ---------------------------------------------------------------------
# Mitä ikkunat kertovat itsestään.
#
# Kaikki on täällä, myös se mikä riippuu näytettävistä perustiedoista: lauseet
# on kirjoitettu kokonaisina, kieli kerrallaan, sen sijaan että ne koottaisiin
# sanoista ja suvuista. Kokoonpano, joka on oikein ranskaksi, on väärin
# seuraavassa kielessä, ja lopulta koodi tietää, että on olemassa feminiini —
# se ei ole sen tehtävä (tekijän sääntö 25/07/2026: ”ohjelmisto toimii
# Fluentilla ranskaksi ja englanniksi heti alusta alkaen”).
# ---------------------------------------------------------------------

ui-loading = Ladataan…
ui-editing = Muokkaus.
ui-viewing = Katselu.
ui-modified-suffix = — muokattu
ui-label-required = Kuvaus on pakollinen.
ui-discard-question = Hylätäänkö muutokset?
ui-yes = Kyllä
ui-no = Ei
ui-select-record = Valitse tietue
ui-key-multiselect = CTRL
ui-multiselect-help = Vinkki: Valitse useita kohteita napsauttamalla taulukkoa hiirellä ja pitämällä [{ $modifier }]-näppäintä pohjassa
ui-no-match = Yksikään kuvaus ei vastaa suodatinta.
ui-filter-placeholder = Suodata kuvauksia…
ui-column-label = KUVAUS
ui-field-label = Kuvaus
ui-field-budget-line = Budjettikohta
ui-identifier = Tunniste
ui-deletion-abandoned = Poisto keskeytetty: mitään ei muutettu.
ui-unknown-nomenclature = Tuntemattomat perustiedot:

ui-title-filter = Suodata
ui-title-create = Luo
ui-title-update = Muokkaa valintaa
ui-title-delete = Poista valinta
ui-title-read = Näytä valinta
ui-title-close = Sulje
ui-title-save = Tallenna
ui-title-add = Lisää
ui-title-modify = Muokkaa

ui-load-failed = Lataaminen epäonnistui:
ui-save-failed = Tallennus epäonnistui:
ui-read-failed = Lukeminen epäonnistui:
ui-delete-failed = Poistaminen epäonnistui:
ui-open-failed = Avaaminen epäonnistui:
ui-close-failed = Sulkeminen epäonnistui:

# --- Kunkin perustietoryhmän omat lauseet ----------------------------

nomenclature-identifier = { $kind ->
    [category] Luokan tunniste
    [assignment] Kohdistuksen tunniste
    [payment-mode] Maksutavan tunniste
    [payee] Vastapuolen tunniste
    [project] Projektin tunniste
    [budget-line] Budjettikohdan tunniste
   *[bank] Pankin tunniste
}

nomenclature-none = { $kind ->
    [category] Ei luokkia.
    [assignment] Ei kohdistuksia.
    [payment-mode] Ei maksutapoja.
    [payee] Ei vastapuolia.
    [project] Ei projekteja.
    [budget-line] Ei budjettikohtia.
   *[bank] Ei pankkeja.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Ei näytettäviä luokkia.
    [assignment] Ei näytettäviä kohdistuksia.
    [payment-mode] Ei näytettäviä maksutapoja.
    [payee] Ei näytettäviä vastapuolia.
    [project] Ei näytettäviä projekteja.
    [budget-line] Ei näytettäviä budjettikohtia.
   *[bank] Ei näytettäviä pankkeja.
}

nomenclature-gone = { $kind ->
    [category] Tätä luokkaa ei ole enää olemassa.
    [assignment] Tätä kohdistusta ei ole enää olemassa.
    [payment-mode] Tätä maksutapaa ei ole enää olemassa.
    [payee] Tätä vastapuolta ei ole enää olemassa.
    [project] Tätä projektia ei ole enää olemassa.
    [budget-line] Tätä budjettikohtaa ei ole enää olemassa.
   *[bank] Tätä pankkia ei ole enää olemassa.
}

nomenclature-fresh = { $kind ->
    [category] Uusi luokka.
    [assignment] Uusi kohdistus.
    [payment-mode] Uusi maksutapa.
    [payee] Uusi vastapuoli.
    [project] Uusi projekti.
    [budget-line] Uusi budjettikohta.
   *[bank] Uusi pankki.
}

nomenclature-created = { $kind ->
    [category] Luokka lisätty.
    [assignment] Kohdistus lisätty.
    [payment-mode] Maksutapa lisätty.
    [payee] Vastapuoli lisätty.
    [project] Projekti lisätty.
    [budget-line] Budjettikohta lisätty.
   *[bank] Pankki lisätty.
}

nomenclature-updated = { $kind ->
    [category] Luokka muokattu.
    [assignment] Kohdistus muokattu.
    [payment-mode] Maksutapa muokattu.
    [payee] Vastapuoli muokattu.
    [project] Projekti muokattu.
    [budget-line] Budjettikohta muokattu.
   *[bank] Pankki muokattu.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 luokka poistettu.
       *[other] { $count } luokkaa poistettu.
      }
    [assignment] { $count ->
        [one] 1 kohdistus poistettu.
       *[other] { $count } kohdistusta poistettu.
      }
    [payment-mode] { $count ->
        [one] 1 maksutapa poistettu.
       *[other] { $count } maksutapaa poistettu.
      }
    [payee] { $count ->
        [one] 1 vastapuoli poistettu.
       *[other] { $count } vastapuolta poistettu.
      }
    [project] { $count ->
        [one] 1 projekti poistettu.
       *[other] { $count } projektia poistettu.
      }
    [budget-line] { $count ->
        [one] 1 budjettikohta poistettu.
       *[other] { $count } budjettikohtaa poistettu.
      }
   *[bank] { $count ->
        [one] 1 pankki poistettu.
       *[other] { $count } pankkia poistettu.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Samanniminen luokka on jo olemassa: ”{ $label }”.
    [assignment] Samanniminen kohdistus on jo olemassa: ”{ $label }”.
    [payment-mode] Samanniminen maksutapa on jo olemassa: ”{ $label }”.
    [payee] Samanniminen vastapuoli on jo olemassa: ”{ $label }”.
    [project] Samanniminen projekti on jo olemassa: ”{ $label }”.
    [budget-line] Samanniminen budjettikohta on jo olemassa: ”{ $label }”.
   *[bank] Samanniminen pankki on jo olemassa: ”{ $label }”.
}

# --- Ikkunoiden otsikot, ranskaksi ilman aksentteja kuten alkuperäisissä -

window-list-title = { $kind ->
    [category] Luokkien luettelo
    [assignment] Kohdistusten luettelo
    [payment-mode] Maksutapojen luettelo
    [payee] Vastapuolten ja kauppiaiden luettelo
    [project] Projektien luettelo
    [budget-line] Budjettikohtien luettelo
   *[bank] Pankkien luettelo
}

window-form-title = { $kind ->
    [category] Luokan kortti
    [assignment] Kohdistuksen kortti
    [payment-mode] Maksutavan kortti
    [payee] Vastapuolen kortti
    [project] Projektin kortti
    [budget-line] Budjettikohdan kortti
   *[bank] Pankin kortti
}

# --- Valikkorivi (01_CAHIER_DES_CHARGES.md §6) ------------------------

menu-file = Tiedosto
menu-file-import-statements = Tiliotteiden tuonti
menu-file-import-excel = Excel-tiedoston tuonti
menu-file-backup = Varmuuskopiointi
menu-file-restore = Palautus
menu-file-repair = Tietokannan korjaus ja optimointi
menu-file-log = Näytä loki
menu-tools-password = Suojaa tietokanta salasanalla
menu-file-disconnect = Katkaise yhteys nykyiseen tietokantaan
menu-file-quit = Lopeta

menu-accounts = Tilit
menu-accounts-manage = Pankkitilien hallinta
menu-accounts-balances = Näytä tiliesi saldot
menu-accounts-operations = Tilin tapahtumien hallinta
menu-accounts-quick-classify = Tapahtumien pikaluokittelu
menu-accounts-recurring = Toistuvien tapahtumien hallinta
menu-accounts-transfer = Siirrä summa kahden tilin välillä
menu-accounts-checkbooks = Shekkivihkojen hallinta

menu-statistics = Tilastot
menu-statistics-balance-chart = Saldon kehitys -kuvaaja
menu-statistics-by-category = Tilastot kategorioittain
menu-statistics-by-assignment = Tilastot kohdistuksittain
menu-statistics-by-budget-line = Tilastot budjettikohdittain
menu-statistics-by-payment-mode = Tilastot maksutavoittain
menu-statistics-by-payee = Tilastot vastapuolittain ja kauppiaittain
menu-statistics-by-project = Tilastot projekteittain
menu-statistics-dashboard = Tapahtumien koontinäyttö

menu-budget = Budjetti
menu-budget-entry = Budjetin syöttö
menu-budget-control = Budjetin seuranta

menu-nomenclatures = Perustiedot
menu-nomenclature = { $kind ->
    [category] Kategoriat
    [assignment] Kohdistukset
    [payment-mode] Maksutavat
    [payee] Vastapuolet ja kauppiaat
    [project] Projektit
    [budget-line] Budjettikohdat
   *[bank] Pankit
}
menu-nomenclatures-templates = Tapahtumamallit

menu-settings = Asetukset
menu-settings-about-author = Tietoja tekijästä
menu-settings-about-radinus = Tietoja Radinuksesta
menu-settings-licence = Käyttöoikeus

menu-misc = Muut
menu-misc-calculator = Laskin
menu-misc-website = Siirry Radinuksen sivustolle
menu-misc-database-folder = Avaa tietokannan sisältävä kansio

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Avaa tietokannan kansio
database-folder-warning =
    Tämä kansio sisältää kaikki tietosi. Tiedoston uudelleennimeäminen, siirtäminen tai poistaminen voi hukata tilisi, vioittaa niitä tai estää Radinusta toimimasta.
    Haluatko varmasti avata sen?
menu-misc-application-folder = Avaa sovelluksen sisältävä kansio
menu-misc-attachments-folder = Pääsy liitetiedostojen kansioon
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Liitetiedostojen hallinta
window-attachments-manager-title = Liitetiedostojen hallinta
attachments-column-document = Asiakirja
attachments-column-size = Koko
attachments-column-added = Lisätty
attachments-column-state = Tila
attachments-state-intact = Ehjä
attachments-state-altered = Muuttunut sittemmin
attachments-state-missing = Tiedosto puuttuu
attachments-state-unknown = Ei tarkistettavissa
attachments-state-orphan = Orpo
attachments-no-operation = Ei tapahtumaa
attachments-orphan-remove-question = Tämä tiedosto ei liity mihinkään tapahtumaan. Siirretäänkö roskakoriin?
attachments-manager-help = Kaksoisnapsauta riviä avataksesi asiakirjan.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Näytä tapahtuma
attachments-reveal = Näytä tiedostonhallinnassa
attachments-manager-summary = { $count } liitetiedostoa, yhteensä { $size }.
attachments-disk-name = Nimi levyllä: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Avaa liitetiedostojen kansio
attachments-folder-warning =
    Tämä kansio sisältää tapahtumiisi liittämäsi tiedostot. Radinus tallentaa ne itse valitsemallaan nimellä: tiedoston uudelleennimeäminen, siirtäminen tai poistaminen ei irrota sitä tapahtumasta, joka ilmoittaa siitä edelleen eikä se enää avaudu.
    Haluatko varmasti avata sen?

# ---------------------------------------------------------------------
# Pankkitilit — F04, F06, F07, F08.
# Version 1.9.3 kirjoitusvirheet (”Bank Identifer Code”, ”Solde
# initial prevu”, ”Est Cloturé”, IBANin sulkua edeltävä välilyönti)
# on korjattu: Fabricen päätös 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Pankkitilien hallinta
window-accounts-select-title = Tililuettelo
window-balances-title = Tiliesi saldot
window-account-title = Tilikortti

accounts-none = Ei tilejä.
accounts-nothing-to-show = Ei näytettäviä tilejä.
accounts-gone = Tätä tiliä ei ole enää olemassa.
accounts-fresh = Uusi tili.
accounts-created = Tili lisätty.
accounts-updated = Tili muokattu.
accounts-deleted = { $count ->
    [one] 1 tili poistettu.
   *[other] { $count } tiliä poistettu.
}
accounts-duplicate-name = Samanniminen tili on jo olemassa: ”{ $label }”.
accounts-multiselect-help = Info: valitse useita tilejä napsauttamalla taulukkoa hiirellä [{ $modifier }]-näppäin pohjassa
accounts-select-question = Mihin pankkitileihin tilastot perustetaan?

accounts-column-label = KUVAUS
accounts-column-bank = Pankki
accounts-column-type = Tilityyppi
accounts-column-number = Tilinro
accounts-column-account = Tili
accounts-column-bank-balance = Pankkisaldo
accounts-column-real-balance = Todellinen
accounts-column-final-balance = Loppusaldo
accounts-total = YHTEENSÄ

# Tilin poisto vie mukanaan sen tapahtumat: tämä on ohjelman ainoa kohta,
# jossa poisto tuhoaa historiaa.
accounts-delete-plain = Vahvistatko, että tili ”{ $label }” poistetaan?
accounts-delete-with-operations = Tili ”{ $label }” sisältää { $count } tapahtumaa, jotka poistetaan sen mukana. Vahvistatko poiston?
accounts-delete-form-open = Tilikortti ”{ $label }” on auki. Sulje se ennen poistoa.

account-group-bank = Tilin ja pankin tiedot
account-group-holder = Tilinomistaja
account-group-rib = Pankkiyhteystiedot (RIB)
account-group-activity = Toiminta
account-group-balances = Saldot

account-field-label = Tilin nimi
account-field-bank = Pankki
account-field-type = Tilityyppi
account-field-branch-address = Pankkikonttorin osoite
account-field-holder-name = Nimi
account-field-holder-address = Osoite
account-field-rib-bank = Pankin koodi
account-field-rib-branch = Konttorin koodi
account-field-rib-number = Tilinumero
account-field-rib-key = RIB-tarkiste
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Avauspäivä
account-field-closing-date = Sulkemispäivä
account-field-closed = On suljettu
account-field-opening-pointed = Täsmäytetty alkusaldo
account-field-opening-committed = Varattu alkusaldo
account-field-opening-planned = Suunniteltu alkusaldo

account-label-required = Tilin nimi on pakollinen.
account-iban-invalid = Tämä IBAN ei ole kelvollinen: tarkista tarkistusnumero.
# Kortin alareunan sininen rivi, sanasta sanaan versiosta 1.9.3 — vain summat
# noudattavat nyt muiden kenttien ranskalaista muotoilua.
account-control-line = Täsmäytetty alkusaldo ({ $opening }) + Tapahtumat yhteensä ({ $operations }) = Nykyinen pankkisaldo: { $balance }.

amount-not-readable = ”{ $field }” ei sisällä kelvollista summaa.

ui-thousands-separator =  
ui-decimal-separator = ,

# --- Tapahtumaluettelo (F02) -----------------------------------------

window-operations-title = Tilin tapahtumat: { $account }

operations-none = Ei tapahtumia tällä ajanjaksolla.
operations-bad-period = Ajanjakson rajat eivät ole kelvollisia päivämääriä.
operations-from = Alkupäivä
operations-to = Loppupäivä
operations-delete-confirm = { $count ->
    [one] Vahvistatko tämän tapahtuman poiston?
   *[other] Vahvistatko näiden { $count } rivin poiston? Valittujen tapahtumien osatapahtumat poistuvat niiden mukana.
}
operations-deleted = { $count ->
    [one] 1 tapahtuma poistettu.
   *[other] { $count } tapahtumaa poistettu.
}
operations-selection-total = Valittujen tapahtumien summa yhteensä: { $amount }

operations-column-date = Päivä
operations-column-clearing-date = Täsmäytyspäivä
operations-column-label = Kuvaus
operations-column-category = Kategoria
operations-column-assignment = Kohdistus
operations-column-payment-mode = Maksutapa
operations-column-payee = Vastapuoli
operations-column-project = Projektit
operations-column-month = Kuukausi
operations-column-debit = Veloitus
operations-column-credit = Hyvitys
operations-column-balance = Saldo
operations-column-comments = Kommentit
operations-column-attachments = Liitteet
operations-column-check = Shekin nro

operations-foot-debit = Veloitus:
operations-foot-credit = Hyvitys:
operations-foot-total = Yhteensä:
operations-foot-bank = Pankkisaldo:
operations-foot-real = Todellinen saldo:
operations-foot-final = Loppusaldo:

operations-menu-export = Vienti
operations-menu-print = Tulostus
operations-menu-filter = Suodatin
operations-menu-period = Ajanjakso
operations-menu-misc = Muut

operations-title-point = Täsmäytä valitut
operations-title-sub = Lisää osatapahtuma
operations-title-duplicate = Kopioi valitut
operations-not-yet = Tätä ikkunaa ei ole vielä olemassa: se tulee suunnitelmassa myöhemmin.

accounts-choose-question = Millä tilillä haluat työskennellä?
ui-title-select = Tee valinta

month-january = tammikuu
month-february = helmikuu
month-march = maaliskuu
month-april = huhtikuu
month-may = toukokuu
month-june = kesäkuu
month-july = heinäkuu
month-august = elokuu
month-september = syyskuu
month-october = lokakuu
month-november = marraskuu
month-december = joulukuu

operations-period-year = Kuluva vuosi

# --- F02:n Ajanjakso-valikko -----------------------------------------
# Yhdeksän kohtaa, joista kaksi avaa alavalikon kahdestatoista kuukaudesta.
# Jokainen tekee vain yhden asian: päättelee siitä alkupäivän ja loppupäivän,
# jotka ikkuna asettaa kahteen kenttäänsä (Fabricen pyyntö, 25/07/2026).

period-all = Kaikki
period-last-year = Viime vuosi
period-this-year = Kuluva vuosi
period-whole-year = Koko vuosi
period-last-month = Viime kuukausi
period-this-month = Kuluva kuukausi
period-last-week = Viime viikko
period-this-week = Kuluva viikko
period-yesterday = Eilen
period-today = Tänään

# --- F02:n Suodatin-valikko ------------------------------------------
# Suodattaa rivit tapahtuman luonteen mukaan (Fabricen pyyntö,
# 25/07/2026). Kolme tilaa ovat tietokannan tilat: 1 täsmäytetty, 2 varattu,
# 3 suunniteltu (02_BASE_DE_DONNEES.md §5.2).

filter-all = Kaikki tapahtumat
filter-pointed = Vain täsmäytetyt tapahtumat
filter-committed = Vain varatut tapahtumat
filter-planned = Vain suunnitellut tapahtumat

# --- Tapahtumalomake (F03) -------------------------------------------
# Nimikkeet ovat kuvakaappauksesta ”Fiche operation transaction.png”,
# alkuperäisen kirjoitusvirheet korjattuina (Fabricen lupa, 25/07/2026:
# ”les coquilles tu les corriges”): ”Libelle” on nyt ”Libellé”,
# ”Categorie” on nyt ”Catégorie”, ”Statut Operation” on nyt
# ”Statut opération”.

window-operation-title = Tilin tapahtuma: { $account }

operation-menu-identification = Tunnistetiedot
operation-menu-options = Asetukset
operation-fitid-edit = Muokkaa FITID-tunnistetta…
operation-fitid-delete = Poista FITID-tunniste
operation-fitid-question = Tämän tapahtuman FITID-tunniste:
operation-fitid-delete-question = Poistetaanko tämän tapahtuman FITID-tunniste?
operation-fitid-written = FITID-tunniste tallennettu.
operation-fitid-removed = FITID-tunniste poistettu.

operation-group-identification = Tapahtuman tunnistetiedot
operation-group-amount = Tapahtuman summa
operation-group-status = Tapahtuman tila
operation-group-classification = Tapahtuman luokittelu tilastojen laskentaa varten
operation-group-check = Tapahtumaan liittyvä shekki
operation-group-comment = Kommentti

operation-field-label = Kuvaus
operation-field-reference = Maksun viite
operation-field-date = Päivämäärä
operation-field-direction = Tapahtuman tyyppi:
operation-field-amount = Summa
operation-field-status = Tapahtuman tila
operation-field-clearing-date = Täsmäytyspäivä
operation-field-category = Luokka
operation-field-assignment = Kohdistus
operation-field-payment-mode = Tapa
operation-field-payee = Vastapuoli
operation-field-project = Projekti
operation-field-check = Liitä shekkiin

operation-direction-debit = Veloitus
operation-direction-credit = Hyvitys

operation-check-info = Tiedot.
operation-check-link = Liitä
operation-check-unlink = Poista

operation-fresh = Uusi tapahtuma.
operation-created = Tapahtuma lisätty.
operation-updated = Tapahtuma muokattu.
operation-gone = Tätä tapahtumaa ei enää ole.
operation-nothing-to-show = Ei näytettäviä tapahtumia.
operation-label-required = Tapahtuman kuvaus on pakollinen.
operation-date-required = Tapahtuman päivämäärä on pakollinen.
operation-clearing-date-invalid = Täsmäytyspäivä ei ole kelvollinen päivämäärä.
operation-is-a-sub = Tämä rivi on osatapahtuma: sitä muokataan sen omalta lomakkeelta.
operation-delete-form-open = Lomake ”{ $label }” on auki. Sulje se ennen poistamista.

operation-attachments = { $count ->
    [0] Ei liitteitä
    [one] 1 liite
   *[other] { $count } liitettä
}

operation-title-comment = Tapahtuman kommentti
operation-title-sub = Luo osatapahtuma
operation-title-template = Tapahtumamallit
operation-title-attachment = Liitteet

# --- Osatapahtuman lomake (F04) --------------------------------------
# Suppeampi versio F03:sta: ei Tapaa, ei Tilaa, ei Päivämäärää — osatapahtuma
# perii ne emoltaan (`Maj_ProprieteSousOp`, Fabrice vahvisti 26/07/2026:
# ”dans une sous-opération, comme est le complément, on ne peut pas toucher
# au mode de paiement, cela serait illogique”).

window-sub-operation-title = Osatapahtuman lomake

sub-operation-group-amount = Osatapahtuman summa
sub-operation-field-label = Nimi
sub-operation-fresh = Uusi osatapahtuma.
sub-operation-created = Osatapahtuma lisätty.
sub-operation-updated = Osatapahtuma muokattu.
sub-operation-gone = Tätä osatapahtumaa ei enää ole.
sub-operation-nothing-to-show = Ei näytettäviä osatapahtumia.
sub-operation-label-required = Osatapahtuman nimi on pakollinen.
sub-operation-parent-gone = Jaettavaa tapahtumaa ei enää ole.
# Mitä lomake sanoo, kun se näyttää Jäännöksen. Sitä ei ole suojattu:
# sitä voi muokata, mutta on tiedettävä, mihin ryhtyy (Fabricen päätös,
# 26/07/2026).
sub-operation-is-the-complement = Tämä on Jäännös: se osa, joka on vielä jakamatta. Jos nimeät sen uudelleen tai muutat sen summaa, siitä tulee tavallinen osatapahtuma.
sub-operation-of = Jakaminen: ”{ $label }” ({ $amount })

operations-pointed = { $count ->
    [one] 1 tapahtuma täsmäytetty.
   *[other] { $count } tapahtumaa täsmäytetty.
}
operations-select-one = Valitse vain yksi tapahtuma.

# --- Kopiointi ja osatapahtumien näyttäminen (F02) --------------------
# Kopiointi avaa esitäytetyn lomakkeen, jonka käyttäjä vahvistaa itse
# (Fabricen päätös, 26/07/2026): mitään ei kirjoiteta ennen kuin hän on
# tallentanut, ja hän voi korjata päivämäärän tai summan sitä ennen.

operation-copy = Kopio on vielä tallentamatta: mitään ei ole vielä luotu.
operations-show-children = Näytä kaikki osatapahtumat
operations-hide-children = Piilota kaikki osatapahtumat

# --- Vakavan poiston toinen vahvistus ---------------------------------
# Pankkitilin poistaminen vie mukanaan koko sen historian: Kyllä/Ei
# napsautetaan lukematta, joten pyydämme kirjoittamaan sanan (Fabricen
# päätös, 26/07/2026). Sana on sanakirjan sana — tässä ”Kyllä”, englanniksi
# ”Yes” — joten mitään ei tarvitse kääntää tässä toiseen kertaan.

accounts-delete-second-question = Tämä poisto on lopullinen ja vie mukanaan tilin koko historian. Vahvista se kirjoittamalla ”{ $word }”.

# --- F20-F24 — Kuusi tilastoa -----------------------------------------
# Yhteinen malli kuudella akselilla. Luokittainen tilasto toimi esikuvana,
# ja Fabrice hyväksyi sen 26/07/2026 ennen kuin viittä muuta oli olemassa —
# sarakkeiden nimet ovat alkuperäisen nimiä.

window-statistics-title = { $kind ->
    [assignment] Tilastot kohdistuksittain
    [budget-line] Tilastot budjettikohdittain
    [payment-mode] Tilastot maksutavoittain
    [payee] Tilastot vastapuolittain ja kauppiaittain
    [project] Tilastot projekteittain
   *[category] Tilastot luokittain
}

statistics-axis-column = { $kind ->
    [assignment] Kohdistus
    [budget-line] BudjettiKohta
    [payment-mode] TapahtumaTapa
    [payee] Vastapuoli
    [project] Projektit
   *[category] LuokkaNimi
}

statistics-unclassified = { $kind ->
    [assignment] Ei kohdistusta
    [budget-line] Ei budjettikohtaa
    [payment-mode] Ei maksutapaa
    [payee] Ei vastapuolta
    [project] Ei projektia
   *[category] Ei luokkaa
}
statistics-total = Yhteensä
statistics-sum = Summa
statistics-cumulative = Kertymä

# Palkin viisi kytkintä. Nimike vaihtuu ON/OFF, kuten alkuperäisessä:
# kytkin itse kertoo, missä asennossa se on.
statistics-switch-pointed = Täsmäytetyt tapahtumat { $state }
statistics-switch-committed = Varatut tapahtumat { $state }
statistics-switch-planned = Suunnitellut tapahtumat { $state }
statistics-switch-debits = Veloitusten summat { $state }
statistics-switch-credits = Hyvitysten summat { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Yhtään tiliä ei ole valittu: tilasto ei koske mitään.
statistics-no-data = Valituilla tileillä ei ole tapahtumia tänä vuonna.
statistics-detail-empty = Napsauta lukua sisältävää ruutua, niin näet sen tapahtumat.
statistics-detail-none = Tämän ruudun takana ei ole yhtään tapahtumaa.
statistics-accounts = { $count ->
    [one] 1 tili
   *[other] { $count } tiliä
}
statistics-year-next = Seuraava vuosi
statistics-year-previous = Edellinen vuosi

statistics-column-date = Päivämäärä
statistics-column-clearing-date = TäsmäytysPäivä
statistics-column-label = Kuvaus
statistics-column-amount = Summa
statistics-column-comments = Kommentit

accounts-stats-multiselect-help = Ohje: Valitse useita tilejä napsauttamalla taulukkoa hiirellä ja pitämällä [{ $modifier }]-näppäintä pohjassa

# Tilastojen vuosiluku: sitä napsautetaan ja siihen kirjoitetaan vuosi.
# Rajat ovat samat kuin Jakso-valikon ”Kaikki”-kohdassa — Radinuksen vuosi
# on kokonaisluku väliltä 1950–2550 (Fabrice, 26/07/2026).
statistics-year-question = Mitä vuotta haluat käsitellä? Radinus ulottuu vuodesta { $first } vuoteen { $last }.
statistics-year-choose = Valitse vuosi

# --- Taulukoiden vienti (hiiren oikea painike) ------------------------
# Taulukon toiminto, ei ikkunan: se on kaikilla listoilla.

export-to-excel = Vie Exceliin (.xlsx)
export-to-word = Vie Wordiin (.docx)
export-to-tsv = Vie TSV-muotoon (.tsv)
export-to-ini = Vie INI-muotoon (.ini)
export-to-toml = Vie TOML-muotoon (.toml)
export-to-yaml = Vie YAML-muotoon (.yaml)
export-to-ofx = Vie OFX-muotoon (.ofx)
export-to-qif = Vie QIF-muotoon (.qif)
export-to-ods = Vie LibreOffice Calciin (.ods)
export-to-csv = Vie CSV-muotoon (.csv)
export-to-xml = Vie XML-muotoon (.xml)
# Tilastoikkunan Vienti-valikko: yksi välilehti vuotta kohti, nimeltään
# AN_2026. Tyhjät vuodet — asetettujen kytkinten mukaan — eivät ole mukana.
export-menu = Vienti
export-all-years-excel = Vie kaikki vuodet Exceliin
export-all-years-ods = Vie kaikki vuodet LibreOffice Calciin
export-no-year = Yhdenkään vuoden kohdalla ei ole tapahtumia: vietävää ei ole.
export-years-done = { $years } vuotta viety tiedostoon ”{ $file }”.
export-to-json = Vie JSON-muotoon (.json)
export-done = Viety tiedostoon ”{ $file }”.
export-failed = Vienti ei onnistu: { $reason }
export-nothing = Vietävää ei ole.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Tilastot kohdistuksittain
    [budget-line] Tilastot budjettikohdittain
    [payment-mode] Tilastot maksutavoittain
    [payee] Tilastot vastapuolittain ja kauppiaittain
    [project] Tilastot projekteittain
   *[category] Tilastot luokittain
}
statistics-detail-name = Tilastojen erittely

# --- F19 — Yleiskatsaus -----------------------------------------------
# Yksi ajanjakso ja kolme kytkintä; kaksi rengaskaaviota budjettikohtaa
# kohden; kolme suurta lukua. Sektorien värit ovat alkuperäisen ohjelman
# värit, luettuina Fabricen kuvakaappauksesta.

window-dashboard-title = Yleiskatsaus
dashboard-menu-period = Ajanjakso
dashboard-menu-misc = Muut
dashboard-from = Alkupäivä:
dashboard-to = Loppupäivä:
dashboard-switch-pointed = Sisällytä täsmäytetyt tapahtumat
dashboard-switch-committed = Sisällytä varatut tapahtumat
dashboard-switch-planned = Sisällytä suunnitellut tapahtumat
dashboard-spending = Menot
dashboard-earning = Tulot
dashboard-debits = Veloitustapahtumien summa
dashboard-credits = Hyvitystapahtumien summa
dashboard-balance = Erotus
dashboard-unclassified = Ei budjettikohtaa
dashboard-nothing = Ei tapahtumia tällä ajanjaksolla.
dashboard-no-account = Yhtään tiliä ei ole valittu: yleiskatsaus ei kohdistu mihinkään.
dashboard-enlarge = Avaa suurena

# --- F25 — Saldon kehitys ----------------------------------------------
# Yksi kuvaaja valittua tiliä kohden sekä kokonaissumman kuvaaja — jota ei
# ole ennen kuin tilejä on kaksi (Fabricen sääntö, 26/07/2026). Kuvaajat
# ovat porrasmaisia: saldo säilyttää arvonsa seuraavaan tapahtumaan asti.

window-curve-title = Saldon kehitys
curve-heading = Saldon kehitys päivittäin
curve-menu-period = Ajanjakso
curve-total = Yhteensä
curve-from = Alkupäivä:
curve-to = Loppupäivä:
curve-axis-balance = saldo
curve-nothing = Yhtään tiliä ei ole valittu: piirrettävää kuvaajaa ei ole.
curve-empty = Ei tapahtumia tällä ajanjaksolla.

# --- F05 — Tapahtumien nopea luokittelu --------------------------------
# Ikkuna, jossa luokitellaan **joukolla**: valitaan rivejä, rastitaan
# muutettavat ominaisuudet ja sovelletaan ne kerralla — muistissa. Mitään ei
# kirjoiteta ennen kuin on tallennettu, ja tallennus kirjoittaa vain sen,
# mikä poikkeaa siitä, mitä on luettu (Fabricen säännöt,
# 27/07/2026).

window-quick-classification-title = Tapahtumien nopea luokittelu: { $account }
quick-dates-title = Luettelon alku- ja loppupäivä.
quick-from = Alkupäivä
quick-to = Loppupäivä
quick-menu-period = Ajanjakso
quick-change-title = Muuta valinnan ominaisuudet:
quick-check-category = Luokka
quick-check-assignment = Kohdistus
quick-check-payment-mode = Maksutapa
quick-check-payee = Vastapuoli
quick-check-project = Projekti
quick-check-status = Tila
quick-column-date = Päivä
quick-column-label = Kuvaus
quick-column-amount = Summa
quick-column-category = Luokka
quick-column-assignment = Kohdistus
quick-column-payment-mode = Maksutapa
quick-column-payee = Vastapuoli
quick-column-project = Projektit
quick-column-status = Tila
# Macissa Ctrl + napsautus on oikea napsautus: valintaan lisäävä näppäin on
# siellä ⌘, ja ohjeen on mainittava se näppäin, joka toimii.
quick-multiselect-help = Info: Valitse taulukosta useita kohteita hiiren napsautuksella ja [{ $modifier }]-näppäimellä
quick-none = Ei tapahtumia tällä ajanjaksolla.
quick-select-lines = Valitse vähintään yksi rivi ja rastita vähintään yksi ominaisuus.
quick-applied = { $count ->
    [0] Mikään ei muuttunut: näillä riveillä oli jo tämä luokittelu.
    [one] 1 rivi luokiteltu. Mitään ei ole vielä tallennettu.
   *[other] { $count } riviä luokiteltu. Mitään ei ole vielä tallennettu.
}
quick-pending = { $count ->
    [0] Ei odottavia muutoksia.
    [one] 1 rivi muutettu, ei tallennettu.
   *[other] { $count } riviä muutettu, ei tallennettu.
}
quick-save-question = { $count ->
    [one] Tallennetaanko odottava muutos?
   *[other] Tallennetaanko { $count } odottavaa muutosta?
}
quick-saved = { $count ->
    [0] Tallennettavaa ei ollut.
    [one] 1 rivi tallennettu.
   *[other] { $count } riviä tallennettu.
}
quick-nothing-to-save = Ei odottavia muutoksia.
quick-leave-question = Muutoksia ei ole tallennettu. Mitä haluat tehdä?
quick-leave-save = Tallenna ja poistu
quick-leave-discard = Hylkää ja poistu
quick-leave-stay = Jää tähän
quick-title-apply = Sovella valittuihin riveihin ( muistissa )
quick-title-save = Tallenna levylle

# --- F17 / F18 — Tiliotteen tuonti -------------------------------------
# Valitaan tili, avataan OFX-tiedosto — joka pysyy keskusmuistissa —, rivit
# jotka tietokanta jo tuntee näkyvät pastellinvärisinä, ja kolmas kuvake
# liittää ne: joukolla jos useita on valittu, muuten yksitellen
# täsmäytyslomakkeella (Fabricen työjärjestys, 27/07/2026).

window-statement-import-title = Pankkitiliotteiden tuonti: { $account }
window-statement-form-title = Täsmäytä tapahtuma (liittää tapahtuman tilisi historiaan)
statement-menu-filter = Suodatin
statement-filter-all = Kaikki rivit
statement-filter-pending = Liitettävät
statement-filter-known = Jo liitetyt
statement-column-id = ID
statement-column-reconciled = Täsmäytetty
statement-column-fitid = FITID
statement-column-date = Päivä
statement-column-label = Kuvaus
statement-column-debit = Veloitus
statement-column-credit = Hyvitys
statement-account = Tili
statement-file = Tiedosto
statement-difference = Erotus
statement-none = Yhtään tiliotetta ei ole avattu: valitse tiedosto napsauttamalla keltaista kansiota.
statement-empty = Tämä tiliote ei sisällä yhtään tapahtumaa.
statement-no-match = Yksikään rivi ei vastaa suodatinta.
statement-help = Info: Valitse taulukosta useita rivejä hiiren napsautuksella ja [{ $modifier }]-näppäimellä
statement-choose-account = Tämä tiedosto sisältää useita tilejä. Minkä niistä haluat tuoda?
statement-select-line = Valitse tiliotteelta vähintään yksi rivi.
statement-title-open = Avaa tiliotetiedosto (.ofx)
statement-title-info = Tietoja avatusta tiedostosta
statement-title-integrate = Liitä valinta tilille
statement-title-validate = Liitä tämä tapahtuma tilille
statement-duplicate = Huomio, kaksoiskappale: tämä tapahtuma näyttää jo olevan liitetty tietokantaan (Financial Institution Transaction ID on jo olemassa)
statement-no-fitid = Huomio: tämä tiedosto ei anna tälle riville mitään tunnistetta (FITID). Kaksoiskappaletta ei voida havaita.
statement-loaded = { $count ->
    [0] Tämä tiedosto ei sisällä yhtään tapahtumaa tälle tilille.
   *[other] { $count } riviä luettu, joista { $known } on jo tililläsi.
}
statement-integrated = { $count ->
    [0] Mitään ei liitetty: nämä rivit ovat jo tililläsi.
    [one] 1 tapahtuma liitetty.
   *[other] { $count } tapahtumaa liitetty.
}
# **Alkuperäisen ohjelman viestit sanasta sanaan** (Fabricen ohje,
# 28/07/2026: pysytään uskollisina alkuperäiselle koodille). Se varoittaa ennen
# erää, kysyy kaksoiskappaleen kohdalla rivi riviltä ja tilittää lopuksi.

statement-mass-question =
    Haluatko varmasti liittää tilillesi useita tapahtumia yhtä aikaa?
    Sinun on luokiteltava ja määriteltävä ne myöhemmin, jotta tilastot olisivat tarkkoja
    Ofx-tiedostojen tapauksessa: jos kaksoiskappaleita havaitaan, sinun on valittava ohjelman toimintatapa
    Muiden tiedostotyyppien osalta: sinun on varottava kaksoiskappaleita
statement-duplicate-question =
    Tapahtuma: { $date } { $label }: { $amount }
    näyttää jo olevan liitetty pankkitilisi tapahtumahistoriaan.
    Haluatko varmasti tehdä täsmäytyksen?
statement-already-reconciled = Olet jo täsmäyttänyt tämän tapahtuman: se on jo liitetty tilisi tapahtumahistoriaan
statement-integration-report =
    Liittäminen päättyi.
    Liitettyjen tietueiden määrä: { $added }
    Ohitettujen tietueiden määrä: { $ignored }
statement-integration-abandoned =
    Liittäminen keskeytetty!
    Liitettyjen tietueiden määrä: { $added }
    Ohitettujen tietueiden määrä: { $ignored }
statement-yes = Kyllä
statement-no = Ei
statement-cancel = Peruuta
statement-file-info =
    Tiedoston tili: { $account }
    Ajanjakso: { $from } — { $to }
    Pankin ilmoittama saldo: { $balance }
    { $count } tapahtumaa, joista { $known } on jo tililläsi.
statement-group-identification = Tapahtuman tunnistetiedot
statement-group-amount = Tapahtuman summa
statement-group-classification = Tapahtuman luokittelu tilastojen laskentaa varten
statement-group-status = Tapahtuman tila
statement-field-date = Päivä
statement-field-label = Kuvaus
statement-field-type = Tapahtumatyyppi
statement-field-amount = Summa
statement-field-mode = Tapahtumatapa
statement-field-category = Luokka
statement-field-assignment = Kohdistus
statement-field-payee = Vastapuoli
statement-field-project = Projekti
statement-field-status = Tila
statement-field-clearing = Täsmäytyspäivä

# --- CSV-tiliotteen jäsennysikkuna -------------------------------------
# CSV ei sisällä yhtään luotettavaa kentän nimeä: säädetään, testataan,
# katsotaan, aloitetaan alusta. Esikatselu näyttää kaiken, myös siansaksan
# — juuri siitä nähdään, että on menty vikaan — mutta vain kelvolliset rivit
# siirtyvät liittämisikkunaan (Fabricen sääntö, 27/07/2026).

window-csv-statement-title = Tietojen tuonti csv-tiedostosta
csv-preview-title = Tiedoston esikatselu:
csv-settings-title = Tiedoston jäsennysasetukset tietojen poimintaa varten:
csv-extraction-title = Poimittujen tietojen tarkastelu jäsennysasetusten mukaan  ( tarkista tietojen johdonmukaisuus ):
csv-column-line = Rivin nro
csv-column-content = Sisältö
csv-header-lines = Ohitettavien otsikkorivien määrä
csv-separator = Tiedot (sarakkeet) on erotettu merkillä:
csv-date-at = Päiväyskentän sijainti
csv-label-at = Kuvauskentän sijainti
csv-debit-at = Veloitussumman kentän sijainti
csv-credit-at = Hyvityssumman kentän sijainti
csv-test = Testaa asetukset
csv-separator-semicolon = Puolipiste   ;
csv-separator-comma = Pilkku   ,
csv-separator-tab = Sarkain
csv-separator-pipe = Pystyviiva   |
csv-separator-space = Välilyönti
csv-help = Säädä, testaa, katso: vain ne rivit tuodaan, joilla on luettava päiväys ja summa.
csv-none = Tiedosto on tyhjä.
csv-not-tested = Napsauta ”Testaa asetukset” nähdäksesi, mitä jäsennys tuottaa.
csv-extraction = { $count ->
    [0] Jäsennys ei tuota yhtään riviä: tarkista otsikkorivien määrä ja erotinmerkki.
   *[other] { $count } riviä jäsennetty: { $valid } tuodaan, { $dropped } hylätään, koska päiväys tai summa ei ole luettavissa.
}
csv-nothing-valid = Yhdelläkään rivillä ei ole sekä luettavaa päiväystä että summaa: tuotavaa ei ole. Tarkista otsikkorivien määrä, erotinmerkki ja kenttien sijainnit.
csv-title-validate = Siirrä kelvolliset rivit tuontiin

# --- F13 / F31 / F14 / F12 — Shekkivihkot ja shekit (vaihe 9) -----------
# Hänen viiden WinDev-koodinsa ja seitsemän kuvakaappauksensa siirto,
# toimitettu 28/07/2026. Hänen tarkat lauseensa siellä missä hänellä on
# sellainen; muualla minun.
#
# Kolme uskollisuutta, jotka hän ratkaisi sinä päivänä ja jotka kuuluvat
# sanoissa: kahteen kertaan esiintyvästä viitteestä ei ilmoiteta (hänen
# `Existe_Reference`-funktiotaan ei koskaan kutsuta), shekkien määrää ei
# verrata rajoihin, ja tapahtumalaskuri laskee mukaan ne osatapahtumat, jotka
# listat hylkäävät.

window-chequebooks-title = Shekkivihkojen luettelo
window-chequebook-title = Shekkivihkon asetukset
window-cheques-title = Shekkivihkon sisältö: shekkien luettelo.
window-cheque-title = Shekin tiedot
window-cheque-operations-title = Tapahtumien luettelo.

# Shekkivihkojen luettelo (F13) — kaikki vihkot, tilistä riippumatta: hänen
# kaksi tilisaraketta olisivat yhdellä tilillä turhat.
chequebooks-column-reference = KUVAUS
chequebooks-column-date = Päivämäärä
chequebooks-column-account = Tilin nimi
chequebooks-column-account-number = Tilinro
chequebooks-column-comments = Kommentit
chequebooks-none = Yhtään shekkivihkoa ei ole tallennettu.
chequebooks-nothing-to-show = Yksikään shekkivihko ei vastaa tätä hakua.
chequebooks-title-composition = Näytä shekkivihkon sisältö
chequebooks-delete-question = Shekkivihkoon liittyviä tapahtumia (pankkitapahtumia) on havaittu. Vahvistatko, että haluat poistaa tämän shekkivihkon?
chequebooks-deleted = { $count ->
    [one] Yksi shekkivihko poistettu.
   *[other] { $count } shekkivihkoa poistettu.
}
chequebooks-gone = Tätä shekkivihkoa ei ole enää olemassa.
chequebooks-created = Shekkivihko tallennettu kaikkine shekkeineen.
chequebooks-updated = Shekkivihko muutettu.
# Hänen `HAjoute`-käskynsä vaikeneminen: ikkuna ei kerro, että viite on jo
# varattu. Se kertoo vain, ettei mitään ole tallennettu — muuten luulisi
# vihkon syntyneen.
# Hänen tiedostonsa ”Precauttion enregistrement cheque.txt” kahdeksan
# varotoimea, sanasta sanaan ja hänen järjestyksessään. Seitsemän ensimmäistä
# ovat `Erreur()`, kahdeksas `Info()` — ja järjestys ratkaisee, mitä nähdään,
# kun kaksi asiaa menee pieleen yhtä aikaa.
chequebook-refusal-duplicate = Samanniminen viite on jo olemassa
chequebook-refusal-reference-required = Viitteen syöttäminen on pakollista
chequebook-refusal-number-too-big = Ensimmäisen ja/tai viimeisen shekin numero on liian suuri (enimmäisarvo 999 999 999)
chequebook-refusal-date = Syötä kelvollinen vastaanottopäivä
chequebook-refusal-numbers-required = Täytä ensimmäisen ja viimeisen shekin numero
chequebook-refusal-order = Ensimmäisen shekin numeron on oltava pienempi kuin viimeisen shekin numero
chequebook-refusal-account = Valitse ehdottomasti tili, johon tämä shekkivihko liittyy
chequebook-refusal-too-many = Shekkien enimmäismäärä yhdessä shekkivihkossa: 1000, raja saavutettu
# Hänen vahvistuskysymyksensä, joka esitetään vain lisättäessä: se kertaa,
# mitä ollaan luomassa, ja varoittaa, ettei mitään siitä voi enää muuttaa.
chequebook-creation-question =
    Shekkivihkon luonti seuraavin tiedoin:
    - Luotavien shekkien määrä:{ $count }
    - Shekkien numerot { $first }–{ $last }
    Huomio: näitä tietoja ei voi muuttaa luonnin jälkeen!

# Shekkivihkon lomake (F31). Viisi ensimmäistä kenttää harmaantuu heti, kun
# vihko on olemassa: sen shekit ovat jo siellä.
chequebook-field-id = Shekkivihkon tunnus
chequebook-field-reference = Viite
chequebook-field-received = Valmistus- tai vastaanottopäivä
chequebook-field-first = Ensimmäisen shekin numero
chequebook-field-last = Viimeisen shekin numero
chequebook-field-quantity = Shekkien määrä
chequebook-field-account = Liitä pankkitiliin:
chequebook-field-comments = Kommentit
chequebook-locked = Tämän vihkon shekit on jo luotu: numerointia ei voi enää muuttaa.
# Hänen lauseensa, sanasta sanaan (`Enreg_Lire`).
chequebook-account-missing = Pankkitili, johon tämä shekkivihko liitettiin, puuttuu tai on poistettu!

# Shekkivihkon sisältö (F14). Tila vaihdetaan ruudussa.
cheques-column-number = Shekin nro
cheques-column-date = Päivämäärä
cheques-column-place = Paikka
cheques-column-payee = Saaja
cheques-column-amount = Summa
cheques-column-status = Tila
cheques-column-comments = Kommentit
cheques-column-operations = Liitettyjä tapahtumia
cheques-none = Tämä shekkivihko ei sisällä yhtään shekkiä.
cheques-nothing-to-show = Yksikään shekki ei vastaa tätä hakua.
cheques-help = Vaihda tila napsauttamalla Tila-ruutua; suurennuslasi näyttää liitetyt tapahtumat, ketjunlenkki liittää uuden.
cheques-title-linked = Näytä tähän shekkiin jo liitetyt tapahtumat
cheques-title-link = Liitä tapahtuma tähän shekkiin
cheques-status-changed = Shekin tila muutettu.

# Shekin lomake (F12).
cheque-field-id = Shekin tunnus
cheque-field-number = Shekin numero
cheque-field-issued = Myöntämispäivä
cheque-field-place = Myöntämispaikka
cheque-field-payee = Saaja
cheque-field-amount = Summa
cheque-field-comments = Kommentit
cheque-field-status = Shekin tila
cheque-gone = Tätä shekkiä ei ole enää olemassa.
cheque-updated = Shekki muutettu.

# Liittämisikkunan kaksi ilmettä.
cheque-operations-linked-title = Tähän shekkiin jo liitettyjen tapahtumien luettelo.
cheque-operations-choose-title = Valitse shekkiin liitettävä tapahtuma
cheque-operations-column-account = Tili
cheque-operations-column-label = Nimi
cheque-operations-column-date = Päivämäärä
cheque-operations-column-clearing = Täsmäytyspäivä
cheque-operations-column-amount = Summa
cheque-operations-column-cheque = Liitetty shekki
cheque-operations-none-linked = Tähän shekkiin ei ole liitetty yhtään tapahtumaa.
cheque-operations-none = Tämä tili ei sisällä yhtään tapahtumaa.
cheque-operations-nothing-to-show = Yksikään tapahtuma ei vastaa tätä hakua.
cheque-operations-help = Lihavoiduilla tapahtumilla on jo shekki.
cheque-operations-linked-help = Punainen risti irrottaa shekin tapahtumasta: mitään ei poisteta.
cheque-operations-linked = Tapahtuma liitetty shekkiin.
cheque-operations-dissociated = Shekki irrotettu tapahtumasta.
cheque-operations-menu-filter = Suodatin
cheque-title-associate = Liitä tämä tapahtuma shekkiin
cheque-title-dissociate = Irrota shekki tästä tapahtumasta

# Tapahtumalomakkeen palkki ”Tapahtumaan liittyvä shekki” ja shekin
# onkimisen kaksi vaihetta — ensin vihko, sitten shekki.
chequebooks-select-question = Valitse shekkivihko
cheques-select-question = Valitse tapahtumaan liitettävä shekki
operation-check-save-first = Tallenna ensin tapahtuma: shekki liitetään tapahtumaan, joka on olemassa.
operation-check-none = Tähän tapahtumaan ei liity yhtään shekkiä.

# --- F36 / F37 — Tapahtumamallit (vaihe 10) -----------------------------
# Malli on valmis syöte: se otetaan käyttöön, jotta ei tarvitse kirjoittaa
# uudelleen, ja se **korvaa** sen, mitä lomakkeessa on. Mitään ei tallennu
# levylle ennen kuin tapahtumalomake on vahvistettu (Fabricen sääntö,
# 29/07/2026).

window-operation-templates-title = Tapahtumamallien luettelo
window-operation-template-title = Tapahtumamallin tiedot

operation-templates-none = Yhtään tapahtumamallia ei ole tallennettu.
operation-templates-nothing-to-show = Yksikään malli ei vastaa tätä hakua.
operation-templates-select-question = Valitse käyttöön otettava malli
operation-templates-delete-question = Vahvistatko valittujen mallien poistamisen?
operation-templates-deleted = { $count ->
    [one] Yksi malli poistettu.
   *[other] { $count } mallia poistettu.
}
operation-template-gone = Tätä mallia ei ole enää olemassa.
operation-template-fresh = Uusi malli.
operation-template-created = Malli tallennettu.
operation-template-updated = Malli muutettu.
operation-template-label-required = Nimen syöttäminen on pakollista
operation-template-duplicate = Samanniminen malli on jo olemassa

# Lomake F36, osio osiolta — hänen tarkat otsikkonsa.
operation-template-field-id = Tapahtumamallin tunnus
operation-template-group-name = Tulevan tapahtuman oletusnimi mallin käyttöönoton jälkeen
operation-template-field-label = Nimi
operation-template-group-amount = Tapahtuman oletussumma, joka on määritelty tässä mallissa
operation-template-field-direction = Tapahtuman tyyppi
operation-template-field-amount = Summa
operation-template-group-status = Tapahtuman oletustila tässä mallissa
operation-template-field-status = Tapahtuman tila
operation-template-group-classification = Mallin tiedot luokittelua ja tilastojen laskentaa varten
operation-template-field-category = Luokka
operation-template-field-assignment = Kohdistus
operation-template-field-mode = Maksutapa
operation-template-field-payee = Vastapuoli
operation-template-field-project = Projekti

# Tapahtumalomakkeen ”Malli”-painike: yksi kuvake, kaksi toimintoa.
operation-template-question = Mitä haluat tehdä tapahtumamalleilla?
operation-template-apply = Ota malli käyttöön
operation-template-save-as = Tallenna mallina
operation-template-applied = Malli otettu käyttöön. Tallenna se vahvistamalla lomake.
operation-template-saved-as = Tapahtuma tallennettu mallina.
operation-template-needs-label = Anna tapahtumalle nimi ennen kuin teet siitä mallin.

# --- F26 / F27 — Budjetti (vaihe 11) ------------------------------------
# Kaksi ovea, kaksi kysymystä: joko syötetään oma budjetti tai tarkistetaan,
# onko siinä pysytty. Akselina on budjettikohta, yksikkönä vuosi, ja
# merkkisääntö on sama kuin tapahtumissa — meno kirjoitetaan negatiivisena.

window-budget-entry-title = Budjetin syöttö: vuodelle suunnitellut menot(-) ja tulot(+)
window-budget-control-title = Budjetin seuranta

budget-column-line = Budjettikohta
budget-none = Yhtään budjettikohtaa ei ole tallennettu: budjetti syötetään kohdittain.
budget-planned = Suunniteltu
budget-actual = Toteutunut
budget-sum = Summa
budget-cumulative = Kertymä
budget-total = Yhteensä
# Muistutus merkkisäännöstä, punaisella syöttötaulukon alla.
# Hänen lauseensa, sanasta sanaan ja välilyönnit mukaan lukien (kuvakaappaus
# ”POINT 004 saisie budget.png”): se on punaisella taulukon alla, ja ikkunan
# otsikko toistaa sen lyhennettynä. Kukaan ei arvaisi sääntöä ilman sitä.
budget-sign-warning = Syötä menot ehdottomasti  negatiivisella merkillä ja suunnitellut tulot positiivisina summina
budget-entry-help = Kirjoita summat ruutuihin ja tallenna sitten.
budget-saved = Budjetti tallennettu.
budget-nothing-changed = Ei tallennettavia muutoksia.
budget-discard-question = Hylätäänkö budjetin muutokset?

# Seurannan Näkymä-valikko: kaksi tapaa lukea sama ero.
budget-menu-display = Näkymä
budget-display-money = Arvot
budget-display-percent = Prosentit
budget-control-help = Vihreä: vähintään yhtä hyvin kuin suunniteltu. Punainen: huonommin.

# --- F09 — Summan siirto kahden tilin välillä (vaihe 12) -----------------
# Tilisiirto ei ole yksi tapahtuma vaan kaksi: veloitus lähdetilillä ja
# hyvitys kohdetilillä. Ne lähtevät yhdessä tai eivät lainkaan.

window-transfer-title = Siirrä summa kahden tilin välillä

transfer-group-source = Veloita summa tältä lähdetililtä
transfer-group-target = Hyvitä summa tälle kohdetilille
transfer-group-description = Tapahtuman kuvaus
transfer-group-nomenclature = Perustietojen tiedot
transfer-group-amount = Siirrettävä summa
transfer-field-source = Lähdetili
transfer-field-target = Kohdetili
transfer-field-label = Kuvaus
transfer-field-reference = Maksun viite
transfer-field-date = Päivämäärä
transfer-field-status = Tapahtuman tila
transfer-field-clearing = Täsmäytyspäivä
transfer-field-category = Luokka
transfer-field-mode = Maksutapa
transfer-field-assignment = Kohdistus
transfer-field-payee = Vastapuoli / kauppiaat
transfer-field-project = Projekti
transfer-field-amount = Summa

# Ainoa painike paneeleissa, jotka ilmoittavat sen sijaan että kysyisivät.
ui-ok = OK
transfer-help = Valitse molemmat tilit: niiden saldot näkyvät tässä.
transfer-title-validate = Tee tilisiirto
# Valitun tilin kolme saldoa, jotta näet mitä tilisiirto merkitsee.
transfer-balances = { $account } — Pankkisaldo: { $bank } · Todellinen saldo: { $real } · Loppusaldo: { $final }
# Paneeli, joka kokoaa yhteen sen mitä juuri kirjoitettiin.
transfer-done = Tilisiirto tehty. { $amount } tililtä ”{ $source }” tilille ”{ $target }” { $date }.

transfer-refusal-accounts-required = Valitse lähdetili ja kohdetili
transfer-refusal-same-account = Lähdetili ja kohdetili eivät voi olla sama tili: tilisiirto menee tililtä toiselle
transfer-refusal-account-gone = Toista näistä kahdesta tilistä ei ole enää olemassa
transfer-refusal-label-required = Kuvaus on pakollinen
transfer-refusal-date-required = Päivämäärä on pakollinen
transfer-refusal-amount = Siirrettävän summan on oltava aidosti positiivinen

# ---------------------------------------------------------------------------
# Vaihe 13 — Excel-taulukon tuonti (F34, F35, yhdistäminen).
# ---------------------------------------------------------------------------

window-excel-import-title = Excel-taulukon tuonti [ Vaihe 1/3 ]: kaappausalueen määrittely
window-excel-fields-title = Excel-taulukon tuonti [ Vaihe 2/3 ]: kenttien yhdistäminen
window-excel-association-title = Excel-taulukon tuonti: tietojen yhdistäminen

# Avattaessa esitettävä kysymys. Excel-tiedosto tehdään käsin: se sisältää
# sen mitä sisältää, eikä osaa sen kantamasta sekamelskasta voi havaita
# mitenkään. Siksi turvaverkko tarjotaan ennen hyppyä.
excel-backup-question = Excel-taulukko tehdään käsin: se voi sisältää päivämääriä, jotka ovat muodoltaan oikein mutta silti vääriä, ja summia, joiden muoto on oikea mutta etumerkki väärä — eikä sitä näe mikään tarkistus. Tuonti kirjoittaa nämä rivit tilillesi. Haluatko varmuuskopioida tietosi ennen aloittamista?

excel-group-file = 1 - Valitse tuotava Excel-tiedosto
excel-pick = Valitse Excel-tiedosto
excel-sheet = Työkirjan taulukko:
excel-group-header = 2 - Määrittele: solujen koordinaatit taulukon otsikkoriville, jolla sarakkeiden nimet ovat.
excel-header-row = Sen ensimmäisen rivin numero, jolla sarakkeiden nimet ovat
excel-first-column = Otsikon alkusarake ( vasemmanpuoleisin sarake ):
excel-column-count = Taulukon sarakkeiden määrä
excel-group-rows = 3 - Määrittele: taulukon tiedot sisältävän luettelon alku- ja loppurivin numerot ( otsikkorivin alapuolelta ja sitä mukaan lukematta )
excel-first-data-row = Ensimmäinen rivi, jolla on tietoja
excel-last-data-row = Viimeinen rivi, jolla on tietoja:
excel-group-shape = 4 - Määrittele: miten tiedostosi kirjoittaa summat
excel-shape-single = Yksi ainoa summasarake etumerkillä ( menot negatiivisina )
excel-shape-debit-credit = Kaksi erillistä saraketta: Veloitus-sarake ja Hyvitys-sarake
excel-shape-note = Kahden sarakkeen tavassa Veloitus-sarakkeeseen kirjoitettua etumerkkiä ei oteta huomioon: veloitus vie aina rahaa, oli siinä ”-50” tai ”50”.
excel-group-test = 5 - Testinäkymä: katso, millainen kaappaus asetuksillasi syntyy
excel-test = Testaa asetukset, jotka määrittelit vaiheissa 2, 3 ja 4.
excel-test-note = Ohje: alla olevien otsikoiden nimien ja taulukon sisällön on vastattava Excel-taulukkoasi. Kaappausalue ei saa ulottua taulukon alueen ulkopuolelle.

excel-help = Käy viisi ryhmää läpi järjestyksessä ja testaa sitten: pääset vaiheeseen 2 vasta kun olet katsonut, mitä alue nappaa.
excel-no-file = Valitse ensin tuotava Excel-tiedosto.
excel-not-tested = Asetukset muuttuivat: aja testinäkymä uudelleen ennen vahvistamista.
excel-tested = Kaapattu alue: { $rows } riviä, { $columns } saraketta. Tarkista, että alla oleva taulukko muistuttaa omaa taulukkoasi.
excel-empty-capture = Ilmoittamasi alue ei nappaa yhtään riviä: tarkista rivien ja sarakkeiden numerot.
excel-title-next = Siirry seuraavaan vaiheeseen
excel-into-account = Tuonti tilille ”{ $account }”.

excel-tab-links = Kenttien väliset yhteydet
excel-tab-settings = Tuonnin asetukset
excel-column-excel = Otsikko_Excel
excel-column-radinus = Kenttä_Radinus
excel-links-help = Kerro jokaisen taulukkosi sarakkeen kohdalla, minkä Radinuksen kentän se täyttää. Sarakkeita, joihin jää [IGNORE], ei tuoda.
excel-group-category = Kategoriat ilman vastinetta
excel-group-payment-mode = Maksutavat ilman vastinetta
excel-group-assignment = Kohdistukset ilman vastinetta
excel-policy-create = { $kind ->
    [payment-mode] Luo puuttuvat maksutavat automaattisesti
    [assignment] Luo puuttuvat kohdistukset automaattisesti
   *[category] Luo puuttuvat kategoriat automaattisesti
}
excel-policy-ask = { $kind ->
    [payment-mode] Kysy jokaisen puuttuvan maksutavan kohdalla, minne tiedot siirretään
    [assignment] Kysy jokaisen puuttuvan kohdistuksen kohdalla, minne tiedot siirretään
   *[category] Kysy jokaisen puuttuvan kategorian kohdalla, minne tiedot siirretään
}
excel-policy-blank = { $kind ->
    [payment-mode] Jätä maksutapa tyhjäksi
    [assignment] Jätä kohdistus tyhjäksi
   *[category] Jätä kategoria tyhjäksi
}
excel-policy-default = { $kind ->
    [payment-mode] Siirrä puuttuvat maksutavat oletusmaksutapaan
    [assignment] Siirrä puuttuvat kohdistukset oletuskohdistukseen
   *[category] Siirrä puuttuvat kategoriat oletuskategoriaan
}
excel-define-destination = Määritä kohde
excel-not-linked = { $kind ->
    [payment-mode] Mikään sarake ei täytä maksutapaa: tämä asetus ei ole käytössä.
    [assignment] Mikään sarake ei täytä kohdistusta: tämä asetus ei ole käytössä.
   *[category] Mikään sarake ei täytä kategoriaa: tämä asetus ei ole käytössä.
}
excel-fields-help = Säädä vastaavuudet ja sitten kolme sääntöä, ennen kuin käynnistät tuonnin.
excel-title-import = Käynnistä tuonti

excel-refusal-required = Kenttien Päivämäärä, Kuvaus ja Summa on ehdottomasti osoitettava Excel-sarakkeisiin
excel-refusal-column-twice = Eri Radinus-kentät osoittavat samaan Excel-sarakkeeseen: yksi sarake voi täyttää vain yhden kentän
excel-refusal-field-twice = Sama Radinus-kenttä on yhdistetty kahteen Excel-sarakkeeseen: niitä voi olla vain yksi
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Valitsit, että tuntemattomien maksutapojen kohdalla kysytään, minne ne siirretään: paina ”Määritä kohde” ennen tuonnin käynnistämistä.
    [assignment] Valitsit, että tuntemattomien kohdistusten kohdalla kysytään, minne ne siirretään: paina ”Määritä kohde” ennen tuonnin käynnistämistä.
   *[category] Valitsit, että tuntemattomien kategorioiden kohdalla kysytään, minne ne siirretään: paina ”Määritä kohde” ennen tuonnin käynnistämistä.
}

excel-column-data = Tiedot_Excel
excel-column-destination = { $kind ->
    [payment-mode] Maksutapa_Radinus
    [assignment] Kohdistus_Radinus
   *[category] Kategoria_Radinus
}
excel-association-help = Valitse jokaisen taulukostasi tulevan arvon kohdalle se Radinuksen arvo, johon se sijoitetaan. Tyhjäksi jätetty rivi jää luokittelematta.
excel-association-none = Ei yhtään tuntematonta arvoa: kaikki mitä taulukkosi kantaa, on jo Radinuksessa.

excel-imported = Tuonti valmis: { $count } tapahtumaa kirjoitettu, { $refused } riviä hylätty, { $created } perustietoarvoa luotu.
excel-report-title = Tuonnin raportti
excel-column-row = Excel-rivi
excel-column-content = Sisältö
excel-column-reason = Hylkäyksen syy
excel-nothing-refused = Kaikki taulukkosi rivit menivät läpi: ei yhtään hylkäystä.

excel-refused-date = Päivämäärä puuttuu tai on lukukelvoton
excel-refused-amount = Summa puuttuu tai on lukukelvoton
excel-refused-amount-both = Summa sekä Veloitus- että Hyvitys-sarakkeessa: valintaa on mahdoton tehdä
excel-refused-amount-missing = Tällä rivillä ei ole veloitusta eikä hyvitystä

# ---------------------------------------------------------------------------
# Vaihe 16 — toistuvat tapahtumat (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Toistuvien tapahtumien luettelo
window-recurring-form-title = Kortti, joka määrittelee toistuvan tapahtuman luontisäännön
window-recurring-calendar-title = Ehdotettu kalenteri tapahtumista, jotka lisätään pankkitileillesi

recurring-column-label = KUVAUS
recurring-none = Yhtään toistuvaa sääntöä ei ole tallennettu.
recurring-help = Valitse sääntö ja sitten kalenteri nähdäksesi, mitä eräpäiviä se ehdottaa.
recurring-title-calendar = Ehdota eräpäivien kalenteria
recurring-deleted = { $count ->
    [0] Yhtään sääntöä ei poistettu.
    [one] Yksi sääntö poistettu. Sen tapahtumat jäävät tilille.
   *[other] { $count } sääntöä poistettu. Niiden tapahtumat jäävät tileille.
}
recurring-gone = Tätä sääntöä ei ole enää olemassa.
recurring-delete-question = Poistetaanko valitut säännöt? Tapahtumat, jotka ne ovat jo lisänneet, jäävät tileillesi.

recurring-group-identity = Tunnistetiedot ja pankkitili
recurring-group-nomenclature = Perustiedot
recurring-group-amount = Tapahtuman summan määrittely
recurring-group-period = Välin määrittely
recurring-group-ending = Jakson päättymisehdot
recurring-group-produced = Tietoja jo lisätyistä tapahtumista ( vain katseltavaksi )

recurring-field-id = Tapahtuman tunniste
recurring-field-account = Kohdetili
recurring-field-label = Kuvaus
recurring-field-category = Kategoria
recurring-field-mode = Maksutapa
recurring-field-assignment = Kohdistus
recurring-field-payee = Vastapuoli / kauppias
recurring-field-project = Projekti
recurring-field-direction = Tapahtuman tyyppi
recurring-field-amount = Summa
recurring-field-next = Seuraavan tapahtuman päivä
recurring-field-every = Sitten joka
recurring-field-end-date = Päättymispäivä
recurring-field-repeat = Toistojen määrä
recurring-field-guid = Tapahtuman GUID
recurring-field-produced-count = Lisättyjen tapahtumien määrä
recurring-field-produced-last = Viimeksi lisätyn tapahtuman päivä
recurring-field-produced-total = Luotujen summien yhteismäärä

recurring-unit-day = Päivä
recurring-unit-week = Viikko
recurring-unit-month = Kuukausi
recurring-unit-quarter = Neljännesvuosi
recurring-unit-year = Vuosi
recurring-ending-no-limit = Ilman rajaa
recurring-ending-until-date = Päättymispäivän kanssa
recurring-ending-repeat-count = Toistojen määrä

recurring-title-erase = Poista tapahtumat, jotka tämä sääntö on jo lisännyt
recurring-erase-question = { $count ->
    [one] Tämä sääntö on lisännyt tileillesi yhden tapahtuman. Haluatko poistaa sen? Saldot lasketaan uudelleen, eikä sääntö peräänny.
   *[other] Tämä sääntö on lisännyt tileillesi { $count } tapahtumaa. Haluatko poistaa ne kaikki? Saldot lasketaan uudelleen, eikä sääntö peräänny.
}
recurring-erase-none = Tämä sääntö ei ole vielä lisännyt yhtään tapahtumaa.
recurring-erased = { $count ->
    [0] Yhtään tapahtumaa ei poistettu.
    [one] Yksi tapahtuma poistettu, saldot laskettu uudelleen.
   *[other] { $count } tapahtumaa poistettu, saldot laskettu uudelleen.
}

recurring-calendar-help = Poista roskakorilla ne eräpäivät, joita et halua, ja vahvista sitten loput lisättäviksi.
recurring-calendar-none = Ei yhtään ehdotettavaa eräpäivää: tarkista sääntöjesi seuraavan tapahtuman päivä ja tili.
recurring-calendar-column-account = Tili
recurring-calendar-column-date = Päivä
recurring-calendar-column-label = Kuvaus
recurring-calendar-column-amount = Summa
recurring-calendar-column-category = Kategoria
recurring-calendar-column-assignment = Kohdistus
recurring-calendar-column-mode = Maksutapa
recurring-calendar-column-payee = Vastapuoli
recurring-calendar-column-project = Projektit
recurring-calendar-removed = { $count ->
    [one] Yksi eräpäivä poistettu ehdotuksesta.
   *[other] { $count } eräpäivää poistettu ehdotuksesta.
}
recurring-title-insert = Lisää valitut eräpäivät tileille
recurring-nothing = Yhtään lisättävää eräpäivää ei ole jäljellä.
# Kysymys ennen kirjoittamista: kalenterin lisääminen luo oikeita tapahtumia
# oikeille tileille, eikä sitä tehdä hajamielisellä klikkauksella.
recurring-insert-question = { $count ->
    [one] Lisätäänkö tämä eräpäivä tilillesi? Yksi tapahtuma luodaan ja saldot lasketaan uudelleen.
   *[other] Lisätäänkö nämä { $count } eräpäivää tileillesi? Yhtä monta tapahtumaa luodaan ja saldot lasketaan uudelleen.
}
recurring-inserted = { $count ->
    [one] Yksi tapahtuma lisätty. Sääntö jatkuu viimeisen lisätyn eräpäivän jälkeen.
   *[other] { $count } tapahtumaa lisätty. Säännöt jatkuvat viimeisen lisätyn eräpäivänsä jälkeen.
}

recurring-refusal-label-required = Kuvauksen syöttäminen on pakollista
recurring-refusal-date-required = Seuraavan tapahtuman päivän syöttäminen on pakollista
recurring-refusal-date-too-old = Seuraavan tapahtuman päivän on oltava vuodesta 2000 alkaen
recurring-refusal-account-gone = Määriteltyä pankkitiliä ei löydy; valitse uusi tili, jotta sääntö on käyttökelpoinen
recurring-refusal-end-required = Jos päättymispäivä on käytössä, se on syötettävä
recurring-refusal-end-before-start = Päättymispäivä ei voi olla aikaisempi kuin seuraavan tapahtuman päivä
recurring-refusal-end-too-far = Seuraavan tapahtuman päivän ja päättymispäivän välinen ero ei voi ylittää 10 000 päivää

# --- Vaihe 15 — tulosteet ja raportit -----------------------------------
# Palkin iso otsikko, sanasta sanaan alkuperäisestä WinDev-raportista.
print-operations-title = Pankkitapahtumien ja osatapahtumien luettelo
print-menu-operations-pdf = Tulostus PDF-tiedostoon
print-recap-title = Yhteenveto luokittain
print-recap-count = Rivejä
print-row-count = Rivien määrä:
print-total-debit = Veloitukset yhteensä:
print-total-credit = Hyvitykset yhteensä:
print-final-balance = Loppusaldo:
print-licence = Radinus on vapaa ohjelmisto, jota levitetään GNU GPL v3 -lisenssillä tai uudemmalla
print-nothing = Ei ole mitään tulostettavaa.
print-done = Raportti tulostettu ja avattu: ”{ $file }”.
print-failed = Tulostus epäonnistui: { $reason }
# PDF on kirjoitettu oikein, mutta järjestelmä ei osannut avata sitä: se
# kerrotaan antamatta ymmärtää, että kyseessä olisi virhe — tiedosto on tallessa.
print-not-opened = Raportti tulostettu tiedostoon ”{ $file }”, mutta järjestelmäsi ei osannut avata sitä itse.

# --- RIB-raportti (F32) -------------------------------------------------
# Pankkiyhteystietojen otsikot, alkuperäisestä asiakirjasta.
rib-title = PANKKIYHTEYSTIEDOT
rib-bank = Pankki:
rib-national = RIB - Kansallinen tilitunnus
rib-establishment = RAHALAITOS
rib-branch = KONTTORI
rib-number = TILINUMERO
rib-key = RIB-TARKISTUSNUMERO
rib-domiciliation = TILINHOITAJAKONTTORI
rib-iban = IBAN - Kansainvälinen tilitunnus
rib-bic = BIC - Rahalaitoksen kansainvälinen tunnus
rib-holder = Tilinomistaja

# --- Ikkuna F32 ---------------------------------------------------------
window-rib-title = RIB-tuloste ( Relevé d'Identité Bancaire )
rib-group-bank = Pankki
rib-group-holder = Tilinomistaja
rib-group-details = Pankkiyhteystiedot
rib-field-bank = Pankin nimi
rib-field-domiciliation = Tilinhoitajakonttori
rib-field-holder = Omistajan nimi
rib-field-address = Osoite
rib-field-establishment = Rahalaitos
rib-field-branch = Konttori
rib-field-number = Tilinumero
rib-field-key = RIB-tarkistusnumero
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Tärkeät käyttöehdot, joita on ehdottomasti noudatettava tulostettaessa
rib-declaration = Minä allekirjoittanut, tämän ohjelmiston käyttäjä, vakuutan kunniani kautta:
rib-declaration-first = - Vahvistan tarkistaneeni pankistani, että tässä ikkunassa olevat pankkitiedot ovat oikein ja tahtoni mukaiset . Vahvistan samalla tavoin sitoutuvani tarkistamaan, että RIB-tulosteessa olevat tiedot ovat oikein ja tahtoni mukaiset. Tämä tulostus ja RIB:n käyttö tapahtuu täysin omalla vastuullani
rib-declaration-second = - Olevani sen tilin omistaja, jonka RIB tulostetaan, enkä käytä tämän ohjelmiston toimintoja lainvastaiseen tarkoitukseen.
rib-title-print = Tulostus tulostimelle
rib-title-pdf = Tulostus PDF-tiedostoon
# Valintaruutu ei ole koristeellinen varoitus: niin kauan kuin sitä ei ole
# rastitettu, molemmat painikkeet ovat pois käytöstä (Fabricen päätös, 01/08/2026).
rib-declaration-required = Rastita kunnian kautta annettava vakuutus, jotta voit tulostaa.
rib-help = Tarkista tietosi, rastita vakuutus ja tulosta sitten.
rib-account-gone = Tätä pankkitiliä ei löydy.
rib-fields-read-only = Nämä tiedot tulevat tilin tiedoista: korjaa ne siellä, niin ne muuttuvat myös täällä.
rib-printed = RIB lähetetty oletustulostimeesi.
rib-print-failed = Tulostus epäonnistui: { $reason }
rib-pdf-done = RIB tulostettu ja avattu: ”{ $file }”.
rib-pdf-not-opened = RIB tulostettu tiedostoon ”{ $file }”, mutta järjestelmäsi ei osannut avata sitä itse.
menu-accounts-bank-details = Tulosta pankkiyhteystiedot (RIB)

# Tulostimen valinta. Radinus kysyy sen itse: mikään kolmesta
# webview-näkymästä ei avaa järjestelmän tulostusikkunaa.
print-choose-printer = Mille tulostimelle haluat tulostaa?
print-do-print = Tulosta
rib-printed-on = RIB lähetetty tulostimelle ”{ $printer }”.
ui-cancel = Peruuta

# Järjestelmä ei osannut nimetä yhtään tulostinta: tulostetaan silti
# oletustulostimelle sen sijaan, että käyttäjä jäisi jumiin.
print-printers-unknown = Järjestelmäsi ei osannut nimetä yhtään tulostinta: asiakirja lähti oletustulostimelle.

print-menu-operations-printer = Tulostus tulostimelle
print-sent-on = Raportti lähetetty tulostimelle ”{ $printer }”.
print-sent-default = Raportti lähetetty oletustulostimeesi.

# --- Vaihe 17 — tietokantatoiminnot -------------------------------------
backup-archive = Radinus-arkisto
backup-no-database = Yhtään tietokantaa ei ole auki.
backup-done = Varmuuskopio kirjoitettu tiedostoon ”{ $file }”.
backup-failed = Varmuuskopiointi epäonnistui: { $reason }
backup-not-started = Varmuuskopiointia ei voitu aloittaa:
restore-unreadable = Tämä tiedosto ei ole luettava Radinus-arkisto: { $reason }
# Kysymys kertoo, mitä menetetään, ennen kuin se menetetään. Arkisto on jo
# tässä vaiheessa luettu: sen ilmoittama tieto on varmaa.
restore-question = Palautetaanko ”{ $file }”? Tietokantasi koko nykyinen sisältö poistetaan ja korvataan, ja siinä oleva menetetään.
restore-done = Palautus valmis: { $accounts } tiliä ja { $operations } tapahtumaa.
restore-failed = Palautus epäonnistui: { $reason }
restore-empty-fields = Tyhjiä kenttiä luettu nolla-arvona: { $count }.


# --- Teknisten toimintojen loki (vaihe 17) ------------------------------
# Hänen Ajoute_Log-funktionsa kolme tilaa, isoin kirjaimin kuten hänellä.
journal-status-success = ONNISTUI
journal-status-failure = EPÄONNISTUI
journal-status-repaired = KORJATTU
journal-step-reindex = Tietokantataulun korjaus
journal-step-refill = Järjestelmän perustiedot tyhjät: oletusarvot palautettu
journal-step-table-created = Taulu puuttuu tietokannasta: luotu uudelleen tyhjänä
journal-step-column-added = Sarake puuttuu taulusta: lisätty oletusarvollaan

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Salasanasuojaus
window-password-form-title = Salasanasuojaus
password-ask = Tämä tietokanta on suojattu. Anna sen salasana.
password-group-database = Kyseinen tietokanta
password-group-password = Salasana
password-group-warning = Ennen vahvistamista
password-field-old = Vanha salasana
password-field-new = Uusi salasana
password-field-repeat = Toista uusi salasana
password-hint = Jätä vanha tyhjäksi, jos tietokantaa ei ole vielä suojattu. Jätä molemmat uudet tyhjiksi poistaaksesi suojauksen.
password-lost-warning = Kadonnut salasana on kadonnut tietokanta: mikään ei palauta sitä. Varmuuskopiot sen sijaan pysyvät salaamattomina.
password-show = Näytä salasana
password-remove-question = Poistetaanko tämän tietokannan suojaus?
password-mismatch = Uuden salasanan kaksi syöttöä eroavat toisistaan
password-wrong = Salasana ei käy
password-close-first = Sulje tämä tietokanta ennen salasanan vaihtamista
password-now-protected = Tietokanta on suojattu salasanalla
password-now-clear = Tietokantaa ei enää suojata
journal-step-date-fixed = Päivättömän tapahtuman korjaus
journal-step-circular = Epäjohdonmukaisen tapahtuman poisto: kehäviittaus
journal-step-flag-parent-true = Väärä lippu EstParent=Epätosi päätapahtumalla
journal-step-flag-parent-false = Väärä lippu EstParent=Tosi päätapahtumalla
journal-step-flag-child = Väärä lippu EstParent=Tosi osatapahtumalla
journal-step-orphan = Orvon osatapahtuman poisto
journal-step-third-level = Toiseen osatapahtumaan liitetyn osatapahtuman poisto
journal-step-coherence = Osatapahtumien ja päätapahtumien johdonmukaisuuden yleinen uudelleenlaskenta
journal-step-balances = Kaikkien tilien kaikkien saldojen uudelleenlaskenta
journal-step-vacuum = Tietokantatiedoston optimointi
journal-step-analyze = Hakutilastojen päivitys
journal-step-backup-begin = Tietokannan varmuuskopioinnin alku
journal-step-backup-end = Tietokannan varmuuskopioinnin loppu
journal-step-restore-begin = Tietokannan arkistosta palauttamisen alku
journal-step-restore-end = Tietokannan arkistosta palauttamisen loppu
journal-step-restore-read = Arkiston lukeminen

# --- Lokin ikkuna (⌘H) --------------------------------------------------
window-journal-title = Viimeisimmän teknisen toiminnon loki
journal-column-step = Vaihe
journal-column-file = Tiedosto
journal-column-table = Taulu
journal-column-status = Tila
journal-column-error = Virhe
journal-column-comments = Huomautukset
journal-empty = Yhtään teknistä toimintoa ei ole vielä tehty ohjelmiston käynnistämisen jälkeen.
journal-help = Loki säilyttää vain viimeisimmän teknisen toiminnon: varmuuskopioinnin, palautuksen, korjauksen, poiston tai tietokannan avaamisen.

# --- Korjaus ------------------------------------------------------------
menu-file-repair-running = Korjaus ja optimointi käynnissä…
repair-done = { $anomalies ->
    [0] Korjaus valmis: poikkeamia ei löytynyt. { $lines } vaihetta kirjattu lokiin.
    [one] Korjaus valmis: yksi poikkeama korjattu. { $lines } vaihetta kirjattu lokiin.
   *[other] Korjaus valmis: { $anomalies } poikkeamaa korjattu. { $lines } vaihetta kirjattu lokiin.
}
repair-failed = Korjaus epäonnistui: { $reason }

journal-status-started = KÄYNNISSÄ
journal-status-finished = VALMIS
journal-step-backup-table = Taulun kirjoitus arkistoon
journal-step-backup-write = Arkiston kirjoitus
journal-step-backup-verified = Kirjoitetun arkiston tarkistus: luetut / odotetut tiedostot, luetut / kirjoitetut tietueet
journal-step-backup-total = Varmuuskopioitu yhteensä: tietueet, tiedot, tiedoston koko
journal-step-restore-table = Taulun lukeminen arkistosta
journal-step-restore-missing = Tiedosto puuttuu arkistosta: tätä taulua ei palauteta
journal-step-restore-wipe = Tietokannan sisällön täydellinen poisto ennen palautusta
journal-step-restore-write = Kirjoitus tietokantaan
journal-step-restore-total = Palautettu yhteensä: tilit, tapahtumat
journal-step-restore-empty-fields = Lukemisen aikana täytetyt tyhjät kentät
backup-verify-mismatch = Kirjoitettua arkistoa ei saada luettua takaisin sellaisena kuin se kirjoitettiin: älä luota siihen, tee varmuuskopio uudelleen.

# --- Tapahtuman liitteet (F28, vaihe 17) --------------------------------
window-attachments-title = Tapahtuman liitteet
attachment-filter = Hyväksytyt asiakirjat
attachment-none = Tässä tapahtumassa ei ole yhtään liitettä.
attachment-title-add = Liitä asiakirja tähän tapahtumaan
attachment-title-open = Avaa liite
attachment-title-remove = Poista liite ja siirrä sen tiedosto roskakoriin
# Tiedoston tila levyllä. ”Ei tarkistettavissa” ei ole turha tietämättömyyden
# tunnustus: Radinus 1.9.3:sta tulleet tiivisteet ovat tallennusmuodon vuoksi
# typistyneitä, ja tiedoston tuomitseminen niiden perusteella olisi umpimähkäistä syyttelyä.
attachment-state-ok = Ehjä
attachment-state-changed = Muuttunut
attachment-state-missing = Tiedosto puuttuu
attachment-state-unknown = Ei tarkistettavissa
attachment-added = ”{ $name }” on liitetty tapahtumaan.
attachment-removed = Liite poistettu, sen tiedosto on roskakorissa.
attachment-removed-kept = Liite poistettu, mutta sen tiedostoa ei saatu siirrettyä roskakoriin.
attachment-remove-question = Poistetaanko ”{ $name }” tästä tapahtumasta? Sen tiedosto siirretään roskakoriin.
attachment-opened = ”{ $name }” on avattu.
attachment-opened-changed = ”{ $name }” on avattu, mutta sen sisältö on muuttunut liittämisen jälkeen.
attachment-gone = Tätä liitettä ei ole enää olemassa.
attachment-file-missing = Liitteen ”{ $name }” tiedostoa ei löydy levyltä.
attachment-failed = Toiminto epäonnistui: { $reason }
attachment-save-first = Tallenna ensin tapahtuma: liite kiinnittyy tapahtumaan, joka on olemassa.
attachment-refusal-missing = Tätä tiedostoa ei ole olemassa.
attachment-refusal-extension = Tämä tiedostotyyppi ei ole hyväksytty. Hyväksytyt ovat: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = Tapahtumaa, johon tämä asiakirja liitettäisiin, ei ole olemassa.
journal-step-backup-attachments = Arkistoon lisätyt liitteet
journal-step-backup-attachment-missing = Liitettä ei löydy levyltä: se puuttuu arkistosta
journal-step-restore-attachments = Arkistosta puretut liitteet
attachment-title-replace = Korvaa tämän liitteen asiakirja
attachment-replaced = Asiakirja on korvattu tiedostolla ”{ $name }”.

# ---------------------------------------------------------------------
# F08 — tilin tietojen ”Työkalut”-valikko.
#
# Sen kolme kohtaa ovat käännöksiä Fabricen WLangage-koodista (kansio
# ”Information import export base piece jointe”): täsmäytetyn alkusaldon
# laskenta, tilin tilastot ja kaikkien sen tapahtumien poisto. Valikko
# toimii vain muokkaustilassa (päätös 02/08/2026): luontivaiheessa ei ole
# mitään laskettavaa, ja katselutilassa tiedot vain näytetään.
# ---------------------------------------------------------------------

account-tools = Työkalut
account-tools-initial-balance = Määritä täsmäytetty alkusaldo
account-tools-statistics = Pankkitilin tilastot
account-tools-delete-operations = Poista tilin kaikki tapahtumat

# Laskennan kysymys, sanasta sanaan alkuperäisen mukaan. { $total } on
# täsmäytettyjen tapahtumien summa, valmiiksi rahamuodossa.
account-initial-balance-question =
    Jotta täsmäytetty alkusaldo voidaan laskea tällä tilillä olevien tapahtumien perusteella, ilmoita pankkisi nykyinen saldo
    Täsmäytetty alkusaldo lasketaan seuraavasti:
    { "[" }Nykyinen pankkisaldo] - [Täsmäytetyt tapahtumat yhteensä ({ $total }) ].
    { "" }
    Jotta sinun ei tarvitse syöttää tätä arvoa uudelleen, tämän tilin pankkitapahtumien luettelon on oltava täysin ajan tasalla.

account-statistics-none = Ei tapahtumia

# Hänen Info()-kutsunsa neljätoista riviä. Alkuperäisen kirjoitusvirhe
# ”pengagés” on korjattu Fabricen 02/08/2026 tekemällä päätöksellä — kuten
# ”Bank Identifer Code” samalla lomakkeella.
account-statistics =
    Tapahtumien kokonaismäärä tällä tilillä: { $count }
    { "" }
    Täsmäytettyjen tapahtumien määrä tällä tilillä: { $pointed }
    Täsmäytettyjen veloitusten summa: { $pointedDebits }
    Täsmäytettyjen hyvitysten summa: { $pointedCredits }
    Täsmäytettyjen hyvitysten ja veloitusten erotus: { $pointedDifference }
    { "" }
    Varattujen tapahtumien määrä tällä tilillä: { $committed }
    Varattujen veloitusten summa: { $committedDebits }
    Varattujen hyvitysten summa: { $committedCredits }
    Varattujen hyvitysten ja veloitusten erotus: { $committedDifference }
    { "" }
    Suunniteltujen tapahtumien määrä tällä tilillä: { $planned }
    Suunniteltujen veloitusten summa: { $plannedDebits }
    Suunniteltujen hyvitysten summa: { $plannedCredits }
    Suunniteltujen hyvitysten ja veloitusten erotus: { $plannedDifference }
    { "" }
    Vanhin tapahtuma: { $first }
    Uusin tapahtuma: { $last }

# Poistamisen kaksinkertainen este. { $word } on nykykielen ”kyllä” — espanjaa
# puhuva ei ymmärtäisi, jos häntä pyydettäisiin kirjoittamaan OUI (Fabricen
# päätös, 02/08/2026).
account-delete-operations-question =
    Haluatko varmasti poistaa kaikki pankkitilin tapahtumat?
    Kirjoita vahvistukseksi { $word } alla olevaan kenttään ja vahvista

account-delete-operations-done =
    { $count ->
        [0] Yhtään tapahtumaa ei poistettu.
        [one] 1 tapahtuma poistettu.
       *[other] { $count } tapahtumaa poistettu.
    }

# ---------------------------------------------------------------------
# Tietokannan valitsin ja kielen valinta (02/08/2026)
#
# Fabricen kanssa keskustellen tehdyt päätökset: Radinus ei enää luo
# tietokantaa ilman lupaa; jos asetuksissa ei ole kieltä, se kysyy kielen
# ennen kaikkea muuta; tietokanta on jokainen databases/-kansion kansio,
# jossa on radinus.sqlite, oli sen nimi mikä tahansa.
#
# Kielen valinnan ikkunassa ei ole yhtään avainta: se ei käytä yhtään
# lausetta, ja juuri siksi se ymmärretään jo ennen kuin tiedetään, mitä
# kieltä käyttäjä puhuu.
# ---------------------------------------------------------------------

window-database-selector-title = Tietokannat
window-database-form-title = Uusi tietokanta
database-group-identity = Tietokannan tunnistetiedot
database-group-restore = Alusta tietokanta varmuuskopion tiedoilla
database-choose-backup = Valitse varmuuskopiotiedosto
database-no-backup = Varmuuskopiota ei valittu: tietokanta luodaan tyhjänä.

databases-column-label = Tietokanta
databases-column-comment = Kommentti
databases-column-folder = Kansio
databases-column-created = Luotu

databases-none = Ei vielä yhtään tietokantaa: luo sellainen.
databases-help = Valitse avattava tietokanta tai luo uusi.
databases-select = Valitse ensin tietokanta luettelosta.
databases-tools = Työkalut
databases-title-open = Avaa tämä tietokanta

database-created = Tietokanta ”{ $label }” on luotu.
database-field-label = Tietokannan nimi
database-field-comment = Kommentti
database-label-required = Anna tälle tietokannalle nimi: se erottaa sen muista.
database-gone = Tätä tietokantaa ei enää ole: se on siirretty tai poistettu tämän ikkunan avaamisen jälkeen.

# Tietokannan poistaminen (02/08/2026). Kansio menee järjestelmän
# roskakoriin, kuten liitteet: vahingossa poistettu tietokanta palautuu hiiren
# oikealla painikkeella. Avointa tietokantaa ei poisteta — Radinus pitää
# kiinni sen tiedostosta.
databases-title-delete = Poista tämä tietokanta
database-delete-question =
    Haluatko varmasti poistaa tietokannan ”{ $label }”?
    { "" }
    Koko sen kansio menee roskakoriin: tapahtumat, tilit ja liitteet.
    Kirjoita vahvistukseksi { $word } alla olevaan kenttään ja vahvista.
database-in-use = Tämä tietokanta on auki: Radinus ei voi poistaa sitä. Avaa ensin jokin toinen.
database-deleted = Tietokanta ”{ $label }” on roskakorissa.

# Valitsimella on kaksi tilaa (Fabrice, 02/08/2026). Kesken käytön avattuna se
# ei enää osaa avata: Radinuksen ikkuna rakennetaan kerran eikä sitä koskaan
# pureta, eikä mikään saa sitä unohtamaan tietokantaa, jota se näyttää. Voit
# katsella, luoda ja poistaa — ja tietokantaa vaihtaaksesi lopetat ohjelman.
database-quit-first = Avataksesi tämän tietokannan lopeta Radinus ja käynnistä se uudelleen: valitsin tarjoaa sitä sinulle käynnistyksessä.


# --- F01 — aloitusikkuna (vaihe 17 bis, 03/08/2026) ----------------------
#
# Ensimmäinen lisäys 2.0.0:ssa version 1.9.3 päälle: aloitusikkunassa ei ole
# enää pelkkä banneri. Sitä ohjaava sääntö on kirjoitettu asiakirjaan 04 F01:
# se on näkymä ILMAN YHTÄÄN NAPSAUTUSTA, eikä sinne tule mitään, mikä vaatii
# säätämistä.
#
# Molemmat rengaskaavioiden otsikot sisältävät koko kuukauden sen sijaan, että
# ikkuna liittäisi ne peräkkäin: ”Menot ... — elokuu 2026” ei ole kolmella
# kielellä sanajärjestykseltään sama, ja vain Fluent tietää, missä aukko on.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Ei yhtään avointa tiliä
    [one] 1 avoin tili
   *[other] { $count } avointa tiliä
}
welcome-total-bank = Pankkisaldo
welcome-total-real = Todellinen saldo
welcome-total-final = Loppusaldo
welcome-total-real-detail = täsmäytetty + varattu
welcome-total-final-detail = täsmäytetty + varattu + suunniteltu
welcome-accounts = Tilisi
welcome-tile-bank = Pankissa
welcome-tile-real = Todellinen
welcome-tile-final = Lopullinen
welcome-spending = Menot — { $month }
welcome-earning = Tulot — { $month }
ui-legend-budget-lines = Budjettikohdat
ui-legend-categories = Luokat
welcome-nothing = Ei yhtään tapahtumaa tässä kuussa.
welcome-open-account = Info: napsauta tiliä, niin sen tapahtumat avautuvat.
welcome-no-account = Ei vielä yhtään pankkitiliä.
welcome-no-account-create = Luo pankkitili napsauttamalla tästä
welcome-previous-month = Edellinen kuukausi
welcome-next-month = Seuraava kuukausi
welcome-refresh = Lue kaikki uudelleen


# --- F39 — valinnat (vaihe 17 ter, 03/08/2026) ---------------------------
#
# Valuuttamerkin paikka on täällä, kahden erottimen vieressä: se seuraa kieltä
# eikä valuuttaa. ”before” asettaa merkin luvun eteen, mikä tahansa muu arvo
# sen taakse. Tähän tiedostoon EI kirjoiteta yhtään valuuttamerkkiä: ”ranska”
# ei tarkoita ”euroa”.

ui-money-sign-position = after
window-preferences-title = Valinnat
menu-settings-preferences = Valinnat…
menu-settings-show-main = Näytä pääikkuna
menu-settings-folders = Radinus-kansiot
preferences-branch-display = Näyttö
preferences-leaf-language = Kieli
preferences-leaf-currency = Valuutta
preferences-field-language = Ohjelman kieli:
preferences-field-currency = Näytettävä valuutta:
preferences-field-custom = Valuutan merkki:
preferences-currency-system = Järjestelmän valuutta
preferences-currency-euro = Eurot
preferences-currency-dollar = Dollarit
preferences-currency-canadian = Kanadan dollarit
preferences-currency-cfa = CFA-frangit
preferences-currency-cfp = CFP-frangit
preferences-currency-swiss = Sveitsin frangit
preferences-currency-none = Ei mitään
preferences-currency-custom = Mukautettu
preferences-currency-system-is = Järjestelmäsi ilmoittaa:
preferences-currency-system-silent = Järjestelmäsi ei ilmoita valuuttaa: summat näytetään euroina.
preferences-custom-required = Kirjoita valuuttasi merkki ennen tallentamista.
preferences-saved = Valinnat tallennettu.
preferences-help = Valitse vaihtoehto puusta ja tallenna sitten.
preferences-sign-too-long = Valuutan merkkiin mahtuu enintään 8 merkkiä.
preferences-sign-not-a-number = Valuutan merkissä ei voi olla numeroa, laskumerkkiä eikä pilkkua: Radinus poistaa ne lukiessaan summan, ja ”120” muuttuisi muotoon ”12”.
preferences-leaf-zoom = Näytön koko
preferences-field-zoom = Suurennus:
preferences-zoom-reset = Oletusarvo
preferences-zoom-hint = Kaikki suurenee yhdessä: teksti, kuvakkeet ja sarakkeet. Alle 100 %:n koossa näytölle mahtuu enemmän. Järjestelmän valikkorivi ja sen valintaikkunat sen sijaan noudattavat tietokoneesi asetuksia eivätkä näitä.

# --- Aloitusnäytön banneri -----------------------------------------------
#
# Nämä lauseet oli kirjoitettu kovakoodattuina tiedostoon `index.html` vaiheesta
# 0 lähtien, eivätkä ne siksi kääntyneet (Fabricen havainto 03/08/2026).
# Tunnuslause on hänen äänensä: englannin- ja espanjankieliset versiot ovat
# ehdotuksia, jotka hän korjaa — tunnuslausetta ei käännetä sana sanalta.
ui-language-tag = fi
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — orava-maskotti puvussa, ympärillään euro, laskin ja kaavioita
welcome-slogan-one = Henkilökohtaisen talouden hallintaohjelma, joka auttaa sinua kuluttamaan vähemmän ja ansaitsemaan enemmän
welcome-slogan-two = Radinuksen avulla ymmärrät, miksi pienistä puroista syntyy suuria virtoja.

# --- ”Tietoja tekijästä” -------------------------------------------------
#
# Nimi ja osoite kirjoitetaan samalla tavalla kaikkiin kolmeen tiedostoon:
# niitä ei käännetä. Ne ovat silti täällä eivätkä sivulla, jotta näkymässä ei
# olisi yhtään lausetta — ja jotta ne korjattaisiin yhdessä ainoassa paikassa
# sinä päivänä, kun tekijä muuttaa.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Tietoja tekijästä
about-author-flag-alt = Korsikan lippu — maurin pää

# --- ”Tietoja Radinuksesta” ----------------------------------------------
#
# `about-radinus-version` sisältää aukon: numero tulee suoritettavasta
# binääristä, ei koskaan kopioidusta merkkijonosta. Se ei siis ole ikkunoiden
# sanakirjassa — komento `app_version` täyttää sen.
window-about-radinus-title = Tietoja Radinuksesta
about-radinus-name = Radinus
about-radinus-version = Versio { $version }
about-radinus-rust-alt = Rust-kielen logo
about-radinus-tauri-alt = Taurin logo
about-radinus-built = Radinus on kirjoitettu Rustilla ja rakennettu Taurilla. Ensimmäinen laskee tilisi, jälkimmäinen tekee siitä työpöytäsovelluksen.
about-radinus-licence = Vapaa ohjelmisto, GNU GPL v3 -lisenssillä.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Käyttöoikeus
licence-heading = RADINUS-OHJELMISTON KÄYTTÖOIKEUS
licence-logo-alt = GNU General Public License version 3 logo
licence-name = GNU GPL v3 tai uudempi
licence-intro = Radinus on vapaa ohjelmisto.
licence-freedoms-title = Sen lisenssi antaa sinulle neljä vapautta:
licence-freedom-use = Käyttää sitä haluamallasi tavalla, mihin haluat.
licence-freedom-study = Tutkia sen lähdekoodia, joka on avoin kaikille.
licence-freedom-share = Kopioida sitä ja antaa sitä eteenpäin.
licence-freedom-improve = Muuttaa sitä ja jakaa muutoksesi.
licence-read = Lue lisenssin koko teksti

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Tämä ohjelma toimitetaan ilman mitään takuuta, siinä määrin kuin laki sallii.
licence-info = Virallinen teksti avautuu selaimessasi osoitteessa gnu.org.

