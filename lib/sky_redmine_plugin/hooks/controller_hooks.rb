module SkyRedminePlugin
  module Hooks
    class ControllerHooks < Redmine::Hook::Listener
      include CriarTarefasHelper
      include FluxoTarefasHelper
      include TarefasRelacionadasHelper

      def controller_issues_edit_after_save(context = {})
        Rails.logger.info ">>> controller_issues_edit_after_save"
        issue = context[:issue]
        journal = context[:journal]

        # Verifica se o status foi alterado
        if journal && journal.details.any? { |detail| detail.prop_key == "status_id" }
          # Obtém os IDs dos status antigo e novo
          status_detail = journal.details.find { |detail| detail.prop_key == "status_id" }

          new_status_name = IssueStatus.find_by(id: status_detail.value).name

          # Processar e atualizar SkyRedmineIndicadores
          processar_indicadores(issue)

          # Chama a atualização da data de início se necessário
          atualizar_data_inicio(issue, new_status_name)

          # Atualiza a tag da tarefa com base no status
          atualizar_tag_tarefas_qs(issue, new_status_name)

          # Fechar a tarefa de testes
          fechar_tarefa_qs(issue, new_status_name)

          # Atualizar status tarefa QS na tarefa de desenvolvimento
          atualizar_status_tarefa_qs_tarefa_devel(issue, new_status_name)
        end
      end

      def controller_issues_new_after_save(context = {})
        issue = context[:issue]

        # Processar e atualizar SkyRedmineIndicadores
        processar_indicadores(issue)
      end

      def controller_additionals_change_status_after_save(context = {})
        controller_issues_edit_after_save(context)
      end

      private

      def atualizar_status_tarefa_qs_tarefa_devel(issue, new_status_name)
        if SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(issue.project.name)
          devel_issue = localizar_tarefa_origem_desenvolvimento(issue)
          if devel_issue
            if custom_field = IssueCustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::TESTE_QS)
              devel_issue.custom_field_values = { custom_field.id => new_status_name }
              devel_issue.save
            end
          end
        end
      end

      # Metodo para fechar a tarefa de testes
      def fechar_tarefa_qs(issue, new_status_name)
        if new_status_name == SkyRedminePlugin::Constants::IssueStatus::FECHADA
          # Localizar uma cópia da tarefa nos projetos QS
          copied_to_qs_issue = localizar_tarefa_copiada_qs(issue)

          # Se existir uma cópia e seu status for "Teste OK"
          if copied_to_qs_issue
            if copied_to_qs_issue.status == IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::TESTE_OK)
              copied_to_qs_issue.status = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA)
              copied_to_qs_issue.tag_list = []
              copied_to_qs_issue.save(validate: false)

              if custom_field = IssueCustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::TESTE_QS)
                issue.custom_field_values = { custom_field.id => SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA }
                issue.save(validate: false)
              end
            end
          end
        end
      end

      # Método para atualizar a data de início da tarefa
      def atualizar_data_inicio(issue, new_status_name)
        # Verifica se o novo status é 'Em Andamento' e a data de início está vazia
        if new_status_name == SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO && issue.start_date.nil?
          issue.start_date = Date.today
          issue.save(validate: false)
        end
      end

      # Método para atualizar a tag da tarefa com base no status
      def atualizar_tag_tarefas_qs(issue, new_status_name)
        # Verifica se o novo status é 'Teste NOK' ou 'Teste OK'
        nova_tag_sufixo = case new_status_name
          when SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK
            SkyRedminePlugin::Constants::Tags::REVER
          when SkyRedminePlugin::Constants::IssueStatus::TESTE_OK
            SkyRedminePlugin::Constants::Tags::PRONTO
          else
            return # Se não for nenhum dos status, não faz nada
          end

        # Obtém a lista de sufixos automatizados
        sufixos_automatizados = SkyRedminePlugin::Constants::Tags::TODAS_TAGS_AUTOMATIZADAS

        # Inicializa a variável para armazenar o prefixo
        prefixo = nil

        # Procura por tags que terminem com os sufixos automatizados e obtém o prefixo
        issue.tag_list = issue.tag_list.reject do |tag|
          sufixo_encontrado = sufixos_automatizados.find { |sufixo| tag.end_with?(sufixo) }
          if sufixo_encontrado
            # Extrai o prefixo (parte antes do sufixo)
            prefixo = tag[0...-sufixo_encontrado.length]
            true # Remove a tag
          else
            false # Mantém a tag
          end
        end

        # Se não foi encontrado um prefixo
        return if prefixo.nil?

        # Constrói a nova tag com o mesmo prefixo e o novo sufixo
        nova_tag = "#{prefixo}#{nova_tag_sufixo}"

        # Adiciona a nova tag ao issue
        issue.tag_list.add(nova_tag)

        # Salva o issue sem validações
        issue.save(validate: false)
      end

      def processar_indicadores(issue)
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
end
