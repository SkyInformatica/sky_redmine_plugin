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
    tarefas = SkyRedmineIndicadores.por_projeto_e_periodo(project, start_date, end_date)

    # Aplicar filtro por equipe
    case equipe
    when SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL
      tarefas = tarefas.where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL)
    when SkyRedminePlugin::Constants::EquipeResponsavel::QS
      tarefas = tarefas.where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::QS)
    when "#{SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL}_#{SkyRedminePlugin::Constants::EquipeResponsavel::QS}"
      tarefas = tarefas.where(equipe_responsavel_atual: [
                                SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL,
                                SkyRedminePlugin::Constants::EquipeResponsavel::QS,
                              ])
    when SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA
      tarefas = tarefas.where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA)
    end

    tarefas_desenvolvimento = tarefas.where(tarefa_complementar: "NAO")
    tarefas_complementar = tarefas.where(tarefa_complementar: "SIM")

    # Buscar as tarefas agrupadas por tipo e calcular tempo gasto
    tempo_gasto_por_tipo_todas_tarefas = tarefas.group(:tipo_primeira_tarefa_devel)
      .sum("ROUND(CAST(COALESCE(tempo_gasto_devel, 0) + COALESCE(tempo_gasto_qs, 0) AS DECIMAL(10,1)), 1)")

    # Tarefas de desenvolvimento agrupadas por tipo
    tarefas_devel_por_tipo = tarefas_desenvolvimento.group(:tipo_primeira_tarefa_devel).count

    # Criar tarefas apenas para tarefas fechadas
    tarefas_devel_fechadas = tarefas_desenvolvimento.where(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA)

    # Buscar quantidade de tarefas por retorno de testes (apenas fechadas)
    tarefas_devel_por_retorno_testes = tarefas_devel_fechadas.group(:qtd_retorno_testes_qs).count

    # Buscar quantidade de tarefas fechadas sem testes (apenas fechadas)
    tarefas_devel_fechadas_sem_testes = tarefas_devel_fechadas.group(:tarefa_fechada_sem_testes).count

    # Calcular tempos médios para tarefas fechadas
    tempo_medio_andamento_devel = tarefas_devel_fechadas.average(:tempo_andamento_devel)
    tempo_medio_resolucao_devel = tarefas_devel_fechadas.average(:tempo_resolucao_devel)
    tempo_medio_para_encaminhar_qs = tarefas_devel_fechadas.average(:tempo_para_encaminhar_qs)

    # Calcular tempos médios do QS
    tempo_medio_andamento_qs = tarefas_devel_fechadas.average(:tempo_andamento_qs)
    tempo_medio_resolucao_qs = tarefas_devel_fechadas.average(:tempo_resolucao_qs)

    # Calcular tempos médios adicionais
    tempo_medio_concluido_testes_versao_liberada = tarefas_devel_fechadas.average(:tempo_concluido_testes_versao_liberada)
    tempo_medio_fechamento_devel = tarefas_devel_fechadas.average(:tempo_fechamento_devel)

    {
      tarefas: tarefas,
      tarefas_desenvolvimento: tarefas_desenvolvimento,
      tarefas_complementar: tarefas_complementar,

      tempo_gasto_por_tipo_todas_tarefas: tempo_gasto_por_tipo_todas_tarefas,

      tarefas_devel_por_tipo: tarefas_devel_por_tipo,
      tarefas_devel_por_retorno_testes: tarefas_devel_por_retorno_testes,
      tarefas_devel_fechadas_sem_testes: tarefas_devel_fechadas_sem_testes,

      tempo_medio_andamento_devel: tempo_medio_andamento_devel,
      tempo_medio_resolucao_devel: tempo_medio_resolucao_devel,
      tempo_medio_para_encaminhar_qs: tempo_medio_para_encaminhar_qs,
      tempo_medio_andamento_qs: tempo_medio_andamento_qs,
      tempo_medio_resolucao_qs: tempo_medio_resolucao_qs,
      tempo_medio_concluido_testes_versao_liberada: tempo_medio_concluido_testes_versao_liberada,
      tempo_medio_fechamento_devel: tempo_medio_fechamento_devel,
    }
  end

  def self.obter_dados_graficos_etapas(project)
    # Obter dados de gráficos para etapas
    tarefas = SkyRedmineIndicadores.por_projeto_e_periodo(project, nil, nil)
    tarefas_por_etapa = tarefas.group(:etapa_atual).count

    # Agrupar etapas similares (removendo _RT)
    tarefas_devel_por_etapa = {}
    tarefas_por_etapa.each do |etapa, quantidade|
      # Ignorar etapas que começam com E99_ ou E02_EM_ANDAMENTO_
      next if etapa.to_s.start_with?("E99_", "E02_EM_ANDAMENTO", "E06_EM_ANDAMENTO", "E08_")

      if etapa.to_s.start_with?("E07_AGUARDA_ENCAMINHAR_RT")
        etapa_base = etapa
      else
        # remover o sufixo _RT
        # Exemplo: "E01_ESTOQUE_DEVEL_RT" se torna "E01_ESTOQUE_DEVEL"
        etapa_base = etapa.to_s.gsub(/_RT$/, "")
      end

      tarefas_devel_por_etapa[etapa_base] ||= 0
      tarefas_devel_por_etapa[etapa_base] += quantidade
    end

    {
      tarefas_devel_por_etapa: tarefas_devel_por_etapa,
    }
  end
end
