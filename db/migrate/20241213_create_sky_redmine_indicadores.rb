class CreateSkyRedmineIndicadores < ActiveRecord::Migration[5.2]
  def change
    create_table :sky_redmine_indicadores do |t|
      t.integer :primeira_tarefa_devel_id
      t.string :tipo_primeira_tarefa_devel
      t.integer :ultima_tarefa_devel_id
      t.string :status_ultima_tarefa_devel
      t.string :prioridade_primeira_tarefa_devel
      t.string :projeto_primeira_tarefa_devel
      t.string :sprint_primeira_tarefa_devel
      t.string :sprint_ultima_tarefa_devel
      t.string :tarefa_complementar
      t.string :teste_no_desenvolvimento
      t.float :tempo_estimado_devel
      t.float :tempo_gasto_devel
      t.string :origem_primeira_tarefa_devel
      t.string :skynet_primeira_tarefa_devel
      t.string :equipe_responsavel_atual
      t.string :etapa_atual
      t.datetime :data_etapa_atual
      t.integer :qtd_retorno_testes_qs
      t.integer :qtd_retorno_testes_devel
      t.datetime :data_criacao_ou_atendimento_primeira_tarefa_devel
      t.datetime :data_andamento_primeira_tarefa_devel
      t.datetime :data_resolvida_ultima_tarefa_devel
      t.datetime :data_fechamento_ultima_tarefa_devel
      t.integer :tempo_andamento_devel
      t.string :tempo_andamento_devel_detalhes
      t.integer :tempo_resolucao_devel
      t.string :tempo_resolucao_devel_detalhes
      t.integer :tempo_fechamento_devel
      t.string :tempo_fechamento_devel_detalhes
      t.integer :tempo_para_encaminhar_qs
      t.string :tempo_para_encaminhar_qs_detalhes
      t.integer :primeira_tarefa_qs_id
      t.integer :ultima_tarefa_qs_id
      t.string :sprint_primeira_tarefa_qs
      t.string :sprint_ultima_tarefa_qs
      t.string :projeto_primeira_tarefa_qs
      t.float :tempo_estimado_qs
      t.float :tempo_gasto_qs
      t.string :status_ultima_tarefa_qs
      t.boolean :houve_teste_nok
      t.datetime :data_criacao_primeira_tarefa_qs
      t.datetime :data_andamento_primeira_tarefa_qs
      t.datetime :data_resolvida_ultima_tarefa_qs
      t.datetime :data_fechamento_ultima_tarefa_qs
      t.integer :tempo_andamento_qs
      t.string :tempo_andamento_qs_detalhes
      t.integer :tempo_resolucao_qs
      t.string :tempo_resolucao_qs_detalhes
      t.integer :tempo_fechamento_qs
      t.string :tempo_fechamento_qs_detalhes
      t.integer :tempo_concluido_testes_versao_liberada
      t.string :tempo_concluido_testes_versao_liberada_detalhes
      t.integer :tempo_total_liberar_versao
      t.integer :tempo_total_testes
      t.integer :tempo_total_devel
      t.string :tarefa_fechada_sem_testes
      t.integer :tempo_total_devel_concluir_testes
      t.string :motivo_situacao_desconhecida
      t.string :versao_estavel
      t.string :versao_teste

      t.timestamps
    end

    add_index :sky_redmine_indicadores, :primeira_tarefa_devel_id, unique: true
  end
end
