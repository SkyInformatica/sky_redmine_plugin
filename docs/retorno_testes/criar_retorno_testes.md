# **Criar tarefa de retorno de testes**

É possivel criar tarefa de retorno de testes tanto para tarefas do **desenvolvimento** quanto para tarefas do **QS**, conforme seguintes condicoes

- **Tarefas do desenvolvimento**: Quando estiver com o status "Resolvido"
- **Tarefas do QS**: Quando estiver com status "Teste NOK"

A criação da tarefa de retorno de testes é feito pelo **link na visualização da tarefa** ou em lote através do **menu de contexto** com o clique do botão direito sobre a lista de tarefas, conforme imagem abaixo

## **Link na visualização da tarefa**

![criar_retorno_testes](criar_retorno_testes.png)

## **Menu de contexto na lista de tarefas**

![criar-retorno-testes-lote](criar-retorno-testes-lote.png)

## **Fluxograma da criação do retorno de testes para tarefas do desenvolvimento**

- Criar um nova tarefa copiando a tarefa de desenvolvimento com o tipo "Retorno de testes"
  - Limpar os campos da nova tarefa que foi criada
    - Atribuído para
    - Data de inicio
    - Percentual concluido
    - Tags
    - Tarefa não planejada IMEDIATA
    - Tarefa antecipada na sprint
    - Teste no desenvolvimento
    - Teste QS
    - Versão estável
    - Versao teste
  - Definir a sprint para "Aptas para desenvolvimento" (caso existir)
  - Definir tempo estimado para 1 hora
  - Definir a descricao da tarefa concatenando o titulo "retorno de testes do desenvolvimento" no inicio da descrição para que seja completado pelo desenvolvedor.
- Atualizar o status da tarefa de desenvolvimento para "Fechada \- cont retorno testes"
- Atualizar o campo "Teste no desenvolvimento" como "Teste NOK"

Abaixo pode-se ver o fluxograma da execução das ações executadas

![fluxograma-criar-retorno-testes-devel](fluxograma-criar-retorno-testes-devel.png)

## **Fluxogram da criação do retorno de testes para tarefas do QS**

- Criar uma nova tarefa copiando a tarefa de QS com o tipo "Retorno de testes" para o projeto de desenvolvimento que originou a tarefa do QS
  - Limpar os campos da nova tarefa que foi criada
    - Atribuído para
    - Data de inicio
    - Percentual concluido
    - Tags
    - Tarefa não planejada IMEDIATA
    - Tarefa antecipada na sprint
    - Teste no desenvolvimento
    - Teste QS
    - Versão estável
    - Versão teste
  - Definir a sprint para "Aptas para desenvolvimento" (caso existir)
  - Definir tempo estimado para 1 hora
  - Definir a descricao da tarefa concatenando o "retorno de testes do QS" no inicio da descrição
- Atualizar o status da tarefa de desenvolvimento (que originou a tarefa do QS) para "Fechada \- cont retorno testes"
- Atualizar o status da tarefa de QS para "Teste NOK \- Fechada"
- Limpar as tags da tarefa de testes

Abaixo pode-se ver o fluxograma da execução das ações executadas

![fluxograma-criar-retorno-testes-qs](fluxograma-criar-retorno-testes-qs.png)
