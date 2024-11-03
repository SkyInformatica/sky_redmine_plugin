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
      flash[:warning] = "A tarefa já está sendo testada por #{view_context.link_to "#{tarefa_testes_existente.tracker.name} ##{tarefa_testes_existente.id} - #{tarefa_testes_existente.subject}", issue_path(tarefa_testes_existente)}."
      redirect_to issue_path(@issue) and return
    end

    # Encontra a tarefa de testes correspondente
    tarefa_testes = encontrar_tarefa_testes(@issue)

    if tarefa_testes
      # Cria a relação entre a tarefa atual e a tarefa de testes
      IssueRelation.create!(
        issue_from: @issue,
        issue_to: tarefa_testes,
        relation_type: "relates",
      )
      flash[:notice] = "A tarefa foi colocada em teste e relacionada com #{view_context.link_to "#{tarefa_testes_existente.tracker.name} ##{tarefa_testes_existente.id} - #{tarefa_testes_existente.subject}", issue_path(tarefa_testes_existente)}."
    else
      flash[:warning] = "Não foi encontrada uma tarefa de testes na sprint para fazer a relação."
    end

    redirect_to issue_path(@issue)
  end

  private

  def teste_tracker_id
    @teste_tracker_id ||= Tracker.find_by(name: SkyRedminePlugin::Constants::Trackers::TESTE)&.id
  end

  def tarefa_ja_sendo_testada(issue)
    issue.relations_from.includes(:issue_to).find do |relation|
      relation.relation_type == "relates" &&
      relation.issue_to.tracker_id == teste_tracker_id &&
      relation.issue_to.fixed_version_id == issue.fixed_version_id
    end&.issue_to
  end

  def encontrar_tarefa_testes(issue)
    Issue.find_by(
      tracker_id: teste_tracker_id,
      assigned_to_id: issue.assigned_to_id,
      fixed_version_id: issue.fixed_version_id,
    )
  end
end
