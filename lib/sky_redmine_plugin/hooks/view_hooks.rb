module SkyRedminePlugin
  module Hooks
    class ViewHooks < Redmine::Hook::ViewListener
      # retorno de testes
      render_on :view_issues_show_details_bottom, partial: "issues/retorno_testes_issues"
      #render_on :view_issues_context_menu_start, partial: "context_menu/retorno_testes_context_menu"

      # encaminhar para QS
      #render_on :view_issues_context_menu_start, partial: "context_menu/encaminhar_qs_context_menu"

      # continua na proxima sprint
      #render_on :view_issues_context_menu_start, partial: "context_menu/continua_proxima_sprint_context_menu"
    end
  end
end
