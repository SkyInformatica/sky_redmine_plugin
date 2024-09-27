module SkyRedminePlugin
  module Hooks
    class CriarRetornoTestesViewIssuesHook < Redmine::Hook::ViewListener
      # Esse hook insere um botão ou link na parte de baixo da página de uma tarefa
      render_on :view_issues_show_details_bottom, partial: "issues/criar_retorno_testes_issues"
    end

    class CriarRetornoTestesContextMenuHook < Redmine::Hook::ViewListener
      # Este hook adiciona itens ao menu de contexto
      render_on :view_issues_context_menu_start, partial: "context_menu/criar_retorno_testes_context_menu"
    end
  end
end
