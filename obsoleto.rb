
    # Método para determinar a situação atual com base no status das tarefas - OBSOLETO
    def self.determinar_situacao_atual_OBSOLETO(indicador,tarefas_relacionadas, tarefas_devel, tarefas_qs, ciclos_devel, ciclos_qs)
      # Primeiro verificar se é uma situação DESCONHECIDA
      situacao = verificar_situacao_desconhecida(tarefas_relacionadas, tarefas_devel, ciclos_devel)
      return situacao if situacao == SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA

      # Obter a última tarefa DEVEL
      ultima_tarefa_devel = tarefas_devel.last
      # Verificar se a tarefa atual é retorno de testes
      eh_retorno_testes = ultima_tarefa_devel.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES
      
      # Verificar o status da última tarefa DEVEL
      if tarefas_qs.empty?
        # Não há tarefas de QS, apenas DEVEL
        if eh_retorno_testes
          # Está em retorno de testes
          case ultima_tarefa_devel.status.name
          when SkyRedminePlugin::Constants::IssueStatus::NOVA
            return SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
            return SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
            return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::FECHADA
            # Se a tarefa DEVEL está fechada, a versão foi liberada
            return SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
          end
        else
          # Está em desenvolvimento normal
          case ultima_tarefa_devel.status.name
          when SkyRedminePlugin::Constants::IssueStatus::NOVA
            return SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL
          when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
            return SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL
          when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
            return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS
          when SkyRedminePlugin::Constants::IssueStatus::FECHADA
            # Se a tarefa DEVEL está fechada, a versão foi liberada
            return SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
          end
        end
      else
        # Existe tarefa de QS
        ultima_tarefa_qs = tarefas_qs.last

        # CORREÇÃO: Verificar se a tarefa QS já está com teste OK mesmo que a DEVEL esteja somente resolvida
        if ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_OK ||
           ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA
          # Se a tarefa QS já está com Teste OK, está aguardando versão
          if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA
            return SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
          else
            # Verificar se é um retorno de testes
            if eh_retorno_testes || tarefas_qs.any? { |t| [SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(t.status.name) }
              return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO_RETORNO_TESTES
            else
              return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO
            end
          end
        end

        # NOVA LÓGICA: Se a última tarefa QS é mais recente que a última resolução DEVEL,
        # então a situação deve ser baseada na tarefa QS
        if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA &&
           ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::NOVA
          # Se a tarefa DEVEL está RESOLVIDA e já existe uma tarefa QS NOVA,
          # significa que a tarefa já saiu do DEVEL e está no QS
          return eh_retorno_testes ? SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS
        end

        # CORREÇÃO: Verificar primeiro se a última tarefa DEVEL é de retorno de testes e está em algum status ativo
        # Isso deve ter precedência mesmo que a última tarefa do QS esteja com TESTE_NOK_FECHADA
        if eh_retorno_testes
          case ultima_tarefa_devel.status.name
          when SkyRedminePlugin::Constants::IssueStatus::NOVA
            return SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
            return SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
            # CORREÇÃO: Verificar se existe uma tarefa QS posterior já com Teste OK
            # Verificamos pela data de criação da QS posterior à data de resolução da DEVEL
            if ultima_tarefa_devel.data_resolvida.present? &&
               ultima_tarefa_qs.created_on.to_date > ultima_tarefa_devel.data_resolvida
              # Se existe tarefa QS criada após a resolução da DEVEL, avaliar seu status
              if ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_OK ||
                 ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA
                return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO_RETORNO_TESTES
              elsif ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::NOVA
                return SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS_RETORNO_TESTES
              elsif ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
                return SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_QS_RETORNO_TESTES
              end
            end
            # Se não há tarefa QS posterior ou não está com Teste OK
            return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::FECHADA
            # Verificar se a última tarefa QS está com TESTE_OK ou TESTE_OK_FECHADA
            if ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_OK ||
               ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA
              # Se o teste foi OK e a tarefa DEVEL está fechada, a versão foi liberada
              return SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
            end
          end
        end

        # Verificar o status da última tarefa QS
        case ultima_tarefa_qs.status.name
        when SkyRedminePlugin::Constants::IssueStatus::NOVA
          # Identificar se é retorno de testes ou não
          return ultima_tarefa_qs.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES ?
                   SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS
        when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
          # Identificar se é retorno de testes ou não
          return ultima_tarefa_qs.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES ?
                   SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_QS_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_QS
        when SkyRedminePlugin::Constants::IssueStatus::TESTE_OK
          # Se o teste foi OK, está aguardando versão
          # Verificar se a tarefa DEVEL foi fechada
          if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA
            return SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
          else
            # Verificar se é um retorno de testes
            if eh_retorno_testes || tarefas_qs.any? { |t| [SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(t.status.name) }
              return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO_RETORNO_TESTES
            else
              return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO
            end
          end
        when SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK
          return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES
        when SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA
          # Se o teste foi OK e fechado, verificar se a tarefa DEVEL foi fechada
          if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA
            return SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
          else
            # Verificar se é um retorno de testes
            if eh_retorno_testes || tarefas_qs.any? { |t| [SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(t.status.name) }
              return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO_RETORNO_TESTES
            else
              return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO
            end
          end
        when SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA
          # Verificar se há nova tarefa de DEVEL de retorno_testes e seu status
          if ciclos_devel.size > 1
            ultimo_ciclo_devel = ciclos_devel.last
            ultima_tarefa_ultimo_ciclo = ultimo_ciclo_devel.last

            if ultima_tarefa_ultimo_ciclo.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES
              case ultima_tarefa_ultimo_ciclo.status.name
              when SkyRedminePlugin::Constants::IssueStatus::NOVA
                return SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL_RETORNO_TESTES
              when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
                return SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL_RETORNO_TESTES
              when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
                # CORREÇÃO: Verificar se existe tarefa QS posterior com Teste OK
                if ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_OK ||
                   ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA
                  return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO_RETORNO_TESTES
                else
                  return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES
                end
              end
            end
          end

          # Se não encontrou uma tarefa de retorno ativa, significa que está aguardando
          return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES
        else
          # Para outros casos, verificar a situação do DEVEL
          case ultima_tarefa_devel.status.name
          when SkyRedminePlugin::Constants::IssueStatus::NOVA
            return SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL
          when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
            return SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL
          when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
            return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS
          when SkyRedminePlugin::Constants::IssueStatus::FECHADA
            # Se a tarefa DEVEL está fechada, a versão foi liberada
            return SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
          end
        end
      end

      # Caso padrão se nenhuma condição for atendida
      return SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL
    end

    # Método para verificar se a situação é DESCONHECIDA
    def self.verificar_situacao_desconhecida(tarefas_relacionadas, tarefas_devel, ciclos_devel)
      # Regra 1: Verificar se a última tarefa do último ciclo DEVEL é FECHADA_CONTINUA_RETORNO_TESTES
      ultima_tarefa_devel = tarefas_devel.last
      if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA_CONTINUA_RETORNO_TESTES
        return SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA
      end

      # Regra 2: Verificar se a última tarefa de todo o ciclo é TESTE_NOK_FECHADA
      ultima_tarefa_ciclo = tarefas_relacionadas.last
      if ultima_tarefa_ciclo.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::QS &&
         ultima_tarefa_ciclo.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA
        return SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA
      end

      # Regra 3: Verificar se há algum ciclo de continuidade onde as tarefas DEVEL não são do tipo RETORNO_TESTES
      if ciclos_devel.size > 1
        # Verificar todos os ciclos de continuidade (após o primeiro ciclo)
        ciclos_devel[1..-1].each do |ciclo|
          ciclo.each do |tarefa|
            if tarefa.tracker.name != SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES
              return SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA
            end
          end
        end
      end

      # Se não atende nenhuma condição de DESCONHECIDA, retorna nil para continuar a verificação
      nil
    end
  end