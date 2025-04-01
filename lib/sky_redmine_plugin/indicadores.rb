module SkyRedminePlugin
  module Indicadores    
    include TarefasRelacionadas

    

    def self.processar_indicadores(issue, is_exclusao = false)
      Rails.logger.info ">>> inicio processar_indicadores issue.id: #{issue.id}, is_exclusao: #{is_exclusao}"
      
      # Se é uma exclusão, procurar o indicador por qualquer um dos campos de ID
      if is_exclusao
        indicador = SkyRedmineIndicadores.find_by(
          "primeira_tarefa_devel_id = ? OR ultima_tarefa_devel_id = ? OR primeira_tarefa_qs_id = ? OR ultima_tarefa_qs_id = ?",
          issue.id, issue.id, issue.id, issue.id
        )

        if indicador
          Rails.logger.info ">>> encontrado indicador para issue.id: #{issue.id}"
          
          # Se a tarefa excluída é a primeira_tarefa_devel_id, excluir o indicador
          if indicador.primeira_tarefa_devel_id == issue.id
            Rails.logger.info ">>> excluindo indicador pois issue.id é a primeira_tarefa_devel_id"
            indicador.destroy
            return
          end
          
          # Se não é a primeira_tarefa_devel_id, reprocessar o indicador
          Rails.logger.info ">>> reprocessando indicador usando primeira_tarefa_devel_id: #{indicador.primeira_tarefa_devel_id}"
          issue = Issue.find(indicador.primeira_tarefa_devel_id)
        end
      end

      # Obter fluxo de tarefas usando o método do módulo TarefasRelacionadas
      tarefas_relacionadas = SkyRedminePlugin::TarefasRelacionadas.obter_lista_tarefas_relacionadas(issue)

      # Separar tarefas DEVEL e QS
      tarefas_devel = tarefas_relacionadas.select { |t| !SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(t.project.name) }
      tarefas_qs = tarefas_relacionadas.select { |t| SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(t.project.name) }

      Rails.logger.info ">>> tarefas_devel: #{tarefas_devel.inspect}"
      Rails.logger.info ">>> tarefas_qs: #{tarefas_qs.inspect}"

      # Processar dados DEVEL
      unless tarefas_devel.empty?
        primeira_tarefa_devel = tarefas_devel.first
        ultima_tarefa_devel = tarefas_devel.last

        # Encontrar ou inicializar o indicador
        indicador = SkyRedmineIndicadores.find_or_initialize_by(primeira_tarefa_devel_id: primeira_tarefa_devel.id)

        # Limpar todos os campos antes de processar
        limpar_campos_indicador(indicador)

        indicador.ultima_tarefa_devel_id = ultima_tarefa_devel.id
        indicador.tipo_primeira_tarefa_devel = primeira_tarefa_devel.tracker.name
        indicador.status_ultima_tarefa_devel = ultima_tarefa_devel.status.name
        indicador.prioridade_primeira_tarefa_devel = primeira_tarefa_devel.priority.name
        indicador.projeto_primeira_tarefa_devel = primeira_tarefa_devel.project.name
        indicador.sprint_primeira_tarefa_devel = primeira_tarefa_devel.fixed_version.present? ? primeira_tarefa_devel.fixed_version.name : nil
        indicador.sprint_ultima_tarefa_devel = ultima_tarefa_devel.fixed_version.present? ? ultima_tarefa_devel.fixed_version.name : nil
        indicador.tempo_estimado_devel = tarefas_devel.sum { |t| t.estimated_hours.to_f }
        indicador.tempo_gasto_devel = tarefas_devel.sum { |t| t.spent_hours.to_f }
        indicador.origem_primeira_tarefa_devel = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, "Origem")
        indicador.skynet_primeira_tarefa_devel = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, "Sky.NET")
        
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
        
        # Usar as datas já calculadas pela função obter_lista_tarefas_relacionadas
        indicador.data_criacao_ou_atendimento_primeira_tarefa_devel = primeira_tarefa_devel.data_criacao
        indicador.data_resolvida_ultima_tarefa_devel = ultima_tarefa_devel.data_resolvida
        indicador.data_fechamento_ultima_tarefa_devel = ultima_tarefa_devel.data_fechada

        # Separar tarefas DEVEL em ciclos de desenvolvimento
        ciclos_devel = SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_devel(tarefas_relacionadas)
        primeiro_ciclo_devel = ciclos_devel.first

        # Processar data de início em andamento usando apenas o primeiro ciclo
        data_andamento = nil
        primeiro_ciclo_devel.each do |tarefa|
          if tarefa.data_em_andamento.present?
            data_andamento = tarefa.data_em_andamento
            break
          end
        end
        indicador.data_andamento_primeira_tarefa_devel = data_andamento

        # Calcular tempos DEVEL
        if indicador.data_criacao_ou_atendimento_primeira_tarefa_devel.present? && indicador.data_andamento_primeira_tarefa_devel.present?
          indicador.tempo_andamento_devel = (indicador.data_andamento_primeira_tarefa_devel - indicador.data_criacao_ou_atendimento_primeira_tarefa_devel).to_i
        end

        if indicador.data_andamento_primeira_tarefa_devel.present? && indicador.data_resolvida_ultima_tarefa_devel.present?
          indicador.tempo_resolucao_devel = (indicador.data_resolvida_ultima_tarefa_devel - indicador.data_andamento_primeira_tarefa_devel).to_i
        end

        if indicador.data_resolvida_ultima_tarefa_devel.present? && indicador.data_fechamento_ultima_tarefa_devel.present?
          indicador.tempo_fechamento_devel = (indicador.data_fechamento_ultima_tarefa_devel - indicador.data_resolvida_ultima_tarefa_devel).to_i
        end

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
          ciclos_qs = SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_qs(tarefas_relacionadas)
          primeiro_ciclo_qs = ciclos_qs.first

          # Processar data de início em andamento QS usando apenas o primeiro ciclo
          data_andamento_qs = nil
          primeiro_ciclo_qs.each do |tarefa|
            if tarefa.data_em_andamento.present?
              data_andamento_qs = tarefa.data_em_andamento
              break
            end
          end
          indicador.data_andamento_primeira_tarefa_qs = data_andamento_qs
          
          # Usar as datas já calculadas pela função obter_lista_tarefas_relacionadas
          indicador.data_resolvida_ultima_tarefa_qs = ultima_tarefa_qs.data_resolvida
          indicador.data_fechamento_ultima_tarefa_qs = ultima_tarefa_qs.data_fechada

          # Calcular tempos QS
          if indicador.data_criacao_primeira_tarefa_qs.present? && indicador.data_andamento_primeira_tarefa_qs.present?
            indicador.tempo_andamento_qs = (indicador.data_andamento_primeira_tarefa_qs - indicador.data_criacao_primeira_tarefa_qs).to_i
          end

          if indicador.data_andamento_primeira_tarefa_qs.present? && indicador.data_resolvida_ultima_tarefa_qs.present?
            indicador.tempo_resolucao_qs = (indicador.data_resolvida_ultima_tarefa_qs - indicador.data_andamento_primeira_tarefa_qs).to_i
          end

          if indicador.data_resolvida_ultima_tarefa_qs.present? && indicador.data_fechamento_ultima_tarefa_qs.present?
            indicador.tempo_fechamento_qs = (indicador.data_fechamento_ultima_tarefa_qs - indicador.data_resolvida_ultima_tarefa_qs).to_i
          end

          # Calcular tempo para encaminhar para QS (apenas no primeiro ciclo)
          if primeiro_ciclo_devel.last.data_resolvida.present? && indicador.data_criacao_primeira_tarefa_qs.present?
            indicador.tempo_para_encaminhar_qs = indicador.data_criacao_primeira_tarefa_qs - primeiro_ciclo_devel.last.data_resolvida
          end

          # Calcular tempo entre conclusão dos testes e liberação da versão
          if indicador.data_resolvida_ultima_tarefa_qs.present? && indicador.data_fechamento_ultima_tarefa_devel.present?
            indicador.tempo_concluido_testes_versao_liberada = (indicador.data_fechamento_ultima_tarefa_devel - indicador.data_resolvida_ultima_tarefa_qs).to_i
          end
        end

        # Determinar o local atual da tarefa
        if tarefas_qs.empty?
          # Se não existe tarefa QS, está no DEVEL
          indicador.local_tarefa = "DEVEL"
        else
          ultima_tarefa_qs = tarefas_qs.last
          if [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK,
              SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(ultima_tarefa_qs.status.name)
            # Se a última tarefa QS está fechada (TESTE_OK_FECHADA ou TESTE_NOK_FECHADA), voltou para DEVEL
            indicador.local_tarefa = "DEVEL"
          else
            # Se existe tarefa QS e não está fechada, está no QS
            indicador.local_tarefa = "QS"
          end
        end

        # Calcular tempo total para liberar versão
        if indicador.data_criacao_ou_atendimento_primeira_tarefa_devel && indicador.data_fechamento_ultima_tarefa_devel
          indicador.tempo_total_liberar_versao = (indicador.data_fechamento_ultima_tarefa_devel - indicador.data_criacao_ou_atendimento_primeira_tarefa_devel).to_i
        end

        # Calcular tempo total de testes
        if indicador.data_criacao_primeira_tarefa_qs && indicador.data_resolvida_ultima_tarefa_qs && 
          [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK,
          SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA].include?(ultima_tarefa_qs.status.name)
          indicador.tempo_total_testes = (indicador.data_resolvida_ultima_tarefa_qs - indicador.data_criacao_primeira_tarefa_qs).to_i
        end

        Rails.logger.info ">>> indicador.save: #{indicador.inspect}"
        indicador.save(validate: false)
      end
    end

    def self.limpar_campos_indicador(indicador)
      Rails.logger.info ">>> Limpando todos os campos do indicador"
      # Campos de DEVEL
      indicador.ultima_tarefa_devel_id = nil
      indicador.tipo_primeira_tarefa_devel = nil
      indicador.status_ultima_tarefa_devel = nil
      indicador.prioridade_primeira_tarefa_devel = nil
      indicador.projeto_primeira_tarefa_devel = nil
      indicador.sprint_primeira_tarefa_devel = nil
      indicador.sprint_ultima_tarefa_devel = nil
      indicador.tempo_estimado_devel = nil
      indicador.tempo_gasto_devel = nil
      indicador.origem_primeira_tarefa_devel = nil
      indicador.skynet_primeira_tarefa_devel = nil
      indicador.qtd_retorno_testes = nil
      indicador.data_criacao_ou_atendimento_primeira_tarefa_devel = nil
      indicador.data_resolvida_ultima_tarefa_devel = nil
      indicador.data_fechamento_ultima_tarefa_devel = nil
      indicador.data_andamento_primeira_tarefa_devel = nil
      indicador.tempo_andamento_devel = nil
      indicador.tempo_resolucao_devel = nil
      indicador.tempo_fechamento_devel = nil
      indicador.tempo_para_encaminhar_qs = nil
      indicador.tempo_total_liberar_versao = nil

      # Campos de QS
      indicador.primeira_tarefa_qs_id = nil
      indicador.ultima_tarefa_qs_id = nil
      indicador.sprint_primeira_tarefa_qs = nil
      indicador.sprint_ultima_tarefa_qs = nil
      indicador.projeto_primeira_tarefa_qs = nil
      indicador.tempo_estimado_qs = nil
      indicador.tempo_gasto_qs = nil
      indicador.status_ultima_tarefa_qs = nil
      indicador.houve_teste_nok = nil
      indicador.data_criacao_primeira_tarefa_qs = nil
      indicador.data_andamento_primeira_tarefa_qs = nil
      indicador.data_resolvida_ultima_tarefa_qs = nil
      indicador.data_fechamento_ultima_tarefa_qs = nil
      indicador.tempo_andamento_qs = nil
      indicador.tempo_resolucao_qs = nil
      indicador.tempo_fechamento_qs = nil
      indicador.tempo_concluido_testes_versao_liberada = nil      
      indicador.tempo_total_testes = nil

      # Campo de localização
      indicador.local_tarefa = nil
    end

    # Método para separar tarefas DEVEL em ciclos de desenvolvimento
    
  end
end
