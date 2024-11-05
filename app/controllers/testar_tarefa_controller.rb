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

    Issue.find_by(
      tracker_id: teste_tracker_id,
      assigned_to_id: User.current.id,
      fixed_version_id: sprint_atual.id,
    )
  end

  def encontrar_sprint_atual(project)
    hoje = Date.current

    # Busca todas as versões (sprints) do projeto
    project.versions.find do |version|
      next unless version.name.match?(/^\d{4}-\d{2}\s+\(\d{2}\/\d{2}\s+a\s+\d{2}\/\d{2}\)$/)

      # Extrai as datas do nome da sprint
      if version.name =~ /(\d{4})-\d{2}\s+\((\d{2})\/(\d{2})\s+a\s+(\d{2})\/(\d{2})\)/
        ano = $1.to_i
        mes_inicio = $3.to_i
        dia_inicio = $2.to_i
        mes_fim = $5.to_i
        dia_fim = $4.to_i

        # Ajusta o ano para o mês final se necessário
        ano_fim = ano
        ano_fim += 1 if mes_fim < mes_inicio # Se o mês final for menor que o inicial, é porque virou o ano

        data_inicio = Date.new(ano, mes_inicio, dia_inicio)
        data_fim = Date.new(ano_fim, mes_fim, dia_fim)

        # Verifica se a data atual está dentro do período da sprint
        hoje >= data_inicio && hoje <= data_fim
      end
    end
  end
end
