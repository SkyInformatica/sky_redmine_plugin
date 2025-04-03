class IndicadoresService
  def self.obter_dados_graficos(project, periodo)
    # Determinar o período com base no parâmetro recebido
    start_date, end_date = case periodo
    when "current_month"
      [Date.current.beginning_of_month, Date.current.end_of_month]
    when "last_month"
      [(Date.current - 1.month).beginning_of_month, (Date.current - 1.month).end_of_month]
    when "current_year"
      [Date.current.beginning_of_year, Date.current.end_of_year]
    else
      [nil, nil]
    end

    {
      tarefas_por_tipo: SkyRedmineIndicadores.tarefas_por_tipo(project, start_date, end_date),
      tarefas_por_status: SkyRedmineIndicadores.tarefas_por_status(project, start_date, end_date)
    }
  end
end 