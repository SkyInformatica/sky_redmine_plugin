module FluxoTarefasHelper
  def atualizar_fluxo_tarefas(tarefa_atual)
    # Busca todas as tarefas relacionadas em ordem
    tarefas_relacionadas = buscar_tarefas_relacionadas(tarefa_atual)

    # Gera o texto do fluxo para todas as tarefas
    texto_fluxo = gerar_texto_fluxo(tarefas_relacionadas)

    # Atualiza o campo personalizado em todas as tarefas
    atualizar_campo_fluxo(tarefas_relacionadas, texto_fluxo)
  end

  private

  def buscar_tarefas_relacionadas(tarefa)
    tarefas = []
    visitadas = Set.new
    tarefa_atual = tarefa

    # Busca tarefas anteriores (indo para trás na cadeia)
    while true
      break if visitadas.include?(tarefa_atual.id)
      visitadas.add(tarefa_atual.id)

      relacao = IssueRelation.find_by(issue_to_id: tarefa_atual.id, relation_type: "copied_to")
      break unless relacao

      tarefa_anterior = Issue.find(relacao.issue_from_id)
      tarefas.unshift(tarefa_anterior)
      tarefa_atual = tarefa_anterior
    end

    # Adiciona a tarefa atual (que será a última da cadeia)
    tarefas << tarefa

    tarefas
  end

  def formatar_linha_tarefa(tarefa, numero_sequencial)
    "| #{numero_sequencial}. #{tarefa.project.name} | ###{tarefa.id} | #{tarefa.status.name} | #{tarefa.start_date} | version##{tarefa.fixed_version_id} | #{tarefa.spent_hours}h |"
  end

  def gerar_texto_fluxo(tarefas)
    tarefas.each_with_index.map do |tarefa, index|
      formatar_linha_tarefa(tarefa, index + 1)
    end.join("\n")
  end

  def atualizar_campo_fluxo(tarefas, texto_fluxo)
    Rails.logger.info ">>> atualizar_campo_fluxo"
    if campo_fluxo = CustomField.find_by(name: "Fluxo das tarefas")
      Rails.logger.info "Iniciando atualização do fluxo para #{tarefas.length} tarefas"
      tarefas.each do |tarefa|
        begin
          Rails.logger.info "Tentando atualizar a tarefa #{tarefa.id} "

          custom_value = tarefa.custom_value_for(campo_fluxo)
          if custom_value
            # Atualiza diretamente a coluna sem passar por validações ou callbacks

            # Cria uma cópia do texto_fluxo_base para não alterar o original
            texto_fluxo_personalizado = texto_fluxo.dup

            # Coloca o ID da tarefa atual em negrito no texto_fluxo_personalizado
            id_tarefa = tarefa.id.to_s
            texto_fluxo_personalizado.gsub!("###{id_tarefa}", "*###{id_tarefa}*")

            custom_value.update_columns(value: texto_fluxo_personalizado)
            Rails.logger.info "Tarefa #{tarefa.id} atualizada com sucesso"
          else
            Rails.logger.info "Tarefa #{tarefa.id} não possui o campo personalizado 'Fluxo das tarefas'"
          end
        rescue => e
          Rails.logger.info "Erro ao atualizar fluxo da tarefa #{tarefa.id}: #{e.message}"
        end
      end
    else
      Rails.logger.info "Campo personalizado 'Fluxo das tarefas' não encontrado"
    end
  end

  def atualizar_campo_fluxo_transaction(tarefas, texto_fluxo)
    Rails.logger.info ">>> atualizar_campo_fluxo"
    if campo_fluxo = CustomField.find_by(name: "Fluxo das tarefas")
      Rails.logger.info "Iniciando atualização do fluxo para #{tarefas.length} tarefas"
      ActiveRecord::Base.transaction do
        tarefas.each do |tarefa|
          tentativas = 0
          max_tentativas = 3

          begin
            Rails.logger.info "Tentando atualizar a tarefa #{tarefa.id} "
            # Recarrega a tarefa para ter a versão mais atual
            tarefa.reload
            tarefa.custom_field_values = { campo_fluxo.id => texto_fluxo }

            if tarefa.save(validate: false)
              Rails.logger.info "Tarefa #{tarefa.id} atualizada com sucesso"
            else
              Rails.logger.info "Erro ao salvar tarefa #{tarefa.id}: #{tarefa.errors.full_messages.join(", ")}"
            end
          rescue ActiveRecord::StaleObjectError => e
            tentativas += 1
            if tentativas < max_tentativas
              Rails.logger.info "Tentativa #{tentativas} de atualizar tarefa #{tarefa.id}"
              sleep(0.5 * tentativas) # Aguarda um tempo crescente entre tentativas
              retry
            else
              Rails.logger.info "Erro após #{max_tentativas} tentativas na tarefa #{tarefa.id}: #{e.message}"
              raise e
            end
          rescue => e
            Rails.logger.info "Erro ao atualizar fluxo da tarefa #{tarefa.id}: #{e.message}"
            raise e
          end
        end
      end
    else
      Rails.logger.error "Campo personalizado 'Fluxo das tarefas' não encontrado"
    end
  end
end
