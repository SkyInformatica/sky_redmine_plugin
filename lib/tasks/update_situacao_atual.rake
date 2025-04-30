namespace :sky_redmine_plugin do
  desc "Atualiza o campo etapa_atual em todos os registros de SkyRedmineIndicadores"
  task update_etapa_atual: :environment do
    puts "Iniciando atualização do campo etapa_atual para todos os indicadores..."

    count = 0
    total = SkyRedmineIndicadores.count

    SkyRedmineIndicadores.find_each do |indicador|
      count += 1
      puts "Processando indicador #{count}/#{total} (#{indicador.primeira_tarefa_devel_id})"

      begin
        # Obter a tarefa DEVEL
        if indicador.primeira_tarefa_devel_id.present?
          issue = Issue.find_by(id: indicador.primeira_tarefa_devel_id)

          if issue
            # Processar o indicador
            SkyRedminePlugin::Indicadores.processar_indicadores(issue)
            puts "  ✓ Indicador atualizado com sucesso"
          else
            puts "  ✗ Não foi possível encontrar a tarefa #{indicador.primeira_tarefa_devel_id}"
          end
        else
          puts "  ✗ Indicador sem primeira_tarefa_devel_id"
        end
      rescue => e
        puts "  ✗ Erro ao processar indicador: #{e.message}"
        puts e.backtrace.join("\n  ")
      end
    end

    puts "Finalizado. #{count} indicadores processados."
  end
end
