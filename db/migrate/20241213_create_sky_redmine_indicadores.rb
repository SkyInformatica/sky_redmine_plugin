class CreateSkyRedmineIndicadores < ActiveRecord::Migration[5.2]
  def change
    create_table :sky_redmine_indicadores do |t|
      t.integer :id_tarefa
      t.string :tipo
      t.integer :id_ultima_tarefa
      t.string :status
      t.string :prioridade
      t.string :projeto
      t.string :sprint
      t.string :sprint_ultima_tarefa
      t.string :tarefa_complementar
      t.string :teste_no_desenvolvimento
      t.float :tempo_estimado
      t.float :tempo_gasto
      t.string :origem
      t.string :skynet
      t.string :equipe_responsavel_atual
      t.string :etapa_atual
      t.boolean :etapa_atual_eh_retorno_testes
      t.datetime :data_etapa_atual
      t.integer :qtd_retorno_testes_qs
      t.integer :qtd_retorno_testes_devel
      t.datetime :data_criacao_ou_atendimento
      t.datetime :data_andamento
      t.datetime :data_resolvida
      t.datetime :data_fechamento
      t.integer :tempo_andamento
      t.string :tempo_andamento_detalhes
      t.integer :tempo_resolucao
      t.string :tempo_resolucao_detalhes
      t.integer :tempo_fechamento
      t.string :tempo_fechamento_detalhes
      t.integer :tempo_para_encaminhar_qs
      t.string :tempo_para_encaminhar_qs_detalhes
      t.integer :id_tarefa_qs
      t.integer :id_ultima_tarefa_qs
      t.string :sprint_qs
      t.string :sprint_ultima_tarefa_qs
      t.string :projeto_qs
      t.float :tempo_estimado_qs
      t.float :tempo_gasto_qs
      t.string :status_qs
      t.boolean :houve_teste_nok
      t.datetime :data_criacao_qs
      t.datetime :data_andamento_qs
      t.datetime :data_resolvida_qs
      t.datetime :data_fechamento_qs
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

    add_index :sky_redmine_indicadores, :id_tarefa, unique: true
  end
end
