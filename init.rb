begin
  require "whenever"
rescue LoadError
  Rails.logger.error "Whenever gem não está instalada. Por favor, adicione 'gem \"whenever\"' ao Gemfile e execute 'bundle install'"
end

require "redmine"
require File.join(File.dirname(__FILE__), "lib", "sky_redmine_plugin")
require_dependency File.join(File.dirname(__FILE__), "app", "helpers", "fluxo_tarefas_helper")

Redmine::Plugin.register :sky_redmine_plugin do
  name "Sky Redmine plugin"
  author "Maglan Diemer"
  description "Disponibiliza facilitadores para gerir a fluxo de tarefas entre Devel e QS."
  url "https://github.com/SkyInformatica/sky_redmine_plugin"
  author_url "mailto:maglan.diemer@skyinformatica.com.br"
  version "2024.11.03.1"

  # Adicionar configurações do plugin
  settings default: {
    "ultima_execucao" => nil,
    "tarefas_processadas" => 0,
    "hora_execucao" => "18:00",
    "atualizacao_automatica" => false,  # nova configuração
  }, partial: "settings/sky_redmine_settings"

  # Adicionar permissão para administração
  permission :manage_sky_plugin, { sky_redmine_settings: [:show, :update] }, require: :admin
end

ActionView::Base.send :include, FluxoTarefasHelper
