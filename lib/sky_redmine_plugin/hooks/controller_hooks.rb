module SkyRedminePlugin
  module Hooks
    class ControllerHooks < Redmine::Hook::Listener
      include CriarTarefasHelper
      include FluxoTarefasHelper

      def controller_issues_edit_after_save(context = {})
        Rails.logger.info ">>> controller_issues_edit_after_save"
        issue = context[:issue]
        journal = context[:journal]

        # Verifica se o status foi alterado
        if journal && journal.details.any? { |detail| detail.prop_key == "status_id" }
          # Obtém os IDs dos status antigo e novo
          status_detail = journal.details.find { |detail| detail.prop_key == "status_id" }

          new_status_name = IssueStatus.find_by(id: status_detail.value).name
          Rails.logger.info ">>> controller_issues_edit_after_save"

          # Chama a atualização da data de início se necessário
          verificar_atualizar_data_inicio(issue, new_status_name)

          # Atualiza a tag da tarefa com base no status
          verificar_atualizar_tag(issue, new_status_name)

          # Atualizar o fluxo das tarefas
          verificar_atualizar_fluxo_tarefas(issue, new_status_name)
        end
      end

      def controller_additionals_change_status_after_save(context = {})
        controller_issues_edit_after_save(context)
      end

      private

      # Metodo para atualizar o fluxo das tarefas relacionadas
      def verificar_atualizar_fluxo_tarefas(issue, new_status_name)
        if [SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA, SkyRedminePlugin::Constants::IssueStatus::FECHADA, SkyRedminePlugin::Constants::IssueStatus::TESTE_OK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK].include?(new_status_name)
          atualizar_fluxo_tarefas(issue)
        end
      end

      # Método para atualizar a data de início da tarefa
      def verificar_atualizar_data_inicio(issue, new_status_name)
        # Verifica se o novo status é 'Em Andamento' e a data de início está vazia
        if new_status_name == SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO && issue.start_date.nil?
          issue.start_date = Date.today
          issue.save(validate: false)
        end
      end

      # Método para atualizar a tag da tarefa com base no status
      def verificar_atualizar_tag(issue, new_status_name)
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
