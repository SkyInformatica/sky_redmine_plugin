class ContinuaProximaSprintController < ApplicationController
  before_action :inicializar
  before_action :find_issue, only: [:continua_proxima_sprint]
  before_action :find_issues, only: [:continua_proxima_sprint_lote]

  def continua_proxima_sprint(is_batch_call = false)
    Rails.logger.info ">>> continua_proxima_sprint #{@issue.id}"
    nova_emandamento_interrompida_status = ["Nova", "Em andamento", "Interrompida"]

    current_sprint_name = @issue.fixed_version&.name # Usa o safe navigation operator para evitar erro se fixed_version for nil
    unless current_sprint_name && current_sprint_name.match?(/^\d{4}-\d{1,2} \(\d{2}\/\d{2} a \d{2}\/\d{2}\)$/)
      # Se o formato da sprint não corresponder, não permite a criação da continua na proxima sprint
      flash[:warning] = "A tarefa não pertence a uma sprint de desenvolvimento e não pode ter uma continuidade na próxima sprint." unless is_batch_call
      @processed_issues << "[NOK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - tarefa não pertence a uma sprint de desenvolvimento"
      redirect_to issue_path(@issue) unless is_batch_call
      return
    end

    # Check if the issue is not in QS projects and its status is "Resolvida"
    if (nova_emandamento_interrompida_status.include?(@issue.status.name))

      # Verificar se já existe uma cópia da tarefa de continuidade na proxima sprint
      related_issues = IssueRelation.where(issue_from_id: @issue.id, relation_type: "copied_to")
      copied_to_issue = related_issues.map { |relation| Issue.find_by(id: relation.issue_to_id) }
        .find { |issue| @issue.project.name == issue.project.name }

      if copied_to_issue
        # A tarefa já foi encaminhada para QS
        flash[:warning] = "A tarefa já possui continuidade em  #{view_context.link_to "#{copied_to_issue.tracker.name} ##{copied_to_issue.id}", issue_path(copied_to_issue)} e está com status #{copied_to_issue.status.name}." unless is_batch_call
        @processed_issues << "[NOK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - tarefa já possui continuidade em  #{view_context.link_to "#{copied_to_issue.tracker.name} ##{copied_to_issue.id}", issue_path(copied_to_issue)} e está com status #{copied_to_issue.status.name}"
        redirect_to issue_path(@issue) unless is_batch_call
        return
      end

      new_issue = criar_nova_tarefa
      if continua_proxima_sprint_status = IssueStatus.find_by(name: "Continua proxima sprint")
        @issue.status = continua_proxima_sprint_status
      end
      @issue.tag_list = []
      @issue.save

      flash[:notice] = "Tarefa de continuidade #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)}" unless is_batch_call
      @processed_issues << "[OK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - continua em #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)}"
    else
      flash[:warning] = "Somente pode continuar na proxima sprint tarefas que estão com status 'Nova', 'Em andamento' ou 'Interrompida'." unless is_batch_call
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
      # o metodo continua_proxima_sprint usa @issue para referencia a tarefa que deve ser copiada
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
    new_issue = @issue.copy
    new_issue.assigned_to_id = nil
    new_issue.start_date = nil
    new_issue.done_ratio = 0

    ["Tarefa não planejada IMEDIATA", "Tarefa antecipada na sprint", "Teste no desenvolvimento", "Teste QS", "Versão estável", "Versão teste"].each do |field_name|
      if custom_field = IssueCustomField.find_by(name: field_name)
        new_issue.custom_field_values = { custom_field.id => nil }
      end
    end

    # Modificando o título da nova tarefa
    original_title = @issue.subject
    if original_title.match?(/\(\d+\)$/)
      # Se já existe um número entre parênteses no fim do título adiciona +1
      current_copy_number = original_title.match(/\d+/)[0].to_i
      new_copy_number = current_copy_number + 1
      new_issue.subject = original_title.sub(/\(\d+\)$/, "(#{new_copy_number})")
    else
      # Se não existe, adicionar (2) ao título original
      new_issue.subject = "#{original_title} (2)"
    end

    # Extraindo o ano e número da sprint atual da variável @issue
    current_sprint_name = @issue.fixed_version.name  # Exemplo: "2024-18 (26/08 a 06/09)"
    year, sprint_number = current_sprint_name.match(/(\d{4})-(\d+)/).captures.map(&:to_i)

    # Tentando encontrar a próxima sprint do mesmo ano
    next_sprint_number = sprint_number + 1
    next_sprint_prefix = "#{year}-#{next_sprint_number.to_s.rjust(2, "0")}"

    # Busca a próxima sprint que começa com o prefixo construído
    sprint = Version.where("name LIKE ? AND project_id = ?", "#{next_sprint_prefix}%", @issue.project.id).first

    # Se a próxima sprint não for encontrada, procurar a primeira sprint do próximo ano
    if sprint.nil?
      next_sprint_prefix = "#{year + 1}-01"
      sprint = Version.where("name LIKE ? AND project_id = ?", "#{next_sprint_prefix}%", @issue.project.id).first
    end

    # Se não encontrar a nova sprint, usar a versão padrão "Aptas para desenvolvimento"
    sprint ||= Version.find_by(name: "Aptas para desenvolvimento", project_id: @issue.project.id)
    if sprint.nil?
      # Caso a versão não exista, cria uma nova versão
      sprint = Version.new(name: "Aptas para desenvolvimento", project_id: @issue.project.id)
      sprint.save
    end
    # Associar a sprint para a nova tarefa
    new_issue.fixed_version = sprint

    new_issue.save
    new_issue
  end

  def atualizar_status_tarefa(issue, novo_status_descricao)
    novo_status = IssueStatus.find_by(name: novo_status_descricao)
    if novo_status
      issue.status = novo_status
      issue.save
    end
  end
end
