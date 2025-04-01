module FluxoTarefasHelper
  include ApplicationHelper
  include IssuesHelper

  def render_fluxo_tarefas_html(issue)
    tarefas_relacionadas = SkyRedminePlugin::TarefasRelacionadas.obter_lista_tarefas_relacionadas(issue)
    
    # Obter indicadores da primeira tarefa
    indicadores = nil
    primeira_tarefa = tarefas_relacionadas.first
    if primeira_tarefa
      indicadores = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: primeira_tarefa.id)
    end
    
    # Gerar HTML dos cards de indicadores
    cards_html = ""
    
    # Adicionar link para processar indicadores
    if primeira_tarefa
      cards_html << "<div style='margin-bottom: 10px;'>"
      cards_html << button_to("Processar indicadores", 
                            processar_indicadores_tarefa_path(primeira_tarefa), 
                            method: :post,
                            class: "button-positive",
                            style: "padding: 5px 10px; font-size: 12px; cursor: pointer;")
      cards_html << "</div>"
    end
    
    # Adicionar cards se houver indicadores
    cards_html << (indicadores ? render_cards_indicadores(indicadores) : "")
    
    # Gerar HTML do fluxo de tarefas
    texto_fluxo = gerar_texto_fluxo_html(tarefas_relacionadas, issue.id)
    
    # Combinar os dois HTMLs
    (cards_html + texto_fluxo).html_safe
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

  def render_cards_indicadores(indicadores)
    # CSS para os cards
    css = "<style>
      .indicadores-container {
        margin-bottom: 20px;
      }
      .indicadores-grupo {
        margin-bottom: 15px;
      }
      .indicadores-titulo {
        font-weight: bold;
        margin-bottom: 10px;
        font-size: 14px;
      }
      .indicadores-cards {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
      }
      .indicador-card {
        background: #f9f9f9;
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 10px;
        min-width: 200px;
      }
      .indicador-caption {
        font-weight: bold;
        color: #666;
        font-size: 12px;
        margin-bottom: 5px;
      }
      .indicador-valor {
        font-size: 14px;
      }
    </style>"

    # Gerar HTML dos cards
    html = []
    html << css
    html << "<div class='indicadores-container'>"
    
    # Informações gerais
    html << "<div class='indicadores-cards'>"
    html << render_card("Responsável atual", indicadores.local_tarefa)
    
    retorno_testes = if indicadores.qtd_retorno_testes&.positive?
      "SIM (#{indicadores.qtd_retorno_testes})"
    else
      "NÃO"
    end
    html << render_card("Retorno de testes", retorno_testes)
    html << "</div>"

    # Cards DEVEL
    html << "<div class='indicadores-grupo'>"
    html << "<div class='indicadores-titulo'>Desenvolvimento</div>"
    html << "<div class='indicadores-cards'>"
    html << render_card("Dias para iniciar desenvolvimento", indicadores.tempo_andamento_devel)
    html << render_card("Dias para concluir desenvolvimento", indicadores.tempo_resolucao_devel)
    html << render_card("Dias para liberar versão", indicadores.tempo_fechamento_devel)
    html << render_card("Dias para encaminhar QS", indicadores.tempo_para_encaminhar_qs)
    html << "</div>"
    html << "</div>"

    # Cards QS
    html << "<div class='indicadores-grupo'>"
    html << "<div class='indicadores-titulo'>Qualidade</div>"
    html << "<div class='indicadores-cards'>"
    html << render_card("Dias para iniciar testes", indicadores.tempo_andamento_qs)
    html << render_card("Dias para concluir testes", indicadores.tempo_resolucao_qs)
    html << render_card("Dias para fechar tarefa", indicadores.tempo_fechamento_qs)
    html << "</div>"
    html << "</div>"

    html << "</div>"
    html.join("\n")
  end

  def render_card(caption, valor)
    "<div class='indicador-card'>
      <div class='indicador-caption'>#{caption}</div>
      <div class='indicador-valor'>#{valor || '-'}</div>
    </div>"
  end
end
