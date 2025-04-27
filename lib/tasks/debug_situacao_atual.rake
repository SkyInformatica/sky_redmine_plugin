# para executar o rake, use o seguinte comando:
# RAILS_ENV=production rake sky_redmine_plugin:debug_situacao_atual[65408]

namespace :sky_redmine_plugin do
  desc "Depura a situação atual e tarefas relacionadas para uma tarefa específica. Uso: rake sky_redmine_plugin:debug_situacao_atual[TAREFA_ID]"
  task :debug_situacao_atual, [:tarefa_id] => :environment do |t, args|
    if args[:tarefa_id].blank?
      puts "Erro: É necessário fornecer o ID da tarefa. Exemplo: RAILS_ENV=production rake sky_redmine_plugin:debug_situacao_atual[12345]"
      exit 1
    end

    tarefa_id = args[:tarefa_id].to_i
    puts "=== Depurando situação atual para tarefa ID: #{tarefa_id} ==="
    begin
      issue = Issue.find(tarefa_id)
    rescue ActiveRecord::RecordNotFound
      puts "Erro: Tarefa com ID #{tarefa_id} não encontrada."
      exit 1
    end

    # Obter tarefas relacionadas
    tarefas_relacionadas = SkyRedminePlugin::TarefasRelacionadas.obter_lista_tarefas_relacionadas(issue)

    # Separar tarefas por equipe
    tarefas_devel = tarefas_relacionadas.select { |t| t.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL }
    tarefas_qs = tarefas_relacionadas.select { |t| t.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::QS }

    # Exibir ciclos de desenvolvimento
    ciclos_devel = SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_devel(tarefas_relacionadas)
    # Exibir ciclos de teste
    ciclos_qs = SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_qs(tarefas_relacionadas)

    # Processar indicadores
    SkyRedminePlugin::Indicadores.processar_indicadores(issue)

    primeira_tarefa = tarefas_relacionadas.first
    if !primeira_tarefa
      return
    end

    indicador = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: primeira_tarefa.id)

    # Gerar JSON das tarefas relacionadas
    json_tarefas = tarefas_relacionadas.map do |tarefa|
      {
        id: tarefa.id,
        projeto: tarefa.project.name,
        tipo: tarefa.tracker.name,
        status: tarefa.status.name,
        sprint: tarefa.fixed_version.present? ? tarefa.fixed_version.name : nil,
        tempo_estimado: tarefa.estimated_hours,
        tempo_gasto: tarefa.spent_hours,
        prioridade: tarefa.priority.name,
        equipe_responsavel: tarefa.equipe_responsavel,
        tarefa_complementar: tarefa.tarefa_complementar,
        teste_no_desenvolvimento: tarefa.teste_no_desenvolvimento,
        teste_qs: tarefa.teste_qs,
        datas: {
          data_criacao: tarefa.data_criacao&.strftime("%d/%m/%Y"),
          data_atendimento: tarefa.data_atendimento&.strftime("%d/%m/%Y"),
          data_em_andamento: tarefa.data_em_andamento&.strftime("%d/%m/%Y"),
          data_resolvida: tarefa.data_resolvida&.strftime("%d/%m/%Y"),
          data_fechada: tarefa.data_fechada&.strftime("%d/%m/%Y"),
        },
      }
    end

    # Adicionar informações do indicador se existir
    json_resultado = {
      tarefa_id: tarefa_id,
      tarefas_relacionadas: json_tarefas,
      ciclos_desenvolvimento: ciclos_devel.map.with_index { |ciclo, i|
        {
          numero: i + 1,
          tarefas: ciclo.map { |t| { id: t.id, tipo: t.tracker.name, status: t.status.name } },
        }
      },
      ciclos_qs: ciclos_qs.map.with_index { |ciclo, i|
        {
          numero: i + 1,
          tarefas: ciclo.map { |t| { id: t.id, tipo: t.tracker.name, status: t.status.name } },
        }
      },
    }

    # Adicionar indicador ao JSON se existe
    if indicador
      json_resultado[:indicador] = {
        # Campos de identificação das tarefas DEVEL
        primeira_tarefa_devel_id: indicador.primeira_tarefa_devel_id,
        tipo_primeira_tarefa_devel: indicador.tipo_primeira_tarefa_devel,
        ultima_tarefa_devel_id: indicador.ultima_tarefa_devel_id,
        status_ultima_tarefa_devel: indicador.status_ultima_tarefa_devel,

        # Informações da primeira tarefa DEVEL
        prioridade_primeira_tarefa_devel: indicador.prioridade_primeira_tarefa_devel,
        projeto_primeira_tarefa_devel: indicador.projeto_primeira_tarefa_devel,
        sprint_primeira_tarefa_devel: indicador.sprint_primeira_tarefa_devel,
        origem_primeira_tarefa_devel: indicador.origem_primeira_tarefa_devel,
        skynet_primeira_tarefa_devel: indicador.skynet_primeira_tarefa_devel,

        # Sprints
        sprint_ultima_tarefa_devel: indicador.sprint_ultima_tarefa_devel,

        # Campos de controle e status
        tarefa_complementar: indicador.tarefa_complementar,
        teste_no_desenvolvimento: indicador.teste_no_desenvolvimento,
        equipe_responsavel_atual: indicador.equipe_responsavel_atual,
        situacao_atual: indicador.situacao_atual,

        # Tempos DEVEL
        tempo_estimado_devel: indicador.tempo_estimado_devel,
        tempo_gasto_devel: indicador.tempo_gasto_devel,

        # Contadores de retorno
        qtd_retorno_testes_qs: indicador.qtd_retorno_testes_qs,
        qtd_retorno_testes_devel: indicador.qtd_retorno_testes_devel,

        # Datas DEVEL
        data_atendimento_primeira_tarefa_devel: indicador.data_atendimento_primeira_tarefa_devel,
        data_criacao_ou_atendimento_primeira_tarefa_devel: indicador.data_criacao_ou_atendimento_primeira_tarefa_devel,
        data_andamento_primeira_tarefa_devel: indicador.data_andamento_primeira_tarefa_devel,
        data_resolvida_ultima_tarefa_devel: indicador.data_resolvida_ultima_tarefa_devel,
        data_fechamento_ultima_tarefa_devel: indicador.data_fechamento_ultima_tarefa_devel,

        # Tempos de processamento DEVEL
        tempo_andamento_devel: indicador.tempo_andamento_devel,
        tempo_resolucao_devel: indicador.tempo_resolucao_devel,
        tempo_fechamento_devel: indicador.tempo_fechamento_devel,
        tempo_para_encaminhar_qs: indicador.tempo_para_encaminhar_qs,

        # Campos de identificação das tarefas QS
        primeira_tarefa_qs_id: indicador.primeira_tarefa_qs_id,
        ultima_tarefa_qs_id: indicador.ultima_tarefa_qs_id,
        status_ultima_tarefa_qs: indicador.status_ultima_tarefa_qs,

        # Informações das tarefas QS
        sprint_primeira_tarefa_qs: indicador.sprint_primeira_tarefa_qs,
        sprint_ultima_tarefa_qs: indicador.sprint_ultima_tarefa_qs,
        projeto_primeira_tarefa_qs: indicador.projeto_primeira_tarefa_qs,

        # Tempos QS
        tempo_estimado_qs: indicador.tempo_estimado_qs,
        tempo_gasto_qs: indicador.tempo_gasto_qs,

        # Status e controles QS
        houve_teste_nok: indicador.houve_teste_nok,

        # Datas QS
        data_criacao_primeira_tarefa_qs: indicador.data_criacao_primeira_tarefa_qs,
        data_andamento_primeira_tarefa_qs: indicador.data_andamento_primeira_tarefa_qs,
        data_resolvida_ultima_tarefa_qs: indicador.data_resolvida_ultima_tarefa_qs,
        data_fechamento_ultima_tarefa_qs: indicador.data_fechamento_ultima_tarefa_qs,

        # Tempos de processamento QS
        tempo_andamento_qs: indicador.tempo_andamento_qs,
        tempo_resolucao_qs: indicador.tempo_resolucao_qs,
        tempo_fechamento_qs: indicador.tempo_fechamento_qs,

        # Tempos totais e controles gerais
        tempo_concluido_testes_versao_liberada: indicador.tempo_concluido_testes_versao_liberada,
        tempo_total_liberar_versao: indicador.tempo_total_liberar_versao,
        tempo_total_testes: indicador.tempo_total_testes,
        tempo_total_devel: indicador.tempo_total_devel,
        tempo_total_devel_concluir_testes: indicador.tempo_total_devel_concluir_testes,

        # Flags e status
        tarefa_fechada_sem_testes: indicador.tarefa_fechada_sem_testes,
        fluxo_das_tarefas: indicador.fluxo_das_tarefas,

        # Timestamps padrão
        created_at: indicador.created_at,
        updated_at: indicador.updated_at,
      }
    end

    # Exibir JSON formatado
    puts "\n=== JSON das tarefas relacionadas e indicadores ==="
    puts JSON.pretty_generate(json_resultado)
  end
end
