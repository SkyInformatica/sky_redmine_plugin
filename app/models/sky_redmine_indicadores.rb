class SkyRedmineIndicadores < ActiveRecord::Base
  self.table_name = "sky_redmine_indicadores"

  # Métodos de classe
  def self.tarefas_por_tipo(scope, start_date = nil, end_date = nil)
    scope.group(:tipo_primeira_tarefa_devel).count
  end

  def self.tarefas_por_status(scope, start_date = nil, end_date = nil)
    scope.group(:status_ultima_tarefa_devel).count
  end

  def self.por_projeto_e_periodo(project, start_date = nil, end_date = nil)
    scope = where(projeto_primeira_tarefa_devel: project.name)
    scope = scope.where("data_criacao_ou_atendimento_primeira_tarefa_devel >= ?", start_date) if start_date
    scope = scope.where("data_criacao_ou_atendimento_primeira_tarefa_devel <= ?", end_date) if end_date
    scope
  end

  def self.tempo_gasto_por_tipo(start_date = nil, end_date = nil)
    scope = obter_tarefas(start_date, end_date)
    
    scope.group(:tipo).sum('tempo_gasto_devel + tempo_gasto_qs')
  end
end
