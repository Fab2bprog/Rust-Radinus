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
menu-statistics-balance-analysis = Saldon kehityksen analyysi
menu-statistics-by-category = Tilastot kategorioittain
menu-statistics-by-assignment = Tilastot kohdistuksittain
menu-statistics-by-budget-line = Tilastot budjettikohdittain
menu-statistics-by-payment-mode = Tilastot maksutavoittain
menu-statistics-by-payee = Tilastot vastapuolittain ja kauppiaittain
menu-statistics-by-project = Tilastot projekteittain
menu-statistics-by-verification = Tilastot tarkistuksittain
menu-statistics-dashboard = Tapahtumien koontinäyttö
menu-statistics-crossed-balance = Ristiintaulukointi

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

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Työkalut
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
operations-column-status = Tapahtuman tila
operation-status-pointed = Täsmäytetty
operation-status-committed = Varattu
operation-status-planned = Suunniteltu
operations-column-verification = Tarkistus
operation-verification-to-verify = Tarkistettava
operation-verification-verified = Tarkistettu
operation-verification-doubtful = Epäilyttävä
operation-verification-disputed = Riitautettu
operations-column-label = Kuvaus
operations-column-reference = Maksun viite
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
filter-by-status = Suodata tilan mukaan
filter-by-verification = Suodata tarkistuksen mukaan
filter-show-all = Näytä kaikki

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
operation-field-verification = Tarkistus
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
operation-clearing-date-required = Täsmäytetyllä tapahtumalla on oltava täsmäytyspäivä.
operation-clearing-date-question =
    Täsmäytetyllä tapahtumalla on oltava täsmäytyspäivä.
    Haluatko tallentaa tapahtuman omalla päivämäärällä { $date }?
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
    [0] Ei täsmäytettäviä tapahtumia: valinta on jo täsmäytetty.
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
operations-recurring-from = Luo toistuva tapahtuma tästä tapahtumasta

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
    [verification] Tilastot tarkistuksittain
   *[category] Tilastot luokittain
}

statistics-axis-column = { $kind ->
    [assignment] Kohdistus
    [budget-line] BudjettiKohta
    [payment-mode] TapahtumaTapa
    [payee] Vastapuoli
    [project] Projektit
    [verification] Tarkistus
   *[category] LuokkaNimi
}

statistics-unclassified = { $kind ->
    [assignment] Ei kohdistusta
    [budget-line] Ei budjettikohtaa
    [payment-mode] Ei maksutapaa
    [payee] Ei vastapuolta
    [project] Ei projektia
    [verification] Tarkistettava
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

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Ristiintaulukointi
crossed-balance-window-name = Ristiintaulukointi
crossed-balance-column = Luokka
crossed-balance-no-data = Ei tapahtumia tässä kuussa valituilla tileillä.
crossed-balance-month-question = Mitä kuukautta haluat tarkastella? Luku väliltä { $first }–{ $last }.
crossed-balance-month-choose = Valitse kuukausi
crossed-balance-next = Seuraava kuukausi
crossed-balance-previous = Edellinen kuukausi

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
export-to = Vie muotoon
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Kopioi solu
copy-rows = Kopioi valitut rivit
copy-failed = Kopiointi leikepöydälle epäonnistui.
export-all-years-excel = Vie kaikki vuodet Exceliin
export-all-years-ods = Vie kaikki vuodet LibreOffice Calciin
export-all-months-excel = Vie näytetyn vuoden kaikki kuukaudet Exceliin
export-all-months-ods = Vie näytetyn vuoden kaikki kuukaudet LibreOffice Calciin
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
    [verification] Tilastot tarkistuksittain
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

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Saldon kehityksen analyysi
analysis-heading = Saldon kehityksen analyysi
analysis-hint = Vedä kuvaajan yli hiiren painike pohjassa nähdäksesi kyseisen jakson tapahtumat.
analysis-zone = Alue:
analysis-opening = Alkusaldo:
analysis-closing = Loppusaldo:
analysis-variation = Muutos:
analysis-detail-name = Saldoanalyysi
analysis-detail-none = Tällä alueella ei ole yhtään tapahtumaa.

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
quick-check-verification = Tarkistus
quick-column-date = Päivä
quick-column-label = Kuvaus
quick-column-amount = Summa
quick-column-category = Luokka
quick-column-assignment = Kohdistus
quick-column-payment-mode = Maksutapa
quick-column-payee = Vastapuoli
quick-column-project = Projektit
quick-column-status = Tila
quick-column-verification = Tarkistus
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
statement-column-reference = Maksun viite
statement-column-debit = Veloitus
statement-column-credit = Hyvitys
statement-account = Tili
statement-file = Tiedosto
statement-difference = Erotus
statement-none = Yhtään tiliotetta ei ole avattu: valitse tiedosto (OFX, CSV, QIF) napsauttamalla keltaista kansiota.
statement-empty = Tämä tiliote ei sisällä yhtään tapahtumaa.
statement-no-match = Yksikään rivi ei vastaa suodatinta.
statement-help = Info: Valitse taulukosta useita rivejä hiiren napsautuksella ja [{ $modifier }]-näppäimellä
statement-choose-account = Tämä tiedosto sisältää useita tilejä. Minkä niistä haluat tuoda?
statement-select-line = Valitse tiliotteelta vähintään yksi rivi.
statement-title-open = Avaa tiliotetiedosto (OFX, QIF, CSV)
statement-title-info = Tietoja avatusta tiedostosta
statement-title-integrate = Liitä valinta tilille
statement-title-validate = Liitä tämä tapahtuma tilille
statement-duplicate = Huomio, kaksoiskappale: tämä tapahtuma näyttää jo olevan liitetty tietokantaan (Financial Institution Transaction ID on jo olemassa)
statement-no-fitid = Huomio: tämä tiedosto ei anna tälle riville mitään tunnistetta (FITID). Kaksoiskappaletta ei voida havaita.
statement-loaded = { $count ->
    [0] Tämä tiedosto ei sisällä yhtään tapahtumaa tälle tilille.
   *[other] { $count } riviä luettu, joista { $known } on jo tililläsi.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } riviä luettu; mikään niistä ei muistuta tapahtumaa, joka on jo tililläsi.
    [one] { $count } riviä luettu, joista yksi muistuttaa tapahtumaa, joka on jo tililläsi (sama päivämäärä, sama kuvaus, sama summa).
   *[other] { $count } riviä luettu, joista { $alike } muistuttaa tapahtumia, jotka ovat jo tililläsi (sama päivämäärä, sama kuvaus, sama summa).
}
statement-loaded-also-alike = { $alike ->
    [one] Vielä yksi muistuttaa tapahtumaa, joka on jo olemassa (sama päivämäärä, sama kuvaus, sama summa).
   *[other] Vielä { $alike } muistuttaa tapahtumia, jotka ovat jo olemassa (sama päivämäärä, sama kuvaus, sama summa).
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
statement-qif-question = Tiedostossa ei ole mitään, mikä kertoisi, onko päivämäärä ”{ $date }” kirjoitettu muodossa päivä/kuukausi vai kuukausi/päivä. Se tarkoittaa:
statement-qif-day-month = Päivä { $day }, kuukausi { $month } (päivä/kuukausi)
statement-qif-month-day = Päivä { $day }, kuukausi { $month } (kuukausi/päivä)
statement-qif-dates-mixed = Tämä tiedosto kirjoittaa päivämääränsä kahdella tavalla: ”{ $first }” luetaan päivä/kuukausi, ”{ $second }” kuukausi/päivä. Tiedostoa ei tuoda, jotta mikään päivämäärä ei vääristy.
statement-qif-amounts-mixed = Tämä tiedosto kirjoittaa summansa kahdella tavalla: ”{ $first }” pisteellä, ”{ $second }” pilkulla. Tiedostoa ei tuoda, jotta mikään summa ei vääristy.
statement-qif-opening = Alkusaldo { $amount } päivältä { $date }: se ei ole tapahtuma, eikä sitä tuoda.
statement-qif-opening-undated = Alkusaldo { $amount }: se ei ole tapahtuma, eikä sitä tuoda.
statement-qif-suspect = Rivi { $rank }, ”{ $label }” ({ $amount }), näyttää alkusaldolta: tarkista se ennen kuin liität sen.
statement-qif-rejected = { $count ->
    [one] Yhtä lukukelvotonta riviä ei tuoda: { $lines }.
   *[other] { $count } lukukelvotonta riviä ei tuoda: { $lines }.
}
statement-qif-reason-date = päivämäärä
statement-qif-reason-amount = summa
statement-qif-reason-differ = ristiriitaiset summat
statement-qif-no-account = Tätä tiliä ei ole enää tiedostossa: avaa tiedosto uudelleen.
statement-balance-unknown = ei ilmoitettu tiedostossa
statement-group-identification = Tapahtuman tunnistetiedot
statement-group-amount = Tapahtuman summa
statement-group-classification = Tapahtuman luokittelu tilastojen laskentaa varten
statement-group-status = Tapahtuman tila
statement-field-date = Päivä
statement-field-label = Kuvaus
statement-field-reference = Maksun viite
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
backup-done = Tietokanta ”{ $base }” on varmuuskopioitu tiedostoon ”{ $file }”. Muihin tietokantoihin tämä ei vaikuta.
backup-failed = Varmuuskopiointi epäonnistui: { $reason }
backup-not-started = Varmuuskopiointia ei voitu aloittaa:
restore-unreadable = Tämä tiedosto ei ole luettava Radinus-arkisto: { $reason }
# Kysymys kertoo, mitä menetetään, ennen kuin se menetetään. Arkisto on jo
# tässä vaiheessa luettu: sen ilmoittama tieto on varmaa.
restore-question = Palautetaanko ”{ $file }” tietokantaan ”{ $base }”? Tämän tietokannan koko nykyinen sisältö poistetaan ja korvataan, ja siinä oleva menetetään. Muihin tietokantoihin ei kosketa.
restore-done = Tietokanta ”{ $base }” on palautettu: { $accounts } tiliä ja { $operations } tapahtumaa. Muihin tietokantoihin ei kosketa.
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
database-too-recent = Tämä tietokanta on tallennettu Radinuksen uudemmalla versiolla (tietokannan versio { $found }; tämä versio lukee versioon { $supported } asti). Päivitä Radinus avataksesi sen.
database-not-radinus = Tämä tiedosto ei ole Radinus-tietokanta.
database-unreadable = Tietokantaa ei voitu lukea: { $reason }
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
    [0] Tietokannan ”{ $base }” korjaus valmis: poikkeamia ei löytynyt. { $lines } vaihetta kirjattu lokiin. Muihin tietokantoihin tämä ei vaikuta.
    [one] Tietokannan ”{ $base }” korjaus valmis: yksi poikkeama korjattu. { $lines } vaihetta kirjattu lokiin. Muihin tietokantoihin tämä ei vaikuta.
   *[other] Tietokannan ”{ $base }” korjaus valmis: { $anomalies } poikkeamaa korjattu. { $lines } vaihetta kirjattu lokiin. Muihin tietokantoihin tämä ei vaikuta.
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
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Summiin lasketut tilit: { $count } / { $total }
welcome-tile-counted = Laske tämä tili mukaan summiin
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
preferences-branch-import = Tuonti
preferences-leaf-verification = Tarkistus
preferences-field-verification = Tuodut tapahtumat:
preferences-verification-hint = ”Tarkistettu”: luotat pankkiisi, tuotu tapahtuma katsotaan oikeaksi. ”Tarkistettava”: jokainen tuotu tapahtuma odottaa tarkistustasi; sen jälkeen merkitset sen itse tilaan ”Tarkistettu” tapahtumaluettelossa. Asetus koskee vain tulevia tuonteja.
preferences-leaf-ofx = OFX-tiliotteet
preferences-field-ofx-label = Tapahtuman kuvaus:
preferences-field-ofx-reference = Maksun viite:
preferences-ofx-choice-name = Tapahtuman nimi
preferences-ofx-choice-memo = Pankin muistio
preferences-ofx-choice-name-and-memo = Nimi ja sen perässä muistio
preferences-ofx-choice-empty = Ei mitään (jätä tyhjäksi)
preferences-ofx-label-help = Mitä tuodun tapahtuman kuvaukseen tulee. Nimi on se, jonka pankki näyttää, esimerkiksi ”PRLV SEPA”; jotkin pankit lisäävät siihen yksityiskohtaisen muistion: suoraveloituksen velkoja, tilisiirron saaja ja aihe. Jos tapahtumalla ei ole muistiota, sen kuvaukseksi jää nimi.
preferences-ofx-reference-help = Mitä tuodun tapahtuman maksun viitteeseen tulee; voit nähdä sen siellä ja suodattaa sen perusteella. Jos tapahtumalla ei ole muistiota, ”Pankin muistio” jättää viitteen tyhjäksi. Jos muistio jo toistaa nimen, sitä ei kirjoiteta kahdesti.
preferences-ofx-hint = Nämä asetukset koskevat kaikkia OFX-tiliotteita riippumatta siitä, mikä tietokanta on auki. Ne otetaan käyttöön seuraavasta avattavasta tiliotteesta alkaen.
preferences-leaf-qif = QIF-tiliotteet
preferences-field-qif-order = Päivän ja kuukauden järjestys:
preferences-qif-order-ask = Kysy minulta joka kerta
preferences-qif-order-day-month = Aina päivä/kuukausi (05/03 = 5. maaliskuuta)
preferences-qif-order-month-day = Aina kuukausi/päivä (05/03 = 3. toukokuuta)
preferences-qif-order-help = Käytetään vain, jos mikään tiedoston päivämäärä ei ratkaise asiaa. Heti kun jokin päivämäärä, kuten 24/11, osoittaa järjestyksen, tiedosto ratkaisee tästä asetuksesta riippumatta.
preferences-field-qif-label = Tapahtuman kuvaus:
preferences-qif-label-both = Vastapuoli + muistio
preferences-qif-label-payee = Vain vastapuoli
preferences-qif-label-memo = Vain muistio
preferences-qif-label-help = Kun tapahtumalla on sekä vastapuoli että muistio. Jos sillä on vain toinen niistä, käytetään sitä tästä asetuksesta riippumatta.
preferences-qif-hint = Nämä asetukset koskevat kaikkia QIF-tiliotteita riippumatta siitä, mikä tietokanta on auki. ”Kysy minulta joka kerta” on turvallisin: tiedostoa, jonka päivämäärät ovat moniselitteisiä, ei koskaan lueta arvaamalla.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Palauta oletussarakkeet
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Näytä/Piilota
columns-colour = Väritä sarake:
columns-colour-none = Ei väriä
columns-colour-red = Punainen
columns-colour-orange = Oranssi
columns-colour-pink = Vaaleanpunainen
columns-colour-pastel-green = Pastellinvihreä
columns-colour-green = Vihreä
columns-colour-pastel-blue = Pastellinsininen
columns-colour-blue = Sininen
columns-colour-pastel-yellow = Pastellinkeltainen
columns-colour-yellow = Keltainen
preferences-leaf-columns = Taulukoiden sarakkeet
preferences-table-operations-list = Tapahtumaluettelo
preferences-columns-reset = Palauta
preferences-columns-reset-all = Palauta kaikki
preferences-columns-done = Sarakkeet on palautettu alkuperäiseen asetteluun.
preferences-columns-hint = Jokainen taulukko muistaa sarakkeidensa järjestyksen, piilottamasi sarakkeet ja niiden leveyden. ”Palauta” palauttaa alkuperäisen asettelun heti.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Palautus
preferences-leaf-comfort = Mukavuusasetukset
preferences-comfort-reset = Palauta mukavuusasetukset
preferences-comfort-hint = Palauttaa kaikkien taulukoiden sarakkeet, aloitusikkunan tilien järjestyksen ja valintaruudut sekä näytön koon. Kieleen, valuuttaan ja tuotujen tapahtumien tarkistukseen ei kosketa.
preferences-comfort-question = Palautetaanko mukavuusasetukset? Taulukoiden sarakkeet, aloitusikkuna ja näytön koko palaavat alkuperäiseen tilaansa.
preferences-comfort-done = Mukavuusasetukset on palautettu.

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

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Lainalaskuri
window-loan-title = Lainalaskuri
loan-tab-credit = Laina
loan-tab-afford = Pystynkö maksamaan sen takaisin?
loan-field-kind = Lainan tyyppi
loan-kind-consumer = Kulutusluotto
loan-kind-mortgage = Asuntolaina
loan-field-amount = Lainasumma
loan-field-payment = Kuukausierä
loan-field-months = Laina-aika
loan-field-rate = Kiinteä korko
loan-field-fees = Avausmaksu
loan-field-insurance = Vakuutus kuukaudessa
loan-unit-months = kk
loan-unit-percent = %
loan-invalid-field = Arvo ei ole luku: korjaa se, niin laskelma tehdään uudelleen.
loan-report-button = PDF-raportti
loan-monthly-table = Taulukko kuukausittain
loan-months-count = { $count ->
        [one] { $count } kuukausi
       *[other] { $count } kuukautta
    }
loan-percent = { $value } %
loan-notice-payment-too-low = Tämä erä ei kata korkoa: lainaa ei koskaan maksettaisi takaisin. Laina-aika jää 600 kuukauteen.
loan-notice-too-long = Tämä erä vaatisi yli 600 kuukautta: laina-aika jää 600 kuukauteen.
loan-figure-payment = Kuukausierä
loan-figure-payment-insured = Erä vakuutuksineen
loan-figure-taeg = Todellinen vuosikorko
loan-figure-interest = Korkokulut
loan-figure-insurance = Vakuutuskulut
loan-figure-cost = Lainan kokonaiskustannus
loan-figure-total-due = Maksettava kokonaissumma
loan-figure-all-in = Takaisin maksettu yhteensä vakuutuksineen
loan-part-capital = Lainasumma
loan-part-interest = Korot
loan-part-fees = Avausmaksu
loan-part-insurance = Vakuutus
loan-donut-cost-caption = yhteensä
loan-chart-cost = Mitä laina maksaa
loan-chart-capital = Jäljellä oleva pääoma
loan-schedule-title = Lyhennystaulukko
loan-schedule-yearly = Lyhennystaulukko vuosittain
loan-column-number = Nro
loan-column-year = Vuosi
loan-column-date = Eräpäivä
loan-column-payment = Erä
loan-column-payments = Erät
loan-column-interest = Korot
loan-column-capital = Lyhennys
loan-column-insurance = Vakuutus
loan-column-remaining = Jäljellä oleva pääoma
loan-history-label = Tarkasteltu jakso
loan-period-last-12 = Viimeiset 12 kuukautta
loan-accounts-title = Tarkastellut tilit
loan-period-title = Jakso
loan-column-account = Tili
loan-column-bank = Pankki
loan-column-balance = Todellinen saldo
loan-unavailable-no-account = Valitse vähintään yksi tili tarkastellaksesi historiaasi.
loan-unavailable-no-month = Tällä jaksolla ei ole vielä yhtään kokonaista kuukautta: valitse toinen.
loan-verdict-title = Lyhyesti
loan-verdict-green = Mahdollinen
loan-verdict-orange = Tiukka
loan-verdict-red = Riskialtis
loan-verdict-no-income = Ei tuloja tällä jaksolla: velkaantumisastetta ei voi laskea.
loan-check-debt-green = Velkaantumisaste { $ratio }: alle tämän menetelmän rajan { $green }.
loan-check-debt-orange = Velkaantumisaste { $ratio }: välillä { $green }–{ $red }, rajalla.
loan-check-debt-red = Velkaantumisaste { $ratio }: yli { $red }.
loan-check-effort = Erä { $payment } vie { $share } siitä, mitä säästät { $kind ->
        [good] hyvänä kuukautena
        [hard] vaikeana kuukautena
       *[usual] tavallisena kuukautena
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Hyvä kuukausi
        [hard] Vaikea kuukausi
       *[usual] Tavallinen kuukausi
    } ei jätä säästöön mitään: erä { $payment } otettaisiin varannostasi.
loan-check-reserve-green = Saldosi pysyy positiivisena lainan loppuun asti.
loan-check-reserve-red = Tämän lainan takia saldosi painuisi miinukselle: { $month }.
loan-check-reserve-sooner = Saldosi painuisi miinukselle ({ $month }) { $count ->
        [one] kuukautta
       *[other] { $count } kuukautta
    } aiemmin kuin ilman lainaa.
loan-check-reserve-anyway = Saldosi painuisi miinukselle ilman lainaakin (noin: { $month }); laina ei juuri muuta sitä.
loan-check-reserve-floor-green = Saldosi pysyy turvavarannon ({ $floor }) yläpuolella lainan loppuun asti.
loan-check-reserve-floor-red = Tämän lainan takia saldosi laskisi turvavarannon ({ $floor }) alle: { $month }.
loan-check-reserve-floor-sooner = Saldosi laskisi turvavarannon ({ $floor }) alle ({ $month }) { $count ->
        [one] kuukautta
       *[other] { $count } kuukautta
    } aiemmin kuin ilman lainaa.
loan-check-reserve-floor-anyway = Saldosi laskisi turvavarannon ({ $floor }) alle ilman lainaakin (noin: { $month }); laina ei juuri muuta sitä.
loan-warning-deficit = Huomio: tällä jaksolla menosi ylittävät jo tulosi keskimäärin { $amount } kuukaudessa, ennen mitään lainaa.
loan-figure-reference = Säästö { $kind ->
        [good] hyvänä kuukautena
        [hard] vaikeana kuukautena
       *[usual] tavallisena kuukautena
    }
loan-figure-tipped = Kuukaudet, jotka laina veisi miinukselle
loan-gauge-caption = velkaantumisaste
loan-figure-income = Keskimääräiset tulot kuukaudessa
loan-figure-spending = Keskimääräiset menot kuukaudessa
loan-figure-saving = Keskimääräinen säästö kuukaudessa
loan-figure-running = Käynnissä olevat lainat kuukaudessa
loan-figure-new = Uusi erä vakuutuksineen
loan-figure-rest = Elämiseen kuukaudessa
loan-figure-debt = Velkaantumisaste
loan-red-months-value = { $count } / { $total }
loan-figure-balance-now = Todellinen saldo tänään
loan-figure-balance-end = Arvioitu saldo lainan lopussa
loan-chart-income = Mihin keskitulosi menevät
loan-donut-income-caption = keskitulo
loan-part-spending = Juoksevat menot
loan-part-running = Käynnissä olevat lainat
loan-part-new = Uusi laina
loan-part-rest = Jäljelle
loan-part-missing = Puuttuu
loan-chart-history = Historiasi tämän lainan kanssa
loan-chart-history-hint = Mitä kustakin kuukaudesta olisi jäänyt erän jälkeen. Kirkkaan punaisella kuukaudet, jotka laina veisi miinukselle; vaaleanpunaisella ne, jotka olivat miinuksella ilman sitäkin.
loan-chart-projection = Arvioitu saldosi
loan-mark-loan-end = Loppu: { $label }
loan-mark-negative = Miinuksella
loan-mark-floor = Varannon alla
loan-mark-floor-line = Turvavaranto
loan-running-title = Huomioidut käynnissä olevat lainat
loan-running-column-label = Toistuva tapahtuma
loan-running-column-monthly = Kuukaudessa
loan-running-column-end = Viimeinen erä
loan-no-running = Toistuvista tapahtumistasi ei tunnistettu yhtään käynnissä olevaa lainaa.
loan-period-caption = { $from } – { $to } ({ $count ->
        [one] { $count } kuukausi
       *[other] { $count } kuukautta
    })
loan-transfers = { $count ->
        [0] Valittujen tiliesi välillä ei tunnistettu siirtoja.
        [one] Yksi siirto valittujen tiliesi välillä tunnistettiin ja jätettiin pois.
       *[other] { $count } siirtoa valittujen tiliesi välillä tunnistettiin ja jätettiin pois.
    }
loan-method = Keskiarvot jakson kokonaisista kuukausista, täsmätyt ja kirjatut tapahtumat, ilman valittujen tiliesi välisiä siirtoja.
loan-report-title = Lainalaskelma
loan-report-made-on = laskelma { $date }
loan-disclaimer = Suuntaa antava laskelma ilman sopimusarvoa. Vain pankin tarjous on sitova.
loan-tab-rules = Arvioinnin asetukset
loan-method-optimistic = Optimistinen
loan-method-neutral = Neutraali
loan-method-severe = Tiukka
loan-method-line = Arviointimenetelmä: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Arvio vastaa kolmeen kysymykseen, ja kukin menetelmä asettaa niille omat vaatimuksensa. Valitse itsellesi sopiva: välilehden ”Pystynkö maksamaan sen takaisin?” arvio seuraa sitä. Viimeinen rivi olettaa menojesi kasvavan vuosittain annetun prosentin verran; erä pysyy samana.
loan-rule-row-debt = Hyväksytty velkaantumisaste
loan-rule-row-reference = Vertailusäästö
loan-rule-row-share = Osuus säästöstä, jonka erä saa viedä
loan-rule-row-floor = Raja, jonka alle saldo ei saa laskea
loan-rule-row-sooner = Jos saldo laskee sen alle ilman lainaakin
loan-rule-row-growth = Menojesi kasvu vuodessa
loan-rule-limits = vihreä enintään { $green }, oranssi enintään { $red }
loan-rule-reference = { $kind ->
        [good] hyvä kuukausi
        [hard] vaikea kuukausi
       *[usual] tavallinen kuukausi
    }: { $amount }
loan-rule-floor-zero = nolla
loan-rule-floor-cushion = kuukauden menot: { $amount }
loan-rule-sooner = oranssi, jos laina aikaistaa sitä { $orange }, punainen { $red }
loan-unit-percent-year = % vuodessa
loan-method-optimistic-explain = Optimistinen menetelmä olettaa hyvän kuukauden, hyväksyy enintään 40 %:n velkaantumisasteen eikä pidä varantoa: se kertoo, mikä on mahdollista, jos kaikki menee hyvin.
loan-method-neutral-explain = Neutraali menetelmä olettaa tavallisen kuukauden ja noudattaa pankkien sääntöä, 33–35 %:n velkaantumisastetta: se on vertailuarvio.
loan-method-severe-explain = Tiukka menetelmä olettaa vaikean kuukauden ja pitää kuukauden menot varantona yllätysten varalle: se kertoo, mikä kestää, vaikka asiat menisivät huonosti.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Sähkölaitteen kulutus
window-appliance-title = Sähkölaitteen kulutus
appliance-device-title = Laite
appliance-on-title = Päällä
appliance-standby-title = Valmiustilassa
appliance-field-on-watts = Teho käytössä
appliance-field-on-hours = Käyttöaika päivässä
appliance-field-days = Käyttöpäivät viikossa
appliance-field-share = Käyttöajan osuus edullisena aikana
appliance-field-standby-watts = Valmiustilan teho
appliance-field-standby-hours = Valmiustila-aika käyttöpäivää kohden
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = / 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Jos kenttä jätetään tyhjäksi, valmiustila kestää loppupäivän. Päivinä, joina laitetta ei käytetä, se on silti kytkettynä: koko aika lasketaan valmiustilaksi. Irrotetun laitteen valmiustilan teho on 0 W.
appliance-contract-title = Sopimuksesi
appliance-field-option = Hinnoittelumalli
appliance-option-base = Yleissähkö (yksi hinta)
appliance-option-off-peak = Huippuaika / edullinen aika
appliance-field-base = kWh-hinta
appliance-field-peak = kWh-hinta huippuaikana
appliance-field-off-peak = kWh-hinta edullisena aikana
appliance-field-off-peak-hours = Edullisen ajan tunnit päivässä
appliance-contract-hint = Nämä hinnat koskevat vain tätä laskelmaa. Tallennettu hinnoittelu asetetaan kohdassa Asetukset › Valinnat › Työkalut.
appliance-contract-reset = Palauta tallennettu hinnoittelu
appliance-period-day = Päivässä
appliance-period-month = Kuukaudessa
appliance-period-year = Vuodessa
appliance-energy = { $value } kWh
appliance-less-than = alle { $amount }
appliance-detail-title = Vuoden erittely
appliance-column-part = Kohde
appliance-column-energy = Energia
appliance-column-cost = Kustannus
appliance-column-share = Osuus
appliance-line-on = Päällä
appliance-line-standby = Valmiustilassa
appliance-line-on-peak = Päällä, huippuaika
appliance-line-on-off-peak = Päällä, edullinen aika
appliance-line-standby-peak = Valmiustilassa, huippuaika
appliance-line-standby-off-peak = Valmiustilassa, edullinen aika
appliance-line-total = Yhteensä
appliance-chart-title = Mihin rahat menevät
appliance-chart-caption = vuodessa
appliance-standby-sentence = Pelkkä valmiustila maksaa vuodessa: { $amount }. Osuus laitteen kustannuksista: { $share }.
appliance-note-plate = Laitteeseen tai sen ohjeeseen merkitty teho on enimmäisarvo: käytössä useimmat laitteet kuluttavat vähemmän. Saat todellisen luvun mittaamalla kulutuksen pistorasiaan kytkettävällä energiamittarilla ja syöttämällä sen lukeman.
appliance-note-subscription = Perusmaksua ei lasketa mukaan: se maksetaan, oli laite kytkettynä tai ei.
appliance-invalid-watts = Anna teho väliltä 0–100 000 W.
appliance-invalid-hours = Anna aika väliltä 0–24 tuntia päivässä.
appliance-invalid-days = Anna päivien määrä kokonaislukuna väliltä 0–7.
appliance-invalid-share = Anna osuus väliltä 0–100 %.
appliance-invalid-day-overflow = Käyttöaika ja valmiustila ylittävät yhteensä 24 tuntia päivässä.
appliance-invalid-price = Anna kWh-hinta väliltä 0–100.
appliance-invalid-off-peak-hours = Anna edullisen ajan tunnit kokonaislukuna väliltä 0–24.
preferences-branch-tools = Työkalut
preferences-leaf-electricity = Sähkön hinnoittelu
preferences-electricity-blue = Palauta EDF:n Tarif Bleu
preferences-electricity-hint = Sopimuksesi hinnoittelu, jota työkalu ”Sähkölaitteen kulutus” käyttää. Oletuksena: EDF:n Tarif Bleu (Ranska) 1.8.2026, hinnat sisältävät verot, mittari 3–6 kVA. Nämä hinnat muuttuvat usein helmi- ja elokuussa: kopioi hinnat laskustasi.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Puskurirahastoni
window-cushion-title = Puskurirahastoni
cushion-question = Jos tulosi loppuisivat huomenna, kuinka monta kuukautta pärjäisit säästöilläsi?
cushion-accounts-title = Tilisi
cushion-column-account = Tili
cushion-column-balance = Todellinen saldo
cushion-column-savings = Säästöt
cushion-column-spending = Menot
cushion-accounts-hint = ”Säästöt”: rahat, joiden varaan laskisit vaikeina aikoina. ”Menot”: tilit, joilta arjen menot maksetaan.
cushion-history-label = Tarkastelujakso
cushion-backup-label = Varatulo kuukaudessa
cushion-backup-hint = Tulot, jotka jatkuisivat: työttömyysturva, puolison palkka… Tyhjä: ei tuloja.
cushion-categories-title = Huomioidut menot
cushion-categories-hint = Poista valinta menoista, joista luopuisit vaikeina aikoina.
cushion-categories-empty = Ei menoja tällä jaksolla.
cushion-verdict-title = Puskurisi
cushion-targets-title = Turvarajat
cushion-projection-title = Säästösi vaikeina aikoina
cushion-projection-hint = Mitä jäisi jäljelle kunakin kuukautena, jos tulosi loppuisivat tänään.
cushion-note = Arvio perustuu historiaasi: vaikean kuukauden menot voivat poiketa keskiarvosta.
cushion-invalid-backup = Summaa ei voi lukea: korjaa se, niin laskelma tehdään uudelleen.
cushion-no-spending-account = Valitse vähintään yksi ”Menot”-tili.
cushion-no-month = Tällä jaksolla ei ole vielä yhtään täyttä kuukautta.
cushion-months = { $value } kk
cushion-per-month = { $amount } kuukaudessa
cushion-figure-holds = Ei rajaa
cushion-gauge-caption = menoja katettuna
cushion-verdict-short = Alle kolme kuukautta: yllättävä isku ajaisi sinut nopeasti ahdinkoon.
cushion-verdict-fair = Kolmesta kuuteen kuukautta: kohtuullinen puskuri, jota kannattaa kasvattaa, jos voit.
cushion-verdict-solid = Kuusi kuukautta tai enemmän: puskurisi on vankka.
cushion-verdict-holds = Varatulosi kattaa menosi: säästösi eivät hupenisi.
cushion-verdict-nothing = Jaksolla ei ole huomioituja menoja: katettavaa ei ole.
cushion-tile-savings = Käytettävissä olevat säästöt
cushion-tile-spending = Huomioidut menot
cushion-tile-backup = Varatulo
cushion-tile-burn = Säästöt hupenisivat
cushion-tile-rhythm = Säästämistahti
cushion-burn-none = Ei mitään
cushion-target-title = { $months } kuukauden menot: { $amount }
cushion-target-reached = Saavutettu.
cushion-target-date = Puuttuu { $missing }. Nykyisellä säästämistahdilla saavutetaan arviolta: { $month }.
cushion-target-never = Puuttuu { $missing }. Säästösi eivät kasvaneet jakson aikana: tällä tahdilla tätä rajaa ei saavuteta.
cushion-mark-empty = Rahat loppu: { $month }
cushion-period = Keskiarvo: { $count ->
        [one] { $count } täysi kuukausi
       *[other] { $count } täyttä kuukautta
    }, jakso { $from } – { $to }. { $transfers ->
        [0] Ei siirtoja tiliesi välillä.
        [one] Yksi siirto tiliesi välillä, jätetty pois laskelmasta.
       *[other] { $transfers } siirtoa tiliesi välillä, jätetty pois laskelmasta.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Säästötavoite
window-goal-title = Säästötavoite
goal-accounts-title = Seuratut tilit
goal-column-account = Tili
goal-column-balance = Todellinen saldo
goal-accounts-hint = Kahden seuratun tilin välinen siirto kumoutuu; siirto tilille, jota ei seurata, lasketaan menoksi.
goal-period-label = Tarkastelujakso
goal-period-range = Vuosiväli…
goal-range-from = vuodesta
goal-range-to = vuoteen
goal-question-title = Kysymyksesi
goal-question-when = Milloin minulla on tämä summa?
goal-question-amount = Paljonko minulla on tavoitepäivänä?
goal-question-effort = Paljonko pitää säästää, jotta minulla on tämä summa tavoitepäivänä?
goal-field-target = Tavoitesumma
goal-field-date = Tavoitepäivä
goal-field-rate = Säästöjen vuosikorko
goal-field-extra = Entä jos säästäisin lisää, kuukaudessa
goal-options-hint = Tyhjät: ei korkoa, ei lisäsäästöä.
goal-answer-title = Vastaus
goal-chart-title = Saldosi eilen ja huomenna
goal-chart-hint = Yhtenäinen viiva: viimeisten kahdentoista kuukauden todellinen saldo; katkoviiva: ennuste; vaalea alue: vaihteluväli kuukausien mukaan.
goal-disclaimer = Historiaasi perustuva ennuste, ei lupaus: yllättävä tapahtuma voi muuttaa kaiken.
goal-no-account = Valitse vähintään yksi seurattava tili.
goal-no-month = Tällä jaksolla ei ole vielä yhtään täyttä kuukautta.
goal-invalid-target = Anna tavoiteltava summa.
goal-invalid-date = Valitse tuleva päivä seuraavan viidenkymmenen vuoden ajalta.
goal-invalid-rate = Anna korko väliltä 0–100 %.
goal-invalid-extra = Summaa ei voi lukea: korjaa se, niin laskelma tehdään uudelleen.
goal-per-month = { $amount } kuukaudessa
goal-tile-balance = Saldo tänään
goal-tile-rhythm = Keskimääräinen tahti
goal-tile-target = Tavoite
goal-tile-reached = Saavutetaan arviolta
goal-tile-date = Tavoitepäivä
goal-tile-projected = Ennustettu saldo
goal-tile-saved = Säästetty siihen mennessä
goal-tile-interest = Josta korkoa
goal-tile-needed = Säästettävä
goal-when-already = Sinulla on jo { $amount }: seuraamiesi tilien saldo on yhteensä { $balance }.
goal-when-reached = Sinulla on { $amount } { $months ->
        [one] kuukauden kuluttua
       *[other] { $months } kuukauden kuluttua
    }, arviolta: { $month }.
goal-when-range = Kuukausista riippuen aikaisintaan: { $early }, viimeistään: { $late }.
goal-when-range-open = Aikaisintaan: { $early }. Heikoilla kuukausilla tavoitetta ei saavutettaisi.
goal-when-never = Tällä tahdilla et saavuta summaa { $amount }.
goal-zero = Saldosi putoaisi nollaan arviolta: { $month }.
goal-amount = { $month }: sinulla olisi noin { $amount }.
goal-amount-range = Kuukausista riippuen vähintään { $low } ja enintään { $high }.
goal-effort-more = Tavoite { $amount }, ajankohta: { $month }. Sinun pitäisi säästää keskimäärin { $monthly } kuukaudessa eli { $gap } enemmän kuin nyt.
goal-effort-less = Tavoite { $amount }, ajankohta: { $month }. { $monthly } kuukaudessa riittäisi eli { $gap } vähemmän kuin nyt: olet edellä aikataulusta.
goal-effort-range = Kuukausista riippuen ero nykyiseen tahtiisi olisi vähintään { $low } ja enintään { $high } kuukaudessa.
goal-chart-target = Tavoite: { $amount }
goal-chart-today = Tänään
goal-note-seasons = Ennuste seuraa vuodenaikoja: jokainen tuleva kuukausi saa jakson samojen kuukausien keskiarvon.
goal-note-range = Vaihteluväli perustuu jakson heikkoihin ja vahvoihin kuukausiin: alimpaan ja ylimpään neljännekseen.
goal-note-loan = Laina ”{ $label }” päättyy: { $month }. Sen jälkeen { $amount } enemmän kuukaudessa.
goal-note-interest = Korko lasketaan kuukausittain, vuosikorko { $rate } %: likiarvo säästötilien puolen kuukauden jaksoihin perustuvasta laskentasäännöstä.
goal-period = Tahti laskettu jaksolta { $from } – { $to }: { $count ->
        [one] { $count } täysi kuukausi
       *[other] { $count } täyttä kuukautta
    }. { $transfers ->
        [0] Ei siirtoja seuraamiesi tilien välillä.
        [one] Yksi siirto seuraamiesi tilien välillä, jätetty pois laskelmasta.
       *[other] { $transfers } siirtoa seuraamiesi tilien välillä, jätetty pois laskelmasta.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = Entä jos vähentäisin…?
window-cut-title = Entä jos vähentäisin…?
cut-axis-label = Ryhmittele
cut-axis-category = Luokat
cut-axis-payee = Vastapuolet
cut-axis-budget-line = Budjettikohdat
cut-table-title = Menosi kohta kohdalta
cut-table-hint = Kirjoita vähennys (% tai { $sign } kuukaudessa) niille kohdille, joita haluaisit keventää. Vähennys ei voi ylittää itse menoa.
cut-column-monthly = Kuukaudessa
cut-column-cut = Vähennys
cut-column-after = Jälkeen
cut-column-yearly = Säästö vuodessa
cut-total = Yhteensä
cut-horizon-label = Aikajänne
cut-settings-title = Asetukset
cut-options-hint = Korko ja tavoitesumma ovat vapaaehtoisia.
cut-report-button = PDF-raportti
cut-chart-title = Saldosi ilman vähennyksiä ja niiden kanssa
cut-chart-hint = Yhtenäinen viiva: viimeisten kahdentoista kuukauden todellinen saldo; harmaa katkoviiva: ennuste ilman vähennyksiä; sininen: vähennysten kanssa; vihreä: säästetty raha.
cut-donut-title = Kuukausimenosi vähennysten jälkeen
cut-donut-caption = kuukaudessa vähennysten jälkeen
cut-donut-others = Muut kohdat
cut-donut-saved = Säästetty
cut-legend-with = Vähennysten kanssa
cut-legend-without = Ilman vähennyksiä
cut-years = { $years ->
        [one] { $years } vuosi
       *[other] { $years } vuotta
    }
cut-headline-none = Kirjoita taulukkoon vähennys nähdäksesi sen vaikutuksen.
cut-headline = { $count ->
        [one] Tällä vähennyksellä
       *[other] Näillä { $count } vähennyksellä
    } säästäisit { $monthly } enemmän kuukaudessa eli { $yearly } vuodessa.
cut-tile-monthly = Säästö kuukaudessa
cut-tile-yearly = Säästö vuodessa
cut-tile-horizon = Säästö { $years ->
        [one] { $years } vuodessa
       *[other] { $years } vuodessa
    }
cut-tile-spending = Menot kuukaudessa
cut-target-already = Sinulla on jo { $amount }.
cut-target-sooner = Saavuttaisit summan { $amount } arviolta: { $with } (ilman vähennyksiä: { $without }), { $months ->
        [0] eli et yhtään aiemmin
        [one] eli kuukautta aiemmin
       *[other] eli { $months } kuukautta aiemmin
    }.
cut-target-only-with = Näillä vähennyksillä saavuttaisit summan { $amount } arviolta: { $with }; ilman niitä, nykyisellä tahdillasi, et koskaan.
cut-target-never = Näilläkään vähennyksillä et saavuttaisi summaa { $amount } nykyisellä tahdillasi.
cut-note-seasons = Jokainen vähennys seuraa kohtansa vuodenaikoja: kohta, joka painaa eniten kesällä, säästää eniten kesällä.
cut-note-capped = Syötetty vähennys ylitti menon: se on rajattu menon suuruiseksi.
cut-invalid-cut = Tätä vähennystä ei voi lukea: anna prosentti väliltä 0–100 tai summa kuukaudessa.
cut-report-settings = Asetukset
cut-report-result = Tulos
cut-report-accounts = Seuratut tilit

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Suunnittele lomasi
window-holiday-title = Suunnittele lomasi
holiday-trip-title = Matka
holiday-field-trip = Matkan tyyppi
holiday-trip-stay = Lomamatka
holiday-trip-cruise = Risteily
holiday-field-adults = Aikuiset
holiday-field-children = Lapset
holiday-field-nights = Matkan kesto öinä
holiday-field-days = Päivät
holiday-field-months = Kuukausia lähtöön
holiday-field-stops = Satamakäyntien määrä
holiday-saved-title = Jo säästetty
holiday-saved-hint = Valitse tilit, joille lomarahaa on jo pantu sivuun: niiden todellinen saldo lasketaan jo säästetyksi.
holiday-budget-title = Budjetti
holiday-budget-hint = Anna jokaiselle kohdalle summa, keitä se koskee ja kuinka pitkältä ajalta. Tyhjää kohtaa ei lasketa.
holiday-optional-title = Valinnaiset rivit
holiday-result-title = Tulos
holiday-donut-title = Mihin matkarahat menevät
holiday-donut-caption = matkaan
holiday-child-label = Lapsen hinta
holiday-count-label = Hytit
holiday-open = Avaa projekti…
holiday-save = Tallenna projekti…
holiday-pdf = PDF-raportti
holiday-excel = Vie Exceliin
holiday-file-filter = Lomaprojekti
holiday-replace-question = Tämän projektin avaaminen korvaa ikkunaan kirjoitetut tiedot. Jatketaanko?
holiday-file-saved = Projekti tallennettu: { $file }
holiday-file-opened = Projekti avattu: { $file }
holiday-file-not-project = Tämä tiedosto ei ole Radinuksen lomaprojekti.
holiday-file-too-recent = Tämä projekti on peräisin Radinuksen uudemmasta versiosta: päivitä Radinus avataksesi sen.
holiday-file-failed = Tiedostoa ei voitu lukea tai kirjoittaa: { $reason }
holiday-line-transport = Meno-paluumatkat
holiday-line-lodging = Majoitus
holiday-line-meals = Ateriat ja päivittäiset menot
holiday-line-visits = Nähtävyydet ja vapaa-aika
holiday-line-port = Matka satamaan
holiday-line-cabins = Hytit
holiday-line-service = Palvelumaksu (juomarahat)
holiday-line-drinks = Juomapaketti
holiday-line-excursions = Maaretket satamissa
holiday-line-port-taxes = Satamamaksut
holiday-line-wifi = Wifi aluksella
holiday-line-onboard = Menot aluksella ja satamissa
holiday-line-other = Muut kulut ja odottamattomat menot
holiday-line-insurance = Peruutusturva
holiday-line-stay-tax = Turistivero
holiday-line-car = Auto perillä, polttoaine ja tiemaksut
holiday-line-parking = Pysäköinti lentoasemalla tai asemalla
holiday-line-bank = Pankkikulut ulkomailla
holiday-line-formalities = Muodollisuudet (passi, viisumi, rokotukset)
holiday-line-pets = Lemmikkien hoito
holiday-span-trip = koko matka
holiday-span-night = per yö
holiday-span-day = per päivä
holiday-span-stop = per satamakäynti
holiday-who-all = kaikille
holiday-who-person = per henkilö
holiday-who-adults = per aikuinen
holiday-cabins-count = { $count ->
        [one] { $count } hytti
       *[other] { $count } hyttiä
    }
holiday-days = { $days ->
        [one] { $days } päivä
       *[other] { $days } päivää
    }
holiday-invalid-count = Anna kokonaisluku.
holiday-invalid-amount = Summaa ei voi lukea: anna positiivinen luku tai prosentti väliltä 0–100.
holiday-headline-empty = Kirjoita budjetin summat nähdäksesi, mitä matka maksaa.
holiday-headline-stay = Tämä lomamatka maksaisi { $total }: { $people ->
        [one] yksi henkilö
       *[other] { $people } henkilöä
    }, { $nights ->
        [0] ei yhtään yötä
        [one] yksi yö
       *[other] { $nights } yötä
    }.
holiday-headline-cruise = Tämä risteily maksaisi { $total }: { $people ->
        [one] yksi henkilö
       *[other] { $people } henkilöä
    }, { $nights ->
        [0] ei yhtään yötä
        [one] yksi yö
       *[other] { $nights } yötä
    }.
holiday-tile-total = Kokonaiskustannus
holiday-tile-person = Per henkilö
holiday-tile-person-day = Per henkilö ja päivä
holiday-tile-saved = Jo säästetty
holiday-tile-remaining = Vielä rahoitettava
holiday-tile-monthly = Tarvittava säästö
holiday-remaining-none = Ei mitään: kaikki on katettu
holiday-monthly-none = Ei mitään säästettävää
holiday-monthly-now = Lähtö tässä kuussa
holiday-note-days = Päiviä on yksi enemmän kuin öitä: seitsemän yötä on kahdeksan päivää.
holiday-note-child = Henkilöä kohden lapsi maksaa lapsen hinnan, jos se on annettu; jos kenttä on tyhjä, lapsi maksaa kuten aikuinen.
holiday-note-percent = Vakuutuksen prosenttiosuus lasketaan matkan pääkohdista; pankkikulujen prosenttiosuus perillä tehdyistä menoista.
holiday-sheet-budget = Budjetti
holiday-sheet-result = Tulos
holiday-column-line = Kohta
holiday-column-amount = Summa
holiday-column-child = Lapsen hinta
holiday-column-who = Kenelle
holiday-column-span = Kuinka pitkään
holiday-column-cost = Kustannus
holiday-disclaimer = Arvio, joka perustuu omiin summiisi: todelliset hinnat voivat vaihdella.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Säästöprojekti
cut-file-not-project = Tämä tiedosto ei ole Radinuksen säästöprojekti.
cut-file-too-recent = Tämä projekti on peräisin Radinuksen uudemmasta versiosta: päivitä Radinus avataksesi sen.
cut-sheet-items = Kohdat

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Autoni päiväkirja
window-car-title = Autoni päiväkirja
car-unnamed = Autoni
car-sheet-title = Auto
car-field-plate = Rekisterinumero
car-field-make = Merkki
car-field-model = Malli
car-field-engine = Käyttövoima
car-field-first-hand = Ensimmäinen omistaja
car-field-registered = Ensirekisteröinti
car-field-acquired = Hankintapäivä
car-field-acquired-km = Mittarilukema hankittaessa
car-field-service = Huoltoväli
car-field-service-or = tai
car-unit-months-short = kk
car-unit-km = km
car-tariff-title = Kotilatauksen hinta
car-tariff-hint = Tämä hinta säilytetään auton päiväkirjassa: se ei muuta valintojen hintaa.
car-tariff-reset = Käytä valintojen hintaa
car-engine-petrol = Bensiini
car-engine-diesel = Diesel
car-engine-lpg = Nestekaasu
car-engine-e85 = E85 (bioetanoli)
car-engine-hybrid = Hybridi
car-engine-plug-in = Ladattava hybridi
car-engine-electric = Sähkö
car-engine-hydrogen = Vety
car-energy-petrol = Bensiini
car-energy-diesel = Diesel
car-energy-lpg = Nestekaasu
car-energy-e85 = E85
car-energy-electricity = Sähkö
car-energy-hydrogen = Vety
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energia
car-rubric-upkeep = Tavallinen ylläpito
car-rubric-service = Huolto
car-rubric-wear = Kuluvat osat
car-rubric-tyres = Renkaat
car-rubric-breakdown = Viat
car-rubric-insurance = Vakuutus
car-rubric-inspection = Katsastus
car-part-brake-pads = Jarrupalat
car-part-brake-discs = Jarrulevyt
car-part-timing-belt = Jakohihna
car-part-clutch = Kytkin
car-part-battery-12v = 12 V:n akku
car-part-shock-absorbers = Iskunvaimentimet
car-part-wipers = Pyyhkijänsulat
car-part-spark-plugs = Sytytystulpat
car-part-glow-plugs = Hehkutulpat
car-part-particulate-filter = Hiukkassuodatin
car-part-catalytic-converter = Katalysaattori
car-part-fuel-cell-filter = Polttokennon suodatin
car-part-exhaust = Pakoputkisto
car-part-other = Muu osa…
car-axle-all = Kaikki neljä rengasta
car-axle-front = Eturenkaat
car-axle-rear = Takarenkaat
car-verdict-pass = Hyväksytty
car-verdict-counter = Jälkitarkastus
car-charge-station = Latausasemalla
car-charge-home = Kotona
car-slot-peak = Huippuaika
car-slot-off-peak = Edullinen aika
car-entry-new = Uusi rivi
car-entry-edit = Muokkaa riviä
car-field-date = Päivämäärä
car-field-km = Mittarilukema
car-field-rubric = Luokka
car-field-amount = Summa
car-field-garage = Korjaamo tai asema
car-field-note = Huomautus
car-field-energy = Energia
car-field-quantity = Määrä
car-field-charge = Lataus
car-field-slot = Latausaika
car-field-part = Osa
car-field-part-name = Osan nimi
car-field-axle = Vaihdetut renkaat
car-field-verdict = Tulos
car-field-months = Katetut kuukaudet
car-field-battery = Akun kunto
car-home-amount-hint = Kotilatauksen summa lasketaan auton kotilataushinnan mukaan.
car-entry-add = Lisää päiväkirjaan
car-entry-update = Tallenna rivi
car-entry-cancel = Peruuta
car-entry-delete = Poista rivi
car-delete-question = Poistetaanko tämä rivi päiväkirjasta?
car-from-operation = Ota tapahtuma…
car-pick-account = Miltä tililtä meno on?
car-pick-operation = Mikä tapahtuma?
car-pick-take = Ota
car-pick-none = Tällä tilillä ei ole menoja.
car-pick-taken = Tapahtuma otettu: täydennä mittarilukema ja luokka ja lisää sitten rivi.
car-history-title = Historia
car-filter-all = Kaikki luokat
car-history-empty = Ei vielä rivejä.
car-history-hint = Napsauta riviä muokataksesi sitä.
car-column-date = Päivämäärä
car-column-km = Km
car-column-rubric = Luokka
car-column-detail = Tiedot
car-column-amount = Summa
car-column-garage = Korjaamo
car-column-note = Huomautus
car-column-share = Osuus
car-column-per-km = Per km
car-column-energy = Energia
car-column-quantity = Määrä
car-column-price = Keskihinta
car-column-consumption = Kulutus
car-column-part = Osa
car-column-changes = Vaihdot
car-column-last = Viimeisin vaihto
car-column-life = Käyttöikä
car-column-next = Seuraava vaihto
car-total = Yhteensä
car-summary-title = Mitä auto maksaa
car-headline-empty = Täytä auton tiedot ja lisää sitten ensimmäinen rivi: tankkaus, huolto, korjaamon lasku…
car-headline = { $since } lähtien autosi on maksanut sinulle { $total }.
car-headline-km = { $since } lähtien autosi on maksanut sinulle { $total }, ja olet ajanut { $km }: { $cost } kilometriä kohden.
car-tile-total = Kokonaiskustannus
car-tile-month = Kuukaudessa
car-tile-km = Kilometriä kohden
car-tile-driven = Ajetut kilometrit
car-tile-consumption = Kulutus
car-tile-energy-km = Energia kilometriä kohden
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } kuukausi
       *[other] { $months } kuukautta
    }
car-detail-battery = Akku: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Luokittain
car-energy-title = Energia
car-parts-title = Kuluvat osat
car-tyres-title = Renkaat
car-battery-title = Akun kunto
car-years-title = Mitä auto on maksanut vuosittain
car-donut-title = Mihin rahat menevät
car-donut-caption = yhteensä
car-deadlines-title = Tulevat määräajat
car-deadlines-empty = Ei vielä määräaikoja: kirjaa huolto, katsastus, vakuutus tai saman osan kaksi vaihtoa.
car-deadline-service = Huolto
car-deadline-inspection = Katsastus
car-deadline-counter = Katsastuksen jälkitarkastus
car-deadline-insurance = Vakuutuksen päättyminen
car-when-date = { $date }
car-when-km = { $km } kohdalla
car-when-km-reached = { $km } kohdalla, ajotahdillasi arviolta: { $month }
car-when-date-km = { $date } tai { $km } kohdalla, kumpi tulee ensin
car-when-inspection-unknown = Kirjaa viimeisin katsastus, niin näet seuraavan päivämäärän.
car-tone-late = Myöhässä
car-tone-soon = Pian
car-note-since = Kaikki lasketaan hankinnasta lähtien: auton tietoihin kirjatusta päivämäärästä ja mittarilukemasta.
car-note-consumption = Kulutus mitataan tankkauksesta tankkaukseen: tankkaa aina täyteen ja kirjaa mittarilukema joka kerta.
car-note-e85 = E85-auto käyttää sitä, mitä sille tankataan: tankkausta seuraavat kilometrit lasketaan kyseiselle polttoaineelle.
car-note-home = Kotilataus hinnoitellaan auton kotilataushinnalla sinä päivänä, jona se kirjataan, ja se säilyttää tämän kustannuksen.
car-note-inspection = Katsastus noudattaa Ranskan sääntöä: ensimmäinen neljän vuoden kuluessa ensirekisteröinnistä, sen jälkeen kahden vuoden välein; jälkitarkastus kahden kuukauden kuluessa.
car-disclaimer = Määräajat ja käyttöiät ovat päiväkirjasta johdettuja arvioita: vain valmistajan huoltokirja on sitova.
car-invalid-date = Anna kelvollinen päivämäärä, joka ei ole tulevaisuudessa.
car-invalid-acquired = Hankintapäivä ei voi olla ennen ensirekisteröintiä.
car-invalid-km = Anna mittarilukema kokonaisina kilometreinä.
car-invalid-amount = Tätä summaa ei voi lukea.
car-invalid-quantity = Kirjoita määrä: litroina, kilowattitunteina tai kiloina.
car-invalid-part = Valitse vaihdettu osa tai kirjoita sen nimi.
car-invalid-rubric = Valitse luokka.
car-invalid-months = Anna kuukausien määrä kokonaislukuna.
car-invalid-battery = Anna akun kunto väliltä 0–100 %.
car-open = Avaa päiväkirja…
car-save = Tallenna päiväkirja…
car-report-button = PDF-raportti
car-file-filter = Autopäiväkirja
car-file-saved = Päiväkirja tallennettu: { $file }
car-file-opened = Päiväkirja avattu: { $file }
car-file-not-logbook = Tämä tiedosto ei ole Radinuksen autopäiväkirja.
car-file-too-recent = Tämä päiväkirja on peräisin Radinuksen uudemmasta versiosta: päivitä Radinus avataksesi sen.
car-replace-question = Tämän päiväkirjan avaaminen korvaa ikkunassa olevan päiväkirjan. Jatketaanko?
car-sheet-history = Päiväkirja
car-sheet-summary = Yhteenveto

analysis-history-hint = Mitä pidempi historiasi on, sitä parempi tästä analyysistä tulee: ihanteellista on, että tapahtumia on vähintään vuoden ajalta.

# --- F48 — Jaa meno (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Jaa meno
window-sharing-title = Jaa meno
sharing-question = Kuka maksaa mitäkin?
sharing-setup-title = Jako
sharing-field-label = Nimike
sharing-label-hint = Esimerkiksi ”Ravintola 12.10.” tai ”Bretagnen matka 2027”: se antaa nimen tiedostoille ja raporteille.
sharing-field-total = Kokonaissumma
sharing-total-hint = Jos kenttä on tyhjä, kokonaissumma on erien ja kunkin omien lisien summa.
sharing-field-rule = Sääntö
sharing-field-rounding = Pyöristys
sharing-field-people = Henkilöt
sharing-mode-whole = Yksi sääntö koko menolle
sharing-mode-item = Yksi sääntö erää kohti
sharing-rule-equal = Yhtä suuret osuudet
sharing-rule-parts = Osien mukaan
sharing-rule-percent = Prosenttien mukaan
sharing-rule-income = Tulojen suhteessa
sharing-rounding-cent = Sentin tarkkuudella
sharing-rounding-euro = Koko yksikköön
sharing-round-euro = Pyöristä koko yksiköihin
sharing-hide-incomes = Piilota tulot raporteista ja viennistä
sharing-people-title = Henkilöt
sharing-people-hint = Yksi rivi per henkilö, yksi sarake per erä: rastita, kuka osallistuu mihinkin. Kaikki muu on valinnaista. Jos joku jättäytyy pois ja jättää ennakkomaksunsa: tarkka summa, joka vastaa hänen maksamaansa, eikä yhtään ruutua rastitettuna.
sharing-add-person = Lisää henkilö
sharing-person-default = Henkilö { $number }
sharing-items-title = Erät
sharing-items-hint = Vain se, mikä ei koske kaikkia, esimerkiksi viini. Loput kokonaissummasta menee yhteiseen erään.
sharing-add-item = Lisää erä
sharing-common = Yhteinen
sharing-payments-title = Maksut
sharing-payments-hint = Kuka maksoi, kuinka paljon ja milloin. Rivi ilman summaa ei vielä lasketa mukaan.
sharing-payments-none = Ei vielä maksuja.
sharing-add-payment = Lisää maksu
sharing-result-title = Tulos
sharing-balances-title = Maksujen tilanne
sharing-transfers-title = Ehdotetut tilisiirrot
sharing-delete = Poista
sharing-delete-person-question = Tällä henkilöllä on maksuja: poistetaanko ne hänen mukanaan?
sharing-disclaimer = Radinus ehdottaa jakoa: ystävien kesken kukin voi sopia toisinkin.
sharing-column-person = Henkilö
sharing-column-household = Talous
sharing-column-income = Tulo
sharing-column-parts = Osat
sharing-column-percent = %
sharing-column-floor = Vähintään
sharing-column-cap = Enintään
sharing-column-fixed = Tarkka summa
sharing-column-alone = Omat lisät
sharing-column-gift = Lahjoitettu ylijäämä
sharing-column-share = Osuus
sharing-column-typed = Kirjoitettu %
sharing-column-constraint = Mikä vaikutti
sharing-column-due = Maksettava
sharing-column-item = Erä
sharing-column-amount = Summa
sharing-column-rule = Sääntö
sharing-column-participants = Osallistujat
sharing-column-unit = Talous tai henkilö
sharing-column-members = Jäsenet
sharing-column-paid = Maksettu
sharing-column-balance = Saldo
sharing-column-date = Päivä
sharing-column-who = Kuka
sharing-column-label = Nimike
sharing-help-household = Saman talouden henkilöt tekevät tilityksen yhdessä: heidän maksunsa ja maksettavansa lasketaan yhteen, ja he saavat yhden erittelyn. Esimerkki: ”Martinin perhe” vanhemmille ja lapsille.
sharing-help-income = Käytetään vain säännössä ”tulojen suhteessa”: mitä suuremmat tulot, sitä suurempi osuus. Kirjoita kuukausitulo.
sharing-help-parts = Henkilö, jolla on 2 osaa, maksaa kaksi kertaa niin paljon kuin henkilö, jolla on 1 osa. Esimerkki: aikuinen 1, lapsi 0,5.
sharing-help-percent = Osuus menosta, jonka henkilö maksaa. Prosenttien summan pitää olla yhteensä 100 %.
sharing-help-floor = Henkilö maksaa vähintään tämän summan, vaikka hänen laskettu osuutensa olisi pienempi. Erotus keventää muiden osuutta.
sharing-help-cap = Henkilö ei maksa koskaan tätä summaa enempää. Se, mitä hän ei maksa, siirtyy muille hänen eriensä osallistujille.
sharing-help-fixed = Henkilö maksaa tämän tarkan summan, mitä tahansa tapahtuu, ja loput jaetaan muiden kesken. Esimerkki: joku jättäytyy pois ja jättää ennakkomaksunsa.
sharing-help-alone = Se, minkä henkilö otti vain itselleen, esimerkiksi jälkiruoka tai kahvi. Hän maksaa sen kokonaan osuutensa lisäksi.
sharing-help-gift = Jos henkilö maksoi enemmän kuin osuutensa: rastitettuna ylijäämä on lahjoitus ryhmälle, rastittamatta se maksetaan hänelle takaisin.
sharing-help-items = Rastita henkilöt, jotka osallistuvat tähän erään. Yhteinen erä on se, mitä kokonaissummasta jää, kun muut erät on vähennetty.
sharing-help-due = Henkilön maksettava yhteensä: hänen osuutensa eristä, omat lisät ja pyöristys.
sharing-help-share = Osuuden suuruus prosentteina jaettavasta summasta.
sharing-help-typed = Kirjoittamasi prosentti. Se voi poiketa todellisesta osuudesta, kun vähimmäismäärä, enimmäismäärä tai tarkka summa on vaikuttanut.
sharing-help-constraint = Kertoo, onko henkilön osuutta muuttanut vähimmäismäärä, enimmäismäärä, tarkka summa vai lahjoitettu ylijäämä.
sharing-help-item = Vain se, mikä ei koske kaikkia, esimerkiksi viini. Loput kokonaissummasta menee yhteiseen erään, jaettuna niiden kesken, jotka on siihen rastitettu.
sharing-help-rule = Miten erä jaetaan: yhtä suuriin osuuksiin, osien mukaan, prosenttien mukaan tai tulojen suhteessa.
sharing-help-paid = Se, minkä talous tai henkilö on jo maksanut, syötettyjen maksujen mukaan.
sharing-help-balance = Se, mitä on vielä maksettava, tai se, mitä on maksettu osuutta enemmän. Esimerkki: ”Maksettavaa vielä: 61,54 €”.
sharing-advice-equal = { $count ->
        [one] { $total } yhdelle henkilölle.
       *[other] { $total } ÷ { $count } henkilöä = { $amount } per henkilö.
    }
sharing-advice-equal-varied = Yhtä suurin osuuksin osallistujien kesken, ottaen huomioon rajat ja poissulkemiset.
sharing-advice-parts = Osia yhteensä { $parts }: yksi osa on { $amount }.
sharing-advice-parts-varied = Kukin maksaa osiensa mukaan, ottaen huomioon rajat ja poissulkemiset. Tyhjä ruutu lasketaan 1 osaksi.
sharing-advice-percent-rest = 100 %:sta puuttuu vielä { $rest } %.
sharing-advice-percent-over = Prosentit ovat { $over } % yli 100 %:n.
sharing-advice-percent-ok = Prosentit ovat yhteensä tasan 100 %.
sharing-advice-percent-nobody = Prosentit ovat jo yhteensä 100 %: { $names } { $count ->
        [one] ei maksaisi mitään.
       *[other] eivät maksaisi mitään.
    }
sharing-advice-income = Kukin maksaa { $rate } % tuloistaan.
sharing-advice-income-missing = Kirjoita kunkin tulot, niin meno jaetaan tulojen suhteessa.
sharing-advice-income-varied = Kukin maksaa saman osuuden tuloistaan, ottaen huomioon rajat ja poissulkemiset.
sharing-advice-empty = Kirjoita jaettava summa.
sharing-apply-advice = Käytä ehdotettuja arvoja
sharing-help-apply-advice = Täyttää tyhjät ruudut harmailla arvoilla. Jo täytetyt ruudut eivät muutu.
sharing-from-incomes = Prosentit tulojen mukaan
sharing-help-from-incomes = Korvaa prosentit kunkin tulon osuudella kaikkien tulojen summasta. Ne ovat yhteensä 100 %.
sharing-reset-percents = Jaa kaikki uudelleen
sharing-help-reset-percents = Tyhjentää prosentit ja jakaa ne tasan kaikkien kesken. Kätevä, kun olet lisännyt henkilön.
sharing-reset-percents-question = Tyhjennetäänkö kaikki prosentit ja jaetaanko ne tasan kaikkien kesken?
sharing-open = Avaa projekti…
sharing-save = Tallenna projekti…
sharing-pdf-distribution = Jako (PDF)
sharing-pdf-payments = Maksujen tilanne (PDF)
sharing-pdf-statements = Henkilökohtaiset erittelyt (PDF)…
sharing-statements-everyone = Kaikki
sharing-excel = Vie Exceliin
sharing-file-filter = Jakoprojekti
sharing-replace-question = Tämän projektin avaaminen korvaa ikkunaan kirjoitetut tiedot. Jatketaanko?
sharing-file-saved = Projekti tallennettu: { $file }
sharing-file-opened = Projekti avattu: { $file }
sharing-file-not-project = Tämä tiedosto ei ole Radinuksen jakoprojekti.
sharing-file-too-recent = Tämä projekti on peräisin Radinuksen uudemmasta versiosta: päivitä Radinus avataksesi sen.
sharing-file-failed = Tiedostoa ei voitu lukea tai kirjoittaa: { $reason }
sharing-statements-replace-question = { $count ->
        [one] Tässä kansiossa on jo yksi erittely. Korvataanko se?
       *[other] Tässä kansiossa on jo { $count } erittelyä. Korvataanko ne?
    }
sharing-statements-written = { $count ->
        [one] Yksi erittely kirjoitettu kansioon ”{ $folder }”.
       *[other] { $count } erittelyä kirjoitettu kansioon ”{ $folder }”.
    }
sharing-too-many-people = Jaossa voi olla enintään 40 henkilöä.
sharing-too-many-items = Jaossa voi olla enintään 20 erää.
sharing-too-many-payments = Jaossa voi olla enintään 400 maksua.
sharing-invalid-amount = Summaa ei voi lukea: anna positiivinen luku.
sharing-invalid-number = Lukua ei voi lukea: anna positiivinen luku.
sharing-invalid-percent = Prosentti on väliltä 0–100.
sharing-invalid-date = Päivämäärää ei voi lukea.
sharing-name-missing = Jokaisella henkilöllä täytyy olla nimi.
sharing-name-duplicate = ”{ $name }” on jo olemassa: erota ne toisistaan, esimerkiksi alkukirjaimella.
sharing-floor-above-cap = Vähimmäismäärä ylittää enimmäismäärän.
sharing-item-label-missing = Tällä erällä ei ole nimeä.
sharing-items-above-total = Erät ja kunkin omat lisät ylittävät kokonaissumman { $amount } verran.
sharing-payment-person = Valitse, kuka maksoi.
sharing-percent-total = Prosentit ovat yhteensä { $sum } %: niiden pitää olla 100 %.
sharing-percent-total-item = ”{ $item }”: prosentit ovat yhteensä { $sum } %: niiden pitää olla 100 %.
sharing-item-nobody = Kukaan ei osallistu erään ”{ $item }”.
sharing-item-no-weight = Kukaan ei vaikuta erään ”{ $item }”: kaikki sen osallistujat ovat nollassa.
sharing-income-missing = Henkilön { $name } tulo puuttuu.
sharing-fixed-above = Tarkat summat ylittävät jaettavan summan { $amount } verran.
sharing-floors-above = Vähimmäismäärät ylittävät jaettavan summan { $amount } verran.
sharing-cap-alone = { $name } on ainoa, joka osallistuu erään ”{ $item }”: hänen enimmäismääräänsä ei voi noudattaa.
sharing-caps-short = Enimmäismäärät eivät riitä kattamaan summaa: puuttuu { $amount }.
sharing-impossible = Kaikkia näitä ehtoja ei voi noudattaa: höllennä vähimmäis- tai enimmäismäärää.
sharing-constraint-floor = Vähimmäismäärä täyttyi
sharing-constraint-cap = Enimmäismäärä täyttyi
sharing-constraint-fixed = Tarkka summa
sharing-constraint-gift = Lahjoitettu ylijäämä
sharing-and = { $first } ja { $last }
sharing-outside = Erien ulkopuolella
sharing-alone = Omat lisät
sharing-rounding = Pyöristys
sharing-headline-empty = Lisää menon jakavat henkilöt.
sharing-headline-no-amount = Kirjoita kokonaissumma tai jaettavat erät.
sharing-headline-equal = { $total } jaettavana: kukin maksaa { $amount }.
sharing-headline-range = { $total } jaettavana: { $min }–{ $max } henkilöstä riippuen.
sharing-participants = { $count ->
        [0] Ei osallistujia
        [one] Yksi osallistuja
       *[other] { $count } osallistujaa
    }
sharing-balance-due = Maksettavaa vielä: { $amount }
sharing-balance-over = Maksanut { $amount } osuuttaan enemmän
sharing-balance-even = Ajan tasalla
sharing-summary-collected = { $collected } maksettu, kokonaissumma { $total }.
sharing-summary-owing = { $count ->
        [0] Kaikki ovat ajan tasalla.
        [one] Vain yksi on vielä velkaa { $amount }.
       *[other] { $count } henkilöä on vielä velkaa yhteensä { $amount }.
    }
sharing-remaining-outside = Menosta maksettavaa vielä: { $amount }
sharing-remaining-reimburse = Palautettavaa henkilölle { $name }: { $amount }
sharing-all-settled = Kaikki on maksettu: kukaan ei ole velkaa kenellekään.
sharing-transfer = { $from } on velkaa { $amount } henkilölle { $to }
sharing-warning-over-paid = Maksut ylittävät menon { $amount } verran: tarkista summat.
sharing-note-income-zero = { $name } ei maksa mitään kohteesta { $items }: hänen tulonsa on 0.
sharing-note-excluded = { $name } ei osallistu erään ”{ $item }”: hänen osuutensa jaetaan muiden kesken.
sharing-note-gift = Henkilön { $giver } lahjoittama ylijäämä pienentää muiden osuutta: { $name } on nyt maksanut enemmän kuin osuutensa.
sharing-note-outside = { $name } maksaa { $amount } omien erinsä ulkopuolelta: summa vähennetään siitä, minkä muut jakavat.
sharing-note-keeper = Pyöristetty koko yksiköihin: { $name } pitää sentit, jotta kokonaissumma täsmää.
sharing-report-distribution = Jako
sharing-report-sharing = Jako
sharing-report-who-pays = Kuka maksaa mitäkin
sharing-report-items = Erien erittely
sharing-report-payments = Maksujen tilanne
sharing-report-as-of = Tilanne { $date }
sharing-report-balances = Osuus, maksettu, saldo
sharing-report-statement = Erittely — { $name }
sharing-report-your-share = Osuutesi
sharing-statement-total = Talouden yhteissumma: { $amount }
sharing-statement-pay = Maksettavaa henkilölle { $name }: { $amount }
sharing-statement-receive = Saatavaa henkilöltä { $name }: { $amount }
sharing-sheet-people = Henkilöt
sharing-sheet-items = Erät
sharing-sheet-result = Tulos
sharing-sheet-payments = Maksut
sharing-sheet-balances = Palautukset

## Tietokannan vientiavustaja (P-74, Fabrice, 19/10/2026).
window-database-export-title = Tietokannan ”{ $base }” vientiavustaja
menu-tools-export = Tietokannan vientiavustaja…
base-export-only-this = Vain luettelosta valittu tietokanta ”{ $base }” viedään. Muihin tietokantoihin tämä ei vaikuta.
base-export-purpose = Tämä avustaja kopioi tietokannan tiedot tiedostoihin, joita muut ohjelmat osaavat lukea: taulukkolaskentaohjelma, Accessin kaltainen tietokanta tai jokin muu talouden hallintaohjelma. Itse tietokantaa ei muuteta.
base-export-step-format = 1. Muoto
base-export-step-options = 2. Asetukset
base-export-step-place = 3. Sijainti
base-export-step-summary = 4. Yhteenveto
base-export-format-xlsx = Excel (.xlsx)
base-export-format-xlsx-hint = Työkirja, jossa on yksi taulukko kutakin taulua kohden. Sen voi avata Excelillä ja useimmilla taulukkolaskentaohjelmilla.
base-export-format-ods = Calc (.ods)
base-export-format-ods-hint = LibreOfficen ja OpenOfficen avoin muoto, jossa on yksi taulukko kutakin taulua kohden.
base-export-format-csv = CSV (.csv)
base-export-format-csv-hint = Yksi tekstitiedosto kutakin taulua kohden, arvot puolipisteillä erotettuina: muoto, jonka lähes kaikki ohjelmat osaavat tuoda, Access mukaan lukien.
base-export-format-json = JSON (.json)
base-export-format-json-hint = Ohjelmoijille ja sovelluksille: jokainen taulu omalla nimellään sekä otsake, joka kuvaa viennin.
base-export-format-xml = XML (.xml)
base-export-format-xml-hint = Sama sisältö kuin JSON-muodossa, mutta XML-muodossa kirjoitettuna.
base-export-format-sql = SQL-komentosarja (.sql)
base-export-format-sql-hint = Komennot, jotka luovat taulut ja niiden tiedot uudelleen toiseen tietokantaan (MySQL, PostgreSQL, SQLite…).
base-export-format-sqlite = SQLite-tietokanta (.sqlite)
base-export-format-sqlite-hint = Itsenäinen tietokanta ilman salasanaa. Monet työkalut avaavat sen suoraan.
base-export-format-qif = QIF, yksi tiedosto tiliä kohden (.qif)
base-export-format-qif-hint = Tiliesi siirtämiseen johonkin toiseen talouden hallintaohjelmaan (Money, Quicken, GnuCash, Grisbi…).
base-export-format-ofx = OFX, yksi tiedosto tiliä kohden (.ofx)
base-export-format-ofx-hint = Tiliotteiden muoto, jonka useimmat talouden hallintaohjelmat osaavat tuoda.
base-export-lossy = Huomio: QIF ja OFX eivät pysty välittämään kaikkea. Mukaan siirtyvät vain tilien tapahtumat vastapuolineen, luokkineen ja kommentteineen; siirto tileltä toiselle muuttuu tavalliseksi tapahtumaksi kummallakin puolella, ja kaikki muu (budjetit, toistuvat tapahtumat, projektit, kohdistukset…) jää pois. Jos haluat säilyttää kaiken, valitse jokin toinen muoto.
base-export-planned-note = Suunniteltuja tapahtumia ja päivämäärättömiä tapahtumia ei viedä: ne eivät ole vielä kulkeneet pankin kautta. Niiden määrä kerrotaan lopuksi.
base-export-dates-hint = Päivämäärät kirjoitetaan muodossa vuosi-kuukausi-päivä (2026-12-31) ja summat tietokannan valuutassa: mikään ohjelma ei voi tulkita niitä väärin.
base-export-group-layout = Tiedostot
base-export-layout-one = Kaikki yhteen tiedostoon
base-export-layout-per-table = Yksi tiedosto kutakin taulua kohden, kansioon
base-export-group-decimal = Summien desimaalierotin
base-export-decimal-point = Piste (1234.56)
base-export-decimal-comma = Pilkku (1234,56)
base-export-group-quotes = Lainausmerkit
base-export-quotes-all = Jokainen arvo lainausmerkeissä
base-export-quotes-none = Ei lainausmerkkejä
base-export-csv-replacements-hint = Jotta jokainen tiedosto voidaan lukea uudelleen virheettä, tekstissä oleva puolipiste muutetaan huutomerkiksi, rivinvaihto välilyönniksi ja, jos lainausmerkkejä ei käytetä, lainausmerkki heittomerkiksi. Korvausten määrä kerrotaan lopuksi.
base-export-group-qif-order = Päivämäärän järjestys
base-export-qif-day-month = Päivä ennen kuukautta (31/12/2026)
base-export-qif-month-day = Kuukausi ennen päivää (12/31/2026)
base-export-qif-order-hint = Valitse järjestys, jota tiedostot lukeva ohjelma odottaa: Euroopassa päivä ensin, Yhdysvalloissa kuukausi ensin.
base-export-no-option = Tällä muodolla ei ole asetuksia.
base-export-choose-file = Valitse tiedosto…
base-export-choose-folder = Valitse kansio…
base-export-place-file = Vienti kirjoitetaan tähän tiedostoon:
base-export-place-folder = Vienti kirjoitetaan tähän kansioon, joka luodaan sitä varten:
base-export-place-none = Sijaintia ei ole vielä valittu.
base-export-place-needed = Valitse ensin, minne vienti tallennetaan.
base-export-folder-exists = Kansio ”{ $name }” on jo olemassa. Sen sisältämät samannimiset tiedostot korvataan. Jatketaanko?
base-export-summary-base = Tietokanta
base-export-summary-format = Muoto
base-export-summary-options = Asetukset
base-export-summary-place = Sijainti
base-export-unprotected = Tämä tietokanta on suojattu salasanalla, mutta vienti ei ole: kuka tahansa, jolla on nämä tiedostot, voi lukea tilisi. Säilytä ne turvallisessa paikassa.
base-export-previous = Edellinen
base-export-next = Seuraava
base-export-run = Vie
base-export-running = Viedään…
base-export-done = Tietokanta ”{ $base }” on viety: { $tables ->
        [one] yksi taulu
       *[other] { $tables } taulua
    }, { $rows ->
        [one] yksi rivi
       *[other] { $rows } riviä
    }.
base-export-done-accounts = Tietokanta ”{ $base }” on viety: { $accounts ->
        [one] yksi tili
       *[other] { $accounts } tiliä
    }, { $operations ->
        [one] yksi tapahtuma
       *[other] { $operations } tapahtumaa
    }.
base-export-done-replacements = { $count ->
        [one] CSV-tiedostoissa korvattiin yksi merkki.
       *[other] CSV-tiedostoissa korvattiin { $count } merkkiä.
    }
base-export-done-controls = { $count ->
        [one] { $count } ohjausmerkki, jota tämä tiedostomuoto ei voi sisältää, korvattiin merkillä ”�”.
       *[other] { $count } ohjausmerkkiä, joita tämä tiedostomuoto ei voi sisältää, korvattiin merkillä ”�”.
    }
base-export-done-excel-cut = { $count ->
        [one] { $count } teksti ylitti Excelin 32 767 merkin rajan: se katkaistiin työkirjassa. Muut tiedostomuodot säilyttävät sen kokonaisena.
       *[other] { $count } tekstiä ylitti Excelin 32 767 merkin rajan: ne katkaistiin työkirjassa. Muut tiedostomuodot säilyttävät ne kokonaisina.
    }
base-export-done-anomalies = { $count ->
        [one] Yksi lukukelvoton arvo kopioitiin sellaisenaan.
       *[other] { $count } lukukelvotonta arvoa kopioitiin sellaisenaan.
    }
base-export-done-planned = { $count ->
        [one] Yksi suunniteltu tapahtuma jätettiin pois.
       *[other] { $count } suunniteltua tapahtumaa jätettiin pois.
    }
base-export-done-undated = { $count ->
        [one] Yksi päivämäärätön tapahtuma jätettiin pois.
       *[other] { $count } päivämäärätöntä tapahtumaa jätettiin pois.
    }
base-export-done-adjusted = { $count ->
        [one] Yksi arvo mukautettiin muotoon sopivaksi.
       *[other] { $count } arvoa mukautettiin muotoon sopiviksi.
    }
base-export-too-old = Tämä tietokanta on peräisin Radinuksen vanhemmasta versiosta. Avaa se ensin kerran Radinuksessa, joka päivittää sen, ja vie se sitten.
base-export-too-recent = Tämä tietokanta on tallennettu Radinuksen uudemmalla versiolla. Päivitä Radinus, jotta voit viedä sen.
base-export-not-radinus = Tämä tiedosto ei ole Radinus-tietokanta.
base-export-failed = Vientiä ei voitu tehdä: { $reason }

## Tietokantaikkunan Työkalut-valikko näyttää tietokannan nimen (Fabrice, 19/10/2026).
databases-tools-selected = Valittu tietokanta: ”{ $base }”
databases-tools-none = Tietokantaa ei ole valittu
menu-tools-backup = Varmuuskopioi tietokanta ”{ $base }”…
menu-tools-backup-none = Varmuuskopioi valittu tietokanta…
menu-tools-restore = Palauta tietokanta ”{ $base }”…
menu-tools-restore-none = Palauta valittu tietokanta…
menu-tools-repair = Korjaa ja optimoi tietokanta ”{ $base }”…
menu-tools-repair-none = Korjaa ja optimoi valittu tietokanta…
