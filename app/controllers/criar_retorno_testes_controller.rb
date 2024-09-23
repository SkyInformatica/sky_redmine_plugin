class CriarRetornoTestesController < ApplicationController
  before_action :obter_tarefa, only: [:criar_retorno_testes_devel, :criar_retorno_testes_qs]

  def criar_retorno_testes_devel
    qs_projects = ["Notarial - QS", "Registral - QS"]
    resolvida_status = IssueStatus.find_by(name: "Resolvida")

    # Check if the issue is not in QS projects and its status is "Resolvida"
    if (!qs_projects.include?(@issue.project.name)) && (@issue.status == resolvida_status)
      new_issue = criar_nova_tarefa(@issue.project.id)

      atualizar_status_tarefa(@issue, "Fechada - cont retorno testes")

      flash[:notice] = "Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada no projeto #{view_context.link_to new_issue.project.name, project_path(new_issue.project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)} com tempo estimado de 1.0h"
      flash[:info] = "Essa tarefa teve seu status ajustado para <strong><em>#{@issue.status.name}</em></strong>".html_safe
    else
      flash[:warning] = "O retorno de testes só pode ser criado se a tarefa de desenvolvimento estiver nos projetos das equipes de desenvolvimento com status 'Resolvida'."
    end

    redirect_to issue_path(@issue)
  end

  def criar_retorno_testes_devel
    qs_projects = ["Notarial - QS", "Registral - QS"]
    resolvida_status = IssueStatus.find_by(name: "Resolvida")
    nova_status = IssueStatus.find_by(name: "Nova")

    # Check if the issue is not in QS projects and its status is "Resolvida"
    if (!qs_projects.include?(@issue.project.name)) && (@issue.status == resolvida_status)

      # Verificar se já existe uma cópia da tarefa nos projetos QS
      related_issues = IssueRelation.where(issue_from_id: @issue.id, relation_type: "copied_to")
      copied_to_qs_issue = related_issues.map { |relation| Issue.find_by(id: relation.issue_to_id) }
        .find { |issue| qs_projects.include?(issue.project.name) }

      Rails.logger.info ">>> procurando tarefa copiado para QS"
      tarefa_qs_removida = false
      # Se existir uma cópia e seu status for "Nova"
      if copied_to_qs_issue
        Rails.logger.info ">>> encontrou tarefa copiado para QS"
        if copied_to_qs_issue.status == nova_status
          Rails.logger.info ">>> a tarefa no qs está como nova"

          # Remover a cópia
          tarefa_qs_removida = true
          copied_to_qs_issue.destroy
          # Remover a relação de cópia
          IssueRelation.where(issue_from_id: @issue.id, issue_to_id: copied_to_qs_issue.id, relation_type: "copied_to").destroy_all
        else
          # A tarefa já foi encaminhada para QS e não está como "Nova"
          flash[:warning] = "Os testes já foram iniciados pelo QS em  #{view_context.link_to "#{copied_to_qs_issue.tracker.name} ##{copied_to_qs_issue.id}", issue_path(copied_to_qs_issue)} e está com status #{copied_to_qs_issue.status.name}.<br>Neste caso não possivel criar um retorno de testes para a tarefa de desenvolvimento.<br>Ou crie uma nova tarefa de Defeito ou crie um retorno de testes apartir da tarefa do QS.".html_safe
          redirect_to issue_path(@issue) and return
        end
      end

      new_issue = criar_nova_tarefa(@issue.project.id)

      atualizar_status_tarefa(@issue, "Fechada - cont retorno testes")

      flash[:notice] = "Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada no projeto #{view_context.link_to new_issue.project.name, project_path(new_issue.project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)} com tempo estimado de 1.0h"
      flash[:info] = "Essa tarefa teve seu status ajustado para <strong><em>#{@issue.status.name}</em></strong>"
      if tarefa_qs_removida
        flash[:info] = flash[:info] + "<br>A tarefa já havia sido encaminhada para o QS e ainda estava com status Nova, portanto foi removida do backlog do QS".html_safe
      end
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

        #limpar tags da tarefa de QS
        @issue.tag_list = []
        @issue.save

        flash[:notice] = "Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada no projeto #{view_context.link_to original_issue.project.name, project_path(original_issue.project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)} com tempo estimado de 1.0h"
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

    new_issue.tag_list = [] # Definindo a lista de tags como vazia

    if custom_field = IssueCustomField.find_by(name: "Tarefa não planejada IMEDIATA")
      new_issue.custom_field_values = { custom_field.id => nil }
    end

    if custom_field = IssueCustomField.find_by(name: "Tarefa antecipada na sprint")
      new_issue.custom_field_values = { custom_field.id => nil }
    end

    if custom_field = IssueCustomField.find_by(name: "Responsável pelo teste")
      new_issue.custom_field_values = { custom_field.id => nil }
    end

    if custom_field = IssueCustomField.find_by(name: "Teste no desenvolvimento")
      new_issue.custom_field_values = { custom_field.id => nil }
    end

    if custom_field = IssueCustomField.find_by(name: "Teste QS")
      new_issue.custom_field_values = { custom_field.id => nil }
    end

    if custom_field = IssueCustomField.find_by(name: "Versão estável")
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
