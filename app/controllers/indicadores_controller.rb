class IndicadoresController < ApplicationController
  layout "base"
  before_action :find_project, :authorize
  menu_item :indicadores

  def index
    # Determinar o período com base no parâmetro recebido
    case params[:periodo]
    when "current_month"
      start_date = Date.current.beginning_of_month
      end_date = Date.current.end_of_month
    when "last_month"
      start_date = (Date.current - 1.month).beginning_of_month
      end_date = (Date.current - 1.month).end_of_month
    when "current_year"
      start_date = Date.current.beginning_of_year
      end_date = Date.current.end_of_year
    else
      start_date = nil
      end_date = nil
    end

    # Filtrar as tarefas com base no período selecionado
    issues = @project.issues
    if start_date && end_date
      issues = issues.where(created_on: start_date..end_date)
    end

    # Agrupar e contar as tarefas por tipo (tracker)
    @tarefas_por_tipo = issues.group(:tracker_id).count.transform_keys do |tracker_id|
      Tracker.find(tracker_id).name
    end

    # Agrupar e contar as tarefas por status
    @tarefas_por_status = issues.group(:status_id).count.transform_keys do |status_id|
      IssueStatus.find(status_id).name
    end

    # **Buscar os registros da tabela SkyRedmineIndicadores**
    @indicadores = SkyRedmineIndicadores.all

    # Caso queira filtrar pelo período selecionado
    if start_date && end_date
      @indicadores = @indicadores.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end
end
