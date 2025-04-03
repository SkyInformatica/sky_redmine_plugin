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
    @periodo = params[:periodo]
    @dados_graficos = IndicadoresService.obter_dados_graficos(@project, @periodo)

    # Adicionar ordenação
    sort_init "id", "desc"
    sort_update %w(primeira_tarefa_devel_id ultima_tarefa_devel_id status_ultima_tarefa_devel tempo_estimado_devel tempo_gasto_devel)

    # Logs para debug da ordenação
    Rails.logger.info "Params de ordenação: #{params[:sort]}, #{params[:order]}"
    Rails.logger.info "Cláusula de ordenação: #{sort_clause}"

    # Buscar os registros da tabela SkyRedmineIndicadores com paginação e ordenação
    scope = @dados_graficos[:scope]
    scope = scope.order(sort_clause)

    # Log da query SQL final
    Rails.logger.info "Query SQL: #{scope.to_sql}"

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
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
