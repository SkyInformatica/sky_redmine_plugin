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
    @cf_teste_no_desenvolvimento = CustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::TESTE_NO_DESENVOLVIMENTO)
    @cf_teste_qs = CustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::TESTE_QS)

    if @author.nil?
      puts "✗ Usuário 'maglan' não encontrado. Verifique se o usuário existe no sistema."
      return
    end
    
    puts "✓ Usuário 'maglan' encontrado (ID: #{@author.id})"
    
    # Executar os cenários
    #criar_tarefa_nova
    #criar_tarefa_nova_em_andamento
    #criar_tarefa_nova_em_andamento_resolvida
    #criar_tarefa_teste_no_desenvolvimento_nao_necessita_teste
    #criar_tarefa_teste_no_desenvolvimento_ok
    #criar_tarefa_teste_no_desenvolvimento_nok
    #criar_tarefa_qs_nao_necessita_teste
    criar_tarefa_encaminhar_para_qs
    
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

  # Função auxiliar para atualizar um campo personalizado
  def atualizar_campo_personalizado(issue, custom_field, valor, mensagem)
    issue = Issue.find(issue.id)
    issue.init_journal(@author, "[SkyRedminePlugin] #{mensagem}")
    issue.custom_field_values = { custom_field.id => valor }
    
    if issue.save
      puts "✓ Campo personalizado atualizado com sucesso: #{mensagem}"
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      puts "✓ Indicadores processados após atualização do campo personalizado"
      return true
    else
      puts "✗ Falha ao atualizar campo personalizado: #{issue.errors.full_messages.join(', ')}"
      return false
    end
  end
  
  # Função para imprimir os dados do indicador e verificar a situação atual
  def verificar_indicador(issue_id, situacao_esperada)
    puts "\n>> Verificação do Indicador para a Tarefa ##{issue_id}"
    
    # Buscar o indicador pelo número da tarefa
    indicador = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: issue_id)
    
    if indicador
      puts "✓ Indicador encontrado"
      
      # Imprimir os dados do indicador
      puts "  Situação Atual: #{indicador.situacao_atual}"
      puts "  Responsável Atual: #{indicador.equipe_responsavel_atual}"
      puts "  Qtde Retorno Testes QS: #{indicador.qtd_retorno_testes_qs}"
      puts "  Qtde Retorno Testes Devel: #{indicador.qtd_retorno_testes_devel}"
      puts "  Versão Liberada Antes dos Testes: #{indicador.tarefa_complementar}"
      puts "  Tarefa Complementar: #{indicador.tarefa_complementar}"
      
      # Verificar se a situação atual está correta
      if indicador.situacao_atual == situacao_esperada
        puts "✓ Situação atual está correta: #{situacao_esperada}"
      else
        puts "✗ Situação atual está incorreta: #{indicador.situacao_atual} (esperada: #{situacao_esperada})"
      end
    else
      puts "✗ Indicador não encontrado para a tarefa ##{issue_id}"
    end
  end
  
  # Cenário 1: Criar uma tarefa nova
  def criar_tarefa_nova
    puts "\n=== Cenário 1: Criar uma tarefa nova ==="
    issue = criar_tarefa("Teste Cenário 1 - Tarefa Nova")
    
    if issue
      verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL)
    end
  end
  
  # Cenário 2: Criar uma tarefa nova e depois colocá-la em andamento
  def criar_tarefa_nova_em_andamento
    puts "\n=== Cenário 2: Criar uma tarefa nova e depois colocá-la em andamento ==="
    issue = criar_tarefa("Teste Cenário 2 - Tarefa Nova para Em Andamento")
    
    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL)
      end
    end
  end
  
  # Cenário 3: Criar uma tarefa nova, colocá-la em andamento e depois resolvida
  def criar_tarefa_nova_em_andamento_resolvida
    puts "\n\n=== Cenário 3: Criar uma tarefa nova, colocá-la em andamento e depois resolvida ==="
    issue = criar_tarefa("Teste Cenário 3 - Tarefa Nova para Em Andamento para Resolvida")
    
    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_TESTES_DEVEL)
        end
      end
    end
  end
  
  # Cenário 4: Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Não necessita teste'
  def criar_tarefa_teste_no_desenvolvimento_nao_necessita_teste
    puts "\n=== Cenário 4: Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Não necessita teste' ==="
    issue = criar_tarefa("Teste Cenário 4 - Tarefa Teste DEVEL Não Necessita Teste")
    
    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          if atualizar_campo_personalizado(issue, @cf_teste_no_desenvolvimento, SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE, "Campo '#{SkyRedminePlugin::Constants::CustomFields::TESTE_NO_DESENVOLVIMENTO}' alterado para '#{SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE}'")
            verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS)
          end
        end
      end
    end
  end
  
  
  
  # Cenário 5: Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Teste OK'
  def criar_tarefa_teste_no_desenvolvimento_ok
    puts "\n=== Cenário 5: Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Teste OK' ==="
    issue = criar_tarefa("Teste Cenário 5 - Tarefa Teste DEVEL Teste OK")
    
    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          if atualizar_campo_personalizado(issue, @cf_teste_no_desenvolvimento, SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_OK, "Campo '#{SkyRedminePlugin::Constants::CustomFields::TESTE_NO_DESENVOLVIMENTO}' alterado para '#{SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_OK}'")
            verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS)
          end
        end
      end
    end
  end
  
  # Cenário 6: Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Teste NOK'
  def criar_tarefa_teste_no_desenvolvimento_nok
    puts "\n=== Cenário 6: Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Teste NOK' ==="
    issue = criar_tarefa("Teste Cenário 6 - Tarefa Teste DEVEL Teste NOK")
    
    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          if atualizar_campo_personalizado(issue, @cf_teste_no_desenvolvimento, SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_NOK, "Campo '#{SkyRedminePlugin::Constants::CustomFields::TESTE_NO_DESENVOLVIMENTO}' alterado para '#{SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_NOK}'")
            verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL)
          end
        end
      end
    end
  end

  # Cenário 7: Criar uma tarefa, colocá-la em andamento, resolvida e marcar Teste QS como 'Não necessita teste'
  def criar_tarefa_qs_nao_necessita_teste
    puts "\n=== Cenário 7: Criar uma tarefa, colocá-la em andamento, resolvida e marcar Teste QS como 'Não necessita teste' ==="
    issue = criar_tarefa("Teste Cenário 7 - Tarefa Teste QS não necessita teste")
    
    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          if atualizar_campo_personalizado(issue, @cf_teste_qs, SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE, "Campo '#{SkyRedminePlugin::Constants::CustomFields::TESTE_QS}' alterado para '#{SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE}'")
            verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO)
          end
        end
      end
    end
  end
  
  # Cenário 8: Criar uma tarefa, colocá-la em andamento, resolvida e encaminhar para QS
  def criar_tarefa_encaminhar_para_qs
    puts "\n=== Cenário 8: Criar uma tarefa, colocá-la em andamento, resolvida e encaminhar para QS ==="
    issue = criar_tarefa("Teste Cenário 8 - Tarefa para Encaminhar para QS")
    
    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          # Verificar se a tarefa está pronta para ser encaminhada para QS
          verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_TESTES_DEVEL)
          
          # Encaminhar para QS usando o controller
          puts "Encaminhando tarefa ##{issue.id} para QS..."
          
          # Configurar o controller para simular a chamada
          controller = EncaminharQsController.new
          controller.instance_variable_set(:@issue, issue)
          controller.instance_variable_set(:@processed_issues, [])
          
          # Simular o parâmetro de usar sprint atual (opcional)
          params = { usar_sprint_atual: false }
          controller.params = params
          
          # Executar o método encaminhar_qs
          controller.encaminhar_qs(true)
          
          Rails.logger.info ">>> depois de controller.encaminhar_qs #{issue.id}"
          # Verificar se a tarefa foi encaminhada com sucesso
          copied_to_qs_issue = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_copiada_qs(issue)
          
          if copied_to_qs_issue
            puts "✓ Tarefa ##{issue.id} encaminhada com sucesso para QS (ID: #{copied_to_qs_issue.id})"
            puts "  Projeto QS: #{copied_to_qs_issue.project.name}"
            puts "  Sprint: #{copied_to_qs_issue.fixed_version.name}"
            puts "  Tempo estimado: #{copied_to_qs_issue.estimated_hours} horas"
            
            # Verificar o indicador após o encaminhamento
            verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_TESTES_QS)
          else
            puts "✗ Falha ao encaminhar a tarefa ##{issue.id} para QS"
          end
        end
      end
    end
  end
end 