class ProcessarIndicadoresController < ApplicationController
  @@progresso_indicadores = { total: 0, processados: 0 }

  before_action :find_issues, only: [:processar_indicadores_lote]
  before_action :find_issue, only: [:processar_indicadores_tarefa]

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

  def processar_indicadores_tarefa
    Rails.logger.info ">>> processar_indicadores_tarefa #{@issue.id}"
    SkyRedminePlugin::Indicadores.processar_indicadores(@issue)

    flash[:notice] = "Indicadores da tarefa ##{@issue.id} foram processados com sucesso."
    redirect_to issue_path(@issue)
  end

  def limpar_indicadores
    SkyRedmineIndicadores.delete_all
    flash[:notice] = "Todos os indicadores foram limpos com sucesso."
    redirect_to sky_redmine_settings # Altere para a rota de configuração do plugin
  end

  def processar_indicadores_2024
    projetos = SkyRedminePlugin::Constants::Projects::REGISTRAL_PROJECTS + SkyRedminePlugin::Constants::Projects::NOTARIAL_PROJECTS
    ProcessarIndicadoresJob.perform_later(projetos, 2024)

    flash[:notice] = "O processamento foi iniciado. Você pode acompanhar o progresso."
    redirect_to sky_redmine_settings
  end

  def self.progresso_indicadores
    @@progresso_indicadores
  end
end
