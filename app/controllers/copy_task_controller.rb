class CopyTaskController < ApplicationController
  before_action :find_issue, only: [:copy_task]

  def copy_task
    new_project = find_original_project(@issue)

    if new_project
      new_issue = @issue.copy(:project_id => new_project.id)

      # Limpar campos, exceto target_version_id
      new_issue.assigned_to_id = nil
      new_issue.start_date = nil
      new_issue.estimated_hours = nil

      # Definir campo personalizado
      custom_field_id = 13
      custom_field_value = ""
      if custom_field = IssueCustomField.find_by(id: custom_field_id)
        new_issue.custom_field_values = { custom_field.id => custom_field_value }
      end

      # Alterar tipo e situação da tarefa copiada
      new_issue.tracker = Tracker.find_by_name("Retorno de testes") # Substitua pelo nome do tipo de tarefa desejado
      new_issue.status = IssueStatus.find_by(name: "Fechado") # Substitua pelo nome da situação fechada
      new_issue.save

      # Mensagem de sucesso com o número da nova tarefa e o nome do projeto destino
      flash[:notice] = "Tarefa ##{new_issue.id} de retorno de testes foi criada para o projeto #{new_project.name}"
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

    Rails.logger.info ">>> Current issue ID: #{current_issue.id}, Project ID: #{current_project_id}, Parent ID: #{current_issue.parent_id}"

    # Percorre a cadeia de cópias até encontrar um projeto diferente
    while current_issue.parent_id
      Rails.logger.info ">>>> WHILE, Current issue ID: #{current_issue.id}, Project ID: #{current_project_id}, Parent ID: #{current_issue.parent_id}"

      parent_issue = Issue.find_by(id: current_issue.parent_id)

      Rails.logger.info ">>>> Parent issue ID: #{parent_issue&.id}, Parent Project ID: #{parent_issue&.project_id}"

      # Verifica se o pai é encontrado e se é de um projeto diferente
      if parent_issue.nil?
        Rails.logger.info ">>>> No parent issue found. Stopping search."
        break # Se não encontrar o pai, interrompe a busca
      elsif parent_issue.project_id != current_project_id
        new_project = parent_issue.project # Define o novo projeto se for diferente do projeto atual
        Rails.logger.info ">>>> Found new project: #{new_project&.name}"
        break
      end

      current_issue = parent_issue
    end

    Rails.logger.info ">>> retornando o projeto #{new_project}"

    new_project # Retorna o projeto encontrado ou nil se não for encontrado
  end
end
