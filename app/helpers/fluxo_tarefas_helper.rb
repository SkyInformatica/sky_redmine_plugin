module FluxoTarefasHelper
  include ApplicationHelper
  include IssuesHelper

  def render_fluxo_tarefas_html(issue)
    tarefas_relacionadas = SkyRedminePlugin::TarefasRelacionadas.obter_lista_tarefas_relacionadas(issue)
    texto_fluxo = gerar_texto_fluxo_html(tarefas_relacionadas, issue.id)
    texto_fluxo.html_safe  # Permite renderizar HTML seguro na visualização
  end

  private

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
        width: 11%;   
      }  
      .tabela-fluxo-tarefas th:nth-child(3),  
      .tabela-fluxo-tarefas td:nth-child(3) {  
        width: 9%;   
      }  
      .tabela-fluxo-tarefas th:nth-child(4),  
      .tabela-fluxo-tarefas td:nth-child(4) {  
        width: 8%; 
      }  
      .tabela-fluxo-tarefas th:nth-child(5),  
      .tabela-fluxo-tarefas td:nth-child(5) {  
        width: 8%; 
      }  
      .tabela-fluxo-tarefas th:nth-child(6),  
      .tabela-fluxo-tarefas td:nth-child(6) {  
        width: 8%; 
      }  
      .tabela-fluxo-tarefas th:nth-child(7),  
      .tabela-fluxo-tarefas td:nth-child(7) {  
        width: 8%; 
      }  
      .tabela-fluxo-tarefas th:nth-child(8),  
      .tabela-fluxo-tarefas td:nth-child(8) {  
        width: 10%;   
      }  
      .tabela-fluxo-tarefas th:nth-child(9),  
      .tabela-fluxo-tarefas td:nth-child(9) {  
        width: 6%;   
      }  
      .tabela-fluxo-tarefas th:nth-child(10),  
      .tabela-fluxo-tarefas td:nth-child(10) {  
        width: 6%; 
      }  
      /* estilo para o título da seção */  
      .titulo-secao {  
        font-size: 12px;  
        font-weight: bold;  
        margin: 10px 0 5px 0;  
      }  
    </style>"

    secoes.each do |secao|
      # Calcular tempo total gasto na seção
      total_tempo = secao[:tarefas].sum { |t| t.spent_hours.to_f }
      total_tempo_formatado = format("%.2f", total_tempo)

      # Adicionar cabeçalho da seção com tempo total
      linhas << "<p class='titulo-secao'>#{secao[:nome]} (Tempo gasto total: #{total_tempo_formatado}h)</p>"
      #linhas << "<table class='tabela-fluxo-tarefas'>"
      linhas << "<table class='tabela-fluxo-tarefas'>"
      linhas << "<tr>  
        <th>Título</th>  
        <th>Situação</th>  
        <th>Atribuído</th>  
        <th>Criada<br>Atendimento</th>  
        <th>Andamento</th>  
        <th>Resolvida<br>Teste</th>  
        <th>Fechada</th>  
        <th>Versão</th>  
        <th>Gasto</th>  
        <th>SVN</th>
      </tr>"

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
    data_criacao = tarefa.data_criacao.strftime("%d/%m/%Y")
    data_em_andamento = tarefa.data_em_andamento&.strftime("%d/%m/%Y")
    data_resolvida = tarefa.data_resolvida&.strftime("%d/%m/%Y")
    data_fechada = tarefa.data_fechada&.strftime("%d/%m/%Y")

    # Obter as revisões associadas à tarefa
    revisoes = tarefa.changesets

    if revisoes.any?
      links_revisoes = revisoes.map do |revisao|
        link_to_revision(revisao, revisao.repository, :text => "r#{revisao.revision}")
      end.join(", ")
    else
      links_revisoes = "-"
    end

    # obter atribuido para
    assigned_to_name = tarefa.assigned_to_id.present? ? link_to(User.find(tarefa.assigned_to_id).name, user_path(tarefa.assigned_to_id)) : ""

    # obter sprint
    version_name = tarefa.fixed_version ? link_to(tarefa.fixed_version.name, version_path(tarefa.fixed_version)) : "-"

    # obter link para tarefa com sua descricao
    link_tarefa = link_to_issue(tarefa)

    # formatar em negrito se é a tarefa atual na tabela do fluxo das tarefas
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
      <td class='revisao'>#{links_revisoes}</td>
    </tr>"
  end
end
