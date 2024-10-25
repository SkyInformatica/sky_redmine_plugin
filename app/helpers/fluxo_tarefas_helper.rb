module FluxoTarefasHelper
  def atualizar_fluxo_tarefas(tarefa_atual)
    # Busca todas as tarefas relacionadas em ordem
    tarefas_relacionadas = buscar_tarefas_relacionadas(tarefa_atual)

    # Gera o texto do fluxo para todas as tarefas
    texto_fluxo = gerar_texto_fluxo(tarefas_relacionadas, tarefa_atual)

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

  def formatar_linha_tarefa(tarefa, numero_sequencial, tarefa_atual)
    id_formatado = if tarefa.id == tarefa_atual.id
        "*###{tarefa.id}*"
      else
        "###{tarefa.id}"
      end

    "| #{numero_sequencial}. #{tarefa.project.name} | #{id_formatado} | #{tarefa.status.name} | #{tarefa.start_date} | version##{tarefa.fixed_version_id} | #{tarefa.spent_hours}h |"
  end

  def gerar_texto_fluxo(tarefas, tarefa_atual)
    tarefas.each_with_index.map do |tarefa, index|
      formatar_linha_tarefa(tarefa, index + 1, tarefa_atual)
    end.join("\n")
  end

  def atualizar_campo_fluxo(tarefas, texto_fluxo)
    Rails.logger.info ">>> atualizar_campo_fluxo"
    if campo_fluxo = CustomField.find_by(name: "Fluxo das tarefas")
      Rails.logger.info "Iniciando atualização do fluxo para #{tarefas.length} tarefas"

      tarefas.each do |tarefa|
        Rails.logger.debug "Atualizando fluxo da tarefa #{tarefa.id}"
        tarefa.custom_field_values = { campo_fluxo.id => texto_fluxo }

        if tarefa.save(validate: false)
          Rails.logger.info "Tarefa #{tarefa.id} atualizada com sucesso"
        else
          Rails.logger.info "Erro ao salvar tarefa #{tarefa.id}: #{tarefa.errors.full_messages.join(", ")}"
        end
      rescue => e
        Rails.logger.info "Erro ao atualizar fluxo da tarefa #{tarefa.id}: #{e.message}"
      end
    else
      Rails.logger.info "Campo personalizado 'Fluxo das tarefas' não encontrado"
    end
  end
end
