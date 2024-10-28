class EncaminharQsController < ApplicationController
  include FluxoTarefasHelper
  include CriarTarefasHelper
  before_action :inicializar
  before_action :find_issue, only: [:encaminhar_qs]
  before_action :find_issues, only: [:encaminhar_qs_lote]

  def encaminhar_qs(is_batch_call = false)
    Rails.logger.info ">>> encaminhar_qs #{@issue.id}"
    qs_projects = ["Notarial - QS", "Registral - QS"]
    resolvida_status = IssueStatus.find_by(name: "Resolvida")

    # Check if the issue is not in QS projects and its status is "Resolvida"
    if (!qs_projects.include?(@issue.project.name)) && (@issue.status == resolvida_status)

      # Verificar se já existe uma cópia da tarefa nos projetos QS
      related_issues = IssueRelation.where(issue_from_id: @issue.id, relation_type: "copied_to")
      copied_to_qs_issue = related_issues.map { |relation| Issue.find_by(id: relation.issue_to_id) }
        .find { |issue| qs_projects.include?(issue.project.name) }

      # Se existir uma cópia da tarefa para o QS
      if copied_to_qs_issue
        # A tarefa já foi encaminhada para QS
        flash[:warning] = "A tarefa já foi encaminhada para o QS em  #{view_context.link_to "#{copied_to_qs_issue.tracker.name} ##{copied_to_qs_issue.id}", issue_path(copied_to_qs_issue)} e está com status #{copied_to_qs_issue.status.name}." unless is_batch_call
        @processed_issues << "[NOK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - tarefa já foi encaminhada para o QS em  #{view_context.link_to "#{copied_to_qs_issue.tracker.name} ##{copied_to_qs_issue.id}", issue_path(copied_to_qs_issue)} e está com status #{copied_to_qs_issue.status.name}"
        redirect_to issue_path(@issue) unless is_batch_call
        return
      end

      new_issue = criar_nova_tarefa

      if custom_field = IssueCustomField.find_by(name: "Teste QS")
        @issue.custom_field_values = { custom_field.id => "Nova" }
      end

      @issue.save

      atualizar_fluxo_tarefas(new_issue)

      flash[:notice] = "Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada no projeto #{view_context.link_to new_issue.project.name, project_path(new_issue.project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)} com tempo estimado de #{new_issue.estimated_hours}" unless is_batch_call
      @processed_issues << "[OK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - encaminhar para QS em #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} "
    else
      flash[:warning] = "Somente pode encaminhar para o QS só pode ser criado se a tarefa estiver nos projetos das equipes de desenvolvimento com status 'Resolvida'." unless is_batch_call
    end

    redirect_to issue_path(@issue) unless is_batch_call
  end

  def encaminhar_qs_lote
    Rails.logger.info ">>> encaminhar_qs_lote"

    @issue_ids = params[:ids]
    Rails.logger.info ">>> #{@issue_ids.to_json}"

    # Itera sobre cada issue
    # O metodo find_issues (Redmine) define o @issues quando eh processamento em lote
    @issues.each do |issue|
      # o metodo encaminhar_qs usa @issue para referencia a tarefa que deve ser copiada
      # o @issue eh definido pelo find_issue (Redmine) quando eh um processamento individual de uma tarefa
      @issue = issue
      encaminhar_qs(true)
    end

    respond_to do |format|
      format.js
    end
  end

  def obter_tempo_gasto
    Rails.logger.info ">>> obter_tempo_gasto"

    tempo_total = 0
    tarefa_atual = @issue
    loop do
      # Adiciona o tempo gasto da tarefa atual
      tempo_total += tarefa_atual.time_entries.sum(&:hours)
      Rails.logger.info ">>> tempo_total #{tempo_total}"

      # Procura a tarefa anterior de onde esta foi copiada
      relacao = IssueRelation.find_by(issue_to_id: tarefa_atual.id, relation_type: "copied_to")

      # Se não houver mais tarefas anteriores, sai do loop
      break unless relacao

      tarefa_anterior = Issue.find_by(id: relacao.issue_from_id)

      # Se a tarefa anterior não for do mesmo projeto, sai do loop
      break if tarefa_anterior.project_id != @issue.project_id

      # Atualiza a tarefa atual para a próxima iteração
      tarefa_atual = tarefa_anterior
    end

    tempo_total
  end

  private

  def inicializar
    @processed_issues = []
  end

  def criar_nova_tarefa
    registral_projects = ["Equipe Civil", "Equipe TED", "Equipe Imoveis"]
    notarial_projects = ["Equipe Notar", "Equipe Protesto", "Equipe Financeiro"]

    if registral_projects.include?(@issue.project.name)
      qs_project = "Registral - QS"
    elsif notarial_projects.include?(@issue.project.name)
      qs_project = "Notarial - QS"
    end

    qs_project = Project.find_by(name: qs_project)

    tempo_gasto_total = obter_tempo_gasto
    new_issue = @issue.copy(project: qs_project)
    limpar_campos_nova_tarefa(new_issue, CriarTarefasHelper::TipoCriarNovaTarefa::ENCAMINHAR_QS)
    new_issue.estimated_hours = [1, (tempo_gasto_total * 0.34).ceil].max

    # se é um retorno de testes verifica se a origem foi um retorno de testes do desenvolvimento
    # neste caso a tarefa de qs deve ser do tipo da tarefa original, ou seja, defeitou ou funcionalidade
    # se foi um retorno de testes que veio do QS entao mantem como retorno de testes e nao altera o tipo
    if @issue.tracker.name == "Retorno de testes"
      original_issue = encontrar_tarefa_original_funcionalidade_defeito(@issue)
      if original_issue && ["Funcionalidade", "Defeito"].include?(original_issue.tracker.name)
        new_issue.tracker = original_issue.tracker
      end
    end

    # definir tag _TESTAR
    sistema_value = ""
    tag_name = ""
    # Adiciona a nova tag, se for sistema LIVROCAIXA usa o campo sistema, senao o nome da equipe do projeto
    if sistema_custom_field = IssueCustomField.find_by(name: "Sistema")
      sistema_value = new_issue.custom_field_value(sistema_custom_field.id)
      if sistema_value
        sistema_value = sistema_value.upcase.gsub(" ", "")
        tag_name = sistema_custom_field + "_TESTAR"
      end
    end
    if (sistema_value != "LIVROCAIXA")
      tag_name = @issue.project.name.sub("Equipe ", "").upcase + "_TESTAR"
    end
    if tag_name
      new_issue.tag_list.add(tag_name)
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

  def encontrar_tarefa_original_funcionalidade_defeito(issue)
    Rails.logger.info ">>> encontrar_tarefa_original_funcionalidade_defeito"
    current_issue = issue

    # procura a tarefa anterior do mesmo projeto até que seja uma funcionalidade ou defeito
    # se nao encontrar retornar nil
    loop do
      related_issues = IssueRelation.find_by(issue_to_id: current_issue.id, relation_type: "copied_to")
      break unless related_issues

      related_issue = Issue.find_by(id: related_issues.issue_from_id)
      Rails.logger.info ">>> related_issue.project.name #{related_issue.project.name}, related_issue.tracker.name #{related_issue.tracker.name}"

      break if related_issue.project_id != issue.project_id

      if ["Funcionalidade", "Defeito"].include?(related_issue.tracker.name)
        return related_issue
      end

      current_issue = related_issue
    end

    nil
  end
end
