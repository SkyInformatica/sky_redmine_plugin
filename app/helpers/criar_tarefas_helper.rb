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
    issue.tag_list = []

    if (tipo == TipoCriarNovaTarefa::ENCAMINHAR_QS)
      ["Tarefa não planejada IMEDIATA", "Tarefa antecipada na sprint", "Teste QS"].each do |field_name|
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

  def remover_acentos(str)
    mapa_acentos = {
      "á" => "a", "à" => "a", "ã" => "a", "â" => "a", "ä" => "a",
      "é" => "e", "è" => "e", "ê" => "e", "ë" => "e",
      "í" => "i", "ì" => "i", "î" => "i", "ï" => "i",
      "ó" => "o", "ò" => "o", "õ" => "o", "ô" => "o", "ö" => "o",
      "ú" => "u", "ù" => "u", "û" => "u", "ü" => "u",
      "ç" => "c", "ñ" => "n",
    }

    mapa_maiusculo = mapa_acentos.map { |k, v| [k.upcase, v.upcase] }.to_h

    (mapa_acentos.merge(mapa_maiusculo)).each do |caracter_com_acento, caracter_sem_acento|
      str = str.gsub(caracter_com_acento, caracter_sem_acento)
    end

    str
  end
end
