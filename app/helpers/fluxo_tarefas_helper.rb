module FluxoTarefasHelper
  def atualizar_fluxo_tarefas(tarefa_atual)
    # Busca todas as tarefas relacionadas em ordem
    tarefas_relacionadas = buscar_tarefas_relacionadas(tarefa_atual)

    # Gera o texto do fluxo para todas as tarefas
    texto_fluxo = gerar_texto_fluxo(tarefas_relacionadas)

    # Atualiza o campo personalizado em todas as tarefas
    atualizar_campo_fluxo(tarefas_relacionadas, texto_fluxo)
  end

  def localizar_tarefa_origem_desenvolvimento(issue)
    current_issue = issue
    current_project_id = issue.project_id
    original_issue = nil

    # Procura na lista de relações da tarefa para encontrar a origem
    loop do

      # Verifica se o projeto da tarefa atual é diferente do projeto original
      if current_issue.project_id != current_project_id
        original_issue = current_issue
        break
      end

      # Verifica as relações da tarefa para encontrar a tarefa original
      related_issues = IssueRelation.where(issue_to_id: current_issue.id, relation_type: "copied_to")

      if related_issues.any?
        related_issue = Issue.find_by(id: related_issues.first.issue_from_id)
        current_issue = related_issue
      else
        break
      end
    end

    original_issue
  end

  def localizar_tarefa_copiada_qs(issue)
    # Verificar se já existe uma cópia da tarefa nos projetos QS
    related_issues = IssueRelation.where(issue_from_id: issue.id, relation_type: "copied_to")
    copied_to_qs_issue = related_issues.map { |relation| Issue.find_by(id: relation.issue_to_id) }
      .find { |issue| SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(issue.project.name) }

    copied_to_qs_issue
  end

  def localizar_tarefa_continuidade(issue)
    # verificar se há uma copia de continuidade da tarefa
    related_issues = IssueRelation.where(issue_from_id: @issue.id, relation_type: "copied_to")
    copied_to_issue = related_issues.map { |relation| Issue.find_by(id: relation.issue_to_id) }
      .find { |issue| @issue.project.name == issue.project.name }

    copied_to_issue
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

    visitadas.clear  # Limpa as visitadas para a próxima busca

    # Busca tarefas posteriores (indo para frente na cadeia)
    tarefa_atual = tarefa
    while true
      break if visitadas.include?(tarefa_atual.id)
      visitadas.add(tarefa_atual.id)

      relacao = IssueRelation.find_by(issue_from_id: tarefa_atual.id, relation_type: "copied_to")
      break unless relacao

      tarefa_posterior = Issue.find(relacao.issue_to_id)
      tarefas << tarefa_posterior
      tarefa_atual = tarefa_posterior
    end

    tarefas
  end

  def formatar_linha_tarefa(tarefa, numero_sequencial)
    horas_gastas = format("%.2f", tarefa.spent_hours.to_f)
    data_inicio = tarefa.start_date || "<data inicio>"
    "| #{numero_sequencial}. #{tarefa.project.name} | ###{tarefa.id} | #{tarefa.status.name} | #{data_inicio} | version##{tarefa.fixed_version_id} | #{horas_gastas}h |"
  end

  def gerar_texto_fluxo(tarefas)
    secoes = []
    secao_atual = nil
    secao_tarefas = []
    numero_sequencial = 1

    tarefas.each do |tarefa|
      projeto_nome = tarefa.project.name

      # Determinar a seção da tarefa
      secao = if ["Notarial - QS", "Registral - QS"].include?(projeto_nome)
          "QS"
        else
          "Desenvolvimento"
        end

      if secao != secao_atual
        # Salvar a seção anterior
        unless secao_atual.nil?
          secoes << { nome: secao_atual, tarefas: secao_tarefas }
        end
        # Iniciar nova seção
        secao_atual = secao
        secao_tarefas = []
      end

      # Adicionar a tarefa à seção atual
      secao_tarefas << tarefa
    end

    # Adicionar a última seção
    secoes << { nome: secao_atual, tarefas: secao_tarefas } unless secao_tarefas.empty?

    # Gerar o texto final
    linhas = []
    secoes.each do |secao|
      # Calcular tempo total gasto na seção
      total_tempo = secao[:tarefas].sum { |t| t.spent_hours.to_f }
      total_tempo_formatado = format("%.2f", total_tempo)

      # Adicionar cabeçalho da seção com tempo total
      linhas << ""
      linhas << "**#{secao[:nome]}**  (tempo gasto total #{total_tempo_formatado}h)"

      # Adicionar as tarefas
      secao[:tarefas].each do |tarefa|
        linha = formatar_linha_tarefa(tarefa, numero_sequencial)
        linhas << linha
        numero_sequencial += 1
      end
    end

    # Remover a primeira linha vazia, se existir
    linhas.shift if linhas.first == ""

    linhas.join("\n")
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
