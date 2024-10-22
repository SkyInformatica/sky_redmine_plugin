## **Criar tarefa de retorno de testes para tarefas do QS**

Quando a tarefa do projeto QS estiver com status "Teste NOK", é possível criar uma tarefa de retorno de testes clicando no link "Criar retorno de testes", conforme o exemplo abaixo.

![redmine-criar-retorno-testes-qs](redmine-criar-retorno-testes-qs.png)

Ao clicar no link, o Redmine criará uma nova tarefa a partir de uma cópia, ajustando-a e realizando as seguintes ações.

- Criar uma nova tarefa copiando a tarefa de QS com o tipo "Retorno de testes" para o projeto de desenvolvimento que originou a tarefa do QS
  - Limpar os campos da nova tarefa que foi criada
    - Atribuído para
    - Data de inicio
    - Tags
    - Tarefa não planejada IMEDIATA
    - Tarefa antecipada na sprint
    - Responsável pelo teste
    - Teste no desenvolvimento
    - Teste QS
    - Versão estável
  - Definir a sprint para "Aptas para desenvolvimento" (caso existir)
  - Definir tempo estimado para 1 hora
- Atualizar o status da tarefa de desenvolvimento (que originou a tarefa do QS) para "Fechada \- cont retorno testes"
- Atualizar o status da tarefa de QS para "Teste NOK \- Fechada"
- Limpar as tags da tarefa de testes

Abaixo pode-se ver o fluxograma da execução das ações executadas

![fluxograma-criar-retorno-testes-qs](fluxograma-criar-retorno-testes-qs.png)
