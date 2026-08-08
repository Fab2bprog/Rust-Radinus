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
menu-statistics-by-category = Estadísticas por categorías
menu-statistics-by-assignment = Estadísticas por asignaciones
menu-statistics-by-budget-line = Estadísticas por partidas presupuestarias
menu-statistics-by-payment-mode = Estadísticas por formas de pago
menu-statistics-by-payee = Estadísticas por beneficiarios y comercios
menu-statistics-by-project = Estadísticas por proyectos
menu-statistics-dashboard = Cuadro de mando de las operaciones

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

menu-settings = Configuración
menu-settings-about-author = Acerca del autor
menu-settings-about-radinus = Acerca de Radinus
menu-settings-licence = Licencia de uso

menu-misc = Varios
menu-misc-calculator = Calculadora
menu-misc-website = Ir al sitio web de Radinus
menu-misc-database-folder = Acceso a la carpeta que contiene la base de datos
menu-misc-application-folder = Acceso a la carpeta que contiene la aplicación

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
operations-column-label = Concepto
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
    [one] 1 operación conciliada.
   *[other] { $count } operaciones conciliadas.
}
operations-select-one = Seleccione una sola operación.

# --- Duplicar y la visualización de los desgloses (F02) ---------------

operation-copy = Copia pendiente de guardar: todavía no se ha creado nada.
operations-show-children = Mostrar todos los desgloses
operations-hide-children = Ocultar todos los desgloses

# --- Segunda confirmación de una eliminación grave --------------------

accounts-delete-second-question = Esta eliminación es definitiva y se lleva todo el historial de la cuenta. Escriba «{ $word }» para confirmarla.

# --- F20-F24 — Las seis estadísticas ----------------------------------

window-statistics-title = { $kind ->
    [assignment] Estadísticas por asignación
    [budget-line] Estadísticas por partida presupuestaria
    [payment-mode] Estadísticas por forma de pago
    [payee] Estadísticas por beneficiario y comercio
    [project] Estadísticas por proyecto
   *[category] Estadísticas por categoría
}

statistics-axis-column = { $kind ->
    [assignment] Asignación
    [budget-line] Partida presupuestaria
    [payment-mode] Forma de pago
    [payee] Beneficiario
    [project] Proyectos
   *[category] Categoría
}

statistics-unclassified = { $kind ->
    [assignment] Sin asignación
    [budget-line] Sin partida presupuestaria
    [payment-mode] Sin forma de pago
    [payee] Sin beneficiario
    [project] Sin proyecto
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
export-all-years-excel = Exportar todos los años a Excel
export-all-years-ods = Exportar todos los años a LibreOffice Calc
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
quick-column-date = Fecha
quick-column-label = Concepto
quick-column-amount = Importe
quick-column-category = Categoría
quick-column-assignment = Asignación
quick-column-payment-mode = Forma de pago
quick-column-payee = Beneficiario
quick-column-project = Proyectos
quick-column-status = Estado
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
statement-column-debit = Cargo
statement-column-credit = Abono
statement-account = Cuenta
statement-file = Archivo
statement-difference = Diferencia
statement-none = No hay ningún extracto abierto: haga clic en la carpeta amarilla para elegir un archivo.
statement-empty = Este extracto no contiene ninguna operación.
statement-no-match = Ninguna línea corresponde al filtro.
statement-help = Información: utilice clic de ratón + tecla [{ $modifier }] sobre la tabla para seleccionar varias líneas
statement-choose-account = Este archivo contiene varias cuentas. ¿Cuál desea importar?
statement-select-line = Seleccione al menos una línea del extracto.
statement-title-open = Abrir un archivo de extracto (.ofx)
statement-title-info = Información sobre el archivo abierto
statement-title-integrate = Incorporar la selección a la cuenta
statement-title-validate = Incorporar esta operación a la cuenta
statement-duplicate = Atención, duplicado: esta transacción parece haber sido incorporada ya a la base de datos (el Financial Institution Transaction ID ya existe)
statement-no-fitid = Atención: este archivo no proporciona ningún identificador (FITID) para esta línea. No será posible detectar un duplicado.
statement-loaded = { $count ->
    [0] Este archivo no contiene ninguna operación para esta cuenta.
   *[other] { $count } líneas leídas, de las cuales { $known } ya están presentes en su cuenta.
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
    { $count } operaciones, de las cuales { $known } ya están presentes en su cuenta.
statement-group-identification = Identificación de la operación
statement-group-amount = Importe de la operación
statement-group-classification = Clasificación de la operación para el cálculo de las estadísticas
statement-group-status = Estado de la operación
statement-field-date = Fecha
statement-field-label = Concepto
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
excel-backup-later = La copia de seguridad todavía no está conectada en esta versión de Radinus 2. Mientras tanto, cierre Radinus y copie usted mismo su archivo de base de datos: así podrá importar sin ningún riesgo.

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
backup-done = Copia de seguridad escrita en «{ $file }».
backup-failed = Copia de seguridad imposible: { $reason }
restore-unreadable = Este archivo no es un archivo Radinus legible: { $reason }
restore-question = ¿Restaurar «{ $file }»? Todo el contenido actual de su base se borrará y se sustituirá, y lo que allí se encuentre se perderá.
restore-done = Restauración terminada: { $accounts } cuentas y { $operations } operaciones.
restore-failed = Restauración imposible: { $reason }


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
    [0] Reparación terminada: ninguna anomalía encontrada. { $lines } etapas registradas.
    [one] Reparación terminada: una anomalía reparada. { $lines } etapas registradas.
   *[other] Reparación terminada: { $anomalies } anomalías reparadas. { $lines } etapas registradas.
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
