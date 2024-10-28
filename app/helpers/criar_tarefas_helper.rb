module CriarTarefasHelper
  class TipoCriarNovaTarefa
    ENCAMINHAR_QS = "ENCAMINHAR_QS"
    CONTINUA_PROXIMA_SPRINT = "CONTINUA_PROXIMA_SPRINT"
    RETORNO_TESTES = "RETORNO_TESTES"
  end

  def definir_titulo_tarefa_incrementando_numero_copia(titulo)

    # Modificando o título da nova tarefa para adicionar o numero da tarefa
    novo_titulo = titulo
    if titulo.match?(/\(\d+\)$/)
      # Se já existe um número entre parênteses no fim do título adiciona +1
      current_copy_number = titulo.match(/\d+/)[0].to_i
      new_copy_number = current_copy_number + 1
      novo_titulo = titulo.sub(/\(\d+\)$/, "(#{new_copy_number})")
    else
      # Se não existe, adicionar (2) ao título original
      novo_titulo = "#{titulo} (2)"
    end

    novo_titulo
  end

  def limpar_campos_nova_tarefa(issue, tipo)
    issue.assigned_to_id = nil
    issue.start_date = nil
    issue.done_ratio = 0
    new_issue.tag_list = []

    if tipo == TipoCriarNovaTarefa::ENCAMINHAR_QS
      ["Tarefa não planejada IMEDIATA", "Tarefa antecipada na sprint", "Teste QS", "Versão estável"].each do |field_name|
        if custom_field = IssueCustomField.find_by(name: field_name)
          issue.custom_field_values = { custom_field.id => nil }
        end
      end
    else
      ["Tarefa não planejada IMEDIATA", "Tarefa antecipada na sprint", "Teste no desenvolvimento", "Teste QS", "Versão estável", "Versão teste"].each do |field_name|
        if custom_field = IssueCustomField.find_by(name: field_name)
          issue.custom_field_values = { custom_field.id => nil }
        end
      end
    end
  end
end
