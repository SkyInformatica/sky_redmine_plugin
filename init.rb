require_relative "lib/criar_retorno_testes_hook"

Redmine::Plugin.register :sky_redmine_plugin do
  name "Sky Redmine plugin"
  author "Maglan Diemer"
  description "Disponibiliza facilitadores para gerir as tarefas do QS. Veja a [documentação do plugin no GitHub](https://github.com/maglancd/sky-redmine-plugin)."
  version "2024.09.24.1"
end
