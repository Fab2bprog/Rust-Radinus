# Radinus — mensajes del núcleo (Fluent), español.
#
# Traducción del fichero francés, que hace fe : el razonamiento de cada frase
# y las decisiones del autor están documentados en `fr.ftl`, no aquí. Este
# fichero no lleva más que las claves y su texto.
#
# El número de la constante « nation » del WLangage para el español es 7
# (ver `i18n.rs`). Añadir un idioma = añadir un fichero como éste y una línea
# en la tabla KNOWN.

# ---------------------------------------------------------------------
# El nombre de este idioma, escrito en este idioma.
# ---------------------------------------------------------------------
language-name = Español

nomenclature-unspecified = No especificado

nomenclature-delete-confirm = Se han detectado operaciones (transacciones bancarias) que poseen el atributo de tipo '{ $label }'. ¿Confirma que desea reinicializar este atributo?

nomenclature-delete-plain = ¿Confirma la eliminación de «{ $label }»?

nomenclature-delete-form-open = La ficha de «{ $label }» está abierta. Ciérrela antes de eliminar.

nomenclature-duplicate = Ya existe { $element } con el mismo nombre: «{ $label }».

# ---------------------------------------------------------------------
# Lo que las ventanas dicen de sí mismas.
# ---------------------------------------------------------------------

ui-loading = Cargando…
ui-editing = Modificación.
ui-viewing = Consulta.
ui-modified-suffix = — modificado
ui-label-required = La denominación es obligatoria.
ui-discard-question = ¿Abandonar las modificaciones?
ui-yes = Sí
ui-no = No
ui-select-record = Seleccione un registro
ui-key-multiselect = CTRL
ui-multiselect-help = Info: Utilice Clic de ratón + tecla [{ $modifier }] en la tabla para seleccionar varios elementos
ui-no-match = Ninguna denominación coincide con el filtro.
ui-filter-placeholder = Filtrar las denominaciones…
ui-column-label = DENOMINACION
ui-field-label = Denominacion
ui-field-budget-line = Partida presupuestaria
ui-identifier = Identificador
ui-deletion-abandoned = Eliminación abandonada: no se ha modificado nada.
ui-unknown-nomenclature = Nomenclatura desconocida:

ui-title-filter = Filtrar
ui-title-create = Crear
ui-title-update = Modificar la selección
ui-title-delete = Eliminar la selección
ui-title-read = Consultar la selección
ui-title-close = Cerrar
ui-title-save = Guardar
ui-title-add = Añadir
ui-title-modify = Modificar

ui-load-failed = No se puede cargar:
ui-save-failed = No se puede guardar:
ui-read-failed = No se puede leer:
ui-delete-failed = No se puede eliminar:
ui-open-failed = No se puede abrir:
ui-close-failed = No se puede cerrar:

# --- Frases propias de cada nomenclatura -----------------------------

nomenclature-identifier = { $kind ->
    [category] Identificador de Categoria
    [assignment] Identificador de Asignacion
    [payment-mode] Identificador de Forma de pago
    [payee] Identificador de Beneficiario
    [project] Identificador de Proyecto
    [budget-line] Identificador de Partida presupuestaria
   *[bank] Identificador de Banco
}

nomenclature-none = { $kind ->
    [category] Ninguna categoría.
    [assignment] Ninguna asignación.
    [payment-mode] Ninguna forma de pago.
    [payee] Ningún beneficiario.
    [project] Ningún proyecto.
    [budget-line] Ninguna partida presupuestaria.
   *[bank] Ningún banco.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Ninguna categoría que mostrar.
    [assignment] Ninguna asignación que mostrar.
    [payment-mode] Ninguna forma de pago que mostrar.
    [payee] Ningún beneficiario que mostrar.
    [project] Ningún proyecto que mostrar.
    [budget-line] Ninguna partida presupuestaria que mostrar.
   *[bank] Ningún banco que mostrar.
}

nomenclature-gone = { $kind ->
    [category] Esta categoría ya no existe.
    [assignment] Esta asignación ya no existe.
    [payment-mode] Esta forma de pago ya no existe.
    [payee] Este beneficiario ya no existe.
    [project] Este proyecto ya no existe.
    [budget-line] Esta partida presupuestaria ya no existe.
   *[bank] Este banco ya no existe.
}

nomenclature-fresh = { $kind ->
    [category] Nueva categoría.
    [assignment] Nueva asignación.
    [payment-mode] Nueva forma de pago.
    [payee] Nuevo beneficiario.
    [project] Nuevo proyecto.
    [budget-line] Nueva partida presupuestaria.
   *[bank] Nuevo banco.
}

nomenclature-created = { $kind ->
    [category] Categoría añadida.
    [assignment] Asignación añadida.
    [payment-mode] Forma de pago añadida.
    [payee] Beneficiario añadido.
    [project] Proyecto añadido.
    [budget-line] Partida presupuestaria añadida.
   *[bank] Banco añadido.
}

nomenclature-updated = { $kind ->
    [category] Categoría modificada.
    [assignment] Asignación modificada.
    [payment-mode] Forma de pago modificada.
    [payee] Beneficiario modificado.
    [project] Proyecto modificado.
    [budget-line] Partida presupuestaria modificada.
   *[bank] Banco modificado.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 categoría eliminada.
       *[other] { $count } categorías eliminadas.
      }
    [assignment] { $count ->
        [one] 1 asignación eliminada.
       *[other] { $count } asignaciones eliminadas.
      }
    [payment-mode] { $count ->
        [one] 1 forma de pago eliminada.
       *[other] { $count } formas de pago eliminadas.
      }
    [payee] { $count ->
        [one] 1 beneficiario eliminado.
       *[other] { $count } beneficiarios eliminados.
      }
    [project] { $count ->
        [one] 1 proyecto eliminado.
       *[other] { $count } proyectos eliminados.
      }
    [budget-line] { $count ->
        [one] 1 partida presupuestaria eliminada.
       *[other] { $count } partidas presupuestarias eliminadas.
      }
   *[bank] { $count ->
        [one] 1 banco eliminado.
       *[other] { $count } bancos eliminados.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Ya existe una categoría con el mismo nombre: «{ $label }».
    [assignment] Ya existe una asignación con el mismo nombre: «{ $label }».
    [payment-mode] Ya existe una forma de pago con el mismo nombre: «{ $label }».
    [payee] Ya existe un beneficiario con el mismo nombre: «{ $label }».
    [project] Ya existe un proyecto con el mismo nombre: «{ $label }».
    [budget-line] Ya existe una partida presupuestaria con el mismo nombre: «{ $label }».
   *[bank] Ya existe un banco con el mismo nombre: «{ $label }».
}

# --- Títulos de ventanas, sin acentos como en las ventanas de origen --

window-list-title = { $kind ->
    [category] Lista de categorias
    [assignment] Lista de asignaciones
    [payment-mode] Lista de formas de pago
    [payee] Lista de beneficiarios y comercios
    [project] Lista de proyectos
    [budget-line] Lista de partidas presupuestarias
   *[bank] Lista de bancos
}

window-form-title = { $kind ->
    [category] Ficha categoria
    [assignment] Ficha asignacion
    [payment-mode] Ficha forma de pago
    [payee] Ficha beneficiario
    [project] Ficha proyecto
    [budget-line] Ficha partida presupuestaria
   *[bank] Ficha banco
}

# --- Barra de menús (01_CAHIER_DES_CHARGES.md §6) ---------------------

menu-file = Archivo
menu-file-import-statements = Importación de extractos bancarios
menu-file-import-excel = Importación de archivo Excel
menu-file-backup = Copia de seguridad
menu-file-restore = Restauración
menu-file-repair = Reparación y optimización de la base de datos
menu-file-log = Mostrar el registro
menu-tools-password = Proteger la base de datos con una contraseña
menu-file-disconnect = Desconectarse de la base actual
menu-file-quit = Salir

menu-accounts = Cuentas
menu-accounts-manage = Gestión de las cuentas bancarias
menu-accounts-balances = Ver los saldos de sus cuentas
menu-accounts-operations = Gestionar las operaciones de una cuenta
menu-accounts-quick-classify = Clasificación rápida de las operaciones
menu-accounts-recurring = Gestión de las operaciones periódicas
menu-accounts-transfer = Transferir un importe entre dos cuentas
menu-accounts-checkbooks = Gestión de los talonarios

menu-statistics = Estadísticas
menu-statistics-balance-chart = Gráfico Evolución del saldo
menu-statistics-balance-analysis = Análisis Evolución del saldo
menu-statistics-by-category = Estadísticas por categorías
menu-statistics-by-assignment = Estadísticas por asignaciones
menu-statistics-by-budget-line = Estadísticas por partidas presupuestarias
menu-statistics-by-payment-mode = Estadísticas por formas de pago
menu-statistics-by-payee = Estadísticas por beneficiarios y comercios
menu-statistics-by-project = Estadísticas por proyectos
menu-statistics-by-verification = Estadísticas por verificaciones
menu-statistics-dashboard = Cuadro de mando de las operaciones
menu-statistics-crossed-balance = Balance cruzado

menu-budget = Presupuesto
menu-budget-entry = Introducción del presupuesto
menu-budget-control = Control del presupuesto

menu-nomenclatures = Nomenclaturas
menu-nomenclature = { $kind ->
    [category] Categorías
    [assignment] Asignaciones
    [payment-mode] Formas de pago
    [payee] Beneficiarios y comercios
    [project] Proyectos
    [budget-line] Partidas presupuestarias
   *[bank] Bancos
}
menu-nomenclatures-templates = Plantillas de operaciones

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Herramientas
menu-settings = Configuración
menu-settings-about-author = Acerca del autor
menu-settings-about-radinus = Acerca de Radinus
menu-settings-licence = Licencia de uso

menu-misc = Varios
menu-misc-calculator = Calculadora
menu-misc-website = Ir al sitio web de Radinus
menu-misc-database-folder = Acceso a la carpeta que contiene la base de datos

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Abrir la carpeta de la base de datos
database-folder-warning =
    Esta carpeta contiene todos sus datos. Renombrar, mover o eliminar un archivo puede hacerle perder sus cuentas, dañarlas o impedir que Radinus funcione.
    ¿Desea abrirla realmente?
menu-misc-application-folder = Acceso a la carpeta que contiene la aplicación
menu-misc-attachments-folder = Acceso a la carpeta que contiene los archivos adjuntos
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Gestión de los archivos adjuntos
window-attachments-manager-title = Gestión de los archivos adjuntos
attachments-column-document = Documento
attachments-column-size = Tamaño
attachments-column-added = Añadido el
attachments-column-state = Estado
attachments-state-intact = Intacto
attachments-state-altered = Modificado desde
attachments-state-missing = Archivo ausente
attachments-state-unknown = No verificable
attachments-state-orphan = Huérfano
attachments-no-operation = Ninguna operación
attachments-orphan-remove-question = Este archivo no está vinculado a ninguna operación. ¿Enviarlo a la papelera?
attachments-manager-help = Haga doble clic en una línea para abrir el documento.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Mostrar la operación
attachments-reveal = Mostrar en el explorador de archivos
attachments-manager-summary = { $count } archivos adjuntos, { $size } en total.
attachments-disk-name = Nombre en el disco: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Abrir la carpeta de los archivos adjuntos
attachments-folder-warning =
    Esta carpeta contiene los archivos que ha adjuntado a sus operaciones. Radinus los guarda con un nombre elegido por él: cambiar el nombre, mover o eliminar uno no lo desvincula de la operación, que seguirá anunciándolo y ya no se abrirá.
    ¿Desea abrirla realmente?

# --- Cuentas bancarias — F04, F06, F07, F08 ---------------------------

window-accounts-title = Gestión de las cuentas bancarias
window-accounts-select-title = Lista de cuentas
window-balances-title = Saldos de sus cuentas
window-account-title = Ficha de la cuenta

accounts-none = Ninguna cuenta.
accounts-nothing-to-show = Ninguna cuenta que mostrar.
accounts-gone = Esta cuenta ya no existe.
accounts-fresh = Nueva cuenta.
accounts-created = Cuenta añadida.
accounts-updated = Cuenta modificada.
accounts-deleted = { $count ->
    [one] 1 cuenta eliminada.
   *[other] { $count } cuentas eliminadas.
}
accounts-duplicate-name = Ya existe una cuenta con el mismo nombre: «{ $label }».
accounts-multiselect-help = Info: utilice clic de ratón + tecla [{ $modifier }] en la tabla para seleccionar varias cuentas
accounts-select-question = ¿En qué cuentas bancarias deben basarse las estadísticas?

accounts-column-label = DENOMINACIÓN
accounts-column-bank = Banco
accounts-column-type = Tipo cuenta
accounts-column-number = Núm. cuenta
accounts-column-account = Cuenta
accounts-column-bank-balance = En el banco
accounts-column-real-balance = Real
accounts-column-final-balance = Final
accounts-total = TOTAL

accounts-delete-plain = ¿Confirma la eliminación de la cuenta «{ $label }»?
accounts-delete-with-operations = La cuenta «{ $label }» contiene { $count } operaciones, que se eliminarán con ella. ¿Confirma la eliminación?
accounts-delete-form-open = La ficha de la cuenta «{ $label }» está abierta. Ciérrela antes de eliminar.

account-group-bank = Datos de la cuenta y del banco
account-group-holder = Titular
account-group-rib = Datos bancarios
account-group-activity = Actividad
account-group-balances = Saldos

account-field-label = Título de la cuenta
account-field-bank = Banco
account-field-type = Tipo cuenta
account-field-branch-address = Dirección de la oficina bancaria
account-field-holder-name = Nombre
account-field-holder-address = Dirección
account-field-rib-bank = Código de entidad
account-field-rib-branch = Código de oficina
account-field-rib-number = Número de cuenta
account-field-rib-key = Dígitos de control
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Fecha de apertura
account-field-closing-date = Fecha de cierre
account-field-closed = Está cerrada
account-field-opening-pointed = Saldo inicial conciliado
account-field-opening-committed = Saldo inicial comprometido
account-field-opening-planned = Saldo inicial previsto

account-label-required = El título de la cuenta es obligatorio.
account-iban-invalid = Este IBAN no es válido: compruebe los dígitos de control.
account-control-line = Saldo inicial conciliado ({ $opening }) + Total de las operaciones ({ $operations }) = Saldo actual en el banco: { $balance }.

amount-not-readable = «{ $field }» no contiene un importe válido.

ui-thousands-separator = .
ui-decimal-separator = ,

# --- Lista de operaciones (F02) --------------------------------------

window-operations-title = Lista de operaciones de la cuenta: { $account }

operations-none = Ninguna operación en este periodo.
operations-bad-period = Los límites del periodo no son fechas válidas.
operations-from = Fecha inicio
operations-to = Fecha fin
operations-delete-confirm = { $count ->
    [one] ¿Confirma la eliminación de esta operación?
   *[other] ¿Confirma la eliminación de estas { $count } líneas? Los desgloses de las operaciones seleccionadas se eliminan con ellas.
}
operations-deleted = { $count ->
    [one] 1 operación eliminada.
   *[other] { $count } operaciones eliminadas.
}
operations-selection-total = Importe total de las operaciones seleccionadas: { $amount }

operations-column-date = Fecha
operations-column-clearing-date = Fecha conciliación
operations-column-status = Estado de la operación
operation-status-pointed = Conciliado
operation-status-committed = Comprometido
operation-status-planned = Previsto
operations-column-verification = Verificación
operation-verification-to-verify = Por verificar
operation-verification-verified = Verificada
operation-verification-doubtful = Dudosa
operation-verification-disputed = Impugnada
operations-column-label = Concepto
operations-column-reference = Referencia del pago
operations-column-category = Categoría
operations-column-assignment = Asignación
operations-column-payment-mode = Forma
operations-column-payee = Beneficiario
operations-column-project = Proyectos
operations-column-month = Mes
operations-column-debit = Debe
operations-column-credit = Haber
operations-column-balance = Saldo
operations-column-comments = Comentarios
operations-column-attachments = Adjuntos
operations-column-check = Núm. cheque

operations-foot-debit = Debe:
operations-foot-credit = Haber:
operations-foot-total = Total:
operations-foot-bank = Saldo en el banco:
operations-foot-real = Saldo real:
operations-foot-final = Saldo final:

operations-menu-export = Exportar
operations-menu-print = Impresión
operations-menu-filter = Filtro
operations-menu-period = Periodo
operations-menu-misc = Varios

operations-title-point = Conciliar la selección
operations-title-sub = Añadir un desglose
operations-title-duplicate = Duplicar la selección
operations-not-yet = Esta ventana aún no existe: llega más adelante en el plan.

accounts-choose-question = ¿En qué cuenta desea trabajar?
ui-title-select = Elegir la selección

month-january = enero
month-february = febrero
month-march = marzo
month-april = abril
month-may = mayo
month-june = junio
month-july = julio
month-august = agosto
month-september = septiembre
month-october = octubre
month-november = noviembre
month-december = diciembre

operations-period-year = Año en curso

# --- Menú Periodo de F02 ---------------------------------------------

period-all = Todas
period-last-year = Año pasado
period-this-year = Año actual
period-whole-year = Todo el año
period-last-month = Mes pasado
period-this-month = Mes en curso
period-last-week = Semana pasada
period-this-week = Semana actual
period-yesterday = Ayer
period-today = Hoy

# --- Menú Filtro de F02 ----------------------------------------------

filter-all = Todas las operaciones
filter-pointed = Solo las operaciones conciliadas
filter-committed = Solo las operaciones comprometidas
filter-planned = Solo las operaciones previstas
filter-by-status = Filtro por estado
filter-by-verification = Filtro por verificación
filter-show-all = Mostrar todo

# --- Ficha de operación (F03) ----------------------------------------

window-operation-title = Operación de la cuenta: { $account }

operation-menu-identification = Identificación
operation-menu-options = Opciones
operation-fitid-edit = Editar el identificador FITID…
operation-fitid-delete = Eliminar el identificador FITID
operation-fitid-question = Identificador FITID de esta transacción:
operation-fitid-delete-question = ¿Eliminar el identificador FITID de esta transacción?
operation-fitid-written = Identificador FITID guardado.
operation-fitid-removed = Identificador FITID eliminado.

operation-group-identification = Identificación de la operación
operation-group-amount = Importe de la operación
operation-group-status = Estado de la operación
operation-group-classification = Clasificación de la operación para el cálculo de las estadísticas
operation-group-check = Cheque relacionado con la operación
operation-group-comment = Comentario

operation-field-label = Concepto
operation-field-reference = Referencia del pago
operation-field-date = Fecha
operation-field-direction = Tipo de operación:
operation-field-amount = Importe
operation-field-status = Estado de la operación
operation-field-clearing-date = Fecha de conciliación
operation-field-verification = Verificación
operation-field-category = Categoría
operation-field-assignment = Asignación
operation-field-payment-mode = Forma
operation-field-payee = Beneficiario
operation-field-project = Proyecto
operation-field-check = Asociar con un cheque

operation-direction-debit = Debe
operation-direction-credit = Haber

operation-check-info = Info.
operation-check-link = Asociar
operation-check-unlink = Eliminar

operation-fresh = Nueva operación.
operation-created = Operación añadida.
operation-updated = Operación modificada.
operation-gone = Esta operación ya no existe.
operation-nothing-to-show = Ninguna operación que mostrar.
operation-label-required = El concepto de la operación es obligatorio.
operation-date-required = La fecha de la operación es obligatoria.
operation-clearing-date-invalid = La fecha de conciliación no es una fecha válida.
operation-clearing-date-required = Una operación punteada debe llevar obligatoriamente una fecha de punteo.
operation-clearing-date-question =
    Una operación punteada debe llevar obligatoriamente una fecha de punteo.
    ¿Desea guardar con la fecha de la operación, el { $date }?
operation-is-a-sub = Esta línea es un desglose: se modifica desde su propia ficha.
operation-delete-form-open = La ficha de «{ $label }» está abierta. Ciérrela antes de eliminar.

operation-attachments = { $count ->
    [0] Ningún adjunto
    [one] 1 adjunto
   *[other] { $count } adjuntos
}

operation-title-comment = Comentario de la operación
operation-title-sub = Crear un desglose
operation-title-template = Modelos de operación
operation-title-attachment = Adjuntos

# --- Ficha de desglose (F04) ------------------------------------------

window-sub-operation-title = Ficha de desglose

sub-operation-group-amount = Importe del desglose
sub-operation-field-label = Nombre
sub-operation-fresh = Nuevo desglose.
sub-operation-created = Desglose añadido.
sub-operation-updated = Desglose modificado.
sub-operation-gone = Este desglose ya no existe.
sub-operation-nothing-to-show = Ningún desglose que mostrar.
sub-operation-label-required = El nombre del desglose es obligatorio.
sub-operation-parent-gone = La operación que se quiere desglosar ya no existe.
sub-operation-is-the-complement = Este es el Complemento: lo que queda por desglosar. Si lo renombra o cambia su importe, pasa a ser un desglose ordinario.
sub-operation-of = Desglose de «{ $label }» ({ $amount })

operations-pointed = { $count ->
    [0] Ninguna operación que conciliar: la selección ya está conciliada.
    [one] 1 operación conciliada.
   *[other] { $count } operaciones conciliadas.
}
operations-select-one = Seleccione una sola operación.

# --- Duplicar y la visualización de los desgloses (F02) ---------------

operation-copy = Copia pendiente de guardar: todavía no se ha creado nada.
operations-show-children = Mostrar todos los desgloses
operations-hide-children = Ocultar todos los desgloses
operations-recurring-from = Crear una operación periódica a partir de esta operación

# --- Segunda confirmación de una eliminación grave --------------------

accounts-delete-second-question = Esta eliminación es definitiva y se lleva todo el historial de la cuenta. Escriba «{ $word }» para confirmarla.

# --- F20-F24 — Las seis estadísticas ----------------------------------

window-statistics-title = { $kind ->
    [assignment] Estadísticas por asignación
    [budget-line] Estadísticas por partida presupuestaria
    [payment-mode] Estadísticas por forma de pago
    [payee] Estadísticas por beneficiario y comercio
    [project] Estadísticas por proyecto
    [verification] Estadísticas por verificación
   *[category] Estadísticas por categoría
}

statistics-axis-column = { $kind ->
    [assignment] Asignación
    [budget-line] Partida presupuestaria
    [payment-mode] Forma de pago
    [payee] Beneficiario
    [project] Proyectos
    [verification] Verificación
   *[category] Categoría
}

statistics-unclassified = { $kind ->
    [assignment] Sin asignación
    [budget-line] Sin partida presupuestaria
    [payment-mode] Sin forma de pago
    [payee] Sin beneficiario
    [project] Sin proyecto
    [verification] Por verificar
   *[category] Sin categoría
}
statistics-total = Total
statistics-sum = Suma
statistics-cumulative = Acumulado

statistics-switch-pointed = Operaciones conciliadas { $state }
statistics-switch-committed = Operaciones comprometidas { $state }
statistics-switch-planned = Operaciones previstas { $state }
statistics-switch-debits = Importes de cargo { $state }
statistics-switch-credits = Importes de abono { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = No se ha elegido ninguna cuenta: la estadística no abarca nada.
statistics-no-data = Ninguna operación en este año para las cuentas elegidas.
statistics-detail-empty = Haga clic en una casilla con cifras para ver las operaciones que cuenta.
statistics-detail-none = Ninguna operación detrás de esta casilla.
statistics-accounts = { $count ->
    [one] 1 cuenta
   *[other] { $count } cuentas
}
statistics-year-next = Año siguiente
statistics-year-previous = Año anterior

statistics-column-date = Fecha
statistics-column-clearing-date = Fecha de conciliación
statistics-column-label = Concepto
statistics-column-amount = Importe
statistics-column-comments = Comentarios

accounts-stats-multiselect-help = Info: Utilice clic de ratón + tecla [{ $modifier }] sobre la tabla para elegir varias cuentas

statistics-year-question = ¿Sobre qué año desea trabajar? Radinus va de { $first } a { $last }.
statistics-year-choose = Elegir el año

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Balance cruzado
crossed-balance-window-name = Balance cruzado
crossed-balance-column = Categoría
crossed-balance-no-data = Ninguna operación en este mes para las cuentas elegidas.
crossed-balance-month-question = ¿Sobre qué mes desea trabajar? Un número entre { $first } y { $last }.
crossed-balance-month-choose = Elegir el mes
crossed-balance-next = Mes siguiente
crossed-balance-previous = Mes anterior

# --- Exportación de las tablas (clic derecho) -------------------------

export-to-excel = Exportar a Excel (.xlsx)
export-to-word = Exportar a Word (.docx)
export-to-tsv = Exportar a TSV (.tsv)
export-to-ini = Exportar a INI (.ini)
export-to-toml = Exportar a TOML (.toml)
export-to-yaml = Exportar a YAML (.yaml)
export-to-ofx = Exportar a OFX (.ofx)
export-to-qif = Exportar a QIF (.qif)
export-to-ods = Exportar a LibreOffice Calc (.ods)
export-to-csv = Exportar a CSV (.csv)
export-to-xml = Exportar a XML (.xml)
export-menu = Exportar
export-to = Exportar a
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Copiar la celda
copy-rows = Copiar las líneas seleccionadas
copy-failed = No se pudo copiar al portapapeles.
export-all-years-excel = Exportar todos los años a Excel
export-all-years-ods = Exportar todos los años a LibreOffice Calc
export-all-months-excel = Exportar todos los meses del año mostrado a Excel
export-all-months-ods = Exportar todos los meses del año mostrado a LibreOffice Calc
export-no-year = Ningún año tiene operaciones: no hay nada que exportar.
export-years-done = { $years } años exportados a «{ $file }».
export-to-json = Exportar a JSON (.json)
export-done = Exportado a «{ $file }».
export-failed = No se puede exportar: { $reason }
export-nothing = No hay nada que exportar.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Estadísticas por asignación
    [budget-line] Estadísticas por partida presupuestaria
    [payment-mode] Estadísticas por forma de pago
    [payee] Estadísticas por beneficiario y comercio
    [project] Estadísticas por proyecto
    [verification] Estadísticas por verificación
   *[category] Estadísticas por categoría
}
statistics-detail-name = Detalle de las estadísticas

# --- F19 — Cuadro de mando --------------------------------------------

window-dashboard-title = Cuadro de mando
dashboard-menu-period = Período
dashboard-menu-misc = Varios
dashboard-from = Fecha de inicio:
dashboard-to = Fecha de fin:
dashboard-switch-pointed = Incluir operaciones conciliadas
dashboard-switch-committed = Incluir operaciones comprometidas
dashboard-switch-planned = Incluir operaciones previstas
dashboard-spending = Gastos
dashboard-earning = Ingresos
dashboard-debits = Suma de operaciones de cargo
dashboard-credits = Suma de operaciones de abono
dashboard-balance = Balance
dashboard-unclassified = Sin partida presupuestaria
dashboard-nothing = Ninguna operación en este período.
dashboard-no-account = No se ha elegido ninguna cuenta: el cuadro de mando no abarca nada.
dashboard-enlarge = Abrir en grande

# --- F25 — Evolución del saldo -----------------------------------------

window-curve-title = Evolución del saldo
curve-heading = Evolución del saldo por día
curve-menu-period = Período
curve-total = Total
curve-from = Fecha de inicio:
curve-to = Fecha de fin:
curve-axis-balance = saldo
curve-nothing = No se ha elegido ninguna cuenta: no hay curva que trazar.
curve-empty = Ninguna operación en este período.

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Análisis de la evolución del saldo
analysis-heading = Análisis de la evolución del saldo
analysis-hint = Trace una zona en el gráfico, con el botón del ratón pulsado, para ver las operaciones de ese período.
analysis-zone = Zona:
analysis-opening = Saldo al inicio:
analysis-closing = Saldo al final:
analysis-variation = Variación:
analysis-detail-name = Análisis del saldo
analysis-detail-none = Ninguna operación en esta zona.

# --- F05 — Clasificación rápida de las operaciones ---------------------

window-quick-classification-title = Clasificación rápida de las operaciones: { $account }
quick-dates-title = Fechas de inicio y de fin de la lista.
quick-from = Fecha inicio
quick-to = Fecha fin
quick-menu-period = Período
quick-change-title = Cambiar las características de la selección a:
quick-check-category = Categoría
quick-check-assignment = Asignación
quick-check-payment-mode = Forma
quick-check-payee = Beneficiario
quick-check-project = Proyecto
quick-check-status = Estado
quick-check-verification = Verificación
quick-column-date = Fecha
quick-column-label = Concepto
quick-column-amount = Importe
quick-column-category = Categoría
quick-column-assignment = Asignación
quick-column-payment-mode = Forma de pago
quick-column-payee = Beneficiario
quick-column-project = Proyectos
quick-column-status = Estado
quick-column-verification = Verificación
quick-multiselect-help = Info: Utilice clic de ratón + tecla [{ $modifier }] sobre la tabla para seleccionar varios elementos
quick-none = Ninguna operación en este período.
quick-select-lines = Seleccione al menos una línea y marque al menos una característica.
quick-applied = { $count ->
    [0] No ha cambiado nada: estas líneas ya tenían esa clasificación.
    [one] 1 línea clasificada. Todavía no se ha guardado nada.
   *[other] { $count } líneas clasificadas. Todavía no se ha guardado nada.
}
quick-pending = { $count ->
    [0] Ninguna modificación pendiente.
    [one] 1 línea modificada, sin guardar.
   *[other] { $count } líneas modificadas, sin guardar.
}
quick-save-question = { $count ->
    [one] ¿Guardar la modificación pendiente?
   *[other] ¿Guardar las { $count } modificaciones pendientes?
}
quick-saved = { $count ->
    [0] No había nada que guardar.
    [one] 1 línea guardada.
   *[other] { $count } líneas guardadas.
}
quick-nothing-to-save = Ninguna modificación pendiente.
quick-leave-question = Hay modificaciones sin guardar. ¿Qué desea hacer?
quick-leave-save = Guardar y salir
quick-leave-discard = Abandonar y salir
quick-leave-stay = Permanecer
quick-title-apply = Aplicar a las líneas seleccionadas ( en memoria )
quick-title-save = Guardar en el disco

# --- F17 / F18 — Importación de un extracto bancario ------------------

window-statement-import-title = Importación de extractos de cuentas bancarias: { $account }
window-statement-form-title = Conciliar una transacción (incorpora una operación al historial de su cuenta)
statement-menu-filter = Filtro
statement-filter-all = Todas las líneas
statement-filter-pending = Por incorporar
statement-filter-known = Ya incorporadas
statement-column-id = ID
statement-column-reconciled = Conciliada
statement-column-fitid = FITID
statement-column-date = Fecha
statement-column-label = Concepto
statement-column-reference = Referencia del pago
statement-column-debit = Cargo
statement-column-credit = Abono
statement-account = Cuenta
statement-file = Archivo
statement-difference = Diferencia
statement-none = No hay ningún extracto abierto: haga clic en la carpeta amarilla para elegir un archivo (OFX, CSV, QIF).
statement-empty = Este extracto no contiene ninguna operación.
statement-no-match = Ninguna línea corresponde al filtro.
statement-help = Información: utilice clic de ratón + tecla [{ $modifier }] sobre la tabla para seleccionar varias líneas
statement-choose-account = Este archivo contiene varias cuentas. ¿Cuál desea importar?
statement-select-line = Seleccione al menos una línea del extracto.
statement-title-open = Abrir un archivo de extracto (OFX, QIF, CSV)
statement-title-info = Información sobre el archivo abierto
statement-title-integrate = Incorporar la selección a la cuenta
statement-title-validate = Incorporar esta operación a la cuenta
statement-duplicate = Atención, duplicado: esta transacción parece haber sido incorporada ya a la base de datos (el Financial Institution Transaction ID ya existe)
statement-no-fitid = Atención: este archivo no proporciona ningún identificador (FITID) para esta línea. No será posible detectar un duplicado.
statement-loaded = { $count ->
    [0] Este archivo no contiene ninguna operación para esta cuenta.
   *[other] { $count } líneas leídas, de las cuales { $known } ya están presentes en su cuenta.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } líneas leídas; ninguna se parece a una operación ya presente en su cuenta.
    [one] { $count } líneas leídas, de las cuales una se parece a una operación ya presente en su cuenta (misma fecha, mismo concepto, mismo importe).
   *[other] { $count } líneas leídas, de las cuales { $alike } se parecen a operaciones ya presentes en su cuenta (misma fecha, mismo concepto, mismo importe).
}
statement-loaded-also-alike = { $alike ->
    [one] Otra se parece a una operación ya presente (misma fecha, mismo concepto, mismo importe).
   *[other] Otras { $alike } se parecen a operaciones ya presentes (misma fecha, mismo concepto, mismo importe).
}
statement-integrated = { $count ->
    [0] No se ha incorporado nada: estas líneas ya están en su cuenta.
    [one] 1 operación incorporada.
   *[other] { $count } operaciones incorporadas.
}

statement-mass-question =
    ¿Está seguro de que desea incorporar a su cuenta varias operaciones simultáneamente?
    Deberá categorizarlas y caracterizarlas posteriormente para obtener estadísticas precisas
    En el caso de los archivos Ofx: si se detectan duplicados deberá elegir el comportamiento del programa
    Para los demás tipos de archivo: deberá prestar atención a los duplicados
statement-duplicate-question =
    La transacción: { $date } { $label }: { $amount }
    parece haber sido incorporada ya al historial de transacciones de su cuenta bancaria.
    ¿Desea realmente proceder a la conciliación?
statement-already-reconciled = Ya ha conciliado esta transacción: ya está incorporada al historial de transacciones de su cuenta
statement-integration-report =
    Fin de la incorporación.
    Número de registros incorporados: { $added }
    Número de registros ignorados: { $ignored }
statement-integration-abandoned =
    ¡Incorporación abandonada!
    Número de registros incorporados: { $added }
    Número de registros ignorados: { $ignored }
statement-yes = Sí
statement-no = No
statement-cancel = Cancelar
statement-file-info =
    Cuenta del archivo: { $account }
    Período: del { $from } al { $to }
    Saldo declarado por el banco: { $balance }
statement-qif-question = Nada en este archivo indica si la fecha «{ $date }» se escribe día/mes o mes/día. Significa:
statement-qif-day-month = Día { $day }, mes { $month } (día/mes)
statement-qif-month-day = Día { $day }, mes { $month } (mes/día)
statement-qif-dates-mixed = Este archivo escribe sus fechas de dos maneras: «{ $first }» se lee día/mes, «{ $second }» mes/día. No se importa, para no falsear ninguna fecha.
statement-qif-amounts-mixed = Este archivo escribe sus importes de dos maneras: «{ $first }» con un punto, «{ $second }» con una coma. No se importa, para no falsear ningún importe.
statement-qif-opening = Saldo inicial de { $amount } al { $date }: no es una operación, no se importa.
statement-qif-opening-undated = Saldo inicial de { $amount }: no es una operación, no se importa.
statement-qif-suspect = La línea { $rank }, «{ $label }» ({ $amount }), parece un saldo inicial: compruébela antes de incorporarla.
statement-qif-rejected = { $count ->
    [one] Una línea ilegible no se importa: { $lines }.
   *[other] { $count } líneas ilegibles no se importan: { $lines }.
}
statement-qif-reason-date = fecha
statement-qif-reason-amount = importe
statement-qif-reason-differ = importes contradictorios
statement-qif-no-account = Esta cuenta ya no está en el archivo: vuelva a abrir el archivo.
statement-balance-unknown = no indicado en el archivo
statement-group-identification = Identificación de la operación
statement-group-amount = Importe de la operación
statement-group-classification = Clasificación de la operación para el cálculo de las estadísticas
statement-group-status = Estado de la operación
statement-field-date = Fecha
statement-field-label = Concepto
statement-field-reference = Referencia del pago
statement-field-type = Tipo de operación
statement-field-amount = Importe
statement-field-mode = Forma de pago
statement-field-category = Categoría
statement-field-assignment = Asignación
statement-field-payee = Beneficiario
statement-field-project = Proyecto
statement-field-status = Estado
statement-field-clearing = Fecha de conciliación

# --- La ventana de división de un extracto CSV ------------------------

window-csv-statement-title = Importación de datos procedentes de un archivo csv
csv-preview-title = Vista previa del archivo:
csv-settings-title = Parámetros de división del archivo para la extracción de los datos:
csv-extraction-title = Visualización de la extracción de los datos según los parámetros de división  ( compruebe la coherencia de los datos ) :
csv-column-line = N.º de línea
csv-column-content = Contenido
csv-header-lines = Número de líneas del encabezado del archivo que se deben ignorar
csv-separator = Los datos (columnas) están separados por el carácter:
csv-date-at = Posición del campo fecha
csv-label-at = Posición del campo concepto
csv-debit-at = Posición del campo importe del cargo
csv-credit-at = Posición del campo importe del abono
csv-test = Probar los parámetros
csv-separator-semicolon = Punto y coma   ;
csv-separator-comma = Coma   ,
csv-separator-tab = Tabulación
csv-separator-pipe = Barra vertical   |
csv-separator-space = Espacio
csv-help = Ajuste, pruebe, observe: solo se importarán las líneas que lleven una fecha y un importe legibles.
csv-none = El archivo está vacío.
csv-not-tested = Haga clic en «Probar los parámetros» para ver el resultado de la división.
csv-extraction = { $count ->
    [0] La división no produce ninguna línea: compruebe el número de líneas de encabezado y el separador.
   *[other] { $count } líneas divididas: { $valid } se importarán y { $dropped } se descartarán por falta de una fecha o de un importe legibles.
}
csv-nothing-valid = Ninguna línea lleva a la vez una fecha y un importe legibles: no hay nada que importar. Compruebe el número de líneas de encabezado, el separador y la posición de los campos.
csv-title-validate = Pasar las líneas válidas a la importación

# --- F13 / F31 / F14 / F12 — Talonarios y cheques (fase 9) ------------

window-chequebooks-title = Lista de talonarios
window-chequebook-title = Parámetros del talonario
window-cheques-title = Composición del talonario: lista de cheques.
window-cheque-title = Ficha de cheques
window-cheque-operations-title = Lista de operaciones.

chequebooks-column-reference = REFERENCIA
chequebooks-column-date = Fecha
chequebooks-column-account = Nombre de cuenta
chequebooks-column-account-number = Núm. de cuenta
chequebooks-column-comments = Comentarios
chequebooks-none = No hay ningún talonario registrado.
chequebooks-nothing-to-show = Ningún talonario responde a esta búsqueda.
chequebooks-title-composition = Ver la composición del talonario
chequebooks-delete-question = Se han detectado operaciones (transacciones bancarias) asociadas a este talonario. ¿Confirma que desea eliminar este talonario?
chequebooks-deleted = { $count ->
    [one] Un talonario eliminado.
   *[other] { $count } talonarios eliminados.
}
chequebooks-gone = Este talonario ya no existe.
chequebooks-created = Talonario registrado, con todos sus cheques.
chequebooks-updated = Talonario modificado.
chequebook-refusal-duplicate = Ya existe una referencia con el mismo nombre
chequebook-refusal-reference-required = Es obligatorio introducir una referencia
chequebook-refusal-number-too-big = Los números del primer y/o del último cheque son demasiado grandes (valor máximo 999.999.999)
chequebook-refusal-date = Introduzca una fecha de recepción válida
chequebook-refusal-numbers-required = Rellene los números del primer y del último cheque
chequebook-refusal-order = El número del primer cheque debe ser inferior al número del último cheque
chequebook-refusal-account = Seleccione obligatoriamente la cuenta relacionada con este talonario
chequebook-refusal-too-many = Número máximo de cheques para un talonario: 1000, límite alcanzado
chequebook-creation-question =
    Creación del talonario con las siguientes características:
    - Número de cheques que se generarán:{ $count }
    - Cheques numerados del { $first } al { $last }
    ¡Atención! Estos datos no se podrán modificar tras la creación.

chequebook-field-id = Identificador de talonario
chequebook-field-reference = Referencia
chequebook-field-received = Fabricado o recibido el
chequebook-field-first = Número del primer cheque
chequebook-field-last = Número del último cheque
chequebook-field-quantity = Número de cheques
chequebook-field-account = Asociar a la cuenta bancaria:
chequebook-field-comments = Comentarios
chequebook-locked = Los cheques de este talonario ya están creados: su numeración ya no se puede modificar.
chequebook-account-missing = ¡La cuenta bancaria a la que se asoció este talonario no existe o ha sido eliminada!

cheques-column-number = Núm. de cheque
cheques-column-date = Fecha
cheques-column-place = Lugar
cheques-column-payee = Beneficiario
cheques-column-amount = Importe
cheques-column-status = Estado
cheques-column-comments = Comentarios
cheques-column-operations = Núm. de operaciones asociadas
cheques-none = Este talonario no contiene ningún cheque.
cheques-nothing-to-show = Ningún cheque responde a esta búsqueda.
cheques-help = Haga clic en la casilla Estado para cambiarlo; la lupa muestra las operaciones asociadas y el eslabón asocia una.
cheques-title-linked = Ver las operaciones ya asociadas a este cheque
cheques-title-link = Asociar una operación a este cheque
cheques-status-changed = Estado del cheque modificado.

cheque-field-id = Identificador de cheque
cheque-field-number = Número de cheque
cheque-field-issued = Fecha de emisión
cheque-field-place = Lugar de emisión
cheque-field-payee = Beneficiario
cheque-field-amount = Importe
cheque-field-comments = Comentarios
cheque-field-status = Estado del cheque
cheque-gone = Este cheque ya no existe.
cheque-updated = Cheque modificado.

cheque-operations-linked-title = Lista de las operaciones ya asociadas a este cheque.
cheque-operations-choose-title = Elija una operación para asociarla al cheque
cheque-operations-column-account = Cuenta
cheque-operations-column-label = Nombre
cheque-operations-column-date = Fecha
cheque-operations-column-clearing = Fecha de conciliación
cheque-operations-column-amount = Importe
cheque-operations-column-cheque = Cheque asociado
cheque-operations-none-linked = Ninguna operación está asociada a este cheque.
cheque-operations-none = Esta cuenta no contiene ninguna operación.
cheque-operations-nothing-to-show = Ninguna operación responde a esta búsqueda.
cheque-operations-help = Las operaciones en negrita ya llevan un cheque.
cheque-operations-linked-help = La cruz roja separa el cheque de la operación: no se elimina nada.
cheque-operations-linked = Operación asociada al cheque.
cheque-operations-dissociated = Cheque separado de la operación.
cheque-operations-menu-filter = Filtro
cheque-title-associate = Asociar esta operación al cheque
cheque-title-dissociate = Separar el cheque de esta operación

chequebooks-select-question = Elija el talonario
cheques-select-question = Elija el cheque que desea asociar a la operación
operation-check-save-first = Guarde primero la operación: un cheque se asocia a una operación que existe.
operation-check-none = Esta operación no lleva ningún cheque.

# --- F36 / F37 — Las plantillas de operación (fase 10) ----------------

window-operation-templates-title = Lista de plantillas de operación
window-operation-template-title = Ficha Plantilla de Operación

operation-templates-none = No hay ninguna plantilla de operación registrada.
operation-templates-nothing-to-show = Ninguna plantilla responde a esta búsqueda.
operation-templates-select-question = Elija la plantilla que desea aplicar
operation-templates-delete-question = ¿Confirma la eliminación de las plantillas seleccionadas?
operation-templates-deleted = { $count ->
    [one] Una plantilla eliminada.
   *[other] { $count } plantillas eliminadas.
}
operation-template-gone = Esta plantilla ya no existe.
operation-template-fresh = Nueva plantilla.
operation-template-created = Plantilla registrada.
operation-template-updated = Plantilla modificada.
operation-template-label-required = Es obligatorio introducir un nombre
operation-template-duplicate = Ya existe una plantilla con el mismo nombre

operation-template-field-id = ID Plantilla de Operación
operation-template-group-name = Nombre por defecto de la futura operación tras aplicar la plantilla
operation-template-field-label = Nombre
operation-template-group-amount = Importe por defecto de la operación predefinido en esta plantilla
operation-template-field-direction = Tipo de Operación
operation-template-field-amount = Importe
operation-template-group-status = Estado de la operación por defecto en esta plantilla
operation-template-field-status = Estado Operación
operation-template-group-classification = Datos de la plantilla para la clasificación y el cálculo de las estadísticas
operation-template-field-category = Categoria
operation-template-field-assignment = Asignación
operation-template-field-mode = Modo
operation-template-field-payee = Beneficiario
operation-template-field-project = Proyecto

operation-template-question = ¿Qué desea hacer con las plantillas de operación?
operation-template-apply = Aplicar una plantilla
operation-template-save-as = Guardar como plantilla
operation-template-applied = Plantilla aplicada. Valide la ficha para registrarla.
operation-template-saved-as = Operación guardada como plantilla.
operation-template-needs-label = Dé un nombre a la operación antes de convertirla en plantilla.

# --- F26 / F27 — El presupuesto (fase 11) --------------------------------

window-budget-entry-title = Entrada de Presupuesto: gastos(-) e ingresos(+) previstos en un año
window-budget-control-title = Control del presupuesto

budget-column-line = Partida presupuestaria
budget-none = No hay ninguna partida presupuestaria registrada: el presupuesto se introduce por partida.
budget-planned = Previsto
budget-actual = Realizado
budget-sum = Suma
budget-cumulative = Acumulado
budget-total = Total
budget-sign-warning = Introduzca obligatoriamente los gastos  con signo negativo y los ingresos previstos con importes positivos
budget-entry-help = Escriba los importes en las casillas y luego guarde.
budget-saved = Presupuesto guardado.
budget-nothing-changed = No hay ninguna modificación que guardar.
budget-discard-question = ¿Abandonar las modificaciones del presupuesto?

budget-menu-display = Visualización
budget-display-money = Valores
budget-display-percent = Porcentajes
budget-control-help = Verde: al menos tan bien como lo previsto. Rojo: peor.

# --- F09 — Transferencia de un importe entre dos cuentas (fase 12) -------

window-transfer-title = Transferir un importe entre dos cuentas

transfer-group-source = Adeudar el importe en esta cuenta de origen
transfer-group-target = Abonar el importe en esta cuenta de destino
transfer-group-description = Descripción de la operación
transfer-group-nomenclature = Datos de Nomenclatura
transfer-group-amount = Importe de la suma que se va a transferir
transfer-field-source = Cuenta de origen
transfer-field-target = Cuenta de destino
transfer-field-label = Concepto
transfer-field-reference = Referencia de pago
transfer-field-date = Fecha
transfer-field-status = Estado Operación
transfer-field-clearing = Fecha de conciliación
transfer-field-category = Categoria
transfer-field-mode = Modo de pago
transfer-field-assignment = Asignación
transfer-field-payee = Beneficiarios / comercios
transfer-field-project = Proyecto
transfer-field-amount = Importe

ui-ok = Aceptar
transfer-help = Elija las dos cuentas: sus saldos se muestran aquí.
transfer-title-validate = Realizar la transferencia
transfer-balances = { $account } — En banco: { $bank } · Real: { $real } · Final: { $final }
transfer-done = Transferencia realizada. { $amount } de la cuenta { $source } a la cuenta { $target }, el { $date }.

transfer-refusal-accounts-required = Elija la cuenta de origen y la cuenta de destino
transfer-refusal-same-account = La cuenta de origen y la cuenta de destino no pueden ser la misma: una transferencia va de una cuenta a otra
transfer-refusal-account-gone = Una de las dos cuentas ya no existe
transfer-refusal-label-required = El concepto es obligatorio
transfer-refusal-date-required = La fecha es obligatoria
transfer-refusal-amount = El importe que se va a transferir debe ser estrictamente positivo

# ---------------------------------------------------------------------------
# Fase 13 — la importación de una hoja de Excel (F34, F35, asociación).
# ---------------------------------------------------------------------------

window-excel-import-title = Importación de hoja de excel [ Paso 1/3 ]: definición de la zona de captura
window-excel-fields-title = Importación de hoja de excel [ Paso 2/3 ]: asociación de los campos
window-excel-association-title = Importación de hoja de excel: asociación de los datos

excel-backup-question = Una hoja de Excel está hecha a mano: puede contener fechas correctas pero falsas, importes con el formato correcto y el signo equivocado, y eso ningún control puede verlo. La importación escribirá esas líneas en su cuenta. ¿Desea guardar una copia de seguridad de sus datos antes de empezar?

excel-group-file = 1 - Designar el archivo Excel que se va a importar
excel-pick = Designar el archivo Excel
excel-sheet = Hoja del libro:
excel-group-header = 2 - Definir: coordenadas de las celdas de la fila de encabezado de la tabla donde están escritos los nombres de las columnas.
excel-header-row = Número de la 1.ª fila donde está situado el nombre de las columnas
excel-first-column = Columna de inicio del encabezado ( columna más a la izquierda ):
excel-column-count = Número de columnas de la tabla
excel-group-rows = 3 - Definir: números de la primera y de la última fila de la lista que contiene los datos de la tabla ( debajo del encabezado y sin incluirlo )
excel-first-data-row = Primera fila que contiene datos
excel-last-data-row = Última fila que contiene datos:
excel-group-shape = 4 - Definir: cómo escribe su archivo los importes
excel-shape-single = Una sola columna de importes, con signo ( los gastos en negativo )
excel-shape-debit-credit = Dos columnas separadas: una columna Debe y una columna Haber
excel-shape-note = En el modo de dos columnas, el signo escrito en la columna Debe no se tiene en cuenta: un adeudo siempre saca dinero, tanto si aparece como «-50» como si aparece como «50».
excel-group-test = 5 - Resultado de prueba: visualice la captura efectuada según su configuración
excel-test = Pruebe los parámetros que ha definido en los pasos 2, 3 y 4.
excel-test-note = Indicación: el nombre de los encabezados y el contenido de la tabla siguiente deben corresponder a los de su tabla de Excel. La zona de captura no debe desbordar fuera de la zona de la tabla.

excel-help = Recorra los cinco grupos en orden y luego pruebe: no podrá pasar al paso 2 hasta que haya mirado lo que la zona captura.
excel-no-file = Designe primero el archivo Excel que se va a importar.
excel-not-tested = Ajustes modificados: vuelva a lanzar el resultado de prueba antes de validar.
excel-tested = Zona capturada: { $rows } filas, { $columns } columnas. Compruebe que la tabla siguiente se parece a su hoja.
excel-empty-capture = La zona que ha declarado no captura ninguna fila: compruebe los números de fila y de columna.
excel-title-next = Pasar al paso siguiente
excel-into-account = Importación en la cuenta { $account }.

excel-tab-links = Vínculos entre campos
excel-tab-settings = Parametros de importación
excel-column-excel = Encabezado_Excel
excel-column-radinus = Campo_Radinus
excel-links-help = Frente a cada columna de su hoja, indique qué campo de Radinus alimenta. Las columnas dejadas en [IGNORE] no se importan.
excel-group-category = Categorias sin correspondencia
excel-group-payment-mode = Modo de pago sin correspondencia
excel-group-assignment = Asignación sin correspondencia
excel-policy-create = { $kind ->
    [payment-mode] Crear automáticamente los modos de pago inexistentes
    [assignment] Crear automáticamente las asignaciones inexistentes
   *[category] Crear automáticamente las categorías inexistentes
}
excel-policy-ask = { $kind ->
    [payment-mode] Preguntar por cada modo de pago inexistente dónde transferir los datos
    [assignment] Preguntar por cada asignación inexistente dónde transferir los datos
   *[category] Preguntar por cada categoría inexistente dónde transferir los datos
}
excel-policy-blank = { $kind ->
    [payment-mode] Dejar el modo de pago en blanco
    [assignment] Dejar la asignación en blanco
   *[category] Dejar la categoría en blanco
}
excel-policy-default = { $kind ->
    [payment-mode] Transferir los modos de pago inexistentes a un modo de pago por defecto
    [assignment] Transferir las asignaciones inexistentes a una asignación por defecto
   *[category] Transferir las categorías inexistentes a una categoría por defecto
}
excel-define-destination = Definir destino
excel-not-linked = { $kind ->
    [payment-mode] Ninguna columna alimenta el modo de pago: este ajuste no se aplica.
    [assignment] Ninguna columna alimenta la asignación: este ajuste no se aplica.
   *[category] Ninguna columna alimenta la categoría: este ajuste no se aplica.
}
excel-fields-help = Ajuste las correspondencias y luego las tres políticas, antes de lanzar la importación.
excel-title-import = Lanzar la importación

excel-refusal-required = Los campos Fecha, Concepto e Importe deben apuntar obligatoriamente a columnas de excel
excel-refusal-column-twice = Campos de Radinus diferentes apuntan a la misma columna de excel: una columna solo puede alimentar un único campo
excel-refusal-field-twice = Un mismo campo de Radinus está asociado a dos columnas de excel: solo puede tener una
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Ha elegido preguntar dónde transferir los modos de pago desconocidos: pulse «Definir destino» antes de lanzar la importación.
    [assignment] Ha elegido preguntar dónde transferir las asignaciones desconocidas: pulse «Definir destino» antes de lanzar la importación.
   *[category] Ha elegido preguntar dónde transferir las categorías desconocidas: pulse «Definir destino» antes de lanzar la importación.
}

excel-column-data = Datos_Excel
excel-column-destination = { $kind ->
    [payment-mode] ModoPago_Radinus
    [assignment] Asignacion_Radinus
   *[category] Categoria_Radinus
}
excel-association-help = Frente a cada valor procedente de su hoja, elija el de Radinus en el que debe clasificarse. Una línea dejada vacía quedará sin clasificar.
excel-association-none = Ningún valor desconocido: todo lo que contiene su hoja ya existe en Radinus.

excel-imported = Importación terminada: { $count } operaciones escritas, { $refused } líneas rechazadas, { $created } valores de nomenclatura creados.
excel-report-title = Informe de la importación
excel-column-row = Fila de Excel
excel-column-content = Contenido
excel-column-reason = Motivo del rechazo
excel-nothing-refused = Todas las líneas de su hoja han entrado: ningún rechazo.

excel-refused-date = Fecha ausente o ilegible
excel-refused-amount = Importe ausente o ilegible
excel-refused-amount-both = Un importe en la columna Debe y otro en la columna Haber: imposible elegir
excel-refused-amount-missing = Ni debe ni haber en esta línea

# ---------------------------------------------------------------------------
# Fase 16 — las operaciones periódicas (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Lista de operaciones periodicas
window-recurring-form-title = Ficha que define la regla de generación de operación periodica
window-recurring-calendar-title = Propuesta de calendario de las operaciones que se van a insertar en sus cuentas bancarias

recurring-column-label = CONCEPTO
recurring-none = Ninguna regla periódica registrada.
recurring-help = Elija una regla y luego el calendario para ver los vencimientos que propone.
recurring-title-calendar = Proponer el calendario de vencimientos
recurring-deleted = { $count ->
    [0] Ninguna regla eliminada.
    [one] Una regla eliminada. Sus operaciones permanecen en la cuenta.
   *[other] { $count } reglas eliminadas. Sus operaciones permanecen en las cuentas.
}
recurring-gone = Esta regla ya no existe.
recurring-delete-question = ¿Eliminar las reglas seleccionadas? Las operaciones que ya han insertado permanecerán en sus cuentas.

recurring-group-identity = Identificación y cuenta bancaria correspondiente
recurring-group-nomenclature = Nomenclatura
recurring-group-amount = Definición del importe de la operación
recurring-group-period = Definición del periodo
recurring-group-ending = Condiciones de fin del periodo
recurring-group-produced = Datos sobre las operaciones ya insertadas ( solo para consulta )

recurring-field-id = Identificador de Operación
recurring-field-account = Cuenta de destino
recurring-field-label = Concepto
recurring-field-category = Categoria
recurring-field-mode = Modo de pago
recurring-field-assignment = Asignación
recurring-field-payee = Beneficiarios / comercios
recurring-field-project = Proyecto
recurring-field-direction = Tipo de Operación
recurring-field-amount = Importe
recurring-field-next = Fecha de la próxima operación
recurring-field-every = Después cada
recurring-field-end-date = Fecha de fin
recurring-field-repeat = Número de repeticiones
recurring-field-guid = GUID Operación
recurring-field-produced-count = Número de operaciones insertadas
recurring-field-produced-last = Fecha de la última operación insertada
recurring-field-produced-total = Total de importes generados

recurring-unit-day = Día
recurring-unit-week = Semana
recurring-unit-month = Mes
recurring-unit-quarter = Trimestre
recurring-unit-year = Año
recurring-ending-no-limit = Sin límite
recurring-ending-until-date = Con fecha de fin
recurring-ending-repeat-count = Número de repeticiones

recurring-title-erase = Borrar las operaciones ya insertadas por esta regla
recurring-erase-question = { $count ->
    [one] Esta regla ha insertado una operación en sus cuentas. ¿Desea borrarla? Los saldos se recalcularán y la regla no retrocederá.
   *[other] Esta regla ha insertado { $count } operaciones en sus cuentas. ¿Desea borrarlas todas? Los saldos se recalcularán y la regla no retrocederá.
}
recurring-erase-none = Esta regla no ha insertado todavía ninguna operación.
recurring-erased = { $count ->
    [0] Ninguna operación borrada.
    [one] Una operación borrada, saldos recalculados.
   *[other] { $count } operaciones borradas, saldos recalculados.
}

recurring-calendar-help = Retire con la papelera los vencimientos que no desee y, a continuación, valide para insertarlos.
recurring-calendar-none = Ningún vencimiento que proponer: compruebe la fecha de la próxima operación y la cuenta de sus reglas.
recurring-calendar-column-account = Cuenta
recurring-calendar-column-date = Fecha
recurring-calendar-column-label = Descripción
recurring-calendar-column-amount = Importe
recurring-calendar-column-category = Categoría
recurring-calendar-column-assignment = Asignación
recurring-calendar-column-mode = Forma de pago
recurring-calendar-column-payee = Beneficiario
recurring-calendar-column-project = Proyectos
recurring-calendar-removed = { $count ->
    [one] Un vencimiento retirado de la propuesta.
   *[other] { $count } vencimientos retirados de la propuesta.
}
recurring-title-insert = Insertar en las cuentas los vencimientos seleccionados
recurring-nothing = No queda ningún vencimiento que insertar.
recurring-insert-question = { $count ->
    [one] ¿Insertar este vencimiento en su cuenta? Se creará una operación y se recalcularán los saldos.
   *[other] ¿Insertar estos { $count } vencimientos en sus cuentas? Se creará el mismo número de operaciones y se recalcularán los saldos.
}
recurring-inserted = { $count ->
    [one] Una operación insertada. La regla se reanuda después del último vencimiento insertado.
   *[other] { $count } operaciones insertadas. Las reglas se reanudan después de su último vencimiento insertado.
}

recurring-refusal-label-required = Es obligatorio introducir una descripción
recurring-refusal-date-required = Es obligatorio introducir la fecha de la próxima operación
recurring-refusal-date-too-old = La fecha de la próxima operación debe ser igual o posterior al año 2000
recurring-refusal-account-gone = No se encuentra la cuenta bancaria indicada; seleccione otra para que la regla pueda aplicarse
recurring-refusal-end-required = Si se elige una fecha de fin, esta debe introducirse
recurring-refusal-end-before-start = La fecha de fin no puede ser anterior a la fecha de la próxima operación
recurring-refusal-end-too-far = La diferencia entre la fecha de la próxima operación y la fecha de fin no puede superar los 10.000 días

# --- Fase 15 — las impresiones e informes -------------------------------
print-operations-title = Lista de operaciones bancarias y desgloses
print-menu-operations-pdf = Impresión en archivo PDF
print-recap-title = Resumen por categoría
print-recap-count = Líneas
print-row-count = Número de líneas:
print-total-debit = Total debe:
print-total-credit = Total haber:
print-final-balance = Saldo final:
print-licence = Radinus es software libre distribuido bajo licencia GNU GPL v3 o posterior
print-nothing = No hay nada que imprimir.
print-done = Informe impreso y abierto: «{ $file }».
print-failed = Impresión imposible: { $reason }
print-not-opened = Informe impreso en «{ $file }», pero su sistema no ha sabido abrirlo por sí solo.

# --- El informe de datos bancarios (F32) --------------------------------
rib-title = DATOS BANCARIOS
rib-bank = Banco:
rib-national = RIB - Identificador nacional de cuenta
rib-establishment = ENTIDAD
rib-branch = OFICINA
rib-number = NUMERO DE CUENTA
rib-key = CLAVE RIB
rib-domiciliation = DOMICILIACION
rib-iban = IBAN - Identificador internacional de cuenta
rib-bic = BIC - Identificador internacional de la entidad
rib-holder = Titular de la cuenta

# --- La ventana F32 ----------------------------------------------------
window-rib-title = Impresión de datos bancarios ( RIB )
rib-group-bank = Banco
rib-group-holder = Titular de la cuenta
rib-group-details = Datos bancarios
rib-field-bank = Nombre del banco
rib-field-domiciliation = Domiciliación
rib-field-holder = Nombre del titular
rib-field-address = Dirección
rib-field-establishment = Entidad
rib-field-branch = Oficina
rib-field-number = Número de cuenta
rib-field-key = Clave RIB
rib-field-bic = BIC (Bank Identifer Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Condiciones de uso importantes que deben respetarse obligatoriamente en caso de impresión
rib-declaration = Yo, el abajo firmante, usuario del software, declaro por mi honor:
rib-declaration-first = - Confirmo haber comprobado con mi banco que los datos bancarios que figuran en esta ventana son correctos y conformes a mi voluntad. Confirmo del mismo modo que me comprometo a comprobar que los datos que figuran en el informe impreso de los datos bancarios son correctos y conformes a mi voluntad. Esta impresión y el uso de los datos bancarios se harán bajo mi entera responsabilidad
rib-declaration-second = - Ser el titular de la cuenta cuyos datos bancarios se imprimirán, y no utilizar las funciones de este software con un fin contrario a la ley.
rib-title-print = Impresión en impresora
rib-title-pdf = Impresión en archivo PDF
rib-declaration-required = Marque la declaración de honor para poder imprimir.
rib-help = Compruebe sus datos, marque la declaración y, a continuación, imprima.
rib-account-gone = No se encuentra esta cuenta bancaria.
rib-fields-read-only = Estos datos proceden de la ficha de la cuenta: corríjalos en la ficha para cambiarlos aquí.
rib-printed = Datos bancarios enviados a su impresora predeterminada.
rib-print-failed = Impresión imposible: { $reason }
rib-pdf-done = Datos bancarios impresos y abiertos: «{ $file }».
rib-pdf-not-opened = Datos bancarios impresos en «{ $file }», pero su sistema no ha sabido abrirlo por sí solo.
menu-accounts-bank-details = Emitir los datos bancarios

print-choose-printer = ¿En qué impresora desea imprimir?
print-do-print = Imprimir
rib-printed-on = Datos bancarios enviados a la impresora «{ $printer }».
ui-cancel = Cancelar

print-printers-unknown = Su sistema no ha sabido nombrar ninguna impresora: el documento se ha enviado a la impresora predeterminada.

print-menu-operations-printer = Impresión en impresora
print-sent-on = Informe enviado a la impresora «{ $printer }».
print-sent-default = Informe enviado a su impresora predeterminada.

# --- Fase 17 — las operaciones sobre la base de datos -------------------
backup-archive = Archivo Radinus
backup-no-database = No hay ninguna base de datos abierta.
backup-done = La base «{ $base }» se ha guardado en «{ $file }». Las demás bases no se ven afectadas.
backup-failed = Copia de seguridad imposible: { $reason }
backup-not-started = No se ha podido iniciar la copia de seguridad:
restore-unreadable = Este archivo no es un archivo Radinus legible: { $reason }
restore-question = ¿Restaurar «{ $file }» en la base «{ $base }»? Todo el contenido actual de esta base se borrará y se sustituirá, y lo que allí se encuentre se perderá. Las demás bases no se tocan.
restore-done = La base «{ $base }» se ha restaurado: { $accounts } cuentas y { $operations } operaciones. Las demás bases no se tocan.
restore-failed = Restauración imposible: { $reason }
restore-empty-fields = Campos vacíos leídos como valor nulo: { $count }.


# --- El registro de las operaciones técnicas (fase 17) --------------------
journal-status-success = EXITO
journal-status-failure = FALLO
journal-status-repaired = REPARADO
journal-step-reindex = Reparación de la tabla de la base de datos
journal-step-refill = Nomenclatura del sistema vacía: valores predeterminados restablecidos
journal-step-table-created = Tabla ausente de la base de datos: recreada vacía
journal-step-column-added = Columna ausente de la tabla: añadida con su valor predeterminado

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Protección por contraseña
window-password-form-title = Protección por contraseña
password-ask = Esta base está protegida. Introduzca su contraseña.
password-group-database = Base afectada
password-group-password = Contraseña
password-group-warning = Antes de confirmar
password-field-old = Contraseña anterior
password-field-new = Nueva contraseña
password-field-repeat = Repita la nueva contraseña
password-hint = Deje la anterior vacía si la base aún no está protegida. Deje las dos nuevas vacías para retirar la protección.
password-lost-warning = Una contraseña perdida es una base perdida: nada permite recuperarla. Las copias de seguridad, en cambio, quedan sin cifrar.
password-show = Mostrar la contraseña
password-remove-question = ¿Retirar la protección de esta base?
password-mismatch = Las dos entradas de la nueva contraseña son diferentes
password-wrong = La contraseña no es correcta
database-too-recent = Esta base fue guardada por una versión más reciente de Radinus (versión de base { $found }; esta versión lee hasta la versión { $supported }). Actualice Radinus para abrirla.
database-not-radinus = Este archivo no es una base de Radinus.
database-unreadable = No se pudo leer la base: { $reason }
password-close-first = Cierre esta base antes de cambiar su contraseña
password-now-protected = La base está protegida por una contraseña
password-now-clear = La base ya no está protegida
journal-step-date-fixed = Corrección de una operación sin fecha
journal-step-circular = Supresión de una operación incoherente: referencia circular
journal-step-flag-parent-true = Indicador EstParent=Falso incorrecto en una operación principal
journal-step-flag-parent-false = Indicador EstParent=Verdadero incorrecto en una operación principal
journal-step-flag-child = Indicador EstParent=Verdadero incorrecto en un desglose
journal-step-orphan = Supresión de un desglose huérfano
journal-step-third-level = Supresión de un desglose vinculado a otro desglose
journal-step-coherence = Recálculo general de la coherencia entre los desgloses y las operaciones principales
journal-step-balances = Recálculo de todos los saldos de todas las cuentas
journal-step-vacuum = Optimización del archivo de la base de datos
journal-step-analyze = Actualización de las estadísticas de búsqueda
journal-step-backup-begin = Inicio de la copia de seguridad de la base
journal-step-backup-end = Fin de la copia de seguridad de la base
journal-step-restore-begin = Inicio de la restauración de la base a partir del archivo
journal-step-restore-end = Fin de la restauración de la base a partir del archivo
journal-step-restore-read = Lectura del archivo

# --- La ventana del registro (⌘H) -----------------------------------------
window-journal-title = Registro de la última operación técnica
journal-column-step = Etapa
journal-column-file = Archivo
journal-column-table = Tabla
journal-column-status = Estado
journal-column-error = Error
journal-column-comments = Comentarios
journal-empty = No se ha efectuado todavía ninguna operación técnica desde la apertura del software.
journal-help = El registro solo conserva la última operación técnica: copia de seguridad, restauración, reparación, borrado o apertura de una base.

# --- La reparación ------------------------------------------------------
menu-file-repair-running = Reparación y optimización en curso…
repair-done = { $anomalies ->
    [0] Reparación de la base «{ $base }» terminada: ninguna anomalía encontrada. { $lines } etapas registradas. Las demás bases no se ven afectadas.
    [one] Reparación de la base «{ $base }» terminada: una anomalía reparada. { $lines } etapas registradas. Las demás bases no se ven afectadas.
   *[other] Reparación de la base «{ $base }» terminada: { $anomalies } anomalías reparadas. { $lines } etapas registradas. Las demás bases no se ven afectadas.
}
repair-failed = Reparación imposible: { $reason }

journal-status-started = EN CURSO
journal-status-finished = TERMINADO
journal-step-backup-table = Escritura de la tabla en el archivo
journal-step-backup-write = Escritura del archivo
journal-step-backup-verified = Verificación del archivo escrito: archivos releídos / esperados, registros releídos / escritos
journal-step-backup-total = Total guardado: registros, datos, tamaño del archivo
journal-step-restore-table = Lectura de la tabla en el archivo
journal-step-restore-missing = Archivo ausente del archivo comprimido: esta tabla no se restaurará
journal-step-restore-wipe = Borrado total del contenido de la base antes de la restauración
journal-step-restore-write = Escritura en la base
journal-step-restore-total = Total restaurado: cuentas, operaciones
journal-step-restore-empty-fields = Campos vacíos completados durante la lectura
backup-verify-mismatch = El archivo escrito no se relee tal como fue escrito: no se fíe de él, rehaga la copia de seguridad.

# --- Los adjuntos de una operación (F28, fase 17) -----------------
window-attachments-title = Adjuntos de la operación
attachment-filter = Documentos aceptados
attachment-none = Esta operación no tiene ningún adjunto.
attachment-title-add = Adjuntar un documento a esta operación
attachment-title-open = Abrir el adjunto
attachment-title-remove = Retirar el adjunto y enviar su archivo a la papelera
attachment-state-ok = Intacto
attachment-state-changed = Modificado
attachment-state-missing = Archivo ausente
attachment-state-unknown = No verificable
attachment-added = «{ $name }» se ha adjuntado a la operación.
attachment-removed = Adjunto retirado, su archivo está en la papelera.
attachment-removed-kept = Adjunto retirado, pero su archivo no ha podido enviarse a la papelera.
attachment-remove-question = ¿Retirar «{ $name }» de esta operación? Su archivo se enviará a la papelera.
attachment-opened = «{ $name }» se ha abierto.
attachment-opened-changed = «{ $name }» se ha abierto, pero su contenido ha cambiado desde que se adjuntó.
attachment-gone = Este adjunto ya no existe.
attachment-file-missing = No se encuentra en el disco el archivo de «{ $name }».
attachment-failed = Operación imposible: { $reason }
attachment-save-first = Guarde primero la operación: un adjunto se vincula a una operación que existe.
attachment-refusal-missing = Este archivo no existe.
attachment-refusal-extension = Este tipo de archivo no se acepta. Se aceptan: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = La operación a la que adjuntar este documento no existe.
journal-step-backup-attachments = Adjuntos añadidos al archivo
journal-step-backup-attachment-missing = Adjunto no encontrado en el disco: faltará en el archivo
journal-step-restore-attachments = Adjuntos extraídos del archivo
attachment-title-replace = Sustituir el documento de este adjunto
attachment-replaced = El documento se ha sustituido por «{ $name }».

# ---------------------------------------------------------------------
# F08 — el menú « Herramientas » de la ficha de cuenta.
# ---------------------------------------------------------------------

account-tools = Herramientas
account-tools-initial-balance = Definir el saldo inicial conciliado
account-tools-statistics = Estadísticas de la cuenta bancaria
account-tools-delete-operations = Eliminar todas las operaciones de la cuenta

account-initial-balance-question =
    Para calcular el saldo inicial conciliado con respecto a las operaciones que ya tiene esta cuenta, indique el saldo actual de su banco
    El saldo inicial conciliado se calculará como:
    { "[" }saldo bancario actual] - [total de operaciones conciliadas ({ $total })].
    { "" }
    Para no tener que volver a introducir este importe, debe tener totalmente al día la lista de operaciones bancarias de esta cuenta.

account-statistics-none = Ninguna operación

account-statistics =
    Número total de operaciones en esta cuenta: { $count }
    { "" }
    Número de operaciones conciliadas en esta cuenta: { $pointed }
    Importe de los cargos conciliados: { $pointedDebits }
    Importe de los abonos conciliados: { $pointedCredits }
    Diferencia entre abonos y cargos conciliados: { $pointedDifference }
    { "" }
    Número de operaciones comprometidas en esta cuenta: { $committed }
    Importe de los cargos comprometidos: { $committedDebits }
    Importe de los abonos comprometidos: { $committedCredits }
    Diferencia entre abonos y cargos comprometidos: { $committedDifference }
    { "" }
    Número de operaciones previstas en esta cuenta: { $planned }
    Importe de los cargos previstos: { $plannedDebits }
    Importe de los abonos previstos: { $plannedCredits }
    Diferencia entre abonos y cargos previstos: { $plannedDifference }
    { "" }
    Operación más antigua: { $first }
    Operación más reciente: { $last }

account-delete-operations-question =
    ¿Está seguro de que desea eliminar todas las operaciones de esta cuenta bancaria?
    Para confirmarlo, escriba { $word } en el campo de abajo y valide

account-delete-operations-done =
    { $count ->
        [0] Ninguna operación eliminada.
        [one] 1 operación eliminada.
       *[other] { $count } operaciones eliminadas.
    }

# ---------------------------------------------------------------------
# El selector de base y la elección del idioma (02/08/2026)
#
# Decisiones tomadas con Fabrice: Radinus ya no crea una base sin
# autorización; sin idioma en la configuración, pregunta el idioma antes
# que nada; es una base toda carpeta de databases/ que contiene un
# radinus.sqlite, sea cual sea su nombre.
#
# La ventana de elección del idioma no tiene ninguna clave aquí: no
# emplea ninguna frase, y es eso lo que le permite ser comprendida antes
# de que se sepa qué idioma habla el usuario.
# ---------------------------------------------------------------------

window-database-selector-title = Bases de datos
window-database-form-title = Nueva base de datos
database-group-identity = Identificación de la base de datos
database-group-restore = Inicializar la base con los datos de una copia de seguridad
database-choose-backup = Seleccionar archivo de copia
database-no-backup = Ninguna copia elegida: la base nacerá vacía.

databases-column-label = Base
databases-column-comment = Comentario
databases-column-folder = Carpeta
databases-column-created = Creada el

databases-none = Ninguna base por ahora: cree una.
databases-help = Elija la base que desea abrir, o cree una nueva.
databases-select = Elija primero una base de la lista.
databases-tools = Herramientas
databases-title-open = Abrir esta base

database-created = La base «{ $label }» está creada.
database-field-label = Nombre de la base
database-field-comment = Comentario
database-label-required = Dé un nombre a esta base: es lo que la distinguirá de las demás.
database-gone = Esta base ya no está: se movió o se eliminó desde que se abrió esta ventana.

# La eliminación de una base (02/08/2026). La carpeta va a la papelera del
# sistema, como los archivos adjuntos: una base eliminada por error se
# restaura con un clic. La base abierta se rechaza — Radinus tiene su archivo.
databases-title-delete = Eliminar esta base
database-delete-question =
    ¿Está seguro de que desea eliminar la base «{ $label }»?
    { "" }
    Toda su carpeta va a la papelera: las operaciones, las cuentas y los archivos adjuntos.
    Para confirmarlo, escriba { $word } en el campo de abajo y valide.
database-in-use = Esta base está abierta: Radinus no puede eliminarla. Abra otra primero.
database-deleted = La base «{ $label }» está en la papelera.

# El selector tiene dos modos (Fabrice, 02/08/2026). Abierto mientras Radinus
# funciona, ya no sabe abrir: una ventana de Radinus se construye una vez y
# nunca se destruye, y nada podría hacerle olvidar la base que muestra. Se
# consulta, se crea, se elimina — y para cambiar de base, se sale.
database-quit-first = Para abrir esta base, salga de Radinus y vuelva a iniciarlo: el selector se la propondrá al arrancar.


# --- F01 — la ventana de bienvenida (fase 17 bis, 03/08/2026) -------------
#
# Lo primero que 2.0.0 tiene y 1.9.3 no tenía: la ventana de bienvenida ya no
# lleva solo su cartel. La regla que la gobierna está en el documento 04 F01:
# es la vista SIN UN CLIC, y nada que necesite un ajuste entra en ella.
#
# Los dos títulos de anillo llevan el mes entero en vez de ser pegados por la
# ventana: el orden de las palabras no es el mismo en los tres idiomas, y solo
# Fluent sabe dónde está el hueco.

window-main-title = Radinus
welcome-month = { $month } de { $year }
welcome-accounts-count = { $count ->
    [0] Ninguna cuenta abierta
    [one] 1 cuenta abierta
   *[other] { $count } cuentas abiertas
}
welcome-total-bank = Saldo en banco
welcome-total-real = Saldo real
welcome-total-final = Saldo final
welcome-total-real-detail = conciliado + comprometido
welcome-total-final-detail = conciliado + comprometido + previsto
welcome-accounts = Sus cuentas
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Cuentas contadas en los totales: { $count } de { $total }
welcome-tile-counted = Contar esta cuenta en los totales
welcome-tile-bank = En banco
welcome-tile-real = Real
welcome-tile-final = Final
welcome-spending = Gastos — { $month }
welcome-earning = Ingresos — { $month }
ui-legend-budget-lines = Partidas presupuestarias
ui-legend-categories = Categorías
welcome-nothing = Ninguna operación este mes.
welcome-open-account = Info: haga clic en una cuenta para abrir sus operaciones.
welcome-no-account = Todavía no hay ninguna cuenta bancaria.
welcome-no-account-create = Cree una cuenta bancaria haciendo clic aquí
welcome-previous-month = Mes anterior
welcome-next-month = Mes siguiente
welcome-refresh = Volver a leer todo


# --- F39 — las preferencias (fase 17 ter, 03/08/2026) ---------------------
#
# El lugar del signo monetario vive aquí, junto a los dos separadores: sigue
# al idioma y no a la moneda. « before » pone el signo delante del número,
# cualquier otro valor lo pone detrás. NINGÚN signo monetario se escribe en
# este archivo: « español » no quiere decir « euro ».

ui-money-sign-position = after
window-preferences-title = Preferencias
menu-settings-preferences = Preferencias…
menu-settings-show-main = Mostrar la ventana principal
menu-settings-folders = Carpetas de Radinus
preferences-branch-display = Presentación
preferences-leaf-language = Idioma
preferences-leaf-currency = Moneda
preferences-field-language = Idioma del programa:
preferences-field-currency = Moneda mostrada:
preferences-field-custom = Signo de la moneda:
preferences-currency-system = Moneda del sistema
preferences-currency-euro = Euros
preferences-currency-dollar = Dólares
preferences-currency-canadian = Dólares canadienses
preferences-currency-cfa = Francos CFA
preferences-currency-cfp = Francos CFP
preferences-currency-swiss = Francos suizos
preferences-currency-none = Ninguna
preferences-currency-custom = Personalizado
preferences-currency-system-is = Su sistema anuncia:
preferences-currency-system-silent = Su sistema no anuncia ninguna moneda: los importes se mostrarán en euros.
preferences-custom-required = Escriba el signo de su moneda antes de guardar.
preferences-saved = Preferencias guardadas.
preferences-help = Elija una opción en el árbol y guarde.
preferences-sign-too-long = El signo de una moneda ocupa 8 caracteres como máximo.
preferences-sign-not-a-number = El signo de una moneda no puede llevar cifras, ni signos de cálculo, ni comas: Radinus los quita al leer un importe, y « 120 » se convertiría en « 12 ».
preferences-leaf-zoom = Tamaño de la presentación
preferences-field-zoom = Ampliación:
preferences-zoom-reset = Valor por defecto
preferences-zoom-hint = Todo crece a la vez: el texto, los iconos, las columnas. Por debajo del 100 %, cabe más en la pantalla. La barra de menús del sistema y sus diálogos siguen los ajustes de su ordenador, no estos.
preferences-branch-import = Importación
preferences-leaf-verification = Verificación
preferences-field-verification = Operaciones importadas:
preferences-verification-hint = «Verificada»: confía en su banco, una operación importada se da por buena. «Por verificar»: cada operación importada espera su control; después usted mismo la pasa a «Verificada» en la lista de operaciones. Este ajuste solo se aplica a las importaciones futuras.
preferences-leaf-ofx = Extractos OFX
preferences-field-ofx-label = Concepto de la operación:
preferences-field-ofx-reference = Referencia del pago:
preferences-ofx-choice-name = El nombre de la operación
preferences-ofx-choice-memo = El memo del banco
preferences-ofx-choice-name-and-memo = El nombre seguido del memo
preferences-ofx-choice-empty = Nada (dejar vacío)
preferences-ofx-label-help = Lo que recibe el concepto de una operación importada. El nombre es el que muestra el banco, por ejemplo «PRLV SEPA»; algunos bancos añaden un memo detallado: el acreedor de un recibo domiciliado, el beneficiario y el motivo de una transferencia. Cuando una operación no tiene memo, su concepto conserva el nombre.
preferences-ofx-reference-help = Lo que recibe la referencia del pago de una operación importada, donde puede verla y filtrarla. Cuando una operación no tiene memo, «El memo del banco» deja la referencia vacía. Si el memo ya repite el nombre, no se escribe dos veces.
preferences-ofx-hint = Estos ajustes valen para todos los extractos OFX, sea cual sea la base de datos abierta. Se aplican al próximo extracto que se abra.
preferences-leaf-qif = Extractos QIF
preferences-field-qif-order = Orden del día y del mes:
preferences-qif-order-ask = Preguntarme cada vez
preferences-qif-order-day-month = Siempre día/mes (05/03 = 5 de marzo)
preferences-qif-order-month-day = Siempre mes/día (05/03 = 3 de mayo)
preferences-qif-order-help = Solo se usa si ninguna fecha del archivo permite decidir. En cuanto una fecha como 24/11 demuestra el orden, decide el archivo, sea cual sea este ajuste.
preferences-field-qif-label = Concepto de la operación:
preferences-qif-label-both = Beneficiario + memo
preferences-qif-label-payee = Solo beneficiario
preferences-qif-label-memo = Solo memo
preferences-qif-label-help = Cuando una operación lleva a la vez un beneficiario y un memo. Si solo lleva uno, se usa ese, sea cual sea este ajuste.
preferences-qif-hint = Estos ajustes valen para todos los extractos QIF, sea cual sea la base de datos abierta. «Preguntarme cada vez» es lo más seguro: un archivo con fechas ambiguas nunca se lee al azar.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Restablecer las columnas por defecto
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Mostrar/Ocultar
columns-colour = Colorear la columna:
columns-colour-none = Sin color
columns-colour-red = Rojo
columns-colour-orange = Naranja
columns-colour-pink = Rosa
columns-colour-pastel-green = Verde pastel
columns-colour-green = Verde
columns-colour-pastel-blue = Azul pastel
columns-colour-blue = Azul
columns-colour-pastel-yellow = Amarillo pastel
columns-colour-yellow = Amarillo
preferences-leaf-columns = Columnas de las tablas
preferences-table-operations-list = Lista de operaciones
preferences-columns-reset = Restablecer
preferences-columns-reset-all = Restablecer todo
preferences-columns-done = Las columnas han recuperado su disposición original.
preferences-columns-hint = Cada tabla recuerda el orden de sus columnas, las que usted oculta y su anchura. «Restablecer» le devuelve su disposición original, de inmediato.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Restablecimiento
preferences-leaf-comfort = Ajustes de comodidad
preferences-comfort-reset = Restablecer los ajustes de comodidad
preferences-comfort-hint = Devuelve a su estado original las columnas de todas las tablas, el orden y las casillas de las cuentas de la ventana de inicio, y el tamaño de la presentación. El idioma, la moneda y la verificación de las operaciones importadas no se tocan.
preferences-comfort-question = ¿Restablecer los ajustes de comodidad? Las columnas de las tablas, la ventana de inicio y el tamaño de la presentación volverán a su estado original.
preferences-comfort-done = Se han restablecido los ajustes de comodidad.

# --- Le bandeau de l'accueil ---------------------------------------------
#
# Ces phrases étaient écrites en dur dans `index.html` depuis la phase 0 et
# ne se traduisaient donc pas (relevé par Fabrice le 03/08/2026). La devise
# est sa voix : les versions anglaise et espagnole sont des propositions, à
# corriger par lui — un slogan ne se traduit pas mot à mot.
ui-language-tag = es
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — la ardilla mascota, de traje, entre un signo de euro, una calculadora y gráficos
welcome-slogan-one = Un programa de gestión de finanzas personales que le ayuda a gastar menos para ganar más
welcome-slogan-two = Con Radinus entenderá por qué los pequeños arroyos forman los grandes ríos.

# --- « À propos de l'auteur » --------------------------------------------
#
# Le nom et l'adresse sont écrits à l'identique dans les trois fichiers : ils
# ne se traduisent pas. Ils sont ici malgré tout, et non dans la page, pour que
# la vue ne porte aucune phrase — et pour qu'ils se corrigent à un seul endroit
# le jour où l'auteur déménage.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Acerca del autor
about-author-flag-alt = Bandera de Córcega — la cabeza de moro

# --- « À propos de Radinus » ---------------------------------------------
#
# `about-radinus-version` porte un trou : le numéro vient du binaire qui
# tourne, jamais d'une chaîne recopiée. Elle n'est donc pas dans le
# dictionnaire des fenêtres — c'est la commande `app_version` qui la remplit.
window-about-radinus-title = Acerca de Radinus
about-radinus-name = Radinus
about-radinus-version = Versión { $version }
about-radinus-rust-alt = El logotipo del lenguaje Rust
about-radinus-tauri-alt = El logotipo de Tauri
about-radinus-built = Radinus está escrito en Rust y construido con Tauri. El primero calcula sus cuentas, el segundo hace de ello una aplicación de escritorio.
about-radinus-licence = Software libre, bajo licencia GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Licencia de uso
licence-heading = LICENCIA DE USO DEL PROGRAMA RADINUS
licence-logo-alt = El logotipo de la GNU General Public License versión 3
licence-name = GNU GPL v3 o posterior
licence-intro = Radinus es software libre.
licence-freedoms-title = Su licencia le concede cuatro libertades:
licence-freedom-use = Usarlo como quiera, para lo que quiera.
licence-freedom-study = Estudiar su código fuente, abierto a todos.
licence-freedom-share = Copiarlo y entregarlo a quien quiera.
licence-freedom-improve = Modificarlo y compartir sus modificaciones.
licence-read = Leer el texto completo de la licencia

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Este programa se ofrece sin ninguna garantía, en la medida permitida por la ley.
licence-info = El texto oficial se abre en su navegador, en gnu.org.

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Simulación de préstamo
window-loan-title = Simulación de préstamo
loan-tab-credit = El préstamo
loan-tab-afford = ¿Puedo devolverlo?
loan-field-kind = Tipo de préstamo
loan-kind-consumer = Préstamo al consumo
loan-kind-mortgage = Préstamo hipotecario
loan-field-amount = Importe prestado
loan-field-payment = Cuota mensual
loan-field-months = Plazo
loan-field-rate = Tipo de interés fijo
loan-field-fees = Gastos de apertura
loan-field-insurance = Seguro al mes
loan-unit-months = meses
loan-unit-percent = %
loan-invalid-field = Este valor no es un número: corríjalo para relanzar el cálculo.
loan-report-button = Informe PDF
loan-monthly-table = Cuadro mes a mes
loan-months-count = { $count ->
        [one] { $count } mes
       *[other] { $count } meses
    }
loan-percent = { $value } %
loan-notice-payment-too-low = Esta cuota no cubre los intereses: el préstamo nunca se devolvería. El plazo se queda en 600 meses.
loan-notice-too-long = Esta cuota requeriría más de 600 meses: el plazo se queda en 600 meses.
loan-figure-payment = Cuota mensual
loan-figure-payment-insured = Cuota con seguro
loan-figure-taeg = TAE
loan-figure-interest = Coste de los intereses
loan-figure-insurance = Coste del seguro
loan-figure-cost = Coste total del préstamo
loan-figure-total-due = Importe total adeudado
loan-figure-all-in = Total devuelto, seguro incluido
loan-part-capital = Importe prestado
loan-part-interest = Intereses
loan-part-fees = Gastos de apertura
loan-part-insurance = Seguro
loan-donut-cost-caption = en total
loan-chart-cost = Lo que cuesta este préstamo
loan-chart-capital = Capital pendiente
loan-schedule-title = Cuadro de amortización
loan-schedule-yearly = Cuadro de amortización, año por año
loan-column-number = N.º
loan-column-year = Año
loan-column-date = Vencimiento
loan-column-payment = Cuota
loan-column-payments = Cuotas
loan-column-interest = Intereses
loan-column-capital = Capital
loan-column-insurance = Seguro
loan-column-remaining = Capital pendiente
loan-history-label = Periodo estudiado
loan-period-last-12 = Últimos 12 meses
loan-accounts-title = Cuentas estudiadas
loan-period-title = Periodo
loan-column-account = Cuenta
loan-column-bank = Banco
loan-column-balance = Saldo real
loan-unavailable-no-account = Marque al menos una cuenta para estudiar su historial.
loan-unavailable-no-month = Este periodo aún no tiene ningún mes completo: elija otro.
loan-verdict-title = En resumen
loan-verdict-green = Viable
loan-verdict-orange = Justo
loan-verdict-red = Arriesgado
loan-verdict-no-income = Ningún ingreso en este periodo: el endeudamiento no se puede calcular.
loan-check-debt-green = Endeudamiento del { $ratio }: por debajo del umbral del { $green } de este método.
loan-check-debt-orange = Endeudamiento del { $ratio }: entre el { $green } y el { $red }, en el límite.
loan-check-debt-red = Endeudamiento del { $ratio }: por encima del { $red }.
loan-check-effort = La cuota de { $payment } se lleva el { $share } de lo que ahorra en { $kind ->
        [good] un buen mes
        [hard] un mes difícil
       *[usual] un mes normal
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Un buen mes
        [hard] Un mes difícil
       *[usual] Un mes normal
    } no le deja nada ahorrado: la cuota de { $payment } saldría de su reserva.
loan-check-reserve-green = Su saldo sigue siendo positivo hasta el final del préstamo.
loan-check-reserve-red = Su saldo bajaría de cero en { $month }, a causa de este préstamo.
loan-check-reserve-sooner = Su saldo bajaría de cero en { $month }, { $count ->
        [one] un mes
       *[other] { $count } meses
    } antes que sin este préstamo.
loan-check-reserve-anyway = Su saldo bajaría de cero hacia { $month } incluso sin este préstamo, que apenas cambia nada.
loan-check-reserve-floor-green = Su saldo se mantiene por encima de su reserva de seguridad ({ $floor }) hasta el final del préstamo.
loan-check-reserve-floor-red = Su saldo bajaría de su reserva de seguridad ({ $floor }) en { $month }, a causa de este préstamo.
loan-check-reserve-floor-sooner = Su saldo bajaría de su reserva de seguridad ({ $floor }) en { $month }, { $count ->
        [one] un mes
       *[other] { $count } meses
    } antes que sin este préstamo.
loan-check-reserve-floor-anyway = Su saldo bajaría de su reserva de seguridad ({ $floor }) hacia { $month } incluso sin este préstamo, que apenas cambia nada.
loan-warning-deficit = Atención: en este periodo, sus gastos ya superan sus ingresos en { $amount } al mes de media, antes de cualquier préstamo.
loan-figure-reference = Ahorro de { $kind ->
        [good] un buen mes
        [hard] un mes difícil
       *[usual] un mes normal
    }
loan-figure-tipped = Meses que el préstamo pondría en números rojos
loan-gauge-caption = de endeudamiento
loan-figure-income = Ingresos medios al mes
loan-figure-spending = Gastos medios al mes
loan-figure-saving = Ahorro medio al mes
loan-figure-running = Préstamos en curso al mes
loan-figure-new = Nueva cuota, seguro incluido
loan-figure-rest = Para vivir al mes
loan-figure-debt = Tasa de endeudamiento
loan-red-months-value = { $count } de { $total }
loan-figure-balance-now = Saldo real hoy
loan-figure-balance-end = Saldo previsto al final del préstamo
loan-chart-income = Adónde va su ingreso medio
loan-donut-income-caption = ingreso medio
loan-part-spending = Gastos corrientes
loan-part-running = Préstamos en curso
loan-part-new = Nuevo préstamo
loan-part-rest = Resto
loan-part-missing = Falta
loan-chart-history = Su historial con este préstamo
loan-chart-history-hint = Lo que habría quedado cada mes, pagada la cuota. En rojo vivo, los meses que el préstamo pondría en números rojos; en rojo pálido, los que ya lo estaban sin él.
loan-chart-projection = Su saldo previsto
loan-mark-loan-end = Fin: { $label }
loan-mark-negative = En números rojos
loan-mark-floor = Bajo la reserva
loan-mark-floor-line = Reserva de seguridad
loan-running-title = Préstamos en curso considerados
loan-running-column-label = Operación periódica
loan-running-column-monthly = Al mes
loan-running-column-end = Último vencimiento
loan-no-running = No se ha reconocido ningún préstamo en curso entre sus operaciones periódicas.
loan-period-caption = de { $from } a { $to } ({ $count ->
        [one] { $count } mes
       *[other] { $count } meses
    })
loan-transfers = { $count ->
        [0] No se ha reconocido ninguna transferencia entre sus cuentas marcadas.
        [one] Se ha reconocido y apartado una transferencia entre sus cuentas marcadas.
       *[other] Se han reconocido y apartado { $count } transferencias entre sus cuentas marcadas.
    }
loan-method = Medias sobre los meses completos del periodo, operaciones punteadas y comprometidas, sin las transferencias entre sus cuentas marcadas.
loan-report-title = Simulación de préstamo
loan-report-made-on = simulación del { $date }
loan-disclaimer = Simulación orientativa, sin valor contractual. Solo la oferta del banco es vinculante.
loan-tab-rules = Ajustes del juicio
loan-method-optimistic = Optimista
loan-method-neutral = Neutro
loan-method-severe = Severo
loan-method-line = Método de juicio: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = El veredicto responde a tres preguntas, y cada método pone sus propias exigencias. Elija el que se le parezca: el veredicto de la pestaña «¿Puedo devolverlo?» lo sigue. La última línea supone que sus gastos aumentan cada año el porcentaje indicado; la cuota no cambia.
loan-rule-row-debt = Endeudamiento aceptado
loan-rule-row-reference = Ahorro de referencia
loan-rule-row-share = Parte de ese ahorro que puede llevarse la cuota
loan-rule-row-floor = Umbral que el saldo no debe cruzar
loan-rule-row-sooner = Si el saldo lo cruza incluso sin el préstamo
loan-rule-row-growth = Aumento de sus gastos al año
loan-rule-limits = verde hasta el { $green }, naranja hasta el { $red }
loan-rule-reference = { $kind ->
        [good] un buen mes
        [hard] un mes difícil
       *[usual] un mes normal
    }: { $amount }
loan-rule-floor-zero = cero
loan-rule-floor-cushion = un mes de gastos: { $amount }
loan-rule-sooner = naranja si lo adelanta { $orange }, rojo si lo adelanta { $red }
loan-unit-percent-year = % al año
loan-method-optimistic-explain = El método optimista supone un buen mes, acepta un endeudamiento de hasta el 40 % y no guarda reserva: dice lo que es posible si todo va bien.
loan-method-neutral-explain = El método neutro supone un mes normal y sigue la regla de los bancos, del 33 al 35 % de endeudamiento: es el juicio de referencia.
loan-method-severe-explain = El método severo supone un mes difícil y guarda un mes de gastos de reserva para un imprevisto: dice lo que aguanta aunque las cosas vayan mal.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Consumo de un aparato eléctrico
window-appliance-title = Consumo de un aparato eléctrico
appliance-device-title = El aparato
appliance-on-title = Encendido
appliance-standby-title = En modo de espera
appliance-field-on-watts = Potencia en funcionamiento
appliance-field-on-hours = Tiempo de funcionamiento al día
appliance-field-days = Días de uso por semana
appliance-field-share = Parte del funcionamiento en horas valle
appliance-field-standby-watts = Potencia en modo de espera
appliance-field-standby-hours = Tiempo en espera por día de uso
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = de 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Si se deja vacío, el modo de espera dura el resto del día. Los días sin uso, el aparato sigue enchufado: todo ese tiempo cuenta como espera. Desenchufado, su consumo en espera es de 0 W.
appliance-contract-title = Su contrato
appliance-field-option = Opción tarifaria
appliance-option-base = Base (precio único)
appliance-option-off-peak = Horas punta / Horas valle
appliance-field-base = Precio del kWh
appliance-field-peak = Precio del kWh en horas punta
appliance-field-off-peak = Precio del kWh en horas valle
appliance-field-off-peak-hours = Horas valle al día
appliance-contract-hint = Estos precios solo valen para este cálculo. La tarifa guardada se configura en Configuración › Preferencias › Herramientas.
appliance-contract-reset = Volver a la tarifa guardada
appliance-period-day = Por día
appliance-period-month = Por mes
appliance-period-year = Por año
appliance-energy = { $value } kWh
appliance-less-than = menos de { $amount }
appliance-detail-title = El detalle de un año
appliance-column-part = Concepto
appliance-column-energy = Energía
appliance-column-cost = Coste
appliance-column-share = Proporción
appliance-line-on = Encendido
appliance-line-standby = En modo de espera
appliance-line-on-peak = Encendido, horas punta
appliance-line-on-off-peak = Encendido, horas valle
appliance-line-standby-peak = En modo de espera, horas punta
appliance-line-standby-off-peak = En modo de espera, horas valle
appliance-line-total = Total
appliance-chart-title = Adónde va el dinero
appliance-chart-caption = al año
appliance-standby-sentence = Solo el modo de espera cuesta { $amount } al año: { $share } de lo que cuesta el aparato.
appliance-note-plate = La potencia indicada en el aparato o en su manual es un máximo: en funcionamiento, la mayoría de los aparatos consumen menos. Para obtener una cifra real, mídala con un enchufe medidor de consumo e introduzca lo que indique.
appliance-note-subscription = La cuota fija no se cuenta: se paga esté o no enchufado el aparato.
appliance-invalid-watts = Introduzca una potencia de 0 a 100 000 W, por favor.
appliance-invalid-hours = Introduzca una duración de 0 a 24 horas al día, por favor.
appliance-invalid-days = Introduzca un número entero de días, de 0 a 7, por favor.
appliance-invalid-share = Introduzca una proporción de 0 a 100 %, por favor.
appliance-invalid-day-overflow = El funcionamiento y el modo de espera superan las 24 horas al día.
appliance-invalid-price = Introduzca un precio del kWh de 0 a 100, por favor.
appliance-invalid-off-peak-hours = Introduzca un número entero de horas valle, de 0 a 24, por favor.
preferences-branch-tools = Herramientas
preferences-leaf-electricity = Tarifa eléctrica
preferences-electricity-blue = Volver al Tarif Bleu de EDF
preferences-electricity-hint = La tarifa de su contrato, que usa la herramienta «Consumo de un aparato eléctrico». Por defecto: el Tarif Bleu de EDF (Francia) a 1 de agosto de 2026, precios con impuestos incluidos, contador de 3 a 6 kVA. Estos precios suelen cambiar en febrero y en agosto: copie los de su factura.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = Mi colchón de seguridad
window-cushion-title = Mi colchón de seguridad
cushion-question = Si sus ingresos se detuvieran mañana, ¿cuántos meses aguantaría con sus ahorros?
cushion-accounts-title = Sus cuentas
cushion-column-account = Cuenta
cushion-column-balance = Saldo real
cushion-column-savings = Ahorro
cushion-column-spending = Gastos
cushion-accounts-hint = «Ahorro»: el dinero con el que cuenta en caso de apuro. «Gastos»: las cuentas de las que salen los gastos del día a día.
cushion-history-label = Período analizado
cushion-backup-label = Ingreso de respaldo al mes
cushion-backup-hint = Lo que seguiría entrando: prestación por desempleo, sueldo de la pareja… Vacío: ningún ingreso.
cushion-categories-title = Gastos considerados
cushion-categories-hint = Desmarque lo que recortaría en caso de apuro.
cushion-categories-empty = Ningún gasto en este período.
cushion-verdict-title = Su colchón
cushion-targets-title = Los umbrales de prudencia
cushion-projection-title = Sus ahorros en caso de apuro
cushion-projection-hint = Lo que quedaría cada mes si sus ingresos se detuvieran hoy.
cushion-note = Una estimación basada en su historial: los gastos de un mes difícil pueden diferir de la media.
cushion-invalid-backup = Este importe no se puede leer: corríjalo para volver a calcular.
cushion-no-spending-account = Marque al menos una cuenta «Gastos».
cushion-no-month = Este período aún no tiene ningún mes completo.
cushion-months = { $value } meses
cushion-per-month = { $amount } al mes
cushion-figure-holds = Sin límite
cushion-gauge-caption = de gastos cubiertos
cushion-verdict-short = Menos de tres meses: un revés le pondría rápidamente en dificultades.
cushion-verdict-fair = Entre tres y seis meses: un colchón aceptable, que conviene reforzar si puede.
cushion-verdict-solid = Seis meses o más: su colchón es sólido.
cushion-verdict-holds = Su ingreso de respaldo cubre sus gastos: sus ahorros no disminuirían.
cushion-verdict-nothing = Ningún gasto considerado en el período: no hay nada que cubrir.
cushion-tile-savings = Ahorro disponible
cushion-tile-spending = Gastos considerados
cushion-tile-backup = Ingreso de respaldo
cushion-tile-burn = El ahorro disminuiría en
cushion-tile-rhythm = Ritmo de ahorro
cushion-burn-none = Nada
cushion-target-title = { $months } meses de gastos: { $amount }
cushion-target-reached = Alcanzado.
cushion-target-date = Faltan { $missing }. A su ritmo de ahorro, se alcanzaría hacia { $month }.
cushion-target-never = Faltan { $missing }. Su ahorro no ha crecido en el período: a este ritmo, este umbral no se alcanzará.
cushion-mark-empty = Agotado: { $month }
cushion-period = Media de { $count ->
        [one] { $count } mes completo
       *[other] { $count } meses completos
    }, de { $from } a { $to }. { $transfers ->
        [0] Ninguna transferencia entre sus cuentas.
        [one] Una transferencia entre sus cuentas, excluida del cálculo.
       *[other] { $transfers } transferencias entre sus cuentas, excluidas del cálculo.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Objetivo de ahorro
window-goal-title = Objetivo de ahorro
goal-accounts-title = Las cuentas seguidas
goal-column-account = Cuenta
goal-column-balance = Saldo real
goal-accounts-hint = Una transferencia entre dos cuentas seguidas se anula; una transferencia a una cuenta no seguida cuenta como una salida.
goal-period-label = Período de referencia
goal-period-range = Rango de años…
goal-range-from = de
goal-range-to = a
goal-question-title = Su pregunta
goal-question-when = ¿Cuándo tendré este importe?
goal-question-amount = ¿Cuánto tendré en esta fecha?
goal-question-effort = ¿Cuánto ahorrar para tener este importe en esta fecha?
goal-field-target = Importe objetivo
goal-field-date = Fecha objetivo
goal-field-rate = Tipo de interés anual del ahorro
goal-field-extra = Y si ahorrara más, al mes
goal-options-hint = Vacíos: ningún interés, nada más.
goal-answer-title = La respuesta
goal-chart-title = Su saldo, ayer y mañana
goal-chart-hint = En línea continua, el saldo real de los últimos doce meses; en punteado, la proyección; en claro, el rango según los meses.
goal-disclaimer = Una proyección basada en su historial, no una promesa: un imprevisto puede cambiarlo todo.
goal-no-account = Marque al menos una cuenta que seguir.
goal-no-month = Este período aún no tiene ningún mes completo.
goal-invalid-target = Un importe que alcanzar, por favor.
goal-invalid-date = Una fecha futura, dentro de los próximos cincuenta años, por favor.
goal-invalid-rate = Un tipo de 0 a 100 %, por favor.
goal-invalid-extra = Este importe no se puede leer: corríjalo para volver a calcular.
goal-per-month = { $amount } al mes
goal-tile-balance = Saldo hoy
goal-tile-rhythm = Ritmo medio
goal-tile-target = Objetivo
goal-tile-reached = Alcanzado hacia
goal-tile-date = Fecha objetivo
goal-tile-projected = Saldo proyectado
goal-tile-saved = Ahorrado hasta entonces
goal-tile-interest = De ello, intereses
goal-tile-needed = Por ahorrar
goal-when-already = Ya tiene { $amount }: sus cuentas seguidas suman { $balance }.
goal-when-reached = Tendrá { $amount } hacia { $month }, dentro de { $months ->
        [one] un mes
       *[other] { $months } meses
    }.
goal-when-range = Según los meses, entre { $early } y { $late }.
goal-when-range-open = Como muy pronto hacia { $early }; con meses flojos, el objetivo no se alcanzaría.
goal-when-never = A este ritmo, no alcanzará { $amount }.
goal-zero = Su saldo caería a cero hacia { $month }.
goal-amount = En { $month }, tendría aproximadamente { $amount }.
goal-amount-range = Según los meses, entre { $low } y { $high }.
goal-effort-more = Para tener { $amount } en { $month }, habría que ahorrar de media { $monthly } al mes, es decir, { $gap } más que hoy.
goal-effort-less = Para tener { $amount } en { $month }, bastarían { $monthly } al mes, es decir, { $gap } menos que hoy: va por delante.
goal-effort-range = Según los meses, la diferencia con su ritmo iría de { $low } a { $high } al mes.
goal-chart-target = Objetivo: { $amount }
goal-chart-today = Hoy
goal-note-seasons = La proyección sigue las estaciones: cada mes futuro toma la media de los mismos meses del período.
goal-note-range = El rango procede de los meses flojos y de los meses fuertes del período: el cuarto más bajo y el cuarto más alto.
goal-note-loan = El préstamo «{ $label }» termina en { $month }: { $amount } más al mes a partir de entonces.
goal-note-interest = Intereses calculados cada mes al tipo de { $rate } % anual: una aproximación de la regla de las quincenas de las cuentas de ahorro.
goal-period = Ritmo calculado sobre { $count ->
        [one] { $count } mes completo
       *[other] { $count } meses completos
    }, de { $from } a { $to }. { $transfers ->
        [0] Ninguna transferencia entre sus cuentas seguidas.
        [one] Una transferencia entre sus cuentas seguidas, neutralizada.
       *[other] { $transfers } transferencias entre sus cuentas seguidas, neutralizadas.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = ¿Y si reduzco…?
window-cut-title = ¿Y si reduzco…?
cut-axis-label = Agrupar por
cut-axis-category = Categorías
cut-axis-payee = Beneficiarios
cut-axis-budget-line = Partidas presupuestarias
cut-table-title = Sus gastos, partida por partida
cut-table-hint = Escriba una reducción en % o en { $sign } al mes en las partidas que quisiera aligerar. Una reducción no puede superar el propio gasto.
cut-column-monthly = Al mes
cut-column-cut = Reducción
cut-column-after = Después
cut-column-yearly = Ahorro al año
cut-total = Total
cut-horizon-label = Horizonte
cut-settings-title = Ajustes
cut-options-hint = El tipo y el importe objetivo son opcionales.
cut-report-button = Informe PDF
cut-chart-title = Su saldo, sin y con las reducciones
cut-chart-hint = En línea continua, el saldo real de los últimos doce meses; en punteado gris, la proyección sin reducción; en azul, con ellas; en verde, el dinero ganado.
cut-donut-title = Sus gastos mensuales tras la reducción
cut-donut-caption = al mes tras la reducción
cut-donut-others = Otras partidas
cut-donut-saved = Ahorrado
cut-legend-with = Con las reducciones
cut-legend-without = Sin reducción
cut-years = { $years ->
        [one] { $years } año
       *[other] { $years } años
    }
cut-headline-none = Escriba una reducción en la tabla para ver su efecto.
cut-headline = Reduciendo { $count ->
        [one] esta partida
       *[other] estas { $count } partidas
    }, apartaría { $monthly } más al mes, es decir, { $yearly } al año.
cut-tile-monthly = Ahorro al mes
cut-tile-yearly = Ahorro al año
cut-tile-horizon = Ahorro en { $years ->
        [one] { $years } año
       *[other] { $years } años
    }
cut-tile-spending = Gastos al mes
cut-target-already = Ya tiene { $amount }.
cut-target-sooner = Alcanzaría { $amount } hacia { $with } en lugar de { $without }: { $months ->
        [0] no antes
        [one] un mes antes
       *[other] { $months } meses antes
    }.
cut-target-only-with = Con estas reducciones, alcanzaría { $amount } hacia { $with }; sin ellas, a su ritmo actual, nunca.
cut-target-never = Incluso con estas reducciones, no alcanzaría { $amount } a su ritmo actual.
cut-note-seasons = Cada reducción sigue las estaciones de su partida: una partida que pesa sobre todo en verano ahorra sobre todo en verano.
cut-note-capped = Una reducción introducida superaba el gasto: se ha limitado al propio gasto.
cut-invalid-cut = Esta reducción no se puede leer: un porcentaje de 0 a 100, o un importe al mes.
cut-report-settings = Los ajustes
cut-report-result = El resultado
cut-report-accounts = Cuentas seguidas

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Preparar mis vacaciones
window-holiday-title = Preparar mis vacaciones
holiday-trip-title = El viaje
holiday-field-trip = Tipo de viaje
holiday-trip-stay = Estancia
holiday-trip-cruise = Crucero
holiday-field-adults = Adultos
holiday-field-children = Niños
holiday-field-nights = Duración de la estancia, en noches
holiday-field-days = Días
holiday-field-months = Meses antes de la salida
holiday-field-stops = Número de escalas
holiday-saved-title = Ya ahorrado
holiday-saved-hint = Marque las cuentas donde ya está apartado el dinero de las vacaciones: su saldo real cuenta como ya ahorrado.
holiday-budget-title = El presupuesto
holiday-budget-hint = Para cada partida, un importe, para quién vale y durante cuánto tiempo. Vacía, una partida no cuenta.
holiday-optional-title = Líneas opcionales
holiday-result-title = El resultado
holiday-donut-title = Adónde va el dinero del viaje
holiday-donut-caption = para el viaje
holiday-child-label = Precio niño
holiday-count-label = Camarotes
holiday-open = Abrir un proyecto…
holiday-save = Guardar el proyecto…
holiday-pdf = Informe PDF
holiday-excel = Exportar a Excel
holiday-file-filter = Proyecto de vacaciones
holiday-replace-question = Abrir este proyecto sustituirá lo que está escrito en la ventana. ¿Continuar?
holiday-file-saved = Proyecto guardado: { $file }
holiday-file-opened = Proyecto abierto: { $file }
holiday-file-not-project = Este archivo no es un proyecto de vacaciones de Radinus.
holiday-file-too-recent = Este proyecto procede de una versión más reciente de Radinus: actualice Radinus para abrirlo.
holiday-file-failed = No se ha podido leer ni escribir el archivo: { $reason }
holiday-line-transport = Transporte de ida y vuelta
holiday-line-lodging = Alojamiento
holiday-line-meals = Comidas y gastos corrientes
holiday-line-visits = Visitas y ocio
holiday-line-port = Traslado hasta el puerto
holiday-line-cabins = Camarotes
holiday-line-service = Cargo por servicio (propinas)
holiday-line-drinks = Paquete de bebidas
holiday-line-excursions = Excursiones en las escalas
holiday-line-port-taxes = Tasas portuarias
holiday-line-wifi = Wifi a bordo
holiday-line-onboard = Gastos a bordo y en las escalas
holiday-line-other = Otros gastos e imprevistos
holiday-line-insurance = Seguro de cancelación
holiday-line-stay-tax = Tasa turística
holiday-line-car = Coche en destino, combustible y peajes
holiday-line-parking = Aparcamiento del aeropuerto o de la estación
holiday-line-bank = Comisiones bancarias en el extranjero
holiday-line-formalities = Trámites (pasaporte, visado, vacunas)
holiday-line-pets = Cuidado de las mascotas
holiday-span-trip = por la estancia
holiday-span-night = por noche
holiday-span-day = por día
holiday-span-stop = por escala
holiday-who-all = para todos
holiday-who-person = por persona
holiday-who-adults = por adulto
holiday-cabins-count = { $count ->
        [one] { $count } camarote
       *[other] { $count } camarotes
    }
holiday-days = { $days ->
        [one] { $days } día
       *[other] { $days } días
    }
holiday-invalid-count = Un número entero, por favor.
holiday-invalid-amount = Este importe no se puede leer: un número positivo, o un porcentaje de 0 a 100.
holiday-headline-empty = Escriba los importes del presupuesto para ver lo que costará el viaje.
holiday-headline-stay = Esta estancia costaría { $total } para { $people ->
        [one] una persona
       *[other] { $people } personas
    } y { $nights ->
        [0] ninguna noche
        [one] una noche
       *[other] { $nights } noches
    }.
holiday-headline-cruise = Este crucero costaría { $total } para { $people ->
        [one] una persona
       *[other] { $people } personas
    } y { $nights ->
        [0] ninguna noche
        [one] una noche
       *[other] { $nights } noches
    }.
holiday-tile-total = Coste total
holiday-tile-person = Por persona
holiday-tile-person-day = Por persona y día
holiday-tile-saved = Ya ahorrado
holiday-tile-remaining = Falta por financiar
holiday-tile-monthly = Ahorro necesario
holiday-remaining-none = Nada: está cubierto
holiday-monthly-none = Nada que apartar
holiday-monthly-now = Salida este mes
holiday-note-days = Los días son las noches más una: siete noches hacen ocho días.
holiday-note-child = Por persona, un niño paga el precio niño si se indica; si está vacío, paga como un adulto.
holiday-note-percent = Un porcentaje de seguro se aplica a las partidas principales del viaje; el de las comisiones bancarias, a los gastos hechos en destino.
holiday-sheet-budget = Presupuesto
holiday-sheet-result = Resultado
holiday-column-line = Partida
holiday-column-amount = Importe
holiday-column-child = Precio niño
holiday-column-who = Para quién
holiday-column-span = Durante cuánto tiempo
holiday-column-cost = Coste
holiday-disclaimer = Una estimación basada en sus propios importes: los precios reales pueden variar.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Proyecto de reducción
cut-file-not-project = Este archivo no es un proyecto de reducción de Radinus.
cut-file-too-recent = Este proyecto procede de una versión más reciente de Radinus: actualice Radinus para abrirlo.
cut-sheet-items = Partidas

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Cuaderno de mi coche
window-car-title = Cuaderno de mi coche
car-unnamed = Mi coche
car-sheet-title = El coche
car-field-plate = Matrícula
car-field-make = Marca
car-field-model = Modelo
car-field-engine = Motorización
car-field-first-hand = Primer propietario
car-field-registered = Primera matriculación
car-field-acquired = Fecha de adquisición
car-field-acquired-km = Kilometraje en la adquisición
car-field-service = Revisión cada
car-field-service-or = o cada
car-unit-months-short = meses
car-unit-km = km
car-tariff-title = Tarifa de la recarga en casa
car-tariff-hint = Esta tarifa se guarda en el cuaderno del coche: no cambia la de las preferencias.
car-tariff-reset = Recuperar la tarifa de las preferencias
car-engine-petrol = Gasolina
car-engine-diesel = Diésel
car-engine-lpg = GLP
car-engine-e85 = E85 (bioetanol)
car-engine-hybrid = Híbrido
car-engine-plug-in = Híbrido enchufable
car-engine-electric = Eléctrico
car-engine-hydrogen = Hidrógeno
car-energy-petrol = Gasolina
car-energy-diesel = Gasóleo
car-energy-lpg = GLP
car-energy-e85 = E85
car-energy-electricity = Electricidad
car-energy-hydrogen = Hidrógeno
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energía
car-rubric-upkeep = Mantenimiento corriente
car-rubric-service = Revisión
car-rubric-wear = Piezas de desgaste
car-rubric-tyres = Neumáticos
car-rubric-breakdown = Averías
car-rubric-insurance = Seguro
car-rubric-inspection = ITV
car-part-brake-pads = Pastillas de freno
car-part-brake-discs = Discos de freno
car-part-timing-belt = Correa de distribución
car-part-clutch = Embrague
car-part-battery-12v = Batería de 12 V
car-part-shock-absorbers = Amortiguadores
car-part-wipers = Escobillas limpiaparabrisas
car-part-spark-plugs = Bujías de encendido
car-part-glow-plugs = Calentadores
car-part-particulate-filter = Filtro de partículas
car-part-catalytic-converter = Catalizador
car-part-fuel-cell-filter = Filtro de la pila de combustible
car-part-exhaust = Escape
car-part-other = Otra pieza…
car-axle-all = Los cuatro neumáticos
car-axle-front = Neumáticos delanteros
car-axle-rear = Neumáticos traseros
car-verdict-pass = Favorable
car-verdict-counter = Segunda inspección
car-charge-station = En un punto de recarga
car-charge-home = En casa
car-slot-peak = Horas punta
car-slot-off-peak = Horas valle
car-entry-new = Nueva línea
car-entry-edit = Modificar la línea
car-field-date = Fecha
car-field-km = Cuentakilómetros
car-field-rubric = Apartado
car-field-amount = Importe
car-field-garage = Taller o estación
car-field-note = Nota
car-field-energy = Energía
car-field-quantity = Cantidad
car-field-charge = Recarga
car-field-slot = Hora de recarga
car-field-part = Pieza
car-field-part-name = Nombre de la pieza
car-field-axle = Neumáticos cambiados
car-field-verdict = Resultado
car-field-months = Meses cubiertos
car-field-battery = Estado de la batería
car-home-amount-hint = El importe de una recarga en casa se calcula con la tarifa del coche.
car-entry-add = Añadir al cuaderno
car-entry-update = Guardar la línea
car-entry-cancel = Cancelar
car-entry-delete = Eliminar la línea
car-delete-question = ¿Eliminar esta línea del cuaderno?
car-from-operation = Tomar una operación…
car-pick-account = ¿De qué cuenta sale el gasto?
car-pick-operation = ¿Qué operación?
car-pick-take = Tomar
car-pick-none = Ningún gasto en esta cuenta.
car-pick-taken = Operación recuperada: complete el cuentakilómetros y el apartado, y luego añada la línea.
car-history-title = El historial
car-filter-all = Todos los apartados
car-history-empty = Todavía no hay ninguna línea.
car-history-hint = Haga clic en una línea para modificarla.
car-column-date = Fecha
car-column-km = Km
car-column-rubric = Apartado
car-column-detail = Detalle
car-column-amount = Importe
car-column-garage = Taller
car-column-note = Nota
car-column-share = Parte
car-column-per-km = Por km
car-column-energy = Energía
car-column-quantity = Cantidad
car-column-price = Precio medio
car-column-consumption = Consumo
car-column-part = Pieza
car-column-changes = Cambios
car-column-last = Último cambio
car-column-life = Vida útil
car-column-next = Próximo cambio
car-total = Total
car-summary-title = Lo que cuesta el coche
car-headline-empty = Rellene la ficha y luego añada una primera línea: un repostaje, una revisión, una factura del taller…
car-headline = Desde el { $since }, su coche le ha costado { $total }.
car-headline-km = Desde el { $since }, su coche le ha costado { $total } por { $km } recorridos: { $cost } por kilómetro.
car-tile-total = Coste total
car-tile-month = Al mes
car-tile-km = Por kilómetro
car-tile-driven = Kilómetros recorridos
car-tile-consumption = Consumo
car-tile-energy-km = Energía por kilómetro
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } mes
       *[other] { $months } meses
    }
car-detail-battery = Batería: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Por apartado
car-energy-title = La energía
car-parts-title = Piezas de desgaste
car-tyres-title = Neumáticos
car-battery-title = Estado de la batería
car-years-title = Lo que ha costado el coche cada año
car-donut-title = Adónde va el dinero
car-donut-caption = en total
car-deadlines-title = Los vencimientos
car-deadlines-empty = Todavía no hay vencimientos: anote una revisión, una ITV, un seguro o dos cambios de una misma pieza.
car-deadline-service = Revisión
car-deadline-inspection = ITV
car-deadline-counter = Segunda inspección de la ITV
car-deadline-insurance = Fin del seguro
car-when-date = el { $date }
car-when-km = a los { $km }
car-when-km-reached = a los { $km }, hacia { $month } a su ritmo
car-when-date-km = el { $date } o a los { $km }, lo que llegue primero
car-when-inspection-unknown = Anote la última ITV para conocer la fecha de la próxima.
car-tone-late = Vencida
car-tone-soon = Pronto
car-note-since = Todo se cuenta desde la adquisición: la fecha y el kilometraje anotados en la ficha.
car-note-consumption = El consumo se mide de lleno a lleno: llene el depósito por completo y anote el cuentakilómetros cada vez.
car-note-e85 = Un coche E85 bebe lo que se le da: los kilómetros que siguen a un repostaje cuentan para su combustible.
car-note-home = Una recarga en casa se calcula con la tarifa del coche el día en que se anota, y conserva ese coste.
car-note-inspection = La ITV sigue la norma francesa: la primera dentro de los cuatro años siguientes a la primera matriculación, después cada dos años; una segunda inspección, en un plazo de dos meses.
car-disclaimer = Los vencimientos y las vidas útiles son estimaciones sacadas del cuaderno: solo el libro de mantenimiento del fabricante es oficial.
car-invalid-date = Una fecha válida, que no esté en el futuro, por favor.
car-invalid-acquired = La fecha de adquisición no puede ser anterior a la primera matriculación.
car-invalid-km = Un kilometraje en kilómetros enteros, por favor.
car-invalid-amount = Este importe no se puede leer.
car-invalid-quantity = Escriba la cantidad: litros, kWh o kilos.
car-invalid-part = Elija la pieza cambiada o escriba su nombre.
car-invalid-rubric = Elija un apartado.
car-invalid-months = Un número entero de meses, por favor.
car-invalid-battery = Un estado de batería de 0 a 100 %, por favor.
car-open = Abrir un cuaderno…
car-save = Guardar el cuaderno…
car-report-button = Dossier PDF
car-file-filter = Cuaderno del coche
car-file-saved = Cuaderno guardado: { $file }
car-file-opened = Cuaderno abierto: { $file }
car-file-not-logbook = Este archivo no es un cuaderno del coche de Radinus.
car-file-too-recent = Este cuaderno procede de una versión más reciente de Radinus: actualice Radinus para abrirlo.
car-replace-question = Abrir este cuaderno sustituirá el de la ventana. ¿Continuar?
car-sheet-history = Cuaderno
car-sheet-summary = Resumen

analysis-history-hint = Cuanto más largo sea su historial, mejor será este análisis: lo ideal es tener al menos un año de operaciones.

# --- F48 — Dividir un gasto (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Dividir un gasto
window-sharing-title = Dividir un gasto
sharing-question = ¿Quién paga qué?
sharing-setup-title = El reparto
sharing-field-label = Nombre
sharing-label-hint = Por ejemplo «Restaurante del 12/10» o «Viaje a Bretaña 2027»: da nombre a los archivos y a los informes.
sharing-field-total = Total
sharing-total-hint = Si se deja vacío, el total es la suma de las partidas y de los extras de cada persona.
sharing-field-rule = Regla
sharing-field-rounding = Redondeo
sharing-field-people = Personas
sharing-mode-whole = Una regla para todo el gasto
sharing-mode-item = Una regla por partida
sharing-rule-equal = Partes iguales
sharing-rule-parts = Por partes
sharing-rule-percent = Por porcentajes
sharing-rule-income = Proporcional a los ingresos
sharing-rounding-cent = Al céntimo
sharing-rounding-euro = A la unidad entera
sharing-round-euro = Redondear a unidades enteras
sharing-hide-incomes = Ocultar los ingresos en los informes y en la exportación
sharing-people-title = Las personas
sharing-people-hint = Una fila por persona, una columna por partida: marque quién participa en qué. Todo lo demás es opcional. Alguien que se retira y deja su anticipo: un importe exacto igual a lo que ha pagado y ninguna casilla marcada.
sharing-add-person = Añadir una persona
sharing-person-default = Persona { $number }
sharing-items-title = Las partidas
sharing-items-hint = Solo lo que no afecta a todos, como el vino. El resto del total va a la partida común.
sharing-add-item = Añadir una partida
sharing-common = Común
sharing-payments-title = Los pagos
sharing-payments-hint = Quién ha pagado, cuánto y cuándo. Una fila sin importe todavía no cuenta.
sharing-payments-none = Ningún pago por ahora.
sharing-add-payment = Añadir un pago
sharing-result-title = El resultado
sharing-balances-title = Cómo van los pagos
sharing-transfers-title = Transferencias propuestas
sharing-delete = Eliminar
sharing-delete-person-question = Esta persona tiene pagos: ¿eliminarlos junto con ella?
sharing-disclaimer = Radinus propone un reparto: entre amigos, cada uno es libre de arreglarse de otra manera.
sharing-column-person = Persona
sharing-column-household = Hogar
sharing-column-income = Ingresos
sharing-column-parts = Partes
sharing-column-percent = %
sharing-column-floor = Como mínimo
sharing-column-cap = Como máximo
sharing-column-fixed = Importe exacto
sharing-column-alone = Sus extras
sharing-column-gift = Excedente regalado
sharing-column-share = Parte
sharing-column-typed = % escrito
sharing-column-constraint = Lo que ha influido
sharing-column-due = A pagar
sharing-column-item = Partida
sharing-column-amount = Importe
sharing-column-rule = Regla
sharing-column-participants = Participantes
sharing-column-unit = Hogar o persona
sharing-column-members = Miembros
sharing-column-paid = Pagado
sharing-column-balance = Saldo
sharing-column-date = Fecha
sharing-column-who = Quién
sharing-column-label = Nombre
sharing-help-household = Las personas de un mismo hogar pagan juntas: sus pagos y lo que deben se suman, y reciben un único extracto. Ejemplo: «Familia Martin» para los padres y los hijos.
sharing-help-income = Solo lo usa la regla «Proporcional a los ingresos»: cuanto más altos son los ingresos, mayor es la parte. Escriba los ingresos mensuales.
sharing-help-parts = Una persona con 2 partes paga el doble que una persona con 1 parte. Ejemplo: adulto 1, niño 0,5.
sharing-help-percent = La parte del gasto que paga la persona. Los porcentajes deben sumar 100 % en total.
sharing-help-floor = La persona pagará como mínimo este importe, aunque su parte calculada sea menor. La diferencia alivia a los demás.
sharing-help-cap = La persona nunca pagará más que este importe. Lo que no paga recae en los demás participantes de sus partidas.
sharing-help-fixed = La persona paga este importe, pase lo que pase, y el resto se reparte entre los demás. Ejemplo: alguien que se retira y deja su anticipo.
sharing-help-alone = Lo que la persona ha tomado solo para sí, como un postre o un café. Lo paga por completo, además de su parte.
sharing-help-gift = Si la persona ha pagado más que su parte: marcada, el excedente es un regalo al grupo; sin marcar, se le devuelve.
sharing-help-items = Marque las personas que participan en esta partida. La partida Común es lo que queda del total una vez descontadas las demás partidas.
sharing-help-due = Lo que la persona debe en total: su parte de las partidas, sus extras y el redondeo.
sharing-help-share = Lo que representa su parte, en porcentaje de la suma repartida.
sharing-help-typed = El porcentaje que ha escrito. Puede diferir de la parte real cuando ha influido un mínimo, un máximo o un importe exacto.
sharing-help-constraint = Indica si la parte de la persona se ha modificado por un mínimo, un máximo, un importe exacto o un excedente regalado.
sharing-help-item = Solo lo que no afecta a todos, como el vino. El resto del total va a la partida Común, repartido entre quienes están marcados en ella.
sharing-help-rule = Cómo se reparte esta partida: a partes iguales, por partes, por porcentajes o proporcional a los ingresos.
sharing-help-paid = Lo que el hogar o la persona ya ha pagado, según los pagos introducidos.
sharing-help-balance = Lo que queda por pagar, o lo que se ha pagado de más sobre la parte. Ejemplo: «Queda por pagar: 61,54 €».
sharing-advice-equal = { $count ->
        [one] { $total } para una sola persona.
       *[other] { $total } ÷ { $count } personas = { $amount } cada uno.
    }
sharing-advice-equal-varied = A partes iguales entre quienes participan, teniendo en cuenta los límites y las exclusiones.
sharing-advice-parts = { $parts } partes en total: una parte vale { $amount }.
sharing-advice-parts-varied = Cada uno paga según sus partes, teniendo en cuenta los límites y las exclusiones. Una casilla vacía cuenta como 1 parte.
sharing-advice-percent-rest = Falta un { $rest } % para llegar al 100 %.
sharing-advice-percent-over = Los porcentajes superan el 100 % en { $over } %.
sharing-advice-percent-ok = Los porcentajes suman exactamente 100 %.
sharing-advice-percent-nobody = Los porcentajes ya suman 100 %: { $names } no { $count ->
        [one] pagaría
       *[other] pagarían
    } nada.
sharing-advice-income = Cada uno paga el { $rate } % de sus ingresos.
sharing-advice-income-missing = Escriba los ingresos de cada persona para repartir en proporción a los ingresos.
sharing-advice-income-varied = Cada uno paga la misma proporción de sus ingresos, teniendo en cuenta los límites y las exclusiones.
sharing-advice-empty = Escriba el importe a repartir.
sharing-apply-advice = Usar los valores aconsejados
sharing-help-apply-advice = Rellena las casillas vacías con los valores en gris. Las casillas ya rellenas no cambian.
sharing-from-incomes = Porcentajes según los ingresos
sharing-help-from-incomes = Sustituye los porcentajes por la parte de cada ingreso en el total de los ingresos. Suman 100 %.
sharing-reset-percents = Volver a repartirlo todo
sharing-help-reset-percents = Borra los porcentajes y los reparte a partes iguales entre todos. Útil después de añadir una persona.
sharing-reset-percents-question = ¿Borrar todos los porcentajes y repartirlos a partes iguales?
sharing-open = Abrir un proyecto…
sharing-save = Guardar el proyecto…
sharing-pdf-distribution = Reparto (PDF)
sharing-pdf-payments = Estado de los pagos (PDF)
sharing-pdf-statements = Extractos individuales (PDF)…
sharing-statements-everyone = Todos
sharing-excel = Exportar a Excel
sharing-file-filter = Proyecto de reparto
sharing-replace-question = Abrir este proyecto sustituirá lo que está escrito en la ventana. ¿Continuar?
sharing-file-saved = Proyecto guardado: { $file }
sharing-file-opened = Proyecto abierto: { $file }
sharing-file-not-project = Este archivo no es un proyecto de reparto de Radinus.
sharing-file-too-recent = Este proyecto procede de una versión más reciente de Radinus: actualice Radinus para abrirlo.
sharing-file-failed = No se ha podido leer ni escribir el archivo: { $reason }
sharing-statements-replace-question = { $count ->
        [one] Ya existe un extracto en esta carpeta. ¿Sustituirlo?
       *[other] Ya existen { $count } extractos en esta carpeta. ¿Sustituirlos?
    }
sharing-statements-written = { $count ->
        [one] Un extracto escrito en «{ $folder }».
       *[other] { $count } extractos escritos en «{ $folder }».
    }
sharing-too-many-people = Un reparto admite como máximo 40 personas.
sharing-too-many-items = Un reparto admite como máximo 20 partidas.
sharing-too-many-payments = Un reparto admite como máximo 400 pagos.
sharing-invalid-amount = Este importe no se puede leer: un número positivo.
sharing-invalid-number = Este número no se puede leer: un número positivo.
sharing-invalid-percent = Un porcentaje va de 0 a 100.
sharing-invalid-date = Esta fecha no se puede leer.
sharing-name-missing = Cada persona debe tener un nombre.
sharing-name-duplicate = Ya existe «{ $name }»: distíngalos, por ejemplo con una inicial.
sharing-floor-above-cap = El mínimo supera el máximo.
sharing-item-label-missing = Esta partida no tiene nombre.
sharing-items-above-total = Las partidas y los extras de cada persona superan el total en { $amount }.
sharing-payment-person = Elija quién ha pagado.
sharing-percent-total = Los porcentajes suman { $sum } %: tienen que sumar 100 %.
sharing-percent-total-item = «{ $item }»: los porcentajes suman { $sum } %: tienen que sumar 100 %.
sharing-item-nobody = Nadie participa en «{ $item }».
sharing-item-no-weight = Nadie pesa en «{ $item }»: todos sus participantes están a cero.
sharing-income-missing = Falta el ingreso de { $name }.
sharing-fixed-above = Los importes exactos superan la suma a repartir en { $amount }.
sharing-floors-above = Los mínimos superan la suma a repartir en { $amount }.
sharing-cap-alone = { $name } es la única persona que participa en «{ $item }»: su máximo no se puede respetar.
sharing-caps-short = Los máximos no bastan para cubrir la suma: faltan { $amount }.
sharing-impossible = Estas condiciones no se pueden respetar todas: afloje un mínimo o un máximo.
sharing-constraint-floor = Mínimo alcanzado
sharing-constraint-cap = Máximo alcanzado
sharing-constraint-fixed = Importe exacto
sharing-constraint-gift = Excedente regalado
sharing-and = { $first } y { $last }
sharing-outside = Fuera de las partidas
sharing-alone = Sus extras
sharing-rounding = Redondeo
sharing-headline-empty = Añada las personas que se reparten el gasto.
sharing-headline-no-amount = Escriba el total, o las partidas a repartir.
sharing-headline-equal = { $total } a repartir: cada uno paga { $amount }.
sharing-headline-range = { $total } a repartir: de { $min } a { $max } según cada persona.
sharing-participants = { $count ->
        [0] Ningún participante
        [one] Un participante
       *[other] { $count } participantes
    }
sharing-balance-due = Queda por pagar: { $amount }
sharing-balance-over = Ha pagado { $amount } más que su parte
sharing-balance-even = Al día
sharing-summary-collected = { $collected } pagados de { $total }.
sharing-summary-owing = { $count ->
        [0] Todos están al día.
        [one] Solo una persona debe aún { $amount }.
       *[other] { $count } personas deben aún { $amount } en total.
    }
sharing-remaining-outside = Queda por pagar del gasto: { $amount }
sharing-remaining-reimburse = A reembolsar a { $name }: { $amount }
sharing-all-settled = Todo está saldado: nadie debe nada a nadie.
sharing-transfer = { $from } debe { $amount } a { $to }
sharing-warning-over-paid = Los pagos superan el gasto en { $amount }: compruebe los importes.
sharing-note-income-zero = { $name } no paga nada en { $items }: sus ingresos son 0.
sharing-note-excluded = { $name } no participa en «{ $item }»: su parte se reparte entre los demás.
sharing-note-gift = El excedente regalado por { $giver } reduce la parte de los demás: { $name } ha pagado ahora más que su parte.
sharing-note-outside = { $name } paga { $amount } fuera de sus partidas: la suma se descuenta de lo que reparten los demás.
sharing-note-keeper = Redondeado a unidades enteras: { $name } se queda con los céntimos, para que el total salga exacto.
sharing-report-distribution = Reparto
sharing-report-sharing = El reparto
sharing-report-who-pays = Quién paga qué
sharing-report-items = El detalle por partida
sharing-report-payments = Estado de los pagos
sharing-report-as-of = Estado a { $date }
sharing-report-balances = Parte, pagado, saldo
sharing-report-statement = Extracto — { $name }
sharing-report-your-share = Su parte
sharing-statement-total = Total del hogar: { $amount }
sharing-statement-pay = A pagar a { $name }: { $amount }
sharing-statement-receive = A cobrar de { $name }: { $amount }
sharing-sheet-people = Personas
sharing-sheet-items = Partidas
sharing-sheet-result = Resultado
sharing-sheet-payments = Pagos
sharing-sheet-balances = Reembolsos

## El asistente de exportación de una base (P-74, Fabrice, 19/10/2026).
window-database-export-title = Asistente de exportación de la base «{ $base }»
menu-tools-export = Asistente de exportación de la base…
base-export-only-this = Solo se exportará la base «{ $base }», seleccionada en la lista. Las demás bases no se ven afectadas.
base-export-purpose = Este asistente copia los datos de la base en archivos que otros programas saben leer: una hoja de cálculo, una base de datos como Access, otro programa de finanzas personales. La base en sí no se modifica.
base-export-step-format = 1. El formato
base-export-step-options = 2. Las opciones
base-export-step-place = 3. La ubicación
base-export-step-summary = 4. El resumen
base-export-format-xlsx = Excel (.xlsx)
base-export-format-xlsx-hint = Un libro con una hoja por tabla, que se puede abrir con Excel y con la mayoría de las hojas de cálculo.
base-export-format-ods = Calc (.ods)
base-export-format-ods-hint = El formato libre de LibreOffice y de OpenOffice, con una hoja por tabla.
base-export-format-csv = CSV (.csv)
base-export-format-csv-hint = Un archivo de texto por tabla, con los valores separados por punto y coma: el formato que casi todos los programas saben importar, Access incluido.
base-export-format-json = JSON (.json)
base-export-format-json-hint = Para programadores y aplicaciones: cada tabla bajo su nombre, con una cabecera que describe la exportación.
base-export-format-xml = XML (.xml)
base-export-format-xml-hint = El mismo contenido que el JSON, escrito en XML.
base-export-format-sql = Script SQL (.sql)
base-export-format-sql-hint = Las instrucciones que vuelven a crear las tablas y sus datos en otra base de datos (MySQL, PostgreSQL, SQLite…).
base-export-format-sqlite = Base SQLite (.sqlite)
base-export-format-sqlite-hint = Una base de datos independiente, sin contraseña, que muchas herramientas abren directamente.
base-export-format-qif = QIF, un archivo por cuenta (.qif)
base-export-format-qif-hint = Para llevar sus cuentas a otro programa de finanzas personales (Money, Quicken, GnuCash, Grisbi…).
base-export-format-ofx = OFX, un archivo por cuenta (.ofx)
base-export-format-ofx-hint = El formato de los extractos bancarios, que la mayoría de los programas de finanzas personales saben importar.
base-export-lossy = Atención: el QIF y el OFX no pueden guardarlo todo. Solo pasan las operaciones de las cuentas, con sus beneficiarios, sus categorías y sus comentarios; una transferencia se convierte en una operación normal en cada lado, y el resto (presupuestos, operaciones periódicas, proyectos, asignaciones…) se queda fuera. Para conservarlo todo, elija otro formato.
base-export-planned-note = Las operaciones previstas y las operaciones sin fecha no se exportan: todavía no han pasado por el banco. Su número se indicará al final.
base-export-dates-hint = Las fechas se escriben año-mes-día (2026-12-31) y los importes en la moneda de la base: ningún programa puede equivocarse.
base-export-group-layout = Archivos
base-export-layout-one = Todo en un solo archivo
base-export-layout-per-table = Un archivo por tabla, en una carpeta
base-export-group-decimal = Separador decimal de los importes
base-export-decimal-point = El punto (1234.56)
base-export-decimal-comma = La coma (1234,56)
base-export-group-quotes = Comillas
base-export-quotes-all = Cada valor entre comillas
base-export-quotes-none = Sin comillas
base-export-csv-replacements-hint = Para que cada archivo se pueda volver a leer sin errores, un punto y coma dentro de un texto se convierte en un signo de exclamación, un salto de línea en un espacio y, sin comillas, unas comillas en un apóstrofo. El número de sustituciones se indicará al final.
base-export-group-qif-order = Orden de las fechas
base-export-qif-day-month = El día antes del mes (31/12/2026)
base-export-qif-month-day = El mes antes del día (12/31/2026)
base-export-qif-order-hint = Elija el orden que espera el programa que leerá los archivos: primero el día en Europa, primero el mes en Estados Unidos.
base-export-no-option = Este formato no tiene opciones.
base-export-choose-file = Elegir el archivo…
base-export-choose-folder = Elegir la carpeta…
base-export-place-file = La exportación se escribirá en este archivo:
base-export-place-folder = La exportación se escribirá en esta carpeta, creada para la ocasión:
base-export-place-none = Todavía no se ha elegido ninguna ubicación.
base-export-place-needed = Elija primero dónde escribir la exportación.
base-export-folder-exists = La carpeta «{ $name }» ya existe. Los archivos con el mismo nombre que contiene serán sustituidos. ¿Continuar?
base-export-summary-base = Base
base-export-summary-format = Formato
base-export-summary-options = Opciones
base-export-summary-place = Ubicación
base-export-unprotected = Esta base está protegida con una contraseña, pero la exportación no lo estará: cualquiera que tenga estos archivos podrá leer sus cuentas. Guárdelos en un lugar seguro.
base-export-previous = Anterior
base-export-next = Siguiente
base-export-run = Exportar
base-export-running = Exportando…
base-export-done = La base «{ $base }» se ha exportado: { $tables ->
        [one] una tabla
       *[other] { $tables } tablas
    }, { $rows ->
        [one] una línea
       *[other] { $rows } líneas
    }.
base-export-done-accounts = La base «{ $base }» se ha exportado: { $accounts ->
        [one] una cuenta
       *[other] { $accounts } cuentas
    }, { $operations ->
        [one] una operación
       *[other] { $operations } operaciones
    }.
base-export-done-replacements = { $count ->
        [one] Se ha sustituido un carácter en los archivos CSV.
       *[other] Se han sustituido { $count } caracteres en los archivos CSV.
    }
base-export-done-controls = { $count ->
        [one] Se ha sustituido { $count } carácter de control, que este formato no puede contener, por «�».
       *[other] Se han sustituido { $count } caracteres de control, que este formato no puede contener, por «�».
    }
base-export-done-excel-cut = { $count ->
        [one] { $count } texto superaba los 32.767 caracteres, el límite de Excel: se ha cortado en el libro. Los demás formatos lo conservan entero.
       *[other] { $count } textos superaban los 32.767 caracteres, el límite de Excel: se han cortado en el libro. Los demás formatos los conservan enteros.
    }
base-export-done-anomalies = { $count ->
        [one] Un valor ilegible se ha copiado tal cual.
       *[other] { $count } valores ilegibles se han copiado tal cual.
    }
base-export-done-planned = { $count ->
        [one] Se ha dejado fuera una operación prevista.
       *[other] Se han dejado fuera { $count } operaciones previstas.
    }
base-export-done-undated = { $count ->
        [one] Se ha dejado fuera una operación sin fecha.
       *[other] Se han dejado fuera { $count } operaciones sin fecha.
    }
base-export-done-adjusted = { $count ->
        [one] Se ha ajustado un valor para el formato.
       *[other] Se han ajustado { $count } valores para el formato.
    }
base-export-too-old = Esta base procede de una versión anterior de Radinus. Ábrala primero una vez en Radinus, que la actualizará, y después expórtela.
base-export-too-recent = Esta base se guardó con una versión más reciente de Radinus. Actualice Radinus para exportarla.
base-export-not-radinus = Este archivo no es una base de Radinus.
base-export-failed = No se ha podido realizar la exportación: { $reason }

## El menú Herramientas de la ventana de bases nombra la base (Fabrice, 19/10/2026).
databases-tools-selected = Base seleccionada: «{ $base }»
databases-tools-none = Ninguna base seleccionada
menu-tools-backup = Hacer una copia de seguridad de la base «{ $base }»…
menu-tools-backup-none = Hacer una copia de seguridad de la base seleccionada…
menu-tools-restore = Restaurar la base «{ $base }»…
menu-tools-restore-none = Restaurar la base seleccionada…
menu-tools-repair = Reparar y optimizar la base «{ $base }»…
menu-tools-repair-none = Reparar y optimizar la base seleccionada…
