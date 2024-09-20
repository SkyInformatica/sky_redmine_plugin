class CriarRetornoTestesController < ApplicationController
  before_action :obter_tarefa, only: [:criar_retorno_testes]

  def criar_retorno_testes
    allowed_projects = ["Notarial - QS", "Registral - QS"]
    nok_status = IssueStatus.find_by(name: "Teste NOK")

    # Verificar se a tarefa pertence aos projetos permitidos e se o status é "Teste NOK"
    if allowed_projects.include?(@issue.project.name) && @issue.status == nok_status

      # localizar a tarefa de origem do desenvolvimento
      original_issue = localizar_tarefa_origem_copia_desenvolvimento(@issue)

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

        sprint = Version.find_by(name: "Aptas para desenvolvimento", project_id: new_project.id)
        if sprint
          new_issue.fixed_version = sprint
        end
        new_issue.save

        # Atualizar a tarefa original
        fechada_cont_retorno_testes_status = IssueStatus.find_by(name: "Fechada - cont retorno testes")
        if fechada_cont_retorno_testes_status
          #original_issue.update(status_id: fechada_cont_retorno_testes.id)
          original_issue.status = fechada_cont_retorno_testes_status
          original_issue.save
        else
          Rails.logger.info ">>> nao foi encontrado o status 'Fechado - cont. retorno teste'"
        end

        # Agora vamos alterar o status da tarefa original (issue)
        status_nok_status = IssueStatus.find_by(name: "Teste NOK - Fechada")
        if status_nok_status
          #@issue.update(status_id: status_nok.id)
          @issue.status = status_nok_status
          @issue.save
          Rails.logger.info ">>> Status da tarefa original #{@issue.id} alterado para 'Teste NOK - Fechada'"
        else
          Rails.logger.info ">>> Não foi encontrado o status 'Teste NOK - Fechada'"
        end

        flash[:notice] = "Tarefa #{view_context.link_to "##{new_issue.id}", issue_path(new_issue)} de retorno de testes foi criada.<br>" \
        "Tarefa criada no projeto: <strong>#{new_project.name}</strong> Sprint: <strong>Aptas para desenvolvimento</strong>".html_safe
      else
        flash[:warning] = "Não foi possível encontrar o projeto de origem (desenvolvimento) para criar o retorno de testes."
      end
    else
      flash[:warning] = "O retorno de testes só pode ser criado se a tarefa de testes estiver nos projetos 'Notarial - QS' ou 'Registral - QS' com status 'Teste NOK'."
    end

    redirect_to issue_path(@issue)
  end

  private

  def obter_tarefa
    @issue = Issue.find(params[:id])
  end

  def localizar_tarefa_origem_copia_desenvolvimento(issue)
    Rails.logger.info ">>> Inicio find_original_issue"
    current_issue = issue
    current_project_id = issue.project_id
    original_issue = nil

    Rails.logger.info ">>> current_issue ID: #{current_issue.id}, Project ID: #{current_project_id}"

    # Procura na lista de relações da tarefa para encontrar a origem
    loop do
      Rails.logger.info ">>>> Verificando issue ID: #{current_issue.id}, Project ID: #{current_issue.project_id}"

      # Verifica se o projeto da tarefa atual é diferente do projeto original
      if current_issue.project_id != current_project_id
        original_issue = current_issue
        Rails.logger.info ">>>> Projeto encontrado: #{original_issue.project.name}"
        break
      end

      # Verifica as relações da tarefa para encontrar a tarefa original
      related_issues = IssueRelation.where(issue_to_id: current_issue.id, relation_type: "copied_to")

      if related_issues.any?
        related_issue = Issue.find_by(id: related_issues.first.issue_from_id)
        current_issue = related_issue
      else
        break
      end
    end

    original_issue
  end
end
