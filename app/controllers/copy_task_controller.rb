class CopyTaskController < ApplicationController
  before_action :find_issue, only: [:copy_task]

  def copy_task
    new_project = find_original_project(@issue)

    if new_project
      new_issue = @issue.copy(:project_id => new_project.id)

      # Limpar campos, exceto target_version_id
      new_issue.tracker = Tracker.find_by_name("Retorno de testes") # Substitua pelo nome do tipo de tarefa desejado
      new_issue.assigned_to_id = nil
      new_issue.start_date = nil
      new_issue.estimated_hours = nil

      # Definir campo personalizado
      custom_field_id = 13
      custom_field_value = nil
      if custom_field = IssueCustomField.find_by(id: custom_field_id)
        new_issue.custom_field_values = { custom_field.id => custom_field_value }
      end

      # Localizar a versão com nome "Aptas para desenvolvimento"
      fixed_version = new_project.versions.find_by(name: "Aptas para desenvolvimento")
      if fixed_version
        new_issue.fixed_version_id = fixed_version.id
      else
        Rails.logger.info ">>> Não foi encontrada a versão 'Aptas para desenvolvimento' no projeto #{new_project.name}"
      end

      new_issue.save

      # Mensagem de sucesso com o número da nova tarefa e o nome do projeto destino
      flash[:notice] = "Tarefa #{new_issue.id} de retorno de testes foi criada para o projeto #{new_project.name}"
    else
      flash[:warning] = "Não foi possível encontrar o projeto de origem para criar o retorno de testes. A cópia não foi realizada."
    end

    redirect_to issue_path(@issue)
  end

  private

  def find_issue
    @issue = Issue.find(params[:id])
  end

  def find_original_project(issue)
    Rails.logger.info ">>> Inicio find_original_project"
    current_issue = issue
    current_project_id = issue.project_id
    new_project = nil

    Rails.logger.info ">>> Current issue ID: #{current_issue.id}, Project ID: #{current_project_id}"

    # Procura na lista de relações da tarefa para encontrar a origem
    loop do
      Rails.logger.info ">>>> Checking issue ID: #{current_issue.id}, Project ID: #{current_issue.project_id}"

      # Verifica se o projeto da tarefa atual é diferente do projeto original
      if current_issue.project_id != current_project_id
        new_project = current_issue.project
        Rails.logger.info ">>>> Found new project: #{new_project&.name}"
        break
      end

      # Verifica as relações da tarefa para encontrar a tarefa original
      related_issues = IssueRelation.where(issue_to_id: current_issue.id, relation_type: "copied_to")

      if related_issues.any?
        Rails.logger.info ">>>> related_issues.first.issue_id: #{related_issues.first.issue_from_id}"
        # Escolhe a primeira relação como exemplo (ajuste conforme necessário)
        related_issue = Issue.find_by(id: related_issues.first.issue_from_id)
        current_issue = related_issue
      else
        break
      end
    end

    new_project
  end
end
