class ContinuaProximaSprintController < ApplicationController
  before_action :inicializar
  before_action :find_issue, only: [:continua_proxima_sprint]
  before_action :find_issues, only: [:continua_proxima_sprint_lote]

  def continua_proxima_sprint(is_batch_call = false)
    Rails.logger.info ">>> continua_proxima_sprint #{@issue.id}"
    qs_projects = ["Notarial - QS", "Registral - QS"]
    resolvida_status = IssueStatus.find_by(name: "Resolvida")
    nova_status = IssueStatus.find_by(name: "Nova")

    # Check if the issue is not in QS projects and its status is "Resolvida"
    if (!qs_projects.include?(@issue.project.name)) && (@issue.status == resolvida_status)

      # Verificar se já existe uma cópia da tarefa nos projetos QS
      related_issues = IssueRelation.where(issue_from_id: @issue.id, relation_type: "copied_to")
      copied_to_qs_issue = related_issues.map { |relation| Issue.find_by(id: relation.issue_to_id) }
        .find { |issue| qs_projects.include?(issue.project.name) }

      tarefa_qs_removida = false
      # Se existir uma cópia e seu status for "Nova"
      if copied_to_qs_issue
        # A tarefa já foi encaminhada para QS
        flash[:warning] = "A tarefa já foi encaminhada para o QS em  #{view_context.link_to "#{copied_to_qs_issue.tracker.name} ##{copied_to_qs_issue.id}", issue_path(copied_to_qs_issue)} e está com status #{copied_to_qs_issue.status.name}." unless is_batch_call
        @processed_issues << "[NOK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - tarefa já foi encaminhada para o QS em  #{view_context.link_to "#{copied_to_qs_issue.tracker.name} ##{copied_to_qs_issue.id}", issue_path(copied_to_qs_issue)} e está com status #{copied_to_qs_issue.status.name}"
        redirect_to issue_path(@issue) unless is_batch_call
        return
      end

      new_issue = criar_nova_tarefa

      flash[:notice] = 'Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada no projeto #{view_context.link_to new_issue.project.name, project_path(new_issue.project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)} com tempo estimado de XX' unless is_batch_call
      @processed_issues << "[OK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - encaminhar para QS em #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} "
    else
      flash[:warning] = "Somente pode encaminhar para o QS só pode ser criado se a tarefa estiver nos projetos das equipes de desenvolvimento com status 'Resolvida'." unless is_batch_call
    end

    redirect_to issue_path(@issue) unless is_batch_call
  end

  def continua_proxima_sprint_lote
    Rails.logger.info ">>> continua_proxima_sprint_lote"

    @issue_ids = params[:ids]
    Rails.logger.info ">>> #{@issue_ids.to_json}"

    # Itera sobre cada issue
    # O metodo find_issues (Redmine) define o @issues quando eh processamento em lote
    @issues.each do |issue|
      # o metodo encaminhar_qs usa @issue para referencia a tarefa que deve ser copiada
      # o @issue eh definido pelo find_issue (Redmine) quando eh um processamento individual de uma tarefa
      @issue = issue
      continua_proxima_sprint(true)
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def inicializar
    @processed_issues = []
  end

  def criar_nova_tarefa
    registral_projects = ["Equipe Civil", "Equipe TED", "Equipe Registral"]
    notarial_projects = ["Equipe Notar", "Equipe Protesto", "Equipe Financeiro"]

    if (registral_projects.include?(@issue.project.name))
      qs_project = "Registral - QS"
    elsif (notarial_projects.include?(@issue.project.name))
      qs_project = "Notarial - QS"
    end

    qs_project = Project.find_by(name: qs_project)

    new_issue = @issue.copy(project: qs_project)
    new_issue.assigned_to_id = nil
    new_issue.start_date = nil
    new_issue.estimated_hours = 1

    #if @new_issue.respond_to?(:tag_list)
    new_issue.tag_list = [] # Definindo a lista de tags como vazia
    #end

    ["Tarefa não planejada IMEDIATA", "Tarefa antecipada na sprint", "Responsável pelo teste", "Teste no desenvolvimento", "Teste QS", "Versão estável"].each do |field_name|
      if custom_field = IssueCustomField.find_by(name: field_name)
        new_issue.custom_field_values = { custom_field.id => nil }
      end
    end

    sprint = Version.find_by(name: "Tarefas para testar", project: qs_project)
    if sprint.nil?
      # Caso a versão não exista, cria uma nova versão
      sprint = Version.new(name: "Tarefas para testar", project: qs_project)
      sprint.save
    end
    new_issue.fixed_version = sprint

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
