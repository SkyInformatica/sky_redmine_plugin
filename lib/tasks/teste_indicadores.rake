#RAILS_ENV=production rake sky_redmine_plugin:teste_indicadores
namespace :sky_redmine_plugin do
  desc "Executa os testes de indicadores no ambiente especificado"
  task :teste_indicadores => :environment do
    puts "Iniciando testes de indicadores..."
    
    # Configuração básica
    @project = Project.find_by(name: "Equipe Notar")
    @tracker = Tracker.first
    @status_nova = IssueStatus.find_by(name: "Nova")
    @status_em_andamento = IssueStatus.find_by(name: "Em andamento")
    @status_resolvida = IssueStatus.find_by(name: "Resolvida")
    @author = User.find_by(login: "maglan")
    
    if @author.nil?
      puts "✗ Usuário 'maglan' não encontrado. Verifique se o usuário existe no sistema."
      return
    end
    
    puts "✓ Usuário 'maglan' encontrado (ID: #{@author.id})"
    
    # Executar os cenários
    criar_tarefa_nova
    criar_tarefa_nova_em_andamento
    criar_tarefa_nova_em_andamento_resolvida
    
    puts "\nTestes concluídos!"
  end
  
  # Função auxiliar para criar uma tarefa
  def criar_tarefa(subject)
    issue = Issue.new(
      project: @project,
      tracker: @tracker,
      status: @status_nova,
      subject: subject,
      author: @author,
      assigned_to: @author
    )
    
    if issue.save
      puts "✓ Tarefa nova criada com sucesso (ID: #{issue.id})"
      
      # Processar indicadores para a tarefa nova
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      puts "✓ Indicadores processados para a tarefa nova"
      
      return issue
    else
      puts "✗ Falha ao criar a tarefa nova: #{issue.errors.full_messages.join(', ')}"
      return nil
    end
  end
  
  # Função auxiliar para trocar o status de uma tarefa
  def trocar_status(issue, novo_status, mensagem)
    # Recarregar a tarefa para evitar StaleObjectError
    issue = Issue.find(issue.id)
    
    # Inicializar o journal antes de alterar o status
    issue.init_journal(@author, "[SkyRedminePlugin] #{mensagem}")
    
    # Atualizar o status
    issue.status = novo_status
    if issue.save
      puts "✓ Tarefa atualizada para #{mensagem.downcase} com sucesso"
      
      # Processar indicadores
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      puts "✓ Indicadores processados para a tarefa #{mensagem.downcase}"
      
      return true
    else
      puts "✗ Falha ao atualizar a tarefa para #{mensagem.downcase}: #{issue.errors.full_messages.join(', ')}"
      return false
    end
  end
  
  # Cenário 1: Criar uma tarefa nova
  def criar_tarefa_nova
    puts "\n=== Cenário 1: Criar uma tarefa nova ==="
    criar_tarefa("Teste Cenário 1 - Tarefa Nova")
  end
  
  # Cenário 2: Criar uma tarefa nova e depois colocá-la em andamento
  def criar_tarefa_nova_em_andamento
    puts "\n=== Cenário 2: Criar uma tarefa nova e depois colocá-la em andamento ==="
    issue = criar_tarefa("Teste Cenário 2 - Tarefa Nova para Em Andamento")
    
    if issue
      trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
    end
  end
  
  # Cenário 3: Criar uma tarefa nova, colocá-la em andamento e depois resolvida
  def criar_tarefa_nova_em_andamento_resolvida
    puts "\n=== Cenário 3: Criar uma tarefa nova, colocá-la em andamento e depois resolvida ==="
    issue = criar_tarefa("Teste Cenário 3 - Tarefa Nova para Em Andamento para Resolvida")
    
    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
      end
    end
  end
end 