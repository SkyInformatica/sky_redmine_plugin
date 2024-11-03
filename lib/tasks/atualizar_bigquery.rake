require "google/cloud/bigquery"

namespace :bigquery do
  desc "Atualiza o banco de dados Google BigQuery com as tarefas atualizadas"
  task atualizar: :environment do
    # Carrega a data da última execução
    ultima_execucao = Setting.sky_redmine_plugin["ultima_execucao"].to_datetime rescue Time.at(0)

    # Obtém todas as tarefas atualizadas desde a última execução
    issues_atualizadas = Issue.where("updated_on >= ?", ultima_execucao)

    # Configura o cliente do BigQuery
    bigquery = Google::Cloud::Bigquery.new(
      project_id: "seu-projeto",
      credentials: "/caminho/para/suas/credenciais.json",
    )

    dataset = bigquery.dataset "seu_dataset"
    table = dataset.table "sua_tabela"

    # Processa e envia as issues atualizadas para o BigQuery
    issues_atualizadas.each do |issue|
      dados = {
        id: issue.id,
        assunto: issue.subject,
        atualizado_em: issue.updated_on,
      # Adicione outros campos necessários
      }

      # Inserir os dados na tabela
      table.insert [dados]
    end

    # Atualiza a data da última execução
    Setting.sky_redmine_plugin["ultima_execucao"] = Time.now.to_s
  end
end
