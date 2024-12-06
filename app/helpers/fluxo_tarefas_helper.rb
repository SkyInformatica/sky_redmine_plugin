module FluxoTarefasHelper
  include ApplicationHelper
  include IssuesHelper

  def render_fluxo_tarefas_html(issue)
    tarefas_relacionadas = obter_lista_tarefas_relacionadas(issue)
    if (tarefas_relacionadas.length > 1)
      texto_fluxo = gerar_texto_fluxo_html(tarefas_relacionadas, issue.id)
      texto_fluxo.html_safe  # Permite renderizar HTML seguro na visualização
    end
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

  def obter_data_mudanca_status(tarefa, status_nomes)
    status_ids = IssueStatus.where(name: status_nomes).pluck(:id)

    journal = tarefa.journals.joins(:details)
                    .where(journal_details: { property: "attr", prop_key: "status_id", value: status_ids })
                    .order("created_on ASC")
                    .first

    journal&.created_on
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
          font-size: 12px; /* Tamanho da fonte ajustado */  
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
          width: 10%;   
        }  
      
        .tabela-fluxo-tarefas th:nth-child(4),  
        .tabela-fluxo-tarefas td:nth-child(4) {  
          width: 10%; /* Data de Criação */  
        }  
      
        .tabela-fluxo-tarefas th:nth-child(5),  
        .tabela-fluxo-tarefas td:nth-child(5) {  
          width: 10%; /* Data Em Andamento */  
        }  
      
        .tabela-fluxo-tarefas th:nth-child(6),  
        .tabela-fluxo-tarefas td:nth-child(6) {  
          width: 10%; /* Data Resolvida/Teste */  
        }  
      
        .tabela-fluxo-tarefas th:nth-child(7),  
        .tabela-fluxo-tarefas td:nth-child(7) {  
          width: 10%; /* Data Fechada */  
        }  
        
        .tabela-fluxo-tarefas th:nth-child(8),  
        .tabela-fluxo-tarefas td:nth-child(8) {  
          width: 11%;   
        }  
      
        .tabela-fluxo-tarefas th:nth-child(9),  
        .tabela-fluxo-tarefas td:nth-child(9) {  
          width: 6%;   
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

  def formatar_linha_tarefa_html_old(tarefa, numero_sequencial, tarefa_atual_id)
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

  def formatar_linha_tarefa_html(tarefa, numero_sequencial, tarefa_atual_id)
    horas_gastas = format("%.2f", tarefa.spent_hours.to_f)
    data_criacao = tarefa.created_on.strftime("%d/%m/%Y")

    # Obter a data que mudou para "Em andamento"
    data_em_andamento = obter_data_mudanca_status(tarefa, [SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO])
    data_em_andamento = data_em_andamento.strftime("%d/%m/%Y") if data_em_andamento

    projeto_nome = tarefa.project.name
    if SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(projeto_nome)
      # Tarefas do QS
      status_resolvida = [
        SkyRedminePlugin::Constants::IssueStatus::TESTE_OK,
        SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK,
      ]
      status_fechada = [
        SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA,
        SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA,
      ]
    else
      # Tarefas de Desenvolvimento
      status_resolvida = [SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA]
      status_fechada = [SkyRedminePlugin::Constants::IssueStatus::FECHADA]
    end

    # Obter a data que mudou para "Resolvida" ou "Teste OK"/"Teste NOK"
    data_resolvida = obter_data_mudanca_status(tarefa, status_resolvida)
    data_resolvida = data_resolvida.strftime("%d/%m/%Y") if data_resolvida

    # Obter a data que mudou para "Fechada" ou "Teste OK - Fechada"/"Teste NOK - Fechada"
    data_fechada = obter_data_mudanca_status(tarefa, status_fechada)
    data_fechada = data_fechada.strftime("%d/%m/%Y") if data_fechada

    assigned_to_name = tarefa.assigned_to_id.present? ? link_to(User.find(tarefa.assigned_to_id).name, user_path(tarefa.assigned_to_id)) : "Não atribuído"
    version_name = tarefa.fixed_version ? link_to(tarefa.fixed_version.name, version_path(tarefa.fixed_version)) : "-"
    link_tarefa = link_to_issue(tarefa)

    if tarefa.id == tarefa_atual_id
      link_tarefa = "<strong>#{link_tarefa}</strong>"
    end

    "<tr>  
      <td class='subject'>#{numero_sequencial}. #{tarefa.project.name} - #{link_tarefa}</td>  
      <td class='status'>#{tarefa.status.name}</td>  
      <td class='assigned_to'>#{assigned_to_name}</td>  
      <td class='data_criacao'>#{data_criacao}</td>  
      <td class='data_em_andamento'>#{data_em_andamento || ""}</td>  
      <td class='data_resolvida'>#{data_resolvida || ""}</td>  
      <td class='data_fechada'>#{data_fechada || ""}</td>  
      <td class='version'>#{version_name}</td>  
      <td class='spent_hours'>#{horas_gastas}h</td>  
    </tr>"
  end
end
