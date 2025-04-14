require File.expand_path('../../test_helper', __FILE__)

class TestIndicadores < ActiveSupport::TestCase
  fixtures :projects, :issues, :issue_statuses, :trackers, :custom_fields, :custom_values

  def setup
    @project = Project.find_by(name: "Equipe Notar")
    @tracker = Tracker.first
    @status_nova = IssueStatus.find_by(name: "Nova")
    @status_em_andamento = IssueStatus.find_by(name: "Em andamento")
    @status_resolvida = IssueStatus.find_by(name: "Resolvida")
  end

  def test_cenario_1_tarefa_nova
    # Cenário 1: Criar uma tarefa nova
    issue = Issue.new(
      project: @project,
      tracker: @tracker,
      status: @status_nova,
      subject: "Teste Cenário 1 - Tarefa Nova",
      description: "Tarefa para testar o cenário 1 - apenas tarefa nova"
    )
    assert issue.save, "Falha ao salvar a tarefa nova: #{issue.errors.full_messages.join(', ')}"
    
    # Processar indicadores
    SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    
    # Verificar se o indicador foi criado
    indicador = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: issue.id)
    assert_not_nil indicador, "Indicador não foi criado para a tarefa nova"
    assert_equal "ESTOQUE_DEVEL", indicador.situacao_atual, "Situação atual incorreta para tarefa nova"
  end

  def test_cenario_2_tarefa_nova_em_andamento
    # Cenário 2: Criar uma tarefa nova e depois colocá-la em andamento
    issue = Issue.new(
      project: @project,
      tracker: @tracker,
      status: @status_nova,
      subject: "Teste Cenário 2 - Tarefa Nova para Em Andamento",
      description: "Tarefa para testar o cenário 2 - nova e depois em andamento"
    )
    assert issue.save, "Falha ao salvar a tarefa nova: #{issue.errors.full_messages.join(', ')}"
    
    # Processar indicadores para a tarefa nova
    SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    
    # Atualizar para em andamento
    issue.status = @status_em_andamento
    assert issue.save, "Falha ao atualizar a tarefa para em andamento: #{issue.errors.full_messages.join(', ')}"
    
    # Processar indicadores novamente
    SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    
    # Verificar se o indicador foi atualizado
    indicador = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: issue.id)
    assert_not_nil indicador, "Indicador não foi encontrado para a tarefa em andamento"
    assert_equal "EM_ANDAMENTO_DEVEL", indicador.situacao_atual, "Situação atual incorreta para tarefa em andamento"
  end

  def test_cenario_3_tarefa_nova_em_andamento_resolvida
    # Cenário 3: Criar uma tarefa nova, colocá-la em andamento e depois resolvida
    issue = Issue.new(
      project: @project,
      tracker: @tracker,
      status: @status_nova,
      subject: "Teste Cenário 3 - Tarefa Nova para Em Andamento para Resolvida",
      description: "Tarefa para testar o cenário 3 - nova, em andamento e resolvida"
    )
    assert issue.save, "Falha ao salvar a tarefa nova: #{issue.errors.full_messages.join(', ')}"
    
    # Processar indicadores para a tarefa nova
    SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    
    # Atualizar para em andamento
    issue.status = @status_em_andamento
    assert issue.save, "Falha ao atualizar a tarefa para em andamento: #{issue.errors.full_messages.join(', ')}"
    
    # Processar indicadores para em andamento
    SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    
    # Atualizar para resolvida
    issue.status = @status_resolvida
    assert issue.save, "Falha ao atualizar a tarefa para resolvida: #{issue.errors.full_messages.join(', ')}"
    
    # Processar indicadores para resolvida
    SkyRedminePlugin::Indicadores.processar_indicadores(issue)
    
    # Verificar se o indicador foi atualizado
    indicador = SkyRedmineIndicadores.find_by(primeira_tarefa_devel_id: issue.id)
    assert_not_nil indicador, "Indicador não foi encontrado para a tarefa resolvida"
    assert_equal "AGUARDANDO_ENCAMINHAR_QS", indicador.situacao_atual, "Situação atual incorreta para tarefa resolvida"
  end
end 