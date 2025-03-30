#begin
#  require "whenever"
#rescue LoadError
#  Rails.logger.error "Whenever gem não está instalada. Por favor, adicione 'gem \"whenever\"' ao Gemfile e execute 'bundle install'"
#end
require "redmine"
require "chartkick"
require "groupdate"
require_relative "app/helpers/fluxo_tarefas_helper"
require_relative "lib/sky_redmine_plugin/issue_helper_patch"
require_relative "app/models/sky_redmine_indicadores"
require_relative "lib/sky_redmine_plugin/patches/issue_patch"

Redmine::Plugin.register :sky_redmine_plugin do
  name "Sky Redmine plugin"
  author "Maglan Diemer"
  description "Disponibiliza facilitadores para gerir o fluxo de tarefas entre Devel e QS."
  url "https://github.com/SkyInformatica/sky_redmine_plugin"
  author_url "mailto:maglan.diemer@skyinformatica.com.br"
  version "2025.03.30.1"

  # Adicionar configurações do plugin
  settings default: {
    "ultima_execucao" => nil,
    "tarefas_processadas" => 0,
    "hora_execucao" => "18:00",
    "atualizacao_automatica" => false,  # nova configuração
  }, partial: "settings/sky_redmine_settings"

  # Adicionar permissão para administração
  permission :manage_sky_plugin, { sky_redmine_settings: [:show, :update] }, require: :admin

  # Definindo o módulo do projeto
  project_module :indicadores do
    permission :view_indicadores, { indicadores: [:index] }, public: true
  end

  menu :project_menu,
       :indicadores,
       { controller: "indicadores", action: "index" },
       caption: :label_indicadores,
       after: :activity
end

begin
  require_dependency "issues_helper"
  IssuesHelper.prepend SkyRedminePlugin::IssueHelperPatch
end

ActionView::Base.send :include, FluxoTarefasHelper

# Garantir que nosso patch seja carregado após o additional_tags
Rails.configuration.to_prepare do
  # Aguardar um momento para garantir que o additional_tags foi carregado
  sleep(0.1) if Rails.env.development?
  
  # Incluir nosso patch
  Issue.send(:include, SkyRedminePlugin::Patches::SkyIssuePatch)
end
