# para executar os testes de indicadores use o comando
# RAILS_ENV=production rake sky_redmine_plugin:teste_indicadores

# tarefa #78983 - versao liberada antes dos testes - modificado para testes
# tarefa #78969 - versao liberada antes dos testes - original

namespace :sky_redmine_plugin do
  desc "Executa os testes de indicadores no ambiente especificado"
  task :teste_indicadores => :environment do
    puts "Iniciando testes de indicadores..."

    # Configuração básica
    @project = Project.find_by(name: "Equipe Notar")
    @tracker = Tracker.first
    @status_nova = IssueStatus.find_by(name: "Nova")
    @version = @project.versions.find_by(name: "2025-01 (30/12 a 10/01)")

    @status_em_andamento = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO)
    @status_resolvida = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA)
    @status_fechada = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::FECHADA)
    @status_teste_nok = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK)
    @author = User.find_by(login: "maglan")
    @cf_teste_no_desenvolvimento = CustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::TESTE_NO_DESENVOLVIMENTO)
    @cf_teste_qs = CustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::TESTE_QS)

    if @author.nil?
      puts "✗ Usuário 'maglan' não encontrado. Verifique se o usuário existe no sistema."
      return
    end

    puts "✓ Usuário 'maglan' encontrado (ID: #{@author.id})"

    # Tipo padrão (Defeito)
    #criar_tarefa_nova
    #criar_tarefa_nova_em_andamento
    #criar_tarefa_nova_em_andamento_resolvida

    # Tipo Conversão
    #criar_tarefa_nova(SkyRedminePlugin::Constants::Trackers::CONVERSAO)
    #criar_tarefa_nova_em_andamento(SkyRedminePlugin::Constants::Trackers::CONVERSAO)
    #criar_tarefa_nova_em_andamento_resolvida(SkyRedminePlugin::Constants::Trackers::CONVERSAO, SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO)
    #criar_tarefa_nova_em_andamento_resolvida_fechada(SkyRedminePlugin::Constants::Trackers::CONVERSAO)

    # Testes no desenvolvimento
    #criar_tarefa_teste_no_desenvolvimento_nao_necessita_teste
    #criar_tarefa_teste_no_desenvolvimento_ok
    #criar_tarefa_teste_no_desenvolvimento_nok

    # Testes no QS
    #criar_tarefa_qs_nao_necessita_teste
    #criar_tarefa_encaminhar_para_qs

    # Teste de situacoes DESCONHECIDAS
    #criar_tarefa_desconhecida_fechada_continua_sem_retorno
    #criar_tarefa_desconhecida_teste_nok_fechada_sem_retorno
    #criar_tarefa_desconhecida_continuidade_nao_retorno

    # Teste das funcionalidaes de continuidade
    #criar_tarefa_continua_proxima_sprint
    #criar_tarefa_encaminhar_para_qs_teste_nok_retorno_testes

    criar_tarefa_teste_no_desenvolvimento_nok_retorno_testes_encaminhar_qs

    puts "\nTestes concluídos!"
  end

  # Função auxiliar para criar uma tarefa
  def criar_tarefa(subject, tracker = nil)
    issue = Issue.new(
      project: @project,
      tracker: tracker || @tracker,
      status: @status_nova,
      subject: subject,
      author: @author,
      assigned_to: @author,
      fixed_version: @version,
    )

    if issue.save
      puts "✓ Tarefa nova criada com sucesso (ID: #{issue.id})"

      # Processar indicadores para a tarefa nova
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      puts "✓ Indicadores processados para a tarefa nova"

      return issue
    else
      puts "✗ Falha ao criar a tarefa nova: #{issue.errors.full_messages.join(", ")}"
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
      puts "✗ Falha ao atualizar a tarefa para #{mensagem.downcase}: #{issue.errors.full_messages.join(", ")}"
      return false
    end
  end

  # Função auxiliar para trocar o tipo (tracker) de uma tarefa
  def trocar_tipo_tarefa(issue, novo_tipo)
    puts "\n>> Trocando tipo da tarefa ##{issue.id} para #{novo_tipo}"

    # Recarregar a tarefa para evitar StaleObjectError
    issue = Issue.find(issue.id)

    # Encontrar o tracker pelo nome
    tracker = Tracker.find_by(name: novo_tipo)
    if tracker.nil?
      puts "✗ Tipo de tarefa '#{novo_tipo}' não encontrado"
      return false
    end

    # Inicializar o journal antes de alterar o tipo
    issue.init_journal(@author, "[SkyRedminePlugin] Tipo alterado para #{novo_tipo}")

    # Guardar o tipo antigo para log
    tipo_antigo = issue.tracker.name

    # Atualizar o tipo
    issue.tracker = tracker

    if issue.save
      puts "✓ Tipo da tarefa alterado com sucesso (#{tipo_antigo} -> #{novo_tipo})"

      # Processar indicadores após a mudança
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      puts "✓ Indicadores processados após alteração do tipo"

      return true
    else
      puts "✗ Falha ao alterar tipo da tarefa: #{issue.errors.full_messages.join(", ")}"
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
      puts "✗ Falha ao atualizar campo personalizado: #{issue.errors.full_messages.join(", ")}"
      return false
    end
  end

  def encaminhar_para_qs(issue)
    issue = Issue.find(issue.id)
    puts "Encaminhando tarefa ##{issue.id} para QS..."
    controller = EncaminharQsController.new
    controller.instance_variable_set(:@issue, issue)
    controller.instance_variable_set(:@processed_issues, [])
    controller.params = { usar_sprint_atual: false }
    controller.encaminhar_qs(false, true)

    # Localizar a tarefa QS criada
    tarefa_qs = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_copiada_qs(issue)
    if tarefa_qs
      puts "✓ Tarefa ##{issue.id} encaminhada com sucesso para QS com ID: #{tarefa_qs.id})"
      puts "  Projeto QS: #{tarefa_qs.project.name}"
      puts "  Sprint: #{tarefa_qs.fixed_version.name}"
      puts "  Tempo estimado: #{tarefa_qs.estimated_hours} horas"

      return tarefa_qs
    else
      puts "✗ Falha ao encaminhar a tarefa ##{issue.id} para QS"
      return nil
    end
  end

  def retorno_testes_devel(tarefa_devel)
    tarefa_devel = Issue.find(tarefa_devel.id)
    puts "Criando retorno de testes DEVEL para tarefa ##{tarefa_devel.id}..."
    controller = RetornoTestesController.new
    controller.instance_variable_set(:@issue, tarefa_devel)
    controller.instance_variable_set(:@processed_issues, [])
    controller.params = { usar_sprint_atual: false }
    controller.retorno_testes_devel(false, true)

    # Localizar a tarefa de retorno de testes criada
    tarefa_retorno_testes = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_retorno_testes(tarefa_devel)
    if tarefa_retorno_testes
      puts "✓ Retorno de testes #{tarefa_retorno_testes.id} criadao com sucesso para tarefa ##{tarefa_devel.id}"
      puts "  Projeto: #{tarefa_retorno_testes.project.name}"
      puts "  Sprint: #{tarefa_retorno_testes.fixed_version.name}"
      puts "  Tempo estimado: #{tarefa_retorno_testes.estimated_hours} horas"
      return tarefa_retorno_testes
    else
      puts "✗ Falha ao criar retorno de testes para a tarefa ##{tarefa_devel.id}"
      return nil
    end
  end

  def retorno_testes_qs(tarefa_qs)
    tarefa_qs = Issue.find(tarefa_qs.id)
    puts "Criando retorno de testes do QS para tarefa ##{tarefa_qs.id}..."
    controller = RetornoTestesController.new
    controller.instance_variable_set(:@issue, tarefa_qs)
    controller.instance_variable_set(:@processed_issues, [])
    controller.params = { usar_sprint_atual: false }
    controller.retorno_testes_qs(false, true)

    # Localizar a tarefa de retorno de testes criada
    tarefa_retorno_testes = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_retorno_testes(tarefa_qs)
    if tarefa_retorno_testes
      puts "✓ Retorno de testes #{tarefa_retorno_testes.id} criadao com sucesso para tarefa ##{tarefa_qs.id}"
      puts "  Projeto: #{tarefa_retorno_testes.project.name}"
      puts "  Sprint: #{tarefa_retorno_testes.fixed_version.name}"
      puts "  Tempo estimado: #{tarefa_retorno_testes.estimated_hours} horas"
      return tarefa_retorno_testes
    else
      puts "✗ Falha ao criar retorno de testes para a tarefa ##{tarefa_qs.id}"
      return nil
    end
  end

  def continua_proxima_sprint(issue)
    issue = Issue.find(issue.id)
    puts "Criando copia da tarefa ##{issue.id} para continua na proxima sprint..."
    # Executar o controller para fazer copia de continuidade para a proxima sprint
    controller = ContinuaProximaSprintController.new
    controller.instance_variable_set(:@issue, issue)
    controller.instance_variable_set(:@processed_issues, [])
    controller.params = { usar_sprint_atual: false }
    controller.continua_proxima_sprint(false, true)

    tarefa_continuidade = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_continuidade(issue)
    if tarefa_continuidade
      puts "✓ Tarefa #{tarefa_continuidade.id} continua na proxima sprint criadao com sucesso para tarefa ##{tarefa_qs.id}"
      puts "  Projeto: #{tarefa_continuidade.project.name}"
      puts "  Sprint: #{tarefa_continuidade.fixed_version.name}"
      puts "  Tempo estimado: #{tarefa_continuidade.estimated_hours} horas"
      return tarefa_continuidade
    else
      puts "✗ Falha ao criar tarefa de continuidade na proxima sprint para ##{tarefa_qs.id}"
      return nil
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

  # Criar uma tarefa nova
  def criar_tarefa_nova(tracker_name = nil)
    tracker = tracker_name ? Tracker.find_by(name: tracker_name) : @tracker
    suffix = tracker_name ? " (#{tracker_name})" : ""
    puts "\n=== Criar uma tarefa nova#{suffix} ==="
    issue = criar_tarefa("Tarefa Nova#{suffix}", tracker)

    if issue
      verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL)
    end
  end

  # Criar uma tarefa nova e depois colocá-la em andamento
  def criar_tarefa_nova_em_andamento(tracker_name = nil)
    tracker = tracker_name ? Tracker.find_by(name: tracker_name) : @tracker
    suffix = tracker_name ? " (#{tracker_name})" : ""
    puts "\n=== Criar uma tarefa nova e depois colocá-la em andamento#{suffix} ==="
    issue = criar_tarefa("Tarefa Nova para Em Andamento#{suffix}", tracker)

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL)
      end
    end
  end

  # Criar uma tarefa nova, colocá-la em andamento e depois resolvida
  def criar_tarefa_nova_em_andamento_resolvida(tracker_name = nil, situacao_esperada = SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_TESTES_DEVEL)
    tracker = tracker_name ? Tracker.find_by(name: tracker_name) : @tracker
    suffix = tracker_name ? " (#{tracker_name})" : ""
    puts "\n\n=== Criar uma tarefa nova, colocá-la em andamento e depois resolvida#{suffix} ==="
    issue = criar_tarefa("Tarefa Nova para Em Andamento para Resolvida#{suffix}", tracker)

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          verificar_indicador(issue.id, situacao_esperada)
        end
      end
    end
  end

  # Criar uma tarefa nova, colocá-la em andamento e depois resolvida
  def criar_tarefa_nova_em_andamento_resolvida_fechada(tracker_name = nil)
    tracker = tracker_name ? Tracker.find_by(name: tracker_name) : @tracker
    suffix = tracker_name ? " (#{tracker_name})" : ""
    puts "\n\n=== Criar uma tarefa nova, colocá-la em andamento e depois resolvida#{suffix} ==="
    issue = criar_tarefa("Tarefa Nova para Em Andamento para Resolvida#{suffix}", tracker)

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          if trocar_status(issue, @status_fechada, "Status alterado para Fechada")
            verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA)
          end
        end
      end
    end
  end

  # Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Não necessita teste'
  def criar_tarefa_teste_no_desenvolvimento_nao_necessita_teste
    puts "\n=== Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Não necessita teste' ==="
    issue = criar_tarefa("Tarefa Teste DEVEL Não Necessita Teste")

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

  # Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Teste OK'
  def criar_tarefa_teste_no_desenvolvimento_ok
    puts "\n=== Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Teste OK' ==="
    issue = criar_tarefa("Tarefa Teste DEVEL Teste OK")

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

  # Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Teste NOK'
  def criar_tarefa_teste_no_desenvolvimento_nok(validar = true)
    puts "\n=== Criar uma tarefa, colocá-la em andamento, resolvida e marcar como 'Teste NOK' ==="
    issue = criar_tarefa("Tarefa Teste DEVEL Teste NOK")

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          if atualizar_campo_personalizado(issue, @cf_teste_no_desenvolvimento, SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_NOK, "Campo '#{SkyRedminePlugin::Constants::CustomFields::TESTE_NO_DESENVOLVIMENTO}' alterado para '#{SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_NOK}'")
            if (validar)
              verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL)
            end

            return issue
          end
        end
      end
    end
  end

  # Criar uma tarefa, colocá-la em andamento, resolvida e marcar Teste QS como 'Não necessita teste'
  def criar_tarefa_qs_nao_necessita_teste
    puts "\n=== Criar uma tarefa, colocá-la em andamento, resolvida e marcar Teste QS como 'Não necessita teste' ==="
    issue = criar_tarefa("Tarefa Teste QS não necessita teste")

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

  # Criar uma tarefa, colocá-la em andamento, resolvida e encaminhar para QS
  def criar_tarefa_encaminhar_para_qs
    puts "\n=== Criar uma tarefa, colocá-la em andamento, resolvida e encaminhar para QS ==="
    issue = criar_tarefa("Tarefa para Encaminhar para QS")

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          issue = Issue.find(issue.id)
          tarefa_qs = encaminhar_para_qs(issue)
          if tarefa_qs
            verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS)
          end
        end
      end
    end
  end

  # Criar uma tarefa que ficará com situação DESCONHECIDA por ter FECHADA_CONTINUA_RETORNO_TESTES sem continuidade
  def criar_tarefa_desconhecida_fechada_continua_sem_retorno
    puts "\n=== Criar tarefa que ficará DESCONHECIDA (FECHADA_CONTINUA_RETORNO_TESTES sem continuidade) ==="
    issue = criar_tarefa("Tarefa DESCONHECIDA - Fechada Continua sem Retorno")

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          issue = Issue.find(issue.id)
          tarefa_qs = encaminhar_para_qs(issue)
          if tarefa_qs
            # Trocar status da tarefa QS para TESTE_NOK
            status_teste_nok = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK)
            trocar_status(tarefa_qs, status_teste_nok, "Status alterado para TESTE NOK")

            # Trocar status da tarefa DEVEL para FECHADA_CONTINUA_RETORNO_TESTES
            status_fechada_continua = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::FECHADA_CONTINUA_RETORNO_TESTES)
            trocar_status(issue, status_fechada_continua, "Status alterado para FECHADA_CONTINUA_RETORNO_TESTES")

            verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA)
          end
        end
      end
    end
  end

  # Criar uma tarefa que ficará com situação DESCONHECIDA por ter TESTE_NOK_FECHADA sem continuidade
  def criar_tarefa_desconhecida_teste_nok_fechada_sem_retorno
    puts "\n=== Criar tarefa que ficará DESCONHECIDA (TESTE_NOK_FECHADA sem continuidade) ==="
    issue = criar_tarefa("Tarefa DESCONHECIDA - Teste NOK Fechada sem Retorno")

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          issue = Issue.find(issue.id)
          # Encaminhar para QS
          tarefa_qs = encaminhar_para_qs(issue)
          if tarefa_qs
            # Trocar status da tarefa QS para TESTE_NOK_FECHADA
            status_teste_nok_fechada = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA)
            trocar_status(tarefa_qs, status_teste_nok_fechada, "Status alterado para TESTE_NOK_FECHADA")

            verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA)
          end
        end
      end
    end
  end

  # Criar uma tarefa que ficará com situação DESCONHECIDA por ter tarefa de continuidade que não é RETORNO_TESTES
  def criar_tarefa_desconhecida_continuidade_nao_retorno
    puts "\n=== Criar tarefa que ficará DESCONHECIDA (Continuidade não é RETORNO_TESTES) ==="
    issue = criar_tarefa("Tarefa DESCONHECIDA - Continuidade não é Retorno")

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          issue = Issue.find(issue.id)
          puts "Encaminhando tarefa ##{issue.id} para QS..."
          tarefa_qs = encaminhar_para_qs(issue)
          if tarefa_qs
            # Trocar status da tarefa QS para TESTE_NOK
            trocar_status(tarefa_qs, @status_teste_nok, "Status alterado para TESTE_NOK")
            tarefa_qs = Issue.find(tarefa_qs.id)

            tarefa_retorno_testes = retorno_testes_qs(tarefa_qs)
            if tarefa_retorno_testes
              trocar_tipo_tarefa(tarefa_retorno_testes, SkyRedminePlugin::Constants::Trackers::DEFEITO)
              tarefa_retorno_testes = Issue.find(tarefa_retorno_testes.id)

              verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA)
            end
          end
        end
      end
    end
  end

  def criar_tarefa_continua_proxima_sprint
    puts "\n=== Criar uma tarefa nova e depois colocá-la em andamento e depois continua na proxima sprint ==="
    issue = criar_tarefa("Tarefa Nova para Em Andamento - continua proxima sprint")

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        tarefa_continuidade = continua_proxima_sprint(issue)
        if tarefa_continuidade
          verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL)
        end
      end
    end
  end

  def criar_tarefa_encaminhar_para_qs_teste_nok_retorno_testes
    puts "\n=== Criar uma tarefa, colocá-la em andamento, resolvida e encaminhar para QS com Teste NOK e criar o retorno de testes ==="
    issue = criar_tarefa("Tarefa para Encaminhar para QS com retorno de testes")

    if issue
      if trocar_status(issue, @status_em_andamento, "Status alterado para Em andamento")
        if trocar_status(issue, @status_resolvida, "Status alterado para Resolvida")
          tarefa_qs = encaminhar_para_qs(issue)
          # Verificar se a tarefa foi encaminhada com sucesso

          if tarefa_qs
            trocar_status(tarefa_qs, @status_teste_nok, "Status alterado para TESTE NOK")
            tarefa_retorno_testes = retorno_testes_qs(tarefa_qs)
            if tarefa_retorno_testes
              verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL_RETORNO_TESTES)
            end
          end
        end
      end
    end
  end

  def criar_tarefa_teste_no_desenvolvimento_nok_retorno_testes_encaminhar_qs
    issue = criar_tarefa_teste_no_desenvolvimento_nok(false)
    issue = Issue.find(issue.id)
    tarefa_retorno_testes = retorno_testes_devel(issue)
    if tarefa_retorno_testes
      trocar_status(tarefa_retorno_testes, @status_resolvida, "Status alterado para Resolvida")
      tarefa_qs = encaminhar_para_qs(tarefa_retorno_testes)
      if tarefa_qs
        verificar_indicador(issue.id, SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS)
      end
    end
  end
end
