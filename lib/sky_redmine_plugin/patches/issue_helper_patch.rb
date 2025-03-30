module SkyRedminePlugin
  module Patches
    module IssueHelperPatch
      def issue_history_tabs
        tabs = super
        # Adiciona a aba "Fluxo das tarefas" como primeira aba
        tabs.unshift({
          name: "fluxo_tarefas",
          partial: "issues/tabs/fluxo_tarefas",
          label: :label_fluxo_tarefas,
          locals: { issue: @issue },
        })

        # Adiciona a aba "Subtarefas"
        tabs << {
          name: "subtarefas",
          partial: "issues/tabs/subtarefas",
          label: :label_subtarefas,
        }

        # Adiciona a aba "Tarefas Relacionadas"
        tabs << {
          name: "tarefas_relacionadas",
          partial: "issues/tabs/tarefas_relacionadas",
          label: :label_tarefas_relacionadas,
        }

        tabs
      end
    end
  end
end 