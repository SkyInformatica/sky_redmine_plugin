class IndicadoresService
  def self.obter_dados_graficos(tarefas, equipe)
    # Determinar o período com base no parâmetro recebido

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

  def self.obter_dados_graficos_etapas(tarefas)
    Rails.logger.info ">>> obter_dados_graficos_etapas"

    tarefas_devel = tarefas
      .where(tarefa_complementar: "NAO")
      .where.not(equipe_responsavel_atual: SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA)

    tarefas_devel_por_etapa = tarefas_devel
      .order(:etapa_atual)
      .group(:etapa_atual)
      .count

    # Criar histograma diretamente no formato final
    data_atual = Date.today
    histograma_por_etapa = {}

    tarefas_devel.each do |tarefa|
      next unless tarefa.data_etapa_atual && tarefa.etapa_atual

      periodo = determinar_periodo(tarefa.data_etapa_atual.to_date, data_atual)
      next unless periodo

      # Processar etapa
      etapa_base = if tarefa.etapa_atual.to_s.start_with?("E07_AGUARDA_ENCAMINHAR_RT")
          tarefa.etapa_atual
        else
          tarefa.etapa_atual.to_s.gsub(/_RT$/, "")
        end

      # Criar rótulo do período
      rotulo = case periodo
        when "maior_2_anos"
          "Maior que 2 anos"
        when "maior_1_ano"
          "Maior que 1 ano"
        else
          (Date.today - periodo.to_i.months).strftime("%Y.%m")
        end

      # Inicializar estruturas se necessário
      histograma_por_etapa[etapa_base] ||= {}
      histograma_por_etapa[etapa_base][rotulo] ||= 0
      histograma_por_etapa[etapa_base][rotulo] += 1
    end

    # Definir períodos na ordem correta (do mais recente para o mais antigo)
    periodos = (0..11).map { |m| (Date.today - m.months).strftime("%Y.%m") }
    periodos_ordenados = periodos + ["Maior que 1 ano", "Maior que 2 anos"]

    # Garantir que todas as etapas tenham todos os períodos e ordenar
    histograma_por_etapa.each do |etapa, dados|
      # Criar hash temporário com todos os períodos zerados
      dados_ordenados = {}
      periodos_ordenados.each do |periodo|
        dados_ordenados[periodo] = dados[periodo] || 0
      end
      # Substituir dados originais pelos ordenados
      histograma_por_etapa[etapa] = dados_ordenados
    end

    {
      tarefas_devel: tarefas_devel,
      tarefas_devel_total: tarefas_devel.count,
      tarefas_devel_por_etapa: tarefas_devel_por_etapa,
      tarefas_devel_por_etapa_por_mes_histograma: histograma_por_etapa,
    }
  end
  # Função auxiliar para determinar o período
  def self.determinar_periodo(data_etapa, data_atual)
    return nil unless data_etapa

    meses_diferenca = ((data_atual.year * 12 + data_atual.month) -
                       (data_etapa.year * 12 + data_etapa.month))

    if meses_diferenca >= 24
      "maior_2_anos"
    elsif meses_diferenca >= 12
      "maior_1_ano"
    elsif meses_diferenca >= 0
      meses_diferenca # retorna o número do mês (0 a 11)
    end
  end
end
