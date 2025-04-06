# Sky Plugin Redmine

Este plugin é exclusivo para a organização da gestão de tarefas de desenvolvimento e QS gerenciadas pelo Redmine, conforme definido pela Sky Informática.

# Como instalar o plugin

- Fazer download da ultima versão disponivel em [https://github.com/maglancd/sky-redmine-plugin/releases](https://github.com/maglancd/sky-redmine-plugin/releases)
- Descompactar o plugin na pasta `<redmine>/plugins.` Normalmente o redmine está instalado em `/opt/redmine`. Normalmente colocamos o plugin na pasta `/opt/redmine/sky_redmine_plugin`. Confirme o local de instalação do Redmine.
- Executar o comando de instalação/atualização dos [plugins instalados conforme documentacao do Redmine](https://www.redmine.org/projects/redmine/wiki/plugins)

```shell
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

# Funcionalidades

- [Criar retorno de testes](docs/retorno_testes/criar_retorno_testes.md)
- [Encaminhar para o QS](docs/encaminhar_qs/encaminhar_qs.md)
- [Continua na próxima sprint](docs/continua_proxima_sprint/continua_proxima_sprint.md)
- [Ações automatizadas na gestão do fluxo das tarefas](docs/acoes_automatizadas_fluxo_tarefas.md)

# O que há de novo?

## 2025.04.06.1

- Nova tabela de indicadores no fluxo das tarefas (individual por tarefa)
- Timeline das etapas de desenvolvimento no fluxo das tarefas
- Nova página de Indicadores em cada um dos projetos para um resumo geral da situacao atual envolvendo todas as tarefas do projeto.
- Novas tags SkyRP\_ para marcar as tarefas de DEVEL com sua situacao atual da sua etapa de desenvolvimento.

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
