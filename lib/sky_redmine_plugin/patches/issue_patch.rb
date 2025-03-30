module SkyRedminePlugin
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          after_destroy :processar_exclusao_indicador
        end
      end

      private

      def processar_exclusao_indicador
        SkyRedminePlugin::Indicadores.processar_indicadores(self, true)
      end
    end
  end
end 