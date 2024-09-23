class CriarRetornoTestesController < ApplicationController
  before_action :obter_tarefa, only: [:criar_retorno_testes_devel, :criar_retorno_testes_qs]

  def criar_retorno_testes_devel
    qs_projects = ["Notarial - QS", "Registral - QS"]
    resolvida_status = IssueStatus.find_by(name: "Resolvida")

    # Check if the issue is not in QS projects and its status is "Resolvida"
    if (!qs_projects.include?(@issue.project.name)) && (@issue.status == resolvida_status)
      new_issue = criar_nova_tarefa(@issue.project.id)

      atualizar_status_tarefa(@issue, "Fechada - cont retorno testes")

      flash[:notice] = "Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada no projeto #{view_context.link_to new_issue.project.name, project_path(new_issue.project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)}"
      flash[:info] = "A tarefa de desenvolvimento #{@issue.id} teve seu status ajustado para <strong><em>#{@issue.status.name}</em></strong>".html_safe
    else
      flash[:warning] = "O retorno de testes só pode ser criado se a tarefa de desenvolvimento estiver nos projetos das equipes de desenvolvimento com status 'Resolvida'."
    end

    redirect_to issue_path(@issue)
  end

  def criar_retorno_testes_qs
    qs_projects = ["Notarial - QS", "Registral - QS"]
    nok_status = IssueStatus.find_by(name: "Teste NOK")

    # Verificar se a tarefa pertence aos projetos permitidos e se o status é "Teste NOK"
    if (qs_projects.include?(@issue.project.name) && (@issue.status == nok_status))

      # localizar a tarefa de origem do desenvolvimento
      original_issue = localizar_tarefa_origem_copia_outro_projeto(@issue)

      if original_issue
        new_issue = criar_nova_tarefa(original_issue.project.id)

        atualizar_status_tarefa(original_issue, "Fechada - cont retorno testes")
        atualizar_status_tarefa(@issue, "Teste NOK - Fechada")

        flash[:notice] = "Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada no projeto #{view_context.link_to new_project.name, project_path(new_project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)}"
        flash[:info] = "Tarefa do desenvolvimento #{view_context.link_to "#{original_issue.tracker.name} ##{original_issue.id}", issue_path(original_issue)} foi ajustada o status para <strong><em>#{original_issue.status.name}</em></strong><br>" \
        "Essa tarefa de testes foi fechada e ajustado seu status para <strong><em>#{@issue.status.name}</em></strong>".html_safe
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

  def criar_nova_tarefa(project_id)
    new_issue = @issue.copy(project_id: project_id)
    new_issue.tracker = Tracker.find_by_name("Retorno de testes")
    new_issue.assigned_to_id = nil
    new_issue.start_date = nil
    new_issue.estimated_hours = 1

    if custom_field = IssueCustomField.find_by(name: "Tarefa não planejada IMEDIATA")
      new_issue.custom_field_values = { custom_field.id => nil }
    end

    if custom_field = IssueCustomField.find_by(name: "Tarefa antecipada na sprint")
      new_issue.custom_field_values = { custom_field.id => nil }
    end

    sprint = Version.find_by(name: "Aptas para desenvolvimento", project_id: project_id)
    new_issue.fixed_version = sprint if sprint
    new_issue.save
    new_issue
  end

  def localizar_tarefa_origem_copia_outro_projeto(issue)
    current_issue = issue
    current_project_id = issue.project_id
    original_issue = nil

    # Procura na lista de relações da tarefa para encontrar a origem
    loop do

      # Verifica se o projeto da tarefa atual é diferente do projeto original
      if current_issue.project_id != current_project_id
        original_issue = current_issue
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

  def atualizar_status_tarefa(issue, novo_status_descricao)
    novo_status = IssueStatus.find_by(name: novo_status_descricao)
    if novo_status
      issue.status = novo_status
      issue.save
    end
  end
end
