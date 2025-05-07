namespace :sky_redmine_plugin do
  desc "Atualiza o campo etapa_atual em todos os registros de SkyRedmineIndicadores"
  task update_etapa_atual: :environment do
    puts "Iniciando atualização do campo etapa_atual para todos os indicadores..."

    count = 0
    total = SkyRedmineIndicadores.count

    SkyRedmineIndicadores.find_each do |indicador|
      count += 1
      puts "Processando indicador #{count}/#{total} (#{indicador.id_tarefa})"

      begin
        # Obter a tarefa DEVEL
        if indicador.id_tarefa.present?
          issue = Issue.find_by(id: indicador.id_tarefa)

          if issue
            # Processar o indicador
            SkyRedminePlugin::Indicadores.processar_indicadores(issue)
            puts "  ✓ Indicador atualizado com sucesso"
          else
            puts "  ✗ Não foi possível encontrar a tarefa #{indicador.id_tarefa}"
          end
        else
          puts "  ✗ Indicador sem id_tarefa"
        end
      rescue => e
        puts "  ✗ Erro ao processar indicador: #{e.message}"
        puts e.backtrace.join("\n  ")
      end
    end

    puts "Finalizado. #{count} indicadores processados."
  end
end
