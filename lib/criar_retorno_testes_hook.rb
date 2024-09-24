class CriarRetornoTestesHook < Redmine::Hook::ViewListener
  # Esse hook insere um botão ou link na parte de baixo da página de uma tarefa
  render_on :view_issues_show_details_bottom, partial: "issues/criar_retorno_testes_button"

  def view_layouts_base_html_head(context = {})
    javascript_include_tag("sky_redmine_plugin_context_menu", :plugin => "sky_redmine_plugin")
  end
end
