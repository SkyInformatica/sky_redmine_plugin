# lib/sky_redmine_plugin/issue_helper_patch.rb

Rails.logger.info "SkyRedminePlugin: Carregando IssueHelperPatch"

module SkyRedminePlugin
  Rails.logger.info "SkyRedminePlugin: No módulo SkyRedminePlugin"

  module IssueHelperPatch
    Rails.logger.info "SkyRedminePlugin: Definindo IssueHelperPatch"

    def self.prepended(base)
      Rails.logger.info "SkyRedminePlugin: IssueHelperPatch foi prepended ao IssuesHelper"
    end

    def issue_history_tabs
      Rails.logger.info "SkyRedminePlugin: Chamando issue_history_tabs personalizado"
      tabs = super
      tabs << {
        name: "fluxo_tarefas",
        partial: "issues/tabs/fluxo_tarefas",
        label: "Fluxo das tarefas",
        locals: { issue: @issue },
      }
      tabs
    end
  end
end
