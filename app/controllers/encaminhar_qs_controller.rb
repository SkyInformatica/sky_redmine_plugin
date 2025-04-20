class EncaminharQsController < ApplicationController
  include CriarTarefasHelper
  before_action :inicializar
  before_action :find_issue, only: [:encaminhar_qs]
  before_action :find_issues, only: [:encaminhar_qs_lote]

  def encaminhar_qs(is_batch_call = false)
    usar_sprint_atual = params[:usar_sprint_atual].present?
    Rails.logger.info ">>> encaminhar_qs #{@issue.id} - is_batch_call #{is_batch_call} usar_sprint_atual #{usar_sprint_atual}"

    # Check if the issue is not in QS projects and its status is "Resolvida"
    if (!SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(@issue.project.name)) && (@issue.status.name == SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA)
      # Verificar se já existe uma cópia da tarefa nos projetos QS
      copied_to_qs_issue = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_copiada_qs(@issue)

      # Se existir uma cópia da tarefa para o QS
      if copied_to_qs_issue
        Rails.logger.info ">>> tarefa já foi encaminhada para o QS #{copied_to_qs_issue.id}"
        # A tarefa já foi encaminhada para QS
        flash[:warning] = "A tarefa já foi encaminhada para o QS em  #{view_context.link_to "#{copied_to_qs_issue.tracker.name} ##{copied_to_qs_issue.id}", issue_path(copied_to_qs_issue)} e está com status #{copied_to_qs_issue.status.name}." unless is_batch_call
        @processed_issues << "[NOK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - tarefa já foi encaminhada para o QS em  #{view_context.link_to "#{copied_to_qs_issue.tracker.name} ##{copied_to_qs_issue.id}", issue_path(copied_to_qs_issue)} e está com status #{copied_to_qs_issue.status.name}"
        redirect_to issue_path(@issue) unless is_batch_call
        return
      end

      Rails.logger.info ">>> criar_nova_tarefa para encaminhar_qs"
      new_issue = criar_nova_tarefa(usar_sprint_atual)      
      Rails.logger.info ">>> inicializando journal da tarefa #{@issue.id}"
      @issue.init_journal(User.current, "[SkyRedminePlugin] Encaminhada para QS")
      if custom_field = IssueCustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::TESTE_QS)
        @issue.custom_field_values = { custom_field.id => SkyRedminePlugin::Constants::IssueStatus::NOVA }
      end
      @issue.save

      SkyRedminePlugin::Indicadores.processar_indicadores(@issue)

      if view_context.present? 
        flash[:notice] = "Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi encaminhada para o QS no projeto #{view_context.link_to new_issue.project.name, project_path(new_issue.project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)} com tempo estimado de #{new_issue.estimated_hours}" unless is_batch_call
        @processed_issues << "[OK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - encaminhar para QS em #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} "
      end
    else
      Rails.logger.info ">>> tarefa não pode ser encaminhada para o QS #{@issue.id} - Somente pode encaminhar para o QS tarefas do desenvolvimento com status 'Resolvida'. Status atual: #{@issue.status.name}"
      flash[:warning] = "Somente pode encaminhar para o QS tarefas do desenvolvimento com status 'Resolvida'." unless is_batch_call
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

  def criar_nova_tarefa(usar_sprint_atual = false)
    Rails.logger.info ">>> criar_nova_tarefa para encaminhar_qs usar_sprint_atual #{usar_sprint_atual}"
    if SkyRedminePlugin::Constants::Projects::REGISTRAL_PROJECTS.include?(@issue.project.name)
      qs_project_name = SkyRedminePlugin::Constants::Projects::REGISTRAL_QS
    elsif SkyRedminePlugin::Constants::Projects::NOTARIAL_PROJECTS.include?(@issue.project.name)
      qs_project_name = SkyRedminePlugin::Constants::Projects::NOTARIAL_QS
    end
    qs_project = Project.find_by(name: qs_project_name)

    tempo_gasto_total = obter_tempo_gasto
    new_issue = @issue.copy(project: qs_project)
    limpar_campos_nova_tarefa(new_issue, CriarTarefasHelper::TipoCriarNovaTarefa::ENCAMINHAR_QS)
    new_issue.tag_list = []
    new_issue.estimated_hours = [1, (tempo_gasto_total * 0.34).ceil].max

    sufixo_tag = SkyRedminePlugin::Constants::Tags::TESTAR
    # se é um retorno de testes verifica se a origem foi um retorno de testes do desenvolvimento
    # neste caso a tarefa de qs deve ser do tipo da tarefa original, ou seja, defeitou ou funcionalidade
    # se foi um retorno de testes que veio do QS entao mantem como retorno de testes e nao altera o tipo
    if @issue.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES
      original_issue = encontrar_tarefa_original_funcionalidade_defeito(@issue)
      if original_issue && [SkyRedminePlugin::Constants::Trackers::FUNCIONALIDADE, SkyRedminePlugin::Constants::Trackers::DEFEITO].include?(original_issue.tracker.name)
        new_issue.tracker = original_issue.tracker
      else
        sufixo_tag = SkyRedminePlugin::Constants::Tags::RETESTAR
      end
    end

    new_issue.tag_list.add(obter_nome_tag(@issue, sufixo_tag))

    if usar_sprint_atual
      Rails.logger.info ">>> encaminhar_qs -> criar_nova_tarefa -> usar_sprint_atual"
      sprint = encontrar_sprint_atual(qs_project)
      Rails.logger.info ">>> sprint #{sprint.to_json}"
      if sprint.nil?
        sprint = Version.find_by(name: SkyRedminePlugin::Constants::Sprints::TAREFAS_PARA_TESTAR, project: qs_project)
        if sprint.nil?
          sprint = Version.new(name: SkyRedminePlugin::Constants::Sprints::TAREFAS_PARA_TESTAR, project: qs_project)
          sprint.save
        end
      end
    else
      sprint = Version.find_by(name: SkyRedminePlugin::Constants::Sprints::TAREFAS_PARA_TESTAR, project: qs_project)
      if sprint.nil?
        sprint = Version.new(name: SkyRedminePlugin::Constants::Sprints::TAREFAS_PARA_TESTAR, project: qs_project)
        sprint.save
      end
    end

    new_issue.fixed_version = sprint
    new_issue.save

    Rails.logger.info ">>> criar_nova_tarefa para encaminhar_qs retornando new_issue #{new_issue.id}"
    new_issue
  end

  def encontrar_tarefa_original_funcionalidade_defeito(issue)
    current_issue = issue

    # procura a tarefa anterior do mesmo projeto até que seja uma funcionalidade ou defeito
    # se nao encontrar retornar nil
    loop do
      related_issues = IssueRelation.find_by(issue_to_id: current_issue.id, relation_type: "copied_to")
      break unless related_issues

      related_issue = Issue.find_by(id: related_issues.issue_from_id)

      break if related_issue.project_id != issue.project_id

      if [SkyRedminePlugin::Constants::Trackers::FUNCIONALIDADE, SkyRedminePlugin::Constants::Trackers::DEFEITO].include?(related_issue.tracker.name)
        return related_issue
      end

      current_issue = related_issue
    end

    nil
  end
end
