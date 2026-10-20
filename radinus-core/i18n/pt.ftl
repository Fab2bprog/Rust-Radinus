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
menu-statistics-balance-analysis = Análise Evolução do saldo
menu-statistics-by-category = Estat. por categorias
menu-statistics-by-assignment = Estat. por afetações
menu-statistics-by-budget-line = Estat. por rubricas orçamentais
menu-statistics-by-payment-mode = Estat. por meios de pagamento
menu-statistics-by-payee = Estat. por terceiros e comerciantes
menu-statistics-by-project = Estat. por projetos
menu-statistics-by-verification = Estat. por verificações
menu-statistics-dashboard = Painel de bordo das operações
menu-statistics-crossed-balance = Balanço cruzado

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

# Le menu Outils (Fabrice, 09/10/2026), entre Nomenclatures et Paramètres.
menu-tools = Ferramentas
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
operations-column-status = Estado da operação
operation-status-pointed = Conciliado
operation-status-committed = Comprometido
operation-status-planned = Previsto
operations-column-verification = Verificação
operation-verification-to-verify = Por verificar
operation-verification-verified = Verificada
operation-verification-doubtful = Duvidosa
operation-verification-disputed = Contestada
operations-column-label = Descrição
operations-column-reference = Referência de pagamento
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
filter-by-status = Filtro por estado
filter-by-verification = Filtro por verificação
filter-show-all = Mostrar tudo

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
operation-field-verification = Verificação
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
operation-clearing-date-required = Uma operação conferida deve obrigatoriamente ter uma data de conferência.
operation-clearing-date-question =
    Uma operação conferida deve obrigatoriamente ter uma data de conferência.
    Deseja guardar com a data da operação, { $date }?
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
    [0] Nenhuma operação a conciliar: a seleção já está conciliada.
    [one] 1 operação conciliada.
   *[other] { $count } operações conciliadas.
}
operations-select-one = Selecione apenas uma operação.

# --- Duplicar e mostrar as suboperações (F02) -------------------------

operation-copy = Cópia por guardar: ainda não foi criado nada.
operations-show-children = Mostrar todas as suboperações
operations-hide-children = Ocultar todas as suboperações
operations-recurring-from = Criar uma operação periódica a partir desta operação

# --- Segunda confirmação de uma eliminação grave ----------------------

accounts-delete-second-question = Esta eliminação é definitiva e leva consigo todo o histórico da conta. Escreva « { $word } » para a confirmar.

# --- F20-F24 — As seis estatísticas -----------------------------------

window-statistics-title = { $kind ->
    [assignment] Estatísticas por afetação
    [budget-line] Estatísticas por rubrica orçamental
    [payment-mode] Estatísticas por meio de pagamento
    [payee] Estatísticas por terceiro e comerciante
    [project] Estatísticas por projeto
    [verification] Estatísticas por verificação
   *[category] Estatísticas por categoria
}

statistics-axis-column = { $kind ->
    [assignment] Afetação
    [budget-line] RubricaOrç
    [payment-mode] ModoPagamento
    [payee] Terceiro
    [project] Projetos
    [verification] Verificação
   *[category] NomeCategoria
}

statistics-unclassified = { $kind ->
    [assignment] Sem afetação
    [budget-line] Sem rubrica orçamental
    [payment-mode] Sem meio de pagamento
    [payee] Sem terceiro
    [project] Sem projeto
    [verification] Por verificar
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

# --- F27, le bilan croisé (Fabrice, 25/08/2026) ---------------------
# Les catégories en lignes, les affectations en colonnes, sur un mois.
# Tout le reste de son vocabulaire est celui des statistiques : Total,
# Somme, les interrupteurs, « Sans … », les colonnes du détail.
window-crossed-balance-title = Balanço cruzado
crossed-balance-window-name = Balanço cruzado
crossed-balance-column = Categoria
crossed-balance-no-data = Nenhuma operação neste mês para as contas escolhidas.
crossed-balance-month-question = Sobre que mês deseja trabalhar? Um número entre { $first } e { $last }.
crossed-balance-month-choose = Escolher o mês
crossed-balance-next = Mês seguinte
crossed-balance-previous = Mês anterior

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
export-to = Exportar para
# Copying from a table (Fabrice, 07/10/2026): the two entries at the head of
# the right-click menu, and what is said when the clipboard refuses.
copy-cell = Copiar a célula
copy-rows = Copiar as linhas selecionadas
copy-failed = Não foi possível copiar para a área de transferência.
export-all-years-excel = Exportar todos os anos para Excel
export-all-years-ods = Exportar todos os anos para LibreOffice Calc
export-all-months-excel = Exportar todos os meses do ano apresentado para Excel
export-all-months-ods = Exportar todos os meses do ano apresentado para LibreOffice Calc
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
    [verification] Estatísticas por verificação
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

# F40 — « Analyse Évolution du solde » (Fabrice, 05/10/2026): the chart of F25,
# on which one drags a zone, and under it the operations of that zone. The
# chart's own words are F25's (curve-*); these are the summary of the zone.
window-analysis-title = Análise da evolução do saldo
analysis-heading = Análise da evolução do saldo
analysis-hint = Trace uma zona no gráfico, com o botão do rato premido, para ver as operações desse período.
analysis-zone = Zona:
analysis-opening = Saldo inicial:
analysis-closing = Saldo final:
analysis-variation = Variação:
analysis-detail-name = Análise do saldo
analysis-detail-none = Nenhuma operação nesta zona.

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
quick-check-verification = Verificação
quick-column-date = Data
quick-column-label = Descrição
quick-column-amount = Montante
quick-column-category = Categoria
quick-column-assignment = Afetação
quick-column-payment-mode = Modo de pagamento
quick-column-payee = Terceiro
quick-column-project = Projetos
quick-column-status = Estado
quick-column-verification = Verificação
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
statement-column-reference = Referência de pagamento
statement-column-debit = Débito
statement-column-credit = Crédito
statement-account = Conta
statement-file = Ficheiro
statement-difference = Diferença
statement-none = Não há nenhum extrato aberto: clique na pasta amarela para escolher um ficheiro (OFX, CSV, QIF).
statement-empty = Este extrato não contém nenhuma operação.
statement-no-match = Nenhuma linha corresponde ao filtro.
statement-help = Info: utilize Clique do rato + tecla [{ $modifier }] na tabela para selecionar várias linhas
statement-choose-account = Este ficheiro contém várias contas. Qual pretende importar?
statement-select-line = Selecione pelo menos uma linha do extrato.
statement-title-open = Abrir um ficheiro de extrato (OFX, QIF, CSV)
statement-title-info = Informações sobre o ficheiro aberto
statement-title-integrate = Integrar a seleção na conta
statement-title-validate = Integrar esta operação na conta
statement-duplicate = Atenção, duplicado: esta transação parece já ter sido integrada na base (o Financial Institution Transaction ID já existe)
statement-no-fitid = Atenção: este ficheiro não dá qualquer identificador (FITID) para esta linha. Não será possível detetar um duplicado.
statement-loaded = { $count ->
    [0] Este ficheiro não contém nenhuma operação para esta conta.
   *[other] { $count } linhas lidas, das quais { $known } já presentes na sua conta.
}
statement-loaded-unidentified = { $alike ->
    [0] { $count } linhas lidas; nenhuma é semelhante a uma operação já presente na sua conta.
    [one] { $count } linhas lidas, das quais { $alike } é semelhante a uma operação já presente na sua conta (mesma data, mesma descrição, mesmo montante).
   *[other] { $count } linhas lidas, das quais { $alike } são semelhantes a operações já presentes na sua conta (mesma data, mesma descrição, mesmo montante).
}
statement-loaded-also-alike = { $alike ->
    [one] Mais { $alike } é semelhante a uma operação já presente (mesma data, mesma descrição, mesmo montante).
   *[other] Mais { $alike } são semelhantes a operações já presentes (mesma data, mesma descrição, mesmo montante).
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
statement-qif-question = Nada neste ficheiro indica se a data « { $date } » se escreve dia/mês ou mês/dia. Significa:
statement-qif-day-month = Dia { $day }, mês { $month } (dia/mês)
statement-qif-month-day = Dia { $day }, mês { $month } (mês/dia)
statement-qif-dates-mixed = Este ficheiro escreve as suas datas de duas formas: « { $first } » lê-se dia/mês, « { $second } » mês/dia. Não é importado, para não falsear nenhuma data.
statement-qif-amounts-mixed = Este ficheiro escreve os seus montantes de duas formas: « { $first } » com um ponto, « { $second } » com uma vírgula. Não é importado, para não falsear nenhum montante.
statement-qif-opening = Saldo inicial de { $amount } em { $date }: não é uma operação, não é importado.
statement-qif-opening-undated = Saldo inicial de { $amount }: não é uma operação, não é importado.
statement-qif-suspect = A linha { $rank }, « { $label } » ({ $amount }), parece um saldo inicial: verifique-a antes de a integrar.
statement-qif-rejected = { $count ->
    [one] { $count } linha ilegível não é importada: { $lines }.
   *[other] { $count } linhas ilegíveis não são importadas: { $lines }.
}
statement-qif-reason-date = data
statement-qif-reason-amount = montante
statement-qif-reason-differ = montantes contraditórios
statement-qif-no-account = Esta conta já não está no ficheiro: abra o ficheiro de novo.
statement-balance-unknown = não indicado no ficheiro
statement-group-identification = Identificação da operação
statement-group-amount = Montante da operação
statement-group-classification = Classificação da operação para o cálculo das estatísticas
statement-group-status = Estado da operação
statement-field-date = Data
statement-field-label = Descrição
statement-field-reference = Referência de pagamento
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
backup-done = A base « { $base } » foi guardada em « { $file } ». As outras bases não são afetadas.
backup-failed = Não foi possível fazer a cópia de segurança: { $reason }
backup-not-started = Não foi possível iniciar a cópia de segurança:
restore-unreadable = Este ficheiro não é um arquivo Radinus legível: { $reason }
restore-question = Restaurar « { $file } » na base « { $base } »? Todo o conteúdo atual desta base será apagado e substituído, e o que lá estiver perder-se-á. As outras bases não são tocadas.
restore-done = A base « { $base } » foi restaurada: { $accounts } contas e { $operations } operações. As outras bases não são tocadas.
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
database-too-recent = Esta base foi guardada por uma versão mais recente do Radinus (versão da base { $found }; esta versão lê até à versão { $supported }). Atualize o Radinus para a abrir.
database-not-radinus = Este ficheiro não é uma base Radinus.
database-unreadable = Não foi possível ler a base: { $reason }
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
    [0] Reparação da base « { $base } » terminada: nenhuma anomalia encontrada. { $lines } etapas registadas. As outras bases não são afetadas.
    [one] Reparação da base « { $base } » terminada: uma anomalia reparada. { $lines } etapas registadas. As outras bases não são afetadas.
   *[other] Reparação da base « { $base } » terminada: { $anomalies } anomalias reparadas. { $lines } etapas registadas. As outras bases não são afetadas.
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
# The tick box of an account on the home window (Fabrice, 07/10/2026), and the
# line that says so when not every account is counted. No plural on purpose:
# « counted: 3 of 5 » reads the same whatever the numbers.
welcome-accounts-counted = Contas contadas nos totais: { $count } de { $total }
welcome-tile-counted = Contar esta conta nos totais
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
preferences-branch-import = Importação
preferences-leaf-verification = Verificação
preferences-field-verification = Operações importadas:
preferences-verification-hint = «Verificada»: confia no seu banco, uma operação importada é tida como correta. «Por verificar»: cada operação importada aguarda o seu controlo; depois passa-a você mesmo a «Verificada» na lista de operações. Esta definição só se aplica às importações futuras.
preferences-leaf-ofx = Extratos OFX
preferences-field-ofx-label = Descrição da operação:
preferences-field-ofx-reference = Referência de pagamento:
preferences-ofx-choice-name = O nome da operação
preferences-ofx-choice-memo = O memo do banco
preferences-ofx-choice-name-and-memo = O nome seguido do memo
preferences-ofx-choice-empty = Nada (deixar vazio)
preferences-ofx-label-help = O que recebe a descrição de uma operação importada. O nome é o que o banco apresenta, por exemplo «PRLV SEPA»; alguns bancos acrescentam um memo detalhado: o credor de um débito direto, o beneficiário e o motivo de uma transferência. Quando uma operação não tem memo, a sua descrição mantém o nome.
preferences-ofx-reference-help = O que recebe a referência de pagamento de uma operação importada, onde a pode ver e filtrar. Quando uma operação não tem memo, «O memo do banco» deixa a referência vazia. Se o memo já repetir o nome, não é escrito duas vezes.
preferences-ofx-hint = Estas definições aplicam-se a todos os extratos OFX, seja qual for a base de dados aberta. Aplicam-se ao próximo extrato aberto.
preferences-leaf-qif = Extratos QIF
preferences-field-qif-order = Ordem do dia e do mês:
preferences-qif-order-ask = Perguntar-me sempre
preferences-qif-order-day-month = Sempre dia/mês (05/03 = 5 de março)
preferences-qif-order-month-day = Sempre mês/dia (05/03 = 3 de maio)
preferences-qif-order-help = Só serve se nenhuma data do ficheiro permitir decidir. Assim que uma data como 24/11 prova a ordem, é o ficheiro que decide, seja qual for esta definição.
preferences-field-qif-label = Descrição da operação:
preferences-qif-label-both = Terceiro + memo
preferences-qif-label-payee = Só terceiro
preferences-qif-label-memo = Só memo
preferences-qif-label-help = Quando uma operação traz ao mesmo tempo um terceiro e um memo. Se só trouxer um, é esse que é usado, seja qual for esta definição.
preferences-qif-hint = Estas definições aplicam-se a todos os extratos QIF, seja qual for a base de dados aberta. «Perguntar-me sempre» é o mais seguro: um ficheiro com datas ambíguas nunca é lido ao acaso.

# The columns of a table (Fabrice, 04/10/2026): each user has his own. The
# first is the last entry of the right-click menu on a table's header; the
# others are the « Table columns » leaf of the preferences, one line per
# table whose columns can be arranged, a « Reset » button facing it.
columns-reset = Repor as colunas predefinidas
# The header menu's two sub-menus (Fabrice, 05/10/2026). « columns-colour » is
# followed by the column's own title, hence its colon. Then the nine tints a
# column can take, and the entry that takes it off.
columns-show-hide = Mostrar/Ocultar
columns-colour = Colorir a coluna:
columns-colour-none = Sem cor
columns-colour-red = Vermelho
columns-colour-orange = Laranja
columns-colour-pink = Rosa
columns-colour-pastel-green = Verde pastel
columns-colour-green = Verde
columns-colour-pastel-blue = Azul pastel
columns-colour-blue = Azul
columns-colour-pastel-yellow = Amarelo pastel
columns-colour-yellow = Amarelo
preferences-leaf-columns = Colunas das tabelas
preferences-table-operations-list = Lista de operações
preferences-columns-reset = Repor
preferences-columns-reset-all = Repor tudo
preferences-columns-done = As colunas voltaram à disposição original.
preferences-columns-hint = Cada tabela memoriza a ordem das suas colunas, as que oculta e a respetiva largura. «Repor» devolve-lhe de imediato a disposição original.

# The reset of the comfort settings (Fabrice, 07/10/2026): columns, home
# window, display size — and nothing else.
preferences-branch-reset = Reposição
preferences-leaf-comfort = Definições de conforto
preferences-comfort-reset = Repor as definições de conforto
preferences-comfort-hint = Repõe as colunas de todas as tabelas, a ordem e as caixas das contas da janela inicial e o tamanho da visualização. O idioma, a moeda e a verificação das operações importadas não são alterados.
preferences-comfort-question = Repor as definições de conforto? As colunas das tabelas, a janela inicial e o tamanho da visualização voltarão ao estado original.
preferences-comfort-done = As definições de conforto foram repostas.


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

# --- F41 — Simulation de crédit (Fabrice, 08/10/2026) ------------------------
# Le calcul d'un prêt à taux fixe, et ce que l'historique de la base dit de la
# capacité à le rembourser. Les phrases sont écrites par le noyau ; la fenêtre
# n'en compose aucune.
menu-tools-loan-simulation = Simulação de crédito
window-loan-title = Simulação de crédito
loan-tab-credit = O crédito
loan-tab-afford = Consigo pagá-lo?
loan-field-kind = Tipo de crédito
loan-kind-consumer = Crédito ao consumo
loan-kind-mortgage = Crédito à habitação
loan-field-amount = Montante pedido
loan-field-payment = Prestação mensal
loan-field-months = Prazo
loan-field-rate = Taxa de juro fixa
loan-field-fees = Comissão de abertura
loan-field-insurance = Seguro por mês
loan-unit-months = meses
loan-unit-percent = %
loan-invalid-field = Este valor não é um número: corrija-o para relançar o cálculo.
loan-report-button = Relatório PDF
loan-monthly-table = Quadro mês a mês
loan-months-count = { $count ->
        [one] { $count } mês
       *[other] { $count } meses
    }
loan-percent = { $value } %
loan-notice-payment-too-low = Esta prestação não cobre os juros: o crédito nunca seria pago. O prazo fica em 600 meses.
loan-notice-too-long = Esta prestação exigiria mais de 600 meses: o prazo fica em 600 meses.
loan-figure-payment = Prestação mensal
loan-figure-payment-insured = Prestação com seguro
loan-figure-taeg = TAEG
loan-figure-interest = Custo dos juros
loan-figure-insurance = Custo do seguro
loan-figure-cost = Custo total do crédito
loan-figure-total-due = Montante total devido
loan-figure-all-in = Total pago, seguro incluído
loan-part-capital = Montante pedido
loan-part-interest = Juros
loan-part-fees = Comissão de abertura
loan-part-insurance = Seguro
loan-donut-cost-caption = no total
loan-chart-cost = Quanto custa este crédito
loan-chart-capital = Capital em dívida
loan-schedule-title = Plano de amortização
loan-schedule-yearly = Plano de amortização, ano a ano
loan-column-number = N.º
loan-column-year = Ano
loan-column-date = Vencimento
loan-column-payment = Prestação
loan-column-payments = Prestações
loan-column-interest = Juros
loan-column-capital = Capital
loan-column-insurance = Seguro
loan-column-remaining = Capital em dívida
loan-history-label = Período estudado
loan-period-last-12 = Últimos 12 meses
loan-accounts-title = Contas estudadas
loan-period-title = Período
loan-column-account = Conta
loan-column-bank = Banco
loan-column-balance = Saldo real
loan-unavailable-no-account = Marque pelo menos uma conta para estudar o seu histórico.
loan-unavailable-no-month = Este período ainda não tem nenhum mês completo: escolha outro.
loan-verdict-title = Em resumo
loan-verdict-green = Viável
loan-verdict-orange = Apertado
loan-verdict-red = Arriscado
loan-verdict-no-income = Nenhum rendimento neste período: a taxa de esforço não se calcula.
loan-check-debt-green = Taxa de esforço de { $ratio }: abaixo do limiar de { $green } deste método.
loan-check-debt-orange = Taxa de esforço de { $ratio }: entre { $green } e { $red }, no limite.
loan-check-debt-red = Taxa de esforço de { $ratio }: acima de { $red }.
loan-check-effort = A prestação de { $payment } leva { $share } do que põe de lado { $kind ->
        [good] num bom mês
        [hard] num mês difícil
       *[usual] num mês normal
    } ({ $margin }).
loan-check-effort-none = { $kind ->
        [good] Um bom mês
        [hard] Um mês difícil
       *[usual] Um mês normal
    } não lhe deixa nada de lado: a prestação de { $payment } sairia da sua reserva.
loan-check-reserve-green = O seu saldo mantém-se positivo até ao fim do crédito.
loan-check-reserve-red = O seu saldo ficaria abaixo de zero em { $month }, por causa deste crédito.
loan-check-reserve-sooner = O seu saldo ficaria abaixo de zero em { $month }, { $count ->
        [one] um mês
       *[other] { $count } meses
    } mais cedo do que sem este crédito.
loan-check-reserve-anyway = O seu saldo ficaria abaixo de zero por volta de { $month } mesmo sem este crédito, que quase nada muda.
loan-check-reserve-floor-green = O seu saldo mantém-se acima da sua reserva de segurança ({ $floor }) até ao fim do crédito.
loan-check-reserve-floor-red = O seu saldo ficaria abaixo da sua reserva de segurança ({ $floor }) em { $month }, por causa deste crédito.
loan-check-reserve-floor-sooner = O seu saldo ficaria abaixo da sua reserva de segurança ({ $floor }) em { $month }, { $count ->
        [one] um mês
       *[other] { $count } meses
    } mais cedo do que sem este crédito.
loan-check-reserve-floor-anyway = O seu saldo ficaria abaixo da sua reserva de segurança ({ $floor }) por volta de { $month } mesmo sem este crédito, que quase nada muda.
loan-warning-deficit = Atenção: neste período, as suas despesas já ultrapassam os seus rendimentos em { $amount } por mês em média, antes de qualquer crédito.
loan-figure-reference = Poupança { $kind ->
        [good] de um bom mês
        [hard] de um mês difícil
       *[usual] de um mês normal
    }
loan-figure-tipped = Meses que o crédito poria no vermelho
loan-gauge-caption = de taxa de esforço
loan-figure-income = Rendimentos médios por mês
loan-figure-spending = Despesas médias por mês
loan-figure-saving = Poupança média por mês
loan-figure-running = Créditos em curso por mês
loan-figure-new = Nova prestação, seguro incluído
loan-figure-rest = Para viver por mês
loan-figure-debt = Taxa de esforço
loan-red-months-value = { $count } em { $total }
loan-figure-balance-now = Saldo real hoje
loan-figure-balance-end = Saldo previsto no fim do crédito
loan-chart-income = Para onde vai o seu rendimento médio
loan-donut-income-caption = rendimento médio
loan-part-spending = Despesas correntes
loan-part-running = Créditos em curso
loan-part-new = Novo crédito
loan-part-rest = Resto
loan-part-missing = Em falta
loan-chart-history = O seu histórico com este crédito
loan-chart-history-hint = O que teria sobrado em cada mês, paga a prestação. A vermelho vivo, os meses que o crédito poria no vermelho; a vermelho pálido, os que já o estavam sem ele.
loan-chart-projection = O seu saldo previsto
loan-mark-loan-end = Fim: { $label }
loan-mark-negative = No vermelho
loan-mark-floor = Abaixo da reserva
loan-mark-floor-line = Reserva de segurança
loan-running-title = Créditos em curso considerados
loan-running-column-label = Operação periódica
loan-running-column-monthly = Por mês
loan-running-column-end = Último vencimento
loan-no-running = Nenhum crédito em curso reconhecido entre as suas operações periódicas.
loan-period-caption = de { $from } a { $to } ({ $count ->
        [one] { $count } mês
       *[other] { $count } meses
    })
loan-transfers = { $count ->
        [0] Não foi reconhecida nenhuma transferência entre as suas contas marcadas.
        [one] Foi reconhecida e posta de lado uma transferência entre as suas contas marcadas.
       *[other] Foram reconhecidas e postas de lado { $count } transferências entre as suas contas marcadas.
    }
loan-method = Médias sobre os meses completos do período, operações conferidas e comprometidas, sem as transferências entre as suas contas marcadas.
loan-report-title = Simulação de crédito
loan-report-made-on = simulação de { $date }
loan-disclaimer = Simulação indicativa, sem valor contratual. Só a proposta do banco é vinculativa.
loan-tab-rules = Definições do juízo
loan-method-optimistic = Otimista
loan-method-neutral = Neutro
loan-method-severe = Severo
loan-method-line = Método de juízo: { $method }
loan-method-verdict = { $method }: { $verdict }
loan-rules-intro = O veredicto responde a três perguntas, e cada método põe as suas próprias exigências. Escolha o que se parece consigo: o veredicto do separador «Consigo pagá-lo?» segue-o. A última linha supõe que as suas despesas aumentam todos os anos a percentagem indicada; a prestação não muda.
loan-rule-row-debt = Taxa de esforço aceite
loan-rule-row-reference = Poupança de referência
loan-rule-row-share = Parte dessa poupança que a prestação pode levar
loan-rule-row-floor = Limiar que o saldo não deve ultrapassar
loan-rule-row-sooner = Se o saldo o ultrapassar mesmo sem o crédito
loan-rule-row-growth = Aumento das suas despesas por ano
loan-rule-limits = verde até { $green }, laranja até { $red }
loan-rule-reference = { $kind ->
        [good] um bom mês
        [hard] um mês difícil
       *[usual] um mês normal
    }: { $amount }
loan-rule-floor-zero = zero
loan-rule-floor-cushion = um mês de despesas: { $amount }
loan-rule-sooner = laranja se o antecipar { $orange }, vermelho se o antecipar { $red }
loan-unit-percent-year = % por ano
loan-method-optimistic-explain = O método otimista supõe um bom mês, aceita uma taxa de esforço até 40 % e não guarda reserva: diz o que é possível se tudo correr bem.
loan-method-neutral-explain = O método neutro supõe um mês normal e segue a regra dos bancos, 33 a 35 % de taxa de esforço: é o juízo de referência.
loan-method-severe-explain = O método severo supõe um mês difícil e guarda um mês de despesas de reserva para um imprevisto: diz o que aguenta mesmo que as coisas corram mal.

# --- F42 — Consommation d'un appareil électrique (Fabrice, 09/10/2026) -------
# Ce que coûte un appareil, allumé et en veille, en heures pleines et en
# heures creuses. Le tarif est une préférence de la base (« tarif.electricite »).
menu-tools-appliance-cost = Consumo de um aparelho elétrico
window-appliance-title = Consumo de um aparelho elétrico
appliance-device-title = O aparelho
appliance-on-title = Ligado
appliance-standby-title = Em standby
appliance-field-on-watts = Potência em funcionamento
appliance-field-on-hours = Tempo de funcionamento por dia
appliance-field-days = Dias de utilização por semana
appliance-field-share = Parte do funcionamento em horas de vazio
appliance-field-standby-watts = Potência em standby
appliance-field-standby-hours = Tempo em standby por dia de utilização
appliance-unit-watts = W
appliance-unit-hours = h
appliance-unit-days = em 7
appliance-unit-percent = %
appliance-unit-price = { $sign }/kWh
appliance-standby-hint = Se ficar vazio, o standby dura o resto do dia. Nos dias sem utilização, o aparelho fica ligado à tomada: todo esse tempo conta como standby. Desligado da tomada, o seu standby é de 0 W.
appliance-contract-title = O seu contrato
appliance-field-option = Opção tarifária
appliance-option-base = Simples (um só preço)
appliance-option-off-peak = Horas de ponta / Horas de vazio
appliance-field-base = Preço do kWh
appliance-field-peak = Preço do kWh em horas de ponta
appliance-field-off-peak = Preço do kWh em horas de vazio
appliance-field-off-peak-hours = Horas de vazio por dia
appliance-contract-hint = Estes preços só valem para este cálculo. A tarifa guardada define-se em Definições › Preferências › Ferramentas.
appliance-contract-reset = Voltar à tarifa guardada
appliance-period-day = Por dia
appliance-period-month = Por mês
appliance-period-year = Por ano
appliance-energy = { $value } kWh
appliance-less-than = menos de { $amount }
appliance-detail-title = O detalhe de um ano
appliance-column-part = Rubrica
appliance-column-energy = Energia
appliance-column-cost = Custo
appliance-column-share = Parte
appliance-line-on = Ligado
appliance-line-standby = Em standby
appliance-line-on-peak = Ligado, horas de ponta
appliance-line-on-off-peak = Ligado, horas de vazio
appliance-line-standby-peak = Em standby, horas de ponta
appliance-line-standby-off-peak = Em standby, horas de vazio
appliance-line-total = Total
appliance-chart-title = Para onde vai o dinheiro
appliance-chart-caption = por ano
appliance-standby-sentence = Só o standby custa { $amount } por ano: { $share } do que custa o aparelho.
appliance-note-plate = A potência indicada no aparelho ou no manual é um máximo: em funcionamento, a maioria dos aparelhos consome menos. Para um valor real, meça-a com um medidor de consumo de tomada e introduza o que ele indicar.
appliance-note-subscription = O termo fixo de potência não é contabilizado: paga-o quer o aparelho esteja ligado à tomada, quer não.
appliance-invalid-watts = Indique uma potência de 0 a 100 000 W, por favor.
appliance-invalid-hours = Indique um tempo de 0 a 24 horas por dia, por favor.
appliance-invalid-days = Indique um número inteiro de dias, de 0 a 7, por favor.
appliance-invalid-share = Indique uma parte de 0 a 100%, por favor.
appliance-invalid-day-overflow = O funcionamento e o standby ultrapassam 24 horas por dia.
appliance-invalid-price = Indique um preço do kWh de 0 a 100, por favor.
appliance-invalid-off-peak-hours = Indique um número inteiro de horas de vazio, de 0 a 24, por favor.
preferences-branch-tools = Ferramentas
preferences-leaf-electricity = Tarifa de eletricidade
preferences-electricity-blue = Voltar ao Tarif Bleu da EDF
preferences-electricity-hint = A tarifa do seu contrato, usada pela ferramenta «Consumo de um aparelho elétrico». Por predefinição: o Tarif Bleu da EDF (França) a 1 de agosto de 2026, preços com impostos, potência contratada de 3 a 6 kVA. Estes preços mudam muitas vezes em fevereiro e em agosto: copie os da sua fatura.

# --- F43 — Mon matelas de sécurité (Fabrice, 09/10/2026) -------------------------
# Combien de mois l'épargne tiendrait si les revenus s'arrêtaient. Les
# phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-safety-cushion = O meu fundo de emergência
window-cushion-title = O meu fundo de emergência
cushion-question = Se os seus rendimentos parassem amanhã, durante quantos meses aguentaria com as suas poupanças?
cushion-accounts-title = As suas contas
cushion-column-account = Conta
cushion-column-balance = Saldo real
cushion-column-savings = Poupança
cushion-column-spending = Despesas
cushion-accounts-hint = « Poupança »: o dinheiro com que conta em caso de aperto. « Despesas »: as contas de onde saem as despesas do dia a dia.
cushion-history-label = Período analisado
cushion-backup-label = Rendimento de substituição por mês
cushion-backup-hint = O que continuaria a entrar: subsídio de desemprego, salário do cônjuge… Vazio: nenhum rendimento.
cushion-categories-title = As despesas consideradas
cushion-categories-hint = Desmarque o que cortaria em caso de aperto.
cushion-categories-empty = Nenhuma despesa neste período.
cushion-verdict-title = O seu fundo
cushion-targets-title = Os limiares de prudência
cushion-projection-title = As suas poupanças em caso de aperto
cushion-projection-hint = O que restaria em cada mês se os seus rendimentos parassem hoje.
cushion-note = Uma estimativa tirada do seu histórico: as despesas de um mês difícil podem diferir da média.
cushion-invalid-backup = Este montante não é legível: corrija-o para relançar o cálculo.
cushion-no-spending-account = Marque pelo menos uma conta « Despesas ».
cushion-no-month = Este período ainda não tem nenhum mês completo.
cushion-months = { $value } meses
cushion-per-month = { $amount } por mês
cushion-figure-holds = Sem limite
cushion-gauge-caption = de despesas cobertas
cushion-verdict-short = Menos de três meses: um revés traria rapidamente dificuldades.
cushion-verdict-fair = Entre três e seis meses: um fundo razoável, a reforçar se puder.
cushion-verdict-solid = Seis meses ou mais: o seu fundo é sólido.
cushion-verdict-holds = O seu rendimento de substituição cobre as suas despesas: as suas poupanças não diminuiriam.
cushion-verdict-nothing = Nenhuma despesa considerada no período: não há nada a cobrir.
cushion-tile-savings = Poupança disponível
cushion-tile-spending = Despesas consideradas
cushion-tile-backup = Rendimento de substituição
cushion-tile-burn = A poupança diminuiria
cushion-tile-rhythm = Ritmo de poupança
cushion-burn-none = Nada
cushion-target-title = { $months } meses de despesas: { $amount }
cushion-target-reached = Atingido.
cushion-target-date = Faltam { $missing }. Ao seu ritmo de poupança, atingido por volta de { $month }.
cushion-target-never = Faltam { $missing }. As suas poupanças não cresceram no período: a este ritmo, este limiar não será atingido.
cushion-mark-empty = Fundo esgotado: { $month }
cushion-period = Média de { $count ->
        [one] { $count } mês completo
       *[other] { $count } meses completos
    }, de { $from } a { $to }. { $transfers ->
        [0] Nenhuma transferência entre as suas contas.
        [one] Uma transferência entre as suas contas, posta de parte.
       *[other] { $transfers } transferências entre as suas contas, postas de parte.
    }

# --- F44 — Objectif Épargne (Fabrice, 10/10/2026) --------------------------------
# Quand aurai-je ce montant, combien aurai-je à cette date, combien épargner.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-savings-goal = Objetivo de poupança
window-goal-title = Objetivo de poupança
goal-accounts-title = As contas acompanhadas
goal-column-account = Conta
goal-column-balance = Saldo real
goal-accounts-hint = Uma transferência entre duas contas acompanhadas anula-se; uma transferência para uma conta não acompanhada conta como uma saída.
goal-period-label = Período de referência
goal-period-range = Intervalo de anos…
goal-range-from = de
goal-range-to = a
goal-question-title = A sua pergunta
goal-question-when = Quando terei este montante?
goal-question-amount = Quanto terei nesta data?
goal-question-effort = Quanto poupar para ter este montante nesta data?
goal-field-target = Montante pretendido
goal-field-date = Data pretendida
goal-field-rate = Taxa anual da poupança
goal-field-extra = E se poupasse mais, por mês
goal-options-hint = Vazios: sem juros, nada mais.
goal-answer-title = A resposta
goal-chart-title = O seu saldo, ontem e amanhã
goal-chart-hint = Linha contínua: o saldo real dos últimos doze meses; tracejado: a projeção; sombreado: o intervalo consoante os meses.
goal-disclaimer = Uma projeção tirada do seu histórico, não uma promessa: um imprevisto pode mudar tudo.
goal-no-account = Marque pelo menos uma conta a acompanhar.
goal-no-month = Este período ainda não tem nenhum mês completo.
goal-invalid-target = Indique um montante a atingir, por favor.
goal-invalid-date = Indique uma data futura, nos próximos cinquenta anos, por favor.
goal-invalid-rate = Indique uma taxa de 0 a 100%, por favor.
goal-invalid-extra = Este montante não é legível: corrija-o para relançar o cálculo.
goal-per-month = { $amount } por mês
goal-tile-balance = Saldo hoje
goal-tile-rhythm = Ritmo médio
goal-tile-target = Objetivo
goal-tile-reached = Atingido por volta de
goal-tile-date = Data pretendida
goal-tile-projected = Saldo projetado
goal-tile-saved = Poupado até lá
goal-tile-interest = Dos quais juros
goal-tile-needed = A poupar
goal-when-already = Já tem { $amount }: as suas contas acompanhadas totalizam { $balance }.
goal-when-reached = Terá { $amount } por volta de { $month }, dentro de { $months ->
        [one] um mês
       *[other] { $months } meses
    }.
goal-when-range = Consoante os meses, entre { $early } e { $late }.
goal-when-range-open = O mais cedo por volta de { $early }; com meses fracos, o objetivo não seria atingido.
goal-when-never = A este ritmo, não atingirá { $amount }.
goal-zero = O seu saldo cairia para zero por volta de { $month }.
goal-amount = Em { $month }, teria cerca de { $amount }.
goal-amount-range = Consoante os meses, entre { $low } e { $high }.
goal-effort-more = Para ter { $amount } em { $month }, seria preciso poupar em média { $monthly } por mês, ou seja, mais { $gap } do que hoje.
goal-effort-less = Para ter { $amount } em { $month }, bastariam { $monthly } por mês, ou seja, menos { $gap } do que hoje: está à frente do previsto.
goal-effort-range = Consoante os meses, a diferença em relação ao seu ritmo iria de { $low } a { $high } por mês.
goal-chart-target = Objetivo: { $amount }
goal-chart-today = Hoje
goal-note-seasons = A projeção acompanha as estações: cada mês futuro retoma a média dos mesmos meses do período.
goal-note-range = O intervalo vem dos meses fracos e dos meses fortes do período: o quarto mais baixo e o quarto mais alto.
goal-note-loan = O crédito «{ $label }» termina em { $month }: depois, mais { $amount } por mês.
goal-note-interest = Juros contados todos os meses à taxa de { $rate }% ao ano: uma aproximação da regra das quinzenas das contas poupança.
goal-period = Ritmo calculado sobre { $count ->
        [one] { $count } mês completo
       *[other] { $count } meses completos
    }, de { $from } a { $to }. { $transfers ->
        [0] Nenhuma transferência entre as suas contas acompanhadas.
        [one] Uma transferência entre as suas contas acompanhadas, neutralizada.
       *[other] { $transfers } transferências entre as suas contas acompanhadas, neutralizadas.
    }

# --- F45 — Et si je réduisais… ? (Fabrice, 10/10/2026) ----------------------------
# Réduire des postes de dépense, et voir ce que ça change dans le temps.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-spending-cut = E se eu reduzisse…?
window-cut-title = E se eu reduzisse…?
cut-axis-label = Agrupar por
cut-axis-category = Categorias
cut-axis-payee = Terceiros
cut-axis-budget-line = Rubricas orçamentais
cut-table-title = As suas despesas, rubrica a rubrica
cut-table-hint = Escreva uma redução em % ou em { $sign } por mês nas rubricas que gostaria de aliviar. Uma redução não pode exceder a própria despesa.
cut-column-monthly = Por mês
cut-column-cut = Redução
cut-column-after = Depois
cut-column-yearly = Poupança por ano
cut-total = Total
cut-horizon-label = Horizonte
cut-settings-title = Definições
cut-options-hint = A taxa e o montante pretendido são opcionais.
cut-report-button = Relatório PDF
cut-chart-title = O seu saldo, sem e com as reduções
cut-chart-hint = Linha contínua: o saldo real dos últimos doze meses; tracejado cinzento: a projeção sem redução; azul: com; verde: o dinheiro poupado.
cut-donut-title = As suas despesas por mês após redução
cut-donut-caption = por mês após redução
cut-donut-others = Outras rubricas
cut-donut-saved = Poupado
cut-legend-with = Com as reduções
cut-legend-without = Sem redução
cut-years = { $years ->
        [one] { $years } ano
       *[other] { $years } anos
    }
cut-headline-none = Escreva uma redução na tabela para ver o seu efeito.
cut-headline = Ao reduzir { $count ->
        [one] esta rubrica
       *[other] estas { $count } rubricas
    }, pouparia mais { $monthly } por mês, ou seja, { $yearly } por ano.
cut-tile-monthly = Poupança por mês
cut-tile-yearly = Poupança por ano
cut-tile-horizon = Poupança em { $years ->
        [one] { $years } ano
       *[other] { $years } anos
    }
cut-tile-spending = Despesas por mês
cut-target-already = Já tem { $amount }.
cut-target-sooner = Atingiria { $amount } por volta de { $with } em vez de { $without }: { $months ->
        [0] não mais cedo
        [one] um mês mais cedo
       *[other] { $months } meses mais cedo
    }.
cut-target-only-with = Com estas reduções, atingiria { $amount } por volta de { $with }; sem elas, ao seu ritmo atual, nunca.
cut-target-never = Mesmo com estas reduções, não atingiria { $amount } ao seu ritmo atual.
cut-note-seasons = Cada redução acompanha as estações da sua rubrica: uma rubrica que pesa sobretudo no verão poupa sobretudo no verão.
cut-note-capped = Uma redução introduzida excedia a despesa: foi limitada à própria despesa.
cut-invalid-cut = Esta redução não é legível: uma percentagem de 0 a 100, ou um montante por mês.
cut-report-settings = As definições
cut-report-result = O resultado
cut-report-accounts = Contas acompanhadas

# --- F46 — Préparer mes vacances (Fabrice, 10/10/2026) -----------------------------
# Ce que coûtera le prochain voyage, séjour ou croisière.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-holiday = Preparar as minhas férias
window-holiday-title = Preparar as minhas férias
holiday-trip-title = A viagem
holiday-field-trip = Tipo de viagem
holiday-trip-stay = Estadia
holiday-trip-cruise = Cruzeiro
holiday-field-adults = Adultos
holiday-field-children = Crianças
holiday-field-nights = Duração da estadia, em noites
holiday-field-days = Dias
holiday-field-months = Meses antes da partida
holiday-field-stops = Número de escalas
holiday-saved-title = Já poupado
holiday-saved-hint = Marque as contas onde o dinheiro das férias já está posto de parte: o seu saldo real conta como já poupado.
holiday-budget-title = O orçamento
holiday-budget-hint = Para cada rubrica, um montante, para quem conta e por quanto tempo. Vazia, uma rubrica não conta.
holiday-optional-title = Rubricas opcionais
holiday-result-title = O resultado
holiday-donut-title = Para onde vai o dinheiro da viagem
holiday-donut-caption = para a viagem
holiday-child-label = Preço criança
holiday-count-label = Camarotes
holiday-open = Abrir um projeto…
holiday-save = Guardar o projeto…
holiday-pdf = Relatório PDF
holiday-excel = Exportar para Excel
holiday-file-filter = Projeto de férias
holiday-replace-question = Abrir este projeto substituirá o que está escrito na janela. Continuar?
holiday-file-saved = Projeto guardado: { $file }
holiday-file-opened = Projeto aberto: { $file }
holiday-file-not-project = Este ficheiro não é um projeto de férias do Radinus.
holiday-file-too-recent = Este projeto vem de uma versão mais recente do Radinus: atualize o Radinus para o abrir.
holiday-file-failed = Não foi possível ler ou escrever o ficheiro: { $reason }
holiday-line-transport = Transporte de ida e volta
holiday-line-lodging = Alojamento
holiday-line-meals = Refeições e despesas correntes
holiday-line-visits = Visitas e lazer
holiday-line-port = Deslocação até ao porto
holiday-line-cabins = Camarotes
holiday-line-service = Taxa de serviço (gorjetas)
holiday-line-drinks = Pacote de bebidas
holiday-line-excursions = Excursões nas escalas
holiday-line-port-taxes = Taxas portuárias
holiday-line-wifi = Wi-Fi a bordo
holiday-line-onboard = Despesas a bordo e nas escalas
holiday-line-other = Outras despesas e imprevistos
holiday-line-insurance = Seguro de cancelamento
holiday-line-stay-tax = Taxa turística
holiday-line-car = Carro no destino, combustível e portagens
holiday-line-parking = Estacionamento no aeroporto ou na estação
holiday-line-bank = Comissões bancárias no estrangeiro
holiday-line-formalities = Formalidades (passaporte, visto, vacinas)
holiday-line-pets = Guarda dos animais
holiday-span-trip = pela estadia
holiday-span-night = por noite
holiday-span-day = por dia
holiday-span-stop = por escala
holiday-who-all = para todos
holiday-who-person = por pessoa
holiday-who-adults = por adulto
holiday-cabins-count = { $count ->
        [one] { $count } camarote
       *[other] { $count } camarotes
    }
holiday-days = { $days ->
        [one] { $days } dia
       *[other] { $days } dias
    }
holiday-invalid-count = Um número inteiro, por favor.
holiday-invalid-amount = Este montante não é legível: um número positivo, ou uma percentagem de 0 a 100.
holiday-headline-empty = Escreva os montantes do orçamento para ver quanto custará a viagem.
holiday-headline-stay = Esta estadia custaria { $total } para { $people ->
        [one] uma pessoa
       *[other] { $people } pessoas
    } e { $nights ->
        [0] nenhuma noite
        [one] uma noite
       *[other] { $nights } noites
    }.
holiday-headline-cruise = Este cruzeiro custaria { $total } para { $people ->
        [one] uma pessoa
       *[other] { $people } pessoas
    } e { $nights ->
        [0] nenhuma noite
        [one] uma noite
       *[other] { $nights } noites
    }.
holiday-tile-total = Custo total
holiday-tile-person = Por pessoa
holiday-tile-person-day = Por pessoa e por dia
holiday-tile-saved = Já poupado
holiday-tile-remaining = Falta financiar
holiday-tile-monthly = Poupança necessária
holiday-remaining-none = Nada: está coberto
holiday-monthly-none = Nada a pôr de parte
holiday-monthly-now = Partida este mês
holiday-note-days = Os dias são as noites mais uma: sete noites dão oito dias.
holiday-note-child = Por pessoa, uma criança paga o preço criança se este for indicado; vazio, paga como um adulto.
holiday-note-percent = Uma percentagem de seguro incide sobre as rubricas principais da viagem; a das comissões bancárias, sobre as despesas feitas no destino.
holiday-sheet-budget = Orçamento
holiday-sheet-result = Resultado
holiday-column-line = Rubrica
holiday-column-amount = Montante
holiday-column-child = Preço criança
holiday-column-who = Para quem
holiday-column-span = Por quanto tempo
holiday-column-cost = Custo
holiday-disclaimer = Uma estimativa tirada dos seus próprios montantes: os preços reais podem variar.

# --- F45 (suite) — le projet de réduction en fichier (Fabrice, 10/10/2026) --------
# « Rajoute enregistrement et chargement JSON et aussi export Excel. »
cut-file-filter = Projeto de redução
cut-file-not-project = Este ficheiro não é um projeto de redução do Radinus.
cut-file-too-recent = Este projeto vem de uma versão mais recente do Radinus: atualize o Radinus para o abrir.
cut-sheet-items = Rubricas

# --- F47 — Carnet de ma voiture (Fabrice, 10/10/2026) --------------------------------
# L'historique de la voiture : énergie, entretien, pièces, pneus, pannes, assurance, contrôle.
# Les phrases sont écrites par le noyau ; la fenêtre n'en compose aucune.
menu-tools-car = Caderneta do meu carro
window-car-title = Caderneta do meu carro
car-unnamed = O meu carro
car-sheet-title = O carro
car-field-plate = Matrícula
car-field-make = Marca
car-field-model = Modelo
car-field-engine = Motorização
car-field-first-hand = Primeiro proprietário
car-field-registered = Data da primeira matrícula
car-field-acquired = Data de aquisição
car-field-acquired-km = Quilometragem na aquisição
car-field-service = Revisão a cada
car-field-service-or = ou a cada
car-unit-months-short = meses
car-unit-km = km
car-tariff-title = Tarifa do carregamento em casa
car-tariff-hint = Esta tarifa fica guardada na caderneta do carro: não altera a das preferências.
car-tariff-reset = Retomar a tarifa das preferências
car-engine-petrol = Gasolina
car-engine-diesel = Diesel
car-engine-lpg = GPL
car-engine-e85 = E85 (bioetanol)
car-engine-hybrid = Híbrido
car-engine-plug-in = Híbrido plug-in
car-engine-electric = Elétrico
car-engine-hydrogen = Hidrogénio
car-energy-petrol = Gasolina
car-energy-diesel = Gasóleo
car-energy-lpg = GPL
car-energy-e85 = E85
car-energy-electricity = Eletricidade
car-energy-hydrogen = Hidrogénio
car-unit-litre = L
car-unit-kwh = kWh
car-unit-kg = kg
car-rubric-energy = Energia
car-rubric-upkeep = Manutenção corrente
car-rubric-service = Revisão
car-rubric-wear = Peças de desgaste
car-rubric-tyres = Pneus
car-rubric-breakdown = Avarias
car-rubric-insurance = Seguro
car-rubric-inspection = Inspeção periódica
car-part-brake-pads = Pastilhas de travão
car-part-brake-discs = Discos de travão
car-part-timing-belt = Correia de distribuição
car-part-clutch = Embraiagem
car-part-battery-12v = Bateria de 12 V
car-part-shock-absorbers = Amortecedores
car-part-wipers = Escovas limpa-para-brisas
car-part-spark-plugs = Velas de ignição
car-part-glow-plugs = Velas de incandescência
car-part-particulate-filter = Filtro de partículas
car-part-catalytic-converter = Catalisador
car-part-fuel-cell-filter = Filtro da pilha de combustível
car-part-exhaust = Escape
car-part-other = Outra peça…
car-axle-all = Os quatro pneus
car-axle-front = Pneus dianteiros
car-axle-rear = Pneus traseiros
car-verdict-pass = Aprovado
car-verdict-counter = Reinspeção
car-charge-station = Num posto de carregamento
car-charge-home = Em casa
car-slot-peak = Horas de ponta
car-slot-off-peak = Horas de vazio
car-entry-new = Nova linha
car-entry-edit = Alterar a linha
car-field-date = Data
car-field-km = Conta-quilómetros
car-field-rubric = Rubrica
car-field-amount = Montante
car-field-garage = Oficina ou posto
car-field-note = Nota
car-field-energy = Energia
car-field-quantity = Quantidade
car-field-charge = Carregamento
car-field-slot = Hora do carregamento
car-field-part = Peça
car-field-part-name = Nome da peça
car-field-axle = Pneus trocados
car-field-verdict = Resultado
car-field-months = Meses cobertos
car-field-battery = Estado da bateria
car-home-amount-hint = O montante de um carregamento em casa é calculado com a tarifa do carro.
car-entry-add = Adicionar à caderneta
car-entry-update = Guardar a linha
car-entry-cancel = Cancelar
car-entry-delete = Eliminar a linha
car-delete-question = Eliminar esta linha da caderneta?
car-from-operation = Retomar uma operação…
car-pick-account = De que conta vem a despesa?
car-pick-operation = Que operação?
car-pick-take = Retomar
car-pick-none = Nenhuma despesa nesta conta.
car-pick-taken = Operação retomada: preencha o conta-quilómetros e a rubrica e, depois, adicione a linha.
car-history-title = O histórico
car-filter-all = Todas as rubricas
car-history-empty = Ainda não há linhas.
car-history-hint = Clique numa linha para a alterar.
car-column-date = Data
car-column-km = Km
car-column-rubric = Rubrica
car-column-detail = Detalhe
car-column-amount = Montante
car-column-garage = Oficina
car-column-note = Nota
car-column-share = Parte
car-column-per-km = Por km
car-column-energy = Energia
car-column-quantity = Quantidade
car-column-price = Preço médio
car-column-consumption = Consumo
car-column-part = Peça
car-column-changes = Substituições
car-column-last = Última substituição
car-column-life = Duração
car-column-next = Próxima substituição
car-total = Total
car-summary-title = Quanto custa o carro
car-headline-empty = Preencha a ficha e, depois, adicione uma primeira linha: um abastecimento, uma revisão, uma fatura da oficina…
car-headline = Desde { $since }, o seu carro custou-lhe { $total }.
car-headline-km = Desde { $since }, o seu carro custou-lhe { $total } por { $km } percorridos: { $cost } por quilómetro.
car-tile-total = Custo total
car-tile-month = Por mês
car-tile-km = Por quilómetro
car-tile-driven = Quilómetros percorridos
car-tile-consumption = Consumo
car-tile-energy-km = Energia por quilómetro
car-km = { $value } km
car-quantity = { $value } { $unit }
car-per-100 = { $value } { $unit } / 100 km
car-per-unit = { $price } / { $unit }
car-months = { $months ->
        [one] { $months } mês
       *[other] { $months } meses
    }
car-detail-battery = Bateria: { $value } %
car-battery-line = { $when }: { $value } %
car-rubrics-title = Por rubrica
car-energy-title = A energia
car-parts-title = Peças de desgaste
car-tyres-title = Pneus
car-battery-title = Estado da bateria
car-years-title = Quanto o carro custou em cada ano
car-donut-title = Para onde vai o dinheiro
car-donut-caption = no total
car-deadlines-title = Os prazos
car-deadlines-empty = Ainda não há prazos: registe uma revisão, uma inspeção periódica, um seguro ou duas substituições da mesma peça.
car-deadline-service = Revisão
car-deadline-inspection = Inspeção periódica
car-deadline-counter = Reinspeção da inspeção periódica
car-deadline-insurance = Fim do seguro
car-when-date = a { $date }
car-when-km = aos { $km }
car-when-km-reached = aos { $km }, por volta de { $month } ao seu ritmo
car-when-date-km = a { $date } ou aos { $km }, o que ocorrer primeiro
car-when-inspection-unknown = Registe a última inspeção periódica para saber a data da próxima.
car-tone-late = Ultrapassado
car-tone-soon = Em breve
car-note-since = Tudo se conta a partir da aquisição: a data e o conta-quilómetros registados na ficha.
car-note-consumption = O consumo mede-se de depósito cheio a depósito cheio: ateste o depósito e registe o conta-quilómetros de cada vez.
car-note-e85 = Um carro E85 bebe o que lhe derem: os quilómetros que se seguem a um abastecimento contam para esse combustível.
car-note-home = Um carregamento em casa é calculado à tarifa do carro no dia em que é registado e mantém esse custo.
car-note-inspection = A inspeção periódica segue a regra francesa: a primeira nos quatro anos seguintes à primeira matrícula, depois de dois em dois anos; uma reinspeção, no prazo de dois meses.
car-disclaimer = Os prazos e as durações são estimativas tiradas da caderneta: só o livro de manutenção do fabricante faz fé.
car-invalid-date = Indique uma data válida que não esteja no futuro, por favor.
car-invalid-acquired = A data de aquisição não pode ser anterior à primeira matrícula.
car-invalid-km = Indique o conta-quilómetros em quilómetros inteiros, por favor.
car-invalid-amount = Este montante não é legível.
car-invalid-quantity = Escreva a quantidade: litros, kWh ou quilos.
car-invalid-part = Escolha a peça substituída ou escreva o seu nome.
car-invalid-rubric = Escolha uma rubrica.
car-invalid-months = Indique um número inteiro de meses, por favor.
car-invalid-battery = Indique um estado da bateria de 0 a 100 %, por favor.
car-open = Abrir uma caderneta…
car-save = Guardar a caderneta…
car-report-button = Relatório PDF
car-file-filter = Caderneta do carro
car-file-saved = Caderneta guardada: { $file }
car-file-opened = Caderneta aberta: { $file }
car-file-not-logbook = Este ficheiro não é uma caderneta de carro do Radinus.
car-file-too-recent = Esta caderneta vem de uma versão mais recente do Radinus: atualize o Radinus para a abrir.
car-replace-question = Abrir esta caderneta substituirá a que está na janela. Continuar?
car-sheet-history = Caderneta
car-sheet-summary = Síntese

analysis-history-hint = Quanto mais longo for o seu histórico, melhor será esta análise: o ideal é ter pelo menos um ano de operações.

# --- F48 — Dividir uma despesa (Fabrice, 11/10/2026, P-71) ---
menu-tools-sharing = Dividir uma despesa
window-sharing-title = Dividir uma despesa
sharing-question = Quem paga o quê?
sharing-setup-title = A divisão
sharing-field-label = Nome
sharing-label-hint = Por exemplo « Restaurante de 12/10 » ou « Viagem à Bretanha 2027 »: dá nome aos ficheiros e aos relatórios.
sharing-field-total = Total
sharing-total-hint = Se ficar vazio, o total é a soma das rubricas e dos extras de cada pessoa.
sharing-field-rule = Regra
sharing-field-rounding = Arredondamento
sharing-field-people = Pessoas
sharing-mode-whole = Uma regra para toda a despesa
sharing-mode-item = Uma regra por rubrica
sharing-rule-equal = Partes iguais
sharing-rule-parts = Por partes
sharing-rule-percent = Por percentagens
sharing-rule-income = Proporcional ao rendimento
sharing-rounding-cent = Ao cêntimo
sharing-rounding-euro = À unidade inteira
sharing-round-euro = Arredondar a unidades inteiras
sharing-hide-incomes = Ocultar os rendimentos nos relatórios e na exportação
sharing-people-title = As pessoas
sharing-people-hint = Uma linha por pessoa, uma coluna por rubrica: marque quem participa em quê. Tudo o resto é facultativo. Alguém que desiste e deixa o seu sinal: um montante exato igual ao que pagou e nenhuma caixa marcada.
sharing-add-person = Adicionar uma pessoa
sharing-person-default = Pessoa { $number }
sharing-items-title = As rubricas
sharing-items-hint = Apenas o que não diz respeito a todos, como o vinho. O resto do total vai para a rubrica comum.
sharing-add-item = Adicionar uma rubrica
sharing-common = Comum
sharing-payments-title = Os pagamentos
sharing-payments-hint = Quem pagou, quanto e quando. Uma linha sem montante ainda não conta.
sharing-payments-none = Nenhum pagamento por agora.
sharing-add-payment = Adicionar um pagamento
sharing-result-title = O resultado
sharing-balances-title = Como estão os pagamentos
sharing-transfers-title = Transferências propostas
sharing-delete = Eliminar
sharing-delete-person-question = Esta pessoa tem pagamentos: eliminá-los com ela?
sharing-disclaimer = O Radinus propõe uma divisão: entre amigos, cada um é livre de se entender de outra forma.
sharing-column-person = Pessoa
sharing-column-household = Agregado
sharing-column-income = Rendimento
sharing-column-parts = Partes
sharing-column-percent = %
sharing-column-floor = Pelo menos
sharing-column-cap = No máximo
sharing-column-fixed = Montante exato
sharing-column-alone = Os seus extras
sharing-column-gift = Excedente oferecido
sharing-column-share = Parte
sharing-column-typed = % escrita
sharing-column-constraint = O que se aplicou
sharing-column-due = A pagar
sharing-column-item = Rubrica
sharing-column-amount = Montante
sharing-column-rule = Regra
sharing-column-participants = Participantes
sharing-column-unit = Agregado ou pessoa
sharing-column-members = Membros
sharing-column-paid = Pago
sharing-column-balance = Saldo
sharing-column-date = Data
sharing-column-who = Quem
sharing-column-label = Nome
sharing-help-household = As pessoas do mesmo agregado acertam contas em conjunto: os seus pagamentos e o que devem somam-se, e recebem um único extrato. Exemplo: « Família Martin » para os pais e os filhos.
sharing-help-income = Só é usado pela regra « Proporcional ao rendimento »: quanto mais elevado o rendimento, maior a parte. Escreva o rendimento mensal.
sharing-help-parts = Uma pessoa com 2 partes paga o dobro de uma pessoa com 1 parte. Exemplo: adulto 1, criança 0,5.
sharing-help-percent = A parte da despesa que a pessoa paga. As percentagens têm de somar 100 % no total.
sharing-help-floor = A pessoa pagará pelo menos este montante, mesmo que a sua parte calculada seja menor. A diferença alivia os outros.
sharing-help-cap = A pessoa nunca pagará mais do que este montante. O que não paga recai sobre os outros participantes das suas rubricas.
sharing-help-fixed = A pessoa paga este montante, aconteça o que acontecer, e o resto é dividido pelos outros. Exemplo: alguém que desiste e deixa o seu sinal.
sharing-help-alone = O que a pessoa tomou só para si, como uma sobremesa ou um café. Paga-o por inteiro, além da sua parte.
sharing-help-gift = Se a pessoa pagou mais do que a sua parte: marcada, o excedente é uma oferta ao grupo; desmarcada, é-lhe devolvido.
sharing-help-items = Marque as pessoas que participam nesta rubrica. A rubrica Comum é o que resta do total depois de retiradas as outras rubricas.
sharing-help-due = O que a pessoa deve no total: a sua parte das rubricas, os seus extras e o arredondamento.
sharing-help-share = O que a sua parte representa, em percentagem da soma dividida.
sharing-help-typed = A percentagem que escreveu. Pode diferir da parte real quando se aplicou um mínimo, um máximo ou um montante exato.
sharing-help-constraint = Indica se a parte da pessoa foi alterada por um mínimo, um máximo, um montante exato ou um excedente oferecido.
sharing-help-item = Apenas o que não diz respeito a todos, como o vinho. O resto do total vai para a rubrica Comum, dividido pelos que nela estão marcados.
sharing-help-rule = Como esta rubrica é dividida: em partes iguais, por partes, por percentagens ou proporcional ao rendimento.
sharing-help-paid = O que o agregado ou a pessoa já pagou, segundo os pagamentos registados.
sharing-help-balance = O que falta pagar, ou o que foi pago a mais do que a parte. Exemplo: « Falta pagar: 61,54 € ».
sharing-advice-equal = { $count ->
        [one] { $total } para uma só pessoa.
       *[other] { $total } ÷ { $count } pessoas = { $amount } cada um.
    }
sharing-advice-equal-varied = Em partes iguais entre quem participa, tendo em conta os limites e as exclusões.
sharing-advice-parts = { $parts } partes no total: uma parte vale { $amount }.
sharing-advice-parts-varied = Cada um paga segundo as suas partes, tendo em conta os limites e as exclusões. Uma caixa vazia conta como 1 parte.
sharing-advice-percent-rest = Faltam { $rest } % para chegar a 100 %.
sharing-advice-percent-over = As percentagens ultrapassam 100 % em { $over } %.
sharing-advice-percent-ok = As percentagens somam exatamente 100 %.
sharing-advice-percent-nobody = As percentagens já somam 100 %: { $names } não { $count ->
        [one] pagaria
       *[other] pagariam
    } nada.
sharing-advice-income = Cada um paga { $rate } % do seu rendimento.
sharing-advice-income-missing = Escreva o rendimento de cada pessoa para dividir em proporção aos rendimentos.
sharing-advice-income-varied = Cada um paga a mesma proporção do seu rendimento, tendo em conta os limites e as exclusões.
sharing-advice-empty = Escreva o montante a dividir.
sharing-apply-advice = Usar os valores aconselhados
sharing-help-apply-advice = Preenche as caixas vazias com os valores a cinzento. As caixas já preenchidas não mudam.
sharing-from-incomes = Percentagens a partir dos rendimentos
sharing-help-from-incomes = Substitui as percentagens pela parte de cada rendimento no total dos rendimentos. Somam 100 %.
sharing-reset-percents = Voltar a dividir tudo
sharing-help-reset-percents = Apaga as percentagens e divide-as em partes iguais por todos. Útil depois de adicionar uma pessoa.
sharing-reset-percents-question = Apagar todas as percentagens e dividi-las em partes iguais?
sharing-open = Abrir um projeto…
sharing-save = Guardar o projeto…
sharing-pdf-distribution = Divisão (PDF)
sharing-pdf-payments = Estado dos pagamentos (PDF)
sharing-pdf-statements = Extratos individuais (PDF)…
sharing-statements-everyone = Todos
sharing-excel = Exportar para Excel
sharing-file-filter = Projeto de divisão
sharing-replace-question = Abrir este projeto substituirá o que está escrito na janela. Continuar?
sharing-file-saved = Projeto guardado: { $file }
sharing-file-opened = Projeto aberto: { $file }
sharing-file-not-project = Este ficheiro não é um projeto de divisão do Radinus.
sharing-file-too-recent = Este projeto vem de uma versão mais recente do Radinus: atualize o Radinus para o abrir.
sharing-file-failed = Não foi possível ler ou escrever o ficheiro: { $reason }
sharing-statements-replace-question = { $count ->
        [one] Já existe um extrato nesta pasta. Substituí-lo?
       *[other] Já existem { $count } extratos nesta pasta. Substituí-los?
    }
sharing-statements-written = { $count ->
        [one] Um extrato escrito em « { $folder } ».
       *[other] { $count } extratos escritos em « { $folder } ».
    }
sharing-too-many-people = Uma divisão tem no máximo 40 pessoas.
sharing-too-many-items = Uma divisão tem no máximo 20 rubricas.
sharing-too-many-payments = Uma divisão tem no máximo 400 pagamentos.
sharing-invalid-amount = Este montante não é legível: um número positivo.
sharing-invalid-number = Este número não é legível: um número positivo.
sharing-invalid-percent = Uma percentagem vai de 0 a 100.
sharing-invalid-date = Esta data não é legível.
sharing-name-missing = Cada pessoa deve ter um nome.
sharing-name-duplicate = Já existe « { $name } »: distinga-os, por exemplo com uma inicial.
sharing-floor-above-cap = O mínimo ultrapassa o máximo.
sharing-item-label-missing = Esta rubrica não tem nome.
sharing-items-above-total = As rubricas e os extras de cada pessoa ultrapassam o total em { $amount }.
sharing-payment-person = Escolha quem pagou.
sharing-percent-total = As percentagens somam { $sum } %: têm de somar 100 %.
sharing-percent-total-item = « { $item } »: as percentagens somam { $sum } %: têm de somar 100 %.
sharing-item-nobody = Ninguém participa em « { $item } ».
sharing-item-no-weight = Ninguém pesa em « { $item } »: todos os seus participantes estão a zero.
sharing-income-missing = Falta o rendimento de { $name }.
sharing-fixed-above = Os montantes exatos ultrapassam a soma a dividir em { $amount }.
sharing-floors-above = Os mínimos ultrapassam a soma a dividir em { $amount }.
sharing-cap-alone = { $name } é a única pessoa a participar em « { $item } »: o seu máximo não pode ser respeitado.
sharing-caps-short = Os máximos não chegam para cobrir a soma: faltam { $amount }.
sharing-impossible = Estas condições não podem ser todas respeitadas: afrouxe um mínimo ou um máximo.
sharing-constraint-floor = Mínimo atingido
sharing-constraint-cap = Máximo atingido
sharing-constraint-fixed = Montante exato
sharing-constraint-gift = Excedente oferecido
sharing-and = { $first } e { $last }
sharing-outside = Fora das rubricas
sharing-alone = Os seus extras
sharing-rounding = Arredondamento
sharing-headline-empty = Adicione as pessoas que dividem a despesa.
sharing-headline-no-amount = Escreva o total, ou as rubricas a dividir.
sharing-headline-equal = { $total } a dividir: cada um paga { $amount }.
sharing-headline-range = { $total } a dividir: de { $min } a { $max } consoante a pessoa.
sharing-participants = { $count ->
        [0] Nenhum participante
        [one] Um participante
       *[other] { $count } participantes
    }
sharing-balance-due = Falta pagar: { $amount }
sharing-balance-over = Pagou { $amount } a mais do que a sua parte
sharing-balance-even = Em dia
sharing-summary-collected = { $collected } pagos de { $total }.
sharing-summary-owing = { $count ->
        [0] Toda a gente está em dia.
        [one] Só uma pessoa deve ainda { $amount }.
       *[other] { $count } pessoas devem ainda { $amount } no total.
    }
sharing-remaining-outside = Falta pagar da despesa: { $amount }
sharing-remaining-reimburse = A reembolsar a { $name }: { $amount }
sharing-all-settled = Está tudo saldado: ninguém deve nada a ninguém.
sharing-transfer = { $from } deve { $amount } a { $to }
sharing-warning-over-paid = Os pagamentos ultrapassam a despesa em { $amount }: verifique os montantes.
sharing-note-income-zero = { $name } não paga nada em { $items }: o seu rendimento é 0.
sharing-note-excluded = { $name } não participa em « { $item } »: a sua parte é repartida pelos outros.
sharing-note-gift = O excedente oferecido por { $giver } reduz a parte dos outros: { $name } pagou agora mais do que a sua parte.
sharing-note-outside = { $name } paga { $amount } fora das suas rubricas: a soma é deduzida ao que os outros dividem.
sharing-note-keeper = Arredondado a unidades inteiras: { $name } fica com os cêntimos, para que o total saia certo.
sharing-report-distribution = Divisão
sharing-report-sharing = A divisão
sharing-report-who-pays = Quem paga o quê
sharing-report-items = O detalhe por rubrica
sharing-report-payments = Estado dos pagamentos
sharing-report-as-of = Estado a { $date }
sharing-report-balances = Parte, pago, saldo
sharing-report-statement = Extrato — { $name }
sharing-report-your-share = A sua parte
sharing-statement-total = Total do agregado: { $amount }
sharing-statement-pay = A pagar a { $name }: { $amount }
sharing-statement-receive = A receber de { $name }: { $amount }
sharing-sheet-people = Pessoas
sharing-sheet-items = Rubricas
sharing-sheet-result = Resultado
sharing-sheet-payments = Pagamentos
sharing-sheet-balances = Reembolsos

## O assistente de exportação de uma base (P-74, Fabrice, 19/10/2026).
window-database-export-title = Assistente de exportação da base « { $base } »
menu-tools-export = Assistente de exportação da base…
base-export-only-this = Só a base « { $base } », selecionada na lista, será exportada. As outras bases não são afetadas.
base-export-purpose = Este assistente copia os dados da base para ficheiros que outros programas sabem ler: uma folha de cálculo, uma base de dados como o Access, outro programa de gestão de contas. A própria base não é alterada.
base-export-step-format = 1. O formato
base-export-step-options = 2. As opções
base-export-step-place = 3. A localização
base-export-step-summary = 4. O resumo
base-export-format-xlsx = Excel (.xlsx)
base-export-format-xlsx-hint = Um livro com uma folha por tabela, que o Excel e a maioria das folhas de cálculo conseguem ler.
base-export-format-ods = Calc (.ods)
base-export-format-ods-hint = O formato livre do LibreOffice e do OpenOffice, com uma folha por tabela.
base-export-format-csv = CSV (.csv)
base-export-format-csv-hint = Um ficheiro de texto por tabela, com os valores separados por ponto e vírgula: o formato que quase todos os programas sabem importar, incluindo o Access.
base-export-format-json = JSON (.json)
base-export-format-json-hint = Para programadores e aplicações: cada tabela com o seu nome, com um cabeçalho que descreve a exportação.
base-export-format-xml = XML (.xml)
base-export-format-xml-hint = O mesmo conteúdo que o JSON, escrito em XML.
base-export-format-sql = Script SQL (.sql)
base-export-format-sql-hint = As instruções que recriam as tabelas e os seus dados noutra base de dados (MySQL, PostgreSQL, SQLite…).
base-export-format-sqlite = Base SQLite (.sqlite)
base-export-format-sqlite-hint = Uma base de dados autónoma, sem palavra-passe, que muitas ferramentas abrem diretamente.
base-export-format-qif = QIF, um ficheiro por conta (.qif)
base-export-format-qif-hint = Para levar as suas contas para outro programa de gestão de contas (Money, Quicken, GnuCash, Grisbi…).
base-export-format-ofx = OFX, um ficheiro por conta (.ofx)
base-export-format-ofx-hint = O formato dos extratos bancários, que a maioria dos programas de gestão de contas sabe importar.
base-export-lossy = Atenção: o QIF e o OFX não conseguem guardar tudo. Só passam as operações das contas, com os seus terceiros, as suas categorias e os seus comentários; uma transferência torna-se uma operação normal de cada lado, e o resto (orçamentos, operações periódicas, projetos, afetações…) fica para trás. Para guardar tudo, escolha outro formato.
base-export-planned-note = As operações previstas e as operações sem data não são exportadas: ainda não passaram pelo banco. O seu número será indicado no fim.
base-export-dates-hint = As datas são escritas ano-mês-dia (2026-12-31) e os montantes na moeda da base: nenhum programa se pode enganar.
base-export-group-layout = Ficheiros
base-export-layout-one = Tudo num único ficheiro
base-export-layout-per-table = Um ficheiro por tabela, numa pasta
base-export-group-decimal = Separador decimal dos montantes
base-export-decimal-point = O ponto (1234.56)
base-export-decimal-comma = A vírgula (1234,56)
base-export-group-quotes = Aspas
base-export-quotes-all = Cada valor entre aspas
base-export-quotes-none = Sem aspas
base-export-csv-replacements-hint = Para que cada ficheiro possa ser relido sem erros, um ponto e vírgula num texto passa a ponto de exclamação, uma mudança de linha passa a espaço e, sem aspas, umas aspas passam a apóstrofo. O número de substituições será indicado no fim.
base-export-group-qif-order = Ordem das datas
base-export-qif-day-month = O dia antes do mês (31/12/2026)
base-export-qif-month-day = O mês antes do dia (12/31/2026)
base-export-qif-order-hint = Escolha a ordem que o programa que vai ler os ficheiros espera: primeiro o dia na Europa, primeiro o mês nos Estados Unidos.
base-export-no-option = Este formato não tem opções.
base-export-choose-file = Escolher o ficheiro…
base-export-choose-folder = Escolher a pasta…
base-export-place-file = A exportação será escrita neste ficheiro:
base-export-place-folder = A exportação será escrita nesta pasta, criada para o efeito:
base-export-place-none = Ainda não foi escolhida nenhuma localização.
base-export-place-needed = Escolha primeiro onde escrever a exportação.
base-export-folder-exists = A pasta « { $name } » já existe. Os ficheiros com o mesmo nome que ela contém serão substituídos. Continuar?
base-export-summary-base = Base
base-export-summary-format = Formato
base-export-summary-options = Opções
base-export-summary-place = Localização
base-export-unprotected = Esta base está protegida por uma palavra-passe, mas a exportação não estará: qualquer pessoa que tenha estes ficheiros poderá ler as suas contas. Guarde-os num lugar seguro.
base-export-previous = Anterior
base-export-next = Seguinte
base-export-run = Exportar
base-export-running = A exportar…
base-export-done = A base « { $base } » foi exportada: { $tables ->
        [one] { $tables } tabela
       *[other] { $tables } tabelas
    }, { $rows ->
        [one] { $rows } linha
       *[other] { $rows } linhas
    }.
base-export-done-accounts = A base « { $base } » foi exportada: { $accounts ->
        [one] { $accounts } conta
       *[other] { $accounts } contas
    }, { $operations ->
        [one] { $operations } operação
       *[other] { $operations } operações
    }.
base-export-done-replacements = { $count ->
        [one] Foi substituído { $count } carácter nos ficheiros CSV.
       *[other] Foram substituídos { $count } caracteres nos ficheiros CSV.
    }
base-export-done-controls = { $count ->
        [one] Foi substituído { $count } carácter de controlo, que este formato não pode conter, por « � ».
       *[other] Foram substituídos { $count } caracteres de controlo, que este formato não pode conter, por « � ».
    }
base-export-done-excel-cut = { $count ->
        [one] { $count } texto ultrapassava os 32.767 caracteres, o limite do Excel: foi cortado no livro. Os outros formatos mantêm-no inteiro.
       *[other] { $count } textos ultrapassavam os 32.767 caracteres, o limite do Excel: foram cortados no livro. Os outros formatos mantêm-nos inteiros.
    }
base-export-done-anomalies = { $count ->
        [one] { $count } valor ilegível foi copiado tal como estava.
       *[other] { $count } valores ilegíveis foram copiados tal como estavam.
    }
base-export-done-planned = { $count ->
        [one] { $count } operação prevista foi deixada de fora.
       *[other] { $count } operações previstas foram deixadas de fora.
    }
base-export-done-undated = { $count ->
        [one] { $count } operação sem data foi deixada de fora.
       *[other] { $count } operações sem data foram deixadas de fora.
    }
base-export-done-adjusted = { $count ->
        [one] { $count } valor foi ajustado ao formato.
       *[other] { $count } valores foram ajustados ao formato.
    }
base-export-too-old = Esta base vem de uma versão mais antiga do Radinus. Abra-a primeiro uma vez no Radinus, que a vai atualizar, e depois exporte-a.
base-export-too-recent = Esta base foi guardada por uma versão mais recente do Radinus. Atualize o Radinus para a exportar.
base-export-not-radinus = Este ficheiro não é uma base Radinus.
base-export-failed = Não foi possível fazer a exportação: { $reason }

## O menu Ferramentas da janela das bases indica o nome da base (Fabrice, 19/10/2026).
databases-tools-selected = Base selecionada: « { $base } »
databases-tools-none = Nenhuma base selecionada
menu-tools-backup = Fazer uma cópia de segurança da base « { $base } »…
menu-tools-backup-none = Fazer uma cópia de segurança da base selecionada…
menu-tools-restore = Restaurar a base « { $base } »…
menu-tools-restore-none = Restaurar a base selecionada…
menu-tools-repair = Reparar e otimizar a base « { $base } »…
menu-tools-repair-none = Reparar e otimizar a base selecionada…
