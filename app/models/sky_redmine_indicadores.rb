class SkyRedmineIndicadores < ActiveRecord::Base
  self.table_name = "sky_redmine_indicadores"

  # Métodos de classe
  def self.tarefas_por_tipo(tarefas, start_date = nil, end_date = nil)
    tarefas.group(:tipo).count
  end

  def self.tarefas_por_status(tarefas, start_date = nil, end_date = nil)
    tarefas.group(:status).count
  end

  def self.tarefas_por_periodo(tarefas, start_date = nil, end_date = nil)
    tarefas = tarefas.where("data_criacao_ou_atendimento >= ?", start_date) if start_date
    tarefas = tarefas.where("data_criacao_ou_atendimento <= ?", end_date) if end_date
    tarefas
  end

  def self.por_projeto(project)
    where(projeto: project.name)
  end

  def self.por_projeto_e_periodo(project, start_date = nil, end_date = nil)
    tarefas = self.por_projeto(project)
    tarefas = tarefas_por_periodo(tarefas, start_date, end_date) if start_date || end_date
    tarefas
  end
end
