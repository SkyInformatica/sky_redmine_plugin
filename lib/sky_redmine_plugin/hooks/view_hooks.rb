module SkyRedminePlugin
  module Hooks
    class ViewHooks < Redmine::Hook::ViewListener
      # retorno de testes
      render_on :view_issues_show_details_bottom, partial: "issues/criar_tarefas"
      render_on :view_issues_context_menu_start, partial: "context_menu/criar_tarefas"

      # encaminhar para QS
      #render_on :view_issues_context_menu_start, partial: "context_menu/encaminhar_qs_context_menu"

      # continua na proxima sprint
      #render_on :view_issues_context_menu_start, partial: "context_menu/continua_proxima_sprint_context_menu"
    end
  end
end
