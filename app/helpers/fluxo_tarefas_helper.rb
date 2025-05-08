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
    indicadores = SkyRedmineIndicadores.find_by(id_tarefa: tarefas_relacionadas.first.id)

    # Gerar HTML dos cards de indicadores
    html = ""
    html << obter_css_completo
    if SkyRedminePlugin::Constants::Projects::TODOS_PROJETOS.include?(issue.project.name)
      # Adicionar cards se houver indicadores
      html << render_cards_indicadores(indicadores, tarefas_relacionadas)
    end

    # Gerar HTML do fluxo de tarefas
    html << gerar_texto_fluxo_html(tarefas_relacionadas, issue.id)

    # Combinar os dois HTMLs
    html.html_safe
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
    html = []
    html << "<div class='description'>"
    html << "<hr>"
    html << "<p>"
    html << "<p><strong>Fluxo das tarefas</strong>"
    html << " ("
    html << link_to("Processar indicadores",
                    processar_indicadores_tarefa_path(tarefas.first),
                    method: :post)
    html << ")"
    html << "<p>"

    secoes.each do |secao|
      # Calcular tempo total gasto na seção
      total_tempo = secao[:tarefas].sum { |t| t.spent_hours.to_f }
      total_tempo_formatado = format("%.2f", total_tempo)

      # Adicionar cabeçalho da seção com tempo total
      html << "<p class='titulo-secao'>#{secao[:nome]} (Tempo gasto: #{total_tempo_formatado}h)</p>"
      html << "<table class='tabela-fluxo-tarefas'>"
      html << "<tr>  
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
        html << linha
        numero_sequencial += 1
      end

      html << "</table>"
      html << "<br>"
    end
    html << "</div>" # description

    html.join("\n")
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

    if tarefas_relacionadas.first.tarefa_complementar == SkyRedminePlugin::Constants::TarefasComplementares::TAREFA_NAO_PLANEJADA
      return html.join("\n")
    end

    html << "<div class='description'>"
    html << "<p>"
    html << "<p><strong>Indicadores</strong>"
    html << " ("
    html << link_to("Processar indicadores",
                    processar_indicadores_tarefa_path(tarefas_relacionadas.first),
                    method: :post)
    html << ")"
    html << "<p>"

    if indicadores.nil?
      html << "</div>" # description
      return html.join("\n")
    end

    html << "<div class='indicadores-container'>"
    if tarefas_relacionadas.first.tarefa_complementar == "SIM"
      html << "<div class='indicadores-grupo'>"
      html << "<div class='indicadores-cards'>"

      html << render_card("Tarefa complementar",
                          indicadores.tarefa_complementar,
                          "",
                          "Tarefa complementar são tarefas de suporte, planejamento, documentação, videos, etc")
      html << "</div>" # indicadores-cards
      html << "</div>" # indicadores-grupo
    else
      html << "<div class='indicadores-grupo'>"
      html << "<div class='indicadores-cards'>"

      # calcula o numero de dias que está nesta a situacao até hoje

      # Informações gerais
      html << render_card("Responsável atual",
                          indicadores.equipe_responsavel_atual,
                          "",
                          "Equipe responsável pela tarefa")

      if (indicadores.tipo != SkyRedminePlugin::Constants::Trackers::CONVERSAO) &&
         (indicadores.etapa_atual != SkyRedminePlugin::Constants::EtapaAtual::FECHADA_SEM_DESENVOLVIMENTO)
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
      end
      html << "</div>" # indicadores-cards
      html << "</div>" # indicadores-grupo

      # Cards DEVEL
      html << "<div class='indicadores-grupo'>"
      tempo_gasto = format("%.2f", indicadores.tempo_gasto.to_f)
      tempo_total_devel = if indicadores.tempo_total_devel
          "#{indicadores.tempo_total_devel} #{indicadores.tempo_total_devel == 1 ? "dia" : "dias"}"
        elsif indicadores.tempo_andamento
          "em desenvolvimento"
        else
          "desenvolvimento não iniciado"
        end
      html << "<div class='indicadores-titulo'>Desenvolvimento - Tempo gasto total: #{tempo_gasto}h - #{tempo_total_devel}</div>"
      html << "<div class='indicadores-cards'>"

      # Para iniciar desenvolvimento
      html << render_card("Iniciar desenvolvimento",
                          formatar_dias(indicadores.tempo_andamento),
                          indicadores.tempo_andamento_detalhes,
                          "Tempo entre a data do atendimento/criação da tarefa até ele ser iniciada o desenvolvimento colocando a situação da tarefa em andamento")

      # Para concluir desenvolvimento
      html << render_card("Concluir desenvolvimento",
                          formatar_dias(indicadores.tempo_resolucao), indicadores.tempo_resolucao_detalhes,
                          "Tempo entre a tarefa de desenvolvimento ser colocada em andamento e sua situação ser resolvida (considerando o todos os ciclos incluindo os retornos de testes)")

      if (indicadores.tipo != SkyRedminePlugin::Constants::Trackers::CONVERSAO) &&
         (indicadores.etapa_atual != SkyRedminePlugin::Constants::EtapaAtual::FECHADA_SEM_DESENVOLVIMENTO)
        # Para encaminhar QS
        html << render_card("Encaminhar QS", formatar_dias(indicadores.tempo_para_encaminhar_qs), indicadores.tempo_para_encaminhar_qs_detalhes,
                            "Tempo entre tarefa de desenvolvimento estar resolvida e a tarefa de QS ser encaminhada (considerando somente o primeiro ciclo de desenvolvimento)")
      end
      html << "</div>" # indicadores-cards
      html << "</div>" # indicadores-grupo

      if (indicadores.tipo != SkyRedminePlugin::Constants::Trackers::CONVERSAO) &&
         (indicadores.etapa_atual != SkyRedminePlugin::Constants::EtapaAtual::FECHADA_SEM_DESENVOLVIMENTO)
        # Cards QS
        html << "<div class='indicadores-grupo'>"
        tempo_gasto_qs = format("%.2f", indicadores.tempo_gasto_qs.to_f)
        tempo_total_testes = if indicadores.tempo_total_testes
            "#{indicadores.tempo_total_testes} #{indicadores.tempo_total_testes == 1 ? "dia" : "dias"}"
          elsif indicadores.tempo_andamento_qs
            "em testes"
          elsif indicadores.data_criacao_qs
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
        html << render_card("Iniciar testes", formatar_dias(indicadores.tempo_andamento_qs), indicadores.tempo_andamento_qs_detalhes,
                            "Tempo entre a tarefa de QS ser encaminhada (criada) e ser colocada em andamento")

        # Para concluir testes
        html << render_card("Concluir testes", formatar_dias(indicadores.tempo_resolucao_qs), indicadores.tempo_resolucao_qs_detalhes,
                            "Tempo entre a tarefa de QS ser colocada em andamento e o seu teste ser concluído (TESTE OK) (considerando o todos os ciclos incluindo os retornos de testes)")

        # Para fechar tarefa
        html << render_card("Fechar testes", formatar_dias(indicadores.tempo_fechamento_qs), indicadores.tempo_fechamento_qs_detalhes,
                            "Tempo entre a tarefa de QS ser concluída (TESTE OK) e ser fechada (TESTE OK - FECHADA)")

        html << "</div>" # indicadores-cards
        html << "</div>" # indicadores-grupo

        # Cards Liberar versão
        html << "<div class='indicadores-grupo'>"
        tempo_gasto = format("%.2f", indicadores.tempo_gasto.to_f)
        tempo_total_liberar_versao = if indicadores.tempo_total_liberar_versao
            "#{indicadores.tempo_total_liberar_versao} #{indicadores.tempo_total_liberar_versao == 1 ? "dia" : "dias"}"
          elsif indicadores.tempo_andamento
            "em desenvolvimento"
          else
            "desenvolvimento não iniciado"
          end
        html << "<div class='indicadores-titulo'>Liberar versão - Tempo total: #{tempo_total_liberar_versao}</div>"
        html << "<div class='indicadores-cards'>"

        # Tempo entre conclusão dos testes e liberação da versão
        html << render_card("Liberar versão após testes", formatar_dias(indicadores.tempo_concluido_testes_versao_liberada), indicadores.tempo_concluido_testes_versao_liberada_detalhes,
                            "Tempo entre a tarefa de QS ser concluída (TESTE OK) e a tarefa de desenvolvimento ser fechada")

        # Para liberar versão
        html << render_card("Liberar versão após concluir o desenvolvimento", formatar_dias(indicadores.tempo_fechamento), indicadores.tempo_fechamento_detalhes,
                            "Tempo entre tarefa de desenvolvimento estar concluída e ser fechada (entre estes tempos existe o tempo das tarefas do QS)")

        html << "</div>" # indicadores-cards
        html << "</div>" # indicadores-grupo
      end

      # Timeline de situação atual
      if indicadores.etapa_atual.present?
        html << render_timeline_etapa_atual(indicadores)
      end
    end
    html << "</div>" # indicadores-container
    html << "</div>" # description
    html.join("\n")
  end

  # Método para renderizar a timeline da situação atual
  def render_timeline_etapa_atual(indicadores)
    Rails.logger.info(">>>> render_timeline_etapa_atual: #{indicadores.etapa_atual}")
    etapa_atual = indicadores.etapa_atual
    return "" unless etapa_atual

    # Preparar HTML
    html = "<div class='indicadores-grupo'>"
    html << "<div class='indicadores-titulo'>Progresso</div>"
    if !indicadores.data_etapa_atual.nil?
      numero_dias_data_etapa_atual = indicadores.data_etapa_atual ? (Date.today - indicadores.data_etapa_atual&.to_date).to_i : 0
      etapa_atual_detalhes = indicadores.data_etapa_atual ? "#{indicadores.etapa_atual} em #{indicadores.data_etapa_atual&.strftime("%d/%m/%Y")} (#{numero_dias_data_etapa_atual} dias)" : "#{indicadores.etapa_atual}"
      html << "<div style='font-style: italic; color: gray;'><small>#{etapa_atual_detalhes}</small></div>"
    end
    html << "<div class='timeline-container'>"

    # Se a situação for DESCONHECIDA, renderizar a timeline específica
    if etapa_atual == SkyRedminePlugin::Constants::EtapaAtual::DESCONHECIDA ||
       etapa_atual == SkyRedminePlugin::Constants::EtapaAtual::INTERROMPIDA ||
       etapa_atual == SkyRedminePlugin::Constants::EtapaAtual::INTERROMPIDA_ANALISE ||
       etapa_atual == SkyRedminePlugin::Constants::EtapaAtual::CANCELADA
      html << render_timeline_desconhecida(etapa_atual, indicadores.motivo_situacao_desconhecida)
      html << "</div>"
      html << "</div>"
      html << "</div>"
      return html
    end

    # Verificar se é uma tarefa que não necessita desenvolvimento
    if etapa_atual == SkyRedminePlugin::Constants::EtapaAtual::FECHADA_SEM_DESENVOLVIMENTO
      fluxo = SkyRedminePlugin::Constants::EtapaAtual::FLUXO_SEM_QS_FECHADA_SEM_DESENVOLVIMENTO
      indice_atual = fluxo.index(etapa_atual)
      html << render_timeline_normal(fluxo, indice_atual, indicadores)
      html << "</div>"
      html << "</div>"

      return html
    end

    if !indicadores.tipo.nil? && indicadores.tipo == SkyRedminePlugin::Constants::Trackers::CONVERSAO
      fluxo = SkyRedminePlugin::Constants::EtapaAtual::FLUXO_SEM_QS
      indice_atual = fluxo.index(etapa_atual)
      html << render_timeline_normal(fluxo, indice_atual, indicadores)
      html << "</div>"
      html << "</div>"

      return html
    end

    tem_retorno_testes_qs = indicadores.qtd_retorno_testes_qs.to_i > 0 ||
                            etapa_atual == SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES

    # Determinar qual fluxo usar baseado em se teve retornos de testes
    fluxo = tem_retorno_testes_qs ?
      SkyRedminePlugin::Constants::EtapaAtual::FLUXO_COM_RETORNO_TESTES :
      SkyRedminePlugin::Constants::EtapaAtual::FLUXO_SEM_RETORNO_TESTES

    if etapa_atual == SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA_FALTA_FECHAR
      # Adicionar a situacao VERSAO_LIBERADA_FALTA_FECHAR ao fluxo antes do VERSAO_LIBERADA
      fluxo = fluxo.dup
      fluxo.insert(fluxo.index(SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA), SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA_FALTA_FECHAR)
    end

    # Encontrar o índice da situação atual no fluxo
    indice_atual = fluxo.index(etapa_atual)

    return "" unless indice_atual

    if tem_retorno_testes_qs
      # Ponto de divisão - índice do AGUARDANDO_ENCAMINHAR_RETORNO_TESTES
      ponto_divisao = fluxo.index(SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES)

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
      # Se está na segunda parte, ajustar o índice atual para a posição relativa na segunda parte
      indice_segunda_parte = esta_na_primeira_parte ? -1 : indice_atual - (ponto_divisao + 1)
      html << render_timeline_steps(segunda_parte, indice_segunda_parte, indicadores, !esta_na_primeira_parte)
      html << "</div>"
    else
      # Fluxo normal sem retorno de testes
      html << render_timeline_normal(fluxo, indice_atual, indicadores)
    end

    html << "</div>"
    html << "</div>"

    html
  end

  def obter_texto_etapa_atual_timeline(etapa_atual)
    etapa_atual.gsub(/E\d{2}_/, "").gsub("_", " ")
  end

  # Método para renderizar a timeline da situação DESCONHECIDA
  # Método para renderizar a timeline da situação DESCONHECIDA
  def render_timeline_desconhecida(etapa_atual, motivo)
    html = ""
    html += "<div class='timeline-row'>"
    html += "<div class='timeline timeline-desconhecida'>"
    html += "<div class='timeline-step timeline-step-error'>"
    html += "<div class='timeline-circle'></div>"
    html += "<div class='timeline-label'>"
    html += "<div class='timeline-text'>#{obter_texto_etapa_atual_timeline(etapa_atual)}"

    # Adicionar o motivo se existir
    if motivo.present?
      html += "<br><br>#{motivo}"
    end

    html += "</div>"
    html += "</div>"
    html += "</div>"
    html += "</div>"
    html
  end

  # Método auxiliar para renderizar uma timeline simples de uma linha
  def render_timeline_normal(fluxo, indice_atual, indicadores)
    "<div class='timeline-row'>" + render_timeline_steps(fluxo, indice_atual, indicadores) + "</div>"
  end

  # Método auxiliar para renderizar os passos da timeline
  def render_timeline_steps(fluxo, indice_atual, indicadores, esta_na_parte_atual = true)
    Rails.logger.info(">>>> render_timeline_steps: #{fluxo}, #{indice_atual}, #{esta_na_parte_atual}")

    if (!indice_atual)
      return render_timeline_desconhecida(indicadores.etapa_atual, "Etapa não encontrada no fluxo")
    end

    html = "<div class='timeline'>"

    fluxo.each_with_index do |etapa, i|
      eh_ultima_etapa = i == fluxo.length - 1
      eh_versao_liberada_antes_testes = indicadores&.tarefa_fechada_sem_testes == "SIM"
      eh_situacao_final = [SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA, SkyRedminePlugin::Constants::EtapaAtual::FECHADA_SEM_DESENVOLVIMENTO].include?(etapa)

      estado = if (i < indice_atual)
          "completed"
        elsif eh_situacao_final && i == indice_atual
          "completed"  # Se é VERSAO_LIBERADA e é a etapa atual, mostra como concluída
        elsif i == indice_atual && esta_na_parte_atual
          "current"
        elsif eh_ultima_etapa && eh_versao_liberada_antes_testes && indicadores.etapa_atual != SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA
          "warning"
        else
          "future"
        end

      texto_etapa = obter_texto_etapa_atual_timeline(etapa)

      if (estado == "completed") || (estado == "current")
        # Adicionar o contador de retornos se for ESTOQUE_DEVEL_RETORNO_TESTES ou AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL
        if etapa == SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_DEVEL_RETORNO_TESTES &&
           indicadores&.qtd_retorno_testes_qs.to_i > 0
          texto_etapa += "<br>#{indicadores.qtd_retorno_testes_qs}x"
        elsif etapa == SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL &&
              indicadores&.qtd_retorno_testes_devel.to_i > 0
          texto_etapa += "<br>#{indicadores.qtd_retorno_testes_devel}x"
          # Adicionar o numero da versão estavel no VERSAO_LIBERADA ou VERSAO_LIBERADA_FALTA_FECHAR
        elsif [SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA, SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA_FALTA_FECHAR].include?(etapa)
          if indicadores&.versao_estavel.present?
            texto_etapa += "<br><br>#{indicadores.versao_estavel}"
          end
          # Adicionar o numero da versão de testes no ESTOQUE_QS ou ESTOQUE_QS_RETORNO_TESTES
        elsif [SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_QS, SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_QS_RETORNO_TESTES].include?(etapa)
          exibir_versao = true
          # somente exibe a versao de testes na situacao ESTOQUE_QS caso ela seja a current
          # se ela for completed somente exibir se a ESTOQUE_QS_RETORNO_TESTES nao exista ou ainda nao foi executada
          if (etapa == SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_QS)
            exibir_versao = esta_na_parte_atual
          end
          if (indicadores&.versao_teste.present? && exibir_versao)
            texto_etapa += "<br><br>#{indicadores.versao_teste}"
          end
        end

        # Adicionar a quantidade de dias que está na etapa atual
        if estado == "current"
          if !indicadores.data_etapa_atual.nil?
            #dias_na_etapa_atual = (Date.today - indicadores.data_etapa_atual).to_i
            #texto_situacao += "<br><br><a title='#{indicadores.data_etapa_atual&.strftime("%d/%m/%Y")}'> #{dias_na_etapa_atual} #{dias_na_etapa_atual == 1 ? "dia" : "dias"}</a>"
            texto_etapa += "<br><br><a title='#{indicadores.data_etapa_atual&.strftime("%d/%m/%Y")}'> #{time_ago_in_words(indicadores.data_etapa_atual)}</a>"
            Rails.logger.info(">>>> texto_situacao: #{texto_etapa}")
          end
        end
      end

      html << "<div class='timeline-step timeline-step-#{estado}'>"
      html << "<div class='timeline-circle'></div>"
      html << "<div class='timeline-label'>"
      html << "<div class='timeline-text'>#{texto_etapa}</div>"
      html << "</div>"
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
