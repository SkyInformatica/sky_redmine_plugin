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
    tarefa_atual = tarefa

    # Busca tarefas anteriores
    while tarefa_atual.copied_from
      tarefa_atual = tarefa_atual.copied_from
      tarefas.unshift(tarefa_atual)
    end

    # Adiciona a tarefa atual
    tarefas << tarefa

    # Busca tarefas posteriores
    tarefas += Issue.where(copied_from_id: tarefa.id)

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
    campo_fluxo = CustomField.find_by(name: "Fluxo das tarefas")

    tarefas.each do |tarefa|
      custom_value = tarefa.custom_field_values.find { |cv| cv.custom_field_id == campo_fluxo.id }
      if custom_value
        custom_value.value = texto_fluxo
        custom_value.save
      end
    end
  end
end
