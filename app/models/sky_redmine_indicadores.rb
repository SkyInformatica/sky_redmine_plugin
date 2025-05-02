class SkyRedmineIndicadores < ActiveRecord::Base
  self.table_name = "sky_redmine_indicadores"

  # Métodos de classe
  def self.tarefas_por_tipo(tarefas, start_date = nil, end_date = nil)
    tarefas.group(:tipo_primeira_tarefa_devel).count
  end

  def self.tarefas_por_status(tarefas, start_date = nil, end_date = nil)
    tarefas.group(:status_ultima_tarefa_devel).count
  end

  def self.por_projeto_e_periodo(project, start_date = nil, end_date = nil)
    tarefas = where(projeto_primeira_tarefa_devel: project.name)
    tarefas = tarefas.where("data_criacao_ou_atendimento_primeira_tarefa_devel >= ?", start_date) if start_date
    tarefas = tarefas.where("data_criacao_ou_atendimento_primeira_tarefa_devel <= ?", end_date) if end_date
    tarefas
  end
end
