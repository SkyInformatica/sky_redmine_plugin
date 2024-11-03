namespace :sky_redmine do
  desc "Processa tarefas atualizadas e envia para BigQuery"
  task process_tasks: :environment do
    settings = Setting.plugin_sky_redmine_plugin
    ultima_execucao = settings["ultima_execucao"]&.to_time || Time.now - 1.day

    # Buscar tarefas atualizadas desde a última execução
    #tarefas = Issue.where("updated_on > ?", ultima_execucao)

    # TODO: Adicionar seu processamento aqui

    # Atualizar configurações
    settings["ultima_execucao"] = Time.now
    settings["tarefas_processadas"] = tarefas.count
    Setting.plugin_sky_redmine_plugin = settings
  end
end
