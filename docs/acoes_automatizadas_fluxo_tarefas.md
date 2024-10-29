# Ações automatizadas no gestão do fluxo das tarefas

O plugin irá controlar o fluxo das tarefas e realizar ações automatizadas conforme a troca de situação das tarefas conforme segue

## Atualizar tags das tarefas de testes para \_PRONTO e \_REVER

- Sempre que uma tarefa do projeto de QS estiver com Teste OK ou Teste NOK a tag será definir para \_PRONTO e \_REVER, respectivamente

## Definir data de inicio da tarefa

- Definir a data de inicio sempre que uma tarefa for colocada "Em andamento" e data de inicio ainda não estiver definida

## Fechar a tarefa de Teste OK e remover as tags

- Fechar a tarefa do QS para "Teste OK - Fechada" e remover suas tags sempre que uma tarefa de desenvolvimento for "Fechada" e a tarefa do QS correspondente estiver com "Teste OK"
