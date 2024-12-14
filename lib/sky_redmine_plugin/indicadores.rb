module SkyRedminePlugin
  class Indicadores
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
        indicador.status_ultima_tarefa_devel = ultima_tarefa_devel.status.name
        indicador.prioridade_primeira_tarefa_devel = primeira_tarefa_devel.priority.id
        indicador.sprint_primeira_tarefa_devel_id = primeira_tarefa_devel.fixed_version_id
        indicador.sprint_ultima_tarefa_devel_id = ultima_tarefa_devel.fixed_version_id
        indicador.projeto_primeira_tarefa_devel_id = primeira_tarefa_devel.project_id
        indicador.tempo_estimado_devel = tarefas_devel.sum { |t| t.estimated_hours.to_f }
        indicador.tempo_gasto_devel = tarefas_devel.sum { |t| t.spent_hours.to_f }
        indicador.origem_primeira_tarefa_devel = obter_valor_campo_personalizado(primeira_tarefa_devel, "Origem")
        indicador.skynet_primeira_tarefa_devel = obter_valor_campo_personalizado(primeira_tarefa_devel, "Sky.NET")
        indicador.local_tarefa = tarefas_qs.empty? ? "DEVEL" : "QS"
        indicador.qtd_retorno_testes = tarefas_relacionadas.count { |t| t.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES }
        indicador.data_atendimento_primeira_tarefa_devel = obter_valor_campo_personalizado(primeira_tarefa_devel, "Data de Atendimento") || primeira_tarefa_devel.created_on.to_date
        indicador.data_andamento_primeira_tarefa_devel = obter_data_mudanca_status(primeira_tarefa_devel, [SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO]) || primeira_tarefa_devel.created_on.to_date
        indicador.data_resolvida_ultima_tarefa_devel = obter_data_mudanca_status(ultima_tarefa_devel, [SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA])
        indicador.data_fechamento_ultima_tarefa_devel = obter_data_mudanca_status(ultima_tarefa_devel, [SkyRedminePlugin::Constants::IssueStatus::FECHADA])

        # Processar dados QS
        unless tarefas_qs.empty?
          primeira_tarefa_qs = tarefas_qs.first
          ultima_tarefa_qs = tarefas_qs.last

          indicador.primeira_tarefa_qs_id = primeira_tarefa_qs.id
          indicador.ultima_tarefa_qs_id = ultima_tarefa_qs.id
          indicador.sprint_primeira_tarefa_qs_id = primeira_tarefa_qs.fixed_version_id
          indicador.sprint_ultima_tarefa_qs_id = ultima_tarefa_qs.fixed_version_id
          indicador.projeto_primeira_tarefa_qs_id = primeira_tarefa_qs.project_id
          indicador.tempo_estimado_qs = tarefas_qs.sum { |t| t.estimated_hours.to_f }
          indicador.tempo_gasto_qs = tarefas_qs.sum { |t| t.spent_hours.to_f }
          indicador.status_ultima_tarefa_qs = ultima_tarefa_qs.status.name
          indicador.houve_teste_nok = tarefas_qs.any? { |t| [SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(t.status.name) }
          indicador.data_criacao_primeira_tarefa_qs = primeira_tarefa_qs.created_on.to_date
          indicador.data_andamento_primeira_tarefa_qs = obter_data_mudanca_status(primeira_tarefa_qs, [SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO]) || primeira_tarefa_qs.created_on.to_date
          indicador.data_resolvida_ultima_tarefa_qs = obter_data_mudanca_status(ultima_tarefa_qs, [SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA])
          indicador.data_fechamento_ultima_tarefa_qs = obter_data_mudanca_status(ultima_tarefa_qs, [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA])
        end

        indicador.save(validate: false)
      end
    end

    private

    # Método para obter o valor de um campo personalizado
    def obter_valor_campo_personalizado(issue, field_name)
      custom_field = issue.custom_field_values.detect { |cf| cf.custom_field.name == field_name }
      custom_field ? custom_field.value : nil
    end

    # Método existente para obter data de mudança de status
    def obter_data_mudanca_status(tarefa, status_nomes)
      status_ids = IssueStatus.where(name: status_nomes).pluck(:id)

      journal = tarefa.journals.joins(:details)
                      .where(journal_details: { property: "attr", prop_key: "status_id", value: status_ids })
                      .order("created_on ASC")
                      .first

      journal&.created_on&.to_date
    end
  end
end
