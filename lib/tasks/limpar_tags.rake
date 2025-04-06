namespace :sky_redmine_plugin do
  desc "Limpar tags com prefixo SkyRP_ das tarefas a partir de 2024"
  task limpar_tags: :environment do
    Rails.logger.info ">>> Iniciando limpeza de tags SkyRP_"

    # Data inicial: 01/01/2024
    data_inicial = Date.new(2024, 1, 1)

    # Buscar todas as tarefas criadas a partir de 2024
    issues = Issue.where("created_on >= ?", data_inicial)
    total_issues = issues.count
    Rails.logger.info ">>> Total de tarefas encontradas: #{total_issues}"

    issues.each_with_index do |issue, index|
      begin
        # Verificar se a tarefa tem tags
        if issue.respond_to?(:tag_list)
          tags_atuais = issue.tag_list.dup
          
          # Filtrar apenas as tags que começam com SkyRP_
          tags_skyrp = tags_atuais.select { |tag| tag.start_with?("SkyRP_") }
          
          if tags_skyrp.any?
            # Remover as tags SkyRP_
            tags_filtradas = tags_atuais.reject { |tag| tag.start_with?("SkyRP_") }
            
            # Atualizar as tags da tarefa
            issue.tag_list = tags_filtradas
            issue.save(validate: false)
            
            Rails.logger.info ">>> Tarefa #{issue.id}: removidas tags #{tags_skyrp.join(', ')}"
          end
        end

        # Log de progresso a cada 100 tarefas
        if (index + 1) % 100 == 0
          Rails.logger.info ">>> Processadas #{index + 1} de #{total_issues} tarefas"
        end
      rescue => e
        Rails.logger.error ">>> Erro ao processar tarefa #{issue.id}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end

    Rails.logger.info ">>> Limpeza de tags concluída"
  end
end 