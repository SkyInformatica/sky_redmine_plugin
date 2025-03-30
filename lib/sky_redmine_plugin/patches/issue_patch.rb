module SkyRedminePlugin
  module Patches
    module SkyIssuePatch
      #def self.included(base)
      #  base.class_eval do
      #    after_destroy :processar_exclusao_indicador
      #  end
      #end

      private

      def processar_exclusao_indicador
        Rails.logger.info ">>> processando exclusão da tarefa #{id}"
        SkyRedminePlugin::Indicadores.processar_indicadores(self, true)
      end
    end
  end
end 