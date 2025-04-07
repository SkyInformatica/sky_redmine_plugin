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
                            SkyRedminePlugin::Constants::EquipeResponsavel::QS,
                          ])
    when SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA
      scope = scope.where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA)
    end

    # Buscar as tarefas agrupadas por tipo e calcular tempo gasto
    tarefas_por_tipo = scope.group(:tipo_primeira_tarefa_devel).count
    tarefas_por_tipo_tempo_gasto = scope.group(:tipo_primeira_tarefa_devel)
      .sum("ROUND(CAST(COALESCE(tempo_gasto_devel, 0) + COALESCE(tempo_gasto_qs, 0) AS DECIMAL(10,1)), 1)")

    # Criar scope apenas para tarefas fechadas
    scope_fechadas = scope.where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA)

    # Buscar quantidade de tarefas por retorno de testes (apenas fechadas)
    tarefas_por_retorno_testes = scope_fechadas.group(:qtd_retorno_testes_qs).count

    # Buscar quantidade de tarefas fechadas sem testes (apenas fechadas)
    tarefas_fechadas_sem_testes = scope_fechadas.group(:tarefa_fechada_sem_testes).count

    # Calcular tempos médios para tarefas fechadas
    tempo_medio_andamento_devel = scope_fechadas.average(:tempo_andamento_devel)
    tempo_medio_resolucao_devel = scope_fechadas.average(:tempo_resolucao_devel)
    tempo_medio_para_encaminhar_qs = scope_fechadas.average(:tempo_para_encaminhar_qs)

    # Calcular tempos médios do QS
    tempo_medio_andamento_qs = scope_fechadas.average(:tempo_andamento_qs)
    tempo_medio_resolucao_qs = scope_fechadas.average(:tempo_resolucao_qs)

    # Calcular tempos médios adicionais
    tempo_medio_concluido_testes_versao_liberada = scope_fechadas.average(:tempo_concluido_testes_versao_liberada)
    tempo_medio_fechamento_devel = scope_fechadas.average(:tempo_fechamento_devel)

    {
      scope: scope,
      tarefas_por_tipo: tarefas_por_tipo,
      tarefas_por_tipo_tempo_gasto: tarefas_por_tipo_tempo_gasto,
      tarefas_por_retorno_testes: tarefas_por_retorno_testes,
      tarefas_fechadas_sem_testes: tarefas_fechadas_sem_testes,
      tempo_medio_andamento_devel: tempo_medio_andamento_devel,
      tempo_medio_resolucao_devel: tempo_medio_resolucao_devel,
      tempo_medio_para_encaminhar_qs: tempo_medio_para_encaminhar_qs,
      tempo_medio_andamento_qs: tempo_medio_andamento_qs,
      tempo_medio_resolucao_qs: tempo_medio_resolucao_qs,
      tempo_medio_concluido_testes_versao_liberada: tempo_medio_concluido_testes_versao_liberada,
      tempo_medio_fechamento_devel: tempo_medio_fechamento_devel,
    }
  end
end
