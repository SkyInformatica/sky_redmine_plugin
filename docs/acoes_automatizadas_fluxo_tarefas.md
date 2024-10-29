# Ações automatizadas no gestão do fluxo das tarefas

O plugin controlará o fluxo das tarefas e realizará ações automatizadas conforme a mudança de situação delas.

## Atualizar tags das tarefas de testes para \_PRONTO e \_REVER

- Quando uma tarefa do projeto de QS for marcada como "Teste OK" ou "Teste NOK", sua tag será ajustada para \_PRONTO e \_REVER, respectivamente.

## Definir data de inicio da tarefa

- Definir a data de início sempre que uma tarefa for marcada como "Em andamento" e ainda não tiver uma data definida.

## Fechar a tarefa de Teste OK e remover as tags

- Fechar a tarefa do QS como "Teste OK - Fechada" e remover suas tags sempre que uma tarefa de desenvolvimento for "Fechada" e a correspondente do QS estiver com "Teste OK".
