module IndicadoresHelper
 

  def render_graficos_container(dados_graficos)
    content_tag(:div, class: 'graficos-container') do
      [
        # Cards de valores
        render_card_valor(
          'Total de Tarefas',
          dados_graficos[:scope].count,
          'Total de tarefas no período selecionado',
          'Todas as tarefas registradas'
        ),
        render_card_valor(
          'Em Desenvolvimento',
          dados_graficos[:scope].where(equipe_responsavel_atual: 'DEVEL').count,
          'Total de tarefas em desenvolvimento',
          'Tarefas atualmente com a equipe de desenvolvimento'
        ),
        render_card_valor(
          'Em QS',
          dados_graficos[:scope].where(equipe_responsavel_atual: 'QS').count,
          'Total de tarefas em QS',
          'Tarefas atualmente com a equipe de qualidade',
          '50 % subindo'
        ),
        render_card_valor(
          'Fechadas',
          dados_graficos[:scope].where(equipe_responsavel_atual: 'FECHADA').count,
          'Total de tarefas fechadas',
          'Tarefas que foram concluídas'
        ),
        # Gráficos existentes
        render_card_grafico(
          'Tarefas por Tipo', 
          'bar', 
          dados_graficos[:tarefas_por_tipo],
          'Distribuição das tarefas por tipo no período selecionado',
          'Total de tarefas agrupadas por tipo'
        ),
        render_card_grafico(
          'Tarefas por Status', 
          'bar', 
          dados_graficos[:tarefas_por_status],
          'Distribuição das tarefas por status no período selecionado',
          'Total de tarefas agrupadas por status'
        )
      ].join.html_safe
    end
  end

  private

  def render_card_grafico(titulo, tipo_grafico, dados, tooltip, descricao = nil)
    content_tag(:div, class: 'card-grafico') do
      [
        render_card_header(titulo, tooltip),
        content_tag(:div, class: 'card-body') do
          content_tag(:canvas, '', data: {
            grafico: {
              tipo: tipo_grafico,
              dados: dados
            }.to_json
          })
        end,
        render_card_footer(descricao)
      ].join.html_safe
    end
  end

  def render_card_valor(titulo, valor, tooltip, descricao = nil, tendencia = nil)
    content_tag(:div, class: 'card-valor') do
      [
        render_card_header(titulo, tooltip),
        content_tag(:div, class: 'card-body') do
          [
            content_tag(:div, valor, class: 'valor-principal'),
            tendencia ? content_tag(:div, tendencia, class: 'valor-tendencia') : nil
          ].compact.join.html_safe
        end,
        render_card_footer(descricao)
      ].join.html_safe
    end
  end

  def render_card_header(titulo, tooltip)
    content_tag(:div, class: 'card-header') do
      [
        content_tag(:h3, titulo, class: 'card-titulo'),
        render_tooltip(tooltip)
      ].join.html_safe
    end
  end

  def render_card_footer(descricao)
    return nil unless descricao.present?
    
    content_tag(:div, class: 'card-footer') do
      content_tag(:p, descricao, class: 'card-descricao')
    end
  end

  def render_tooltip(texto)
    return nil unless texto.present?

    content_tag(:div, class: 'tooltip-container') do
      content_tag(:i, '', class: 'fa fa-info-circle', title: texto)
    end
  end
end 