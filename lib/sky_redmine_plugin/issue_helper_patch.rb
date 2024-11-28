# lib/sky_redmine_plugin/issue_helper_patch.rb
module SkyRedminePlugin
  module IssueHelperPatch
    def issue_history_tabs
      Rails.logger.info "SkyRedminePlugin: Chamando issue_history_tabs com prepend"
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

Rails.application.config.to_prepare do
  Rails.logger.info "SkyRedminePlugin: Usando prepend para IssueHelperPatch"
  IssuesHelper.prepend SkyRedminePlugin::IssueHelperPatch
end

Rails.configuration.to_prepare do
  Rails.logger.info "SkyRedminePlugin: Usando include para IssueHelperPatch"
  IssuesHelper.include SkyRedminePlugin::IssueHelperPatch
end
