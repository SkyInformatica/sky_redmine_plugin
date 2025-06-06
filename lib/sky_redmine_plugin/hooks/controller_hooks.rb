module SkyRedminePlugin
  module Hooks
    class ControllerHooks < Redmine::Hook::Listener
      include CriarTarefasHelper
      include FluxoTarefasHelper

      def controller_issues_bulk_edit_before_save(context = {})
        Rails.logger.info ">>> controller_issues_bulk_edit_before_save"
        issue = context[:issue]
        params = context[:params]

        Rails.logger.info ">>> issue: #{issue.id}"

        new_status_id = context[:params][:issue][:status_id]
        return unless new_status_id.present?
        new_status_name = IssueStatus.find_by(id: new_status_id)&.name
        return unless new_status_name

        Rails.logger.info ">>> new_status_name: #{new_status_name}"
        processar_tarefa(issue, new_status_name)
        SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      end

      def controller_issues_edit_after_save(context = {})
        Rails.logger.info ">>> controller_issues_edit_after_save"
        issue = context[:issue]
        journal = context[:journal]

        # Verifica se o status foi alterado
        if journal && journal.details.any? { |detail| detail.prop_key == "status_id" }
          # Obtém os IDs dos status antigo e novo
          status_detail = journal.details.find { |detail| detail.prop_key == "status_id" }

          new_status_name = IssueStatus.find_by(id: status_detail.value).name
          processar_tarefa(issue, new_status_name)
        end
        SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      end

      def controller_issues_new_after_save(context = {})
        Rails.logger.info ">>> controller_issues_new_after_save"
        issue = context[:issue]
        Rails.logger.info ">>> issue: #{issue.id}"

        # Processar e atualizar SkyRedmineIndicadores
        SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      end

      def controller_additionals_change_status_after_save(context = {})
        controller_issues_edit_after_save(context)
      end

      private

      def processar_tarefa(issue, new_status_name)
        Rails.logger.info ">>> processar tarefa #{issue.id} com status #{new_status_name}"
        # Verifica se o projeto da tarefa está na lista de projetos relevantes, se nao estiver, nao continua o processamento
        if !SkyRedminePlugin::Constants::Projects::TODOS_PROJETOS.include?(issue.project.name)
          return
        end

        # Chama a atualização da data de início se necessário
        atualizar_data_inicio(issue, new_status_name)

        # Atualiza a tag da tarefa com base no status
        atualizar_tag_tarefas_qs(issue, new_status_name)

        # Fechar a tarefa de testes
        fechar_tarefa_qs(issue, new_status_name)

        # Atualizar status tarefa QS na tarefa de desenvolvimento
        atualizar_status_tarefa_qs_tarefa_devel(issue, new_status_name)
      end

      def atualizar_status_tarefa_qs_tarefa_devel(issue, new_status_name)
        if SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(issue.project.name)
          devel_issue = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_origem_desenvolvimento(issue)
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
          copied_to_qs_issue = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_copiada_qs(issue)

          # Se existir uma cópia e seu status for "Teste OK"
          if copied_to_qs_issue
            if copied_to_qs_issue.status == IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::TESTE_OK)
              copied_to_qs_issue.init_journal(User.current, "[SkyRedminePlugin] Tarefa devel fechada")
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
    end
  end
end
