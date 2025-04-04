class ProcessarIndicadoresJob < ApplicationJob
  queue_as :default

  def perform(projetos, ano)
    total = Issue.where(project_id: Project.where(name: projetos).pluck(:id))
                 .where("created_on >= ?", Date.new(ano, 1, 1)).count
    processados = 0

    Issue.where(project_id: Project.where(name: projetos).pluck(:id))
         .where("created_on >= ?", Date.new(ano, 1, 1)).find_each do |issue|
      SkyRedminePlugin::Indicadores.processar_indicadores(issue)
      processados += 1
      Redis.current.set("progresso_processar_indicadores", { total: total, processados: processados }.to_json)
    end
  end
end
