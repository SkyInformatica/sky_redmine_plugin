class TestarTarefaController < ApplicationController
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
      # Se não existir uma tarefa de testes para o usuário atual, cria uma nova
      tarefa_testes = Issue.new(
        tracker_id: teste_tracker_id,
        assigned_to_id: User.current.id,
        fixed_version_id: @issue.fixed_version_id,
        subject: "Tarefas de testes - #{User.current.name}",
      )

      if tarefa_testes.save
        flash[:notice] = "Nova tarefa de testes criada: #{view_context.link_to "#{tarefa_testes.tracker.name} ##{tarefa_testes.id} - #{tarefa_testes.subject}", issue_path(tarefa_testes)}."
      else
        flash[:error] = "Não foi possível criar uma nova tarefa de testes."
        redirect_to issue_path(@issue) and return
      end
    end

    # Cria a relação entre a issue atual e a tarefa de testes encontrada ou criada
    IssueRelation.create(
      issue_from: @issue,
      issue_to: tarefa_testes,
      relation_type: "relates",
    )

    flash[:notice] ||= "A tarefa foi colocada em teste e relacionada com #{view_context.link_to "#{tarefa_testes.tracker.name} ##{tarefa_testes.id} - #{tarefa_testes.subject}", issue_path(tarefa_testes)}."
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
    Issue.find_by(
      tracker_id: teste_tracker_id,
      assigned_to_id: User.current.id,
      fixed_version_id: issue.fixed_version_id,
    )
  end
end
