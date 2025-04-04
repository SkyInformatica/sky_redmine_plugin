class IndicadoresService

  def self.obter_dados_graficos(project, periodo = "all", equipe = "all")
    # Determinar o período com base no parâmetro recebido
    case periodo
    when "current_month"
      start_date = Date.current.beginning_of_month
      end_date = Date.current.end_of_month
    when "last_month"
      start_date = (Date.current - 1.month).beginning_of_month
      end_date = (Date.current - 1.month).end_of_month
    when "current_year"
      start_date = Date.current.beginning_of_year
      end_date = Date.current.end_of_year
    else
      start_date = nil
      end_date = nil
    end

    # Buscar os registros com base no período
    scope = SkyRedmineIndicadores.por_projeto_e_periodo(project, start_date, end_date)

    # Aplicar filtro por equipe
    case equipe
    when SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL
      scope = scope.where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL)
    when SkyRedminePlugin::Constants::EquipeResponsavel::QS
      scope = scope.where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::QS)
    when "#{SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL}_#{SkyRedminePlugin::Constants::EquipeResponsavel::QS}"
      scope = scope.where(equipe_responsavel_atual: [
        SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL,
        SkyRedminePlugin::Constants::EquipeResponsavel::QS
      ])
    when SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA
      scope = scope.where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA)
    end

    # Buscar as tarefas agrupadas por tipo e status usando os métodos da entidade
    tarefas_por_tipo = scope.group(:tipo_primeira_tarefa_devel).count
    tarefas_por_status = scope.group(:status_ultima_tarefa_devel).count

    {
      scope: scope,
      tarefas_por_tipo: tarefas_por_tipo,
      tarefas_por_status: tarefas_por_status
    }
  end
end 