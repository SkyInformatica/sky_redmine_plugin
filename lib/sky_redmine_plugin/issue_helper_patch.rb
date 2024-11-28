# lib/sky_redmine_plugin/issue_helper_patch.rb
module SkyRedminePlugin
  module IssueHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :original_issue_history_tabs, :issue_history_tabs

        def issue_history_tabs
          Rails.logger.info ">>>> SkyRedminePlugin: Método issue_history_tabs patchado com sucesso."
          tabs = original_issue_history_tabs
          tabs << {
            name: "fluxo_tarefas",
            partial: "issues/tabs/fluxo_tarefas",
            label: "Fluxo das tarefas",
          }
          tabs
        end
      end
    end

    module InstanceMethods
      # Métodos auxiliares, se necessário
    end
  end
end
