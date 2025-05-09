class CreateSkyRedmineIndicadores < ActiveRecord::Migration[5.2]
  def change
    create_table :sky_redmine_indicadores do |t|
      # Campo id_tarefa e timestamps
      t.integer :id_tarefa

      # Campos de DEVEL
      t.integer :id_ultima_tarefa
      t.string :tipo
      t.string :status
      t.string :prioridade
      t.string :projeto
      t.string :sprint
      t.string :sprint_ultima_tarefa
      t.string :atribuido_para
      t.string :categoria
      t.string :sistema
      t.string :origem
      t.string :skynet
      t.string :cliente
      t.string :clientenome
      t.string :clientecidade
      t.string :qtde_skynet
      t.datetime :data_prevista
      t.boolean :tarefa_nao_planejada_imediata
      t.boolean :tarefa_antecipada_sprint
      t.string :versao_estavel
      t.string :versao_teste
      t.string :teste_no_desenvolvimento
      t.float :tempo_estimado
      t.float :tempo_gasto
      t.datetime :data_criacao_ou_atendimento
      t.datetime :data_resolvida
      t.datetime :data_fechamento
      t.datetime :data_andamento
      t.integer :tempo_andamento
      t.integer :tempo_resolucao
      t.integer :tempo_fechamento
      t.integer :tempo_para_encaminhar_qs
      t.integer :tempo_total_liberar_versao
      t.integer :tempo_total_devel_concluir_testes
      t.string :tempo_andamento_detalhes
      t.string :tempo_resolucao_detalhes
      t.string :tempo_fechamento_detalhes
      t.string :tempo_para_encaminhar_qs_detalhes
      t.integer :tempo_total_devel
      t.integer :qtd_retorno_testes_devel

      # Campos de QS
      t.integer :id_tarefa_qs
      t.integer :id_ultima_tarefa_qs
      t.string :status_qs
      t.string :projeto_qs
      t.string :sprint_qs
      t.string :sprint_ultima_tarefa_qs
      t.string :atribuido_para_qs
      t.boolean :tarefa_nao_planejada_imediata_qs
      t.boolean :tarefa_antecipada_sprint_qs
      t.float :tempo_estimado_qs
      t.float :tempo_gasto_qs
      t.boolean :houve_teste_nok
      t.datetime :data_criacao_qs
      t.datetime :data_andamento_qs
      t.datetime :data_resolvida_qs
      t.datetime :data_fechamento_qs
      t.integer :tempo_andamento_qs
      t.integer :tempo_resolucao_qs
      t.integer :tempo_fechamento_qs
      t.integer :tempo_concluido_testes_versao_liberada
      t.integer :tempo_total_testes
      t.string :tempo_andamento_qs_detalhes
      t.string :tempo_resolucao_qs_detalhes
      t.string :tempo_fechamento_qs_detalhes
      t.string :tempo_concluido_testes_versao_liberada_detalhes
      t.integer :qtd_retorno_testes_qs

      # Campos de controle/status
      t.string :tarefa_complementar
      t.string :equipe_responsavel_atual
      t.string :tarefa_fechada_sem_testes
      t.string :etapa_atual
      t.string :etapa_atual_agrupado_retorno_testes
      t.string :etapa_atual_eh_retorno_testes
      t.datetime :data_etapa_atual
      t.string :motivo_situacao_desconhecida

      t.timestamps
    end

    add_index :sky_redmine_indicadores, :id_tarefa, unique: true
  end
end
