class IndicadoresController < ApplicationController
  layout "base"
  before_action :find_project, :authorize
  menu_item :indicadores

  helper :sort
  include SortHelper
  helper :issues
  include IssuesHelper
  include Redmine::Pagination

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

    # Buscar as tarefas agrupadas por tipo e status usando os métodos da entidade
    @tarefas_por_tipo = SkyRedmineIndicadores.tarefas_por_tipo(@project, start_date, end_date)
    @tarefas_por_status = SkyRedmineIndicadores.tarefas_por_status(@project, start_date, end_date)

    # Adicionar ordenação
    sort_init "id", "desc"
    sort_update %w(primeira_tarefa_devel_id ultima_tarefa_devel_id status_ultima_tarefa_devel tempo_estimado_devel tempo_gasto_devel)

    # Buscar os registros da tabela SkyRedmineIndicadores com paginação e ordenação
    scope = SkyRedmineIndicadores.por_projeto_e_periodo(@project, start_date, end_date)
    scope = scope.order(sort_clause)

    # Paginação usando o Paginator do Redmine
    @limit = per_page_option
    @indicadores_count = scope.count
    @indicadores_pages = Paginator.new(@indicadores_count, @limit, params[:page])
    @offset = @indicadores_pages.offset
    @indicadores = scope.limit(@limit).offset(@offset)
    @colunas = SkyRedmineIndicadores.column_names
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end
end
