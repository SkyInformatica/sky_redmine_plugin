module SkyRedminePlugin
  class Indicadores
    extend FluxoTarefasHelper

    def self.processar_indicadores(issue)
      Rails.logger.info ">>> inicio processar_indicadores issue.id: #{issue.id}"
      # Obter fluxo de tarefas
      tarefas_relacionadas = obter_lista_tarefas_relacionadas(issue)

      # Separar tarefas DEVEL e QS
      tarefas_devel = tarefas_relacionadas.select { |t| !SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(t.project.name) }
      tarefas_qs = tarefas_relacionadas.select { |t| SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(t.project.name) }

      # Processar dados DEVEL
      unless tarefas_devel.empty?
        primeira_tarefa_devel = tarefas_devel.first
        ultima_tarefa_devel = tarefas_devel.last

        indicador = SkyRedmineIndicadores.find_or_initialize_by(primeira_tarefa_devel_id: primeira_tarefa_devel.id)

        indicador.ultima_tarefa_devel_id = ultima_tarefa_devel.id
        indicador.tipo_primeira_tarefa_devel = primeira_tarefa_devel.tracker.name
        indicador.status_ultima_tarefa_devel = ultima_tarefa_devel.status.name
        indicador.prioridade_primeira_tarefa_devel = primeira_tarefa_devel.priority.name
        indicador.projeto_primeira_tarefa_devel = primeira_tarefa_devel.project.name
        indicador.sprint_primeira_tarefa_devel = primeira_tarefa_devel.fixed_version.present? ? primeira_tarefa_devel.fixed_version.name : nil
        indicador.sprint_ultima_tarefa_devel = ultima_tarefa_devel.fixed_version.present? ? ultima_tarefa_devel.fixed_version.name : nil
        indicador.tempo_estimado_devel = tarefas_devel.sum { |t| t.estimated_hours.to_f }
        indicador.tempo_gasto_devel = tarefas_devel.sum { |t| t.spent_hours.to_f }
        indicador.origem_primeira_tarefa_devel = obter_valor_campo_personalizado(primeira_tarefa_devel, "Origem")
        indicador.skynet_primeira_tarefa_devel = obter_valor_campo_personalizado(primeira_tarefa_devel, "Sky.NET")
        
        # Contar retornos de testes baseado no fluxo entre projetos
        qtd_retorno_testes = 0
        tarefas_relacionadas.each_with_index do |tarefa, index|
          next if index == 0 # Pula a primeira tarefa
          
          # Se a tarefa atual é DEVEL e a anterior era QS, é um retorno de testes
          if !SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(tarefa.project.name) &&
             SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(tarefas_relacionadas[index-1].project.name)
            qtd_retorno_testes += 1
          end
        end
        indicador.qtd_retorno_testes = qtd_retorno_testes
        
        data_atendimento = obter_valor_campo_personalizado(primeira_tarefa_devel, "Data de Atendimento")
        indicador.data_atendimento_primeira_tarefa_devel = data_atendimento
        indicador.data_criacao_ou_atendimento_primeira_tarefa_devel = data_atendimento || primeira_tarefa_devel.created_on.to_date
        
        # Processar datas de resolução e fechamento
        data_fechamento = obter_data_mudanca_status(ultima_tarefa_devel, [SkyRedminePlugin::Constants::IssueStatus::FECHADA])
        data_resolucao = obter_data_mudanca_status(ultima_tarefa_devel, [SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA])
        
        if data_fechamento.present? && data_resolucao.nil?
          # Se foi direto para fechada, usar a data de fechamento para ambos
          indicador.data_resolvida_ultima_tarefa_devel = data_fechamento
          indicador.data_fechamento_ultima_tarefa_devel = data_fechamento
        else
          indicador.data_resolvida_ultima_tarefa_devel = data_resolucao
          indicador.data_fechamento_ultima_tarefa_devel = data_fechamento
        end

        # Separar tarefas DEVEL em ciclos de desenvolvimento
        ciclos_devel = separar_ciclos_devel(tarefas_relacionadas)
        primeiro_ciclo_devel = ciclos_devel.first

        # Processar data de início em andamento usando apenas o primeiro ciclo
        data_andamento = nil
        data_criacao = primeira_tarefa_devel.created_on.to_date

        # Verificar cada tarefa do primeiro ciclo DEVEL na sequência
        primeiro_ciclo_devel.each_with_index do |tarefa, index|
          # Procurar por mudança para EM_ANDAMENTO
          data_andamento = obter_data_mudanca_status(tarefa, [SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO])
          break if data_andamento.present?

          # Se não encontrou EM_ANDAMENTO, verificar se está CONTINUA_PROXIMA_SPRINT
          if tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT
            # Se é a última tarefa do ciclo e está CONTINUA_PROXIMA_SPRINT, não encontrou EM_ANDAMENTO
            break if index == primeiro_ciclo_devel.length - 1
            # Se não é a última, continua procurando na próxima tarefa
            next
          end

          # Se chegou aqui, não está CONTINUA_PROXIMA_SPRINT
          # Se é a última tarefa do ciclo e foi direto para RESOLVIDA/FECHADA, usar data de criação
          if index == primeiro_ciclo_devel.length - 1 && 
             (tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA || 
              tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA)
            data_andamento = data_criacao
          end
          break
        end

        # Definir data de andamento
        indicador.data_andamento_primeira_tarefa_devel = data_andamento

        # Processar dados QS
        unless tarefas_qs.empty?
          primeira_tarefa_qs = tarefas_qs.first
          ultima_tarefa_qs = tarefas_qs.last

          indicador.primeira_tarefa_qs_id = primeira_tarefa_qs.id
          indicador.ultima_tarefa_qs_id = ultima_tarefa_qs.id
          indicador.sprint_primeira_tarefa_qs = primeira_tarefa_qs.fixed_version.present? ? primeira_tarefa_qs.fixed_version.name : nil
          indicador.sprint_ultima_tarefa_qs = ultima_tarefa_qs.fixed_version.present? ? ultima_tarefa_qs.fixed_version.name : nil
          indicador.projeto_primeira_tarefa_qs = primeira_tarefa_qs.project.name

          indicador.tempo_estimado_qs = tarefas_qs.sum { |t| t.estimated_hours.to_f }
          indicador.tempo_gasto_qs = tarefas_qs.sum { |t| t.spent_hours.to_f }
          indicador.status_ultima_tarefa_qs = ultima_tarefa_qs.status.name
          indicador.houve_teste_nok = tarefas_qs.any? { |t| [SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(t.status.name) }
          indicador.data_criacao_primeira_tarefa_qs = primeira_tarefa_qs.created_on.to_date
          
          # Separar tarefas QS em ciclos de teste
          ciclos_qs = separar_ciclos_qs(tarefas_relacionadas)
          primeiro_ciclo_qs = ciclos_qs.first

          # Processar data de início em andamento QS usando apenas o primeiro ciclo
          data_andamento_qs = nil
          data_criacao_qs = primeira_tarefa_qs.created_on.to_date

          # Verificar cada tarefa do primeiro ciclo QS na sequência
          primeiro_ciclo_qs.each_with_index do |tarefa, index|
            # Procurar por mudança para EM_ANDAMENTO
            data_andamento_qs = obter_data_mudanca_status(tarefa, [SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO])
            break if data_andamento_qs.present?

            # Se não encontrou EM_ANDAMENTO, verificar se está CONTINUA_PROXIMA_SPRINT
            if tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT
              # Se é a última tarefa do ciclo e está CONTINUA_PROXIMA_SPRINT, não encontrou EM_ANDAMENTO
              break if index == primeiro_ciclo_qs.length - 1
              # Se não é a última, continua procurando na próxima tarefa
              next
            end

            # Se chegou aqui, não está CONTINUA_PROXIMA_SPRINT
            # Se é a última tarefa do ciclo e foi direto para TESTE_OK ou TESTE_NOK, usar data de criação
            if index == primeiro_ciclo_qs.length - 1 && 
               [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK].include?(tarefa.status.name)
              data_andamento_qs = data_criacao_qs
            end
            break
          end

          # Definir data de andamento QS
          indicador.data_andamento_primeira_tarefa_qs = data_andamento_qs
          
          # Processar datas de resolução e fechamento QS
          data_fechamento_qs = obter_data_mudanca_status(ultima_tarefa_qs, [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA])
          data_resolucao_qs = obter_data_mudanca_status(ultima_tarefa_qs, [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK])
          
          if data_fechamento_qs.present? && data_resolucao_qs.nil?
            # Se foi direto para fechada, usar a data de fechamento para ambos
            indicador.data_resolvida_ultima_tarefa_qs = data_fechamento_qs
            indicador.data_fechamento_ultima_tarefa_qs = data_fechamento_qs
          else
            indicador.data_resolvida_ultima_tarefa_qs = data_resolucao_qs
            indicador.data_fechamento_ultima_tarefa_qs = data_fechamento_qs
          end
        end

        # Determinar o local atual da tarefa
        if tarefas_qs.empty?
          # Se não existe tarefa QS, está no DEVEL
          indicador.local_tarefa = "DEVEL"
        else
          ultima_tarefa_qs = tarefas_qs.last
          if [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(ultima_tarefa_qs.status.name)
            # Se a última tarefa QS está fechada (TESTE_OK_FECHADA ou TESTE_NOK_FECHADA), voltou para DEVEL
            indicador.local_tarefa = "DEVEL"
          else
            # Se existe tarefa QS e não está fechada, está no QS
            indicador.local_tarefa = "QS"
          end
        end

        indicador.save(validate: false)
      end
    end

    # Método para obter o valor de um campo personalizado
    def self.obter_valor_campo_personalizado(issue, field_name)
      custom_field = issue.custom_field_values.detect { |cf| cf.custom_field.name == field_name }
      custom_field ? custom_field.value : nil
    end

    # Método existente para obter data de mudança de status
    def self.obter_data_mudanca_status(tarefa, status_nomes)
      status_ids = IssueStatus.where(name: status_nomes).pluck(:id)

      journal = tarefa.journals.joins(:details)
                      .where(journal_details: { property: "attr", prop_key: "status_id", value: status_ids })
                      .order("created_on ASC")
                      .first

      journal&.created_on&.to_date
    end

    # Método para separar tarefas DEVEL em ciclos de desenvolvimento
    def self.separar_ciclos_devel(tarefas_relacionadas)
      ciclos = []
      ciclo_atual = []
      
      tarefas_relacionadas.each do |tarefa|
        # Se a tarefa é do projeto DEVEL
        if !SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(tarefa.project.name)
          ciclo_atual << tarefa
        else
          # Se encontrou uma tarefa QS, este ciclo DEVEL termina aqui
          ciclos << ciclo_atual unless ciclo_atual.empty?
          ciclo_atual = []
        end
      end
      
      # Adicionar o último ciclo se não estiver vazio
      ciclos << ciclo_atual unless ciclo_atual.empty?
      
      ciclos
    end

    # Método para separar tarefas QS em ciclos de teste
    def self.separar_ciclos_qs(tarefas_relacionadas)
      ciclos = []
      ciclo_atual = []
      
      tarefas_relacionadas.each do |tarefa|
        # Se a tarefa é do projeto QS
        if SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(tarefa.project.name)
          ciclo_atual << tarefa
        else
          # Se encontrou uma tarefa DEVEL, este ciclo QS termina aqui
          ciclos << ciclo_atual unless ciclo_atual.empty?
          ciclo_atual = []
        end
      end
      
      # Adicionar o último ciclo se não estiver vazio
      ciclos << ciclo_atual unless ciclo_atual.empty?
      
      ciclos
    end
  end
end
