namespace :sky_redmine_plugin do
  desc "Executa os testes de indicadores no ambiente especificado"
  task :test_indicadores => :environment do
    puts "Iniciando testes de indicadores..."
    
    # Configuração básica
    @project = Project.find_by(name: "Equipe Notar")
    @tracker = Tracker.first
    @status_nova = IssueStatus.find_by(name: "Nova")
    @status_em_andamento = IssueStatus.find_by(name: "Em andamento")
    @status_resolvida = IssueStatus.find_by(name: "Resolvida")
    
    # Verificar se os status existem
    unless @status_nova
      puts "ERRO: Status 'Nova' não encontrado"
      next
    end
    
    unless @status_em_andamento
      puts "ERRO: Status 'Em andamento' não encontrado"
      next
    end
    
    unless @status_resolvida
      puts "ERRO: Status 'Resolvida' não encontrado"
      next
    end
    
    # Verificar se o projeto existe
    unless @project
      puts "ERRO: Projeto 'Equipe Notar' não encontrado"
      next
    end
    
    # Verificar se o tracker existe
    unless @tracker
      puts "ERRO: Nenhum tracker encontrado"
      next
    end
    
    # Executar os cenários
    test_cenario_1_tarefa_nova
    test_cenario_2_tarefa_nova_em_andamento
    test_cenario_3_tarefa_nova_em_andamento_resolvida
    
    puts "\nTestes concluídos!"
  end
  
  # Cenário 1: Criar uma tarefa nova
  def test_cenario_1_tarefa_nova
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
      
      # Verificar se o indicador foi criado
      indicador = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: issue.id)
      if indicador
        puts "✓ Indicador criado com sucesso"
        puts "  Situação atual: #{indicador.situacao_atual}"
        if indicador.situacao_atual == "ESTOQUE_DEVEL"
          puts "✓ Situação atual correta para tarefa nova"
        else
          puts "✗ Situação atual incorreta para tarefa nova (esperado: ESTOQUE_DEVEL, obtido: #{indicador.situacao_atual})"
        end
      else
        puts "✗ Indicador não foi criado para a tarefa nova"
      end
    else
      puts "✗ Falha ao criar a tarefa nova: #{issue.errors.full_messages.join(', ')}"
    end
  end
  
  # Cenário 2: Criar uma tarefa nova e depois colocá-la em andamento
  def test_cenario_2_tarefa_nova_em_andamento
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
      
      # Atualizar para em andamento
      issue.status = @status_em_andamento
      if issue.save
        puts "✓ Tarefa atualizada para em andamento com sucesso"
        
        # Processar indicadores novamente
        SkyRedminePlugin::Indicadores.processar_indicadores(issue)
        
        # Verificar se o indicador foi atualizado
        indicador = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: issue.id)
        if indicador
          puts "✓ Indicador atualizado com sucesso"
          puts "  Situação atual: #{indicador.situacao_atual}"
          if indicador.situacao_atual == "EM_ANDAMENTO_DEVEL"
            puts "✓ Situação atual correta para tarefa em andamento"
          else
            puts "✗ Situação atual incorreta para tarefa em andamento (esperado: EM_ANDAMENTO_DEVEL, obtido: #{indicador.situacao_atual})"
          end
        else
          puts "✗ Indicador não foi encontrado para a tarefa em andamento"
        end
      else
        puts "✗ Falha ao atualizar a tarefa para em andamento: #{issue.errors.full_messages.join(', ')}"
      end
    else
      puts "✗ Falha ao criar a tarefa nova: #{issue.errors.full_messages.join(', ')}"
    end
  end
  
  # Cenário 3: Criar uma tarefa nova, colocá-la em andamento e depois resolvida
  def test_cenario_3_tarefa_nova_em_andamento_resolvida
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
      
      # Atualizar para em andamento
      issue.status = @status_em_andamento
      if issue.save
        puts "✓ Tarefa atualizada para em andamento com sucesso"
        
        # Processar indicadores para em andamento
        SkyRedminePlugin::Indicadores.processar_indicadores(issue)
        
        # Atualizar para resolvida
        issue.status = @status_resolvida
        if issue.save
          puts "✓ Tarefa atualizada para resolvida com sucesso"
          
          # Processar indicadores para resolvida
          SkyRedminePlugin::Indicadores.processar_indicadores(issue)
          
          # Verificar se o indicador foi atualizado
          indicador = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: issue.id)
          if indicador
            puts "✓ Indicador atualizado com sucesso"
            puts "  Situação atual: #{indicador.situacao_atual}"
            if indicador.situacao_atual == "AGUARDANDO_ENCAMINHAR_QS"
              puts "✓ Situação atual correta para tarefa resolvida"
            else
              puts "✗ Situação atual incorreta para tarefa resolvida (esperado: AGUARDANDO_ENCAMINHAR_QS, obtido: #{indicador.situacao_atual})"
            end
          else
            puts "✗ Indicador não foi encontrado para a tarefa resolvida"
          end
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