# Radinus — messaggi lato core (Fluent), italiano.
# Compilato progressivamente man mano che vengono implementati i moduli core
# che producono messaggi visibili dall'utente. Vedere 08_ARCHITECTURE.md §2.1.

# La sentinella «0 = Non specificato» che usa ogni collegamento facoltativo di
# nomenclatura (02_BASE_DE_DONNEES.md §7 regola 2). Mostrata in cima a ogni combo.
# ---------------------------------------------------------------------
# Il nome della lingua, scritto nella propria lingua.
#
# È ciò che mostrano il menu Impostazioni e il selettore del primo
# avvio (01_CAHIER_DES_CHARGES.md §3.5: «ogni lingua scritta nella
# propria lingua»). Sta qui, e non nel codice, perché è l'unico posto in cui
# possa essere giusto: aggiungere una lingua significa depositare un
# file che sa come chiamarsi.
# ---------------------------------------------------------------------
language-name = Italiano

nomenclature-unspecified = Non specificato

# Chiesto prima di eliminare un elemento di nomenclatura che delle operazioni
# usano ancora (02_BASE_DE_DONNEES.md §7 regola 5). Riprodotto parola per parola
# dal sorgente WinDev originale (Enreg_Supprimer), punteggiatura compresa — la
# formulazione è dell'autore, non una traduzione.
nomenclature-delete-confirm = Sono state rilevate delle operazioni (transazioni bancarie) che possiedono l'attributo di tipo '{ $label }'. Conferma di voler reinizializzare questo attributo?

# Chiesto prima di eliminare un elemento di nomenclatura che nessuno usa.
# L'originale eliminava un simile elemento di netto, senza una parola; Fabrice ha
# chiesto il 25/07/2026 che un'eliminazione sia sempre confermata — uno scarto
# assunto rispetto al suo stesso codice, e l'unico in questo modulo.
nomenclature-delete-plain = Conferma l'eliminazione di «{ $label }»?

# Rifiuto mostrato quando l'elemento che l'utente sta per eliminare è proprio
# quello che la sua scheda mostra. Decisione di Fabrice del 25/07/2026: un
# elemento non si elimina da sotto la propria scheda aperta — la scheda si chiude
# prima, invece di lasciarla mostrare un record che non esiste più.
nomenclature-delete-form-open = La scheda di «{ $label }» è aperta. La chiuda prima di eliminare.

# Rifiuto mostrato quando la descrizione che si sta salvando è già portata da un
# altro elemento della stessa nomenclatura (decisione dell'autore, 25/07/2026: due
# elementi di una stessa nomenclatura non devono condividere un nome — classificare
# un'operazione sotto una di due descrizioni identiche è un testa o croce). `element`
# è il nome nel proprio genere, «una categoria», «un terzo»; `label` è la descrizione
# esistente, così com'è memorizzata, perché l'utente veda che cosa gli sbarra la strada.
nomenclature-duplicate = Esiste già { $element } con lo stesso nome: «{ $label }».

# ---------------------------------------------------------------------
# Ciò che le finestre dicono di sé stesse.
#
# Tutto è qui, compreso ciò che dipende dalla nomenclatura visualizzata: le
# frasi sono scritte per intero, lingua per lingua, invece di essere fabbricate
# per assemblaggio di parole e di generi. Un assemblaggio giusto in francese è
# falso nella lingua successiva, ed è il codice che finisce per sapere che
# esiste un femminile — non è il suo lavoro (regola dell'autore,
# 25/07/2026: «il software funziona con Fluent in francese e in
# inglese fin dall'inizio»).
# ---------------------------------------------------------------------

ui-loading = Caricamento…
ui-editing = Modifica.
ui-viewing = Consultazione.
ui-modified-suffix = — modificato
ui-label-required = La descrizione è obbligatoria.
ui-discard-question = Abbandonare le modifiche?
ui-yes = Sì
ui-no = No
ui-select-record = Selezioni un record
ui-key-multiselect = CTRL
ui-multiselect-help = Info: Utilizzi Clic Mouse + tasto [{ $modifier }] sulla tabella per selezionare più elementi
ui-no-match = Nessuna descrizione corrisponde al filtro.
ui-filter-placeholder = Filtrare le descrizioni…
ui-column-label = DESCRIZIONE
ui-field-label = Descrizione
ui-field-budget-line = Voce di bilancio
ui-identifier = Identificativo
ui-deletion-abandoned = Eliminazione abbandonata: non è stato modificato nulla.
ui-unknown-nomenclature = Nomenclatura sconosciuta:

ui-title-filter = Filtrare
ui-title-create = Creare
ui-title-update = Modificare la selezione
ui-title-delete = Eliminare la selezione
ui-title-read = Consultare la selezione
ui-title-close = Chiudere
ui-title-save = Salvare
ui-title-add = Aggiungere
ui-title-modify = Modificare

ui-load-failed = Caricamento impossibile:
ui-save-failed = Salvataggio impossibile:
ui-read-failed = Lettura impossibile:
ui-delete-failed = Eliminazione impossibile:
ui-open-failed = Apertura impossibile:
ui-close-failed = Chiusura impossibile:

# --- Frasi proprie di ogni nomenclatura ------------------------------

nomenclature-identifier = { $kind ->
    [category] Identificativo di Categoria
    [assignment] Identificativo di Assegnazione
    [payment-mode] Identificativo di Modalita di pagamento
    [payee] Identificativo di Terzo
    [project] Identificativo di Progetto
    [budget-line] Identificativo di Voce di bilancio
   *[bank] Identificativo di Banca
}

nomenclature-none = { $kind ->
    [category] Nessuna categoria.
    [assignment] Nessuna assegnazione.
    [payment-mode] Nessuna modalità di pagamento.
    [payee] Nessun terzo.
    [project] Nessun progetto.
    [budget-line] Nessuna voce di bilancio.
   *[bank] Nessuna banca.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Nessuna categoria da visualizzare.
    [assignment] Nessuna assegnazione da visualizzare.
    [payment-mode] Nessuna modalità di pagamento da visualizzare.
    [payee] Nessun terzo da visualizzare.
    [project] Nessun progetto da visualizzare.
    [budget-line] Nessuna voce di bilancio da visualizzare.
   *[bank] Nessuna banca da visualizzare.
}

nomenclature-gone = { $kind ->
    [category] Questa categoria non esiste più.
    [assignment] Questa assegnazione non esiste più.
    [payment-mode] Questa modalità di pagamento non esiste più.
    [payee] Questo terzo non esiste più.
    [project] Questo progetto non esiste più.
    [budget-line] Questa voce di bilancio non esiste più.
   *[bank] Questa banca non esiste più.
}

nomenclature-fresh = { $kind ->
    [category] Nuova categoria.
    [assignment] Nuova assegnazione.
    [payment-mode] Nuova modalità di pagamento.
    [payee] Nuovo terzo.
    [project] Nuovo progetto.
    [budget-line] Nuova voce di bilancio.
   *[bank] Nuova banca.
}

nomenclature-created = { $kind ->
    [category] Categoria aggiunta.
    [assignment] Assegnazione aggiunta.
    [payment-mode] Modalità di pagamento aggiunta.
    [payee] Terzo aggiunto.
    [project] Progetto aggiunto.
    [budget-line] Voce di bilancio aggiunta.
   *[bank] Banca aggiunta.
}

nomenclature-updated = { $kind ->
    [category] Categoria modificata.
    [assignment] Assegnazione modificata.
    [payment-mode] Modalità di pagamento modificata.
    [payee] Terzo modificato.
    [project] Progetto modificato.
    [budget-line] Voce di bilancio modificata.
   *[bank] Banca modificata.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 categoria eliminata.
       *[other] { $count } categorie eliminate.
      }
    [assignment] { $count ->
        [one] 1 assegnazione eliminata.
       *[other] { $count } assegnazioni eliminate.
      }
    [payment-mode] { $count ->
        [one] 1 modalità di pagamento eliminata.
       *[other] { $count } modalità di pagamento eliminate.
      }
    [payee] { $count ->
        [one] 1 terzo eliminato.
       *[other] { $count } terzi eliminati.
      }
    [project] { $count ->
        [one] 1 progetto eliminato.
       *[other] { $count } progetti eliminati.
      }
    [budget-line] { $count ->
        [one] 1 voce di bilancio eliminata.
       *[other] { $count } voci di bilancio eliminate.
      }
   *[bank] { $count ->
        [one] 1 banca eliminata.
       *[other] { $count } banche eliminate.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Esiste già una categoria con lo stesso nome: «{ $label }».
    [assignment] Esiste già un'assegnazione con lo stesso nome: «{ $label }».
    [payment-mode] Esiste già una modalità di pagamento con lo stesso nome: «{ $label }».
    [payee] Esiste già un terzo con lo stesso nome: «{ $label }».
    [project] Esiste già un progetto con lo stesso nome: «{ $label }».
    [budget-line] Esiste già una voce di bilancio con lo stesso nome: «{ $label }».
   *[bank] Esiste già una banca con lo stesso nome: «{ $label }».
}

# --- Titoli di finestre, senza accenti come nelle finestre d'origine --

window-list-title = { $kind ->
    [category] Elenco delle categorie
    [assignment] Elenco delle assegnazioni
    [payment-mode] Elenco delle modalita di pagamento
    [payee] Elenco dei terzi e dei commercianti
    [project] Elenco dei progetti
    [budget-line] Elenco delle voci di bilancio
   *[bank] Elenco delle banche
}

window-form-title = { $kind ->
    [category] Scheda categoria
    [assignment] Scheda assegnazione
    [payment-mode] Scheda modalita di pagamento
    [payee] Scheda terzo
    [project] Scheda progetto
    [budget-line] Scheda voce di bilancio
   *[bank] Scheda banca
}

# --- Barra dei menu (01_CAHIER_DES_CHARGES.md §6) ---------------------

menu-file = File
menu-file-import-statements = Importazione di estratti conto bancari
menu-file-import-excel = Importazione di file Excel
menu-file-backup = Copia di sicurezza
menu-file-restore = Ripristino
menu-file-repair = Riparazione e ottimizzazione della base di dati
menu-file-log = Mostrare il log
menu-tools-password = Proteggere il database con una password
menu-file-disconnect = Disconnettersi dal database corrente
menu-file-quit = Uscire

menu-accounts = Conti
menu-accounts-manage = Gestione dei conti bancari
menu-accounts-balances = Vedere i saldi dei suoi conti
menu-accounts-operations = Gestire le operazioni di un conto
menu-accounts-quick-classify = Classificazione rapida delle operazioni
menu-accounts-recurring = Gestione delle operazioni periodiche
menu-accounts-transfer = Trasferire un importo tra due conti
menu-accounts-checkbooks = Gestione dei libretti degli assegni

menu-statistics = Statistiche
menu-statistics-balance-chart = Grafico Evoluzione del saldo
menu-statistics-balance-analysis = Analisi Evoluzione del saldo
menu-statistics-by-category = Stat per categorie
menu-statistics-by-assignment = Stat per assegnazioni
menu-statistics-by-budget-line = Stat per voci di bilancio
menu-statistics-by-payment-mode = Stat per modalità di pagamento
menu-statistics-by-payee = Stat per terzi e commercianti
menu-statistics-by-project = Stat per progetti
menu-statistics-by-verification = Stat per verifiche
menu-statistics-dashboard = Cruscotto delle operazioni
menu-statistics-crossed-balance = Bilancio incrociato

menu-budget = Budget
menu-budget-entry = Inserimento budget
menu-budget-control = Controllo budget

menu-nomenclatures = Nomenclature
menu-nomenclature = { $kind ->
    [category] Categorie
    [assignment] Assegnazioni
    [payment-mode] Modalità operazione
    [payee] Terzi e commercianti
    [project] Progetti
    [budget-line] Voci di Bilancio
   *[bank] Banche
}
menu-nomenclatures-templates = Modelli di operazioni

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Strumenti
menu-settings = Impostazioni
menu-settings-about-author = Informazioni sull'autore
menu-settings-about-radinus = Informazioni su Radinus
menu-settings-licence = Licenza d'uso

menu-misc = Varie
menu-misc-calculator = Calcolatrice
menu-misc-website = Andare sul sito di Radinus
menu-misc-database-folder = Accesso alla cartella contenente la base di dati

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Aprire la cartella del database
database-folder-warning =
    Questa cartella contiene tutti i vostri dati. Rinominare, spostare o eliminare un file può farvi perdere i conti, danneggiarli o impedire a Radinus di funzionare.
    Volete davvero aprirla?
menu-misc-application-folder = Accesso alla cartella contenente l'applicazione
menu-misc-attachments-folder = Accesso alla cartella contenente gli allegati
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Gestione degli allegati
window-attachments-manager-title = Gestione degli allegati
attachments-column-document = Documento
attachments-column-size = Dimensione
attachments-column-added = Aggiunto il
attachments-column-state = Stato
attachments-state-intact = Intatto
attachments-state-altered = Modificato da allora
attachments-state-missing = File assente
attachments-state-unknown = Non verificabile
attachments-state-orphan = Orfano
attachments-no-operation = Nessuna operazione
attachments-orphan-remove-question = Questo file non è collegato a nessuna operazione. Spostarlo nel cestino?
attachments-manager-help = Fate doppio clic su una riga per aprire il documento.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Mostrare l'operazione
attachments-reveal = Mostrare nel gestore di file
attachments-manager-summary = { $count } allegati, { $size } in tutto.
attachments-disk-name = Nome sul disco: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Aprire la cartella degli allegati
attachments-folder-warning =
    Questa cartella contiene i file che avete allegato alle vostre operazioni. Radinus li conserva con un nome scelto da lui: rinominare, spostare o eliminare un file non lo stacca dall'operazione, che continuerà ad annunciarlo e non si aprirà più.
    Volete davvero aprirla?

# ---------------------------------------------------------------------
# Conti bancari — F04, F06, F07, F08.
# I refusi della versione 1.9.3 («Bank Identifer Code», «Solde
# initial prevu», «Est Cloturé», lo spazio prima della parentesi dell'IBAN)
# sono corretti: decisione di Fabrice del 25/07/2026.
# ---------------------------------------------------------------------

window-accounts-title = Gestione dei conti bancari
window-accounts-select-title = Elenco dei conti
window-balances-title = Saldi dei suoi conti
window-account-title = Scheda conto

accounts-none = Nessun conto.
accounts-nothing-to-show = Nessun conto da visualizzare.
accounts-gone = Questo conto non esiste più.
accounts-fresh = Nuovo conto.
accounts-created = Conto aggiunto.
accounts-updated = Conto modificato.
accounts-deleted = { $count ->
    [one] 1 conto eliminato.
   *[other] { $count } conti eliminati.
}
accounts-duplicate-name = Esiste già un conto con lo stesso nome: «{ $label }».
accounts-multiselect-help = Info: utilizzi clic del mouse + tasto [{ $modifier }] sulla tabella per selezionare più conti
accounts-select-question = Su quali conti bancari devono basarsi le statistiche?

accounts-column-label = DESCRIZIONE
accounts-column-bank = Banca
accounts-column-type = Tipo conto
accounts-column-number = Num conto
accounts-column-account = Conto
accounts-column-bank-balance = In Banca
accounts-column-real-balance = Reale
accounts-column-final-balance = Finale
accounts-total = TOTALE

# L'eliminazione di un conto comporta quella delle sue operazioni: è l'unico punto
# del software in cui un'eliminazione distrugge dello storico.
accounts-delete-plain = Conferma l'eliminazione del conto «{ $label }»?
accounts-delete-with-operations = Il conto «{ $label }» contiene { $count } operazioni, che saranno eliminate insieme a esso. Conferma l'eliminazione?
accounts-delete-form-open = La scheda del conto «{ $label }» è aperta. La chiuda prima di eliminare.

account-group-bank = Info conto e banca
account-group-holder = Titolare
account-group-rib = Coordinate bancarie (IBAN)
account-group-activity = Attività
account-group-balances = Saldi

account-field-label = Titolo del conto
account-field-bank = Banca
account-field-type = Tipo conto
account-field-branch-address = Indirizzo della filiale bancaria
account-field-holder-name = Nome
account-field-holder-address = Indirizzo
account-field-rib-bank = Codice istituto
account-field-rib-branch = Codice sportello
account-field-rib-number = Numero di conto
account-field-rib-key = Codice di controllo
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Data di apertura
account-field-closing-date = Data di chiusura
account-field-closed = È chiuso
account-field-opening-pointed = Saldo iniziale riconciliato
account-field-opening-committed = Saldo iniziale impegnato
account-field-opening-planned = Saldo iniziale previsto

account-label-required = Il titolo del conto è obbligatorio.
account-iban-invalid = Questo IBAN non è valido: verifichi il codice di controllo.
# La riga blu in fondo alla scheda, parola per parola quella della 1.9.3 — solo gli
# importi seguono ormai il formato francese degli altri campi.
account-control-line = Saldo iniziale riconciliato ({ $opening }) + Totale delle operazioni ({ $operations }) = Saldo attuale in banca: { $balance }.

amount-not-readable = «{ $field }» non contiene un importo valido.

ui-thousands-separator = .
ui-decimal-separator = ,

# --- Elenco delle operazioni (F02) -----------------------------------

window-operations-title = Elenco operazioni del conto: { $account }

operations-none = Nessuna operazione in questo periodo.
operations-bad-period = I limiti del periodo non sono date valide.
operations-from = Data inizio
operations-to = Data fine
operations-delete-confirm = { $count ->
    [one] Conferma l'eliminazione di questa operazione?
   *[other] Conferma l'eliminazione di queste { $count } righe? Le sotto-operazioni delle operazioni selezionate saranno eliminate insieme a esse.
}
operations-deleted = { $count ->
    [one] 1 operazione eliminata.
   *[other] { $count } operazioni eliminate.
}
operations-selection-total = Importo totale delle operazioni selezionate: { $amount }

operations-column-date = Data
operations-column-clearing-date = Data Riconciliazione
operations-column-status = Stato operazione
operation-status-pointed = Riconciliato
operation-status-committed = Impegnato
operation-status-planned = Previsto
operations-column-verification = Verifica
operation-verification-to-verify = Da verificare
operation-verification-verified = Verificata
operation-verification-doubtful = Dubbia
operation-verification-disputed = Contestata
operations-column-label = Descrizione
operations-column-reference = Riferimento pagamento
operations-column-category = Categoria
operations-column-assignment = Assegnazione
operations-column-payment-mode = ModoOp
operations-column-payee = Terzi
operations-column-project = Progetti
operations-column-month = Mese
operations-column-debit = Debito
operations-column-credit = Credito
operations-column-balance = Saldo
operations-column-comments = Commenti
operations-column-attachments = Allegati
operations-column-check = Num Assegno

operations-foot-debit = Debito:
operations-foot-credit = Credito:
operations-foot-total = Totale:
operations-foot-bank = Saldo in banca:
operations-foot-real = Saldo reale:
operations-foot-final = Saldo finale:

operations-menu-export = Esportazione
operations-menu-print = Stampa
operations-menu-filter = Filtro
operations-menu-period = Periodo
operations-menu-misc = Varie

operations-title-point = Riconciliare la selezione
operations-title-sub = Aggiungere una sotto-operazione
operations-title-duplicate = Duplicare la selezione
operations-not-yet = Questa finestra non esiste ancora: arriva più avanti nel piano.

accounts-choose-question = Su quale conto desidera lavorare?
ui-title-select = Scegliere la selezione

month-january = gennaio
month-february = febbraio
month-march = marzo
month-april = aprile
month-may = maggio
month-june = giugno
month-july = luglio
month-august = agosto
month-september = settembre
month-october = ottobre
month-november = novembre
month-december = dicembre

operations-period-year = Anno in corso

# --- Menu Periodo di F02 ---------------------------------------------
# Nove voci, due delle quali aprono un sottomenu dei dodici mesi. Ognuna
# fa una cosa sola: dedurne una data di inizio e una data di fine, che la
# finestra rimette nei suoi due campi (richiesta di Fabrice, 25/07/2026).

period-all = Tutte
period-last-year = Anno Scorso
period-this-year = Anno Attuale
period-whole-year = Tutto l'anno
period-last-month = Mese Scorso
period-this-month = Mese in Corso
period-last-week = Settimana Scorsa
period-this-week = Settimana Attuale
period-yesterday = Ieri
period-today = Oggi

# --- Menu Filtro di F02 ----------------------------------------------
# Filtra le righe secondo la natura dell'operazione (richiesta di Fabrice,
# 25/07/2026). I tre stati sono quelli della base: 1 riconciliato, 2 impegnato,
# 3 previsto (02_BASE_DE_DONNEES.md §5.2).

filter-all = Tutte le operazioni
filter-pointed = Solo le operazioni riconciliate
filter-committed = Solo le operazioni impegnate
filter-planned = Solo le operazioni previste
filter-by-status = Filtro per stato
filter-by-verification = Filtro per verifica
filter-show-all = Mostra tutto

# --- Scheda operazione (F03) -----------------------------------------
# Le diciture sono quelle della schermata «Fiche operation transaction.png»,
# con i refusi dell'originale corretti (autorizzazione di Fabrice, 25/07/2026:
# «les coquilles tu les corriges»): «Libelle» diventa «Libellé»,
# «Categorie» diventa «Catégorie», «Statut Operation» diventa
# «Statut opération».

window-operation-title = Operazione Conto: { $account }

operation-menu-identification = Identificazione
operation-menu-options = Opzioni
operation-fitid-edit = Modificare l'identificativo FITID…
operation-fitid-delete = Eliminare l'identificativo FITID
operation-fitid-question = Identificativo FITID di questa transazione:
operation-fitid-delete-question = Eliminare l'identificativo FITID di questa transazione?
operation-fitid-written = Identificativo FITID salvato.
operation-fitid-removed = Identificativo FITID eliminato.

operation-group-identification = Identificazione dell'operazione
operation-group-amount = Importo dell'operazione
operation-group-status = Stato dell'operazione
operation-group-classification = Classificazione dell'operazione per il calcolo delle statistiche
operation-group-check = Assegno collegato all'operazione
operation-group-comment = Commento

operation-field-label = Descrizione
operation-field-reference = Riferimento pagamento
operation-field-date = Data
operation-field-direction = Tipo Operazione:
operation-field-amount = Importo
operation-field-status = Stato operazione
operation-field-clearing-date = Data riconciliazione
operation-field-verification = Verifica
operation-field-category = Categoria
operation-field-assignment = Assegnazione
operation-field-payment-mode = Modalità
operation-field-payee = Terzo
operation-field-project = Progetto
operation-field-check = Associare a un assegno

operation-direction-debit = Debito
operation-direction-credit = Credito

operation-check-info = Info.
operation-check-link = Associare
operation-check-unlink = Eliminare

operation-fresh = Nuova operazione.
operation-created = Operazione aggiunta.
operation-updated = Operazione modificata.
operation-gone = Questa operazione non esiste più.
operation-nothing-to-show = Nessuna operazione da visualizzare.
operation-label-required = La descrizione dell'operazione è obbligatoria.
operation-date-required = La data dell'operazione è obbligatoria.
operation-clearing-date-invalid = La data di riconciliazione non è una data valida.
operation-clearing-date-required = Un'operazione puntata deve obbligatoriamente avere una data di punta.
operation-clearing-date-question =
    Un'operazione puntata deve obbligatoriamente avere una data di punta.
    Vuole registrare con la data dell'operazione, il { $date }?
operation-is-a-sub = Questa riga è una sotto-operazione: si modifica dalla sua scheda.
operation-delete-form-open = La scheda di «{ $label }» è aperta. La chiuda prima di eliminare.

operation-attachments = { $count ->
    [0] Nessun allegato
    [one] 1 allegato
   *[other] { $count } allegati
}

operation-title-comment = Commento dell'operazione
operation-title-sub = Creare una sotto-operazione
operation-title-template = Modelli di operazione
operation-title-attachment = Allegati

# --- Scheda sotto-operazione (F04) -----------------------------------
# Versione ridotta di F03: né Modalità, né Stato, né Data — una sotto-operazione
# li eredita dalla madre (`Maj_ProprieteSousOp`, confermato da Fabrice il
# 26/07/2026: «dans une sous-opération, comme est le complément, on ne peut
# pas toucher au mode de paiement, cela serait illogique»).

window-sub-operation-title = Scheda Sotto-Operazione

sub-operation-group-amount = Importo della sotto-operazione
sub-operation-field-label = Nome
sub-operation-fresh = Nuova sotto-operazione.
sub-operation-created = Sotto-operazione aggiunta.
sub-operation-updated = Sotto-operazione modificata.
sub-operation-gone = Questa sotto-operazione non esiste più.
sub-operation-nothing-to-show = Nessuna sotto-operazione da visualizzare.
sub-operation-label-required = Il nome della sotto-operazione è obbligatorio.
sub-operation-parent-gone = L'operazione da ripartire non esiste più.
# Ciò che la scheda dice quando mostra il Complemento. Non è protetto:
# lo si può modificare, ma si deve sapere che cosa si prende (decisione di
# Fabrice, 26/07/2026).
sub-operation-is-the-complement = Questo è il Complemento: ciò che resta da ripartire. Rinominarlo o cambiarne l'importo ne fa una sotto-operazione ordinaria.
sub-operation-of = Ripartizione di «{ $label }» ({ $amount })

operations-pointed = { $count ->
    [0] Nessuna operazione da riconciliare: la selezione è già riconciliata.
    [one] 1 operazione riconciliata.
   *[other] { $count } operazioni riconciliate.
}
operations-select-one = Selezioni una sola operazione.

# --- Duplicare e la visualizzazione delle sotto-operazioni (F02) -------
# Duplicare apre una scheda precompilata che l'utente conferma lui stesso
# (decisione di Fabrice, 26/07/2026): nulla è scritto finché non ha
# salvato, e può correggere la data o l'importo prima.

operation-copy = Copia da salvare: non è ancora stato creato nulla.
operations-show-children = Mostrare tutte le sotto-operazioni
operations-hide-children = Nascondere tutte le sotto-operazioni
operations-recurring-from = Creare un'operazione periodica da questa operazione

# --- Seconda conferma di un'eliminazione grave ------------------------
# Eliminare un conto bancario si porta via tutto il suo storico: un Sì/No si
# clicca senza leggere, allora si chiede di scrivere la parola (decisione di
# Fabrice, 26/07/2026). La parola è quella del dizionario — «Oui» in francese,
# «Yes» in inglese — quindi qui non c'è nulla da tradurre due volte.

accounts-delete-second-question = Questa eliminazione è definitiva e si porta via tutto lo storico del conto. Digiti «{ $word }» per confermarla.

# --- F20-F24 — Le sei statistiche -------------------------------------
# Modello comune, declinato su sei assi. Quella per categorie è servita da
# modello e Fabrice l'ha convalidata il 26/07/2026 prima che le altre cinque
# esistessero — i nomi delle colonne sono quelli dell'originale.

window-statistics-title = { $kind ->
    [assignment] Statistiche per assegnazione
    [budget-line] Statistiche per voce di bilancio
    [payment-mode] Statistiche per modalita di pagamento
    [payee] Statistiche per terzo e commerciante
    [project] Statistiche per progetto
    [verification] Statistiche per verifica
   *[category] Statistiche per categoria
}

statistics-axis-column = { $kind ->
    [assignment] Assegnazione
    [budget-line] VoceBilancio
    [payment-mode] ModalitaPagamento
    [payee] Terzi
    [project] Progetti
    [verification] Verifica
   *[category] NomeCategoria
}

statistics-unclassified = { $kind ->
    [assignment] Senza assegnazione
    [budget-line] Senza voce di bilancio
    [payment-mode] Senza modalita di pagamento
    [payee] Senza terzo
    [project] Senza progetto
    [verification] Da verificare
   *[category] Senza categoria
}
statistics-total = Totale
statistics-sum = Somma
statistics-cumulative = Cumulato

# I cinque interruttori della barra. La dicitura commuta ON/OFF, come
# nell'originale: è l'interruttore stesso a dire dove si trova.
statistics-switch-pointed = Operazioni riconciliate { $state }
statistics-switch-committed = Operazioni impegnate { $state }
statistics-switch-planned = Operazioni previste { $state }
statistics-switch-debits = Importi a debito { $state }
statistics-switch-credits = Importi a credito { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Non è stato scelto nessun conto: la statistica non riguarda nulla.
statistics-no-data = Nessuna operazione in quest'anno per i conti scelti.
statistics-detail-empty = Clicchi una casella con una cifra per vedere le operazioni che conta.
statistics-detail-none = Nessuna operazione dietro questa casella.
statistics-accounts = { $count ->
    [one] 1 conto
   *[other] { $count } conti
}
statistics-year-next = Anno successivo
statistics-year-previous = Anno precedente

statistics-column-date = Data
statistics-column-clearing-date = DataRiconciliazione
statistics-column-label = Descrizione
statistics-column-amount = Importo
statistics-column-comments = Commenti

accounts-stats-multiselect-help = Info: Utilizzi Clic del mouse + tasto [{ $modifier }] sulla tabella per scegliere più conti

# Il millesimo delle statistiche: ci si clicca sopra e si digita un anno.
# I limiti sono quelli del «Tutte» del menu Periodo — un anno di Radinus
# è un intero compreso tra 1950 e 2550 (Fabrice, 26/07/2026).
statistics-year-question = Su quale anno vuole lavorare? Radinus va da { $first } a { $last }.
statistics-year-choose = Scegliere l'anno

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Bilancio incrociato
crossed-balance-window-name = Bilancio incrociato
crossed-balance-column = Categoria
crossed-balance-no-data = Nessuna operazione in questo mese per i conti scelti.
crossed-balance-month-question = Su quale mese vuole lavorare? Un numero tra { $first } e { $last }.
crossed-balance-month-choose = Scegliere il mese
crossed-balance-next = Mese successivo
crossed-balance-previous = Mese precedente

# --- Esportazione delle tabelle (clic destro) -------------------------
# Una funzione della tabella, non di una finestra: tutti gli elenchi ce l'hanno.

export-to-excel = Esportare verso Excel (.xlsx)
export-to-word = Esportare verso Word (.docx)
export-to-tsv = Esportare verso TSV (.tsv)
export-to-ini = Esportare verso INI (.ini)
export-to-toml = Esportare verso TOML (.toml)
export-to-yaml = Esportare verso YAML (.yaml)
export-to-ofx = Esportare verso OFX (.ofx)
export-to-qif = Esportare verso QIF (.qif)
export-to-ods = Esportare verso LibreOffice Calc (.ods)
export-to-csv = Esportare verso CSV (.csv)
export-to-xml = Esportare verso XML (.xml)
# Il menu Esportazione della finestra delle statistiche: una scheda per anno,
# chiamata AN_2026. Gli anni vuoti — sotto gli interruttori impostati — non ci sono.
export-menu = Esportazione
export-to = Esportare verso
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Copia cella
copy-rows = Copia le righe selezionate
copy-failed = Copia negli appunti non riuscita.
export-all-years-excel = Esportare tutti gli anni verso Excel
export-all-years-ods = Esportare tutti gli anni verso LibreOffice Calc
export-all-months-excel = Esportare tutti i mesi dell'anno visualizzato verso Excel
export-all-months-ods = Esportare tutti i mesi dell'anno visualizzato verso LibreOffice Calc
export-no-year = Nessun anno porta operazioni: non c'è nulla da esportare.
export-years-done = { $years } anni esportati verso «{ $file }».
export-to-json = Esportare verso JSON (.json)
export-done = Esportato verso «{ $file }».
export-failed = Esportazione impossibile: { $reason }
export-nothing = Non c'è nulla da esportare.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Statistiche per assegnazione
    [budget-line] Statistiche per voce di bilancio
    [payment-mode] Statistiche per modalita di pagamento
    [payee] Statistiche per terzo e commerciante
    [project] Statistiche per progetto
    [verification] Statistiche per verifica
   *[category] Statistiche per categoria
}
statistics-detail-name = Dettaglio delle statistiche

# --- F19 — Cruscotto --------------------------------------------------
# Un periodo e tre interruttori; due anelli per voce di bilancio;
# tre grandi cifre. I colori dei settori sono quelli dell'originale,
# rilevati sulla schermata di Fabrice.

window-dashboard-title = Cruscotto
dashboard-menu-period = Periodo
dashboard-menu-misc = Varie
dashboard-from = Data inizio:
dashboard-to = Data fine:
dashboard-switch-pointed = Includere operazioni riconciliate
dashboard-switch-committed = Includere operazioni impegnate
dashboard-switch-planned = Includere operazioni previste
dashboard-spending = Spese
dashboard-earning = Guadagni
dashboard-debits = Somma operazioni a debito
dashboard-credits = Somma operazioni a credito
dashboard-balance = Bilancio
dashboard-unclassified = Senza voce di bilancio
dashboard-nothing = Nessuna operazione in questo periodo.
dashboard-no-account = Nessun conto è stato scelto: il cruscotto non riguarda nulla.
dashboard-enlarge = Aprire a schermo intero

# --- F25 — Evoluzione del saldo ----------------------------------------
# Una curva per ogni conto scelto, più quella del totale — che esiste solo
# a partire da due conti (regola di Fabrice, 26/07/2026). Le curve sono
# a gradini: il saldo mantiene il suo valore fino all'operazione successiva.

window-curve-title = Evoluzione del saldo
curve-heading = Evoluzione del saldo per giorno
curve-menu-period = Periodo
curve-total = Totale
curve-from = Data inizio:
curve-to = Data fine:
curve-axis-balance = saldo
curve-nothing = Nessun conto è stato scelto: non c'è alcuna curva da tracciare.
curve-empty = Nessuna operazione in questo periodo.

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Analisi dell'evoluzione del saldo
analysis-heading = Analisi dell'evoluzione del saldo
analysis-hint = Tracciate una zona sul grafico, tenendo premuto il pulsante del mouse, per vedere le operazioni di quel periodo.
analysis-zone = Zona:
analysis-opening = Saldo iniziale:
analysis-closing = Saldo finale:
analysis-variation = Variazione:
analysis-detail-name = Analisi del saldo
analysis-detail-none = Nessuna operazione in questa zona.

# --- F05 — Classificazione rapida delle operazioni ---------------------
# La finestra in cui si classifica **in massa**: si selezionano delle righe, si
# spuntano le caratteristiche da cambiare e le si applicano in un colpo solo — in
# memoria. Nulla viene scritto finché non si è salvato, e il salvataggio
# scrive solo ciò che differisce da ciò che è stato letto (regole di Fabrice,
# 27/07/2026).

window-quick-classification-title = Classificazione rapida delle operazioni: { $account }
quick-dates-title = Date di inizio e fine elenco.
quick-from = Data inizio
quick-to = Data fine
quick-menu-period = Periodo
quick-change-title = Cambiare caratteristiche selezione in:
quick-check-category = Categoria
quick-check-assignment = Assegnazione
quick-check-payment-mode = Modalità
quick-check-payee = Terzo
quick-check-project = Progetto
quick-check-status = Stato
quick-check-verification = Verifica
quick-column-date = Data
quick-column-label = Descrizione
quick-column-amount = Importo
quick-column-category = Categoria
quick-column-assignment = Assegnazione
quick-column-payment-mode = Modalità pagamento
quick-column-payee = Terzo
quick-column-project = Progetti
quick-column-status = Stato
quick-column-verification = Verifica
# Su un Mac, Ctrl + clic è un clic destro: il tasto che aggiunge a una
# selezione è ⌘, e l'aiuto deve indicare quello che funziona.
quick-multiselect-help = Info: Utilizzi clic del mouse + tasto [{ $modifier }] sulla tabella per selezionare più elementi
quick-none = Nessuna operazione in questo periodo.
quick-select-lines = Selezioni almeno una riga e spunti almeno una caratteristica.
quick-applied = { $count ->
    [0] Nulla è cambiato: queste righe avevano già questa classificazione.
    [one] 1 riga classificata. Nulla è ancora salvato.
   *[other] { $count } righe classificate. Nulla è ancora salvato.
}
quick-pending = { $count ->
    [0] Nessuna modifica in sospeso.
    [one] 1 riga modificata, non salvata.
   *[other] { $count } righe modificate, non salvate.
}
quick-save-question = { $count ->
    [one] Salvare la modifica in sospeso?
   *[other] Salvare le { $count } modifiche in sospeso?
}
quick-saved = { $count ->
    [0] Non c'era nulla da salvare.
    [one] 1 riga salvata.
   *[other] { $count } righe salvate.
}
quick-nothing-to-save = Nessuna modifica in sospeso.
quick-leave-question = Alcune modifiche non sono salvate. Che cosa vuole fare?
quick-leave-save = Salvare e uscire
quick-leave-discard = Abbandonare e uscire
quick-leave-stay = Restare
quick-title-apply = Applicare alle righe selezionate ( in memoria )
quick-title-save = Salvare su disco

# --- F17 / F18 — Importazione di un estratto conto bancario ------------
# Si sceglie un conto, si apre un file OFX — che resta in RAM —, le
# righe che la base conosce già appaiono in pastello, e la terza icona
# le integra: in massa se ne sono state scelte più di una, una per una tramite la
# scheda di riconciliazione altrimenti (procedura di Fabrice, 27/07/2026).

window-statement-import-title = Importazione di estratti conto bancari: { $account }
window-statement-form-title = Riconciliare una transazione (Integra un'operazione nello storico del suo conto)
statement-menu-filter = Filtro
statement-filter-all = Tutte le righe
statement-filter-pending = Da integrare
statement-filter-known = Già integrate
statement-column-id = ID
statement-column-reconciled = Riconciliato
statement-column-fitid = FITID
statement-column-date = Data
statement-column-label = Descrizione
statement-column-reference = Riferimento pagamento
statement-column-debit = Debito
statement-column-credit = Credito
statement-account = Conto
statement-file = File
statement-difference = Scarto
statement-none = Nessun estratto conto è aperto: clicchi sulla cartella gialla per scegliere un file (OFX, CSV, QIF).
statement-empty = Questo estratto conto non contiene alcuna operazione.
statement-no-match = Nessuna riga corrisponde al filtro.
statement-help = Info: Utilizzi clic del mouse + tasto [{ $modifier }] sulla tabella per selezionare più righe
statement-choose-account = Questo file contiene più conti. Quale vuole importare?
statement-select-line = Selezioni almeno una riga dell'estratto conto.
statement-title-open = Aprire un file di estratto conto (OFX, QIF, CSV)
statement-title-info = Informazioni sul file aperto
statement-title-integrate = Integrare la selezione nel conto
statement-title-validate = Integrare questa operazione nel conto
statement-duplicate = Attenzione duplicato: questa transazione sembra essere già stata integrata nella base (Financial Institution Transaction ID esistente)
statement-no-fitid = Attenzione: questo file non fornisce alcun identificatore (FITID) per questa riga. Un duplicato non potrà essere rilevato.
statement-loaded = { $count ->
    [0] Questo file non contiene alcuna operazione per questo conto.
   *[other] { $count } righe lette, di cui { $known } già presenti nel suo conto.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } righe lette; nessuna somiglia a un'operazione già presente nel suo conto.
    [one] { $count } righe lette, di cui una che somiglia a un'operazione già presente nel suo conto (stessa data, stessa descrizione, stesso importo).
   *[other] { $count } righe lette, di cui { $alike } che somigliano a operazioni già presenti nel suo conto (stessa data, stessa descrizione, stesso importo).
}
statement-loaded-also-alike = { $alike ->
    [one] Un'altra somiglia a un'operazione già presente (stessa data, stessa descrizione, stesso importo).
   *[other] Altre { $alike } somigliano a operazioni già presenti (stessa data, stessa descrizione, stesso importo).
}
statement-integrated = { $count ->
    [0] Nulla è stato inserito: queste righe sono già nel suo conto.
    [one] 1 operazione integrata.
   *[other] { $count } operazioni integrate.
}
# **I messaggi dell'originale, parola per parola** (istruzione di Fabrice,
# 28/07/2026: restare fedeli al codice d'origine). Il suo avverte prima del lotto,
# chiede riga per riga davanti a un duplicato, e rende conto alla fine.

statement-mass-question =
    È sicuro di voler integrare nel suo conto simultaneamente più operazioni?
    Dovrà categorizzarle e caratterizzarle in seguito per fare statistiche precise
    Nel caso dei file Ofx: se vengono rilevati dei duplicati dovrà scegliere il comportamento del programma
    Per gli altri tipi di file: dovrà fare attenzione ai duplicati
statement-duplicate-question =
    La transazione: { $date } { $label }: { $amount }
    sembra essere già stata integrata nello storico delle transazioni del suo conto bancario.
    Vuole davvero procedere alla riconciliazione?
statement-already-reconciled = Ha già riconciliato questa transazione: è già integrata nello storico delle transazioni del suo conto
statement-integration-report =
    Fine dell'integrazione.
    Numero di registrazioni integrate: { $added }
    Numero di registrazioni ignorate: { $ignored }
statement-integration-abandoned =
    Abbandono dell'integrazione!
    Numero di registrazioni integrate: { $added }
    Numero di registrazioni ignorate: { $ignored }
statement-yes = Sì
statement-no = No
statement-cancel = Annullare
statement-file-info =
    Conto del file: { $account }
    Periodo: dal { $from } al { $to }
    Saldo dichiarato dalla banca: { $balance }
statement-qif-question = Niente in questo file indica se la data «{ $date }» è scritta giorno/mese o mese/giorno. Significa:
statement-qif-day-month = Giorno { $day }, mese { $month } (giorno/mese)
statement-qif-month-day = Giorno { $day }, mese { $month } (mese/giorno)
statement-qif-dates-mixed = Questo file scrive le sue date in due modi: «{ $first }» si legge giorno/mese, «{ $second }» mese/giorno. Non viene importato, per non falsare nessuna data.
statement-qif-amounts-mixed = Questo file scrive i suoi importi in due modi: «{ $first }» con un punto, «{ $second }» con una virgola. Non viene importato, per non falsare nessun importo.
statement-qif-opening = Saldo iniziale di { $amount } al { $date }: non è un'operazione, non viene importato.
statement-qif-opening-undated = Saldo iniziale di { $amount }: non è un'operazione, non viene importato.
statement-qif-suspect = La riga { $rank }, «{ $label }» ({ $amount }), sembra un saldo iniziale: la verifichi prima di integrarla.
statement-qif-rejected = { $count ->
    [one] Una riga illeggibile non viene importata: { $lines }.
   *[other] { $count } righe illeggibili non vengono importate: { $lines }.
}
statement-qif-reason-date = data
statement-qif-reason-amount = importo
statement-qif-reason-differ = importi contraddittori
statement-qif-no-account = Questo conto non è più nel file: riapra il file.
statement-balance-unknown = non indicato nel file
statement-group-identification = Identificazione dell'operazione
statement-group-amount = Importo dell'operazione
statement-group-classification = Classificazione dell'operazione per il calcolo delle statistiche
statement-group-status = Stato dell'operazione
statement-field-date = Data
statement-field-label = Descrizione
statement-field-reference = Riferimento pagamento
statement-field-type = Tipo Operazione
statement-field-amount = Importo
statement-field-mode = Modalità Operazione
statement-field-category = Categoria
statement-field-assignment = Assegnazione
statement-field-payee = Terzo
statement-field-project = Progetto
statement-field-status = Stato
statement-field-clearing = Data riconciliazione

# --- La finestra di suddivisione di un estratto conto CSV --------------
# Un CSV non porta alcun nome di campo affidabile: si regola, si prova, si guarda,
# si ricomincia. L'anteprima mostra tutto, farfugliamenti compresi — è così che si
# vede di aver sbagliato — ma solo le righe valide passano alla
# finestra di integrazione (regola di Fabrice, 27/07/2026).

window-csv-statement-title = Importazione di dati provenienti da un file csv
csv-preview-title = Anteprima del file:
csv-settings-title = Parametri di suddivisione del file in vista dell'estrazione dei dati:
csv-extraction-title = Visualizzazione dell'estrazione dei dati secondo i parametri di suddivisione  ( verificare la coerenza dei dati ):
csv-column-line = N° riga
csv-column-content = Contenuto
csv-header-lines = Numero di righe dell'intestazione del file da ignorare
csv-separator = I dati (colonne) sono separati dal carattere:
csv-date-at = Posizione campo data
csv-label-at = Posizione campo descrizione
csv-debit-at = Posizione campo importo debito
csv-credit-at = Posizione campo importo credito
csv-test = Provare i parametri
csv-separator-semicolon = Punto e virgola   ;
csv-separator-comma = Virgola   ,
csv-separator-tab = Tabulazione
csv-separator-pipe = Barra verticale   |
csv-separator-space = Spazio
csv-help = Regoli, provi, guardi: solo le righe che portano una data e un importo leggibili saranno importate.
csv-none = Il file è vuoto.
csv-not-tested = Clicchi su «Provare i parametri» per vedere che cosa dà la suddivisione.
csv-extraction = { $count ->
    [0] La suddivisione non produce alcuna riga: verifichi il numero di righe di intestazione e il separatore.
   *[other] { $count } righe suddivise: { $valid } saranno importate, { $dropped } scartate per mancanza di una data o di un importo leggibili.
}
csv-nothing-valid = Nessuna riga porta al tempo stesso una data e un importo leggibili: non c'è nulla da importare. Verifichi il numero di righe di intestazione, il separatore e la posizione dei campi.
csv-title-validate = Passare le righe valide all'importazione

# --- F13 / F31 / F14 / F12 — Libretti degli assegni e assegni (fase 9) --
# Trasposizione dei suoi cinque codici WinDev e delle sue sette schermate,
# forniti il 28/07/2026. Le sue frasi esatte dove ne ha una; le mie altrove.
#
# Tre fedeltà che ha arbitrato quel giorno e che si sentono nelle parole: il
# riferimento doppio non viene annunciato (la sua `Existe_Reference` non è
# mai chiamata), il numero di assegni non viene confrontato con i limiti, e
# il contatore delle operazioni conta le figlie che gli elenchi rifiutano.

window-chequebooks-title = Elenco dei libretti degli assegni
window-chequebook-title = Parametri libretto degli assegni
window-cheques-title = Composizione del libretto degli assegni: elenco degli assegni.
window-cheque-title = Scheda assegni
window-cheque-operations-title = Elenco delle operazioni.

# L'elenco dei libretti degli assegni (F13) — tutti i libretti, di tutti i
# conti insieme: le sue due colonne di conto non servirebbero a nulla su uno
# solo.
chequebooks-column-reference = DESCRIZIONE
chequebooks-column-date = Data
chequebooks-column-account = NomeConto
chequebooks-column-account-number = Num. Conto
chequebooks-column-comments = Commenti
chequebooks-none = Nessun libretto degli assegni è registrato.
chequebooks-nothing-to-show = Nessun libretto degli assegni risponde a questa ricerca.
chequebooks-title-composition = Vedere la composizione del libretto degli assegni
chequebooks-delete-question = Sono state rilevate delle operazioni (transazioni bancarie) associate a libretto degli assegni. Conferma di voler eliminare questo libretto degli assegni?
chequebooks-deleted = { $count ->
    [one] Un libretto degli assegni eliminato.
   *[other] { $count } libretti degli assegni eliminati.
}
chequebooks-gone = Questo libretto degli assegni non esiste più.
chequebooks-created = Libretto degli assegni registrato, con tutti i suoi assegni.
chequebooks-updated = Libretto degli assegni modificato.
# Il silenzio del suo `HAjoute`: la finestra non dice che il riferimento è
# già preso. Dice soltanto che nulla è stato registrato — altrimenti si
# crederebbe il libretto creato.
# Le otto precauzioni del suo « Precauttion enregistrement cheque.txt »,
# parola per parola e nel suo ordine. Le prime sette sono degli `Erreur()`,
# l'ottava un `Info()` — e l'ordine decide ciò che si vede quando due cose
# vanno male insieme.
chequebook-refusal-duplicate = Esiste già un riferimento con lo stesso nome
chequebook-refusal-reference-required = L'inserimento di un riferimento è obbligatorio
chequebook-refusal-number-too-big = I numeri del primo e/o dell'ultimo assegno sono troppo grandi (valore massimo 999.999.999)
chequebook-refusal-date = Inserisca una data di ricezione valida
chequebook-refusal-numbers-required = Compili i numeri del primo e dell'ultimo assegno
chequebook-refusal-order = Il numero del primo assegno deve essere inferiore al numero dell'ultimo assegno
chequebook-refusal-account = Selezioni obbligatoriamente il conto in relazione con questo libretto degli assegni
chequebook-refusal-too-many = Numero massimo di assegni per un libretto: 1000, limite raggiunto
# La sua richiesta di conferma, posta solo all'aggiunta: riepiloga ciò che
# sta per essere creato e avverte che nulla ne sarà modificabile dopo.
chequebook-creation-question =
    Creazione del libretto degli assegni con le caratteristiche seguenti:
    - Numero di assegni da generare:{ $count }
    - Assegni numerati da { $first } a { $last }
    Attenzione, questi dati non saranno modificabili dopo la creazione!

# La scheda libretto degli assegni (F31). I primi cinque campi sono in
# grigio non appena il libretto esiste: i suoi assegni sono già lì.
chequebook-field-id = Identificativo di Libretto degli assegni
chequebook-field-reference = Riferimento
chequebook-field-received = Fabbricato o ricevuto il
chequebook-field-first = Numero del primo assegno
chequebook-field-last = Numero dell'ultimo assegno
chequebook-field-quantity = Numero di assegni
chequebook-field-account = Associare al conto bancario:
chequebook-field-comments = Commenti
chequebook-locked = Gli assegni di questo libretto sono già creati: la sua numerazione non si modifica più.
# La sua frase, parola per parola (`Enreg_Lire`).
chequebook-account-missing = Il Conto bancario al quale è stato associato questo libretto degli assegni è assente o è stato eliminato!

# La composizione del libretto degli assegni (F14). Lo stato si cambia nella
# casella.
cheques-column-number = Num. Assegno
cheques-column-date = Data
cheques-column-place = Luogo
cheques-column-payee = Beneficiario
cheques-column-amount = Importo
cheques-column-status = Stato
cheques-column-comments = Commenti
cheques-column-operations = Num. Operazioni Associate
cheques-none = Questo libretto degli assegni non contiene alcun assegno.
cheques-nothing-to-show = Nessun assegno risponde a questa ricerca.
cheques-help = Clicchi nella casella Stato per cambiarlo; la lente mostra le operazioni associate, l'anello ne associa una.
cheques-title-linked = Vedere le operazioni già associate a questo assegno
cheques-title-link = Associare un'operazione a questo assegno
cheques-status-changed = Stato dell'assegno modificato.

# La scheda assegno (F12).
cheque-field-id = Identificativo di Assegno
cheque-field-number = Numero assegno
cheque-field-issued = Data Emissione
cheque-field-place = Luogo Emissione
cheque-field-payee = Beneficiario
cheque-field-amount = Importo
cheque-field-comments = Commenti
cheque-field-status = Stato dell'assegno
cheque-gone = Questo assegno non esiste più.
cheque-updated = Assegno modificato.

# I due volti della finestra di associazione.
cheque-operations-linked-title = Elenco delle operazioni già associate a questo assegno.
cheque-operations-choose-title = Scelga un'operazione da associare all'assegno
cheque-operations-column-account = Conto
cheque-operations-column-label = Nome
cheque-operations-column-date = Data
cheque-operations-column-clearing = Data Riconciliazione
cheque-operations-column-amount = Importo
cheque-operations-column-cheque = Assegno associato
cheque-operations-none-linked = Nessuna operazione è associata a questo assegno.
cheque-operations-none = Questo conto non contiene alcuna operazione.
cheque-operations-nothing-to-show = Nessuna operazione risponde a questa ricerca.
cheque-operations-help = Le operazioni in grassetto portano già un assegno.
cheque-operations-linked-help = La croce rossa stacca l'assegno dall'operazione: nulla viene eliminato.
cheque-operations-linked = Operazione associata all'assegno.
cheque-operations-dissociated = Assegno staccato dall'operazione.
cheque-operations-menu-filter = Filtro
cheque-title-associate = Associare questa operazione all'assegno
cheque-title-dissociate = Staccare l'assegno da questa operazione

# La fascia «Assegno in relazione con l'operazione» della scheda operazione,
# e i due tempi della pesca all'assegno — il libretto, poi l'assegno.
chequebooks-select-question = Scelga il libretto degli assegni
cheques-select-question = Scelga l'assegno da associare all'operazione
operation-check-save-first = Registri prima l'operazione: un assegno si associa a un'operazione che esiste.
operation-check-none = Questa operazione non porta alcun assegno.

# --- F36 / F37 — I modelli di operazione (fase 10) ----------------------
# Un modello è un inserimento già pronto: lo si applica per non ridigitare, e
# **sovrascrive** ciò che è nella scheda. Nulla parte sul disco finché la
# scheda operazione non è confermata (regola di Fabrice, 29/07/2026).

window-operation-templates-title = Elenco dei modelli di operazioni
window-operation-template-title = Scheda Modello Operazione

operation-templates-none = Nessun modello di operazione è registrato.
operation-templates-nothing-to-show = Nessun modello risponde a questa ricerca.
operation-templates-select-question = Scelga il modello da applicare
operation-templates-delete-question = Conferma l'eliminazione dei modelli selezionati?
operation-templates-deleted = { $count ->
    [one] Un modello eliminato.
   *[other] { $count } modelli eliminati.
}
operation-template-gone = Questo modello non esiste più.
operation-template-fresh = Nuovo modello.
operation-template-created = Modello registrato.
operation-template-updated = Modello modificato.
operation-template-label-required = L'inserimento di un nome è obbligatorio
operation-template-duplicate = Esiste già un modello con lo stesso nome

# La scheda F36, sezione per sezione — le sue diciture esatte.
operation-template-field-id = ID Modello Operazione
operation-template-group-name = Nome predefinito della futura operazione dopo l'applicazione del modello
operation-template-field-label = Nome
operation-template-group-amount = Importo predefinito dell'operazione preimpostato in questo modello
operation-template-field-direction = Tipo Operazione
operation-template-field-amount = Importo
operation-template-group-status = Stato dell'operazione predefinito in questo modello
operation-template-field-status = Stato Operazione
operation-template-group-classification = Informazioni del modello per la classificazione e il calcolo delle statistiche
operation-template-field-category = Categoria
operation-template-field-assignment = Assegnazione
operation-template-field-mode = Modalità
operation-template-field-payee = Terzo
operation-template-field-project = Progetto

# Il pulsante «Modello» della scheda operazione: un'icona, due gesti.
operation-template-question = Che cosa vuole fare con i modelli di operazione?
operation-template-apply = Applicare un modello
operation-template-save-as = Salvare come modello
operation-template-applied = Modello applicato. Confermi la scheda per registrarla.
operation-template-saved-as = Operazione registrata come modello.
operation-template-needs-label = Dia un nome all'operazione prima di farne un modello.

# --- F26 / F27 — Il budget (fase 11) ------------------------------------
# Due porte, due domande: si inserisce il proprio budget, oppure si controlla
# se è stato rispettato. L'asse è la voce di bilancio, l'unità è l'anno, e la
# convenzione di segno è quella delle operazioni — una spesa si scrive
# negativa.

window-budget-entry-title = Inserimento Budget: spese(-) ed entrate(+) previste su un anno
window-budget-control-title = Controllo del budget

budget-column-line = Voce di bilancio
budget-none = Nessuna voce di bilancio è registrata: il budget si inserisce per voce.
budget-planned = Previsto
budget-actual = Realizzato
budget-sum = Somma
budget-cumulative = Cumulato
budget-total = Totale
# Il richiamo della convenzione di segno, in rosso sotto la tabella di
# inserimento. La sua frase, parola per parola e spazi compresi (schermata
# « POINT 004 saisie budget.png »): è in rosso sotto la tabella, e il titolo
# della finestra la ripete in forma abbreviata. Nessuno indovinerebbe la
# convenzione senza di essa.
budget-sign-warning = Inserisca obbligatoriamente le spese  con un segno negativo e le entrate previste con importi positivi
budget-entry-help = Digiti gli importi nelle caselle, poi salvi.
budget-saved = Budget registrato.
budget-nothing-changed = Nessuna modifica da registrare.
budget-discard-question = Abbandonare le modifiche del budget?

# Il menu Visualizzazione del controllo: i due modi di leggere lo stesso
# scarto.
budget-menu-display = Visualizzazione
budget-display-money = Valori
budget-display-percent = Percentuali
budget-control-help = Verde: almeno bene quanto previsto. Rosso: peggio.

# --- F09 — Trasferimento di un importo tra due conti (fase 12) -----------
# Un bonifico non è un'operazione, ne sono due: un debito sul conto di
# origine, un credito sul conto di destinazione. Partono insieme o niente.

window-transfer-title = Trasferire un importo tra due conti

transfer-group-source = Addebitare l'importo su questo conto di origine
transfer-group-target = Accreditare l'importo su questo conto di destinazione
transfer-group-description = Descrizione dell'operazione
transfer-group-nomenclature = Informazioni di Nomenclatura
transfer-group-amount = Importo della somma da trasferire
transfer-field-source = Conto di origine
transfer-field-target = Conto di destinazione
transfer-field-label = Descrizione
transfer-field-reference = Riferimento pagamento
transfer-field-date = Data
transfer-field-status = Stato Operazione
transfer-field-clearing = Data riconciliazione
transfer-field-category = Categoria
transfer-field-mode = Modalità di pagamento
transfer-field-assignment = Assegnazione
transfer-field-payee = Terzi / commercianti
transfer-field-project = Progetto
transfer-field-amount = Importo

# L'unico pulsante dei pannelli che annunciano invece di chiedere.
ui-ok = OK
transfer-help = Scelga i due conti: i loro saldi vengono visualizzati qui.
transfer-title-validate = Effettuare il bonifico
# I tre saldi del conto scelto, per sapere che cosa comporta il bonifico.
transfer-balances = { $account } — In banca: { $bank } · Reale: { $real } · Finale: { $final }
# Il pannello che riepiloga ciò che è appena stato scritto.
transfer-done = Bonifico effettuato. { $amount } dal conto { $source } verso il conto { $target }, il { $date }.

transfer-refusal-accounts-required = Scelga il conto di origine e il conto di destinazione
transfer-refusal-same-account = Il conto di origine e il conto di destinazione non possono essere lo stesso: un bonifico va da un conto verso un altro
transfer-refusal-account-gone = Uno dei due conti non esiste più
transfer-refusal-label-required = La descrizione è obbligatoria
transfer-refusal-date-required = La data è obbligatoria
transfer-refusal-amount = L'importo da trasferire deve essere strettamente positivo

# ---------------------------------------------------------------------------
# Fase 13 — l'importazione di un foglio Excel (F34, F35, associazione).
# ---------------------------------------------------------------------------

window-excel-import-title = Importazione di foglio excel [ Passo 1/3 ]: definizione della zona di cattura
window-excel-fields-title = Importazione di foglio excel [ Passo 2/3 ]: associazione dei campi
window-excel-association-title = Importazione di foglio excel: associazione dei dati

# La domanda posta all'apertura. Un file Excel è fatto a mano:
# contiene ciò che contiene, e una parte delle assurdità che porta
# è impossibile da rilevare. Si propone quindi la rete prima di saltare.
excel-backup-question = Un foglio Excel è fatto a mano: può contenere date giuste ma false, importi del formato giusto e del segno sbagliato — e questo, nessun controllo può vederlo. L'importazione scriverà queste righe nel suo conto. Vuole salvare una copia di sicurezza dei suoi dati prima di cominciare?

excel-group-file = 1 - Designare il file Excel da importare
excel-pick = Designare il file Excel
excel-sheet = Foglio della cartella di lavoro:
excel-group-header = 2 - Definire: coordinate delle celle per la riga di intestazione della tabella dove sono scritti i nomi delle colonne.
excel-header-row = Numero della 1ª riga dove è situato il nome delle colonne
excel-first-column = Colonna di inizio intestazione ( colonna più a sinistra ):
excel-column-count = Numero di colonne della tabella
excel-group-rows = 3 - Definire: numeri della riga di inizio e di fine dell'elenco contenente i dati della tabella ( sotto l'intestazione e senza includerla )
excel-first-data-row = Prima riga contenente dei dati
excel-last-data-row = Ultima riga contenente dei dati:
excel-group-shape = 4 - Definire: come il suo file scrive gli importi
excel-shape-single = Una sola colonna di importi, con segno ( le spese in negativo )
excel-shape-debit-credit = Due colonne separate: una colonna Debito e una colonna Credito
excel-shape-note = Nella modalità a due colonne, il segno scritto nella colonna Debito non viene preso in considerazione: un debito fa sempre uscire del denaro, che sia annotato «-50» o «50».
excel-group-test = 5 - Risultato Test: visualizzi la cattura effettuata in funzione della sua configurazione
excel-test = Provi i parametri che ha definito ai passi 2, 3 e 4.
excel-test-note = Indicazione: il nome delle intestazioni e il contenuto della tabella qui sotto devono corrispondere a quelli della sua tabella Excel. La zona di cattura non deve debordare al di fuori della zona della tabella.

excel-help = Scorra i cinque gruppi nell'ordine, poi provi: non potrà passare al passo 2 se non dopo aver guardato ciò che la zona cattura.
excel-no-file = Designi prima il file Excel da importare.
excel-not-tested = Impostazioni modificate: rilanci il risultato test prima di confermare.
excel-tested = Zona catturata: { $rows } righe, { $columns } colonne. Verifichi che la tabella qui sotto assomigli al suo foglio.
excel-empty-capture = La zona che ha dichiarato non cattura nessuna riga: verifichi i numeri di riga e di colonna.
excel-title-next = Passare al passo successivo
excel-into-account = Importazione nel conto { $account }.

excel-tab-links = Collegamenti tra campi
excel-tab-settings = Parametri di importazione
excel-column-excel = Intestazione_Excel
excel-column-radinus = Voce_Radinus
excel-links-help = Di fronte a ogni colonna del suo foglio, dica quale voce di Radinus alimenta. Le colonne lasciate su [IGNORE] non vengono importate.
excel-group-category = Categorie senza corrispondenze
excel-group-payment-mode = Modalità di pagamento senza corrispondenze
excel-group-assignment = Assegnazione senza corrispondenze
excel-policy-create = { $kind ->
    [payment-mode] Creare automaticamente le modalità di pagamento inesistenti
    [assignment] Creare automaticamente le assegnazioni inesistenti
   *[category] Creare automaticamente le categorie inesistenti
}
excel-policy-ask = { $kind ->
    [payment-mode] Chiedere per ogni modalità di pagamento inesistente dove trasferire i dati
    [assignment] Chiedere per ogni assegnazione inesistente dove trasferire i dati
   *[category] Chiedere per ogni categoria inesistente dove trasferire i dati
}
excel-policy-blank = { $kind ->
    [payment-mode] Lasciare la modalità di pagamento vuota
    [assignment] Lasciare l'assegnazione vuota
   *[category] Lasciare la categoria vuota
}
excel-policy-default = { $kind ->
    [payment-mode] Trasferire le modalità di pagamento inesistenti in una modalità di pagamento predefinita
    [assignment] Trasferire le assegnazioni inesistenti in un'assegnazione predefinita
   *[category] Trasferire le categorie inesistenti in una categoria predefinita
}
excel-define-destination = Definire destinazione
excel-not-linked = { $kind ->
    [payment-mode] Nessuna colonna alimenta la modalità di pagamento: questa impostazione non si applica.
    [assignment] Nessuna colonna alimenta l'assegnazione: questa impostazione non si applica.
   *[category] Nessuna colonna alimenta la categoria: questa impostazione non si applica.
}
excel-fields-help = Regoli le concordanze, poi le tre politiche, prima di lanciare l'importazione.
excel-title-import = Lanciare l'importazione

excel-refusal-required = Le voci Data, Descrizione e Importo devono obbligatoriamente puntare su delle colonne excel
excel-refusal-column-twice = Voci Radinus diverse puntano sulla stessa colonna excel: una colonna può alimentare una sola voce
excel-refusal-field-twice = Una stessa voce Radinus è associata a due colonne excel: non può averne che una
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Ha scelto di chiedere dove trasferire le modalità di pagamento sconosciute: prema «Definire destinazione» prima di lanciare l'importazione.
    [assignment] Ha scelto di chiedere dove trasferire le assegnazioni sconosciute: prema «Definire destinazione» prima di lanciare l'importazione.
   *[category] Ha scelto di chiedere dove trasferire le categorie sconosciute: prema «Definire destinazione» prima di lanciare l'importazione.
}

excel-column-data = Dati_Excel
excel-column-destination = { $kind ->
    [payment-mode] ModalitàPagamento_Radinus
    [assignment] Assegnazione_Radinus
   *[category] Categoria_Radinus
}
excel-association-help = Di fronte a ogni valore proveniente dal suo foglio, scelga quello di Radinus in cui deve essere collocato. Una riga lasciata vuota resterà senza classificazione.
excel-association-none = Nessun valore sconosciuto: tutto ciò che porta il suo foglio esiste già in Radinus.

excel-imported = Importazione terminata: { $count } operazioni scritte, { $refused } righe rifiutate, { $created } valori di nomenclatura creati.
excel-report-title = Resoconto dell'importazione
excel-column-row = Riga Excel
excel-column-content = Contenuto
excel-column-reason = Motivo del rifiuto
excel-nothing-refused = Tutte le righe del suo foglio sono entrate: nessun rifiuto.

excel-refused-date = Data assente o illeggibile
excel-refused-amount = Importo assente o illeggibile
excel-refused-amount-both = Un importo nella colonna Debito e un altro nella colonna Credito: impossibile scegliere
excel-refused-amount-missing = Né debito né credito su questa riga

# ---------------------------------------------------------------------------
# Fase 16 — le operazioni periodiche (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Elenco delle operazioni periodiche
window-recurring-form-title = Scheda che definisce la regola di generazione di operazione periodica
window-recurring-calendar-title = Proposta di calendario delle operazioni da inserire nei suoi conti bancari

recurring-column-label = DESCRIZIONE
recurring-none = Nessuna regola periodica registrata.
recurring-help = Scelga una regola, poi il calendario per vedere le scadenze che propone.
recurring-title-calendar = Proporre il calendario delle scadenze
recurring-deleted = { $count ->
    [0] Nessuna regola eliminata.
    [one] Una regola eliminata. Le sue operazioni restano nel conto.
   *[other] { $count } regole eliminate. Le loro operazioni restano nei conti.
}
recurring-gone = Questa regola non esiste più.
recurring-delete-question = Eliminare le regole selezionate? Le operazioni che hanno già inserito resteranno nei suoi conti.

recurring-group-identity = Identificazione e conto bancario interessato
recurring-group-nomenclature = Nomenclatura
recurring-group-amount = Definizione dell'importo dell'operazione
recurring-group-period = Definizione del periodo
recurring-group-ending = Condizioni di fine del periodo
recurring-group-produced = Informazioni sulle operazioni già inserite ( solo per consultazione )

recurring-field-id = Identificativo di Operazione
recurring-field-account = Conto di destinazione
recurring-field-label = Descrizione
recurring-field-category = Categoria
recurring-field-mode = Modalità di pagamento
recurring-field-assignment = Assegnazione
recurring-field-payee = Terzi / commercianti
recurring-field-project = Progetto
recurring-field-direction = Tipo Operazione
recurring-field-amount = Importo
recurring-field-next = Data prossima operazione
recurring-field-every = Poi ogni
recurring-field-end-date = Data fine
recurring-field-repeat = Numero ripetizioni
recurring-field-guid = GUID Operazione
recurring-field-produced-count = Numero di operazioni inserite
recurring-field-produced-last = Data ultima operazione inserita
recurring-field-produced-total = Totale importi generati

recurring-unit-day = Giorno
recurring-unit-week = Settimana
recurring-unit-month = Mese
recurring-unit-quarter = Trimestre
recurring-unit-year = Anno
recurring-ending-no-limit = Senza limite
recurring-ending-until-date = Con data di Fine
recurring-ending-repeat-count = Numero ripetizioni

recurring-title-erase = Eliminare le operazioni già inserite da questa regola
recurring-erase-question = { $count ->
    [one] Questa regola ha inserito un'operazione nei suoi conti. Vuole eliminarla? I saldi saranno ricalcolati, e la regola non tornerà indietro.
   *[other] Questa regola ha inserito { $count } operazioni nei suoi conti. Vuole eliminarle tutte? I saldi saranno ricalcolati, e la regola non tornerà indietro.
}
recurring-erase-none = Questa regola non ha ancora inserito nessuna operazione.
recurring-erased = { $count ->
    [0] Nessuna operazione eliminata.
    [one] Un'operazione eliminata, saldi ricalcolati.
   *[other] { $count } operazioni eliminate, saldi ricalcolati.
}

recurring-calendar-help = Tolga con il cestino le scadenze che non vuole, poi confermi per inserirle.
recurring-calendar-none = Nessuna scadenza da proporre: verifichi la data di prossima operazione e il conto delle sue regole.
recurring-calendar-column-account = Conto
recurring-calendar-column-date = Data
recurring-calendar-column-label = Descrizione
recurring-calendar-column-amount = Importo
recurring-calendar-column-category = Categoria
recurring-calendar-column-assignment = Assegnazione
recurring-calendar-column-mode = Modalità Pagamento
recurring-calendar-column-payee = Terzi
recurring-calendar-column-project = Progetti
recurring-calendar-removed = { $count ->
    [one] Una scadenza tolta dalla proposta.
   *[other] { $count } scadenze tolte dalla proposta.
}
recurring-title-insert = Inserire nei conti le scadenze selezionate
recurring-nothing = Non resta nessuna scadenza da inserire.
# La domanda posta prima di scrivere: inserire un calendario crea delle vere
# operazioni in dei veri conti, e questo non si fa con un clic distratto.
recurring-insert-question = { $count ->
    [one] Inserire questa scadenza nel suo conto? Un'operazione sarà creata e i saldi ricalcolati.
   *[other] Inserire queste { $count } scadenze nei suoi conti? Altrettante operazioni saranno create e i saldi ricalcolati.
}
recurring-inserted = { $count ->
    [one] Un'operazione inserita. La regola riparte dopo l'ultima scadenza inserita.
   *[other] { $count } operazioni inserite. Le regole ripartono dopo la loro ultima scadenza inserita.
}

recurring-refusal-label-required = L'inserimento di una descrizione è obbligatorio
recurring-refusal-date-required = L'inserimento della data di prossima operazione è obbligatorio
recurring-refusal-date-too-old = La data di prossima operazione deve essere superiore o uguale all'anno 2000
recurring-refusal-account-gone = Il conto bancario specificato è introvabile, la preghiamo di selezionarne uno nuovo per rendere applicabile la regola
recurring-refusal-end-required = In caso di data di fine, la data deve essere inserita
recurring-refusal-end-before-start = La data di fine non può essere inferiore alla data della prossima operazione
recurring-refusal-end-too-far = Lo scarto tra la data di prossima operazione e la data di fine non può superare i 10 000 giorni

# --- Fase 15 — le stampe e i prospetti ---------------------------------
# Il grande titolo della fascia, ripreso parola per parola dal prospetto WinDev d'origine.
print-operations-title = Elenco delle transazioni bancarie e delle sotto-operazioni
print-menu-operations-pdf = Stampa su file PDF
print-recap-title = Riepilogo per categoria
print-recap-count = Righe
print-row-count = Numero di righe:
print-total-debit = Totale debito:
print-total-credit = Totale credito:
print-final-balance = Saldo finale:
print-licence = Radinus è software libero distribuito con licenza GNU GPL v3 o successiva
print-nothing = Non c'è nulla da stampare.
print-done = Prospetto stampato e aperto: «{ $file }».
print-failed = Stampa impossibile: { $reason }
# Il PDF è stato scritto correttamente, ma il sistema non è riuscito ad aprirlo: lo si
# dice senza far credere a un fallimento, dato che il file c'è.
print-not-opened = Prospetto stampato in «{ $file }», ma il suo sistema non è riuscito ad aprirlo da solo.

# --- Il prospetto RIB (F32) --------------------------------------------
# Le diciture delle coordinate bancarie, riprese dal documento d'origine.
rib-title = COORDINATE BANCARIE
rib-bank = Banca:
rib-national = RIB - Identificativo nazionale del conto
rib-establishment = ISTITUTO
rib-branch = SPORTELLO
rib-number = NUMERO DI CONTO
rib-key = CHIAVE RIB
rib-domiciliation = DOMICILIAZIONE
rib-iban = IBAN - Identificativo internazionale del conto
rib-bic = BIC - Identificativo internazionale dell'istituto
rib-holder = Intestatario del conto

# --- La finestra F32 ---------------------------------------------------
window-rib-title = Stampa del RIB ( Coordinate Bancarie )
rib-group-bank = Banca
rib-group-holder = Intestatario del conto
rib-group-details = Coordinate bancarie
rib-field-bank = Nome banca
rib-field-domiciliation = Domiciliazione
rib-field-holder = Nome dell'intestatario
rib-field-address = Indirizzo
rib-field-establishment = Istituto
rib-field-branch = Sportello
rib-field-number = Numero conto
rib-field-key = Chiave RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Importanti condizioni d'uso da rispettare obbligatoriamente in caso di stampa
rib-declaration = Io sottoscritto, utente del software, dichiaro sul mio onore:
rib-declaration-first = - Confermo di aver verificato presso la mia banca che le informazioni bancarie contenute in questa finestra sono corrette e conformi alla mia volontà . Confermo allo stesso modo che mi impegno a verificare che le informazioni contenute nel prospetto di stampa del RIB siano corrette e conformi alla mia volontà. Questa stampa e l'utilizzo del RIB avverranno sotto la mia intera responsabilità
rib-declaration-second = - Di essere l'intestatario del conto di cui sarà stampato il RIB, e di non servirmi delle funzioni di questo software per uno scopo contrario alla legge.
rib-title-print = Stampa su stampante
rib-title-pdf = Stampa su file PDF
# La casella non è un avvertimento decorativo: finché non è spuntata, i due
# pulsanti restano spenti (arbitrato di Fabrice, 01/08/2026).
rib-declaration-required = Spunti la dichiarazione sul proprio onore per poter stampare.
rib-help = Verifichi le sue coordinate, spunti la dichiarazione, poi stampi.
rib-account-gone = Questo conto bancario è introvabile.
rib-fields-read-only = Queste coordinate provengono dalla scheda del conto: le corregga nella scheda per cambiarle qui.
rib-printed = RIB inviato alla sua stampante predefinita.
rib-print-failed = Stampa impossibile: { $reason }
rib-pdf-done = RIB stampato e aperto: «{ $file }».
rib-pdf-not-opened = RIB stampato in «{ $file }», ma il suo sistema non è riuscito ad aprirlo da solo.
menu-accounts-bank-details = Emettere le coordinate bancarie (RIB)

# La scelta della stampante. Radinus pone la domanda da sé: nessuna delle tre
# webview apre la finestra di stampa del sistema.
print-choose-printer = Su quale stampante desidera stampare?
print-do-print = Stampa
rib-printed-on = RIB inviato alla stampante «{ $printer }».
ui-cancel = Annulla

# Il sistema non è riuscito a nominare alcuna stampante: si stampa comunque su
# quella predefinita piuttosto che bloccare l'utente.
print-printers-unknown = Il suo sistema non è riuscito a nominare alcuna stampante: il documento è stato inviato alla stampante predefinita.

print-menu-operations-printer = Stampa su stampante
print-sent-on = Prospetto inviato alla stampante «{ $printer }».
print-sent-default = Prospetto inviato alla sua stampante predefinita.

# --- Fase 17 — le operazioni sulla base di dati -------------------------
backup-archive = Archivio Radinus
backup-no-database = Nessuna base di dati è aperta.
backup-done = La base «{ $base }» è stata salvata in «{ $file }». Le altre basi non sono interessate.
backup-failed = Copia di sicurezza impossibile: { $reason }
backup-not-started = Non è stato possibile avviare il salvataggio:
restore-unreadable = Questo file non è un archivio Radinus leggibile: { $reason }
# La domanda dice ciò che sarà perduto prima di perderlo. A quel punto l'archivio
# è già stato letto: ciò che annuncia è certo.
restore-question = Ripristinare «{ $file }» nella base «{ $base }»? Tutto il contenuto attuale di questa base sarà cancellato e sostituito, e ciò che vi si trova andrà perduto. Le altre basi non vengono toccate.
restore-done = La base «{ $base }» è stata ripristinata: { $accounts } conti e { $operations } operazioni. Le altre basi non vengono toccate.
restore-failed = Ripristino impossibile: { $reason }
restore-empty-fields = Campi vuoti letti come valore nullo: { $count }.


# --- Il registro delle operazioni tecniche (fase 17) --------------------
# I tre stati del suo Ajoute_Log, in maiuscolo come da lui.
journal-status-success = SUCCESSO
journal-status-failure = FALLIMENTO
journal-status-repaired = RIPARATO
journal-step-reindex = Riparazione tabella base di dati
journal-step-refill = Nomenclatura di sistema vuota: valori predefiniti ripristinati
journal-step-table-created = Tabella assente dal database: ricreata vuota
journal-step-column-added = Colonna assente dalla tabella: aggiunta con il suo valore predefinito

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Protezione con password
window-password-form-title = Protezione con password
password-ask = Questo database è protetto. Inserisci la sua password.
password-group-database = Database interessato
password-group-password = Password
password-group-warning = Prima di confermare
password-field-old = Vecchia password
password-field-new = Nuova password
password-field-repeat = Ripeti la nuova password
password-hint = Lascia vuota la vecchia se il database non è ancora protetto. Lascia vuote le due nuove per togliere la protezione.
password-lost-warning = Una password persa è un database perso: niente permette di recuperarlo. I backup, invece, restano in chiaro.
password-show = Mostra la password
password-remove-question = Togliere la protezione da questo database?
password-mismatch = Le due digitazioni della nuova password sono diverse
password-wrong = La password non va bene
database-too-recent = Questa base è stata salvata da una versione più recente di Radinus (versione della base { $found }; questa versione legge fino alla versione { $supported }). Aggiornate Radinus per aprirla.
database-not-radinus = Questo file non è una base Radinus.
database-unreadable = Impossibile leggere la base: { $reason }
password-close-first = Chiudi questo database prima di cambiarne la password
password-now-protected = Il database è protetto da una password
password-now-clear = Il database non è più protetto
journal-step-date-fixed = Correzione di un'operazione senza data
journal-step-circular = Eliminazione di un'operazione incoerente: riferimento circolare
journal-step-flag-parent-true = Indicatore errato EstParent=Falso su un'operazione principale
journal-step-flag-parent-false = Indicatore errato EstParent=Vero su un'operazione principale
journal-step-flag-child = Indicatore errato EstParent=Vero su una sotto-operazione
journal-step-orphan = Eliminazione di una sotto-operazione orfana
journal-step-third-level = Eliminazione di una sotto-operazione collegata a un'altra sotto-operazione
journal-step-coherence = Ricalcolo generale della coerenza tra sotto-operazioni e operazioni principali
journal-step-balances = Ricalcolo di tutti i saldi di tutti i conti
journal-step-vacuum = Ottimizzazione del file della base di dati
journal-step-analyze = Aggiornamento delle statistiche di ricerca
journal-step-backup-begin = Inizio della copia di sicurezza della base
journal-step-backup-end = Fine della copia di sicurezza della base
journal-step-restore-begin = Inizio del ripristino della base a partire dall'archivio
journal-step-restore-end = Fine del ripristino della base a partire dall'archivio
journal-step-restore-read = Lettura dell'archivio

# --- La finestra del registro (⌘H) --------------------------------------
window-journal-title = Registro dell'ultima operazione tecnica
journal-column-step = Fase
journal-column-file = File
journal-column-table = Tabella
journal-column-status = Stato
journal-column-error = Errore
journal-column-comments = Commenti
journal-empty = Nessuna operazione tecnica è ancora stata effettuata dall'apertura del software.
journal-help = Il registro conserva solo l'ultima operazione tecnica: copia di sicurezza, ripristino, riparazione, cancellazione o apertura di un database.

# --- La riparazione -----------------------------------------------------
menu-file-repair-running = Riparazione e ottimizzazione in corso…
repair-done = { $anomalies ->
    [0] Riparazione della base «{ $base }» terminata: nessuna anomalia trovata. { $lines } fasi registrate. Le altre basi non sono interessate.
    [one] Riparazione della base «{ $base }» terminata: un'anomalia riparata. { $lines } fasi registrate. Le altre basi non sono interessate.
   *[other] Riparazione della base «{ $base }» terminata: { $anomalies } anomalie riparate. { $lines } fasi registrate. Le altre basi non sono interessate.
}
repair-failed = Riparazione impossibile: { $reason }

journal-status-started = IN CORSO
journal-status-finished = TERMINATO
journal-step-backup-table = Scrittura della tabella nell'archivio
journal-step-backup-write = Scrittura dell'archivio
journal-step-backup-verified = Verifica dell'archivio scritto: file riletti / attesi, registrazioni rilette / scritte
journal-step-backup-total = Totale salvato: registrazioni, dati, dimensione del file
journal-step-restore-table = Lettura della tabella nell'archivio
journal-step-restore-missing = File assente dall'archivio: questa tabella non sarà ripristinata
journal-step-restore-wipe = Cancellazione totale del contenuto della base prima del ripristino
journal-step-restore-write = Scrittura nella base
journal-step-restore-total = Totale ripristinato: conti, operazioni
journal-step-restore-empty-fields = Campi vuoti completati durante la lettura
backup-verify-mismatch = L'archivio scritto non si rilegge tale quale è stato scritto: non ci faccia affidamento, rifaccia la copia di sicurezza.

# --- Gli allegati di un'operazione (F28, fase 17) -----------------------
window-attachments-title = Allegati dell'operazione
attachment-filter = Documenti accettati
attachment-none = Questa operazione non porta alcun allegato.
attachment-title-add = Allegare un documento a questa operazione
attachment-title-open = Aprire l'allegato
attachment-title-remove = Rimuovere l'allegato e mandare il suo file nel cestino
# Lo stato del file sul disco. «Non verificabile» non è un'ammissione d'ignoranza
# gratuita: le impronte provenienti da Radinus 1.9.3 sono mutilate dal formato
# di salvataggio, e giudicare un file su di esse equivarrebbe ad accusare a caso.
attachment-state-ok = Intatto
attachment-state-changed = Modificato
attachment-state-missing = File assente
attachment-state-unknown = Non verificabile
attachment-added = «{ $name }» è stato allegato all'operazione.
attachment-removed = Allegato rimosso, il suo file è nel cestino.
attachment-removed-kept = Allegato rimosso, ma il suo file non ha potuto essere messo nel cestino.
attachment-remove-question = Rimuovere «{ $name }» da questa operazione? Il suo file sarà mandato nel cestino.
attachment-opened = «{ $name }» è stato aperto.
attachment-opened-changed = «{ $name }» è stato aperto, ma il suo contenuto è cambiato da quando è stato allegato.
attachment-gone = Questo allegato non esiste più.
attachment-file-missing = Il file di «{ $name }» è introvabile sul disco.
attachment-failed = Operazione impossibile: { $reason }
attachment-save-first = Salvi prima l'operazione: un allegato si collega a un'operazione che esiste.
attachment-refusal-missing = Questo file non esiste.
attachment-refusal-extension = Questo tipo di file non è accettato. Sono accettati: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = L'operazione a cui allegare questo documento non esiste.
journal-step-backup-attachments = Allegati aggiunti all'archivio
journal-step-backup-attachment-missing = Allegato introvabile sul disco: mancherà nell'archivio
journal-step-restore-attachments = Allegati estratti dall'archivio
attachment-title-replace = Sostituire il documento di questo allegato
attachment-replaced = Il documento è stato sostituito da «{ $name }».

# ---------------------------------------------------------------------
# F08 — il menu «Strumenti» della scheda conto.
#
# Le sue tre voci sono port dal WLangage di Fabrice (cartella
# «Information import export base piece jointe»): il calcolo del saldo
# iniziale riconciliato, le statistiche del conto e l'eliminazione di tutte
# le sue transazioni. Il menu agisce soltanto in modifica (arbitrato del
# 02/08/2026): alla creazione non c'è nulla da contare, in consultazione la
# scheda si limita a mostrare.
# ---------------------------------------------------------------------

account-tools = Strumenti
account-tools-initial-balance = Definire il saldo iniziale riconciliato
account-tools-statistics = Statistiche conto bancario
account-tools-delete-operations = Eliminare tutte le transazioni del conto

# La domanda del calcolo, parola per parola quella dell'originale. { $total } è
# il totale delle operazioni riconciliate, già scritto in formato monetario.
account-initial-balance-question =
    Per calcolare il saldo iniziale riconciliato rispetto alle operazioni presenti su questo conto, la preghiamo di indicare il saldo attuale della sua banca
    Il saldo iniziale riconciliato sarà calcolato come uguale a:
    { "[" }Saldo banca attuale] - [Totale operazioni riconciliate ({ $total }) ].
    { "" }
    Per non dover reinserire questo valore deve essere completamente aggiornato con la lista delle operazioni bancarie di questo conto.

account-statistics-none = Nessuna transazione

# Le quattordici righe del suo Info(). Il refuso «pengagés» dell'originale è
# corretto, per decisione di Fabrice del 02/08/2026 — come «Bank Identifer
# Code» su questa stessa scheda.
account-statistics =
    Numero totale di transazioni in questo conto: { $count }
    { "" }
    Numero di transazioni riconciliate in questo conto: { $pointed }
    Importo dei debiti riconciliati: { $pointedDebits }
    Importo dei crediti riconciliati: { $pointedCredits }
    Differenza tra crediti e debiti riconciliati: { $pointedDifference }
    { "" }
    Numero di transazioni impegnate in questo conto: { $committed }
    Importo dei debiti impegnati: { $committedDebits }
    Importo dei crediti impegnati: { $committedCredits }
    Differenza tra crediti e debiti impegnati: { $committedDifference }
    { "" }
    Numero di transazioni previste in questo conto: { $planned }
    Importo dei debiti previsti: { $plannedDebits }
    Importo dei crediti previsti: { $plannedCredits }
    Differenza tra crediti e debiti previsti: { $plannedDifference }
    { "" }
    Transazione più antica: { $first }
    Transazione più recente: { $last }

# La doppia barriera dell'eliminazione. { $word } è il «sì» della lingua
# corrente — un ispanofono a cui si chiedesse di scrivere OUI non
# capirebbe (decisione di Fabrice, 02/08/2026).
account-delete-operations-question =
    È sicuro di voler eliminare tutte le operazioni contenute nel conto bancario?
    Per confermarlo scriva { $word } nel campo qui sotto e confermi

account-delete-operations-done =
    { $count ->
        [0] Nessuna transazione eliminata.
        [one] 1 transazione eliminata.
       *[other] { $count } transazioni eliminate.
    }

# ---------------------------------------------------------------------
# Il selettore di base e la scelta della lingua (02/08/2026)
#
# Decisioni prese in discussione con Fabrice: Radinus non crea più una
# base senza autorizzazione; senza lingua nella configurazione chiede la
# lingua prima di tutto il resto; è una base ogni cartella di databases/
# che contiene un radinus.sqlite, qualunque sia il suo nome.
#
# La finestra della scelta della lingua non ha alcuna chiave qui: non
# impiega alcuna frase, ed è questo che le permette di essere compresa
# prima che si sappia quale lingua parla l'utente.
# ---------------------------------------------------------------------

window-database-selector-title = Basi di dati
window-database-form-title = Nuova base di dati
database-group-identity = Identificazione della base di dati
database-group-restore = Inizializzare la base con i dati di un backup
database-choose-backup = Selezionare il file di backup
database-no-backup = Nessun backup scelto: la base nascerà vuota.

databases-column-label = Base
databases-column-comment = Commento
databases-column-folder = Cartella
databases-column-created = Creata il

databases-none = Nessuna base per ora: ne crei una.
databases-help = Scelga la base da aprire, o ne crei una nuova.
databases-select = Scelga prima una base nell'elenco.
databases-tools = Strumenti
databases-title-open = Aprire questa base

database-created = La base «{ $label }» è creata.
database-field-label = Nome della base
database-field-comment = Commento
database-label-required = Dia un nome a questa base: sarà lui a distinguerla dalle altre.
database-gone = Questa base non c'è più: è stata spostata o eliminata dopo l'apertura di questa finestra.

# L'eliminazione di una base (02/08/2026). La cartella va nel cestino del
# sistema, come gli allegati: una base eliminata per errore si rimette a
# posto con un clic destro. La base aperta è rifiutata — Radinus tiene il suo file.
databases-title-delete = Eliminare questa base
database-delete-question =
    È sicuro di voler eliminare la base «{ $label }»?
    { "" }
    Tutta la sua cartella va nel cestino: le operazioni, i conti e gli allegati.
    Per confermarlo, scriva { $word } nel campo qui sotto e confermi.
database-in-use = Questa base è aperta: Radinus non può eliminarla. Ne apra prima un'altra.
database-deleted = La base «{ $label }» è nel cestino.

# Il selettore ha due modi (Fabrice, 02/08/2026). Aperto mentre si lavora,
# non sa più aprire: una finestra di Radinus è costruita una volta sola e mai
# distrutta, e nulla saprebbe farle dimenticare la base che mostra. Si
# consulta, si crea, si elimina — e per cambiare base, si esce.
database-quit-first = Per aprire questa base, esca da Radinus e lo riavvii: il selettore gliela proporrà all'avvio.


# --- F01 — la finestra di benvenuto (fase 17 bis, 03/08/2026) -------------
#
# Prima aggiunta della 2.0.0 sulla 1.9.3: la finestra di benvenuto non porta
# più soltanto lo striscione. La regola che la governa è scritta nel documento
# 04 F01: è la vista SENZA UN CLIC, e nulla di ciò che richiede una regolazione
# vi entra.
#
# I due titoli dell'anello portano il mese intero invece di essere incollati
# uno all'altro dalla finestra: «Spese ... — agosto 2026» non ha lo stesso
# ordine delle parole nelle tre lingue, e solo Fluent sa dov'è il buco.

window-main-title = Radinus
welcome-month = { $month } { $year }
welcome-accounts-count = { $count ->
    [0] Nessun conto aperto
    [one] 1 conto aperto
   *[other] { $count } conti aperti
}
welcome-total-bank = Saldo in banca
welcome-total-real = Saldo reale
welcome-total-final = Saldo finale
welcome-total-real-detail = riconciliato + impegnato
welcome-total-final-detail = riconciliato + impegnato + previsto
welcome-accounts = I suoi conti
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Conti contati nei totali: { $count } su { $total }
welcome-tile-counted = Conta questo conto nei totali
welcome-tile-bank = In banca
welcome-tile-real = Reale
welcome-tile-final = Finale
welcome-spending = Spese — { $month }
welcome-earning = Guadagni — { $month }
ui-legend-budget-lines = Voci di bilancio
ui-legend-categories = Categorie
welcome-nothing = Nessuna operazione questo mese.
welcome-open-account = Info: clicchi su un conto per aprirne le operazioni.
welcome-no-account = Nessun conto bancario per ora.
welcome-no-account-create = Creare un conto bancario facendo clic qui
welcome-previous-month = Mese precedente
welcome-next-month = Mese successivo
welcome-refresh = Rileggere tutto


# --- F39 — le preferenze (fase 17 ter, 03/08/2026) ------------------------
#
# Il posto del segno monetario vive qui, accanto ai due separatori: segue la
# lingua e non la valuta. « before » mette il segno davanti al numero, qualsiasi
# altro valore lo mette dietro. NESSUN segno monetario è scritto in questo
# file: « italiano » non vuol dire « euro ».

ui-money-sign-position = after
window-preferences-title = Preferenze
menu-settings-preferences = Preferenze…
menu-settings-show-main = Mostrare la finestra principale
menu-settings-folders = Cartelle di Radinus
preferences-branch-display = Visualizzazione
preferences-leaf-language = Lingua
preferences-leaf-currency = Valuta
preferences-field-language = Lingua del software:
preferences-field-currency = Valuta visualizzata:
preferences-field-custom = Segno della valuta:
preferences-currency-system = Valuta di sistema
preferences-currency-euro = Euro
preferences-currency-dollar = Dollari
preferences-currency-canadian = Dollari canadesi
preferences-currency-cfa = Franchi CFA
preferences-currency-cfp = Franchi Pacifico
preferences-currency-swiss = Franchi svizzeri
preferences-currency-none = Nessuna
preferences-currency-custom = Personalizzato
preferences-currency-system-is = Il suo sistema annuncia:
preferences-currency-system-silent = Il suo sistema non annuncia alcuna valuta: gli importi saranno visualizzati in euro.
preferences-custom-required = Digiti il segno della sua valuta prima di salvare.
preferences-saved = Preferenze salvate.
preferences-help = Scelga un'opzione nell'albero, poi salvi.
preferences-sign-too-long = Il segno di una valuta occupa 8 caratteri al massimo.
preferences-sign-not-a-number = Il segno di una valuta non può contenere né cifre, né segni di calcolo, né virgole: Radinus li toglie quando legge un importo, e « 120 » diventerebbe « 12 ».
preferences-leaf-zoom = Dimensione della visualizzazione
preferences-field-zoom = Ingrandimento:
preferences-zoom-reset = Valore predefinito
preferences-zoom-hint = Tutto si ingrandisce insieme: il testo, le icone, le colonne. Al di sotto del 100 %, ne sta di più sullo schermo. La barra dei menu del sistema e le sue finestre di dialogo, invece, seguono le impostazioni del suo computer e non queste.
preferences-branch-import = Importazione
preferences-leaf-verification = Verifica
preferences-field-verification = Operazioni importate:
preferences-verification-hint = «Verificata»: vi fidate della vostra banca, un'operazione importata è considerata corretta. «Da verificare»: ogni operazione importata attende il vostro controllo; poi la portate voi stessi a «Verificata» nell'elenco delle operazioni. Questa impostazione vale solo per le importazioni future.
preferences-leaf-ofx = Estratti conto OFX
preferences-field-ofx-label = Descrizione dell'operazione:
preferences-field-ofx-reference = Riferimento pagamento:
preferences-ofx-choice-name = Il nome dell'operazione
preferences-ofx-choice-memo = Il memo della banca
preferences-ofx-choice-name-and-memo = Il nome seguito dal memo
preferences-ofx-choice-empty = Niente (lasciare vuoto)
preferences-ofx-label-help = Ciò che riceve la descrizione di un'operazione importata. Il nome è quello mostrato dalla banca, per esempio «PRLV SEPA»; alcune banche aggiungono un memo dettagliato: il creditore di un addebito diretto, il beneficiario e la causale di un bonifico. Quando un'operazione non ha memo, la sua descrizione mantiene il nome.
preferences-ofx-reference-help = Ciò che riceve il riferimento pagamento di un'operazione importata, dove potete vederlo e filtrarlo. Quando un'operazione non ha memo, «Il memo della banca» lascia vuoto il riferimento. Se il memo ripete già il nome, non viene scritto due volte.
preferences-ofx-hint = Queste impostazioni valgono per tutti gli estratti conto OFX, qualunque sia la base aperta. Si applicano al prossimo estratto conto aperto.
preferences-leaf-qif = Estratti conto QIF
preferences-field-qif-order = Ordine di giorno e mese:
preferences-qif-order-ask = Chiedermelo ogni volta
preferences-qif-order-day-month = Sempre giorno/mese (05/03 = 5 marzo)
preferences-qif-order-month-day = Sempre mese/giorno (05/03 = 3 maggio)
preferences-qif-order-help = Serve solo se nessuna data del file permette di decidere. Appena una data come 24/11 dimostra l'ordine, decide il file, qualunque sia questa impostazione.
preferences-field-qif-label = Descrizione dell'operazione:
preferences-qif-label-both = Terzo + memo
preferences-qif-label-payee = Solo terzo
preferences-qif-label-memo = Solo memo
preferences-qif-label-help = Quando un'operazione riporta sia un terzo sia un memo. Se ne riporta uno solo, si usa quello, qualunque sia questa impostazione.
preferences-qif-hint = Queste impostazioni valgono per tutti gli estratti conto QIF, qualunque sia la base aperta. «Chiedermelo ogni volta» è la scelta più sicura: un file con date ambigue non viene mai letto a caso.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Ripristina le colonne predefinite
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Mostra/Nascondi
columns-colour = Colora la colonna:
columns-colour-none = Nessun colore
columns-colour-red = Rosso
columns-colour-orange = Arancione
columns-colour-pink = Rosa
columns-colour-pastel-green = Verde pastello
columns-colour-green = Verde
columns-colour-pastel-blue = Blu pastello
columns-colour-blue = Blu
columns-colour-pastel-yellow = Giallo pastello
columns-colour-yellow = Giallo
preferences-leaf-columns = Colonne delle tabelle
preferences-table-operations-list = Elenco operazioni
preferences-columns-reset = Ripristina
preferences-columns-reset-all = Ripristina tutto
preferences-columns-done = Le colonne sono tornate alla disposizione originale.
preferences-columns-hint = Ogni tabella ricorda l'ordine delle sue colonne, quelle che nascondete e la loro larghezza. «Ripristina» le restituisce subito la disposizione originale.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Ripristino
preferences-leaf-comfort = Impostazioni di comodità
preferences-comfort-reset = Ripristina le impostazioni di comodità
preferences-comfort-hint = Riporta allo stato originale le colonne di tutte le tabelle, l'ordine e le caselle dei conti della finestra iniziale e la dimensione della visualizzazione. La lingua, la valuta e la verifica delle operazioni importate non vengono toccate.
preferences-comfort-question = Ripristinare le impostazioni di comodità? Le colonne delle tabelle, la finestra iniziale e la dimensione della visualizzazione torneranno allo stato originale.
preferences-comfort-done = Le impostazioni di comodità sono state ripristinate.

# --- Lo striscione della pagina di benvenuto ------------------------------
#
# Queste frasi erano scritte in modo fisso in `index.html` fin dalla fase 0 e
# quindi non si traducevano (rilevato da Fabrice il 03/08/2026). Il motto è la
# sua voce: le versioni inglese e spagnola sono proposte, da correggere da
# parte sua — uno slogan non si traduce parola per parola.
ui-language-tag = it
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — lo scoiattolo mascotte, in completo, circondato da un euro, una calcolatrice e dei grafici
welcome-slogan-one = Un software di gestione delle finanze personali che l'aiuta a spendere meno per guadagnare di più
welcome-slogan-two = Con Radinus capirà perché i piccoli ruscelli fanno i grandi fiumi.

# --- « A proposito dell'autore » ------------------------------------------
#
# Il nome e l'indirizzo sono scritti in modo identico nei tre file: non si
# traducono. Sono qui malgrado tutto, e non nella pagina, perché la vista non
# porti alcuna frase — e perché si correggano in un solo posto il giorno in cui
# l'autore trasloca.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = A proposito dell'autore
about-author-flag-alt = Bandiera della Corsica — la testa di moro

# --- « A proposito di Radinus » -------------------------------------------
#
# `about-radinus-version` porta un buco: il numero viene dal binario che gira,
# mai da una stringa ricopiata. Non è dunque nel dizionario delle finestre — è
# il comando `app_version` che la riempie.
window-about-radinus-title = A proposito di Radinus
about-radinus-name = Radinus
about-radinus-version = Versione { $version }
about-radinus-rust-alt = Il logo del linguaggio Rust
about-radinus-tauri-alt = Il logo di Tauri
about-radinus-built = Radinus è scritto in Rust e costruito con Tauri. Il primo calcola i suoi conti, il secondo ne fa un'applicazione da scrivania.
about-radinus-licence = Software libero, con licenza GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Licenza d'uso
licence-heading = LICENZA D'USO DEL SOFTWARE RADINUS
licence-logo-alt = Il logo della GNU General Public License versione 3
licence-name = GNU GPL v3 o successiva
licence-intro = Radinus è software libero.
licence-freedoms-title = La sua licenza vi dà quattro libertà:
licence-freedom-use = Usarlo come volete, per quello che volete.
licence-freedom-study = Studiarne il codice sorgente, aperto a tutti.
licence-freedom-share = Copiarlo e darlo a chi volete.
licence-freedom-improve = Modificarlo e condividere le vostre modifiche.
licence-read = Leggere il testo completo della licenza

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Questo programma è fornito senza alcuna garanzia, nei limiti consentiti dalla legge.
licence-info = Il testo ufficiale si apre nel vostro browser, su gnu.org.

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Simulazione di prestito
window-loan-title = Simulazione di prestito
loan-tab-credit = Il prestito
loan-tab-afford = Posso rimborsarlo?
loan-field-kind = Tipo di prestito
loan-kind-consumer = Credito al consumo
loan-kind-mortgage = Mutuo
loan-field-amount = Importo richiesto
loan-field-payment = Rata mensile
loan-field-months = Durata
loan-field-rate = Tasso fisso
loan-field-fees = Spese di istruttoria
loan-field-insurance = Assicurazione al mese
loan-unit-months = mesi
loan-unit-percent = %
loan-invalid-field = Questo valore non è un numero: correggetelo per rilanciare il calcolo.
loan-report-button = Rapporto PDF
loan-monthly-table = Tabella mese per mese
loan-months-count = { $count ->
        [one] { $count } mese
       *[other] { $count } mesi
    }
loan-percent = { $value }%
loan-notice-payment-too-low = Questa rata non copre gli interessi: il prestito non verrebbe mai rimborsato. La durata resta a 600 mesi.
loan-notice-too-long = Questa rata richiederebbe più di 600 mesi: la durata resta a 600 mesi.
loan-figure-payment = Rata mensile
loan-figure-payment-insured = Rata con assicurazione
loan-figure-taeg = TAEG
loan-figure-interest = Costo degli interessi
loan-figure-insurance = Costo dell'assicurazione
loan-figure-cost = Costo totale del prestito
loan-figure-total-due = Importo totale dovuto
loan-figure-all-in = Totale rimborsato, assicurazione inclusa
loan-part-capital = Importo richiesto
loan-part-interest = Interessi
loan-part-fees = Spese di istruttoria
loan-part-insurance = Assicurazione
loan-donut-cost-caption = in totale
loan-chart-cost = Quanto costa questo prestito
loan-chart-capital = Capitale residuo
loan-schedule-title = Piano di ammortamento
loan-schedule-yearly = Piano di ammortamento, anno per anno
loan-column-number = N.
loan-column-year = Anno
loan-column-date = Scadenza
loan-column-payment = Rata
loan-column-payments = Rate
loan-column-interest = Interessi
loan-column-capital = Capitale
loan-column-insurance = Assicurazione
loan-column-remaining = Capitale residuo
loan-history-label = Periodo esaminato
loan-period-last-12 = Ultimi 12 mesi
loan-accounts-title = Conti esaminati
loan-period-title = Periodo
loan-column-account = Conto
loan-column-bank = Banca
loan-column-balance = Saldo reale
loan-unavailable-no-account = Spuntate almeno un conto per esaminare la vostra cronologia.
loan-unavailable-no-month = Questo periodo non ha ancora nessun mese completo: sceglietene un altro.
loan-verdict-title = In breve
loan-verdict-green = Fattibile
loan-verdict-orange = Al limite
loan-verdict-red = Rischioso
loan-verdict-no-income = Nessuna entrata in questo periodo: l'indebitamento non si può calcolare.
loan-check-debt-green = Indebitamento del { $ratio }: sotto la soglia del { $green } di questo metodo.
loan-check-debt-orange = Indebitamento del { $ratio }: tra il { $green } e il { $red }, al limite.
loan-check-debt-red = Indebitamento del { $ratio }: oltre il { $red }.
loan-check-effort = La rata di { $payment } assorbe il { $share } di ciò che mettete da parte in { $kind ->
        [good] un mese buono
        [hard] un mese difficile
       *[usual] un mese normale
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Un mese buono
        [hard] Un mese difficile
       *[usual] Un mese normale
    } non vi lascia nulla da parte: la rata di { $payment } verrebbe presa dalla vostra riserva.
loan-check-reserve-green = Il vostro saldo resta positivo fino alla fine del prestito.
loan-check-reserve-red = Il vostro saldo scenderebbe sotto zero a { $month }, a causa di questo prestito.
loan-check-reserve-sooner = Il vostro saldo scenderebbe sotto zero a { $month }, { $count ->
        [one] un mese
       *[other] { $count } mesi
    } prima che senza questo prestito.
loan-check-reserve-anyway = Il vostro saldo scenderebbe sotto zero verso { $month } anche senza questo prestito, che non cambia quasi nulla.
loan-check-reserve-floor-green = Il vostro saldo resta sopra la riserva di sicurezza ({ $floor }) fino alla fine del prestito.
loan-check-reserve-floor-red = Il vostro saldo scenderebbe sotto la riserva di sicurezza ({ $floor }) a { $month }, a causa di questo prestito.
loan-check-reserve-floor-sooner = Il vostro saldo scenderebbe sotto la riserva di sicurezza ({ $floor }) a { $month }, { $count ->
        [one] un mese
       *[other] { $count } mesi
    } prima che senza questo prestito.
loan-check-reserve-floor-anyway = Il vostro saldo scenderebbe sotto la riserva di sicurezza ({ $floor }) verso { $month } anche senza questo prestito, che non cambia quasi nulla.
loan-warning-deficit = Attenzione: in questo periodo le vostre spese superano già le entrate di { $amount } al mese in media, prima di qualsiasi prestito.
loan-figure-reference = Risparmio di { $kind ->
        [good] un mese buono
        [hard] un mese difficile
       *[usual] un mese normale
    }
loan-figure-tipped = Mesi che il prestito manderebbe in rosso
loan-gauge-caption = di indebitamento
loan-figure-income = Entrate medie al mese
loan-figure-spending = Spese medie al mese
loan-figure-saving = Risparmio medio al mese
loan-figure-running = Prestiti in corso al mese
loan-figure-new = Nuova rata, assicurazione inclusa
loan-figure-rest = Per vivere al mese
loan-figure-debt = Tasso di indebitamento
loan-red-months-value = { $count } su { $total }
loan-figure-balance-now = Saldo reale oggi
loan-figure-balance-end = Saldo previsto a fine prestito
loan-chart-income = Dove va il vostro reddito medio
loan-donut-income-caption = reddito medio
loan-part-spending = Spese correnti
loan-part-running = Prestiti in corso
loan-part-new = Nuovo prestito
loan-part-rest = Resto
loan-part-missing = Mancano
loan-chart-history = La vostra cronologia con questo prestito
loan-chart-history-hint = Ciò che sarebbe rimasto ogni mese, pagata la rata. In rosso vivo, i mesi che il prestito manderebbe in rosso; in rosso pallido, quelli che lo erano già senza.
loan-chart-projection = Il vostro saldo previsto
loan-mark-loan-end = Fine: { $label }
loan-mark-negative = In rosso
loan-mark-floor = Sotto la riserva
loan-mark-floor-line = Riserva di sicurezza
loan-running-title = Prestiti in corso considerati
loan-running-column-label = Operazione periodica
loan-running-column-monthly = Al mese
loan-running-column-end = Ultima scadenza
loan-no-running = Nessun prestito in corso riconosciuto tra le vostre operazioni periodiche.
loan-period-caption = da { $from } a { $to } ({ $count ->
        [one] { $count } mese
       *[other] { $count } mesi
    })
loan-transfers = { $count ->
        [0] Nessun bonifico tra i vostri conti spuntati è stato riconosciuto.
        [one] Un bonifico tra i vostri conti spuntati è stato riconosciuto e messo da parte.
       *[other] { $count } bonifici tra i vostri conti spuntati sono stati riconosciuti e messi da parte.
    }
loan-method = Medie sui mesi completi del periodo, operazioni riconciliate e impegnate, senza i bonifici tra i vostri conti spuntati.
loan-report-title = Simulazione di prestito
loan-report-made-on = simulazione del { $date }
loan-disclaimer = Simulazione indicativa, senza valore contrattuale. Fa fede solo l'offerta della banca.
loan-tab-rules = Impostazioni del giudizio
loan-method-optimistic = Ottimista
loan-method-neutral = Neutro
loan-method-severe = Severo
loan-method-line = Metodo di giudizio: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = Il verdetto risponde a tre domande, e ogni metodo vi mette le proprie esigenze. Scegliete quello che vi somiglia: il verdetto della scheda «Posso rimborsarlo?» lo segue. L'ultima riga suppone che le vostre spese aumentino ogni anno della percentuale indicata; la rata, invece, non cambia.
loan-rule-row-debt = Indebitamento accettato
loan-rule-row-reference = Risparmio di riferimento
loan-rule-row-share = Parte di questo risparmio che la rata può prendere
loan-rule-row-floor = Soglia sotto cui il saldo non deve scendere
loan-rule-row-sooner = Se il saldo vi scende anche senza il prestito
loan-rule-row-growth = Aumento delle vostre spese all'anno
loan-rule-limits = verde fino al { $green }, arancione fino al { $red }
loan-rule-reference = { $kind ->
        [good] un mese buono
        [hard] un mese difficile
       *[usual] un mese normale
    }: { $amount }
loan-rule-floor-zero = zero
loan-rule-floor-cushion = un mese di spese: { $amount }
loan-rule-sooner = arancione se lo anticipa di { $orange }, rosso di { $red }
loan-unit-percent-year = % all'anno
loan-method-optimistic-explain = Il metodo ottimista suppone un mese buono, accetta un indebitamento fino al 40% e non tiene alcuna riserva: dice ciò che è possibile se tutto va bene.
loan-method-neutral-explain = Il metodo neutro suppone un mese normale e segue la regola delle banche, dal 33 al 35% di indebitamento: è il giudizio di riferimento.
loan-method-severe-explain = Il metodo severo suppone un mese difficile e tiene un mese di spese di riserva per un imprevisto: dice ciò che regge anche se le cose vanno male.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Consumo di un apparecchio elettrico
window-appliance-title = Consumo di un apparecchio elettrico
appliance-device-title = L'apparecchio
appliance-on-title = Acceso
appliance-standby-title = In standby
appliance-field-on-watts = Potenza in funzione
appliance-field-on-hours = Tempo di funzionamento al giorno
appliance-field-days = Giorni di utilizzo a settimana
appliance-field-share = Quota del funzionamento nelle ore fuori punta
appliance-field-standby-watts = Potenza in standby
appliance-field-standby-hours = Tempo in standby per giorno di utilizzo
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = su 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Se lasciato vuoto, lo standby dura il resto della giornata. Nei giorni senza utilizzo l'apparecchio resta collegato: tutto quel tempo conta come standby. Se scollegato, il suo standby è di 0 W.
appliance-contract-title = Il tuo contratto
appliance-field-option = Opzione tariffaria
appliance-option-base = Monoraria (prezzo unico)
appliance-option-off-peak = Ore di punta / fuori punta
appliance-field-base = Prezzo al kWh
appliance-field-peak = Prezzo al kWh nelle ore di punta
appliance-field-off-peak = Prezzo al kWh nelle ore fuori punta
appliance-field-off-peak-hours = Ore fuori punta al giorno
appliance-contract-hint = Questi prezzi valgono solo per questo calcolo. La tariffa salvata si imposta in Impostazioni › Preferenze › Strumenti.
appliance-contract-reset = Riprendi la tariffa salvata
appliance-period-day = Al giorno
appliance-period-month = Al mese
appliance-period-year = All'anno
appliance-energy = { $value } kWh
appliance-less-than = meno di { $amount }
appliance-detail-title = Il dettaglio su un anno
appliance-column-part = Voce
appliance-column-energy = Energia
appliance-column-cost = Costo
appliance-column-share = Quota
appliance-line-on = Acceso
appliance-line-standby = In standby
appliance-line-on-peak = Acceso, ore di punta
appliance-line-on-off-peak = Acceso, ore fuori punta
appliance-line-standby-peak = In standby, ore di punta
appliance-line-standby-off-peak = In standby, ore fuori punta
appliance-line-total = Totale
appliance-chart-title = Dove vanno i soldi
appliance-chart-caption = all'anno
appliance-standby-sentence = Il solo standby costa { $amount } all'anno: { $share } del costo dell'apparecchio.
appliance-note-plate = La potenza indicata sull'apparecchio o nel suo manuale è un valore massimo: in funzione, la maggior parte degli apparecchi consuma meno. Per un dato reale, misurala con una presa wattmetro e inserisci il valore che indica.
appliance-note-subscription = La quota fissa non è conteggiata: si paga che l'apparecchio sia collegato o no.
appliance-invalid-watts = Inserisci una potenza da 0 a 100.000 W.
appliance-invalid-hours = Inserisci una durata da 0 a 24 ore al giorno.
appliance-invalid-days = Inserisci un numero intero di giorni, da 0 a 7.
appliance-invalid-share = Inserisci una quota da 0 a 100%.
appliance-invalid-day-overflow = Funzionamento e standby superano le 24 ore al giorno.
appliance-invalid-price = Inserisci un prezzo al kWh da 0 a 100.
appliance-invalid-off-peak-hours = Inserisci un numero intero di ore fuori punta, da 0 a 24.
preferences-branch-tools = Strumenti
preferences-leaf-electricity = Tariffa elettrica
preferences-electricity-blue = Torna al Tarif Bleu EDF
preferences-electricity-hint = La tariffa del tuo contratto, usata dallo strumento «Consumo di un apparecchio elettrico». Predefinita: il Tarif Bleu di EDF (Francia) al 1° agosto 2026, prezzi tasse incluse, contatore da 3 a 6 kVA. Questi prezzi cambiano spesso a febbraio e ad agosto: ricopia quelli della tua bolletta.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Il mio fondo di emergenza
window-cushion-title = Il mio fondo di emergenza
cushion-question = Se le tue entrate si fermassero domani, per quanti mesi potresti andare avanti con i tuoi risparmi?
cushion-accounts-title = I tuoi conti
cushion-column-account = Conto
cushion-column-balance = Saldo reale
cushion-column-savings = Risparmi
cushion-column-spending = Spese
cushion-accounts-hint = «Risparmi»: il denaro su cui conti in caso di difficoltà. «Spese»: i conti da cui partono le spese quotidiane.
cushion-history-label = Periodo analizzato
cushion-backup-label = Reddito di riserva al mese
cushion-backup-hint = Ciò che continuerebbe ad arrivare: indennità di disoccupazione, stipendio del partner… Vuoto: nessun reddito.
cushion-categories-title = Le spese considerate
cushion-categories-hint = Deseleziona ciò che taglieresti in caso di difficoltà.
cushion-categories-empty = Nessuna spesa in questo periodo.
cushion-verdict-title = Il tuo fondo
cushion-targets-title = Le soglie di prudenza
cushion-projection-title = I tuoi risparmi in caso di difficoltà
cushion-projection-hint = Ciò che resterebbe ogni mese se le tue entrate si fermassero oggi.
cushion-note = Una stima ricavata dal tuo storico: le spese di un mese difficile possono differire dalla media.
cushion-invalid-backup = Questo importo non è leggibile: correggilo per rifare il calcolo.
cushion-no-spending-account = Seleziona almeno un conto «Spese».
cushion-no-month = Questo periodo non ha ancora nessun mese completo.
cushion-months = { $value } mesi
cushion-per-month = { $amount } al mese
cushion-figure-holds = Senza limite
cushion-gauge-caption = di spese coperte
cushion-verdict-short = Meno di tre mesi: un imprevisto ti metterebbe presto in difficoltà.
cushion-verdict-fair = Tra tre e sei mesi: un fondo discreto, da rafforzare se puoi.
cushion-verdict-solid = Sei mesi o più: il tuo fondo è solido.
cushion-verdict-holds = Il tuo reddito di riserva copre le tue spese: i tuoi risparmi non si ridurrebbero.
cushion-verdict-nothing = Nessuna spesa considerata nel periodo: non c'è nulla da coprire.
cushion-tile-savings = Risparmi disponibili
cushion-tile-spending = Spese considerate
cushion-tile-backup = Reddito di riserva
cushion-tile-burn = I risparmi calerebbero di
cushion-tile-rhythm = Ritmo di risparmio
cushion-burn-none = Nulla
cushion-target-title = { $months } mesi di spese: { $amount }
cushion-target-reached = Raggiunta.
cushion-target-date = Mancano { $missing }. Al tuo ritmo di risparmio, sarà raggiunta verso { $month }.
cushion-target-never = Mancano { $missing }. I tuoi risparmi non sono cresciuti nel periodo: a questo ritmo, questa soglia non sarà raggiunta.
cushion-mark-empty = A secco: { $month }
cushion-period = Media di { $count ->
        [one] { $count } mese completo
       *[other] { $count } mesi completi
    }, da { $from } a { $to }. { $transfers ->
        [0] Nessun trasferimento tra i tuoi conti.
        [one] Un trasferimento tra i tuoi conti, escluso dal calcolo.
       *[other] { $transfers } trasferimenti tra i tuoi conti, esclusi dal calcolo.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Obiettivo di risparmio
window-goal-title = Obiettivo di risparmio
goal-accounts-title = I conti seguiti
goal-column-account = Conto
goal-column-balance = Saldo reale
goal-accounts-hint = Un trasferimento tra due conti seguiti si annulla; un trasferimento verso un conto non seguito conta come un'uscita.
goal-period-label = Periodo di riferimento
goal-period-range = Intervallo di anni…
goal-range-from = da
goal-range-to = a
goal-question-title = La tua domanda
goal-question-when = Quando avrò questo importo?
goal-question-amount = Quanto avrò a questa data?
goal-question-effort = Quanto risparmiare per avere questo importo a questa data?
goal-field-target = Importo obiettivo
goal-field-date = Data obiettivo
goal-field-rate = Tasso annuo del risparmio
goal-field-extra = E se risparmiassi di più, al mese
goal-options-hint = Vuoti: nessun interesse, niente di più.
goal-answer-title = La risposta
goal-chart-title = Il tuo saldo, ieri e domani
goal-chart-hint = Linea continua: il saldo reale degli ultimi dodici mesi; linea tratteggiata: la proiezione; area chiara: la forbice a seconda dei mesi.
goal-disclaimer = Una proiezione ricavata dal tuo storico, non una promessa: un imprevisto può cambiare tutto.
goal-no-account = Seleziona almeno un conto da seguire.
goal-no-month = Questo periodo non ha ancora nessun mese completo.
goal-invalid-target = Inserisci un importo da raggiungere, per favore.
goal-invalid-date = Scegli una data futura, entro i prossimi cinquant'anni, per favore.
goal-invalid-rate = Inserisci un tasso da 0 a 100%, per favore.
goal-invalid-extra = Questo importo non è leggibile: correggilo per rifare il calcolo.
goal-per-month = { $amount } al mese
goal-tile-balance = Saldo oggi
goal-tile-rhythm = Ritmo medio
goal-tile-target = Obiettivo
goal-tile-reached = Raggiunto verso
goal-tile-date = Data obiettivo
goal-tile-projected = Saldo previsto
goal-tile-saved = Risparmiato fino ad allora
goal-tile-interest = Di cui interessi
goal-tile-needed = Da risparmiare
goal-when-already = Hai già { $amount }: i tuoi conti seguiti ammontano a { $balance }.
goal-when-reached = Avrai { $amount } verso { $month }, tra { $months ->
        [one] un mese
       *[other] { $months } mesi
    }.
goal-when-range = A seconda dei mesi, tra { $early } e { $late }.
goal-when-range-open = Al più presto verso { $early }; con mesi deboli, l'obiettivo non verrebbe raggiunto.
goal-when-never = A questo ritmo, non raggiungerai { $amount }.
goal-zero = Il tuo saldo scenderebbe a zero verso { $month }.
goal-amount = A { $month }, avresti circa { $amount }.
goal-amount-range = A seconda dei mesi, tra { $low } e { $high }.
goal-effort-more = Per avere { $amount } a { $month }, dovresti risparmiare in media { $monthly } al mese, cioè { $gap } in più di oggi.
goal-effort-less = Per avere { $amount } a { $month }, basterebbero { $monthly } al mese, cioè { $gap } in meno di oggi: sei in anticipo.
goal-effort-range = A seconda dei mesi, la differenza rispetto al tuo ritmo andrebbe da { $low } a { $high } al mese.
goal-chart-target = Obiettivo: { $amount }
goal-chart-today = Oggi
goal-note-seasons = La proiezione segue le stagioni: ogni mese futuro riprende la media degli stessi mesi del periodo.
goal-note-range = La forbice viene dai mesi deboli e dai mesi forti del periodo: il quarto più basso e il quarto più alto.
goal-note-loan = Il prestito «{ $label }» termina a { $month }: poi { $amount } in più al mese.
goal-note-interest = Interessi calcolati ogni mese al tasso del { $rate }% annuo: un'approssimazione del calcolo a quindicine dei libretti di risparmio.
goal-period = Ritmo calcolato su { $count ->
        [one] { $count } mese completo
       *[other] { $count } mesi completi
    }, da { $from } a { $to }. { $transfers ->
        [0] Nessun trasferimento tra i tuoi conti seguiti.
        [one] Un trasferimento tra i tuoi conti seguiti, neutralizzato.
       *[other] { $transfers } trasferimenti tra i tuoi conti seguiti, neutralizzati.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = E se riducessi…?
window-cut-title = E se riducessi…?
cut-axis-label = Raggruppa per
cut-axis-category = Categorie
cut-axis-payee = Terzi
cut-axis-budget-line = Voci di bilancio
cut-table-title = Le tue spese, voce per voce
cut-table-hint = Inserisci una riduzione in % o in { $sign } al mese sulle voci che vorresti alleggerire. Una riduzione non può superare la spesa stessa.
cut-column-monthly = Al mese
cut-column-cut = Riduzione
cut-column-after = Dopo
cut-column-yearly = Guadagno all'anno
cut-total = Totale
cut-horizon-label = Orizzonte
cut-settings-title = Impostazioni
cut-options-hint = Il tasso e l'importo obiettivo sono facoltativi.
cut-report-button = Rapporto PDF
cut-chart-title = Il tuo saldo, senza e con le riduzioni
cut-chart-hint = Linea continua: il saldo reale degli ultimi dodici mesi; tratteggio grigio: la proiezione senza riduzioni; in blu: con le riduzioni; in verde: il denaro guadagnato.
cut-donut-title = Le tue spese mensili dopo le riduzioni
cut-donut-caption = al mese dopo le riduzioni
cut-donut-others = Altre voci
cut-donut-saved = Risparmiato
cut-legend-with = Con le riduzioni
cut-legend-without = Senza riduzioni
cut-years = { $years ->
        [one] { $years } anno
       *[other] { $years } anni
    }
cut-headline-none = Inserisci una riduzione nella tabella per vederne l'effetto.
cut-headline = Riducendo { $count ->
        [one] questa voce
       *[other] queste { $count } voci
    }, metteresti da parte { $monthly } in più al mese, cioè { $yearly } all'anno.
cut-tile-monthly = Guadagno al mese
cut-tile-yearly = Guadagno all'anno
cut-tile-horizon = Guadagno su { $years ->
        [one] { $years } anno
       *[other] { $years } anni
    }
cut-tile-spending = Spese al mese
cut-target-already = Hai già { $amount }.
cut-target-sooner = Raggiungeresti { $amount } verso { $with } invece che verso { $without }: { $months ->
        [0] non prima
        [one] un mese prima
       *[other] { $months } mesi prima
    }.
cut-target-only-with = Con queste riduzioni, raggiungeresti { $amount } verso { $with }; senza, al tuo ritmo attuale, mai.
cut-target-never = Anche con queste riduzioni, non raggiungeresti { $amount } al tuo ritmo attuale.
cut-note-seasons = Ogni riduzione segue le stagioni della sua voce: una voce che pesa soprattutto d'estate fa risparmiare soprattutto d'estate.
cut-note-capped = Una riduzione inserita superava la spesa: è stata riportata alla spesa stessa.
cut-invalid-cut = Questa riduzione non è leggibile: una percentuale da 0 a 100, o un importo al mese.
cut-report-settings = Le impostazioni
cut-report-result = Il risultato
cut-report-accounts = Conti seguiti

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Preparare le vacanze
window-holiday-title = Preparare le vacanze
holiday-trip-title = Il viaggio
holiday-field-trip = Tipo di viaggio
holiday-trip-stay = Soggiorno
holiday-trip-cruise = Crociera
holiday-field-adults = Adulti
holiday-field-children = Bambini
holiday-field-nights = Durata del soggiorno, in notti
holiday-field-days = Giorni
holiday-field-months = Mesi prima della partenza
holiday-field-stops = Numero di scali
holiday-saved-title = Già risparmiato
holiday-saved-hint = Spunta i conti in cui il denaro delle vacanze è già messo da parte: il loro saldo reale conta come già risparmiato.
holiday-budget-title = Il budget
holiday-budget-hint = Per ogni voce, un importo, a chi si applica e per quanto tempo. Una voce vuota non conta.
holiday-optional-title = Righe facoltative
holiday-result-title = Il risultato
holiday-donut-title = Dove vanno i soldi del viaggio
holiday-donut-caption = per il viaggio
holiday-child-label = Prezzo bambino
holiday-count-label = Cabine
holiday-open = Apri un progetto…
holiday-save = Salva il progetto…
holiday-pdf = Rapporto PDF
holiday-excel = Esporta in Excel
holiday-file-filter = Progetto vacanze
holiday-replace-question = Aprire questo progetto sostituirà ciò che è inserito nella finestra. Continuare?
holiday-file-saved = Progetto salvato: { $file }
holiday-file-opened = Progetto aperto: { $file }
holiday-file-not-project = Questo file non è un progetto vacanze di Radinus.
holiday-file-too-recent = Questo progetto proviene da una versione più recente di Radinus: aggiorna Radinus per aprirlo.
holiday-file-failed = Impossibile leggere o scrivere il file: { $reason }
holiday-line-transport = Trasporto andata e ritorno
holiday-line-lodging = Alloggio
holiday-line-meals = Pasti e spese quotidiane
holiday-line-visits = Visite e svago
holiday-line-port = Trasferimento al porto
holiday-line-cabins = Cabine
holiday-line-service = Quota di servizio (mance)
holiday-line-drinks = Pacchetto bevande
holiday-line-excursions = Escursioni agli scali
holiday-line-port-taxes = Tasse portuali
holiday-line-wifi = Wi-Fi a bordo
holiday-line-onboard = Spese a bordo e agli scali
holiday-line-other = Altre spese e imprevisti
holiday-line-insurance = Assicurazione annullamento
holiday-line-stay-tax = Tassa di soggiorno
holiday-line-car = Auto sul posto, carburante e pedaggi
holiday-line-parking = Parcheggio dell'aeroporto o della stazione
holiday-line-bank = Commissioni bancarie all'estero
holiday-line-formalities = Formalità (passaporto, visto, vaccini)
holiday-line-pets = Custodia degli animali
holiday-span-trip = per il soggiorno
holiday-span-night = a notte
holiday-span-day = al giorno
holiday-span-stop = per scalo
holiday-who-all = per tutti
holiday-who-person = a persona
holiday-who-adults = per adulto
holiday-cabins-count = { $count ->
        [one] { $count } cabina
       *[other] { $count } cabine
    }
holiday-days = { $days ->
        [one] { $days } giorno
       *[other] { $days } giorni
    }
holiday-invalid-count = Un numero intero, per favore.
holiday-invalid-amount = Questo importo non è leggibile: un numero positivo, o una percentuale da 0 a 100.
holiday-headline-empty = Inserisci gli importi del budget per vedere quanto costerà il viaggio.
holiday-headline-stay = Questo soggiorno costerebbe { $total } per { $people ->
        [one] una persona
       *[other] { $people } persone
    } e { $nights ->
        [0] nessuna notte
        [one] una notte
       *[other] { $nights } notti
    }.
holiday-headline-cruise = Questa crociera costerebbe { $total } per { $people ->
        [one] una persona
       *[other] { $people } persone
    } e { $nights ->
        [0] nessuna notte
        [one] una notte
       *[other] { $nights } notti
    }.
holiday-tile-total = Costo totale
holiday-tile-person = A persona
holiday-tile-person-day = A persona al giorno
holiday-tile-saved = Già risparmiato
holiday-tile-remaining = Ancora da finanziare
holiday-tile-monthly = Risparmio necessario
holiday-remaining-none = Niente: è coperto
holiday-monthly-none = Niente da mettere da parte
holiday-monthly-now = Partenza questo mese
holiday-note-days = I giorni sono le notti più uno: sette notti fanno otto giorni.
holiday-note-child = A persona, un bambino paga il prezzo bambino se indicato; se vuoto, paga come un adulto.
holiday-note-percent = Una percentuale di assicurazione si applica alle voci principali del viaggio; quella delle commissioni bancarie, alle spese fatte sul posto.
holiday-sheet-budget = Budget
holiday-sheet-result = Risultato
holiday-column-line = Voce
holiday-column-amount = Importo
holiday-column-child = Prezzo bambino
holiday-column-who = Per chi
holiday-column-span = Per quanto tempo
holiday-column-cost = Costo
holiday-disclaimer = Una stima basata sui tuoi importi: i prezzi reali possono variare.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Progetto di riduzione
cut-file-not-project = Questo file non è un progetto di riduzione di Radinus.
cut-file-too-recent = Questo progetto proviene da una versione più recente di Radinus: aggiorna Radinus per aprirlo.
cut-sheet-items = Voci

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Il diario della mia auto
window-car-title = Il diario della mia auto
car-unnamed = La mia auto
car-sheet-title = L'auto
car-field-plate = Targa
car-field-make = Marca
car-field-model = Modello
car-field-engine = Alimentazione
car-field-first-hand = Primo proprietario
car-field-registered = Prima immatricolazione
car-field-acquired = Data di acquisto
car-field-acquired-km = Chilometraggio all'acquisto
car-field-service = Tagliando ogni
car-field-service-or = o ogni
car-unit-months-short = mesi
car-unit-km = km
car-tariff-title = Tariffa della ricarica a casa
car-tariff-hint = Questa tariffa è conservata nel diario dell'auto: non cambia quella delle preferenze.
car-tariff-reset = Riprendi la tariffa delle preferenze
car-engine-petrol = Benzina
car-engine-diesel = Diesel
car-engine-lpg = GPL
car-engine-e85 = E85 (bioetanolo)
car-engine-hybrid = Ibrida
car-engine-plug-in = Ibrida plug-in
car-engine-electric = Elettrica
car-engine-hydrogen = Idrogeno
car-energy-petrol = Benzina
car-energy-diesel = Gasolio
car-energy-lpg = GPL
car-energy-e85 = E85
car-energy-electricity = Elettricità
car-energy-hydrogen = Idrogeno
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energia
car-rubric-upkeep = Manutenzione ordinaria
car-rubric-service = Tagliando
car-rubric-wear = Parti soggette a usura
car-rubric-tyres = Pneumatici
car-rubric-breakdown = Guasti
car-rubric-insurance = Assicurazione
car-rubric-inspection = Revisione
car-part-brake-pads = Pastiglie dei freni
car-part-brake-discs = Dischi dei freni
car-part-timing-belt = Cinghia di distribuzione
car-part-clutch = Frizione
car-part-battery-12v = Batteria 12 V
car-part-shock-absorbers = Ammortizzatori
car-part-wipers = Spazzole tergicristallo
car-part-spark-plugs = Candele di accensione
car-part-glow-plugs = Candelette di preriscaldamento
car-part-particulate-filter = Filtro antiparticolato
car-part-catalytic-converter = Marmitta catalitica
car-part-fuel-cell-filter = Filtro della cella a combustibile
car-part-exhaust = Scarico
car-part-other = Altro ricambio…
car-axle-all = Tutti e quattro gli pneumatici
car-axle-front = Pneumatici anteriori
car-axle-rear = Pneumatici posteriori
car-verdict-pass = Regolare
car-verdict-counter = Da ripetere
car-charge-station = A una colonnina
car-charge-home = A casa
car-slot-peak = Ore di punta
car-slot-off-peak = Ore fuori punta
car-entry-new = Nuova riga
car-entry-edit = Modifica la riga
car-field-date = Data
car-field-km = Contachilometri
car-field-rubric = Categoria
car-field-amount = Importo
car-field-garage = Officina o stazione
car-field-note = Nota
car-field-energy = Energia
car-field-quantity = Quantità
car-field-charge = Ricarica
car-field-slot = Orario di ricarica
car-field-part = Ricambio
car-field-part-name = Nome del ricambio
car-field-axle = Pneumatici sostituiti
car-field-verdict = Esito
car-field-months = Mesi coperti
car-field-battery = Stato della batteria
car-home-amount-hint = L'importo di una ricarica a casa si calcola con la tariffa dell'auto.
car-entry-add = Aggiungi al diario
car-entry-update = Salva la riga
car-entry-cancel = Annulla
car-entry-delete = Elimina la riga
car-delete-question = Eliminare questa riga dal diario?
car-from-operation = Riprendi un'operazione…
car-pick-account = Da quale conto viene la spesa?
car-pick-operation = Quale operazione?
car-pick-take = Riprendi
car-pick-none = Nessuna spesa in questo conto.
car-pick-taken = Operazione ripresa: completa il contachilometri e la categoria, poi aggiungi la riga.
car-history-title = Lo storico
car-filter-all = Tutte le categorie
car-history-empty = Ancora nessuna riga.
car-history-hint = Fai clic su una riga per modificarla.
car-column-date = Data
car-column-km = Km
car-column-rubric = Categoria
car-column-detail = Dettaglio
car-column-amount = Importo
car-column-garage = Officina
car-column-note = Nota
car-column-share = Quota
car-column-per-km = Al km
car-column-energy = Energia
car-column-quantity = Quantità
car-column-price = Prezzo medio
car-column-consumption = Consumo
car-column-part = Ricambio
car-column-changes = Sostituzioni
car-column-last = Ultima sostituzione
car-column-life = Durata
car-column-next = Prossima sostituzione
car-total = Totale
car-summary-title = Quanto costa l'auto
car-headline-empty = Compila la scheda, poi aggiungi una prima riga: un pieno, un tagliando, una fattura dell'officina…
car-headline = Dal { $since }, la tua auto ti è costata { $total }.
car-headline-km = Dal { $since }, la tua auto ti è costata { $total } per { $km } percorsi: { $cost } al chilometro.
car-tile-total = Costo totale
car-tile-month = Al mese
car-tile-km = Al chilometro
car-tile-driven = Chilometri percorsi
car-tile-consumption = Consumo
car-tile-energy-km = Energia al chilometro
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } mese
       *[other] { $months } mesi
    }
car-detail-battery = Batteria: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Per categoria
car-energy-title = L'energia
car-parts-title = Parti soggette a usura
car-tyres-title = Pneumatici
car-battery-title = Stato della batteria
car-years-title = Quanto è costata l'auto ogni anno
car-donut-title = Dove vanno i soldi
car-donut-caption = in tutto
car-deadlines-title = Le scadenze
car-deadlines-empty = Ancora nessuna scadenza: annota un tagliando, una revisione, un'assicurazione o due sostituzioni dello stesso ricambio.
car-deadline-service = Tagliando
car-deadline-inspection = Revisione
car-deadline-counter = Revisione da ripetere
car-deadline-insurance = Scadenza dell'assicurazione
car-when-date = il { $date }
car-when-km = a { $km }
car-when-km-reached = a { $km }, verso { $month } al tuo ritmo
car-when-date-km = il { $date } o a { $km }, alla prima delle due scadenze
car-when-inspection-unknown = Annota l'ultima revisione per conoscere la data della prossima.
car-tone-late = Scaduta
car-tone-soon = A breve
car-note-since = Tutto si conta dall'acquisto: la data e il contachilometri annotati sulla scheda.
car-note-consumption = Il consumo si misura da pieno a pieno: fai sempre il pieno completo e annota ogni volta il contachilometri.
car-note-e85 = Un'auto E85 beve ciò che le si dà: i chilometri che seguono un pieno contano per quel carburante.
car-note-home = Una ricarica a casa viene calcolata con la tariffa dell'auto del giorno in cui è annotata, e mantiene quel costo.
car-note-inspection = La revisione segue la regola francese: la prima entro quattro anni dalla prima immatricolazione, poi ogni due anni; una revisione da ripetere, entro due mesi.
car-disclaimer = Le scadenze e le durate sono stime ricavate dal diario: fa fede solo il libretto di manutenzione del costruttore.
car-invalid-date = Una data valida, che non sia nel futuro, per favore.
car-invalid-acquired = La data di acquisto non può precedere la prima immatricolazione.
car-invalid-km = Un contachilometri in chilometri interi, per favore.
car-invalid-amount = Questo importo non è leggibile.
car-invalid-quantity = Inserisci la quantità: litri, kWh o chili.
car-invalid-part = Scegli il ricambio sostituito, o scrivi il suo nome.
car-invalid-rubric = Scegli una categoria.
car-invalid-months = Un numero intero di mesi, per favore.
car-invalid-battery = Uno stato della batteria da 0 a 100 %, per favore.
car-open = Apri un diario…
car-save = Salva il diario…
car-report-button = Rapporto PDF
car-file-filter = Diario dell'auto
car-file-saved = Diario salvato: { $file }
car-file-opened = Diario aperto: { $file }
car-file-not-logbook = Questo file non è un diario dell'auto di Radinus.
car-file-too-recent = Questo diario proviene da una versione più recente di Radinus: aggiorna Radinus per aprirlo.
car-replace-question = Aprire questo diario sostituirà quello della finestra. Continuare?
car-sheet-history = Diario
car-sheet-summary = Sintesi

analysis-history-hint = Più lungo è lo storico, migliore sarà questa analisi: l'ideale è avere almeno un anno di operazioni.

# --- F48 — Dividere una spesa (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Dividere una spesa
window-sharing-title = Dividere una spesa
sharing-question = Chi paga cosa?
sharing-setup-title = La divisione
sharing-field-label = Nome
sharing-label-hint = Per esempio «Ristorante del 12/10» o «Viaggio in Bretagna 2027»: dà il nome ai file e ai rapporti.
sharing-field-total = Totale
sharing-total-hint = Se lasciato vuoto, il totale è la somma delle voci e degli extra di ciascuno.
sharing-field-rule = Regola
sharing-field-rounding = Arrotondamento
sharing-field-people = Persone
sharing-mode-whole = Una regola per tutta la spesa
sharing-mode-item = Una regola per voce
sharing-rule-equal = Quote uguali
sharing-rule-parts = A parti
sharing-rule-percent = In percentuale
sharing-rule-income = In proporzione al reddito
sharing-rounding-cent = Al centesimo
sharing-rounding-euro = All'unità intera
sharing-round-euro = Arrotonda a unità intere
sharing-hide-incomes = Nascondi i redditi nei rapporti e nell'esportazione
sharing-people-title = Le persone
sharing-people-hint = Una riga per persona, una colonna per voce: spunta chi partecipa a cosa. Tutto il resto è facoltativo. Chi si ritira lasciando la caparra: un importo esatto pari a quanto ha versato e nessuna casella spuntata.
sharing-add-person = Aggiungi una persona
sharing-person-default = Persona { $number }
sharing-items-title = Le voci
sharing-items-hint = Solo ciò che non riguarda tutti, come il vino. Il resto del totale va nella voce comune.
sharing-add-item = Aggiungi una voce
sharing-common = Comune
sharing-payments-title = I pagamenti
sharing-payments-hint = Chi ha pagato, quanto e quando. Una riga senza importo non conta ancora.
sharing-payments-none = Nessun pagamento per ora.
sharing-add-payment = Aggiungi un pagamento
sharing-result-title = Il risultato
sharing-balances-title = A che punto sono i pagamenti
sharing-transfers-title = Bonifici proposti
sharing-delete = Elimina
sharing-delete-person-question = Questa persona ha dei pagamenti: eliminarli insieme a lei?
sharing-disclaimer = Radinus propone una divisione: tra amici, ciascuno resta libero di accordarsi diversamente.
sharing-column-person = Persona
sharing-column-household = Nucleo familiare
sharing-column-income = Reddito
sharing-column-parts = Parti
sharing-column-percent = %
sharing-column-floor = Almeno
sharing-column-cap = Al massimo
sharing-column-fixed = Importo esatto
sharing-column-alone = I suoi extra
sharing-column-gift = Eccedenza offerta
sharing-column-share = Quota
sharing-column-typed = % digitata
sharing-column-constraint = Cosa ha influito
sharing-column-due = Da pagare
sharing-column-item = Voce
sharing-column-amount = Importo
sharing-column-rule = Regola
sharing-column-participants = Partecipanti
sharing-column-unit = Nucleo familiare o persona
sharing-column-members = Membri
sharing-column-paid = Pagato
sharing-column-balance = Saldo
sharing-column-date = Data
sharing-column-who = Chi
sharing-column-label = Nome
sharing-help-household = Le persone dello stesso nucleo familiare saldano insieme: i loro pagamenti e ciò che devono si sommano, e ricevono un solo estratto. Esempio: «Famiglia Martin» per i genitori e i figli.
sharing-help-income = Serve solo alla regola «In proporzione al reddito»: più alto è il reddito, più grande è la quota. Digita il reddito mensile.
sharing-help-parts = Una persona con 2 parti paga il doppio di una persona con 1 parte. Esempio: adulto 1, bambino 0,5.
sharing-help-percent = La quota della spesa che paga la persona. Le percentuali devono fare 100 % in totale.
sharing-help-floor = La persona pagherà almeno questo importo, anche se la sua quota calcolata è più piccola. La differenza alleggerisce gli altri.
sharing-help-cap = La persona non pagherà mai più di questo importo. Ciò che non paga ricade sugli altri partecipanti delle sue voci.
sharing-help-fixed = La persona paga questo importo, qualunque cosa accada, e il resto si divide tra gli altri. Esempio: chi si ritira e lascia la caparra.
sharing-help-alone = Ciò che la persona ha preso solo per sé, come un dolce o un caffè. Lo paga per intero, in aggiunta alla sua quota.
sharing-help-gift = Se la persona ha versato più della sua quota: spuntato, l'eccedenza è un regalo al gruppo; non spuntato, le viene restituita.
sharing-help-items = Spunta le persone che partecipano a questa voce. La voce Comune è ciò che resta del totale una volta tolte le altre voci.
sharing-help-due = Ciò che la persona deve in tutto: la sua quota delle voci, i suoi extra e l'arrotondamento.
sharing-help-share = Ciò che rappresenta la sua quota, in percentuale della somma divisa.
sharing-help-typed = La percentuale che hai digitato. Può differire dalla quota reale quando ha influito un minimo, un massimo o un importo esatto.
sharing-help-constraint = Indica se la quota della persona è stata modificata da un minimo, un massimo, un importo esatto o un'eccedenza offerta.
sharing-help-item = Solo ciò che non riguarda tutti, come il vino. Il resto del totale va nella voce Comune, diviso tra chi vi è spuntato.
sharing-help-rule = Come si divide questa voce: in quote uguali, a parti, in percentuale o in proporzione al reddito.
sharing-help-paid = Ciò che il nucleo familiare o la persona ha già versato, in base ai pagamenti inseriti.
sharing-help-balance = Ciò che resta da pagare, o ciò che è stato versato in più rispetto alla quota. Esempio: «Resta da pagare: 61,54 €».
sharing-advice-equal = { $count ->
        [one] { $total } per una sola persona.
       *[other] { $total } ÷ { $count } persone = { $amount } a testa.
    }
sharing-advice-equal-varied = In quote uguali tra chi partecipa, tenendo conto dei limiti e delle esclusioni.
sharing-advice-parts = { $parts } parti in totale: una parte vale { $amount }.
sharing-advice-parts-varied = Ciascuno paga in base alle sue parti, tenendo conto dei limiti e delle esclusioni. Una casella vuota conta come 1 parte.
sharing-advice-percent-rest = Manca il { $rest } % per arrivare al 100 %.
sharing-advice-percent-over = Le percentuali superano il 100 % di { $over } %.
sharing-advice-percent-ok = Le percentuali fanno esattamente 100 %.
sharing-advice-percent-nobody = Le percentuali fanno già 100 %: { $names } non { $count ->
        [one] pagherebbe
       *[other] pagherebbero
    } nulla.
sharing-advice-income = Ciascuno paga il { $rate } % del suo reddito.
sharing-advice-income-missing = Digita il reddito di ciascuno per dividere in proporzione ai redditi.
sharing-advice-income-varied = Ciascuno paga la stessa proporzione del suo reddito, tenendo conto dei limiti e delle esclusioni.
sharing-advice-empty = Digita l'importo da dividere.
sharing-apply-advice = Usa i valori consigliati
sharing-help-apply-advice = Riempie le caselle vuote con i valori in grigio. Le caselle già compilate non cambiano.
sharing-from-incomes = Percentuali in base ai redditi
sharing-help-from-incomes = Sostituisce le percentuali con la quota di ciascun reddito sul totale dei redditi. Fanno 100 %.
sharing-reset-percents = Ridividi tutto
sharing-help-reset-percents = Cancella le percentuali e le divide in parti uguali tra tutti. Utile dopo aver aggiunto una persona.
sharing-reset-percents-question = Cancellare tutte le percentuali e dividerle in parti uguali?
sharing-open = Apri un progetto…
sharing-save = Salva il progetto…
sharing-pdf-distribution = Ripartizione (PDF)
sharing-pdf-payments = Stato dei pagamenti (PDF)
sharing-pdf-statements = Estratti individuali (PDF)…
sharing-statements-everyone = Tutti
sharing-excel = Esporta in Excel
sharing-file-filter = Progetto di divisione
sharing-replace-question = Aprire questo progetto sostituirà ciò che è inserito nella finestra. Continuare?
sharing-file-saved = Progetto salvato: { $file }
sharing-file-opened = Progetto aperto: { $file }
sharing-file-not-project = Questo file non è un progetto di divisione di Radinus.
sharing-file-too-recent = Questo progetto proviene da una versione più recente di Radinus: aggiorna Radinus per aprirlo.
sharing-file-failed = Impossibile leggere o scrivere il file: { $reason }
sharing-statements-replace-question = { $count ->
        [one] In questa cartella esiste già un estratto. Sostituirlo?
       *[other] In questa cartella esistono già { $count } estratti. Sostituirli?
    }
sharing-statements-written = { $count ->
        [one] Un estratto scritto in «{ $folder }».
       *[other] { $count } estratti scritti in «{ $folder }».
    }
sharing-too-many-people = Una divisione comprende al massimo 40 persone.
sharing-too-many-items = Una divisione comprende al massimo 20 voci.
sharing-too-many-payments = Una divisione comprende al massimo 400 pagamenti.
sharing-invalid-amount = Questo importo non è leggibile: serve un numero positivo.
sharing-invalid-number = Questo numero non è leggibile: serve un numero positivo.
sharing-invalid-percent = Una percentuale va da 0 a 100.
sharing-invalid-date = Questa data non è leggibile.
sharing-name-missing = Ogni persona deve avere un nome.
sharing-name-duplicate = Esiste già «{ $name }»: distinguile, per esempio con un'iniziale.
sharing-floor-above-cap = Il minimo supera il massimo.
sharing-item-label-missing = Questa voce non ha un nome.
sharing-items-above-total = Le voci e gli extra di ciascuno superano il totale di { $amount }.
sharing-payment-person = Scegli chi ha pagato.
sharing-percent-total = Le percentuali fanno { $sum } %: devono fare 100 %.
sharing-percent-total-item = «{ $item }»: le percentuali fanno { $sum } %: devono fare 100 %.
sharing-item-nobody = Nessuno partecipa a «{ $item }».
sharing-item-no-weight = Nessuno pesa su «{ $item }»: tutti i suoi partecipanti sono a zero.
sharing-income-missing = Manca il reddito di { $name }.
sharing-fixed-above = Gli importi esatti superano la somma da dividere di { $amount }.
sharing-floors-above = I minimi superano la somma da dividere di { $amount }.
sharing-cap-alone = Solo { $name } partecipa a «{ $item }»: il suo massimo non può essere rispettato.
sharing-caps-short = I massimi non bastano a coprire la somma: mancano { $amount }.
sharing-impossible = Queste condizioni non possono essere rispettate tutte: allenta un minimo o un massimo.
sharing-constraint-floor = Minimo raggiunto
sharing-constraint-cap = Massimo raggiunto
sharing-constraint-fixed = Importo esatto
sharing-constraint-gift = Eccedenza offerta
sharing-and = { $first } e { $last }
sharing-outside = Fuori dalle voci
sharing-alone = I suoi extra
sharing-rounding = Arrotondamento
sharing-headline-empty = Aggiungi le persone che dividono la spesa.
sharing-headline-no-amount = Digita il totale, o le voci da dividere.
sharing-headline-equal = { $total } da dividere: ciascuno paga { $amount }.
sharing-headline-range = { $total } da dividere: da { $min } a { $max } a seconda della persona.
sharing-participants = { $count ->
        [0] Nessun partecipante
        [one] Un partecipante
       *[other] { $count } partecipanti
    }
sharing-balance-due = Resta da pagare: { $amount }
sharing-balance-over = Ha versato { $amount } in più della sua quota
sharing-balance-even = In pari
sharing-summary-collected = { $collected } pagati su { $total }.
sharing-summary-owing = { $count ->
        [0] Tutti sono in pari.
        [one] Solo una persona deve ancora { $amount }.
       *[other] { $count } persone devono ancora { $amount } in totale.
    }
sharing-remaining-outside = Resta da pagare sulla spesa: { $amount }
sharing-remaining-reimburse = Da rimborsare a { $name }: { $amount }
sharing-all-settled = Tutto è regolato: nessuno deve niente a nessuno.
sharing-transfer = { $from } deve { $amount } a { $to }
sharing-warning-over-paid = I pagamenti superano la spesa di { $amount }: controlla gli importi.
sharing-note-income-zero = { $name } non paga nulla su { $items }: il suo reddito è 0.
sharing-note-excluded = { $name } non partecipa a «{ $item }»: la sua quota è ripartita tra gli altri.
sharing-note-gift = L'eccedenza offerta da { $giver } riduce la quota degli altri: { $name } ha ora versato più della sua quota.
sharing-note-outside = { $name } paga { $amount } fuori dalle sue voci: la somma è detratta da ciò che dividono gli altri.
sharing-note-keeper = Arrotondato a unità intere: { $name } tiene i centesimi, perché il totale torni esatto.
sharing-report-distribution = Ripartizione
sharing-report-sharing = La divisione
sharing-report-who-pays = Chi paga cosa
sharing-report-items = Il dettaglio per voce
sharing-report-payments = Stato dei pagamenti
sharing-report-as-of = Stato al { $date }
sharing-report-balances = Quota, pagato, saldo
sharing-report-statement = Estratto — { $name }
sharing-report-your-share = La tua quota
sharing-statement-total = Totale per il nucleo familiare: { $amount }
sharing-statement-pay = Da versare a { $name }: { $amount }
sharing-statement-receive = Da ricevere da { $name }: { $amount }
sharing-sheet-people = Persone
sharing-sheet-items = Voci
sharing-sheet-result = Risultato
sharing-sheet-payments = Pagamenti
sharing-sheet-balances = Rimborsi

## L'assistente di esportazione di una base (P-74, Fabrice, 19/10/2026).
window-database-export-title = Assistente di esportazione della base «{ $base }»
menu-tools-export = Assistente di esportazione della base…
base-export-only-this = Verrà esportata solo la base «{ $base }», selezionata nell'elenco. Le altre basi non sono interessate.
base-export-purpose = Questo assistente copia i dati della base in file che altri programmi sanno leggere: un foglio di calcolo, un database come Access, un altro programma di gestione dei conti. La base stessa non viene modificata.
base-export-step-format = 1. Il formato
base-export-step-options = 2. Le opzioni
base-export-step-place = 3. La posizione
base-export-step-summary = 4. Il riepilogo
base-export-format-xlsx = Excel (.xlsx)
base-export-format-xlsx-hint = Una cartella di lavoro con un foglio per tabella, leggibile da Excel e dalla maggior parte dei fogli di calcolo.
base-export-format-ods = Calc (.ods)
base-export-format-ods-hint = Il formato libero di LibreOffice e di OpenOffice, con un foglio per tabella.
base-export-format-csv = CSV (.csv)
base-export-format-csv-hint = Un file di testo per tabella, con i valori separati da punti e virgola: il formato che quasi tutti i programmi sanno importare, Access compreso.
base-export-format-json = JSON (.json)
base-export-format-json-hint = Per programmatori e applicazioni: ogni tabella sotto il proprio nome, con un'intestazione che descrive l'esportazione.
base-export-format-xml = XML (.xml)
base-export-format-xml-hint = Lo stesso contenuto del JSON, scritto in XML.
base-export-format-sql = Script SQL (.sql)
base-export-format-sql-hint = Le istruzioni che ricreano le tabelle e i loro dati in un altro database (MySQL, PostgreSQL, SQLite…).
base-export-format-sqlite = Base SQLite (.sqlite)
base-export-format-sqlite-hint = Un database autonomo, senza password, che molti strumenti aprono direttamente.
base-export-format-qif = QIF, un file per conto (.qif)
base-export-format-qif-hint = Per riprendere i propri conti in un altro programma di gestione dei conti (Money, Quicken, GnuCash, Grisbi…).
base-export-format-ofx = OFX, un file per conto (.ofx)
base-export-format-ofx-hint = Il formato degli estratti conto bancari, che la maggior parte dei programmi di gestione dei conti sa importare.
base-export-lossy = Attenzione: il QIF e l'OFX non sanno esprimere tutto. Passano solo le operazioni dei conti, con i loro terzi, le loro categorie e i loro commenti; un trasferimento diventa un'operazione normale da ciascun lato, e il resto (budget, operazioni periodiche, progetti, assegnazioni…) non segue. Per conservare tutto, scelga un altro formato.
base-export-planned-note = Le operazioni previste e le operazioni senza data non vengono esportate: non sono ancora passate in banca. Il loro numero sarà indicato alla fine.
base-export-dates-hint = Le date sono scritte anno-mese-giorno (2026-12-31) e gli importi nella valuta della base: nessun programma può sbagliarsi.
base-export-group-layout = File
base-export-layout-one = Tutto in un unico file
base-export-layout-per-table = Un file per tabella, in una cartella
base-export-group-decimal = Separatore decimale degli importi
base-export-decimal-point = Il punto (1234.56)
base-export-decimal-comma = La virgola (1234,56)
base-export-group-quotes = Virgolette
base-export-quotes-all = Ogni valore tra virgolette
base-export-quotes-none = Nessuna virgoletta
base-export-csv-replacements-hint = Perché ogni file si possa rileggere senza errori, un punto e virgola in un testo diventa un punto esclamativo, un ritorno a capo diventa uno spazio e, senza virgolette, una virgoletta diventa un apostrofo. Il numero di sostituzioni sarà indicato alla fine.
base-export-group-qif-order = Ordine delle date
base-export-qif-day-month = Il giorno prima del mese (31/12/2026)
base-export-qif-month-day = Il mese prima del giorno (12/31/2026)
base-export-qif-order-hint = Scelga l'ordine che si aspetta il programma che leggerà i file: prima il giorno in Europa, prima il mese negli Stati Uniti.
base-export-no-option = Questo formato non ha opzioni.
base-export-choose-file = Scegliere il file…
base-export-choose-folder = Scegliere la cartella…
base-export-place-file = L'esportazione sarà scritta in questo file:
base-export-place-folder = L'esportazione sarà scritta in questa cartella, creata per l'occasione:
base-export-place-none = Nessuna posizione è ancora stata scelta.
base-export-place-needed = Scelga prima dove scrivere l'esportazione.
base-export-folder-exists = La cartella «{ $name }» esiste già. I file con lo stesso nome che contiene saranno sostituiti. Continuare?
base-export-summary-base = Base
base-export-summary-format = Formato
base-export-summary-options = Opzioni
base-export-summary-place = Posizione
base-export-unprotected = Questa base è protetta da una password, ma l'esportazione non lo sarà: chiunque abbia questi file potrà leggere i suoi conti. Li conservi in un luogo sicuro.
base-export-previous = Indietro
base-export-next = Avanti
base-export-run = Esporta
base-export-running = Esportazione in corso…
base-export-done = La base «{ $base }» è stata esportata: { $tables ->
        [one] una tabella
       *[other] { $tables } tabelle
    }, { $rows ->
        [one] una riga
       *[other] { $rows } righe
    }.
base-export-done-accounts = La base «{ $base }» è stata esportata: { $accounts ->
        [one] un conto
       *[other] { $accounts } conti
    }, { $operations ->
        [one] un'operazione
       *[other] { $operations } operazioni
    }.
base-export-done-replacements = { $count ->
        [one] Un carattere è stato sostituito nei file CSV.
       *[other] { $count } caratteri sono stati sostituiti nei file CSV.
    }
base-export-done-controls = { $count ->
        [one] { $count } carattere di controllo, che questo formato non può contenere, è stato sostituito con «�».
       *[other] { $count } caratteri di controllo, che questo formato non può contenere, sono stati sostituiti con «�».
    }
base-export-done-excel-cut = { $count ->
        [one] { $count } testo superava i 32.767 caratteri, il limite di Excel: è stato troncato nella cartella di lavoro. Gli altri formati lo conservano intero.
       *[other] { $count } testi superavano i 32.767 caratteri, il limite di Excel: sono stati troncati nella cartella di lavoro. Gli altri formati li conservano interi.
    }
base-export-done-anomalies = { $count ->
        [one] Un valore illeggibile è stato ricopiato così com'era.
       *[other] { $count } valori illeggibili sono stati ricopiati così com'erano.
    }
base-export-done-planned = { $count ->
        [one] Un'operazione prevista è stata lasciata da parte.
       *[other] { $count } operazioni previste sono state lasciate da parte.
    }
base-export-done-undated = { $count ->
        [one] Un'operazione senza data è stata lasciata da parte.
       *[other] { $count } operazioni senza data sono state lasciate da parte.
    }
base-export-done-adjusted = { $count ->
        [one] Un valore è stato adattato al formato.
       *[other] { $count } valori sono stati adattati al formato.
    }
base-export-too-old = Questa base proviene da una versione più vecchia di Radinus. La apra prima una volta in Radinus, che la aggiornerà, poi la esporti.
base-export-too-recent = Questa base è stata salvata da una versione più recente di Radinus. Aggiorni Radinus per esportarla.
base-export-not-radinus = Questo file non è una base Radinus.
base-export-failed = Non è stato possibile eseguire l'esportazione: { $reason }

## Il menu Strumenti della finestra delle basi nomina la base (Fabrice, 19/10/2026).
databases-tools-selected = Base selezionata: «{ $base }»
databases-tools-none = Nessuna base selezionata
menu-tools-backup = Fare una copia di sicurezza della base «{ $base }»…
menu-tools-backup-none = Fare una copia di sicurezza della base selezionata…
menu-tools-restore = Ripristinare la base «{ $base }»…
menu-tools-restore-none = Ripristinare la base selezionata…
menu-tools-repair = Riparare e ottimizzare la base «{ $base }»…
menu-tools-repair-none = Riparare e ottimizzare la base selezionata…
