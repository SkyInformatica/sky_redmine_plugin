module FluxoTarefasHelper
  include ApplicationHelper
  include IssuesHelper

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
    linhas << "<div class='description'>"
    linhas << "<hr>"
    linhas << "<p><strong>Fluxo das tarefas</strong></b></p>"
    linhas << "<style>  
              .tabela-fluxo-tarefas {  
                border-collapse: collapse;  
                table-layout: fixed; /* Definição importante para controlar as larguras */
                width: 100%; /* Ocupará toda a largura disponível */  
                margin: 0 auto; /* Centraliza a tabela */                  
              }  
              .tabela-fluxo-tarefas th,  
              .tabela-fluxo-tarefas td {  
                border: 1px solid #dddddd;  
                text-align: left;  
                padding: 4px;  
                word-wrap: break-word; /* Quebra palavras longas */                
              }        
                .tabela-fluxo-tarefas th:nth-child(1),  
                .tabela-fluxo-tarefas td:nth-child(1) {  
                    width: 50%; 
                }  

                .tabela-fluxo-tarefas th:nth-child(2),  
                .tabela-fluxo-tarefas td:nth-child(2) {  
                    width: 15%; 
                }  

                .tabela-fluxo-tarefas th:nth-child(3),  
                .tabela-fluxo-tarefas td:nth-child(3) {  
                    width: 12%; 
                }  

                .tabela-fluxo-tarefas th:nth-child(4),  
                .tabela-fluxo-tarefas td:nth-child(4) {  
                    width: 6%; 
                }  

                .tabela-fluxo-tarefas th:nth-child(5),  
                .tabela-fluxo-tarefas td:nth-child(5) {  
                    width: 13%; 
                }  

                .tabela-fluxo-tarefas th:nth-child(6),  
                .tabela-fluxo-tarefas td:nth-child(6) {  
                    width: 4%; 
                }  
            </style>"
    secoes.each do |secao|
      # Calcular tempo total gasto na seção
      total_tempo = secao[:tarefas].sum { |t| t.spent_hours.to_f }
      total_tempo_formatado = format("%.2f", total_tempo)

      # Adicionar cabeçalho da seção com tempo total
      linhas << "<b>#{secao[:nome]}</b> (Tempo gasto total: #{total_tempo_formatado}h)"
      #linhas << "<table class='tabela-fluxo-tarefas'>"
      linhas << "<table class='tabela-fluxo-tarefas'>"

      # Adicionar as tarefas
      secao[:tarefas].each do |tarefa|
        linha = formatar_linha_tarefa_html(tarefa, numero_sequencial, tarefa_atual_id)
        linhas << linha
        numero_sequencial += 1
      end

      linhas << "</table>"
      linhas << "<br>"
    end
    linhas << "</div>"

    linhas.join("\n")
  end

  def formatar_linha_tarefa_html(tarefa, numero_sequencial, tarefa_atual_id)
    horas_gastas = format("%.2f", tarefa.spent_hours.to_f)
    data_inicio = tarefa.start_date.present? ? tarefa.start_date.strftime("%d/%m/%Y") : ""
    #assigned_to_name = tarefa.assigned_to_id.present? ? User.find(tarefa.assigned_to_id).name : "Não atribuído"
    assigned_to_name = tarefa.assigned_to_id.present? ? link_to(User.find(tarefa.assigned_to_id).name, user_path(tarefa.assigned_to_id)) : "Não atribuído"
    version_name = tarefa.fixed_version ? link_to(tarefa.fixed_version.name, version_path(tarefa.fixed_version)) : "-"
    link_tarefa = link_to_issue(tarefa)

    if (tarefa.id == tarefa_atual_id)
      link_tarefa = "<strong>#{link_tarefa}</strong>"
    end

    "<tr>        
      <td class='subject'>#{numero_sequencial}. #{tarefa.project.name} - #{link_tarefa}</td>        
      <td class='status'>#{tarefa.status.name}</td>  
      <td class='assigned_to'>#{assigned_to_name}</td>
      <td class='start_date'>#{data_inicio}</td>  
      <td class='version'>#{version_name}</td>  
      <td class='spent_hours'>#{horas_gastas}h</td>  
    </tr>"
  end
end
