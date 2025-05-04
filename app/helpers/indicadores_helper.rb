module IndicadoresHelper
  def render_graficos_geral(dados_graficos)
    content_tag(:div, class: "graficos-container") do
      safe_join([
        # Primeira linha - Cards de valores
        render_cards_row([
          render_card_valor(
            "Total de tarefas",
            dados_graficos[:tarefas_desenvolvimento].count,
            "Total de tarefas de desenvolvimento (Defeito, Funcionalidade, Retorno de testes, Conversão) no período selecionado",
            "Complementares: #{dados_graficos[:tarefas_complementar].count}"
          ),
          render_card_valor(
            "Desenvolvimento",
            dados_graficos[:tarefas_desenvolvimento].where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL).count,
            "Total de tarefas abertas sob responsabilidade do desenvolvimento no período selecionado",
            "Tarefas abertas sob responsabilidade do desenvolvimento"
          ),
          render_card_valor(
            "QS",
            dados_graficos[:tarefas_desenvolvimento].where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::QS).count,
            "Total de tarefas aberta sob responsabilidade da QS no período selecionado",
            "Tarefas abertas sob responsabilidade do QS",
          ),
          render_card_valor(
            "Versão liberada",
            dados_graficos[:tarefas_desenvolvimento].where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA).count,
            "Total de tarefas com versão liberada no período selecionado",
            "Tarefas com versão liberada no período selecionado",
          ),
        ]),

        # Segunda linha - Cards de gráficos
        render_cards_row([
          render_card_grafico(
            "Tempo gasto em horas de todas as tarefas",
            "doughnut",
            dados_graficos[:tempo_gasto_por_tipo_todas_tarefas],
            "Total do tempo gasto em horas por tipo de tarefa",
            "Total do tempo gasto do desenvolvimento + QS"
          ),
          render_card_grafico(
            "Tarefas de desenvolvimento",
            "bar",
            dados_graficos[:tarefas_devel_por_tipo],
            "Distribuição das tarefas por tipo no período selecionado",
            "Total de tarefas agrupadas por tipo"
          ),
        ]),

        # Terceira linha - Cards de gráficos
        render_cards_row([
          render_card_grafico(
            "Retornos de Testes",
            "bar",
            dados_graficos[:tarefas_devel_por_retorno_testes],
            "Quantidade de vezes que as tarefas retornaram dos testes",
            "Total de tarefas agrupadas por quantidade de retornos de testes"
          ),
          render_card_grafico(
            "Tarefas fechadas sem testes",
            "bar",
            dados_graficos[:tarefas_devel_fechadas_sem_testes],
            "Tarefas que foram fechadas antes de passar por testes",
            "Total de tarefas fechadas sem passar por testes"
          ),
        ]),

        # Quarta linha - Cards dos gráficos de tempos médios
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
          render_card_grafico(
            "Tempos médios de liberação versão",
            "bar",
            {
              "Após testes" => dados_graficos[:tempo_medio_concluido_testes_versao_liberada].to_f || 0,
              "Após concluir desenvolvimento" => dados_graficos[:tempo_medio_fechamento_devel].to_f || 0,
            },
            "Gráfico de barras com os tempos médios para liberar a versão. Após concluir o desenvolvimento inclui o tempo total entre a tarefa desenvolvimento ficar pronta, testar e liberar a versão",
            "Tempos médios em dias para tarefas fechadas"
          ),
        ]),
      ])
    end
  end

  def render_graficos_etapas(dados_graficos_etapas)
    content_tag(:div, class: "graficos-container") do
      safe_join([
        render_cards_row([
          render_card_valor(
            "Total de tarefas",
            100,
            "Total de tarefas de desenvolvimento (Defeito, Funcionalidade, Retorno de testes, Conversão) no período selecionado",
            "teste"
          ),
          render_card_grafico(
            "Tarefas desenvolvimento em aberto por etapa",
            "bar",
            dados_graficos_etapas[:tarefas_devel_por_etapa],
            "Distribuição das tarefas em desenvolvimento em aberto por etapa atual (nao contabiliza as etapas E99_, E08_ e EM_ANDAMENTO)",
            "Total de tarefas na fila de cada etapa"
          ),
        ]),

        render_cards_row([
          render_card_grafico(
            "E01_ESTOQUE_DEVEL",
            "bar",
            dados_graficos_etapas[:tarefas_devel_por_etapa_por_mes_histograma]["E01_ESTOQUE_DEVEL"],
            "Distribuição temporal das tarefas em estoque",
            "Total de tarefas: #{dados_graficos_etapas[:tarefas_devel_por_etapa]["E01_ESTOQUE_DEVEL"]}",
            2
          ),
        ]),

        render_cards_row([
          render_card_grafico(
            "E04_AGUARDA_ENCAMINHAR_QS",
            "bar",
            dados_graficos_etapas[:tarefas_devel_por_etapa_por_mes_histograma]["E04_AGUARDA_ENCAMINHAR_QS"],
            "Distribuição temporal das tarefas aguardando encaminhamento para QS",
            "Total de tarefas: #{dados_graficos_etapas[:tarefas_devel_por_etapa]["E04_AGUARDA_ENCAMINHAR_QS"]}",
            1
          ),
        ]),
      ])
    end
  end

  # Adicione esta nova função
  def render_filtros(periodo_atual, equipe_atual, project)
    content_tag(:div, class: "filtros-section") do
      form_with(url: indicadores_path(project), method: :get, local: true, class: "filtros-form") do
        content_tag(:div, class: "filtros-container") do
          safe_join([
            render_filtro_grupo(
              "periodo",
              "Período:",
              options_for_select([
                ["Todo o período", "all"],
                ["Este mês", "current_month"],
                ["Último mês", "last_month"],
                ["Este ano", "current_year"],
              ], selected: periodo_atual)
            ),
            render_filtro_grupo(
              "equipe",
              "Responsável atual:",
              options_for_select([
                ["Todas", "all"],
                ["Desenvolvimento", SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL],
                ["QS", SkyRedminePlugin::Constants::EquipeResponsavel::QS],
                ["Desenvolvimento+QS", "#{SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL}_#{SkyRedminePlugin::Constants::EquipeResponsavel::QS}"],
                ["Versão liberada", SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA],
              ], selected: equipe_atual)
            ),
            content_tag(:button, "Filtrar", type: "submit", class: "filtro-submit"),
          ])
        end
      end
    end
  end

  private

  # Adicione esta nova função auxiliar
  def render_filtro_grupo(campo, label_texto, options)
    content_tag(:div, class: "filtro-grupo") do
      safe_join([
        label_tag(campo, label_texto),
        select_tag(campo, options),
      ])
    end
  end

  private

  def render_cards_row(cards)
    content_tag(:div, class: "cards-row") do
      safe_join(cards)
    end
  end

  def render_card_grafico(titulo, tipo_grafico, dados, tooltip, descricao = nil, cards_por_linha = 3)
    # Determina a classe CSS baseada no número de cards por linha
    layout_class = case cards_por_linha
      when 1 then "card-grafico-full"
      when 2 then "card-grafico-half"
      else "card-grafico-third"
      end

    content_tag(:div, class: "card-grafico #{layout_class}") do
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
