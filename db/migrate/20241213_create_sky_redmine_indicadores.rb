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
      t.float :tempo_estimado_devel
      t.float :tempo_gasto_devel
      t.string :origem_primeira_tarefa_devel
      t.string :skynet_primeira_tarefa_devel
      t.string :equipe_responsavel_atual
      t.string :situacao_atual
      t.integer :qtd_retorno_testes
      t.date :data_atendimento_primeira_tarefa_devel
      t.date :data_criacao_ou_atendimento_primeira_tarefa_devel
      t.date :data_andamento_primeira_tarefa_devel
      t.date :data_resolvida_ultima_tarefa_devel
      t.date :data_fechamento_ultima_tarefa_devel
      t.integer :tempo_andamento_devel
      t.integer :tempo_resolucao_devel
      t.integer :tempo_fechamento_devel
      t.integer :tempo_para_encaminhar_qs
      t.integer :primeira_tarefa_qs_id
      t.integer :ultima_tarefa_qs_id
      t.string :sprint_primeira_tarefa_qs
      t.string :sprint_ultima_tarefa_qs
      t.string :projeto_primeira_tarefa_qs
      t.float :tempo_estimado_qs
      t.float :tempo_gasto_qs
      t.string :status_ultima_tarefa_qs
      t.boolean :houve_teste_nok
      t.date :data_criacao_primeira_tarefa_qs
      t.date :data_andamento_primeira_tarefa_qs
      t.date :data_resolvida_ultima_tarefa_qs
      t.date :data_fechamento_ultima_tarefa_qs
      t.integer :tempo_andamento_qs
      t.integer :tempo_resolucao_qs
      t.integer :tempo_fechamento_qs
      t.integer :tempo_concluido_testes_versao_liberada
      t.integer :tempo_total_liberar_versao
      t.integer :tempo_total_testes
      t.integer :tempo_total_devel
      t.string :tarefa_fechada_sem_testes

      t.timestamps
    end

    add_index :sky_redmine_indicadores, :primeira_tarefa_devel_id, unique: true
  end
end
