module FluxoTarefasHelper
  include ApplicationHelper
  include IssuesHelper

  def atualizar_fluxo_tarefas(issue)
    # Busca todas as tarefas relacionadas em ordem
    #tarefas_relacionadas = obter_lista_tarefas_relacionadas(issue)

    # Gera o texto do fluxo para todas as tarefas
    #texto_fluxo = gerar_texto_fluxo(tarefas_relacionadas)

    # Atualiza o campo personalizado em todas as tarefas
    #atualizar_campo_fluxo(tarefas_relacionadas, texto_fluxo)
  end

  def render_fluxo_tarefas_html(issue)
    tarefas_relacionadas = obter_lista_tarefas_relacionadas(issue)
    texto_fluxo = gerar_texto_fluxo_html(tarefas_relacionadas, issue.id)
    texto_fluxo.html_safe  # Permite renderizar HTML seguro na visualização
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

      # Verifica a relação da tarefa para encontrar a tarefa original
      relation = IssueRelation.find_by(issue_to_id: current_issue.id, relation_type: "copied_to")

      # Se não houver mais relações de cópia, interrompe o loop
      break unless relation

      related_issue = Issue.find_by(id: relation.issue_from_id)

      # Verifica se a próxima tarefa existe
      break unless related_issue

      current_issue = related_issue
    end

    original_issue
  end

  def localizar_tarefa_copiada_qs(issue)
    # Verificar se já existe uma cópia da tarefa nos projetos QS
    # retorna a ultima tarefa do QS na possivel sequencia de copias de continua na proxima sprint
    current_issue = issue
    last_qs_issue = nil

    loop do
      # Encontrar a relação de cópia a partir da current_issue
      relation = IssueRelation.find_by(issue_from_id: current_issue.id, relation_type: "copied_to")

      # Se não houver mais relações de cópia, interrompe o loop
      break unless relation

      # Obter a próxima tarefa na cadeia
      next_issue = Issue.find_by(id: relation.issue_to_id)

      # Verifica se a próxima tarefa existe
      break unless next_issue

      # Verifica se a tarefa está em um projeto QS
      if SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(next_issue.project.name)
        last_qs_issue = next_issue
      end

      # Avança para a próxima tarefa
      current_issue = next_issue
    end

    last_qs_issue
  end

  def localizar_tarefa_continuidade(issue)
    # verificar se há uma copia de continuidade da tarefa
    related_issues = IssueRelation.where(issue_from_id: @issue.id, relation_type: "copied_to")
    copied_to_issue = related_issues.map { |relation| Issue.find_by(id: relation.issue_to_id) }
      .find { |issue| @issue.project.name == issue.project.name }

    copied_to_issue
  end

  private

  def obter_lista_tarefas_relacionadas(tarefa)
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
      secao = if SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(projeto_nome)
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

  def gerar_texto_fluxo_html(tarefas, tarefa_atual_id)
    secoes = []
    secao_atual = nil
    secao_tarefas = []
    numero_sequencial = 1

    tarefas.each do |tarefa|
      projeto_nome = tarefa.project.name

      # Determinar a seção da tarefa
      secao = if SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(projeto_nome)
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
    linhas << "<hr>"
    linhas << "<b>Fluxo das tarefas<br></b>"
    linhas << "<style>  
              .tabela-fluxo-tarefas {  
                border-collapse: collapse;  
                table-layout: auto;
                width: 100%;  
              }  
              .tabela-fluxo-tarefas th,  
              .tabela-fluxo-tarefas td {  
                border: 1px solid #dddddd;  
                text-align: left;  
                padding: 4px;  
                word-wrap: break-word; /* Quebra palavras longas */
              }                
            </style>"
    secoes.each do |secao|
      # Calcular tempo total gasto na seção
      total_tempo = secao[:tarefas].sum { |t| t.spent_hours.to_f }
      total_tempo_formatado = format("%.2f", total_tempo)

      # Adicionar cabeçalho da seção com tempo total
      linhas << "<br><b>#{secao[:nome]}</b> (Tempo gasto total: #{total_tempo_formatado}h)"
      linhas << "<table class='tabela-fluxo-tarefas'>"
      #linhas << "<tr><th>Nº</th><th>Projeto</th><th>ID</th><th>Status</th><th>Data de Início</th><th>Versão</th><th>Horas Gastas</th></tr>"

      # Adicionar as tarefas
      secao[:tarefas].each do |tarefa|
        linha = formatar_linha_tarefa_html(tarefa, numero_sequencial, tarefa_atual_id)
        linhas << linha
        numero_sequencial += 1
      end

      linhas << "</table>"
    end

    linhas.join("\n")
  end

  def formatar_linha_tarefa_html(tarefa, numero_sequencial, tarefa_atual_id)
    horas_gastas = format("%.2f", tarefa.spent_hours.to_f)
    data_inicio = tarefa.due_date || "<previsao>"
    version_name = tarefa.fixed_version ? link_to(tarefa.fixed_version.name, version_path(tarefa.fixed_version)) : "-"
    link_tarefa = link_to_issue(tarefa)

    if (tarefa.id == tarefa_atual_id)
      link_tarefa = "<b>#{link_tarefa}</b>"
    end

    "<tr>        
      <td>#{numero_sequencial} #{tarefa.project.name}</td>  
      <td>#{link_tarefa}</td>  
      <td>#{tarefa.status.name}</td>  
      <td>#{data_inicio}</td>  
      <td>#{version_name}</td>  
      <td>#{horas_gastas}h</td>  
    </tr>"
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
