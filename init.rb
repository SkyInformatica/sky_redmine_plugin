require "redmine"

require_dependency "sky_redmine_plugin/hooks/view_hooks"
require_dependency "sky_redmine_plugin/hooks/controller_hooks"

require_dependency "app/helpers/fluxo_tarefas_helper"

Redmine::Plugin.register :sky_redmine_plugin do
  name "Sky Redmine plugin"
  author "Maglan Diemer"
  description "Disponibiliza facilitadores para gerir as tarefas do QS."
  url "https://github.com/SkyInformatica/sky_redmine_plugin"
  author_url "mailto:maglan.diemer@skyinformatica.com.br"
  version "2024.11.01.1"
end

ActionView::Base.send :include, FluxoTarefasHelper
