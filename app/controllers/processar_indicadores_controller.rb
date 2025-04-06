class ProcessarIndicadoresController < ApplicationController
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
    issues = Issue.where(project_id: Project.where(name: projetos).pluck(:id))
                  .where("created_on >= ?", Date.new(2024, 1, 1))

    issues.each do |issue|
      Rails.logger.info ">>> processando tarefa #{issue.id}"
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    end

    flash[:notice] = "Indicadores das tarefas criadas a partir de 2024 foram processados com sucesso."
    redirect_to admin_plugins_path
  end

  def limpar_tags_skyrp
    Rails.logger.info ">>> Iniciando limpeza de todas as tags SkyRP_"
    
    # Buscar todas as tags que começam com SkyRP_
    tags_skyrp = ActsAsTaggableOn::Tag.where("name LIKE ?", "SkyRP_%")
    
    if tags_skyrp.any?
      Rails.logger.info ">>> Encontradas #{tags_skyrp.count} tags SkyRP_ para remover"
      
      # Remover as tags de todas as tarefas
      tags_skyrp.each do |tag|
        begin
          # Remover a tag de todas as tarefas que a possuem
          tag.taggings.destroy_all
          # Excluir a tag da tabela de tags
          tag.destroy
          Rails.logger.info ">>> Tag #{tag.name} removida com sucesso"
        rescue => e
          Rails.logger.error ">>> Erro ao remover tag #{tag.name}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end

    flash[:notice] = "Todas as tags SkyRP_ foram removidas com sucesso."
    redirect_to admin_plugins_path
  end
end
