module IndicadoresHelper
 

  def render_graficos_container(dados_graficos)
    html = []
    
    html << "<div class='graficos-container'>"
    html << "<div class='grafico'>"
    html << "<h3>#{l(:label_tarefas_por_tipo)}</h3>"
    html << pie_chart(dados_graficos[:tarefas_por_tipo])
    html << "</div>"

    html << "<div class='grafico'>"
    html << "<h3>#{l(:label_tarefas_por_status)}</h3>"
    html << column_chart(dados_graficos[:tarefas_por_status])
    html << "</div>"
    html << "</div>"

    html.join("\n").html_safe
  end
end 