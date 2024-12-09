class IndicadoresController < ApplicationController
  unloadable
  before_action :find_project
  before_action :authorize  # Verifica permissões
  menu_item :indicadores

  helper Chartkick::Helper

  def index
    Rails.logger.info ">>>> index indicadores"
    # Definir a data de início para um mês atrás
    start_date = 1.month.ago

    # Filtrar as tarefas do projeto criadas no último mês
    issues = @project.issues.where("created_on >= ?", start_date)

    # Continuar com seu agrupamento e contagem
    @tarefas_por_tipo = issues.group(:tracker_id).count
    @tarefas_por_status = issues.group(:status_id).count

    @tarefas_por_tipo = {
      "Bug" => 5,
      "Feature" => 8,
      "Suporte" => 3,
    }

    @tarefas_por_status = {
      "Novo" => 4,
      "Em Progresso" => 6,
      "Resolvido" => 2,
      "Fechado" => 4,
    }

    Rails.logger.info @tarefas_por_tipo
    Rails.logger.info @tarefas_por_status
  end

  private

  def find_project
    @project = Project.find(params[:id])
  end
end
