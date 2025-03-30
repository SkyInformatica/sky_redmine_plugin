module SkyRedminePlugin
  module TarefasRelacionadas
    def self.obter_lista_tarefas_relacionadas(tarefa)
      tarefas = []
      visitadas = Set.new
      tarefa_atual = tarefa

      # Busca tarefas anteriores (indo para trás na cadeia)
      while true
        break if visitadas.include?(tarefa_atual.id)
        visitadas.add(tarefa_atual.id)

        relacao = IssueRelation.find_by(issue_to_id: tarefa_atual.id, relation_type: "copied_to")
        break unless relacao

        tarefa_anterior = Issue.find(relacao.issue_from_id)
        tarefas.unshift(tarefa_anterior)
        tarefa_atual = tarefa_anterior
      end

      # Adiciona a tarefa atual (que será a última da cadeia)
      tarefas << tarefa

      visitadas.clear  # Limpa as visitadas para a próxima busca

      # Busca tarefas posteriores (indo para frente na cadeia)
      tarefa_atual = tarefa
      while true
        break if visitadas.include?(tarefa_atual.id)
        visitadas.add(tarefa_atual.id)

        relacao = IssueRelation.find_by(issue_from_id: tarefa_atual.id, relation_type: "copied_to")
        break unless relacao

        tarefa_posterior = Issue.find(relacao.issue_to_id)
        tarefas << tarefa_posterior
        tarefa_atual = tarefa_posterior
      end

      # Adiciona os atributos de data para cada tarefa
      tarefas.map do |tarefa|
        # Data de criação pode ser a data de criação ou a data de atendimento
        data_atendimento = obter_valor_campo_personalizado(tarefa, "Data de Atendimento")
        data_criacao = data_atendimento.present? ? data_atendimento : tarefa.created_on
        
        projeto_nome = tarefa.project.name
        if SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(projeto_nome)
          # Tarefas do QS
          status_resolvida = [
            SkyRedminePlugin::Constants::IssueStatus::TESTE_OK,
            SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK,
          ]

          status_fechada = [
            SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA,
            SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA,
            SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT          
          ]
        else
          # Tarefas de Desenvolvimento
          status_resolvida = [SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA]

          status_fechada = [
            SkyRedminePlugin::Constants::IssueStatus::FECHADA,
            SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT,
            SkyRedminePlugin::Constants::IssueStatus::FECHADA_CONTINUA_RETORNO_TESTES,
          ]
        end

        # Obter as datas de resolução e fechamento
        data_resolucao = obter_data_mudanca_status(tarefa, status_resolvida)
        data_fechamento = obter_data_mudanca_status(tarefa, status_fechada)

        # Definir data de andamento
        data_em_andamento = obter_data_mudanca_status(tarefa, [SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO])
        
        # Se não encontrou EM_ANDAMENTO, verificar se está em CONTINUA_PROXIMA_SPRINT
        if data_em_andamento.nil? && tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT
          # Se está em CONTINUA_PROXIMA_SPRINT, mantém data_em_andamento como nil
          data_em_andamento = nil
        elsif data_em_andamento.nil? && (data_resolucao.present? || data_fechamento.present?)
          # Se não encontrou EM_ANDAMENTO mas tem RESOLVIDA ou FECHADA, usa a data de criação
          data_em_andamento = tarefa.created_on
        end

        # Definir datas de resolução e fechamento
        if data_fechamento.present? && data_resolucao.nil?
          # Se foi direto para fechada, usar a data de fechamento para ambos
          data_resolvida = data_fechamento
          data_fechada = data_fechamento
        else
          data_resolvida = data_resolucao
          data_fechada = data_fechamento
        end

        # Se a tarefa está em CONTINUA_PROXIMA_SPRINT, ela não foi resolvida ainda
        if tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT
          data_resolvida = nil
        end

        # Se a tarefa não está atualmente em um status de fechamento, não considerar a data_fechada
        unless status_fechada.include?(tarefa.status.name)
          data_fechada = nil
        end

        tarefa.instance_variable_set(:@data_atendimento, data_atendimento)
        tarefa.instance_variable_set(:@data_criacao, data_criacao)
        tarefa.instance_variable_set(:@data_em_andamento, data_em_andamento)
        tarefa.instance_variable_set(:@data_resolvida, data_resolvida)
        tarefa.instance_variable_set(:@data_fechada, data_fechada)

        tarefa.define_singleton_method(:data_atendimento) { @data_atendimento }
        tarefa.define_singleton_method(:data_criacao) { @data_criacao }
        tarefa.define_singleton_method(:data_em_andamento) { @data_em_andamento }
        tarefa.define_singleton_method(:data_resolvida) { @data_resolvida }
        tarefa.define_singleton_method(:data_fechada) { @data_fechada }

        tarefa
      end
    end

    private

    def self.obter_data_mudanca_status(tarefa, status_nomes)
      status_ids = IssueStatus.where(name: status_nomes).pluck(:id)

      journal = tarefa.journals.joins(:details)
                      .where(journal_details: { property: "attr", prop_key: "status_id", value: status_ids })
                      .order("created_on ASC")
                      .first

      journal&.created_on
    end

    def self.obter_valor_campo_personalizado(tarefa, nome_campo)
      if custom_field = IssueCustomField.find_by(name: nome_campo)
        tarefa.custom_field_value(custom_field.id)
      end
    end
  end
end 