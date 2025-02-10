class ProcessarIndicadoresController < ApplicationController
  before_action :find_issues, only: [:processar_indicadores_lote]

  def processar_indicadores_lote
    Rails.logger.info ">>> processar_indicadores_lote"
    @issue_ids = params[:ids]

    @issues.each do |issue|
      Rails.logger.info ">>> processando tarefa #{issue.id}"
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    end

    respond_to do |format|
      format.js
    end
  end

  def limpar_indicadores
    SkyRedmineIndicadores.delete_all
    flash[:notice] = "Todos os indicadores foram limpos com sucesso."
    redirect_to plugin_settings_path # Altere para a rota de configuração do plugin
  end
end
