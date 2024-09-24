# Sky Plugin Redmine

Este documento descreve as funcionalidades do plugin [https://github.com/maglancd/sky-redmine-plugin](https://github.com/maglancd/sky-redmine-plugin)

# Como instalar o plugin

Fazer download da ultima versão disponivel em [https://github.com/maglancd/sky-redmine-plugin/archive/refs/tags/2024.09.24.0.tar.gz](https://github.com/maglancd/sky-redmine-plugin/archive/refs/tags/2024.09.24.0.tar.gz) (ou superior)  
Descompactar o plugin na pasta \<redmine\>/plugins. Normalmente o redmine está instalado em /opt/redmine  
Normalmente colocamos o plugin na pasta /opt/redmine/sky-redmine-plugin

Executar o comando de instalação/atualização dos [plugins instalados conforme documentacao do Redmine](https://www.redmine.org/projects/redmine/wiki/plugins)

```
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

# Funcionalidades

## **Criar tarefa de retorno de testes para tarefas do desenvolvimento**

Quando a tarefa for dos projetos do desenvolvimento e estiver com seu status "Resolvido" é possível criar uma tarefa de retorno de testes clicando no link "Criar tarefa de retorno de testes para essa tarefa de desenvolvimento" conforme exemplo abaixo

![redmine-criar-retorno-testes-devel](docs/redmine-criar-retorno-testes-devel.png)

Ao clicar no link o Redmine irá criar uma nova tarefa apartir de uma cópia fazendo os ajustes necessários conforme a documentação [Fluxograma do processo de testes](https://docs.google.com/document/d/1H_ADkIaIxo5wy2QCW3bFRrw7l23HpUkaPUXaeZMbJCY/edit), realizando as seguintes ações

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

![fluxograma-criar-retorno-testes-devel](docs/fluxograma-criar-retorno-testes-devel.png)

##

## **Criar tarefa de retorno de testes para tarefas do QS**

Quando a tarefa for dos projetos do QS e estiver com seu status "Teste NOK" é possível criar uma tarefa de retorno de testes clicando no link "Criar tarefa de retorno de testes para essa tarefa de testes" conforme exemplo abaixo

![redmine-criar-retorno-testes-qs](docs/redmine-criar-retorno-testes-qs.png)

Ao clicar no link o Redmine irá criar uma nova tarefa apartir de uma cópia fazendo os ajustes necessários conforme a documentação [Fluxograma do processo de testes](https://docs.google.com/document/d/1H_ADkIaIxo5wy2QCW3bFRrw7l23HpUkaPUXaeZMbJCY/edit), realizando as seguintes ações

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

![fluxograma-criar-retorno-testes-qs](docs/fluxograma-criar-retorno-testes-qs.png)
