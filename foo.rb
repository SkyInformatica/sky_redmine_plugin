
# Carrega o ambiente do Redmine
require File.expand_path('../../config/environment', __FILE__) # Ajuste o caminho conforme a instalação Redmine  

require_relative "app/helpers/fluxo_tarefas_helper"
require_relative "lib/sky_redmine_plugin/issue_helper_patch"
require_relative "app/models/sky_redmine_indicadores"

include SkyRedminePlugin::Hooks::ControllerHooks

# Define um método para executar o teste
def foo(issue_id)
  # Busca a tarefa pelo ID
  issue = Issue.find_by(id: issue_id)

  puts issue.id
end

# Chame o método de teste junto ao ID da tarefa
foo(74933)
