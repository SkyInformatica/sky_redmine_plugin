class IndicadoresV2Controller < ApplicationController
  layout "base"
  before_action :find_project
  before_action :authorize
  menu_item :indicadores_v2

  METABASE_SITE_URL = "https://metabase.skyinformatica.com.br"
  METABASE_SECRET_KEY = "0ea69615468a2ff4859d94bb587f94850e8bf2277c2c0b7bb502a7070bbfb337"

  def index
    Rails.logger.info ">>> IndicadoresV2Controller index"
    payload = {
      :resource => { :dashboard => 4 },
      :params => {},
      :exp => Time.now.to_i + (60 * 10), # 10 minute expiration
    }

    token = JWT.encode(payload, METABASE_SECRET_KEY)

    # Hash com os parâmetros da URL para os filtros editaveis
    # Se colocar no parametro no payload o filtro fica bloqueado.
    url_params = {
      "projeto" => @project.to_s,
    }

    # Hash com os parâmetros do fragment (#)
    fragment_params = {
      "background" => "false",
      "bordered" => "false",
      "titled" => "false",
    }

    # Monta a query string codificando os parâmetros
    query_string = url_params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")

    # Monta o fragment
    fragment_string = fragment_params.map { |k, v| "#{k}=#{v}" }.join("&")

    # Monta a URL final do iframe
    @iframe_url = [
      METABASE_SITE_URL,
      "/embed/dashboard/",
      token,
      "?#{query_string}",
      "##{fragment_string}",
    ].join

    # Monta a URL direta para o Metabase
    @metabase_direct_url = "#{METABASE_SITE_URL}/dashboard/4-redmine-indicadores?projeto=#{CGI.escape(@project.to_s)}"

    Rails.logger.info "#{@iframe_url}"
  end

  private

  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
