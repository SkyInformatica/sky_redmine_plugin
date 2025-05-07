# para executar o rake, use o seguinte comando:
# RAILS_ENV=production rake sky_redmine_plugin:debug_etapa_atual[65408]

namespace :sky_redmine_plugin do
  desc "Depura a situação atual e tarefas relacionadas para uma tarefa específica. Uso: rake sky_redmine_plugin:debug_etapa_atual[TAREFA_ID]"
  task :debug_etapa_atual, [:tarefa_id] => :environment do |t, args|
    if args[:tarefa_id].blank?
      puts "Erro: É necessário fornecer o ID da tarefa. Exemplo: RAILS_ENV=production rake sky_redmine_plugin:debug_etapa_atual[12345]"
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

    indicador = SkyRedmineIndicadores.find_by(id_tarefa: primeira_tarefa.id)

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
        id_tarefa: indicador.id_tarefa,
        tipo: indicador.tipo,
        id_ultima_tarefa: indicador.id_ultima_tarefa,
        status: indicador.status,

        # Informações da primeira tarefa DEVEL
        prioridade: indicador.prioridade,
        projeto: indicador.projeto,
        sprint: indicador.sprint,
        origem: indicador.origem,
        skynet: indicador.skynet,

        # Sprints
        sprint_ultima_tarefa: indicador.sprint_ultima_tarefa,

        # Campos de controle e status
        tarefa_complementar: indicador.tarefa_complementar,
        teste_no_desenvolvimento: indicador.teste_no_desenvolvimento,
        equipe_responsavel_atual: indicador.equipe_responsavel_atual,
        etapa_atual: indicador.etapa_atual,

        # Tempos DEVEL
        tempo_estimado: indicador.tempo_estimado,
        tempo_gasto: indicador.tempo_gasto,

        # Contadores de retorno
        qtd_retorno_testes_qs: indicador.qtd_retorno_testes_qs,
        qtd_retorno_testes_devel: indicador.qtd_retorno_testes_devel,

        # Datas DEVEL
        data_criacao_ou_atendimento: indicador.data_criacao_ou_atendimento,
        data_andamento: indicador.data_andamento,
        data_resolvida: indicador.data_resolvida,
        data_fechamento: indicador.data_fechamento,

        # Tempos de processamento DEVEL
        tempo_andamento: indicador.tempo_andamento,
        tempo_resolucao: indicador.tempo_resolucao,
        tempo_fechamento: indicador.tempo_fechamento,
        tempo_para_encaminhar_qs: indicador.tempo_para_encaminhar_qs,

        # Campos de identificação das tarefas QS
        id_tarefa_qs: indicador.id_tarefa_qs,
        id_ultima_tarefa_qs: indicador.id_ultima_tarefa_qs,
        status_qs: indicador.status_qs,

        # Informações das tarefas QS
        sprint_qs: indicador.sprint_qs,
        sprint_ultima_tarefa_qs: indicador.sprint_ultima_tarefa_qs,
        projeto_qs: indicador.projeto_qs,

        # Tempos QS
        tempo_estimado_qs: indicador.tempo_estimado_qs,
        tempo_gasto_qs: indicador.tempo_gasto_qs,

        # Status e controles QS
        houve_teste_nok: indicador.houve_teste_nok,

        # Datas QS
        data_criacao_qs: indicador.data_criacao_qs,
        data_andamento_qs: indicador.data_andamento_qs,
        data_resolvida_qs: indicador.data_resolvida_qs,
        data_fechamento_qs: indicador.data_fechamento_qs,

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
