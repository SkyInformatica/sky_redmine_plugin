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
    @iframe_url = "#{METABASE_SITE_URL}/embed/dashboard/#{token}#bordered=true&titled=false?projeto=#{@project}"
    Rails.logger.info "#{@iframe_url}"
  end

  private

  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
