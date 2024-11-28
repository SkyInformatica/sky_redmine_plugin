module SkyRedminePlugin
  module IssueHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :original_issue_tabs, :issue_tabs

        def issue_tabs
          tabs = original_issue_tabs
          tabs << { name: "fluxo_tarefas", partial: "issues/fluxo_tarefas", label: "Fluxo das tarefas" }
          tabs
        end
      end
    end

    module InstanceMethods
      # Você pode adicionar métodos auxiliares aqui, se necessário
    end
  end
end
