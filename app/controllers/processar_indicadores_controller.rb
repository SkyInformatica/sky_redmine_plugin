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
    redirect_to sky_redmine_settings_path
  end

  def limpar_tags_2024
    Rails.logger.info ">>> Iniciando limpeza de tags SkyRP_ a partir de 2024"
    
    # Buscar todos os projetos relevantes
    projetos = SkyRedminePlugin::Constants::Projects::REGISTRAL_PROJECTS + 
               SkyRedminePlugin::Constants::Projects::NOTARIAL_PROJECTS +
               SkyRedminePlugin::Constants::Projects::QS_PROJECTS

    # Buscar todas as tarefas dos projetos a partir de 2024
    issues = Issue.where(project_id: Project.where(name: projetos).pluck(:id))
                  .where("created_on >= ?", Date.new(2024, 1, 1))

    total_issues = issues.count
    Rails.logger.info ">>> Total de tarefas encontradas: #{total_issues}"

    issues.each do |issue|
      begin
        # Verificar se a tarefa tem tags
        if issue.respond_to?(:tag_list)
          tags_atuais = issue.tag_list.dup
          
          # Filtrar apenas as tags que começam com SkyRP_
          tags_skyrp = tags_atuais.select { |tag| tag.start_with?("SkyRP_") }
          
          if tags_skyrp.any?
            # Remover as tags SkyRP_
            tags_filtradas = tags_atuais.reject { |tag| tag.start_with?("SkyRP_") }
            
            # Atualizar as tags da tarefa
            issue.tag_list = tags_filtradas
            issue.save(validate: false)
            
            Rails.logger.info ">>> Tarefa #{issue.id}: removidas tags #{tags_skyrp.join(', ')}"
          end
        end
      rescue => e
        Rails.logger.error ">>> Erro ao processar tarefa #{issue.id}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end

    flash[:notice] = "Tags SkyRP_ das tarefas criadas a partir de 2024 foram removidas com sucesso."
    redirect_to sky_redmine_settings_path
  end
end
