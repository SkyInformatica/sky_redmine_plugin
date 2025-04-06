namespace :sky_redmine_plugin do
  desc "Depura a situação atual e tarefas relacionadas para uma tarefa específica. Uso: rake sky_redmine_plugin:debug_situacao_atual[TAREFA_ID]"
  task :debug_situacao_atual, [:tarefa_id] => :environment do |t, args|
    if args[:tarefa_id].blank?
      puts "Erro: É necessário fornecer o ID da tarefa. Exemplo: rake sky_redmine_plugin:debug_situacao_atual[12345]"
      exit 1
    end

    tarefa_id = args[:tarefa_id].to_i
    puts "=== Depurando situação atual para tarefa ID: #{tarefa_id} ==="
    
    begin
      issue = Issue.find(tarefa_id)
      puts "\n=== Informações da tarefa ==="
      puts "ID: #{issue.id}"
      puts "Projeto: #{issue.project.name}"
      puts "Tipo: #{issue.tracker.name}"
      puts "Status: #{issue.status.name}"
      puts "Versão: #{issue.fixed_version&.name || 'Nenhuma'}"
    rescue ActiveRecord::RecordNotFound
      puts "Erro: Tarefa com ID #{tarefa_id} não encontrada."
      exit 1
    end
    
    # Obter tarefas relacionadas
    tarefas_relacionadas = SkyRedminePlugin::TarefasRelacionadas.obter_lista_tarefas_relacionadas(issue)
    
    # Separar tarefas por equipe
    tarefas_devel = tarefas_relacionadas.select { |t| t.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL }
    tarefas_qs = tarefas_relacionadas.select { |t| t.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::QS }
    
    puts "\n=== Tarefas relacionadas encontradas: #{tarefas_relacionadas.count} ==="
    puts "---------------------------------------------------------------------------------------------------------"
    puts "| ID    | Projeto                  | Tipo              | Status                     | Equipe | Tracker   |"
    puts "---------------------------------------------------------------------------------------------------------"
    
    tarefas_relacionadas.each do |tarefa|
      projeto = tarefa.project.name.ljust(24)[0..23]
      tipo = tarefa.tracker.name.ljust(17)[0..16]
      status = tarefa.status.name.ljust(26)[0..25]
      equipe = tarefa.equipe_responsavel.ljust(6)[0..5]
      tracker_id = tarefa.tracker_id.to_s.ljust(9)[0..8]
      
      puts "| #{tarefa.id.to_s.ljust(5)} | #{projeto} | #{tipo} | #{status} | #{equipe} | #{tracker_id} |"
    end
    
    puts "---------------------------------------------------------------------------------------------------------"
    
    puts "\n=== Datas das tarefas ==="
    puts "--------------------------------------------------------------------------------------------------------------------------------------"
    puts "| ID    | Criação    | Atendimento | Em andamento | Resolvida  | Fechada    | Equipe | Tipo              | Status                     |"
    puts "--------------------------------------------------------------------------------------------------------------------------------------"
    
    tarefas_relacionadas.each do |tarefa|
      data_criacao = tarefa.data_criacao&.strftime("%d/%m/%Y") || "N/A"
      data_atendimento = tarefa.data_atendimento&.strftime("%d/%m/%Y") || "N/A"
      data_em_andamento = tarefa.data_em_andamento&.strftime("%d/%m/%Y") || "N/A"
      data_resolvida = tarefa.data_resolvida&.strftime("%d/%m/%Y") || "N/A"
      data_fechada = tarefa.data_fechada&.strftime("%d/%m/%Y") || "N/A"
      equipe = tarefa.equipe_responsavel.ljust(6)[0..5]
      tipo = tarefa.tracker.name.ljust(17)[0..16]
      status = tarefa.status.name.ljust(26)[0..25]
      
      puts "| #{tarefa.id.to_s.ljust(5)} | #{data_criacao} | #{data_atendimento} | #{data_em_andamento} | #{data_resolvida} | #{data_fechada} | #{equipe} | #{tipo} | #{status} |"
    end
    
    puts "--------------------------------------------------------------------------------------------------------------------------------------"
    
    # Exibir ciclos de desenvolvimento
    ciclos_devel = SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_devel(tarefas_relacionadas)
    
    puts "\n=== Ciclos de desenvolvimento: #{ciclos_devel.count} ==="
    ciclos_devel.each_with_index do |ciclo, i|
      puts "\nCiclo #{i+1} (#{ciclo.count} tarefas):"
      ciclo.each do |tarefa|
        puts "  - #{tarefa.id} - #{tarefa.tracker.name} - #{tarefa.status.name}"
      end
    end
    
    # Exibir ciclos de teste
    ciclos_qs = SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_qs(tarefas_relacionadas)
    
    puts "\n=== Ciclos de QS: #{ciclos_qs.count} ==="
    ciclos_qs.each_with_index do |ciclo, i|
      puts "\nCiclo #{i+1} (#{ciclo.count} tarefas):"
      ciclo.each do |tarefa|
        puts "  - #{tarefa.id} - #{tarefa.tracker.name} - #{tarefa.status.name}"
      end
    end
    
    # Processar indicadores
    puts "\n=== Processando indicadores ==="
    SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    
    # Exibir situação atual do indicador
    primeira_tarefa = tarefas_relacionadas.first
    if primeira_tarefa
      indicador = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: primeira_tarefa.id)
      if indicador
        puts "\n=== Indicador processado ==="
        puts "Primeira tarefa DEVEL ID: #{indicador.primeira_tarefa_devel_id}"
        puts "Última tarefa DEVEL ID: #{indicador.ultima_tarefa_devel_id}"
        puts "Status última tarefa DEVEL: #{indicador.status_ultima_tarefa_devel}"
        puts "Primeira tarefa QS ID: #{indicador.primeira_tarefa_qs_id}"
        puts "Última tarefa QS ID: #{indicador.ultima_tarefa_qs_id}"
        puts "Status última tarefa QS: #{indicador.status_ultima_tarefa_qs}"
        puts "Equipe responsável atual: #{indicador.equipe_responsavel_atual}"
        puts "Retornos de testes: #{indicador.qtd_retorno_testes}"
        puts "Situação atual: #{indicador.situacao_atual}"
      else
        puts "Não foi encontrado indicador para a primeira tarefa (ID: #{primeira_tarefa.id})"
      end
    else
      puts "Não foram encontradas tarefas relacionadas."
    end
    
    puts "\n=== Fim da depuração ==="
  end
end 