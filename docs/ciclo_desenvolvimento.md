#Ciclos de desenvolvimento das tarefas

## Observações gerais

- O inicio sempre sera da equipe DEVEL
- Cada tarefa RESOLVIDA pela equipe DEVEL deve ser encaminhar para equipe de QS
- As tarefas sao relacionadas por uma cópia sempre uma continuidade da tarefa haverá uma copia da tarefa para dar sequencia e continuidade
- O encaminhamento da tarefa DEVEL para o QS é feito por uma cópia da tarefa
- O tarefa inicia no DEVEL depois vai para QS, se tiver RETORNO_TESTES volta para DEVEL e depois vai para QS novamente, até que a tarefa de QS seja TESTE_OK

## Ciclo normal de uma tarefa de desenvolvimento quando não há retorno de testes

- As situações esperada para as tarefas de DEVEL são, na ordem cronológica, NOVA (quando criadas) -> EM_ANDAMENTO -> RESOLVIDA -> FECHADA
- Entre a situacao RESOLVIDA e FECHADA as tarefas sao encaminhadas para o QS.
- No QS as tarefas sao NOVA (quando criadas) -> EM_ANDAMENTO -> TESTE_OK -> TESTE_OK_FECHADA.

## Situacao CONTINUA_PROXIMA_SPRINT

- Um tarefa de DEVEL ou QS pode nao ser concluída durante a sprint
- Quando uma tarefa nao é concluída na sprint atual ela deve continuar na proxima sprint
- Para isso haverá uma cópia da tarefa para a continuidade e a situacao da tarefa será CONTINUA_PROXIMA_SPRINT

## Como uma tarefa de DEVEL é fechada com situacao FECHADA e tarefa de QS é fechada com situacao TESTE_OK_FECHADA

- Uma tarefa de DEVEL quando é RESOLVIDA é encaminhada para o QS
- A tarefa de DEVEL somente será FECHADA quando os testes terminarem com TESTE_OK
- Enquanto os testes nao terminarem com TESTE_OK a tarefa de DEVEL nao pode ser fechada
- As tarefas que estao com TESTE_OK sao as tarefas que estão aguardando a liberação da versão.
- Se os testes retornarem TESTE_OK a tarefa de devel pode ser entregue para cliente em versão estável, e neste momento a situacao é definida como FECHADA e a tarefa de QS será tambem fechada com TESTE_OK_FECHADA.
- Depois de liberada a versão do sistema o ciclo de desenvolvimento se encerra

## Retorno de testes do QS

- Quando uma tarefa do QS encontrar um problema ela será definida com a situacao TESTE_NOK
- As tarefa que estao na situacao TESTE_NOK estão aguardando para ser encaminhadas para o retorno de testes no desenvolvimento
- Quando o desenvolvimento encaminhar o retorno de testes, será feito uma copia da tarefa de QS para o DEVEL continuar o desenvolvimento e corrigir os problema encontrados
- Essa tarefa será trocada para o tipo (tracker) RETORNO_TESTES
- Neste momento a tarefa de QS será fechada com TESTE_NOK_FECHADA e a tarefa de desenvolvimento que estava como RESOLVIDA será trocada para FECHADA_CONTINUA_RETORNO_TESTES
- Apartir deste momento se reinicia todo o ciclo de desenvolvimento dando continuidade até que a tarefa de devel seja RESOLVIDA encaminhado para o QS e o teste resulte TESTE_OK.
- Uma tarefa de desenvolvimento pode ir mais de uma vez para o QS e mais de uma vez pode retornar TESTE_NOK. Ou seja, podem haver quantos ciclos forem necessarios até que a tarefa de QS retorno TESTE_OK.
- Os ciclos de desenvolvimento somente irão terminar quando o resultado do teste for TESTE_OK. Apartir deste momento a tarefa pode ser entregue a cliente e ser FECHADA.

## Retorno de testes gerados pelo DEVEL

- Eventualmente uma tarefa de DEVEL, após RESOLVIDA, pode ser testada entre os pares dentro da própria equipe de DEVEL antes de ser encaminhada para o QS
- Caso encontrar um defeito a própria equipe de DEVEL faz uma cópia da tarefa para dar continuidade no desenvolvimento para resolver o problema
- Neste caso também se usa o tipo da tarefa RETORNO_TESTES e a tarefa de devel que estava RESOLVIDA vai ser FECHADA_CONTINUA_RETORNO_TESTES
- Quando a tarefa de RETORNO_TESTES for RESOLVIDA ele está apta para ser encaminhada para o QS com uma tarefa normal de DEVEL
- Entao uma tarefa de DEVEL pode ser encaminhada para QS sem ter RETORNO_TESTES pelo DEVEL ou com RETORNO_TESTES encontrados pelo DEVEL.

## Exemplos de ciclos em ordem dos eventos

Os exemplos abaixos sao sempre dos ciclos completos. Durante o processamento dos ciclos ele pode estar acontecendo, entao o ciclo pode nao estar fechado

### Formatação usada nos exemplos

#### “DEVEL RETORNO_TESTES Tarefa ID 104 FECHADA”

- DEVEL: equipe responsável
- RETORNO_TESTES: indica que está no ciclo de retorno de testes
- Tarefa ID 104: tarefa número 104. O ID da tarefa é único
- FECHADA: situação da tarefa

#### “QS Tarefa ID 102 NOVA”

- QS: equipe responsável
- Tarefa ID 102: tarefa número 102. O id da tarefa é único
- NOVA: situação da tarefa

### Teste OK no primeiro ciclo do QS.

DEVEL Tarefa ID 100 NOVA -> DEVEL Tarefa ID 100 EM_ANDAMENTO -> DEVEL Tarefa ID 100 RESOLVIDA -> QS Tarefa ID 101 NOVA -> QS Tarefa ID 101 EM_ANDAMENTO -> QS Tarefa ID 101 TESTE_OK -> QS Tarefa ID 101 TESTE_OK_FECHADA -> DEVEL Tarefa ID 100 FECHADA

### Teste NOK no primeiro ciclo do QS e com RETORNO_TESTES gerado pela equipe QS

DEVEL Tarefa ID 100 NOVA -> DEVEL Tarefa ID 100 EM_ANDAMENTO -> DEVEL Tarefa ID 100 RESOLVIDA -> QS Tarefa ID 101 NOVA -> QS Tarefa ID 101 EM_ANDAMENTO -> QS Tarefa ID 101 TESTE_NOK -> QS Tarefa ID 101 TESTE_NOK_FECHADA -> DEVEL Tarefa ID 100 FECHADA_CONTINUA_RETORNO_TESTES -> DEVEL RETORNO_TESTES Tarefa ID 102 NOVA -> DEVEL RETORNO_TESTES Tarefa ID 102 EM_ANDAMENTO -> DEVEL RETORNO_TESTES Tarefa ID 102 RESOLVIDA -> QS RETORNO_TESTES Tarefa 103 NOVA -> QS RETORNO_TESTES Tarefa 103 EM_ANDAMENTO -> QS RETORNO_TESTES Tarefa 103 TESTE_OK -> QS RETORNO_TESTES Tarefa ID 103 TESTE_OK_FECHADA -> DEVEL RETORNO_TESTES Tarefa ID 102 FECHADA

### Teste NOK com dois ciclos de RETORNO_TESTES gerado pela equipe de QS

DEVEL Tarefa ID 100 NOVA -> DEVEL Tarefa ID 100 EM_ANDAMENTO -> DEVEL Tarefa ID 100 RESOLVIDA -> QS Tarefa ID 101 NOVA -> QS Tarefa ID 101 EM_ANDAMENTO -> QS Tarefa ID 101 TESTE_NOK -> QS Tarefa ID 101 TESTE_NOK_FECHADA -> DEVEL Tarefa ID 100 FECHADA_CONTINUA_RETORNO_TESTES -> DEVEL RETORNO_TESTES Tarefa ID 102 NOVA -> DEVEL RETORNO_TESTES Tarefa ID 102 EM_ANDAMENTO -> DEVEL RETORNO_TESTES Tarefa ID 102 RESOLVIDA -> QS RETORNO_TESTES Tarefa 103 NOVA -> QS RETORNO_TESTES Tarefa 103 EM_ANDAMENTO -> QS RETORNO_TESTES Tarefa 103 TESTE_NOK -> QS Tarefa ID 103 TESTE_NOK_FECHADA -> DEVEL Tarefa ID 103 FECHADA_CONTINUA_RETORNO_TESTES -> DEVEL RETORNO_TESTES Tarefa ID 104 NOVA -> DEVEL RETORNO_TESTES Tarefa ID 104 EM_ANDAMENTO -> DEVEL RETORNO_TESTES Tarefa ID 104 RESOLVIDA -> QS RETORNO_TESTES Tarefa 105 NOVA -> QS RETORNO_TESTES Tarefa 105 EM_ANDAMENTO -> QS RETORNO_TESTES Tarefa 105 TESTE_NOK -> QS RETORNO_TESTES Tarefa ID 105 TESTE_OK_FECHADA -> DEVEL RETORNO_TESTES Tarefa ID 104 FECHADA

### Tarefa DEVEL no primeiro ciclo com CONTINUA_PROXIMA_SPRINT e Teste OK no primeiro ciclo do QS

DEVEL Tarefa ID 100 NOVA -> DEVEL Tarefa ID 100 EM_ANDAMENTO -> DEVEL Tarefa ID 100 CONTINUA_PROXIMA_SPRINT -> DEVEL Tarefa ID 101 NOVA -> DEVEL Tarefa ID 101 EM_ANDAMENTO -> DEVEL Tarefa ID 101 RESOLVIDA -> QS Tarefa ID 102 NOVA -> QS Tarefa ID 102 EM_ANDAMENTO -> QS Tarefa ID 102 TESTE_OK -> QS Tarefa ID 102 TESTE_OK_FECHADA -> DEVEL Tarefa ID 101 FECHADA

Observacoes: nas tarefas de DEVEL a situacao CONTINUA_PROXIMA_SPRINT pode ocorrer em qualquer momento antes da tarefa ser RESOLVIDA. Na tarefas de QS a situacao CONTINUA_PROXIMA_SPRINT pode ocorrer em qualquer momento antes da tarefa ser TESTE_OK ou TESTE_NOK. Pode haver quantas vezes forem necessária o CONTINUA_PROXIMA_SPRINT sempre que a tarefa nao for concluída dentro da sprint atual haverá uma copia de continuidade na proxima sprint. A tarefa atual é fechada com situacao CONTINUA_PROXIMA_SPRINT e a proxima tarefa é a continuidade do desenvolvimento ou dos testes.

### RETORNO_TESTES na equipe de DEVEL e TESTE_OK no primeiro ciclo do QS

DEVEL Tarefa ID 100 NOVA -> DEVEL Tarefa ID 100 EM_ANDAMENTO -> DEVEL Tarefa ID 100 RESOLVIDA -> DEVEL Tarefa ID 100 FECHADA_CONTINUA_RETORNO_TESTES ->DEVEL Tarefa ID 101 NOVA -> DEVEL Tarefa ID 101 EM_ANDAMENTO -> DEVEL Tarefa ID 101 RESOLVIDA -> QS Tarefa ID 102 NOVA -> QS Tarefa ID 102 EM_ANDAMENTO -> QS Tarefa ID 102 TESTE_OK -> QS Tarefa ID 102 TESTE_OK_FECHADA -> DEVEL Tarefa ID 101 FECHADA

### RETORNO_TESTES na equipe de DEVEL e TESTE_NOK no primeiro ciclo do QS e com RETORNO_TESTES gerado pela equipe QS

DEVEL Tarefa ID 100 NOVA -> DEVEL Tarefa ID 100 EM_ANDAMENTO -> DEVEL Tarefa ID 100 RESOLVIDA -> DEVEL Tarefa ID 100 FECHADA_CONTINUA_RETORNO_TESTES ->DEVEL Tarefa ID 101 NOVA -> DEVEL Tarefa ID 101 EM_ANDAMENTO -> DEVEL Tarefa ID 101 RESOLVIDA -> QS Tarefa ID 102 NOVA -> QS Tarefa ID 102 EM_ANDAMENTO -> QS Tarefa ID 102 TESTE_NOK -> QS Tarefa ID 102 TESTE_NOK_FECHADA -> DEVEL Tarefa ID 101 FECHADA_CONTINUA_RETORNO_TESTES -> DEVEL RETORNO_TESTES Tarefa ID 103 NOVA -> DEVEL RETORNO_TESTES Tarefa ID 103 EM_ANDAMENTO -> DEVEL RETORNO_TESTES Tarefa ID 103 RESOLVIDA -> QS RETORNO_TESTES Tarefa 104 NOVA -> QS RETORNO_TESTES Tarefa 104 EM_ANDAMENTO -> QS RETORNO_TESTES Tarefa 104 TESTE_OK -> QS RETORNO_TESTES Tarefa ID 104 TESTE_OK_FECHADA -> DEVEL RETORNO_TESTES Tarefa ID 103 FECHADA

## Situações especiais que a tarefa não será encaminhada para QS

### Tarefa de DEVEL que não vai ser encaminhada para QS

- Uma tarefa de DEVEL quando for definido no campo “TesteQS” o conteudo “Não necessita teste” essa tarefa nao se espera que vai ser encaminhado para o QS. Ou seja, o a sequencia de situações dela vai ser NOVA -> EM_ANDAMENTO -> RESOLVIDA -> FECHADA. Neste caso vai usar o FLUXO_SEM_QS especial de tarefas que nao sao encaminhadas para o QS,

# Detalhes técnicos do código fonte do projeto

- Para determinar se a tarefa é do DEVEL o QS deve-se avaliar o nome do projeto e ver se pertence a constante SkyRedminePlugin::Constants::Projects::QS_PROJECTS
- A funcao SkyRedminePlugin::TarefasRelacionadas.obter_lista_tarefas_relacionadas retorna a lista de tarefas que estao relacionadas por copia na ordem cronologia delas
- As funções SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_devel e SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_qs separam os ciclos de desenvolvimento do DEVEL e QS
- A constante SkyRedminePlugin::Constants::IssueStatus define as situações possíveis das tarefas.
- A constante SkyRedminePlugin::Constants::Trackers define os tipos de tarefas
- A constante SkyRedminePlugin::Constants::SituacaoAtual::FLUXO_SEM_QS define o fluxo das tarefas DEVEL que não são encaminhadas para QS
  - ESTOQUE_DEVEL: Tarefa que está no estoque, uma tarefa DEVEL com a situação NOVA
  - EM_ANDAMENTO_DEVEL: Tarefa que está em desenvolvimento, uma tarefa DEVEL com a situação EM_ANDAMENTO
  - AGUARDANDO_VERSAO: Está com testes concluídos com situação TESTE_OK e aguardando liberação da versão
  - VERSAO_LIBERADA: A versão foi liberada, a tarefa de DEVEL está com situação FECHADA
- A constante SkyRedminePlugin::Constants::SituacaoAtual::FLUXO_IDEAL define o fluxo ideal das tarefas de DEVEL que devem ir para QS, ou seja, nao possuem retorno de testes
  - ESTOQUE_DEVEL: Tarefa que está no estoque, uma tarefa DEVEL com a situação NOVA
  - EM_ANDAMENTO_DEVEL: Tarefa que está em desenvolvimento, uma tarefa DEVEL com a situação EM_ANDAMENTO
  - AGUARDANDO_ENCAMINHAR_QS: Tarefa DEVEL que está com a situação RESOLVIDA e aguardando na fila para encaminhar para o QS
  - ESTOQUE_QS: Foi encaminhada para QS e está no estoque do QS, uma tarefa QS com a situação NOVA
  - EM_ANDAMENTO_QS: Está em testes, uma tarefa do QS com a situação EM_ANDAMENTO
  - AGUARDANDO_VERSAO: Está com testes concluídos com situação TESTE_OK e aguardando liberação da versão
  - VERSAO_LIBERADA: A versão foi liberada, a tarefa de DEVEL está com situação FECHADA
- A constante SkyRedminePlugin::Constants::SituacaoAtual::FLUXO_RETORNO_TESTES define o fluxo quando há retorno de testes das tarefas de DEVEL que devem ir para QS.
  - ESTOQUE_DEVEL: Tarefa que está no estoque, uma tarefa DEVEL com a situação NOVA
  - EM_ANDAMENTO_DEVEL: Tarefa que está em desenvolvimento, uma tarefa DEVEL com a situação EM_ANDAMENTO
  - AGUARDANDO_ENCAMINHAR_QS: Tarefa DEVEL que está com a situação RESOLVIDA e aguardando na fila para encaminhar para o QS
  - ESTOQUE_QS: Foi encaminhada para QS e está no estoque do QS, uma tarefa QS com a situação NOVA
  - EM_ANDAMENTO_QS: Está em testes, uma tarefa do QS com a situação EM_ANDAMENTO
  - AGUARDANDO_ENCAMINHAR_RETORNO_TESTES: Está com os testes concluídos com situação TESTE_NOK e aguardando encaminhar a tarefa do tipo RETORNO_TESTES
  - ESTOQUE_DEVEL_RETORNO_TESTES: Tarefa que retornou do QS com tipo RETORNO_TESTES que está no estoque, uma tarefa DEVEL com a situação NOVA
  - EM_ANDAMENTO_DEVEL_RETORNO_TESTES: Tarefa que retornou do QS com tipo RETORNO_TESTES que está em desenvolvimento, uma tarefa DEVEL com situação EM_ANDAMENTO
  - AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES: Tarefa que retornou do QS com tipo RETORNO_TESTES que está com a situação RESOLVIDA e aguardando na fila para encaminhar para o QS
  - ESTOQUE_QS_RETORNO_TESTES: Tarefa que retornou do QS com tipo RETORNO_TESTES que foi encaminhada para QS e está no estoque do QS, uma tarefa QS com a situação NOVA
  - EM_ANDAMENTO_QS_RETORNO_TESTES: Tarefa que retornou do QS com tipo RETORNO_TESTES que está em testes, uma tarefa do QS com a situação EM_ANDAMENTO
  - AGUARDANDO_VERSAO_RETORNO_TESTES: Tarefa que retornou do QS com tipo RETORNO_TESTES que está com testes concluídos com situação TESTE_OK e aguardando liberação da versão
  - VERSAO_LIBERADA: A versão foi liberada, a tarefa de DEVEL está com situação FECHADA
- A funcao SkyRedminePlugin::Indicadores.processar_indicadores processa e define os indicadores das tarefas que sao definidas na entidade SkyRedmineIndicadores pela tabela sky_redmine_indicadores.
- A funcao SkyRedminePlugin::Indicadores.determinar_situacao_atual define a situacao atual avaliando o fluxo e em qual situação a tarefa se encontra no momento.
- A classe SkyRedmineIndicadorer cria a entidade para definir os Indicadores da tarefa. O conteudo dos indicadores é definido pela funcao SkyRedminePlugin::Indicadores::processar_indicadores. Alguns indicadores importantes
  - “equipe_responsavel_atual”: DEVEL: se o ciclo está com a responsabilidade da equipe de DEVEL, QS se o ciclo atual está com a responsabilidade da equipe de QS e FECHADA quando todos os ciclos estão concluídos
  - “qtd_retorno_testes_qs”: quantidade de vezes que houve retorno de testes que foram originados pelos testes do QS
  - “qtd_retorno_testes_devel”: quantidade de vezes que ouve retorno de testes que foram originados pelos testes do DEVEL
  - “tarefa_fechada_sem_testes”: vai ser definido SIM se a tarefa de DEVEL foi fechada antes dos testes estarem concluídos com TESTE_OK, caso contrário vai ser NAO. Em outras palavras o normal esperado é que a tarefa somente seja fechada apos os testes. Entao estar SIM neste indicador não é o desejado. Assim sendo, a data de resolvida da tarefa de QS com situacao TESTE_OK tem que ser maior que a data de fechada da ultima tarefa de DEVEL. Portanto, se a tarefa de DEVEL foi fechada antes da tarefa de QS ser concluída o teste com TESTE_OK entao esse campo vai estar definido como SIM caso contrario vai ser NAO.

# Situações que devem ser tratadas como exceção e definir situacao DESCONHECIDO

- A ultima tarefa do ultimo ciclo do DEVEL nao pode ser FECHADA_CONTINUA_RETORNO_TESTES. Se uma tarefa está com essa situacao espera-se que exista uma copia de continuidade do desenvolvimento no RETORNO_TESTES
- A ultima tarefa de todo ciclo se for do QS ela nao pode ser TESTE_NOK_FECHADA. Se a tarefa do QS for TESTE_NOK_FECHADA então espera-se que exista uma tarefa de continuidade do desenvolvimento no RETORNO_TESTES.
- Ciclos de continuidade da tarefa de RETORNO_TESTES. Sempre que houver mais de um ciclo de tarefas DEVEL apartir do segundo CICLO a tarefa deve ser sempre do tipo RETORNO_TESTES.
