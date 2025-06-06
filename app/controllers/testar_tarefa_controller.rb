class TestarTarefaController < ApplicationController
  include CriarTarefasHelper
  include CriarTarefasHelper
  before_action :find_issue, only: [:testar_tarefa]

  def testar_tarefa
    # Verifica se a tarefa não pertence aos projetos QS e está com status 'Resolvida'
    unless ((!SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(@issue.project.name)) &&
            (@issue.status.name == SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA))
      flash[:warning] = "A tarefa deve estar nos projetos de desenvolvimento e com status 'Resolvida' para ser colocada em teste."
      redirect_to issue_path(@issue) and return
    end

    # Verifica se a tarefa já está sendo testada e obtém a tarefa de testes relacionada
    tarefa_testes_existente = tarefa_ja_sendo_testada(@issue)

    if tarefa_testes_existente
      Rails.logger.info ">>> tarefa_testes_existente #{tarefa_testes_existente}"
      flash[:warning] = "A tarefa já está sendo testada por #{view_context.link_to "#{tarefa_testes_existente.tracker.name} ##{tarefa_testes_existente.id} - #{tarefa_testes_existente.subject}", issue_path(tarefa_testes_existente)}."
      redirect_to issue_path(@issue) and return
    end

    # Encontra a tarefa de testes correspondente
    tarefa_testes = encontrar_tarefa_testes_usuario_logado(@issue)

    unless tarefa_testes
      # Se não encontrar a tarefa de testes dá um aviso
      flash[:warning] = "Não foi localizada sua tarefa de testes em uma sprint atual de desenvolvimento."
      redirect_to issue_path(@issue) and return
    end

    # Cria a relação entre a issue atual e a tarefa de testes encontrada ou criada
    IssueRelation.create(
      issue_from: @issue,
      issue_to: tarefa_testes,
      relation_type: "relates",
    )

    flash[:notice] = "A tarefa pode ser testada e está relacionada com #{view_context.link_to "#{tarefa_testes.tracker.name} ##{tarefa_testes.id} - #{tarefa_testes.subject}", issue_path(tarefa_testes)} da sprint #{view_context.link_to tarefa_testes.fixed_version.name, version_path(tarefa_testes.fixed_version)}"
    redirect_to issue_path(@issue)
  end

  private

  def teste_tracker_id
    @teste_tracker_id ||= Tracker.find_by(name: SkyRedminePlugin::Constants::Trackers::TESTE)&.id
  end

  def tarefa_ja_sendo_testada(issue)
    relations = issue.relations_from + issue.relations_to

    relation = relations.find do |relation|
      related_issue = relation.other_issue(issue)
      relation.relation_type == "relates" &&
      related_issue.present? &&
      related_issue.tracker_id == teste_tracker_id
    end

    relation&.other_issue(issue)
  end

  def encontrar_tarefa_testes_usuario_logado(issue)
    sprint_atual = encontrar_sprint_atual(issue.project)
    return nil unless sprint_atual

    tarefa_testes = Issue.find_by(
      tracker_id: teste_tracker_id,
      assigned_to_id: User.current.id,
      fixed_version_id: sprint_atual.id,
    )
    unless tarefa_testes
      tarefa_testes = Issue.new(
        project_id: @issue.project_id,
        author_id: User.current.id,
        tracker_id: teste_tracker_id,
        assigned_to_id: User.current.id,
        fixed_version_id: sprint_atual.id,
        subject: "Tarefas de testes - #{User.current.name}",
      )

      if tarefa_testes.save
        flash[:info] = "Não existia uma tarefa de testes para #{User.current.name}. Foi criada a tarefa #{view_context.link_to "#{tarefa_testes.tracker.name} ##{tarefa_testes.id} - #{tarefa_testes.subject}", issue_path(tarefa_testes)} na sprint #{view_context.link_to tarefa_testes.fixed_version.name, version_path(tarefa_testes.fixed_version)}."
      else
        flash[:error] = "Não foi possível criar uma nova tarefa de testes na sprint #{view_context.link_to "#{sprint_atual.name}", version_path(sprint_atual)}: #{tarefa_testes.errors.full_messages.join(", ")}."
        return nil
      end
    end
    tarefa_testes
  end


end
