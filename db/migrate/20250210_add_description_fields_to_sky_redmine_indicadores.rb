class AddDescriptionFieldsToSkyRedmineIndicadores < ActiveRecord::Migration[5.2]
  def change
    add_column :sky_redmine_indicadores, :projeto_primeira_tarefa_devel, :string
    add_column :sky_redmine_indicadores, :sprint_primeira_tarefa_devel, :string
    add_column :sky_redmine_indicadores, :sprint_ultima_tarefa_devel, :string
    add_column :sky_redmine_indicadores, :sprint_primeira_tarefa_qs, :string
    add_column :sky_redmine_indicadores, :sprint_ultima_tarefa_qs, :string
    add_column :sky_redmine_indicadores, :projeto_primeira_tarefa_qs, :string
  end
end
