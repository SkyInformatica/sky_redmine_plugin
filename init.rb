require "redmine"
require File.join(File.dirname(__FILE__), "lib", "sky_redmine_plugin")
require_dependency File.join(File.dirname(__FILE__), "app", "helpers", "fluxo_tarefas_helper")

Redmine::Plugin.register :sky_redmine_plugin do
  name "Sky Redmine plugin"
  author "Maglan Diemer"
  description "Disponibiliza facilitadores para gerir a fluxo de tarefas entre Devel e QS."
  url "https://github.com/SkyInformatica/sky_redmine_plugin"
  author_url "mailto:maglan.diemer@skyinformatica.com.br"
  version "2024.11.01.1"

  assets_directory = File.join(__dir__, "assets")
  directories = [assets_directory]
  directories.each do |dir|
    Redmine::Plugin::registered_plugins[:sky_redmine_plugin].assets_paths << dir
  end
end

ActionView::Base.send :include, FluxoTarefasHelper
