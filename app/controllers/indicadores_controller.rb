class IndicadoresController < ApplicationController
  layout "base"
  before_action :find_project
  before_action :authorize
  menu_item :indicadores

  helper :sort
  include SortHelper
  helper :issues
  include IssuesHelper
  include Redmine::Pagination

  def index
    @periodo = params[:periodo] || "all"
    @equipe = params[:equipe] || "all"
    @start_date = nil
    @end_date = nil

    case @periodo
    when "current_month"
      @start_date = Date.current.beginning_of_month
      @end_date = Date.current.end_of_month
    when "last_month"
      @start_date = (Date.current - 1.month).beginning_of_month
      @end_date = (Date.current - 1.month).end_of_month
    when "current_year"
      @start_date = Date.current.beginning_of_year
      @end_date = Date.current.end_of_year
    end

    tarefas_projeto = SkyRedmineIndicadores.por_projeto(@project)
    tarefas_projeto_periodo = SkyRedmineIndicadores.tarefas_por_periodo(tarefas_projeto, @start_date, @end_date)

    @dados_graficos = IndicadoresService.obter_dados_graficos(tarefas_projeto_periodo, @equipe)
    @dados_graficos_etapas = IndicadoresService.obter_dados_graficos_etapas(tarefas_projeto)

    # Adicionar ordenação
    sort_init "id", "desc"
    sort_update %w(id_tarefa id_ultima_tarefa status tempo_estimado tempo_gasto)

    # Logs para debug da ordenação
    Rails.logger.info "Params de ordenação: #{params[:sort]}, #{params[:order]}"
    Rails.logger.info "Cláusula de ordenação: #{sort_clause}"

    # Buscar os registros da tabela SkyRedmineIndicadores com paginação e ordenação
    tarefas_listagem = tarefas_projeto_periodo.order(sort_clause)

    # Paginação usando o Paginator do Redmine
    @limit = per_page_option
    @indicadores_count = tarefas_listagem.count
    @indicadores_pages = Paginator.new(@indicadores_count, @limit, params[:page])
    @offset = @indicadores_pages.offset
    @indicadores = tarefas_listagem.limit(@limit).offset(@offset)
    @colunas = SkyRedmineIndicadores.column_names
  end

  private

  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
