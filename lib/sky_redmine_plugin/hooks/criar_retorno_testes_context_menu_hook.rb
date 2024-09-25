module SkyRedminePlugin
  module Hooks
    class CriarRetornoTestesContextMenuHook < Redmine::Hook::ViewListener
      # Este hook adiciona itens ao menu de contexto
      render_on :view_issues_context_menu_start, partial: "context_menu/criar_retorno_testes_context_menu"
    end
  end
end
