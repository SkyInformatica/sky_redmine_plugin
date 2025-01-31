
# Carrega o ambiente do Redmine
ENV['RAILS_ENV'] ||= 'production' # Opcional, defina o ambiente conforme a instalação Redmine
require File.expand_path('../../../config/environment', __FILE__) # Ajuste o caminho conforme a instalação Redmine  

include TarefasRelacionadasHelper

# Define um método para executar o teste
def foo(issue_id)
  # Busca a tarefa pelo ID
  issue = Issue.find_by(id: issue_id)

  puts "id: #{issue.id}"

  # Localizar uma cópia da tarefa nos projetos QS                    
  copied_to_qs_issue = localizar_tarefa_copiada_qs(issue)

  # Se existir uma cópia e seu status for "Teste OK"
  if copied_to_qs_issue
    puts "tarefa qs encontrada com id #{copied_to_qs_issue.id} e status #{copied_to_qs_issue.status.name}"      
  end
end

# Chame o método de teste junto ao ID da tarefa
foo(74933)
