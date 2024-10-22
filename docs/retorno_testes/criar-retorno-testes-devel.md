## **Criar tarefa de retorno de testes para tarefas do desenvolvimento**

Quando a tarefa de desenvolvimento estiver com o status "Resolvido", é possível criar uma tarefa de retorno de testes clicando no link "Criar retorno de testes" na visualização da tarefa.

![redmine-criar-retorno-testes-devel](redmine-criar-retorno-testes-devel.png)

Ao clicar no link, o Redmine criará uma nova tarefa a partir de uma cópia, realizando os ajustes e executando as seguintes ações.

- Criar um nova tarefa copiando a tarefa de desenvolvimento com o tipo "Retorno de testes"
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
- Atualizar o status da tarefa de desenvolvimento para "Fechada \- cont retorno testes"

Abaixo pode-se ver o fluxograma da execução das ações executadas

![fluxograma-criar-retorno-testes-devel](fluxograma-criar-retorno-testes-devel.png)
