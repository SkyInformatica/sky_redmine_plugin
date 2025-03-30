module SkyRedminePlugin
  module Hooks
    class ModelHook < Redmine::Hook::ViewListener
      def after_plugins_loaded(context = {})
        Rails.logger.info ">>> Iniciando configuração do Sky Redmine Plugin via Hook"
        
        # Adicionar o callback after_destroy ao modelo Issue
        Issue.class_eval do
          after_destroy :processar_exclusao_indicador
          
          private
          
          def processar_exclusao_indicador
            Rails.logger.info ">>> processando exclusão da tarefa #{id}"
            SkyRedminePlugin::Indicadores.processar_indicadores(self, true)
          end
        end
        
        Rails.logger.info ">>> Hook configurado com sucesso"
      end
    end
  end
end 