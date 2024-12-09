class IndicadoresController < ApplicationController
  unloadable
  before_action :find_project
  before_action :authorize  # Verifica permissões
  menu_item :indicadores

  helper Chartkick::Helper

  def index
    Rails.logger.info ">>>> index indicadores"
    # Definir a data de início para um mês atrás
    start_date = 1.month.ago

    # Filtrar as tarefas do projeto criadas no último mês
    issues = @project.issues.where("created_on >= ?", start_date)

    # Continuar com seu agrupamento e contagem
    @tarefas_por_tipo = issues.group(:tracker_id).count
    @tarefas_por_status = issues.group(:status_id).count

    Rails.logger.info @tarefas_por_tipo
    Rails.logger.info @tarefas_por_status
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end
end
