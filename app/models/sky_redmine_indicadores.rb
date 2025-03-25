class SkyRedmineIndicadores < ActiveRecord::Base
  self.table_name = "sky_redmine_indicadores"

  # Associações, validações ou métodos adicionais, se necessários

  def self.tarefas_por_tipo(project, start_date = nil, end_date = nil)
    scope = por_projeto_e_periodo(project, start_date, end_date)
    scope.group(:tipo_primeira_tarefa_devel).count
  end

  def self.tarefas_por_status(project, start_date = nil, end_date = nil)
    scope = por_projeto_e_periodo(project, start_date, end_date)
    scope.group(:status_ultima_tarefa_devel).count
  end

  def self.por_projeto_e_periodo(project, start_date = nil, end_date = nil)
    scope = where(projeto_primeira_tarefa_devel: project.name)
    scope = scope.where("data_criacao_ou_atendimento_primeira_tarefa_devel >= ?", start_date) if start_date
    scope = scope.where("data_criacao_ou_atendimento_primeira_tarefa_devel <= ?", end_date) if end_date
    scope
  end
end
