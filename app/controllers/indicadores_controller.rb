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

    # Adicionar ordenação
    sort_init "id", "desc"
    sort_update %w(primeira_tarefa_devel_id ultima_tarefa_devel_id status_ultima_tarefa_devel tempo_estimado_devel tempo_gasto_devel)

    # Buscar os registros da tabela SkyRedmineIndicadores com paginação e ordenação
    @indicadores = SkyRedmineIndicadores.order(sort_clause)
    if start_date && end_date
      @indicadores = @indicadores.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
    @indicadores = @indicadores.paginate(page: params[:page], per_page: 25)
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end
end
