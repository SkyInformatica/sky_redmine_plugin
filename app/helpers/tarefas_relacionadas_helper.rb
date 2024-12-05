module TarefasRelacionadasHelper
  include ApplicationHelper
  include IssuesHelper

  def localizar_tarefa_origem_desenvolvimento(issue)
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

      # Verifica a relação da tarefa para encontrar a tarefa original
      relation = IssueRelation.find_by(issue_to_id: current_issue.id, relation_type: "copied_to")

      # Se não houver mais relações de cópia, interrompe o loop
      break unless relation

      related_issue = Issue.find_by(id: relation.issue_from_id)

      # Verifica se a próxima tarefa existe
      break unless related_issue

      current_issue = related_issue
    end

    original_issue
  end

  def localizar_tarefa_copiada_qs(issue)
    # Verificar se já existe uma cópia da tarefa nos projetos QS
    # retorna a ultima tarefa do QS na possivel sequencia de copias de continua na proxima sprint
    current_issue = issue
    last_qs_issue = nil

    loop do
      # Encontrar a relação de cópia a partir da current_issue
      relation = IssueRelation.find_by(issue_from_id: current_issue.id, relation_type: "copied_to")

      # Se não houver mais relações de cópia, interrompe o loop
      break unless relation

      # Obter a próxima tarefa na cadeia
      next_issue = Issue.find_by(id: relation.issue_to_id)

      # Verifica se a próxima tarefa existe
      break unless next_issue

      # Verifica se a tarefa está em um projeto QS
      if SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(next_issue.project.name)
        last_qs_issue = next_issue
      end

      # Avança para a próxima tarefa
      current_issue = next_issue
    end

    last_qs_issue
  end

  def localizar_tarefa_continuidade(issue)
    # verificar se há uma copia de continuidade da tarefa
    related_issues = IssueRelation.where(issue_from_id: @issue.id, relation_type: "copied_to")
    copied_to_issue = related_issues.map { |relation| Issue.find_by(id: relation.issue_to_id) }
      .find { |issue| @issue.project.name == issue.project.name }

    copied_to_issue
  end

  def localizar_tarefa_retorno_testes(issue)
    # verificar se há uma copia de continuidade da tarefa
    related_issues = IssueRelation.where(issue_from_id: @issue.id, relation_type: "copied_to")
    copied_to_issue = related_issues.map { |relation| Issue.find_by(id: relation.issue_to_id) }
      .find { |issue| issue.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES }

    copied_to_issue
  end
end
