class IndicadoresV2Controller < ApplicationController
  layout "base"
  before_action :find_project
  before_action :authorize
  menu_item :indicadores_v2

  def index
    payload = {
      :resource => { :dashboard => 4 },
      :params => {},
      :exp => Time.now.to_i + (60 * 10), # 10 minute expiration
    }

    token = JWT.encode(payload, SkyRedminePlugin::MetabaseConfig::SECRET_KEY)
    @iframe_url = "#{SkyRedminePlugin::MetabaseConfig::SITE_URL}/embed/dashboard/#{token}#bordered=true&titled=true"
  end

  private

  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
