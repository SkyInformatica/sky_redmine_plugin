class ProcessarIndicadoresController < ApplicationController
  unloadable

  def processar_indicadores_lote
    issue_ids = params[:issue_ids]
    issues = Issue.where(id: issue_ids)

    issues.each do |issue|
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    end

    respond_to do |format|
      format.js
    end
  end
end
