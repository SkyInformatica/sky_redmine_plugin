class SkyRedmineIndicadores < ActiveRecord::Base
  self.table_name = "sky_redmine_indicadores"

  # Associações, validações ou métodos adicionais, se necessários

  def self.tarefas_por_tipo(project, start_date = nil, end_date = nil)
    scope = where(projeto_primeira_tarefa_devel: project.name)
    scope = scope.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date && end_date
    scope.group(:local_tarefa).count
  end

  def self.tarefas_por_status(project, start_date = nil, end_date = nil)
    scope = where(projeto_primeira_tarefa_devel: project.name)
    scope = scope.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date && end_date
    scope.group(:status_ultima_tarefa_devel).count
  end

  def self.por_projeto_e_periodo(project, start_date = nil, end_date = nil)
    scope = where(projeto_primeira_tarefa_devel: project.name)
    scope = scope.where(created_at: start_date.beginning_of_day..end_date.end_of_day) if start_date && end_date
    scope
  end
end
