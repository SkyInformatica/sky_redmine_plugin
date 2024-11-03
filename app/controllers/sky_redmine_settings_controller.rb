class SkyRedmineSettingsController < ApplicationController
  layout "admin"
  before_action :require_admin

  def show
    @settings = Setting.plugin_sky_redmine_plugin
  end

  def update
    settings = params[:settings] || {}
    Setting.plugin_sky_redmine_plugin = settings
    flash[:notice] = l(:notice_successful_update)
    redirect_to action: "show"
  end
end
