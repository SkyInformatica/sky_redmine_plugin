module SkyRedminePlugin
  module Hooks
    class ControllerHooks < Redmine::Hook::Listener
      def controller_issues_edit_after_save(context = {})
        issue = context[:issue]

        # Atualiza a data de início, se necessário
        atualizar_data_inicio(issue)

        # Atualiza a tag da tarefa com base no status
        atualizar_tag(issue)
      end

      def controller_additionals_change_status_after_save(context = {})
        controller_issues_edit_after_save(context)
      end

      private

      # Método para atualizar a data de início da tarefa
      def atualizar_data_inicio(issue)
        if issue.status.name == SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO && issue.start_date.nil?
          issue.start_date = Date.today
          issue.save(validate: false)
        end
      end

      # Método para atualizar a tag da tarefa com base no status
      def atualizar_tag(issue)
        status = issue.status.name

        # Verifica se o status é 'Teste NOK' ou 'Teste OK'
        nova_tag_sufixo = case status
          when SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK
            "_REVER"
          when SkyRedminePlugin::Constants::IssueStatus::TESTE_OK
            "_PRONTO"
          else
            return # Se não for nenhum dos status, não faz nada
          end

        # Obtém as tags atuais da tarefa
        tags = issue.tags.map(&:name)

        # Encontra a tag que termina com '_TESTAR'
        tag_atual = tags.find { |tag| tag.end_with?("_TESTAR") }

        # Se não encontrar a tag, não faz nada
        return unless tag_atual

        # Substitui o sufixo '_TESTAR' pela nova tag
        nova_tag = tag_atual.sub("_TESTAR", nova_tag_sufixo)

        # Remove a tag antiga e adiciona a nova
        issue.tags.delete(Tag.find_by(name: tag_atual))
        issue.tags << Tag.find_or_create_by(name: nova_tag)

        # Salva a tarefa sem validações
        issue.save(validate: false)
      end
    end
  end
end
