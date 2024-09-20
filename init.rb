require_relative "lib/CriarRetornoTestesHook"

Redmine::Plugin.register :sky_redmine_plugin do
  name "Sky Redmine plugin"
  author "Maglan Diemer"
  description "Disponibiliza facilitadores para gerar as tarefas de retorno de teste do QS"
  version "2024.09.17.1"
end
