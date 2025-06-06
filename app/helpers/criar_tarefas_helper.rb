module CriarTarefasHelper
  class TipoCriarNovaTarefa
    ENCAMINHAR_QS = "ENCAMINHAR_QS"
    CONTINUA_PROXIMA_SPRINT = "CONTINUA_PROXIMA_SPRINT"
    RETORNO_TESTES = "RETORNO_TESTES"
  end

  def definir_titulo_tarefa_incrementando_numero_copia(titulo)
    novo_titulo = titulo
    if titulo.match?(/\[(\d+)\]$/)
      # Captura o número dentro dos colchetes no final do título
      current_copy_number = titulo.match(/\[(\d+)\]$/)[1].to_i
      new_copy_number = current_copy_number + 1
      novo_titulo = titulo.sub(/\[\d+\]$/, "[#{new_copy_number}]")
    elsif titulo.match?(/\((\d+)\)$/)
      # Captura o número dentro dos parênteses no final do título
      current_copy_number = titulo.match(/\((\d+)\)$/)[1].to_i
      new_copy_number = current_copy_number + 1
      novo_titulo = titulo.sub(/\(\d+\)$/, "[#{new_copy_number}]")
    else
      novo_titulo = "#{titulo} [2]"
    end
    novo_titulo
  end

  def limpar_campos_nova_tarefa(issue, tipo)
    issue.assigned_to_id = nil
    issue.start_date = nil
    issue.done_ratio = 0

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

  def obter_nome_tag(issue, tag)
    # Lógica para definir o prefixo da nova tag
    sistema_value = ""
    tag_prefix = ""

    # Obtém o campo personalizado 'SISTEMA'
    if sistema_custom_field = IssueCustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::SISTEMA)
      sistema_value = issue.custom_field_value(sistema_custom_field.id)
      if sistema_value.present?
        sistema_value = sistema_value.upcase.gsub(" ", "")
        tag_prefix = sistema_value
      end
    end

    # Se o sistema não for 'LIVROCAIXA', usa o nome da equipe do projeto
    if sistema_value != "LIVROCAIXA"
      tag_prefix = remover_acentos(issue.project.name.sub("Equipe ", "")).upcase
    end

    # Monta o nome da nova tag
    nova_tag = "#{tag_prefix}#{tag}"
    nova_tag
  end

  def encontrar_sprint_atual(project)
    hoje = Date.current

    # Busca todas as versões (sprints) do projeto
    project.versions.find do |version|
      next unless version.name.match?(/^\d{4}-\d{2}\s+\(\d{2}\/\d{2}\s+a\s+\d{2}\/\d{2}\)$/)

      # Extrai as datas do nome da sprint
      if version.name =~ /(\d{4})-\d{2}\s+\((\d{2})\/(\d{2})\s+a\s+(\d{2})\/(\d{2})\)/
        ano = $1.to_i
        mes_inicio = $3.to_i
        dia_inicio = $2.to_i
        mes_fim = $5.to_i
        dia_fim = $4.to_i

        # Ajusta o ano para o mês final se necessário
        ano_fim = ano
        ano_fim += 1 if mes_fim < mes_inicio # Se o mês final for menor que o inicial, é porque virou o ano

        data_inicio = Date.new(ano, mes_inicio, dia_inicio)
        data_fim = Date.new(ano_fim, mes_fim, dia_fim)

        # Verifica se a data atual está dentro do período da sprint
        hoje >= data_inicio && hoje <= data_fim
      end
    end
  end
end
