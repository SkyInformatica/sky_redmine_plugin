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
        indicador.qtd_retorno_testes = tarefas_relacionadas.count { |t| t.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES }
        
        data_atendimento = obter_valor_campo_personalizado(primeira_tarefa_devel, "Data de Atendimento")
        indicador.data_atendimento_primeira_tarefa_devel = data_atendimento
        indicador.data_criacao_ou_atendimento_primeira_tarefa_devel = data_atendimento || primeira_tarefa_devel.created_on.to_date
        
        indicador.data_andamento_primeira_tarefa_devel = obter_data_mudanca_status(primeira_tarefa_devel, [SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO]) || primeira_tarefa_devel.created_on.to_date
        
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
          indicador.data_andamento_primeira_tarefa_qs = obter_data_mudanca_status(primeira_tarefa_qs, [SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO]) || primeira_tarefa_qs.created_on.to_date
          
          # Processar datas de resolução e fechamento QS
          data_fechamento_qs = obter_data_mudanca_status(ultima_tarefa_qs, [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA])
          data_resolucao_qs = obter_data_mudanca_status(ultima_tarefa_qs, [SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA])
          
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
  end
end
