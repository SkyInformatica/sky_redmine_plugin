class SkyRedmineSettingsController < ApplicationController
  def show
    Rails.logger.info ">>> Executando SkyRedmineSettingsController#show"
    @ultima_execucao = SkyRedmineIndicadores.maximum(:updated_at)
    @tarefas_processadas = SkyRedmineIndicadores.count
  end

  def update
    # Método vazio, pois não há configurações a serem salvas no momento
  end
end
