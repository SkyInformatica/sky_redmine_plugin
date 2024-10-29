module SkyRedminePlugin
  module Hooks
    class ControllerHooks < Redmine::Hook::Listener
      def controller_issues_edit_after_save(context = {})
        Rails.logger.info ">>> controller_issues_edit_after_save"
        issue = context[:issue]
        journal = context[:journal]

        # Verifica se o status mudou para 'Em Andamento' e a data de início não está definida
        if issue.status.name == SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO && issue.start_date.nil?
          Rails.logger.info ">>> definindo a data de inicio da tarefa #{issue.id}"
          issue.init_journal(User.current, "Data de início atualizada automaticamente.")
          issue.start_date = Date.today
          issue.save(validate: false)
        end
      end
    end
  end
end
