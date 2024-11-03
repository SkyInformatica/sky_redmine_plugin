class TestarTarefaController < ApplicationController
  before_action :find_issue, only: [:testar_tarefa]

  def testar_tarefa
    # Verifica se a tarefa não pertence aos projetos QS e está com status 'Resolvida'
    unless SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(@issue.project.name) &&
           @issue.status.name == SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
      flash[:warning] = "A tarefa deve estar nos projetos de desenvolvimento e com status 'Resolvida' para ser colocada em teste."
      redirect_to issue_path(@issue) and return
    end

    # Verifica se a tarefa já está sendo testada
    if tarefa_ja_sendo_testada?(@issue)
      flash[:warning] = "A tarefa já está sendo testada."
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
      flash[:notice] = "A tarefa foi colocada em teste e relacionada com a tarefa de testes #{view_context.link_to "##{tarefa_testes.id}", issue_path(tarefa_testes)}."
    else
      flash[:warning] = "Não foi encontrada uma tarefa de testes na sprint para fazer a relação."
    end

    redirect_to issue_path(@issue)
  end

  private

  def tarefa_ja_sendo_testada?(issue)
    issue.relations_from.exists?(
      relation_type: "relates",
      issue_to_id: Issue.where(
        tracker_id: SkyRedminePlugin::Constants::Trackers::TESTES,
        fixed_version_id: issue.fixed_version_id,
      ).pluck(:id),
    )
  end

  def encontrar_tarefa_testes(issue)
    Issue.find_by(
      tracker_id: SkyRedminePlugin::Constants::Trackers::TESTES,
      assigned_to_id: issue.assigned_to_id,
      fixed_version_id: issue.fixed_version_id,
    )
  end
end
