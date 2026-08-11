# Radinus — core-side messages (Fluent), Portuguese (Portugal).
#
# Ajouté le 03/08/2026 à la demande de l'auteur. Quatrième langue, et la
# preuve que l'architecture tenait sa promesse : ajouter une langue, c'est
# déposer un fichier et une ligne dans la table `KNOWN` de `i18n.rs`.
#
# Numéro WinDev : 14 (`nationPortugais`, table `Analyse/Langues/Code
# langue.xlsx`). Le portugais brésilien y porte le 15 et reste à faire.

# ---------------------------------------------------------------------
# Le nom de la langue, écrit dans sa propre langue.
# ---------------------------------------------------------------------
language-name = Português

nomenclature-unspecified = Não especificado

nomenclature-delete-confirm = Foram detetadas operações (transações bancárias) com o atributo do tipo '{ $label }'. Confirma que pretende reinicializar este atributo?

nomenclature-delete-plain = Confirma a eliminação de « { $label } »?

nomenclature-delete-form-open = A ficha de « { $label } » está aberta. Feche-a antes de eliminar.

nomenclature-duplicate = Já existe { $element } com o mesmo nome: « { $label } ».

# ---------------------------------------------------------------------
# Ce que les fenêtres disent d'elles-mêmes.
# ---------------------------------------------------------------------

ui-loading = A carregar…
ui-editing = Modificação.
ui-viewing = Consulta.
ui-modified-suffix = — modificado
ui-label-required = O nome é obrigatório.
ui-discard-question = Abandonar as alterações?
ui-yes = Sim
ui-no = Não
ui-select-record = Selecione um registo
ui-key-multiselect = CTRL
ui-multiselect-help = Info: utilize Clique do rato + tecla [{ $modifier }] na tabela para selecionar vários elementos
ui-no-match = Nenhum nome corresponde ao filtro.
ui-filter-placeholder = Filtrar os nomes…
ui-column-label = NOME
ui-field-label = Nome
ui-field-budget-line = Rubrica orçamental
ui-identifier = Identificador
ui-deletion-abandoned = Eliminação abandonada: nada foi alterado.
ui-unknown-nomenclature = Nomenclatura desconhecida:

ui-title-filter = Filtrar
ui-title-create = Criar
ui-title-update = Modificar a seleção
ui-title-delete = Eliminar a seleção
ui-title-read = Consultar a seleção
ui-title-close = Fechar
ui-title-save = Guardar
ui-title-add = Adicionar
ui-title-modify = Modificar

ui-load-failed = Não foi possível carregar:
ui-save-failed = Não foi possível guardar:
ui-read-failed = Não foi possível ler:
ui-delete-failed = Não foi possível eliminar:
ui-open-failed = Não foi possível abrir:
ui-close-failed = Não foi possível fechar:

# --- Phrases propres à chaque nomenclature ---------------------------

nomenclature-identifier = { $kind ->
    [category] Identificador de Categoria
    [assignment] Identificador de Afetação
    [payment-mode] Identificador de Modo de pagamento
    [payee] Identificador de Terceiro
    [project] Identificador de Projeto
    [budget-line] Identificador de Rubrica orçamental
   *[bank] Identificador de Banco
}

nomenclature-none = { $kind ->
    [category] Nenhuma categoria.
    [assignment] Nenhuma afetação.
    [payment-mode] Nenhum modo de pagamento.
    [payee] Nenhum terceiro.
    [project] Nenhum projeto.
    [budget-line] Nenhuma rubrica orçamental.
   *[bank] Nenhum banco.
}

nomenclature-nothing-to-show = { $kind ->
    [category] Nenhuma categoria a mostrar.
    [assignment] Nenhuma afetação a mostrar.
    [payment-mode] Nenhum modo de pagamento a mostrar.
    [payee] Nenhum terceiro a mostrar.
    [project] Nenhum projeto a mostrar.
    [budget-line] Nenhuma rubrica orçamental a mostrar.
   *[bank] Nenhum banco a mostrar.
}

nomenclature-gone = { $kind ->
    [category] Esta categoria já não existe.
    [assignment] Esta afetação já não existe.
    [payment-mode] Este modo de pagamento já não existe.
    [payee] Este terceiro já não existe.
    [project] Este projeto já não existe.
    [budget-line] Esta rubrica orçamental já não existe.
   *[bank] Este banco já não existe.
}

nomenclature-fresh = { $kind ->
    [category] Nova categoria.
    [assignment] Nova afetação.
    [payment-mode] Novo modo de pagamento.
    [payee] Novo terceiro.
    [project] Novo projeto.
    [budget-line] Nova rubrica orçamental.
   *[bank] Novo banco.
}

nomenclature-created = { $kind ->
    [category] Categoria adicionada.
    [assignment] Afetação adicionada.
    [payment-mode] Modo de pagamento adicionado.
    [payee] Terceiro adicionado.
    [project] Projeto adicionado.
    [budget-line] Rubrica orçamental adicionada.
   *[bank] Banco adicionado.
}

nomenclature-updated = { $kind ->
    [category] Categoria modificada.
    [assignment] Afetação modificada.
    [payment-mode] Modo de pagamento modificado.
    [payee] Terceiro modificado.
    [project] Projeto modificado.
    [budget-line] Rubrica orçamental modificada.
   *[bank] Banco modificado.
}

nomenclature-deleted = { $kind ->
    [category] { $count ->
        [one] 1 categoria eliminada.
       *[other] { $count } categorias eliminadas.
      }
    [assignment] { $count ->
        [one] 1 afetação eliminada.
       *[other] { $count } afetações eliminadas.
      }
    [payment-mode] { $count ->
        [one] 1 modo de pagamento eliminado.
       *[other] { $count } modos de pagamento eliminados.
      }
    [payee] { $count ->
        [one] 1 terceiro eliminado.
       *[other] { $count } terceiros eliminados.
      }
    [project] { $count ->
        [one] 1 projeto eliminado.
       *[other] { $count } projetos eliminados.
      }
    [budget-line] { $count ->
        [one] 1 rubrica orçamental eliminada.
       *[other] { $count } rubricas orçamentais eliminadas.
      }
   *[bank] { $count ->
        [one] 1 banco eliminado.
       *[other] { $count } bancos eliminados.
      }
}

nomenclature-duplicate-name = { $kind ->
    [category] Já existe uma categoria com o mesmo nome: « { $label } ».
    [assignment] Já existe uma afetação com o mesmo nome: « { $label } ».
    [payment-mode] Já existe um modo de pagamento com o mesmo nome: « { $label } ».
    [payee] Já existe um terceiro com o mesmo nome: « { $label } ».
    [project] Já existe um projeto com o mesmo nome: « { $label } ».
    [budget-line] Já existe uma rubrica orçamental com o mesmo nome: « { $label } ».
   *[bank] Já existe um banco com o mesmo nome: « { $label } ».
}

# --- Titres de fenêtres -----------------------------------------------

window-list-title = { $kind ->
    [category] Lista das categorias
    [assignment] Lista das afetações
    [payment-mode] Lista dos modos de pagamento
    [payee] Lista dos terceiros e comerciantes
    [project] Lista dos projetos
    [budget-line] Lista das rubricas orçamentais
   *[bank] Lista dos bancos
}

window-form-title = { $kind ->
    [category] Ficha de categoria
    [assignment] Ficha de afetação
    [payment-mode] Ficha de modo de pagamento
    [payee] Ficha de terceiro
    [project] Ficha de projeto
    [budget-line] Ficha de rubrica orçamental
   *[bank] Ficha de banco
}

# --- Barra de menus ---------------------------------------------------

menu-file = Ficheiro
menu-file-import-statements = Importação de extratos bancários
menu-file-import-excel = Importação de ficheiro Excel
menu-file-backup = Cópia de segurança
menu-file-restore = Restauro
menu-file-repair = Reparação e otimização da base de dados
menu-file-log = Mostrar o registo
menu-tools-password = Proteger a base de dados com uma palavra-passe
menu-file-disconnect = Desligar-se da base atual
menu-file-quit = Sair

menu-accounts = Contas
menu-accounts-manage = Gestão das contas bancárias
menu-accounts-balances = Ver os saldos das suas contas
menu-accounts-operations = Gerir as operações de uma conta
menu-accounts-quick-classify = Classificação rápida das operações
menu-accounts-recurring = Gestão das operações periódicas
menu-accounts-transfer = Transferir um montante entre duas contas
menu-accounts-checkbooks = Gestão dos livros de cheques

menu-statistics = Estatísticas
menu-statistics-balance-chart = Gráfico Evolução do saldo
menu-statistics-by-category = Estat. por categorias
menu-statistics-by-assignment = Estat. por afetações
menu-statistics-by-budget-line = Estat. por rubricas orçamentais
menu-statistics-by-payment-mode = Estat. por meios de pagamento
menu-statistics-by-payee = Estat. por terceiros e comerciantes
menu-statistics-by-project = Estat. por projetos
menu-statistics-dashboard = Painel de bordo das operações

menu-budget = Orçamento
menu-budget-entry = Introdução do orçamento
menu-budget-control = Controlo do orçamento

menu-nomenclatures = Nomenclaturas
menu-nomenclature = { $kind ->
    [category] Categorias
    [assignment] Afetações
    [payment-mode] Modos de pagamento
    [payee] Terceiros e comerciantes
    [project] Projetos
    [budget-line] Rubricas orçamentais
   *[bank] Bancos
}
menu-nomenclatures-templates = Modelos de operações

menu-settings = Definições
menu-settings-about-author = Acerca do autor
menu-settings-about-radinus = Acerca do Radinus
menu-settings-licence = Licença de utilização

menu-misc = Diversos
menu-misc-calculator = Calculadora
menu-misc-website = Ir ao sítio do Radinus
menu-misc-database-folder = Aceder à pasta que contém a base de dados

# L'avertissement posé devant ce dossier (Fabrice, 08/08/2026) : « un
# utilisateur ignorant peut faire des bêtises ». La question est posée
# avant l'ouverture, jamais après.
database-folder-warning-title = Abrir a pasta da base de dados
database-folder-warning =
    Esta pasta contém todos os seus dados. Renomear, mover ou eliminar um ficheiro pode fazer perder as suas contas, danificá-las ou impedir o Radinus de funcionar.
    Deseja realmente abri-la?
menu-misc-application-folder = Aceder à pasta que contém a aplicação
menu-misc-attachments-folder = Acesso à pasta que contém os anexos
# --- « Gestion des pièces jointes » (08/08/2026) -------------------------
#
# La fenêtre montre les pièces de toutes les opérations, plus les fichiers
# du dossier que la base ne réclame pas. Les cinq états ne sont pas trois :
# un fichier disparu, un fichier modifié et un fichier qu'on ne sait pas
# juger ne se traitent pas de la même façon.
menu-settings-attachments = Gestão dos anexos
window-attachments-manager-title = Gestão dos anexos
attachments-column-document = Documento
attachments-column-size = Tamanho
attachments-column-added = Adicionado em
attachments-column-state = Estado
attachments-state-intact = Intacto
attachments-state-altered = Alterado desde
attachments-state-missing = Ficheiro ausente
attachments-state-unknown = Não verificável
attachments-state-orphan = Órfão
attachments-no-operation = Nenhuma operação
attachments-orphan-remove-question = Este ficheiro não está ligado a nenhuma operação. Enviá-lo para a reciclagem?
attachments-manager-help = Faça duplo clique numa linha para abrir o documento.

# Les deux entrées du clic droit. « Afficher l'opération » n'apparaît pas
# sur un orphelin — il n'appartient à aucune opération — et « Révéler »
# disparaît quand le fichier n'est plus sur le disque.
attachments-show-operation = Mostrar a operação
attachments-reveal = Revelar no explorador de ficheiros
attachments-manager-summary = { $count } anexos, { $size } no total.
attachments-disk-name = Nome no disco: { $name }

# L'avertissement du dossier des pièces jointes (Fabrice, 08/08/2026).
# Le danger n'y est pas le même que pour la base : on ne perd pas des
# comptes, on casse un lien — l'opération annonce une pièce qui ne
# s'ouvre plus. C'est ce que dit la phrase, plutôt que « ne faites pas
# n'importe quoi ».
attachments-folder-warning-title = Abrir a pasta dos anexos
attachments-folder-warning =
    Esta pasta contém os ficheiros que anexou às suas operações. O Radinus guarda-os com um nome escolhido por ele: renomear, mover ou eliminar um não o desliga da operação, que continuará a anunciá-lo e ele deixará de abrir.
    Deseja realmente abri-la?

# ---------------------------------------------------------------------
# Contas bancárias — F04, F06, F07, F08.
# ---------------------------------------------------------------------

window-accounts-title = Gestão das contas bancárias
window-accounts-select-title = Lista das contas
window-balances-title = Saldos das suas contas
window-account-title = Ficha de conta

accounts-none = Nenhuma conta.
accounts-nothing-to-show = Nenhuma conta a mostrar.
accounts-gone = Esta conta já não existe.
accounts-fresh = Nova conta.
accounts-created = Conta adicionada.
accounts-updated = Conta modificada.
accounts-deleted = { $count ->
    [one] 1 conta eliminada.
   *[other] { $count } contas eliminadas.
}
accounts-duplicate-name = Já existe uma conta com o mesmo nome: « { $label } ».
accounts-multiselect-help = Info: utilize Clique do rato + tecla [{ $modifier }] na tabela para selecionar várias contas
accounts-select-question = Em que contas bancárias devem basear-se as estatísticas?

accounts-column-label = NOME
accounts-column-bank = Banco
accounts-column-type = Tipo de conta
accounts-column-number = N.º da conta
accounts-column-account = Conta
accounts-column-bank-balance = No Banco
accounts-column-real-balance = Real
accounts-column-final-balance = Final
accounts-total = TOTAL

accounts-delete-plain = Confirma a eliminação da conta « { $label } »?
accounts-delete-with-operations = A conta « { $label } » contém { $count } operações, que serão eliminadas com ela. Confirma a eliminação?
accounts-delete-form-open = A ficha da conta « { $label } » está aberta. Feche-a antes de eliminar.

account-group-bank = Dados da conta e do banco
account-group-holder = Titular
account-group-rib = Coordenadas bancárias (NIB)
account-group-activity = Atividade
account-group-balances = Saldos

account-field-label = Título da conta
account-field-bank = Banco
account-field-type = Tipo de conta
account-field-branch-address = Morada do balcão
account-field-holder-name = Nome
account-field-holder-address = Morada
account-field-rib-bank = Instituição
account-field-rib-branch = Código do balcão
account-field-rib-number = Número da conta
account-field-rib-key = Chave de controlo
account-field-bic = BIC (Bank Identifier Code)
account-field-iban = IBAN (International Bank Account Number)
account-field-opening-date = Data de abertura
account-field-closing-date = Data de encerramento
account-field-closed = Está encerrada
account-field-opening-pointed = Saldo inicial conciliado
account-field-opening-committed = Saldo inicial comprometido
account-field-opening-planned = Saldo inicial previsto

account-label-required = O título da conta é obrigatório.
account-iban-invalid = Este IBAN não é válido: verifique a chave de controlo.
account-control-line = Saldo inicial conciliado ({ $opening }) + Total das operações ({ $operations }) = Saldo bancário atual: { $balance }.

amount-not-readable = « { $field } » não contém um montante válido.

# O ponto agrupa os milhares e a vírgula abre as decimais : 1.549,81 €.
ui-thousands-separator = .
ui-decimal-separator = ,

# --- Lista das operações (F02) ----------------------------------------

window-operations-title = Lista de operações da conta: { $account }

operations-none = Nenhuma operação neste período.
operations-bad-period = Os limites do período não são datas válidas.
operations-from = Data de início
operations-to = Data de fim
operations-delete-confirm = { $count ->
    [one] Confirma a eliminação desta operação?
   *[other] Confirma a eliminação destas { $count } linhas? As suboperações das operações selecionadas serão eliminadas com elas.
}
operations-deleted = { $count ->
    [one] 1 operação eliminada.
   *[other] { $count } operações eliminadas.
}
operations-selection-total = Montante total das operações selecionadas: { $amount }

operations-column-date = Data
operations-column-clearing-date = Data de conciliação
operations-column-label = Descrição
operations-column-category = Categoria
operations-column-assignment = Afetação
operations-column-payment-mode = ModoOp
operations-column-payee = Terceiro
operations-column-project = Projetos
operations-column-month = Mês
operations-column-debit = Débito
operations-column-credit = Crédito
operations-column-balance = Saldo
operations-column-comments = Comentários
operations-column-attachments = Anexos
operations-column-check = N.º do cheque

operations-foot-debit = Débito:
operations-foot-credit = Crédito:
operations-foot-total = Total:
operations-foot-bank = Saldo no banco:
operations-foot-real = Saldo real:
operations-foot-final = Saldo final:

operations-menu-export = Exportar
operations-menu-print = Impressão
operations-menu-filter = Filtro
operations-menu-period = Período
operations-menu-misc = Diversos

operations-title-point = Conciliar a seleção
operations-title-sub = Adicionar uma suboperação
operations-title-duplicate = Duplicar a seleção
operations-not-yet = Esta janela ainda não existe: vem mais adiante no plano.

accounts-choose-question = Em que conta pretende trabalhar?
ui-title-select = Escolher a seleção

month-january = janeiro
month-february = fevereiro
month-march = março
month-april = abril
month-may = maio
month-june = junho
month-july = julho
month-august = agosto
month-september = setembro
month-october = outubro
month-november = novembro
month-december = dezembro

operations-period-year = Ano em curso

# --- Menu Período de F02 ----------------------------------------------

period-all = Todas
period-last-year = Ano passado
period-this-year = Ano atual
period-whole-year = Todo o ano
period-last-month = Mês passado
period-this-month = Mês em curso
period-last-week = Semana passada
period-this-week = Semana atual
period-yesterday = Ontem
period-today = Hoje

# --- Menu Filtro de F02 -----------------------------------------------

filter-all = Todas as operações
filter-pointed = Apenas as operações conciliadas
filter-committed = Apenas as operações comprometidas
filter-planned = Apenas as operações previstas

# --- Ficha de operação (F03) ------------------------------------------

window-operation-title = Operação da conta: { $account }

operation-menu-identification = Identificação
operation-menu-options = Opções
operation-fitid-edit = Editar o identificador FITID…
operation-fitid-delete = Eliminar o identificador FITID
operation-fitid-question = Identificador FITID desta transação:
operation-fitid-delete-question = Eliminar o identificador FITID desta transação?
operation-fitid-written = Identificador FITID guardado.
operation-fitid-removed = Identificador FITID eliminado.

operation-group-identification = Identificação da operação
operation-group-amount = Montante da operação
operation-group-status = Estado da operação
operation-group-classification = Classificação da operação para o cálculo das estatísticas
operation-group-check = Cheque associado à operação
operation-group-comment = Comentário

operation-field-label = Descrição
operation-field-reference = Referência de pagamento
operation-field-date = Data
operation-field-direction = Tipo de operação:
operation-field-amount = Montante
operation-field-status = Estado da operação
operation-field-clearing-date = Data de conciliação
operation-field-category = Categoria
operation-field-assignment = Afetação
operation-field-payment-mode = Modo
operation-field-payee = Terceiro
operation-field-project = Projeto
operation-field-check = Associar a um cheque

operation-direction-debit = Débito
operation-direction-credit = Crédito

operation-check-info = Info.
operation-check-link = Associar
operation-check-unlink = Remover

operation-fresh = Nova operação.
operation-created = Operação adicionada.
operation-updated = Operação modificada.
operation-gone = Esta operação já não existe.
operation-nothing-to-show = Nenhuma operação a mostrar.
operation-label-required = A descrição da operação é obrigatória.
operation-date-required = A data da operação é obrigatória.
operation-clearing-date-invalid = A data de conciliação não é uma data válida.
operation-is-a-sub = Esta linha é uma suboperação: modifica-se a partir da sua própria ficha.
operation-delete-form-open = A ficha de « { $label } » está aberta. Feche-a antes de eliminar.

operation-attachments = { $count ->
    [0] Nenhum anexo
    [one] 1 anexo
   *[other] { $count } anexos
}

operation-title-comment = Comentário da operação
operation-title-sub = Criar uma suboperação
operation-title-template = Modelos de operação
operation-title-attachment = Anexos

# --- Ficha de suboperação (F04) ---------------------------------------

window-sub-operation-title = Ficha de suboperação

sub-operation-group-amount = Montante da suboperação
sub-operation-field-label = Nome
sub-operation-fresh = Nova suboperação.
sub-operation-created = Suboperação adicionada.
sub-operation-updated = Suboperação modificada.
sub-operation-gone = Esta suboperação já não existe.
sub-operation-nothing-to-show = Nenhuma suboperação a mostrar.
sub-operation-label-required = O nome da suboperação é obrigatório.
sub-operation-parent-gone = A operação a repartir já não existe.
sub-operation-is-the-complement = Este é o Complemento: o que falta repartir. Mudar-lhe o nome ou o montante torna-o numa suboperação vulgar.
sub-operation-of = Repartição de « { $label } » ({ $amount })

operations-pointed = { $count ->
    [one] 1 operação conciliada.
   *[other] { $count } operações conciliadas.
}
operations-select-one = Selecione apenas uma operação.

# --- Duplicar e mostrar as suboperações (F02) -------------------------

operation-copy = Cópia por guardar: ainda não foi criado nada.
operations-show-children = Mostrar todas as suboperações
operations-hide-children = Ocultar todas as suboperações

# --- Segunda confirmação de uma eliminação grave ----------------------

accounts-delete-second-question = Esta eliminação é definitiva e leva consigo todo o histórico da conta. Escreva « { $word } » para a confirmar.

# --- F20-F24 — As seis estatísticas -----------------------------------

window-statistics-title = { $kind ->
    [assignment] Estatísticas por afetação
    [budget-line] Estatísticas por rubrica orçamental
    [payment-mode] Estatísticas por meio de pagamento
    [payee] Estatísticas por terceiro e comerciante
    [project] Estatísticas por projeto
   *[category] Estatísticas por categoria
}

statistics-axis-column = { $kind ->
    [assignment] Afetação
    [budget-line] RubricaOrç
    [payment-mode] ModoPagamento
    [payee] Terceiro
    [project] Projetos
   *[category] NomeCategoria
}

statistics-unclassified = { $kind ->
    [assignment] Sem afetação
    [budget-line] Sem rubrica orçamental
    [payment-mode] Sem meio de pagamento
    [payee] Sem terceiro
    [project] Sem projeto
   *[category] Sem categoria
}
statistics-total = Total
statistics-sum = Soma
statistics-cumulative = Acumulado

statistics-switch-pointed = Operações conciliadas { $state }
statistics-switch-committed = Operações comprometidas { $state }
statistics-switch-planned = Operações previstas { $state }
statistics-switch-debits = Montantes a débito { $state }
statistics-switch-credits = Montantes a crédito { $state }
statistics-switch-on = ON
statistics-switch-off = OFF

statistics-no-account = Não foi escolhida nenhuma conta: a estatística não incide sobre nada.
statistics-no-data = Nenhuma operação neste ano para as contas escolhidas.
statistics-detail-empty = Clique numa célula com valor para ver as operações que a compõem.
statistics-detail-none = Nenhuma operação por detrás desta célula.
statistics-accounts = { $count ->
    [one] 1 conta
   *[other] { $count } contas
}
statistics-year-next = Ano seguinte
statistics-year-previous = Ano anterior

statistics-column-date = Data
statistics-column-clearing-date = DataConciliação
statistics-column-label = Descrição
statistics-column-amount = Montante
statistics-column-comments = Comentários

accounts-stats-multiselect-help = Info: utilize Clique do rato + tecla [{ $modifier }] na tabela para escolher várias contas

statistics-year-question = Em que ano pretende trabalhar? O Radinus vai de { $first } a { $last }.
statistics-year-choose = Escolher o ano

# --- Exportação das tabelas (clique direito) --------------------------

export-to-excel = Exportar para Excel (.xlsx)
export-to-word = Exportar para Word (.docx)
export-to-tsv = Exportar para TSV (.tsv)
export-to-ini = Exportar para INI (.ini)
export-to-toml = Exportar para TOML (.toml)
export-to-yaml = Exportar para YAML (.yaml)
export-to-ofx = Exportar para OFX (.ofx)
export-to-qif = Exportar para QIF (.qif)
export-to-ods = Exportar para LibreOffice Calc (.ods)
export-to-csv = Exportar para CSV (.csv)
export-to-xml = Exportar para XML (.xml)
export-menu = Exportar
export-all-years-excel = Exportar todos os anos para Excel
export-all-years-ods = Exportar todos os anos para LibreOffice Calc
export-no-year = Nenhum ano tem operações: não há nada a exportar.
export-years-done = { $years } anos exportados para « { $file } ».
export-to-json = Exportar para JSON (.json)
export-done = Exportado para « { $file } ».
export-failed = Não foi possível exportar: { $reason }
export-nothing = Não há nada a exportar.
export-context = { $window } — { $detail }
statistics-window-name = { $kind ->
    [assignment] Estatísticas por afetação
    [budget-line] Estatísticas por rubrica orçamental
    [payment-mode] Estatísticas por meio de pagamento
    [payee] Estatísticas por terceiro e comerciante
    [project] Estatísticas por projeto
   *[category] Estatísticas por categoria
}
statistics-detail-name = Detalhe das estatísticas

# --- F19 — Painel de bordo --------------------------------------------

window-dashboard-title = Painel de bordo
dashboard-menu-period = Período
dashboard-menu-misc = Diversos
dashboard-from = Data de início:
dashboard-to = Data de fim:
dashboard-switch-pointed = Incluir operações conciliadas
dashboard-switch-committed = Incluir operações comprometidas
dashboard-switch-planned = Incluir operações previstas
dashboard-spending = Despesas
dashboard-earning = Ganhos
dashboard-debits = Soma das operações a débito
dashboard-credits = Soma das operações a crédito
dashboard-balance = Balanço
dashboard-unclassified = Sem rubrica orçamental
dashboard-nothing = Nenhuma operação neste período.
dashboard-no-account = Não foi escolhida nenhuma conta: o painel de bordo não incide sobre nada.
dashboard-enlarge = Abrir em grande

# --- F25 — Evolução do saldo ------------------------------------------

window-curve-title = Evolução do saldo
curve-heading = Evolução do saldo por dia
curve-menu-period = Período
curve-total = Total
curve-from = Data de início:
curve-to = Data de fim:
curve-axis-balance = saldo
curve-nothing = Não foi escolhida nenhuma conta: não há curva a traçar.
curve-empty = Nenhuma operação neste período.

# --- F05 — Classificação rápida das operações -------------------------

window-quick-classification-title = Classificação rápida das operações: { $account }
quick-dates-title = Datas de início e de fim da lista.
quick-from = Data de início
quick-to = Data de fim
quick-menu-period = Período
quick-change-title = Alterar as características da seleção para:
quick-check-category = Categoria
quick-check-assignment = Afetação
quick-check-payment-mode = Modo
quick-check-payee = Terceiro
quick-check-project = Projeto
quick-check-status = Estado
quick-column-date = Data
quick-column-label = Descrição
quick-column-amount = Montante
quick-column-category = Categoria
quick-column-assignment = Afetação
quick-column-payment-mode = Modo de pagamento
quick-column-payee = Terceiro
quick-column-project = Projetos
quick-column-status = Estado
quick-multiselect-help = Info: utilize Clique do rato + tecla [{ $modifier }] na tabela para selecionar vários elementos
quick-none = Nenhuma operação neste período.
quick-select-lines = Selecione pelo menos uma linha e marque pelo menos uma característica.
quick-applied = { $count ->
    [0] Nada mudou: estas linhas já tinham esta classificação.
    [one] 1 linha classificada. Ainda nada foi guardado.
   *[other] { $count } linhas classificadas. Ainda nada foi guardado.
}
quick-pending = { $count ->
    [0] Nenhuma alteração pendente.
    [one] 1 linha alterada, por guardar.
   *[other] { $count } linhas alteradas, por guardar.
}
quick-save-question = { $count ->
    [one] Guardar a alteração pendente?
   *[other] Guardar as { $count } alterações pendentes?
}
quick-saved = { $count ->
    [0] Não havia nada a guardar.
    [one] 1 linha guardada.
   *[other] { $count } linhas guardadas.
}
quick-nothing-to-save = Nenhuma alteração pendente.
quick-leave-question = Há alterações por guardar. O que pretende fazer?
quick-leave-save = Guardar e sair
quick-leave-discard = Abandonar e sair
quick-leave-stay = Ficar
quick-title-apply = Aplicar às linhas selecionadas ( em memória )
quick-title-save = Guardar no disco

# --- F17 / F18 — Importação de um extrato bancário --------------------

window-statement-import-title = Importação de extratos de contas bancárias: { $account }
window-statement-form-title = Conciliar uma transação (integra uma operação no histórico da sua conta)
statement-menu-filter = Filtro
statement-filter-all = Todas as linhas
statement-filter-pending = Por integrar
statement-filter-known = Já integradas
statement-column-id = ID
statement-column-reconciled = Conciliado
statement-column-fitid = FITID
statement-column-date = Data
statement-column-label = Descrição
statement-column-debit = Débito
statement-column-credit = Crédito
statement-account = Conta
statement-file = Ficheiro
statement-difference = Diferença
statement-none = Não há nenhum extrato aberto: clique na pasta amarela para escolher um ficheiro.
statement-empty = Este extrato não contém nenhuma operação.
statement-no-match = Nenhuma linha corresponde ao filtro.
statement-help = Info: utilize Clique do rato + tecla [{ $modifier }] na tabela para selecionar várias linhas
statement-choose-account = Este ficheiro contém várias contas. Qual pretende importar?
statement-select-line = Selecione pelo menos uma linha do extrato.
statement-title-open = Abrir um ficheiro de extrato (.ofx)
statement-title-info = Informações sobre o ficheiro aberto
statement-title-integrate = Integrar a seleção na conta
statement-title-validate = Integrar esta operação na conta
statement-duplicate = Atenção, duplicado: esta transação parece já ter sido integrada na base (o Financial Institution Transaction ID já existe)
statement-no-fitid = Atenção: este ficheiro não dá qualquer identificador (FITID) para esta linha. Não será possível detetar um duplicado.
statement-loaded = { $count ->
    [0] Este ficheiro não contém nenhuma operação para esta conta.
   *[other] { $count } linhas lidas, das quais { $known } já presentes na sua conta.
}
statement-integrated = { $count ->
    [0] Nada entrou: estas linhas já estão na sua conta.
    [one] 1 operação integrada.
   *[other] { $count } operações integradas.
}

statement-mass-question =
    Tem a certeza de que pretende integrar na sua conta várias operações em simultâneo?
    Terá de as categorizar e caracterizar mais tarde para obter estatísticas precisas.
    No caso dos ficheiros OFX: se forem detetados duplicados, terá de escolher o comportamento do programa.
    Para os outros tipos de ficheiro: terá de prestar atenção aos duplicados.
statement-duplicate-question =
    A transação: { $date } { $label }: { $amount }
    parece já ter sido integrada no histórico de transações da sua conta bancária.
    Pretende mesmo proceder à conciliação?
statement-already-reconciled = Já conciliou esta transação: ela já está integrada no histórico de transações da sua conta.
statement-integration-report =
    Fim da integração.
    Número de registos integrados: { $added }
    Número de registos ignorados: { $ignored }
statement-integration-abandoned =
    Integração abandonada!
    Número de registos integrados: { $added }
    Número de registos ignorados: { $ignored }
statement-yes = Sim
statement-no = Não
statement-cancel = Cancelar
statement-file-info =
    Conta do ficheiro: { $account }
    Período: de { $from } a { $to }
    Saldo anunciado pelo banco: { $balance }
    { $count } operações, das quais { $known } já presentes na sua conta.
statement-group-identification = Identificação da operação
statement-group-amount = Montante da operação
statement-group-classification = Classificação da operação para o cálculo das estatísticas
statement-group-status = Estado da operação
statement-field-date = Data
statement-field-label = Descrição
statement-field-type = Tipo de operação
statement-field-amount = Montante
statement-field-mode = Modo de pagamento
statement-field-category = Categoria
statement-field-assignment = Afetação
statement-field-payee = Terceiro
statement-field-project = Projeto
statement-field-status = Estado
statement-field-clearing = Data de conciliação

# --- A janela de recorte de um extrato CSV ----------------------------

window-csv-statement-title = Importação de dados provenientes de um ficheiro csv
csv-preview-title = Pré-visualização do ficheiro:
csv-settings-title = Parâmetros de recorte do ficheiro para a extração dos dados:
csv-extraction-title = Visualização da extração dos dados segundo os parâmetros de recorte  ( verifique a coerência dos dados ):
csv-column-line = N.º da linha
csv-column-content = Conteúdo
csv-header-lines = Número de linhas de cabeçalho do ficheiro a ignorar
csv-separator = Os dados (colunas) estão separados pelo carácter:
csv-date-at = Posição do campo data
csv-label-at = Posição do campo descrição
csv-debit-at = Posição do campo montante a débito
csv-credit-at = Posição do campo montante a crédito
csv-test = Testar os parâmetros
csv-separator-semicolon = Ponto e vírgula   ;
csv-separator-comma = Vírgula   ,
csv-separator-tab = Tabulação
csv-separator-pipe = Barra vertical   |
csv-separator-space = Espaço
csv-help = Regule, teste, observe: só serão importadas as linhas com uma data e um montante legíveis.
csv-none = O ficheiro está vazio.
csv-not-tested = Clique em « Testar os parâmetros » para ver o que o recorte produz.
csv-extraction = { $count ->
    [0] O recorte não produz nenhuma linha: verifique o número de linhas de cabeçalho e o separador.
   *[other] { $count } linhas recortadas: { $valid } serão importadas, { $dropped } postas de lado por falta de data ou de montante legível.
}
csv-nothing-valid = Nenhuma linha tem ao mesmo tempo uma data e um montante legíveis: não há nada a importar. Verifique o número de linhas de cabeçalho, o separador e a posição dos campos.
csv-title-validate = Passar as linhas válidas para a importação

# --- F13 / F31 / F14 / F12 — Livros de cheques e cheques --------------

window-chequebooks-title = Lista dos livros de cheques
window-chequebook-title = Parâmetros do livro de cheques
window-cheques-title = Composição do livro de cheques: lista dos cheques.
window-cheque-title = Ficha de cheques
window-cheque-operations-title = Lista das operações.

chequebooks-column-reference = NOME
chequebooks-column-date = Data
chequebooks-column-account = NomeConta
chequebooks-column-account-number = N.º da conta
chequebooks-column-comments = Comentários
chequebooks-none = Não há nenhum livro de cheques registado.
chequebooks-nothing-to-show = Nenhum livro de cheques corresponde a esta pesquisa.
chequebooks-title-composition = Ver a composição do livro de cheques
chequebooks-delete-question = Foram detetadas operações (transações bancárias) associadas a este livro de cheques. Confirma que pretende eliminá-lo?
chequebooks-deleted = { $count ->
    [one] Um livro de cheques eliminado.
   *[other] { $count } livros de cheques eliminados.
}
chequebooks-gone = Este livro de cheques já não existe.
chequebooks-created = Livro de cheques registado, com todos os seus cheques.
chequebooks-updated = Livro de cheques modificado.

chequebook-refusal-duplicate = Já existe uma referência com o mesmo nome
chequebook-refusal-reference-required = A introdução de uma referência é obrigatória
chequebook-refusal-number-too-big = Os números do primeiro e/ou do último cheque são demasiado grandes (valor máximo 999 999 999)
chequebook-refusal-date = Introduza uma data de receção válida
chequebook-refusal-numbers-required = Preencha os números do primeiro e do último cheque
chequebook-refusal-order = O número do primeiro cheque deve ser inferior ao número do último cheque
chequebook-refusal-account = Selecione obrigatoriamente a conta associada a este livro de cheques
chequebook-refusal-too-many = Número máximo de cheques por livro: 1000, limite atingido
chequebook-creation-question =
    Criação do livro de cheques com as seguintes características:
    - Número de cheques a gerar:{ $count }
    - Cheques numerados de { $first } a { $last }
    Atenção, estes dados não poderão ser alterados após a criação!

chequebook-field-id = Identificador de livro de cheques
chequebook-field-reference = Referência
chequebook-field-received = Fabricado ou recebido em
chequebook-field-first = Número do primeiro cheque
chequebook-field-last = Número do último cheque
chequebook-field-quantity = Número de cheques
chequebook-field-account = Associar à conta bancária:
chequebook-field-comments = Comentários
chequebook-locked = Os cheques deste livro já foram criados: a sua numeração já não se altera.
chequebook-account-missing = A conta bancária associada a este livro de cheques está ausente ou foi eliminada!

cheques-column-number = N.º do cheque
cheques-column-date = Data
cheques-column-place = Local
cheques-column-payee = Beneficiário
cheques-column-amount = Montante
cheques-column-status = Estado
cheques-column-comments = Comentários
cheques-column-operations = N.º de operações associadas
cheques-none = Este livro de cheques não contém nenhum cheque.
cheques-nothing-to-show = Nenhum cheque corresponde a esta pesquisa.
cheques-help = Clique na célula Estado para o alterar ; a lupa mostra as operações associadas, o elo associa uma.
cheques-title-linked = Ver as operações já associadas a este cheque
cheques-title-link = Associar uma operação a este cheque
cheques-status-changed = Estado do cheque modificado.

cheque-field-id = Identificador de cheque
cheque-field-number = Número do cheque
cheque-field-issued = Data de emissão
cheque-field-place = Local de emissão
cheque-field-payee = Beneficiário
cheque-field-amount = Montante
cheque-field-comments = Comentários
cheque-field-status = Estado do cheque
cheque-gone = Este cheque já não existe.
cheque-updated = Cheque modificado.

cheque-operations-linked-title = Lista das operações já associadas a este cheque.
cheque-operations-choose-title = Escolha uma operação para associar ao cheque
cheque-operations-column-account = Conta
cheque-operations-column-label = Nome
cheque-operations-column-date = Data
cheque-operations-column-clearing = Data de conciliação
cheque-operations-column-amount = Montante
cheque-operations-column-cheque = Cheque associado
cheque-operations-none-linked = Nenhuma operação está associada a este cheque.
cheque-operations-none = Esta conta não contém nenhuma operação.
cheque-operations-nothing-to-show = Nenhuma operação corresponde a esta pesquisa.
cheque-operations-help = As operações a negrito já têm um cheque.
cheque-operations-linked-help = A cruz vermelha separa o cheque da operação: nada é eliminado.
cheque-operations-linked = Operação associada ao cheque.
cheque-operations-dissociated = Cheque separado da operação.
cheque-operations-menu-filter = Filtro
cheque-title-associate = Associar esta operação ao cheque
cheque-title-dissociate = Separar o cheque desta operação

chequebooks-select-question = Escolha o livro de cheques
cheques-select-question = Escolha o cheque a associar à operação
operation-check-save-first = Guarde primeiro a operação: um cheque associa-se a uma operação que existe.
operation-check-none = Esta operação não tem nenhum cheque.

# --- F36 / F37 — Os modelos de operação --------------------------------

window-operation-templates-title = Lista dos modelos de operações
window-operation-template-title = Ficha de modelo de operação

operation-templates-none = Não há nenhum modelo de operação registado.
operation-templates-nothing-to-show = Nenhum modelo corresponde a esta pesquisa.
operation-templates-select-question = Escolha o modelo a aplicar
operation-templates-delete-question = Confirma a eliminação dos modelos selecionados?
operation-templates-deleted = { $count ->
    [one] Um modelo eliminado.
   *[other] { $count } modelos eliminados.
}
operation-template-gone = Este modelo já não existe.
operation-template-fresh = Novo modelo.
operation-template-created = Modelo registado.
operation-template-updated = Modelo modificado.
operation-template-label-required = A introdução de um nome é obrigatória
operation-template-duplicate = Já existe um modelo com o mesmo nome

operation-template-field-id = ID do modelo de operação
operation-template-group-name = Nome por defeito da futura operação após aplicação do modelo
operation-template-field-label = Nome
operation-template-group-amount = Montante por defeito da operação predefinido neste modelo
operation-template-field-direction = Tipo de operação
operation-template-field-amount = Montante
operation-template-group-status = Estado da operação por defeito neste modelo
operation-template-field-status = Estado da operação
operation-template-group-classification = Informações do modelo para a classificação e o cálculo das estatísticas
operation-template-field-category = Categoria
operation-template-field-assignment = Afetação
operation-template-field-mode = Modo
operation-template-field-payee = Terceiro
operation-template-field-project = Projeto

operation-template-question = O que pretende fazer com os modelos de operação?
operation-template-apply = Aplicar um modelo
operation-template-save-as = Guardar como modelo
operation-template-applied = Modelo aplicado. Valide a ficha para o guardar.
operation-template-saved-as = Operação guardada como modelo.
operation-template-needs-label = Dê um nome à operação antes de fazer dela um modelo.

# --- F26 / F27 — O orçamento -------------------------------------------

window-budget-entry-title = Introdução do orçamento: despesas(-) e receitas(+) previstas num ano
window-budget-control-title = Controlo do orçamento

budget-column-line = Rubrica orçamental
budget-none = Não há nenhuma rubrica orçamental registada: o orçamento introduz-se por rubrica.
budget-planned = Previsto
budget-actual = Realizado
budget-sum = Soma
budget-cumulative = Acumulado
budget-total = Total
budget-sign-warning = Introduza obrigatoriamente as despesas  com sinal negativo e as receitas previstas com montantes positivos
budget-entry-help = Escreva os montantes nas células e depois guarde.
budget-saved = Orçamento guardado.
budget-nothing-changed = Nenhuma alteração a guardar.
budget-discard-question = Abandonar as alterações do orçamento?

budget-menu-display = Apresentação
budget-display-money = Valores
budget-display-percent = Percentagens
budget-control-help = Verde: pelo menos tão bem como previsto. Vermelho: pior.

# --- F09 — Transferência entre duas contas -----------------------------

window-transfer-title = Transferir um montante entre duas contas

transfer-group-source = Debitar o montante nesta conta de origem
transfer-group-target = Creditar o montante nesta conta de destino
transfer-group-description = Descrição da operação
transfer-group-nomenclature = Informações de nomenclatura
transfer-group-amount = Montante da quantia a transferir
transfer-field-source = Conta de origem
transfer-field-target = Conta de destino
transfer-field-label = Descrição
transfer-field-reference = Referência de pagamento
transfer-field-date = Data
transfer-field-status = Estado da operação
transfer-field-clearing = Data de conciliação
transfer-field-category = Categoria
transfer-field-mode = Modo de pagamento
transfer-field-assignment = Afetação
transfer-field-payee = Terceiros / comerciantes
transfer-field-project = Projeto
transfer-field-amount = Montante

ui-ok = OK
transfer-help = Escolha as duas contas: os seus saldos aparecem aqui.
transfer-title-validate = Efetuar a transferência
transfer-balances = { $account } — No banco: { $bank } · Real: { $real } · Final: { $final }
transfer-done = Transferência efetuada. { $amount } da conta { $source } para a conta { $target }, em { $date }.

transfer-refusal-accounts-required = Escolha a conta de origem e a conta de destino
transfer-refusal-same-account = A conta de origem e a conta de destino não podem ser a mesma: uma transferência vai de uma conta para outra
transfer-refusal-account-gone = Uma das duas contas já não existe
transfer-refusal-label-required = A descrição é obrigatória
transfer-refusal-date-required = A data é obrigatória
transfer-refusal-amount = O montante a transferir deve ser estritamente positivo

# ---------------------------------------------------------------------------
# A importação de uma folha Excel (F34, F35, associação).
# ---------------------------------------------------------------------------

window-excel-import-title = Importação de folha Excel [ Etapa 1/3 ]: definição da zona de captura
window-excel-fields-title = Importação de folha Excel [ Etapa 2/3 ]: associação dos campos
window-excel-association-title = Importação de folha Excel: associação dos dados

excel-backup-question = Uma folha Excel é feita à mão: pode conter datas certas mas falsas, montantes com o formato certo e o sinal errado — e isso nenhum controlo consegue ver. A importação escreverá estas linhas na sua conta. Pretende salvaguardar os seus dados antes de começar?

excel-group-file = 1 - Designar o ficheiro Excel a importar
excel-pick = Designar o ficheiro Excel
excel-sheet = Folha do livro:
excel-group-header = 2 - Definir: coordenadas das células da linha de cabeçalho da tabela onde estão escritos os nomes das colunas.
excel-header-row = Número da 1.ª linha onde está o nome das colunas
excel-first-column = Coluna de início do cabeçalho ( a coluna mais à esquerda ):
excel-column-count = Número de colunas da tabela
excel-group-rows = 3 - Definir: números das linhas de início e de fim da lista que contém os dados da tabela ( abaixo do cabeçalho e sem o incluir )
excel-first-data-row = Primeira linha que contém dados
excel-last-data-row = Última linha que contém dados:
excel-group-shape = 4 - Definir: como o seu ficheiro escreve os montantes
excel-shape-single = Uma única coluna de montantes, com sinal ( as despesas em negativo )
excel-shape-debit-credit = Duas colunas separadas: uma coluna Débito e uma coluna Crédito
excel-shape-note = No modo de duas colunas, o sinal escrito na coluna Débito não é tido em conta: um débito tira sempre dinheiro, quer esteja escrito « -50 » quer « 50 ».
excel-group-test = 5 - Teste: visualize a captura efetuada em função dos seus parâmetros
excel-test = Teste os parâmetros que definiu nas etapas 2, 3 e 4.
excel-test-note = Indicação: o nome dos cabeçalhos e o conteúdo da tabela abaixo devem corresponder aos da sua tabela Excel. A zona de captura não deve sair da zona da tabela.

excel-help = Percorra os cinco grupos por ordem e depois teste: só poderá passar à etapa 2 depois de ver o que a zona apanha.
excel-no-file = Designe primeiro o ficheiro Excel a importar.
excel-not-tested = Parâmetros alterados: volte a executar o teste antes de validar.
excel-tested = Zona capturada: { $rows } linhas, { $columns } colunas. Verifique se a tabela abaixo se parece com a sua folha.
excel-empty-capture = A zona que declarou não apanha nenhuma linha: verifique os números de linha e de coluna.
excel-title-next = Passar à etapa seguinte
excel-into-account = Importação para a conta { $account }.

excel-tab-links = Ligações entre campos
excel-tab-settings = Parâmetros de importação
excel-column-excel = Cabeçalho_Excel
excel-column-radinus = Rubrica_Radinus
excel-links-help = À frente de cada coluna da sua folha, diga que rubrica do Radinus ela alimenta. As colunas deixadas em [IGNORE] não são importadas.
excel-group-category = Categorias sem correspondência
excel-group-payment-mode = Modos de pagamento sem correspondência
excel-group-assignment = Afetações sem correspondência
excel-policy-create = { $kind ->
    [payment-mode] Criar automaticamente os modos de pagamento inexistentes
    [assignment] Criar automaticamente as afetações inexistentes
   *[category] Criar automaticamente as categorias inexistentes
}
excel-policy-ask = { $kind ->
    [payment-mode] Perguntar, para cada modo de pagamento inexistente, para onde transferir os dados
    [assignment] Perguntar, para cada afetação inexistente, para onde transferir os dados
   *[category] Perguntar, para cada categoria inexistente, para onde transferir os dados
}
excel-policy-blank = { $kind ->
    [payment-mode] Deixar o modo de pagamento em branco
    [assignment] Deixar a afetação em branco
   *[category] Deixar a categoria em branco
}
excel-policy-default = { $kind ->
    [payment-mode] Transferir os modos de pagamento inexistentes para um modo de pagamento por defeito
    [assignment] Transferir as afetações inexistentes para uma afetação por defeito
   *[category] Transferir as categorias inexistentes para uma categoria por defeito
}
excel-define-destination = Definir destino
excel-not-linked = { $kind ->
    [payment-mode] Nenhuma coluna alimenta o modo de pagamento: este ajuste não se aplica.
    [assignment] Nenhuma coluna alimenta a afetação: este ajuste não se aplica.
   *[category] Nenhuma coluna alimenta a categoria: este ajuste não se aplica.
}
excel-fields-help = Regule as correspondências e depois as três políticas, antes de lançar a importação.
excel-title-import = Lançar a importação

excel-refusal-required = As rubricas Data, Descrição e Montante devem obrigatoriamente apontar para colunas do Excel
excel-refusal-column-twice = Rubricas diferentes do Radinus apontam para a mesma coluna do Excel: uma coluna só pode alimentar uma rubrica
excel-refusal-field-twice = A mesma rubrica do Radinus está associada a duas colunas do Excel: só pode ter uma
excel-refusal-ask-unset = { $kind ->
    [payment-mode] Escolheu perguntar para onde transferir os modos de pagamento desconhecidos: prima « Definir destino » antes de lançar a importação.
    [assignment] Escolheu perguntar para onde transferir as afetações desconhecidas: prima « Definir destino » antes de lançar a importação.
   *[category] Escolheu perguntar para onde transferir as categorias desconhecidas: prima « Definir destino » antes de lançar a importação.
}

excel-column-data = Dados_Excel
excel-column-destination = { $kind ->
    [payment-mode] MeioPagamento_Radinus
    [assignment] Afetacao_Radinus
   *[category] Categoria_Radinus
}
excel-association-help = À frente de cada valor vindo da sua folha, escolha aquele do Radinus onde ele deve ser arrumado. Uma linha deixada vazia ficará sem classificação.
excel-association-none = Nenhum valor desconhecido: tudo o que a sua folha contém já existe no Radinus.

excel-imported = Importação terminada: { $count } operações escritas, { $refused } linhas recusadas, { $created } valores de nomenclatura criados.
excel-report-title = Relatório da importação
excel-column-row = Linha do Excel
excel-column-content = Conteúdo
excel-column-reason = Motivo da recusa
excel-nothing-refused = Todas as linhas da sua folha entraram: nenhuma recusa.

excel-refused-date = Data ausente ou ilegível
excel-refused-amount = Montante ausente ou ilegível
excel-refused-amount-both = Um montante na coluna Débito e outro na coluna Crédito: impossível escolher
excel-refused-amount-missing = Nem débito nem crédito nesta linha

# ---------------------------------------------------------------------------
# As operações periódicas (F15, F38, F16).
# ---------------------------------------------------------------------------

window-recurring-list-title = Lista das operações periódicas
window-recurring-form-title = Ficha que define a regra de geração de operação periódica
window-recurring-calendar-title = Proposta de calendário das operações a inserir nas suas contas bancárias

recurring-column-label = NOME
recurring-none = Não há nenhuma regra periódica registada.
recurring-help = Escolha uma regra e depois o calendário para ver as datas que ela propõe.
recurring-title-calendar = Propor o calendário das datas
recurring-deleted = { $count ->
    [0] Nenhuma regra eliminada.
    [one] Uma regra eliminada. As suas operações ficam na conta.
   *[other] { $count } regras eliminadas. As suas operações ficam nas contas.
}
recurring-gone = Esta regra já não existe.
recurring-delete-question = Eliminar as regras selecionadas? As operações que já inseriram ficarão nas suas contas.

recurring-group-identity = Identificação e conta bancária em causa
recurring-group-nomenclature = Nomenclatura
recurring-group-amount = Definição do montante da operação
recurring-group-period = Definição do período
recurring-group-ending = Condições de fim do período
recurring-group-produced = Informações sobre as operações já inseridas ( apenas para consulta )

recurring-field-id = Identificador de operação
recurring-field-account = Conta de destino
recurring-field-label = Descrição
recurring-field-category = Categoria
recurring-field-mode = Modo de pagamento
recurring-field-assignment = Afetação
recurring-field-payee = Terceiros / comerciantes
recurring-field-project = Projeto
recurring-field-direction = Tipo de operação
recurring-field-amount = Montante
recurring-field-next = Data da próxima operação
recurring-field-every = Depois, a cada
recurring-field-end-date = Data de fim
recurring-field-repeat = Número de repetições
recurring-field-guid = GUID da operação
recurring-field-produced-count = Número de operações inseridas
recurring-field-produced-last = Data da última operação inserida
recurring-field-produced-total = Total dos montantes gerados

recurring-unit-day = Dia
recurring-unit-week = Semana
recurring-unit-month = Mês
recurring-unit-quarter = Trimestre
recurring-unit-year = Ano
recurring-ending-no-limit = Sem limite
recurring-ending-until-date = Com data de fim
recurring-ending-repeat-count = Número de repetições

recurring-title-erase = Apagar as operações já inseridas por esta regra
recurring-erase-question = { $count ->
    [one] Esta regra inseriu uma operação nas suas contas. Pretende apagá-la? Os saldos serão recalculados e a regra não recuará.
   *[other] Esta regra inseriu { $count } operações nas suas contas. Pretende apagá-las todas? Os saldos serão recalculados e a regra não recuará.
}
recurring-erase-none = Esta regra ainda não inseriu nenhuma operação.
recurring-erased = { $count ->
    [0] Nenhuma operação apagada.
    [one] Uma operação apagada, saldos recalculados.
   *[other] { $count } operações apagadas, saldos recalculados.
}

recurring-calendar-help = Retire com o caixote as datas que não pretende e valide para as inserir.
recurring-calendar-none = Nenhuma data a propor: verifique a data da próxima operação e a conta das suas regras.
recurring-calendar-column-account = Conta
recurring-calendar-column-date = Data
recurring-calendar-column-label = Descrição
recurring-calendar-column-amount = Montante
recurring-calendar-column-category = Categoria
recurring-calendar-column-assignment = Afetação
recurring-calendar-column-mode = Modo de pagamento
recurring-calendar-column-payee = Terceiro
recurring-calendar-column-project = Projetos
recurring-calendar-removed = { $count ->
    [one] Uma data retirada da proposta.
   *[other] { $count } datas retiradas da proposta.
}
recurring-title-insert = Inserir nas contas as datas mantidas
recurring-nothing = Não resta nenhuma data a inserir.
recurring-insert-question = { $count ->
    [one] Inserir esta data na sua conta? Será criada uma operação e os saldos serão recalculados.
   *[other] Inserir estas { $count } datas nas suas contas? Serão criadas outras tantas operações e os saldos recalculados.
}
recurring-inserted = { $count ->
    [one] Uma operação inserida. A regra recomeça depois da última data inserida.
   *[other] { $count } operações inseridas. As regras recomeçam depois da sua última data inserida.
}

recurring-refusal-label-required = A introdução de uma descrição é obrigatória
recurring-refusal-date-required = A introdução da data da próxima operação é obrigatória
recurring-refusal-date-too-old = A data da próxima operação deve ser superior ou igual ao ano 2000
recurring-refusal-account-gone = A conta bancária indicada não foi encontrada ; escolha outra para tornar a regra aplicável
recurring-refusal-end-required = Havendo data de fim, essa data deve ser introduzida
recurring-refusal-end-before-start = A data de fim não pode ser anterior à data da próxima operação
recurring-refusal-end-too-far = O intervalo entre a data da próxima operação e a data de fim não pode exceder 10 000 dias

# --- Impressões e mapas -------------------------------------------------
print-operations-title = Lista das transações bancárias e suboperações
print-menu-operations-pdf = Impressão para ficheiro PDF
print-recap-title = Resumo por categoria
print-recap-count = Linhas
print-row-count = Número de linhas:
print-total-debit = Total a débito:
print-total-credit = Total a crédito:
print-final-balance = Saldo final:
print-licence = O Radinus é software livre distribuído sob a licença GNU GPL v3 ou posterior
print-nothing = Não há nada a imprimir.
print-done = Mapa impresso e aberto: « { $file } ».
print-failed = Não foi possível imprimir: { $reason }
print-not-opened = Mapa impresso em « { $file } », mas o seu sistema não o soube abrir sozinho.

# --- O mapa NIB (F32) ---------------------------------------------------
rib-title = IDENTIFICAÇÃO BANCÁRIA
rib-bank = Banco:
rib-national = NIB - Número de identificação bancária
rib-establishment = INSTITUIÇÃO
rib-branch = BALCÃO
rib-number = NÚMERO DA CONTA
rib-key = CHAVE DE CONTROLO
rib-domiciliation = DOMICILIAÇÃO
rib-iban = IBAN - Identificador internacional de conta
rib-bic = BIC - Identificador internacional da instituição
rib-holder = Titular da conta

window-rib-title = Impressão da identificação bancária ( NIB )
rib-group-bank = Banco
rib-group-holder = Titular da conta
rib-group-details = Coordenadas bancárias
rib-field-bank = Nome do banco
rib-field-domiciliation = Domiciliação
rib-field-holder = Nome do titular
rib-field-address = Morada
rib-field-establishment = Instituição
rib-field-branch = Balcão
rib-field-number = Número da conta
rib-field-key = Chave de controlo
rib-field-bic = BIC (Bank Identifier Code)
rib-field-iban = IBAN (International Bank Account Number )
rib-conditions = Importante: condições de utilização a respeitar obrigatoriamente em caso de impressão
rib-declaration = Eu, abaixo assinado, utilizador do programa, declaro sob compromisso de honra:
rib-declaration-first = - Confirmo ter verificado junto do meu banco que as informações bancárias contidas nesta janela estão corretas e conformes à minha vontade. Confirmo do mesmo modo que me comprometo a verificar que as informações contidas no mapa de impressão da identificação bancária estão corretas e conformes à minha vontade. Esta impressão e a utilização da identificação bancária far-se-ão sob a minha inteira responsabilidade.
rib-declaration-second = - Ser o titular da conta cuja identificação bancária será impressa, e não me servir das funções deste programa para fins contrários à lei.
rib-title-print = Impressão na impressora
rib-title-pdf = Impressão para ficheiro PDF
rib-declaration-required = Assinale a declaração de honra para poder imprimir.
rib-help = Verifique as suas coordenadas, assinale a declaração e depois imprima.
rib-account-gone = Esta conta bancária não foi encontrada.
rib-fields-read-only = Estas coordenadas vêm da ficha da conta: corrija-as na ficha para as alterar aqui.
rib-printed = Identificação bancária enviada para a sua impressora por defeito.
rib-print-failed = Não foi possível imprimir: { $reason }
rib-pdf-done = Identificação bancária impressa e aberta: « { $file } ».
rib-pdf-not-opened = Identificação bancária impressa em « { $file } », mas o seu sistema não a soube abrir sozinho.
menu-accounts-bank-details = Editar uma identificação bancária

print-choose-printer = Em que impressora pretende imprimir?
print-do-print = Imprimir
rib-printed-on = Identificação bancária enviada para a impressora « { $printer } ».
ui-cancel = Cancelar

print-printers-unknown = O seu sistema não soube nomear nenhuma impressora: o documento seguiu para a impressora por defeito.

print-menu-operations-printer = Impressão na impressora
print-sent-on = Mapa enviado para a impressora « { $printer } ».
print-sent-default = Mapa enviado para a sua impressora por defeito.

# --- As operações sobre a base de dados ---------------------------------
backup-archive = Arquivo Radinus
backup-no-database = Não há nenhuma base de dados aberta.
backup-done = Cópia de segurança escrita em « { $file } ».
backup-failed = Não foi possível fazer a cópia de segurança: { $reason }
backup-not-started = Não foi possível iniciar a cópia de segurança:
restore-unreadable = Este ficheiro não é um arquivo Radinus legível: { $reason }
restore-question = Restaurar « { $file } »? Todo o conteúdo atual da sua base será apagado e substituído, e o que lá estiver perder-se-á.
restore-done = Restauro terminado: { $accounts } contas e { $operations } operações.
restore-failed = Não foi possível restaurar: { $reason }
restore-empty-fields = Campos vazios lidos como valor nulo: { $count }.


# --- O registo das operações técnicas -----------------------------------
journal-status-success = SUCESSO
journal-status-failure = FALHA
journal-status-repaired = REPARADO
journal-step-reindex = Reparação da tabela da base de dados
journal-step-refill = Nomenclatura do sistema vazia: valores por defeito repostos
journal-step-table-created = Tabela ausente da base de dados: recriada vazia
journal-step-column-added = Coluna ausente da tabela: adicionada com o seu valor por defeito

# --- Protection par mot de passe (05/08/2026) ---
password-protect = Proteção por palavra-passe
window-password-form-title = Proteção por palavra-passe
password-ask = Esta base está protegida. Introduza a sua palavra-passe.
password-group-database = Base em causa
password-group-password = Palavra-passe
password-group-warning = Antes de confirmar
password-field-old = Palavra-passe anterior
password-field-new = Nova palavra-passe
password-field-repeat = Repita a nova palavra-passe
password-hint = Deixe a anterior vazia se a base ainda não estiver protegida. Deixe as duas novas vazias para retirar a proteção.
password-lost-warning = Uma palavra-passe perdida é uma base perdida: nada permite recuperá-la. As cópias de segurança, essas, ficam sem cifra.
password-show = Mostrar a palavra-passe
password-remove-question = Retirar a proteção desta base?
password-mismatch = As duas introduções da nova palavra-passe são diferentes
password-wrong = A palavra-passe não serve
password-close-first = Feche esta base antes de mudar a sua palavra-passe
password-now-protected = A base está protegida por uma palavra-passe
password-now-clear = A base já não está protegida
journal-step-date-fixed = Correção de uma operação sem data
journal-step-circular = Eliminação de uma operação incoerente: referência circular
journal-step-flag-parent-true = Marca EstParent=Falso errada numa operação principal
journal-step-flag-parent-false = Marca EstParent=Verdadeiro errada numa operação principal
journal-step-flag-child = Marca EstParent=Verdadeiro errada numa suboperação
journal-step-orphan = Eliminação de uma suboperação órfã
journal-step-third-level = Eliminação de uma suboperação ligada a outra suboperação
journal-step-coherence = Recálculo geral da coerência entre suboperações e operações principais
journal-step-balances = Recálculo de todos os saldos de todas as contas
journal-step-vacuum = Otimização do ficheiro da base de dados
journal-step-analyze = Atualização das estatísticas de pesquisa
journal-step-backup-begin = Início da cópia de segurança da base
journal-step-backup-end = Fim da cópia de segurança da base
journal-step-restore-begin = Início do restauro da base a partir do arquivo
journal-step-restore-end = Fim do restauro da base a partir do arquivo
journal-step-restore-read = Leitura do arquivo

window-journal-title = Registo da última operação técnica
journal-column-step = Etapa
journal-column-file = Ficheiro
journal-column-table = Tabela
journal-column-status = Estado
journal-column-error = Erro
journal-column-comments = Comentários
journal-empty = Ainda não foi efetuada nenhuma operação técnica desde a abertura do programa.
journal-help = O registo só guarda a última operação técnica: cópia de segurança, restauro, reparação, apagamento ou abertura de uma base.

menu-file-repair-running = Reparação e otimização em curso…
repair-done = { $anomalies ->
    [0] Reparação terminada: nenhuma anomalia encontrada. { $lines } etapas registadas.
    [one] Reparação terminada: uma anomalia reparada. { $lines } etapas registadas.
   *[other] Reparação terminada: { $anomalies } anomalias reparadas. { $lines } etapas registadas.
}
repair-failed = Não foi possível reparar: { $reason }

journal-status-started = EM CURSO
journal-status-finished = TERMINADO
journal-step-backup-table = Escrita da tabela no arquivo
journal-step-backup-write = Escrita do arquivo
journal-step-backup-verified = Verificação do arquivo escrito: ficheiros relidos / esperados, registos relidos / escritos
journal-step-backup-total = Total salvaguardado: registos, dados, tamanho do ficheiro
journal-step-restore-table = Leitura da tabela no arquivo
journal-step-restore-missing = Ficheiro ausente do arquivo: esta tabela não será restaurada
journal-step-restore-wipe = Apagamento total do conteúdo da base antes do restauro
journal-step-restore-write = Escrita na base
journal-step-restore-total = Total restaurado: contas, operações
journal-step-restore-empty-fields = Campos vazios preenchidos durante a leitura
backup-verify-mismatch = O arquivo escrito não se relê tal como foi escrito: não confie nele, refaça a cópia de segurança.

# --- Os anexos de uma operação (F28) ------------------------------------
window-attachments-title = Anexos da operação
attachment-filter = Documentos aceites
attachment-none = Esta operação não tem nenhum anexo.
attachment-title-add = Anexar um documento a esta operação
attachment-title-open = Abrir o anexo
attachment-title-remove = Retirar o anexo e enviar o seu ficheiro para a reciclagem
attachment-state-ok = Intacto
attachment-state-changed = Modificado
attachment-state-missing = Ficheiro ausente
attachment-state-unknown = Não verificável
attachment-added = « { $name } » foi anexado à operação.
attachment-removed = Anexo retirado, o seu ficheiro está na reciclagem.
attachment-removed-kept = Anexo retirado, mas não foi possível enviar o seu ficheiro para a reciclagem.
attachment-remove-question = Retirar « { $name } » desta operação? O seu ficheiro será enviado para a reciclagem.
attachment-opened = « { $name } » foi aberto.
attachment-opened-changed = « { $name } » foi aberto, mas o seu conteúdo mudou desde que foi anexado.
attachment-gone = Este anexo já não existe.
attachment-file-missing = O ficheiro de « { $name } » não foi encontrado no disco.
attachment-failed = Operação impossível: { $reason }
attachment-save-first = Guarde primeiro a operação: um anexo liga-se a uma operação que existe.
attachment-refusal-missing = Este ficheiro não existe.
attachment-refusal-extension = Este tipo de ficheiro não é aceite. São aceites: pdf, jpeg, jpg, png, bmp, tiff, gif, webp, xls, xlsx, doc, docx, odt, rtf, txt, json, xml.
attachment-refusal-operation = A operação a que anexar este documento não existe.
journal-step-backup-attachments = Anexos acrescentados ao arquivo
journal-step-backup-attachment-missing = Anexo não encontrado no disco: faltará no arquivo
journal-step-restore-attachments = Anexos retirados do arquivo
attachment-title-replace = Substituir o documento deste anexo
attachment-replaced = O documento foi substituído por « { $name } ».

# ---------------------------------------------------------------------
# F08 — o menu « Ferramentas » da ficha de conta.
# ---------------------------------------------------------------------

account-tools = Ferramentas
account-tools-initial-balance = Definir o saldo inicial conciliado
account-tools-statistics = Estatísticas da conta bancária
account-tools-delete-operations = Eliminar todas as transações da conta

account-initial-balance-question =
    Para calcular o saldo inicial conciliado face às operações presentes nesta conta, indique o saldo atual do seu banco.
    O saldo inicial conciliado será calculado como sendo igual a:
    { "[" }Saldo bancário atual] - [Total das operações conciliadas ({ $total }) ].
    { "" }
    Para não ter de voltar a introduzir este valor, deve estar totalmente em dia com a lista das operações bancárias desta conta.

account-statistics-none = Nenhuma transação

account-statistics =
    Número total de transações nesta conta: { $count }
    { "" }
    Número de transações conciliadas nesta conta: { $pointed }
    Montante dos débitos conciliados: { $pointedDebits }
    Montante dos créditos conciliados: { $pointedCredits }
    Diferença entre créditos e débitos conciliados: { $pointedDifference }
    { "" }
    Número de transações comprometidas nesta conta: { $committed }
    Montante dos débitos comprometidos: { $committedDebits }
    Montante dos créditos comprometidos: { $committedCredits }
    Diferença entre créditos e débitos comprometidos: { $committedDifference }
    { "" }
    Número de transações previstas nesta conta: { $planned }
    Montante dos débitos previstos: { $plannedDebits }
    Montante dos créditos previstos: { $plannedCredits }
    Diferença entre créditos e débitos previstos: { $plannedDifference }
    { "" }
    Transação mais antiga: { $first }
    Transação mais recente: { $last }

account-delete-operations-question =
    Tem a certeza de que pretende eliminar todas as operações contidas nesta conta bancária?
    Para o confirmar, escreva { $word } no campo abaixo e valide.

account-delete-operations-done =
    { $count ->
        [0] Nenhuma transação eliminada.
        [one] 1 transação eliminada.
       *[other] { $count } transações eliminadas.
    }


# ---------------------------------------------------------------------
# O seletor de bases e a escolha do idioma (02/08/2026)
#
# Decisões tomadas em conversa com Fabrice: o Radinus já não cria nenhuma
# base sem autorização; sem idioma na configuração, pergunta o idioma
# antes de tudo o resto; é uma base qualquer pasta de databases/ que
# contenha um radinus.sqlite, seja qual for o seu nome.
#
# A janela da escolha do idioma não tem aqui nenhuma chave: não emprega
# nenhuma frase, e é isso que lhe permite ser compreendida antes de se
# saber que língua fala o utilizador.
# ---------------------------------------------------------------------

window-database-selector-title = Bases de dados
window-database-form-title = Nova base de dados
database-group-identity = Identificação da base de dados
database-group-restore = Inicializar a base com os dados de um backup
database-choose-backup = Selecionar ficheiro de backup
database-no-backup = Nenhum backup escolhido: a base nascerá vazia.

databases-column-label = Base
databases-column-comment = Comentário
databases-column-folder = Pasta
databases-column-created = Criada em

databases-none = Nenhuma base por enquanto: crie uma.
databases-help = Escolha a base a abrir, ou crie uma nova.
databases-select = Escolha primeiro uma base na lista.
databases-tools = Ferramentas
databases-title-open = Abrir esta base

database-created = A base «{ $label }» está criada.
database-field-label = Nome da base
database-field-comment = Comentário
database-label-required = Dê um nome a esta base: é ele que a distinguirá das outras.
database-gone = Esta base já não está aqui: foi movida ou apagada desde que esta janela foi aberta.

# A eliminação de uma base (02/08/2026). A pasta vai para a reciclagem do
# sistema, tal como os anexos: uma base apagada por engano recupera-se com um
# clique direito. A base aberta é recusada — o Radinus tem o seu ficheiro.
databases-title-delete = Eliminar esta base
database-delete-question =
    Tem a certeza de que pretende eliminar a base «{ $label }»?
    { "" }
    Toda a sua pasta vai para a reciclagem: as operações, as contas e os anexos.
    Para o confirmar, escreva { $word } no campo abaixo e valide.
database-in-use = Esta base está aberta: o Radinus não a pode eliminar. Abra outra primeiro.
database-deleted = A base «{ $label }» está na reciclagem.

# O seletor tem dois modos (Fabrice, 02/08/2026). Aberto durante a
# utilização, já não sabe abrir: uma janela do Radinus é construída uma vez e
# nunca destruída, e nada a poderia fazer esquecer a base que mostra.
# Consulta-se, cria-se, elimina-se — e para mudar de base, sai-se.
database-quit-first = Para abrir esta base, saia do Radinus e volte a lançá-lo: o seletor propor-lha-á no arranque.


# --- F01 — a janela de boas-vindas (fase 17 bis, 03/08/2026) -------------
#
# Primeiro acrescento da 2.0.0 sobre a 1.9.3: a janela de boas-vindas já não
# leva apenas o cartaz. A regra que a governa está escrita no documento 04 F01:
# é a vista SEM UM CLIQUE, e nada do que exija uma regulação lhe entra.
#
# Os dois títulos de anel levam o mês inteiro em vez de serem colados ponta a
# ponta pela janela: «Despesas ... — agosto de 2026» não tem a mesma ordem de
# palavras nas várias línguas, e só o Fluent sabe onde está o buraco.

window-main-title = Radinus
welcome-month = { $month } de { $year }
welcome-accounts-count = { $count ->
    [0] Nenhuma conta aberta
    [one] 1 conta aberta
   *[other] { $count } contas abertas
}
welcome-total-bank = Saldo no banco
welcome-total-real = Saldo real
welcome-total-final = Saldo final
welcome-total-real-detail = conciliado + comprometido
welcome-total-final-detail = conciliado + comprometido + previsto
welcome-accounts = As suas contas
welcome-tile-bank = No banco
welcome-tile-real = Real
welcome-tile-final = Final
welcome-spending = Despesas — { $month }
welcome-earning = Ganhos — { $month }
ui-legend-budget-lines = Rubricas orçamentais
ui-legend-categories = Categorias
welcome-nothing = Nenhuma operação neste mês.
welcome-open-account = Informação: clique numa conta para abrir as suas operações.
welcome-no-account = Ainda não há nenhuma conta bancária.
welcome-no-account-create = Crie uma conta bancária clicando aqui
welcome-previous-month = Mês anterior
welcome-next-month = Mês seguinte
welcome-refresh = Reler tudo


# --- F39 — as preferências (fase 17 ter, 03/08/2026) ---------------------
#
# O lugar do sinal monetário vive aqui, ao lado dos dois separadores: segue a
# língua e não a moeda. «before» põe o sinal à frente do número, qualquer
# outro valor põe-no atrás. NENHUM sinal monetário está escrito neste
# ficheiro: «português» não quer dizer «euro».

ui-money-sign-position = after
window-preferences-title = Preferências
menu-settings-preferences = Preferências…
menu-settings-show-main = Mostrar a janela principal
menu-settings-folders = Pastas do Radinus
preferences-branch-display = Visualização
preferences-leaf-language = Idioma
preferences-leaf-currency = Moeda
preferences-field-language = Idioma do programa:
preferences-field-currency = Moeda apresentada:
preferences-field-custom = Sinal da moeda:
preferences-currency-system = Moeda do sistema
preferences-currency-euro = Euros
preferences-currency-dollar = Dólares
preferences-currency-canadian = Dólares canadianos
preferences-currency-cfa = Francos CFA
preferences-currency-cfp = Francos Pacífico
preferences-currency-swiss = Francos suíços
preferences-currency-none = Nenhuma
preferences-currency-custom = Personalizada
preferences-currency-system-is = O seu sistema anuncia:
preferences-currency-system-silent = O seu sistema não anuncia nenhuma moeda: os montantes serão apresentados em euros.
preferences-custom-required = Escreva o sinal da sua moeda antes de guardar.
preferences-saved = Preferências guardadas.
preferences-help = Escolha uma opção na árvore e depois guarde.
preferences-sign-too-long = O sinal de uma moeda cabe em 8 caracteres no máximo.
preferences-sign-not-a-number = O sinal de uma moeda não pode conter algarismos, nem sinais de cálculo, nem vírgulas: o Radinus retira-os quando lê um montante, e «120» tornar-se-ia «12».
preferences-leaf-zoom = Tamanho da visualização
preferences-field-zoom = Ampliação:
preferences-zoom-reset = Valor por omissão
preferences-zoom-hint = Tudo aumenta em conjunto: o texto, os ícones, as colunas. Abaixo de 100 %, cabe mais no ecrã. A barra de menus do sistema e as suas caixas de diálogo, essas, seguem as definições do seu computador e não estas.


# --- O cartaz das boas-vindas --------------------------------------------
#
# Estas frases estavam escritas em duro no `index.html` desde a fase 0 e não
# se traduziam, portanto (assinalado por Fabrice a 03/08/2026). O lema é a sua
# voz: as versões estrangeiras são propostas, a corrigir por ele — um lema não
# se traduz palavra a palavra.
ui-language-tag = pt
welcome-banner-title = Radinus
welcome-mascot-alt = Radinus — o esquilo mascote, de fato, rodeado de um euro, de uma calculadora e de gráficos
welcome-slogan-one = Um programa de gestão de finanças pessoais que o ajuda a gastar menos para ganhar mais
welcome-slogan-two = Com o Radinus compreenderá porque é que os pequenos ribeiros fazem os grandes rios.

# --- «Acerca do autor» ---------------------------------------------------
#
# O nome e a morada estão escritos de forma idêntica em todos os ficheiros:
# não se traduzem. Estão aqui mesmo assim, e não na página, para que a vista
# não leve nenhuma frase — e para que se corrijam num só sítio no dia em que o
# autor mudar de casa.
about-author-name = Auteur : Fabrice Garcia
about-author-place = 20290 Borgo, Corsica, France
window-about-author-title = Acerca do autor
about-author-flag-alt = Bandeira da Córsega — a cabeça de mouro

# --- «Acerca do Radinus» -------------------------------------------------
#
# `about-radinus-version` leva um buraco: o número vem do binário que corre,
# nunca de uma cadeia copiada. Não está portanto no dicionário das janelas —
# é o comando `app_version` que a preenche.
window-about-radinus-title = Acerca do Radinus
about-radinus-name = Radinus
about-radinus-version = Versão { $version }
about-radinus-rust-alt = O logótipo da linguagem Rust
about-radinus-tauri-alt = O logótipo do Tauri
about-radinus-built = O Radinus é escrito em Rust e construído com o Tauri. O primeiro calcula as suas contas, o segundo faz delas uma aplicação de secretária.
about-radinus-licence = Software livre, sob licença GNU GPL v3.

# --- « Licence d'utilisation » (08/08/2026) -------------------------------
#
# The window names the licence and says, in four lines, what it gives the
# person using Radinus. The legal text itself is not translated here: the
# button opens the official page, published and maintained by the Free
# Software Foundation, which knows its own wording better than we do.
window-licence-title = Licença de utilização
licence-heading = LICENÇA DE UTILIZAÇÃO DO PROGRAMA RADINUS
licence-logo-alt = O logótipo da GNU General Public License versão 3
licence-name = GNU GPL v3 ou posterior
licence-intro = O Radinus é software livre.
licence-freedoms-title = A sua licença dá-lhe quatro liberdades:
licence-freedom-use = Utilizá-lo como quiser, para o que quiser.
licence-freedom-study = Estudar o seu código-fonte, aberto a todos.
licence-freedom-share = Copiá-lo e dá-lo a quem quiser.
licence-freedom-improve = Modificá-lo e partilhar as suas alterações.
licence-read = Ler o texto completo da licença

# The two notices the GPL asks an interactive interface to display, next
# to the right to redistribute and the way to read the licence, which the
# window already carried (LICENSE, definition of « Appropriate Legal
# Notices »). The copyright is a name and a year: identical everywhere,
# here all the same so that the view holds no sentence of its own.
licence-copyright = Copyright © 2026 Fabrice Garcia
licence-no-warranty = Este programa é fornecido sem qualquer garantia, na medida permitida por lei.
licence-info = O texto oficial abre no seu navegador, em gnu.org.
