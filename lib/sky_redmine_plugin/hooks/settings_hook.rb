module SkyRedminePlugin
  module Hooks
    class SettingsHook < Redmine::Hook::ViewListener
      def controller_settings_plugin_before_render(context = {})
        if context[:plugin].id == :sky_redmine_plugin
          context[:controller].instance_variable_set(:@ultima_execucao, SkyRedmineIndicadores.maximum(:updated_at))
          context[:controller].instance_variable_set(:@tarefas_processadas, SkyRedmineIndicadores.count)
        end
      end
    end
  end
end
