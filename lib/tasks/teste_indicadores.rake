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
    
    # Executar os cenários
    criar_tarefa_nova
    criar_tarefa_nova_em_andamento
    criar_tarefa_nova_em_andamento_resolvida
    
    puts "\nTestes concluídos!"
  end
  
  # Cenário 1: Criar uma tarefa nova
  def criar_tarefa_nova
    puts "\n=== Cenário 1: Criar uma tarefa nova ==="
    issue = Issue.new(
      project: @project,
      tracker: @tracker,
      status: @status_nova,
      subject: "Teste Cenário 1 - Tarefa Nova",
      description: "Tarefa para testar o cenário 1 - apenas tarefa nova",
      author: User.first
    )
    
    if issue.save
      puts "✓ Tarefa nova criada com sucesso (ID: #{issue.id})"
      
      # Processar indicadores
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      puts "✓ Indicadores processados para a tarefa nova"
    else
      puts "✗ Falha ao criar a tarefa nova: #{issue.errors.full_messages.join(', ')}"
    end
  end
  
  # Cenário 2: Criar uma tarefa nova e depois colocá-la em andamento
  def criar_tarefa_nova_em_andamento
    puts "\n=== Cenário 2: Criar uma tarefa nova e depois colocá-la em andamento ==="
    issue = Issue.new(
      project: @project,
      tracker: @tracker,
      status: @status_nova,
      subject: "Teste Cenário 2 - Tarefa Nova para Em Andamento",
      description: "Tarefa para testar o cenário 2 - nova e depois em andamento",
      author: User.first
    )
    
    if issue.save
      puts "✓ Tarefa nova criada com sucesso (ID: #{issue.id})"
      
      # Processar indicadores para a tarefa nova
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      puts "✓ Indicadores processados para a tarefa nova"
      
      # Atualizar para em andamento
      issue.status = @status_em_andamento
      if issue.save
        puts "✓ Tarefa atualizada para em andamento com sucesso"
        
        # Processar indicadores novamente
        SkyRedminePlugin::Indicadores.processar_indicadores(issue)
        puts "✓ Indicadores processados para a tarefa em andamento"
      else
        puts "✗ Falha ao atualizar a tarefa para em andamento: #{issue.errors.full_messages.join(', ')}"
      end
    else
      puts "✗ Falha ao criar a tarefa nova: #{issue.errors.full_messages.join(', ')}"
    end
  end
  
  # Cenário 3: Criar uma tarefa nova, colocá-la em andamento e depois resolvida
  def criar_tarefa_nova_em_andamento_resolvida
    puts "\n=== Cenário 3: Criar uma tarefa nova, colocá-la em andamento e depois resolvida ==="
    issue = Issue.new(
      project: @project,
      tracker: @tracker,
      status: @status_nova,
      subject: "Teste Cenário 3 - Tarefa Nova para Em Andamento para Resolvida",
      description: "Tarefa para testar o cenário 3 - nova, em andamento e resolvida",
      author: User.first
    )
    
    if issue.save
      puts "✓ Tarefa nova criada com sucesso (ID: #{issue.id})"
      
      # Processar indicadores para a tarefa nova
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      puts "✓ Indicadores processados para a tarefa nova"
      
      # Atualizar para em andamento
      issue.status = @status_em_andamento
      if issue.save
        puts "✓ Tarefa atualizada para em andamento com sucesso"
        
        # Processar indicadores para em andamento
        SkyRedminePlugin::Indicadores.processar_indicadores(issue)
        puts "✓ Indicadores processados para a tarefa em andamento"
        
        # Atualizar para resolvida
        issue.status = @status_resolvida
        if issue.save
          puts "✓ Tarefa atualizada para resolvida com sucesso"
          
          # Processar indicadores para resolvida
          SkyRedminePlugin::Indicadores.processar_indicadores(issue)
          puts "✓ Indicadores processados para a tarefa resolvida"
        else
          puts "✗ Falha ao atualizar a tarefa para resolvida: #{issue.errors.full_messages.join(', ')}"
        end
      else
        puts "✗ Falha ao atualizar a tarefa para em andamento: #{issue.errors.full_messages.join(', ')}"
      end
    else
      puts "✗ Falha ao criar a tarefa nova: #{issue.errors.full_messages.join(', ')}"
    end
  end
end 