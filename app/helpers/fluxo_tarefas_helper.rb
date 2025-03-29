module FluxoTarefasHelper
  include ApplicationHelper
  include IssuesHelper

  def obter_valor_campo_personalizado(issue, nome_campo)
    if custom_field = IssueCustomField.find_by(name: nome_campo)
      issue.custom_field_value(custom_field.id)
    end
  end

  def render_fluxo_tarefas_html(issue)
    tarefas_relacionadas = obter_lista_tarefas_relacionadas(issue)
    texto_fluxo = gerar_texto_fluxo_html(tarefas_relacionadas, issue.id)
    texto_fluxo.html_safe  # Permite renderizar HTML seguro na visualização
  end

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

    # Adiciona os atributos de data para cada tarefa
    tarefas.map do |tarefa|
      # Data de criação pode ser a data de criação ou a data de atendimento
      data_atendimento = obter_valor_campo_personalizado(tarefa, "Data de Atendimento")
      data_criacao = data_atendimento.present? ? data_atendimento : tarefa.created_on
      
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
          SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT          
        ]
      else
        # Tarefas de Desenvolvimento
        status_resolvida = [SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA]

        status_fechada = [
          SkyRedminePlugin::Constants::IssueStatus::FECHADA,
          SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT,
          SkyRedminePlugin::Constants::IssueStatus::FECHADA_CONTINUA_RETORNO_TESTES,
        ]
      end

      # Obter as datas de resolução e fechamento
      data_resolucao = obter_data_mudanca_status(tarefa, status_resolvida)
      data_fechamento = obter_data_mudanca_status(tarefa, status_fechada)

      # Definir data de andamento
      data_em_andamento = obter_data_mudanca_status(tarefa, [SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO])
      
      # Se não encontrou EM_ANDAMENTO, verificar se está em CONTINUA_PROXIMA_SPRINT
      if data_em_andamento.nil? && tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT
        # Se está em CONTINUA_PROXIMA_SPRINT, mantém data_em_andamento como nil
        data_em_andamento = nil
      elsif data_em_andamento.nil? && (data_resolucao.present? || data_fechamento.present?)
        # Se não encontrou EM_ANDAMENTO mas tem RESOLVIDA ou FECHADA, usa a data de criação
        data_em_andamento = tarefa.created_on
      end

      # Definir datas de resolução e fechamento
      if data_fechamento.present? && data_resolucao.nil?
        # Se foi direto para fechada, usar a data de fechamento para ambos
        data_resolvida = data_fechamento
        data_fechada = data_fechamento
      else
        data_resolvida = data_resolucao
        data_fechada = data_fechamento
      end

      # Se a tarefa está em CONTINUA_PROXIMA_SPRINT, ela não foi resolvida ainda
      if tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT
        data_resolvida = nil
      end

      # Se a tarefa não está atualmente em um status de fechamento, não considerar a data_fechada
      unless status_fechada.include?(tarefa.status.name)
        data_fechada = nil
      end

      tarefa.instance_variable_set(:@data_criacao, data_criacao)
      tarefa.instance_variable_set(:@data_em_andamento, data_em_andamento)
      tarefa.instance_variable_set(:@data_resolvida, data_resolvida)
      tarefa.instance_variable_set(:@data_fechada, data_fechada)

      tarefa.define_singleton_method(:data_criacao) { @data_criacao }
      tarefa.define_singleton_method(:data_em_andamento) { @data_em_andamento }
      tarefa.define_singleton_method(:data_resolvida) { @data_resolvida }
      tarefa.define_singleton_method(:data_fechada) { @data_fechada }

      tarefa
    end
  end

  private

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
