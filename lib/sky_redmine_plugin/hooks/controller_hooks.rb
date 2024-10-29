module SkyRedminePlugin
  module Hooks
    class ControllerHooks < Redmine::Hook::Listener
      def controller_issues_edit_after_save(context = {})
        issue = context[:issue]
        journal = context[:journal]

        # Verifica se o status mudou para 'Em Andamento' e a data de início não está definida
        if issue.status.name == "Em Andamento" && issue.start_date.nil?
          issue.init_journal(User.current, "Data de início atualizada automaticamente.")
          issue.start_date = Date.today
          issue.save(validate: false)
        end
      end
    end
  end
end
