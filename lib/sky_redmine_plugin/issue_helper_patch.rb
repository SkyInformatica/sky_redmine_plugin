# lib/sky_redmine_plugin/issue_helper_patch.rb
module SkyRedminePlugin
  module IssueHelperPatch
    extend ActiveSupport::Concern

    included do
      def issue_history_tabs
        # Chama o método original para obter as abas existentes
        tabs = super

        # Adiciona a nova aba ao array de abas
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
end

# Aplica o patch ao IssuesHelper
Rails.application.config.to_prepare do
  IssuesHelper.include SkyRedminePlugin::IssueHelperPatch
end
