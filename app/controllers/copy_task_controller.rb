class CopyTaskController < ApplicationController
  before_action :find_issue, only: [:copy_task]

  def copy_task
    original_issue = find_original_issue(@issue)

    if original_issue
      new_project = original_issue.project
      new_issue = @issue.copy(:project_id => new_project.id)

      # Limpar campos, exceto target_version_id
      new_issue.tracker = Tracker.find_by_name("Retorno de testes")
      new_issue.assigned_to_id = nil
      new_issue.start_date = nil
      new_issue.estimated_hours = nil

      # Definir campo personalizado
      custom_field_id = 13
      custom_field_value = nil
      if custom_field = IssueCustomField.find_by(id: custom_field_id)
        new_issue.custom_field_values = { custom_field.id => custom_field_value }
      end

      new_issue.fixed_version = Version.find_by(name: "Aptas para desenvolvimento", project_id: new_project.id)
      new_issue.save

      # Atualizar a tarefa original
      fechada_cont_retorno_testes = IssueStatus.find_by(name: "Fechada - cont retorno testes")
      if fechada_cont_retorno_testes
        original_issue.update(status_id: fechada_cont_retorno_testes.id)
        original_issue.save
      else
        Rails.logger.info ">>> nao foi encontrado o status 'Fechado - cont. retorno teste'"
      end

      # Agora vamos alterar o status da tarefa original (issue)
      status_nok = IssueStatus.find_by(name: "Teste NOK - Fechada")
      if status_nok
        #@issue.update(status_id: status_nok.id)
        @issue.status = status_nok
        @issue.save
        Rails.logger.info ">>> Status da tarefa original #{@issue.id} alterado para 'Teste NOK - Fechada'"
      else
        Rails.logger.info ">>> Não foi encontrado o status 'Teste NOK - Fechada'"
      end

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

  def find_original_issue(issue)
    Rails.logger.info ">>> Inicio find_original_issue"
    current_issue = issue
    current_project_id = issue.project_id
    original_issue = nil

    Rails.logger.info ">>> Current issue ID: #{current_issue.id}, Project ID: #{current_project_id}"

    # Procura na lista de relações da tarefa para encontrar a origem
    loop do
      Rails.logger.info ">>>> Checking issue ID: #{current_issue.id}, Project ID: #{current_issue.project_id}"

      # Verifica se o projeto da tarefa atual é diferente do projeto original
      if current_issue.project_id != current_project_id
        original_issue = current_issue
        Rails.logger.info ">>>> Found original issue in project: #{original_issue.project.name}"
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

    original_issue
  end
end
