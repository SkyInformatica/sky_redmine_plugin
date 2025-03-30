class Issue < ActiveRecord::Base
  # ... existing code ...

  after_destroy :processar_exclusao_indicador

  private

  def processar_exclusao_indicador
    SkyRedminePlugin::Indicadores.processar_indicadores(self, true)
  end
end 