# ./lib/sky_redmine_plugin/hooks/view_hooks.rb
module SkyRedminePlugin
  module Hooks
    class ViewHooks < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, partial: "issues/criar_tarefas"
      render_on :view_issues_context_menu_start, partial: "context_menu/criar_tarefas"
    end
  end
end
