module FluxoTarefasHelper
  include ApplicationHelper
  include IssuesHelper

  private

  def obter_css_tabela
    css = []
    css << ".tabela-fluxo-tarefas {"
    css << "  border-collapse: collapse;"
    css << "  table-layout: fixed;"
    css << "  width: 100%;"
    css << "  margin: 0 auto;"
    css << "}"
    css << ".tabela-fluxo-tarefas th,"
    css << ".tabela-fluxo-tarefas td {"
    css << "  border: 1px solid #dddddd;"
    css << "  text-align: left;"
    css << "  padding: 4px;"
    css << "  word-wrap: break-word;"
    css << "  font-size: 12px;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(1),"
    css << ".tabela-fluxo-tarefas td:nth-child(1) {"
    css << "  width: 50%;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(2),"
    css << ".tabela-fluxo-tarefas td:nth-child(2) {"
    css << "  width: 11%;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(3),"
    css << ".tabela-fluxo-tarefas td:nth-child(3) {"
    css << "  width: 9%;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(4),"
    css << ".tabela-fluxo-tarefas td:nth-child(4) {"
    css << "  width: 8%;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(5),"
    css << ".tabela-fluxo-tarefas td:nth-child(5) {"
    css << "  width: 8%;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(6),"
    css << ".tabela-fluxo-tarefas td:nth-child(6) {"
    css << "  width: 8%;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(7),"
    css << ".tabela-fluxo-tarefas td:nth-child(7) {"
    css << "  width: 8%;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(8),"
    css << ".tabela-fluxo-tarefas td:nth-child(8) {"
    css << "  width: 10%;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(9),"
    css << ".tabela-fluxo-tarefas td:nth-child(9) {"
    css << "  width: 6%;"
    css << "}"
    css << ".tabela-fluxo-tarefas th:nth-child(10),"
    css << ".tabela-fluxo-tarefas td:nth-child(10) {"
    css << "  width: 6%;"
    css << "}"
    css << ".titulo-secao {"
    css << "  font-size: 12px;"
    css << "  font-weight: bold;"
    css << "  margin: 10px 0 5px 0;"
    css << "}"
    css.join("\n")
  end

  def obter_css_timeline
    css = []
    css << ".timeline-container {"
    css << "  margin: 20px 0;"
    css << "  width: 100%;"
    css << "  overflow-x: auto;"
    css << "}"
    css << ".timeline {"
    css << "  position: relative;"
    css << "  display: flex;"
    css << "  justify-content: space-between;"
    css << "  align-items: flex-start;"
    css << "  padding-top: 12px;"
    css << "}"
    css << "/* Linha conectora */"
    css << ".timeline::before {"
    css << "  content: '';"
    css << "  position: absolute;"
    css << "  top: 24px;"
    css << "  left: 12px;"
    css << "  right: 12px;"
    css << "  height: 2px;"
    css << "  background-color: #e0e0e0;"
    css << "  z-index: 0;"
    css << "}"
    css << ".timeline-step {"
    css << "  flex: 1;"
    css << "  position: relative;"
    css << "  text-align: center;"
    css << "  padding: 0 5px;"
    css << "  min-width: 80px;"
    css << "}"
    css << ".timeline-circle {"
    css << "  width: 24px;"
    css << "  height: 24px;"
    css << "  border-radius: 50%;"
    css << "  border: 2px solid #e0e0e0;"
    css << "  background-color: #fff;"
    css << "  margin: 0 auto;"
    css << "  position: relative;"
    css << "  z-index: 1;"
    css << "  display: flex;"
    css << "  align-items: center;"
    css << "  justify-content: center;"
    css << "}"
    css << "/* Estados dos círculos */"
    css << ".timeline-step-completed .timeline-circle {"
    css << "  background-color: #4CAF50;"
    css << "  border-color: #4CAF50;"
    css << "}"
    css << ".timeline-step-completed .timeline-circle::after {"
    css << "  content: '✓';"
    css << "  color: white;"
    css << "  font-weight: bold;"
    css << "  font-size: 14px;"
    css << "}"
    css << ".timeline-step-current .timeline-circle {"
    css << "  background-color: #2196F3;"
    css << "  border-color: #2196F3;"
    css << "}"
    css << ".timeline-step-current .timeline-circle::after {"
    css << "  content: '';"
    css << "  display: block;"
    css << "  width: 8px;"
    css << "  height: 8px;"
    css << "  border-radius: 50%;"
    css << "  background-color: white;"
    css << "}"
    css << ".timeline-step-warning .timeline-circle {"
    css << "  background-color: #FFC107;"
    css << "  border-color: #FFC107;"
    css << "}"
    css << ".timeline-step-warning .timeline-circle::after {"
    css << "  content: '✓';"
    css << "  color: white;"
    css << "  font-weight: bold;"
    css << "  font-size: 14px;"
    css << "}"
    css << ".timeline-step-warning .timeline-label,"
    css << ".timeline-step-warning .timeline-text {"
    css << "  color: #FFC107;"
    css << "  font-weight: bold;"
    css << "}"
    css << ".timeline-step-future .timeline-circle {"
    css << "  background-color: #fff;"
    css << "  border-color: #e0e0e0;"
    css << "}"
    css << ".timeline-step-error .timeline-circle {"
    css << "  background-color: #f44336;"
    css << "  border-color: #f44336;"
    css << "}"
    css << ".timeline-step-error .timeline-label,"
    css << ".timeline-step-error .timeline-text {"
    css << "  color: #f44336;"
    css << "  font-weight: bold;"
    css << "}"
    css << "/* Textos da timeline */"
    css << ".timeline-label {"
    css << "  display: block;"
    css << "  font-size: 10px;"
    css << "  margin-top: 10px;"
    css << "  word-wrap: break-word;"
    css << "}"
    css << ".timeline-text {"
    css << "  max-width: 100px;"
    css << "  margin: 0 auto;"
    css << "  text-align: center;"
    css << "  font-size: 9px;"
    css << "  color: #666;"
    css << "}"
    css << "/* Cores dos textos baseadas no estado */"
    css << ".timeline-step-completed .timeline-label,"
    css << ".timeline-step-completed .timeline-text {"
    css << "  color: #4CAF50;"
    css << "  font-weight: bold;"
    css << "}"
    css << ".timeline-step-current .timeline-label,"
    css << ".timeline-step-current .timeline-text {"
    css << "  color: #2196F3;"
    css << "  font-weight: bold;"
    css << "}"
    css << ".timeline-step-future .timeline-label,"
    css << ".timeline-step-future .timeline-text {"
    css << "  color: #999;"
    css << "}"
    css << "/* Espaçamento entre múltiplas timelines */"
    css << ".timeline-row + .timeline-row {"
    css << "  margin-top: 30px;"
    css << "}"
    css << ".timeline-step-continua .timeline-circle {"
    css << "  width: 16px;"
    css << "  height: 16px;"
    css << "  background-color: #999;"
    css << "  border-color: #999;"
    css << "}"
    css << ".timeline-step-continua .timeline-label {"
    css << "  color: #999;"
    css << "  font-size: 9px;"
    css << "}"
    css << "/* Estilos específicos para a timeline desconhecida */"
    css << ".timeline-desconhecida {"
    css << "  width: 200px;"
    css << "  margin-left: 20px;"
    css << "}"
    css << ".timeline-desconhecida::before {"
    css << "  right: 12px;"
    css << "  width: auto;"
    css << "}"
    css << ".timeline-desconhecida .timeline-step {"
    css << "  flex: 0 0 auto;"
    css << "  min-width: 120px;"
    css << "}"
    css.join("\n")
  end

  def obter_css_indicadores
    css = []
    css << ".indicadores-container {"
    css << "  margin-bottom: 20px;"
    css << "}"
    css << ".indicadores-grupo {"
    css << "  margin-bottom: 15px;"
    css << "}"
    css << ".indicadores-titulo {"
    css << "  font-weight: bold;"
    css << "  margin-bottom: 10px;"
    css << "  font-size: 12px;"
    css << "}"
    css << ".indicadores-cards {"
    css << "  display: flex;"
    css << "  flex-wrap: wrap;"
    css << "  gap: 10px;"
    css << "  margin-bottom: 10px;"
    css << "}"
    css << ".indicador-card {"
    css << "  background: #f9f9f9;"
    css << "  border: 1px solid #ddd;"
    css << "  border-radius: 4px;"
    css << "  padding: 10px;"
    css << "  min-width: 200px;"
    css << "}"
    css << ".indicador-caption {"
    css << "  font-weight: bold;"
    css << "  color: #666;"
    css << "  font-size: 12px;"
    css << "  margin-bottom: 5px;"
    css << "  display: flex;"
    css << "  align-items: center;"
    css << "  gap: 5px;"
    css << "}"
    css << ".indicador-valor {"
    css << "  font-size: 14px;"
    css << "  margin-bottom: 3px;"
    css << "}"
    css << ".indicador-detalhe {"
    css << "  color: #888;"
    css << "  font-style: italic;"
    css << "  font-size: 11px;"
    css << "}"
    css << ".info-icon {"
    css << "  color: #666;"
    css << "  cursor: help;"
    css << "  font-size: 14px;"
    css.join("\n")
  end

  def obter_css_completo
    css = []
    css << "<style>"
    css << obter_css_tabela
    css << obter_css_timeline
    css << obter_css_indicadores
    css << "</style>"
    css.join("\n")
  end

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

    # Adicionar título e link para processar indicadores
    if primeira_tarefa
      cards_html << "<div class='description'>"
      cards_html << "<hr>"
      cards_html << "<p>"
      cards_html << "<strong>Indicadores</strong>"
      cards_html << " ("
      cards_html << link_to("Processar",
                            processar_indicadores_tarefa_path(primeira_tarefa),
                            method: :post)
      cards_html << ")"
      cards_html << "</p>"
    end

    # Adicionar cards se houver indicadores
    cards_html << (indicadores ? render_cards_indicadores(indicadores, tarefas_relacionadas) : "")

    # Fechar div description se tiver primeira tarefa
    cards_html << "</div>" if primeira_tarefa

    # Gerar HTML do fluxo de tarefas
    texto_fluxo = gerar_texto_fluxo_html(tarefas_relacionadas, issue.id)

    # Combinar os dois HTMLs
    (cards_html + texto_fluxo).html_safe
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
    linhas << obter_css_completo

    secoes.each do |secao|
      # Calcular tempo total gasto na seção
      total_tempo = secao[:tarefas].sum { |t| t.spent_hours.to_f }
      total_tempo_formatado = format("%.2f", total_tempo)

      # Adicionar cabeçalho da seção com tempo total
      linhas << "<p class='titulo-secao'>#{secao[:nome]} (Tempo gasto: #{total_tempo_formatado}h)</p>"
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

  def render_cards_indicadores(indicadores, tarefas_relacionadas)
    # Gerar HTML dos cards
    html = []
    html << obter_css_completo
    html << "<div class='indicadores-container'>"

    # Informações gerais
    html << "<div class='indicadores-cards'>"
    html << render_card("Responsável atual", indicadores.equipe_responsavel_atual, "", "Equipe responsável pela tarefa")

    # Card de retorno de testes
    retornos = []
    if indicadores.qtd_retorno_testes_qs.to_i > 0
      retornos << "QS: #{indicadores.qtd_retorno_testes_qs}"
    end
    if indicadores.qtd_retorno_testes_devel.to_i > 0
      retornos << "DEVEL: #{indicadores.qtd_retorno_testes_devel}"
    end
    html << render_card(
      "Retorno de testes",
      retornos.any? ? retornos.join(", ") : "0",
      "",
      "Quantidade de vezes que a tarefa retornou para desenvolvimento"
    )

    # Card de versão liberada antes dos testes
    html << render_card(
      "Versão liberada antes dos testes",
      indicadores.tarefa_fechada_sem_testes || "NAO", "",
      "A versão foi liberada antes da conclusão dos testes"
    )

    html << render_card(
      "Etapa atual",
      indicadores.situacao_atual,
      "",
      "Etapa atual da tarefa"
    )

    html << render_card(
      "Tarefa complementar",
      indicadores.tarefa_complementar,
      "",
      "Tarefa complementar são tarefas de suporte, planejamento, documentação, videos, etc"
    )

    html << "</div>"

    # Cards DEVEL
    html << "<div class='indicadores-grupo'>"
    tempo_gasto_devel = format("%.2f", indicadores.tempo_gasto_devel.to_f)
    tempo_total_devel = if indicadores.tempo_total_devel
        "#{indicadores.tempo_total_devel} #{indicadores.tempo_total_devel == 1 ? "dia" : "dias"}"
      elsif indicadores.tempo_andamento_devel
        "em desenvolvimento"
      else
        "desenvolvimento não iniciado"
      end
    html << "<div class='indicadores-titulo'>Desenvolvimento - Tempo gasto total: #{tempo_gasto_devel}h - #{tempo_total_devel}</div>"
    html << "<div class='indicadores-cards'>"

    # Para iniciar desenvolvimento
    data_criacao = indicadores.data_criacao_ou_atendimento_primeira_tarefa_devel&.strftime("%d/%m/%Y")
    data_andamento = indicadores.data_andamento_primeira_tarefa_devel&.strftime("%d/%m/%Y")
    detalhe_andamento = data_criacao && data_andamento ? "De #{data_criacao} até #{data_andamento}" : nil
    valor_andamento = formatar_dias(indicadores.tempo_andamento_devel)
    html << render_card("Iniciar desenvolvimento",
                        valor_andamento,
                        detalhe_andamento,
                        "Tempo entre a data do atendimento/criação da tarefa até ele ser iniciada o desenvolvimento colocando a situação da tarefa em andamento")

    # Para concluir desenvolvimento
    data_andamento = indicadores.data_andamento_primeira_tarefa_devel&.strftime("%d/%m/%Y")
    data_resolvida = indicadores.data_resolvida_ultima_tarefa_devel&.strftime("%d/%m/%Y")
    detalhe_resolucao = data_andamento && data_resolvida ? "De #{data_andamento} até #{data_resolvida}" : nil
    valor_resolucao = formatar_dias(indicadores.tempo_resolucao_devel)
    html << render_card("Concluir desenvolvimento",
                        valor_resolucao, detalhe_resolucao,
                        "Tempo entre a tarefa de desenvolvimento ser colocada em andamento e sua situação ser resolvida (considerando o todos os ciclos incluindo os retornos de testes)")

    # Para encaminhar QS
    ciclos_devel = SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_devel(tarefas_relacionadas)
    primeiro_ciclo_devel = ciclos_devel.first
    data_resolvida = primeiro_ciclo_devel.last.data_resolvida&.strftime("%d/%m/%Y")
    data_criacao_qs = indicadores.data_criacao_primeira_tarefa_qs&.strftime("%d/%m/%Y")
    detalhe_encaminhar = data_resolvida && data_criacao_qs ? "De #{data_resolvida} até #{data_criacao_qs}" : nil
    valor_encaminhar = formatar_dias(indicadores.tempo_para_encaminhar_qs)
    html << render_card("Encaminhar QS", valor_encaminhar, detalhe_encaminhar,
                        "Tempo entre tarefa de desenvolvimento estar resolvida e a tarefa de QS ser encaminhada (considerando somente o primeiro ciclo de desenvolvimento)")

    html << "</div>"
    html << "</div>"

    # Cards QS
    html << "<div class='indicadores-grupo'>"
    tempo_gasto_qs = format("%.2f", indicadores.tempo_gasto_qs.to_f)
    tempo_total_testes = if indicadores.tempo_total_testes
        "#{indicadores.tempo_total_testes} #{indicadores.tempo_total_testes == 1 ? "dia" : "dias"}"
      elsif indicadores.tempo_andamento_qs
        "em testes"
      elsif indicadores.data_criacao_primeira_tarefa_qs
        "testes ainda não iniciados"
      else
        "testes ainda não encaminhados"
      end

    # Adicionar o tempo total desde a criação até conclusão dos testes
    tempo_desde_criacao = if indicadores.tempo_total_devel_concluir_testes
        " (desde a criação da tarefa até conclusão testes: #{indicadores.tempo_total_devel_concluir_testes} #{indicadores.tempo_total_devel_concluir_testes == 1 ? "dia" : "dias"})"
      else
        ""
      end

    html << "<div class='indicadores-titulo'>QS - Tempo gasto total: #{tempo_gasto_qs}h - #{tempo_total_testes}#{tempo_desde_criacao}</div>"
    html << "<div class='indicadores-cards'>"

    # Para iniciar testes
    data_criacao_qs = indicadores.data_criacao_primeira_tarefa_qs&.strftime("%d/%m/%Y")
    data_andamento_qs = indicadores.data_andamento_primeira_tarefa_qs&.strftime("%d/%m/%Y")
    detalhe_andamento_qs = data_criacao_qs && data_andamento_qs ? "De #{data_criacao_qs} até #{data_andamento_qs}" : nil
    valor_andamento_qs = formatar_dias(indicadores.tempo_andamento_qs)
    html << render_card("Iniciar testes", valor_andamento_qs, detalhe_andamento_qs,
                        "Tempo entre a tarefa de QS ser encaminhada (criada) e ser colocada em andamento")

    # Para concluir testes
    data_andamento_qs = indicadores.data_andamento_primeira_tarefa_qs&.strftime("%d/%m/%Y")
    data_resolvida_qs = indicadores.data_resolvida_ultima_tarefa_qs&.strftime("%d/%m/%Y")
    detalhe_resolucao_qs = data_andamento_qs && data_resolvida_qs ? "De #{data_andamento_qs} até #{data_resolvida_qs}" : nil
    valor_resolucao_qs = formatar_dias(indicadores.tempo_resolucao_qs)
    html << render_card("Concluir testes", valor_resolucao_qs, detalhe_resolucao_qs,
                        "Tempo entre a tarefa de QS ser colocada em andamento e o seu teste ser concluído (TESTE OK) (considerando o todos os ciclos incluindo os retornos de testes)")

    # Para fechar tarefa
    data_resolvida_qs = indicadores.data_resolvida_ultima_tarefa_qs&.strftime("%d/%m/%Y")
    data_fechada_qs = indicadores.data_fechamento_ultima_tarefa_qs&.strftime("%d/%m/%Y")
    detalhe_fechamento_qs = data_resolvida_qs && data_fechada_qs ? "De #{data_resolvida_qs} até #{data_fechada_qs}" : nil
    valor_fechamento_qs = formatar_dias(indicadores.tempo_fechamento_qs)
    html << render_card("Fechar testes", valor_fechamento_qs, detalhe_fechamento_qs,
                        "Tempo entre a tarefa de QS ser concluída (TESTE OK) e ser fechada (TESTE OK - FECHADA)")

    html << "</div>"
    html << "</div>"

    # Cards Liberar versão
    html << "<div class='indicadores-grupo'>"
    tempo_gasto_devel = format("%.2f", indicadores.tempo_gasto_devel.to_f)
    tempo_total_liberar_versao = if indicadores.tempo_total_liberar_versao
        "#{indicadores.tempo_total_liberar_versao} #{indicadores.tempo_total_liberar_versao == 1 ? "dia" : "dias"}"
      elsif indicadores.tempo_andamento_devel
        "em desenvolvimento"
      else
        "desenvolvimento não iniciado"
      end
    html << "<div class='indicadores-titulo'>Liberar versão - Tempo total: #{tempo_total_liberar_versao}</div>"
    html << "<div class='indicadores-cards'>"

    # Tempo entre conclusão dos testes e liberação da versão
    data_resolvida_qs = indicadores.data_resolvida_ultima_tarefa_qs&.strftime("%d/%m/%Y")
    data_fechada_devel = indicadores.data_fechamento_ultima_tarefa_devel&.strftime("%d/%m/%Y")
    detalhe_liberacao = data_resolvida_qs && data_fechada_devel ? "De #{data_resolvida_qs} até #{data_fechada_devel}" : nil
    valor_liberacao = formatar_dias(indicadores.tempo_concluido_testes_versao_liberada)
    html << render_card("Liberar versão após testes", valor_liberacao, detalhe_liberacao,
                        "Tempo entre a tarefa de QS ser concluída (TESTE OK) e a tarefa de desenvolvimento ser fechada")

    # Para liberar versão
    data_resolvida = indicadores.data_resolvida_ultima_tarefa_devel&.strftime("%d/%m/%Y")
    data_fechada = indicadores.data_fechamento_ultima_tarefa_devel&.strftime("%d/%m/%Y")
    detalhe_fechamento = data_resolvida && data_fechada ? "De #{data_resolvida} até #{data_fechada}" : nil
    valor_fechamento = formatar_dias(indicadores.tempo_fechamento_devel)
    html << render_card("Liberar versão após concluir o desenvolvimento", valor_fechamento, detalhe_fechamento,
                        "Tempo entre tarefa de desenvolvimento estar concluída e ser fechada (entre estes tempos existe o tempo das tarefas do QS)")
    html << "</div>"
    html << "</div>"

    # Timeline de situação atual
    # Verificar se há uma situação atual e quantidade de retornos de testes
   
    if indicadores.situacao_atual.present?
      html << render_timeline_situacao_atual(indicadores)
    end

    html << "</div>"
    html.join("\n")
  end

  # Método para renderizar a timeline da situação atual
  def render_timeline_situacao_atual(indicadores)
    situacao_atual = indicadores.situacao_atual
    return "" unless situacao_atual

    # Se a situação for DESCONHECIDA, renderizar a timeline específica
    if situacao_atual == SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA
      return render_timeline_desconhecida
    end

    tem_retorno_testes_qs = indicadores.qtd_retorno_testes_qs.to_i > 0 || 
                           situacao_atual == SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES
    tem_retorno_testes_devel = indicadores.qtd_retorno_testes_devel.to_i > 0 || 
                              situacao_atual == SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL

    # Determinar qual fluxo usar baseado em se teve retornos de testes
    fluxo = if tem_retorno_testes_qs
              tem_retorno_testes_devel ? 
                SkyRedminePlugin::Constants::SituacaoAtual::FLUXO_RETORNO_TESTES_COM_RETORNO_TESTES_NO_DESENVOLVIMENTO :
                SkyRedminePlugin::Constants::SituacaoAtual::FLUXO_RETORNO_TESTES
            else
              tem_retorno_testes_devel ? 
                SkyRedminePlugin::Constants::SituacaoAtual::FLUXO_IDEAL_COM_RETORNO_TESTES_NO_DESENVOLVIMENTO :
                SkyRedminePlugin::Constants::SituacaoAtual::FLUXO_IDEAL
            end

    # Encontrar o índice da situação atual no fluxo
    indice_atual = fluxo.index(situacao_atual)
    return "" unless indice_atual

    # Preparar HTML
    html = "<div class='indicadores-grupo'>"
    html << "<div class='indicadores-titulo'>Progresso</div>"
    html << "<div class='timeline-container'>"

    if tem_retorno_testes_qs
      # Ponto de divisão - índice do AGUARDANDO_ENCAMINHAR_RETORNO_TESTES
      ponto_divisao = fluxo.index(SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES)

      # Se o ponto de divisão não for encontrado, usar o fluxo normal
      if ponto_divisao.nil?
        return render_timeline_normal(fluxo, indice_atual, indicadores)
      end

      # Dividir o fluxo em duas partes
      primeira_parte = fluxo[0..ponto_divisao]
      segunda_parte = fluxo[(ponto_divisao + 1)..-1]

      # Determinar em qual parte está a situação atual
      esta_na_primeira_parte = indice_atual <= ponto_divisao

      # Renderizar a primeira linha da timeline
      html << "<div class='timeline-row'>"
      html << render_timeline_steps(primeira_parte, indice_atual, indicadores, esta_na_primeira_parte)
      html << "</div>"

      # Adicionar espaçamento entre as linhas
      html << "<div style='height: 30px;'></div>"

      # Renderizar a segunda linha da timeline
      html << "<div class='timeline-row'>"
      html << render_timeline_steps(segunda_parte, indice_atual - primeira_parte.length, indicadores, !esta_na_primeira_parte, primeira_parte.length)
      html << "</div>"
    else
      # Fluxo normal sem retorno de testes
      html << render_timeline_normal(fluxo, indice_atual, indicadores)
    end

    html << "</div>"
    html << "</div>"

    html
  end

  # Método para renderizar a timeline da situação DESCONHECIDA
  def render_timeline_desconhecida
    html = "<div class='indicadores-grupo'>"
    html << "<div class='indicadores-titulo'>Progresso</div>"
    html << "<div class='timeline-container'>"
    html << "<div class='timeline-row'>"
    html << "<div class='timeline timeline-desconhecida'>"
    html << "<div class='timeline-step timeline-step-error'>"
    html << "<div class='timeline-circle'></div>"
    html << "<div class='timeline-label'><div class='timeline-text'>DESCONHECIDA</div></div>"
    html << "</div>"
    html << "</div>"
    html << "</div>"
    html << "</div>"
    html << "</div>"

    html
  end

  # Método auxiliar para renderizar uma timeline simples de uma linha
  def render_timeline_normal(fluxo, indice_atual, indicadores)
    "<div class='timeline-row'>" + render_timeline_steps(fluxo, indice_atual, indicadores) + "</div>"
  end

  # Método auxiliar para renderizar os passos da timeline
  def render_timeline_steps(fluxo, indice_atual, indicadores, esta_na_parte_atual = true, offset = 0)
    html = "<div class='timeline'>"

    fluxo.each_with_index do |situacao, i|
      i_ajustado = i + offset
      eh_ultima_etapa = i == fluxo.length - 1
      eh_fechada = indicadores&.equipe_responsavel_atual == SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA
      eh_versao_liberada = situacao == SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA

      # Corrigido o cálculo do estado para considerar o offset quando não está na parte atual
      estado = if (!esta_na_parte_atual && i_ajustado < indice_atual) || (esta_na_parte_atual && i < indice_atual)
          "completed"
        elsif eh_versao_liberada && i_ajustado == indice_atual
          "completed"  # Se é VERSAO_LIBERADA e é a etapa atual, mostra como concluída
        elsif i_ajustado == indice_atual && esta_na_parte_atual
          "current"
        elsif eh_ultima_etapa && eh_fechada && indicadores.situacao_atual != SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
          "warning"
        else
          "future"
        end

      texto_situacao = situacao.gsub("_", " ")

      # Adicionar o contador de retornos se for ESTOQUE_DEVEL_RETORNO_TESTES
      contador_retornos = if situacao == SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL_RETORNO_TESTES &&
                             indicadores&.qtd_retorno_testes_qs.to_i > 0
          
        else
          ""
        end

      html << "<div class='timeline-step timeline-step-#{estado}'>"
      html << "<div class='timeline-circle'></div>"
      html << "<div class='timeline-label'><div class='timeline-text'>#{texto_situacao}#{contador_retornos}</div></div>"
      html << "</div>"
    end

    html << "</div>"
    html
  end

  def render_card(caption, valor, detalhe = nil, tooltip = nil)
    html = "<div class='indicador-card'>
      <div class='indicador-caption'>"

    html << caption

    if tooltip
      html << " <span class='info-icon' title='#{tooltip}'>&#9432;</span>"
    end

    html << "</div>
      <div class='indicador-valor'>#{valor || "-"}</div>"

    if detalhe
      html << "<div class='indicador-detalhe'>#{detalhe}</div>"
    end

    html << "</div>"
    html
  end

  def formatar_dias(valor)
    return "-" unless valor
    "#{valor} #{valor == 1 ? "dia" : "dias"}"
  end
end
