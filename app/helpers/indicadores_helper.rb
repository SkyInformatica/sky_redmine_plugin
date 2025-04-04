module IndicadoresHelper
  def render_graficos_container(dados_graficos)
    content_tag(:div, class: "graficos-container") do
      safe_join([
        # Primeira linha - Cards de valores
        render_cards_row([
          render_card_valor(
            "Total de tarefas",
            dados_graficos[:scope].count,
            "Total de tarefas no período selecionado",
            "Geral"
          ),
          render_card_valor(
            "Desenvolvimento",
            dados_graficos[:scope].where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL).count,
            "Total de tarefas abertas sob responsabilidade do desenvolvimento no período selecionado",
            "Tarefas abertas sob responsabilidade do desenvolvimento"
          ),
          render_card_valor(
            "QS",
            dados_graficos[:scope].where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::QS).count,
            "Total de tarefas aberta sob responsabilidade da QS no período selecionado",
            "Tarefas abertas sob responsabilidade do QS",
          ),
          render_card_valor(
            "Fechadas",
            dados_graficos[:scope].where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA).count,
            "Total de tarefas fechadas no período selecionado",
            "Tarefas fechadas no período selecionado",
          ),
        ]),

        # Segunda linha - Cards de gráficos
        render_cards_row([
          render_card_grafico(
            "Tarefas por Tipo",
            "bar",
            dados_graficos[:tarefas_por_tipo],
            "Distribuição das tarefas por tipo no período selecionado",
            "Total de tarefas agrupadas por tipo"
          ),
          render_card_grafico(
            "Tempo gasto em horas por tipo",
            "doughnut",
            dados_graficos[:tarefas_por_tipo_tempo_gasto],
            "Total do tempo gasto em horas por tipo de tarefa",
            "Total do tempo gasto do desenvolvimento + QS"
          ),
        ]),

        # Terceira linha - Cards de gráficos
        render_cards_row([
          render_card_grafico(
            "Retornos de Testes",
            "bar",
            dados_graficos[:tarefas_por_retorno_testes],
            "Quantidade de vezes que as tarefas retornaram dos testes",
            "Total de tarefas agrupadas por quantidade de retornos de testes"
          ),
          render_card_grafico(
            "Tarefas fechadas sem testes",
            "bar",
            dados_graficos[:tarefas_fechadas_sem_testes],
            "Tarefas que foram fechadas antes de passar por testes",
            "Total de tarefas fechadas sem passar por testes"
          ),
        ]),

        # Quarta linha - Card do gráfico de tempos médios
        render_cards_row([
          render_card_grafico(
            "Tempos médios do desenvolvimento",
            "bar",
            {
              "Andamento" => dados_graficos[:tempo_medio_andamento_devel].to_f || 0,
              "Resolução" => dados_graficos[:tempo_medio_resolucao_devel].to_f || 0,
              "Encaminhar QS" => dados_graficos[:tempo_medio_para_encaminhar_qs].to_f || 0,
            },
            "Gráfico de barras com os tempos médios de andamento, resolução e encaminhamento ao QS para tarefas fechadas",
            "Tempos médios em dias para tarefas fechadas"
          ),
          render_card_grafico(
            "Tempos médios do QS",
            "bar",
            {
              "Iniciar Testes" => dados_graficos[:tempo_medio_andamento_qs].to_f || 0,
              "Concluir Testes" => dados_graficos[:tempo_medio_resolucao_qs].to_f || 0,
            },
            "Gráfico de barras com os tempos médios de início e conclusão de testes para tarefas fechadas",
            "Tempos médios em dias para tarefas fechadas"
          ),
        ]),
      ])
    end
  end

  private

  def render_cards_row(cards)
    content_tag(:div, class: "cards-row") do
      safe_join(cards)
    end
  end

  def render_card_grafico(titulo, tipo_grafico, dados, tooltip, descricao = nil)
    content_tag(:div, class: "card-grafico") do
      [
        render_card_header(titulo, tooltip),
        content_tag(:div, descricao, class: "card-subtitulo"),
        content_tag(:div, class: "card-body") do
          content_tag(:canvas, "", data: {
                                     grafico: {
                                       tipo: tipo_grafico,
                                       dados: dados,
                                     }.to_json,
                                   })
        end,
      ].join.html_safe
    end
  end

  def render_card_valor(titulo, valor, tooltip, descricao = nil, tendencia = nil)
    content_tag(:div, class: "card-valor") do
      [
        render_card_header(titulo, tooltip),
        content_tag(:div, class: "card-body") do
          [
            content_tag(:div, valor, class: "valor-principal"),
            tendencia ? content_tag(:div, tendencia, class: "valor-tendencia") : nil,
          ].compact.join.html_safe
        end,
        render_card_footer(descricao),
      ].join.html_safe
    end
  end

  def render_card_header(titulo, tooltip)
    content_tag(:div, class: "card-header") do
      [
        content_tag(:h3, titulo, class: "card-titulo"),
        render_tooltip(tooltip),
      ].join.html_safe
    end
  end

  def render_card_footer(descricao)
    return nil unless descricao.present?

    content_tag(:div, class: "card-footer") do
      content_tag(:p, descricao, class: "card-descricao")
    end
  end

  def render_tooltip(texto)
    return nil unless texto.present?

    content_tag(:div, class: "tooltip-container") do
      content_tag(:i, "", class: "fa fa-info-circle",
                          data: {
                            bs_toggle: "tooltip",
                            bs_placement: "top",
                            bs_title: texto,
                          })
    end
  end

  def gerar_grafico_tempos_medios_qs(indicadores)
    data = {
      labels: ["Iniciar Testes", "Concluir Testes"],
      datasets: [
        {
          label: "Tempos Médios do QS (dias)",
          backgroundColor: ["#36A2EB", "#FF6384"],
          data: [
            indicadores.tempo_medio_andamento_qs || 0,
            indicadores.tempo_medio_resolucao_qs || 0,
          ],
        },
      ],
    }

    options = {
      responsive: true,
      plugins: {
        legend: { position: "top" },
        tooltip: { enabled: true },
      },
    }

    render_chart("bar", data, options)
  end
end
