=begin class SkyRedmineSettingsController < ApplicationController
  layout "admin"
  before_action :require_admin

  def show
    @settings = Setting.plugin_sky_redmine_plugin
  end

  def update
    settings = params[:settings] || {}
    old_settings = Setting.plugin_sky_redmine_plugin

    Setting.plugin_sky_redmine_plugin = settings

    # Verifica mudança no status da atualização automática
    old_auto_update = old_settings["atualizacao_automatica"] == "1"
    new_auto_update = settings["atualizacao_automatica"] == "1"

    if old_auto_update != new_auto_update
      if new_auto_update
        update_crontab
      else
        clear_crontab
      end
    elsif new_auto_update && old_settings["hora_execucao"] != settings["hora_execucao"]
      # Se só o horário mudou e está ativo, atualiza o crontab
      update_crontab
    end

    flash[:notice] = l(:notice_successful_update)
    redirect_to action: "show"
  end

  private

  def update_crontab
    begin
      rails_root = Rails.root
      plugin_path = File.join(rails_root, "plugins", "sky_redmine_plugin")

      Dir.chdir(rails_root) do
        success = system("bundle exec whenever --update-crontab --load-file #{plugin_path}/config/schedule.rb")
        unless success
          raise "Falha ao executar whenever"
        end
      end

      flash[:notice] = l(:notice_successful_update) + " Agendamento atualizado com sucesso."
    rescue => e
      Rails.logger.error "Erro ao atualizar crontab: #{e.message}"
      flash[:error] = "Configurações salvas, mas houve um erro ao atualizar o agendamento: #{e.message}"
    end
  end

  def clear_crontab
    begin
      Dir.chdir(Rails.root) do
        success = system("bundle exec whenever --clear-crontab")
        unless success
          raise "Falha ao limpar whenever"
        end
      end

      flash[:notice] = l(:notice_successful_update) + " Agendamento removido com sucesso."
    rescue => e
      Rails.logger.error "Erro ao limpar crontab: #{e.message}"
      flash[:error] = "Configurações salvas, mas houve um erro ao remover o agendamento: #{e.message}"
    end
  end
end
 =end