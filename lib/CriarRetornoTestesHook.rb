class CriarRetornoTestesController < Redmine::Hook::ViewListener
  # Esse hook insere um botão ou link na parte de baixo da página de uma tarefa
  render_on :view_issues_show_details_bottom, partial: "issues/CriarRetornoTestesButton"
end
