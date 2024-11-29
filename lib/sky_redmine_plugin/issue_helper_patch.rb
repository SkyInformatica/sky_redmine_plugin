# lib/sky_redmine_plugin/issue_helper_patch.rb
module SkyRedminePlugin
  module IssueHelperPatch
    def issue_history_tabs
      Rails.logger.info "SkyRedminePlugin: Chamando issue_history_tabs personalizado"
      tabs = super
      tabs << {
        name: "fluxo_tarefas",
        partial: "issues/tabs/fluxo_tarefas",
        label: :label_fluxo_tarefas,
        locals: { issue: @issue },
      }

      # Adiciona a aba "Tarefas Relacionadas"
      tabs << {
        name: "tarefas_relacionadas",
        partial: "issues/tabs/tarefas_relacionadas",
        label: :label_tarefas_relacionadas,
      #locals: { issue: @issue },
      }

      tabs
    end
  end
end
