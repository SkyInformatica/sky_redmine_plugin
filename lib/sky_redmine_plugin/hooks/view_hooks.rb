# ./lib/sky_redmine_plugin/hooks/view_hooks.rb
module SkyRedminePlugin
  module Hooks
    class ViewHooks < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, partial: "issues/criar_tarefas"
      render_on :view_issues_context_menu_start, partial: "context_menu/criar_tarefas"
      #render_on :view_issues_show_description_bottom, partial: "issues/fluxo_tarefas"
      # Adiciona a aba personalizada na visualização da tarefa
      def helper_issues_show_tabs(context = {})
        context[:tabs] << {
          name: "fluxo_tarefas",
          partial: "issues/fluxo_tarefas",
          label: "Fluxo das tarefas",
        }
      end

      def view_layouts_base_html_head(context = {})
        javascript_include_tag("ocultar_tarefas_relacionadas", plugin: "sky_redmine_plugin")
      end
    end
  end
end
