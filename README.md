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
