class IndicadoresController < ApplicationController
  unloadable
  before_action :find_project
  before_action :authorize  # Verifica permissões

  def index
    # Filtrar as tarefas do projeto atual
    @tarefas_por_tipo = @project.issues.group(:tracker_id).count.transform_keys do |tracker_id|
      Tracker.find(tracker_id).name
    end

    @tarefas_por_status = @project.issues.group(:status_id).count.transform_keys do |status_id|
      IssueStatus.find(status_id).name
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end
end
