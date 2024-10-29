module SkyRedminePlugin
  module Hooks
    class ControllerHooks < Redmine::Hook::Listener
      include CriarTarefasHelper

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
        # Verifica se o status é 'Teste NOK' ou 'Teste OK'
        nova_tag_sufixo = case issue.status.name
          when SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK
            SkyRedminePlugin::Constants::Tags::REVER
          when SkyRedminePlugin::Constants::IssueStatus::TESTE_OK
            SkyRedminePlugin::Constants::Tags::PRONTO
          else
            return # Se não for nenhum dos status, não faz nada
          end

        # removendo as tags de controle automatizado para deixar somente a tag REVER ou PRONTO
        issue.tag_list = issue.tag_list.reject do |tag|
          SkyRedminePlugin::Constants::Tags::TODAS_TAGS_AUTOMATIZADAS.any? { |sufixo| tag.end_with?(sufixo) }
        end

        issue.tag_list.add(obter_nome_tag(issue, nova_tag_sufixo))
        issue.save(validate: false)
      end
    end
  end
end
