
# Carrega o ambiente do Redmine
require File.expand_path('../../config/environment', __FILE__) # Ajuste o caminho conforme a instalação Redmine  


# Define um método para executar o teste
def foo(issue_id)
  # Busca a tarefa pelo ID
  issue = Issue.find_by(id: issue_id)

  puts "id: #{issue.id}"
end

# Chame o método de teste junto ao ID da tarefa
foo(74933)
