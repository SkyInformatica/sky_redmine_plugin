# Sky Plugin Redmine

Este plugin é exclusivo para a organização da gestão de tarefas de desenvolvimento e QS gerenciadas pelo Redmine, conforme definido pela Sky Informática.

# Como instalar o plugin

- Fazer download da ultima versão disponivel em [https://github.com/maglancd/sky-redmine-plugin/releases](https://github.com/maglancd/sky-redmine-plugin/releases)
- Descompactar o plugin na pasta `<redmine>/plugins.` Normalmente o redmine está instalado em `/opt/redmine`. Normalmente colocamos o plugin na pasta `/opt/redmine/sky_redmine_plugin`. Confirme o local de instalação do Redmine.
- Executar o comando de instalação/atualização dos [plugins instalados conforme documentacao do Redmine](https://www.redmine.org/projects/redmine/wiki/plugins)

```shell
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

# Funcionalidades, recursos e documentação

- [Criar retorno de testes](docs/retorno_testes/criar_retorno_testes.md)
- [Encaminhar para o QS](docs/encaminhar_qs/encaminhar_qs.md)
- [Continua na próxima sprint](docs/continua_proxima_sprint/continua_proxima_sprint.md)
- [Ações automatizadas na gestão do fluxo das tarefas](docs/acoes_automatizadas_fluxo_tarefas.md)
- [Ciclo do desenvolvimento das tarefas](docs/ciclo_desenvolvimento.md)

# O que há de novo?

## 2025.04.06.1

- Cards com indicadores no fluxo das tarefas (individual por tarefa) com a contabilização do tempo entre de cada situação.
- Timeline das etapas de desenvolvimento no fluxo das tarefas
- Nova página de Indicadores em cada um dos projetos para um resumo geral da situacao atual envolvendo todas as tarefas do projeto.
- Novas tags Exx\_ para marcar as tarefas de DEVEL com sua situacao atual da sua etapa de desenvolvimento.

Fluxo sem retorno de testes: define o fluxo ideal das tarefas de DEVEL que devem ir para QS, ou seja, não possuem retorno de testes
| Tag | Descrição |
| ---------------------------- | --------------------------------------------------------------------------------------------- |
| E01_ESTOQUE_DEVEL | Tarefa que está no estoque, uma tarefa DEVEL com a situação NOVA |
| E02_EM_ANDAMENTO_DEVEL | Tarefa que está em desenvolvimento, uma tarefa DEVEL com a situação EM_ANDAMENTO |
| E03_AGUARDANDO_ENCAMINHAR_QS | Tarefa DEVEL que está com a situação RESOLVIDA e aguardando na fila para encaminhar para o QS |
| E04_ESTOQUE_QS | Foi encaminhada para QS e está no estoque do QS, uma tarefa QS com a situação NOVA |
| E05_EM_ANDAMENTO_QS | Está em testes, uma tarefa do QS com a situação EM_ANDAMENTO |
| E06_AGUARDANDO_VERSAO | Está com testes concluídos com situação TESTE_OK e aguardando liberação da versão |

Fluxo com retorno de testes: define o fluxo quando há retorno de testes das tarefas de DEVEL que devem ir para QS.
| Tag | Descrição |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| E01_ESTOQUE_DEVEL | Tarefa que está no estoque, uma tarefa DEVEL com a situação NOVA |
| E02_EM_ANDAMENTO_DEVEL | Tarefa que está em desenvolvimento, uma tarefa DEVEL com a situação EM_ANDAMENTO |
| E03_AGUARDANDO_ENCAMINHAR_QS | Tarefa DEVEL que está com a situação RESOLVIDA e aguardando na fila para encaminhar para o QS |
| E04_ESTOQUE_QS | Foi encaminhada para QS e está no estoque do QS, uma tarefa QS com a situação NOVA |
| E05_EM_ANDAMENTO_QS | Está em testes, uma tarefa do QS com a situação EM_ANDAMENTO |
beração da versão |
| E07_AGUARDANDO_ENCAMINHAR_RT | Está com os testes concluídos com situação TESTE_NOK e aguardando encaminhar a tarefa do tipo RETORNO_TESTES |
| E01_ESTOQUE_DEVEL_RT | Tarefa que retornou do QS com tipo RETORNO_TESTES que está no estoque, uma tarefa DEVEL com a situação NOVA |
| E02_EM_ANDAMENTO_DEVEL_RT | Tarefa que retornou do QS com tipo RETORNO_TESTES que está em desenvolvimento, uma tarefa DEVEL com situação EM_ANDAMENTO |
| E03_AGUARDANDO_ENCAMINHAR_QS_RT | Tarefa que retornou do QS com tipo RETORNO_TESTES que está com a situação RESOLVIDA e aguardando na fila para encaminhar para o QS |
| E04_ESTOQUE_QS_RT | Tarefa que retornou do QS com tipo RETORNO_TESTES que foi encaminhada para QS e está no estoque do QS, uma tarefa QS com a situação NOVA |
| E05_EM_ANDAMENTO_QS_RT | Tarefa que retornou do QS com tipo RETORNO_TESTES que está em testes, uma tarefa do QS com a situação EM_ANDAMENTO |
| E06_AGUARDANDO_VERSAO_RT | Tarefa que retornou do QS com tipo RETORNO_TESTES que está com testes concluídos com situação TESTE_OK e aguardando li

## 2025.01.06.1

- Corrigido o problema que não estava executando as acoes automatizadas ao editar tarefas em lote

## 2024.12.09.1

- Criado nova coluna no fluxo das tarefas para exibir a lista da revisões do SVN associadas a tarefa

## 2024.12.06.1

- Criado novas colunas no fluxo das tarefas para data criacao, data em andamento, data resolvida e data fechada.

## 2024.12.05.1

- Ajuste para a aba "Fluxo das tarefas" sempre ser a primeira aba
- Ajuste da aba "Tarefas relacionadas" para funcionar o link de adicionar relacionamento novo.

## 2024.11.29.1

- Implementado novas abas para exibir o Fluxo das tarefas, Subtarefas e Tarefas relacionadas
- Criado hyperlink para ocultar as Instruções para testes, Resultado teste ok e Resultado teste NOK
- Criado hyperlink 'Ir para as abas' no topo da tarefa para navegar até a seção das abas no rodapé da tarefa

## 2024.11.28.1

- Manter a categoria original da tarefa de desenvolvimento quando se cria uma nova tarefa de retorno de testes do QS.

## 2024.11.26.1

- Funcionalidade para registrar histórico das alterações nas tarefas pelas automações das cópias das tarefas para retorno de testes, encaminhar para o QS e continua na proxima sprint
- Controle para impedir de criar mais de uma vez o retorno de testes em tarefas do QS.
