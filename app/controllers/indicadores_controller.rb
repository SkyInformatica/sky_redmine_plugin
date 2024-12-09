class IndicadoresController < ApplicationController
  unloadable
  before_action :find_project
  before_action :authorize  # Verifica permissões
  menu_item :indicadores

  helper Chartkick::Helper

  def index
    Rails.logger.info ">>>> index indicadores"
    # Definir a data de início para um mês atrás
    start_date = 12.month.ago

    # Filtrar as tarefas do projeto criadas no último mês
    issues = @project.issues.where("created_on >= ?", start_date)

    # Agrupar e contar as tarefas por tipo (tracker)
    @tarefas_por_tipo = issues.group(:tracker_id).count.transform_keys do |tracker_id|
      Tracker.find(tracker_id).name
    end

    # Agrupar e contar as tarefas por status
    @tarefas_por_status = issues.group(:status_id).count.transform_keys do |status_id|
      IssueStatus.find(status_id).name
    end

    Rails.logger.info @tarefas_por_tipo
    Rails.logger.info @tarefas_por_status
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end
end
