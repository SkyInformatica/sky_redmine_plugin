require File.expand_path(File.dirname(__FILE__) + "/../../../config/environment")

set :environment, Rails.env
set :output, "log/cron.log"

settings = Setting.plugin_sky_redmine_plugin
if settings["atualizacao_automatica"] == "1"
  hora_execucao = settings["hora_execucao"] || "18:00"

  every 1.day, at: hora_execucao do
    rake "sky_redmine:process_tasks"
  end
end
