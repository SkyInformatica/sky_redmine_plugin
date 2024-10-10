module SkyRedminePlugin
  module Hooks
    class RetornoTestesContextMenuHook < Redmine::Hook::ViewListener
      # retorno de testes

      #render_on :view_issues_context_menu_start, partial: "context_menu/retorno_testes_context_menu"
    end
  end
end
