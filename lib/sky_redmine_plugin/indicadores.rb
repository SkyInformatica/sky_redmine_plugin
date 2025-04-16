module SkyRedminePlugin
  module Indicadores
    include TarefasRelacionadas

    def self.processar_indicadores(issue, is_exclusao = false)
      Rails.logger.info ">>> inicio processar_indicadores issue.id: #{issue.id}, is_exclusao: #{is_exclusao}"

      # Se é uma exclusão, procurar o indicador por qualquer um dos campos de ID
      if is_exclusao
        indicador = SkyRedmineIndicadores.find_by(
          "primeira_tarefa_devel_id = ? OR ultima_tarefa_devel_id = ? OR primeira_tarefa_qs_id = ? OR ultima_tarefa_qs_id = ?",
          issue.id, issue.id, issue.id, issue.id
        )

        if indicador
          Rails.logger.info ">>> encontrado indicador para issue.id: #{issue.id}"

          # Se a tarefa excluída é a primeira_tarefa_devel_id, excluir o indicador
          if indicador.primeira_tarefa_devel_id == issue.id
            Rails.logger.info ">>> excluindo indicador pois issue.id é a primeira_tarefa_devel_id"
            indicador.destroy
            return
          end

          # Se não é a primeira_tarefa_devel_id, reprocessar o indicador
          Rails.logger.info ">>> reprocessando indicador usando primeira_tarefa_devel_id: #{indicador.primeira_tarefa_devel_id}"
          issue = Issue.find(indicador.primeira_tarefa_devel_id)
        end
      end

      # Obter fluxo de tarefas usando o método do módulo TarefasRelacionadas
      tarefas_relacionadas = SkyRedminePlugin::TarefasRelacionadas.obter_lista_tarefas_relacionadas(issue)

      # Separar tarefas DEVEL e QS
      tarefas_devel = tarefas_relacionadas.select { |t| t.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL }
      tarefas_qs = tarefas_relacionadas.select { |t| t.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::QS }

      Rails.logger.info ">>> tarefas_devel: #{tarefas_devel.inspect}"
      Rails.logger.info ">>> tarefas_qs: #{tarefas_qs.inspect}"

      # Processar dados DEVEL
      unless tarefas_devel.empty?
        primeira_tarefa_devel = tarefas_devel.first
        ultima_tarefa_devel = tarefas_devel.last

        # Encontrar ou inicializar o indicador
        indicador = SkyRedmineIndicadores.find_or_initialize_by(primeira_tarefa_devel_id: primeira_tarefa_devel.id)

        # Limpar todos os campos antes de processar
        limpar_campos_indicador(indicador)

        indicador.ultima_tarefa_devel_id = ultima_tarefa_devel.id
        indicador.tipo_primeira_tarefa_devel = primeira_tarefa_devel.tracker.name
        indicador.status_ultima_tarefa_devel = ultima_tarefa_devel.status.name
        indicador.prioridade_primeira_tarefa_devel = primeira_tarefa_devel.priority.name
        indicador.projeto_primeira_tarefa_devel = primeira_tarefa_devel.project.name
        indicador.sprint_primeira_tarefa_devel = primeira_tarefa_devel.fixed_version.present? ? primeira_tarefa_devel.fixed_version.name : nil
        indicador.sprint_ultima_tarefa_devel = ultima_tarefa_devel.fixed_version.present? ? ultima_tarefa_devel.fixed_version.name : nil
        indicador.tarefa_complementar = primeira_tarefa_devel.tarefa_complementar
        indicador.teste_no_desenvolvimento = primeira_tarefa_devel.teste_no_desenvolvimento
        indicador.tempo_estimado_devel = tarefas_devel.sum { |t| t.estimated_hours.to_f }
        indicador.tempo_gasto_devel = tarefas_devel.sum { |t| t.spent_hours.to_f }
        indicador.origem_primeira_tarefa_devel = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, "Origem")
        indicador.skynet_primeira_tarefa_devel = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, "Sky.NET")

        # Contar retornos de testes baseado no fluxo entre projetos
        qtd_retorno_testes_qs = 0
        qtd_retorno_testes_devel = 0
        tarefas_relacionadas.each_with_index do |tarefa, index|
          next if index == 0 # Pula a primeira tarefa

          # Se a tarefa atual é DEVEL e a anterior era QS, é um retorno de testes do QS
          if tarefa.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL &&
             tarefas_relacionadas[index - 1].equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::QS
            qtd_retorno_testes_qs += 1
          end

          # Se a tarefa atual é DEVEL e é um retorno de testes, e a anterior foi fechada com FECHADA_CONTINUA_RETORNO_TESTES
          if tarefa.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL &&
             tarefa.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES &&
             tarefas_relacionadas[index - 1].status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA_CONTINUA_RETORNO_TESTES
            qtd_retorno_testes_devel += 1
          end
        end
        indicador.qtd_retorno_testes_qs = qtd_retorno_testes_qs
        indicador.qtd_retorno_testes_devel = qtd_retorno_testes_devel

        # Usar as datas já calculadas pela função obter_lista_tarefas_relacionadas
        indicador.data_criacao_ou_atendimento_primeira_tarefa_devel = primeira_tarefa_devel.data_criacao
        indicador.data_resolvida_ultima_tarefa_devel = ultima_tarefa_devel.data_resolvida
        indicador.data_fechamento_ultima_tarefa_devel = ultima_tarefa_devel.data_fechada

        # Separar tarefas DEVEL em ciclos de desenvolvimento
        ciclos_devel = SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_devel(tarefas_relacionadas)
        primeiro_ciclo_devel = ciclos_devel.first

        # Processar data de início em andamento usando apenas o primeiro ciclo
        data_andamento = nil
        primeiro_ciclo_devel.each do |tarefa|
          if tarefa.data_em_andamento.present?
            data_andamento = tarefa.data_em_andamento
            break
          end
        end
        indicador.data_andamento_primeira_tarefa_devel = data_andamento

        # Calcular tempos DEVEL
        if indicador.data_criacao_ou_atendimento_primeira_tarefa_devel.present? && indicador.data_andamento_primeira_tarefa_devel.present?
          indicador.tempo_andamento_devel = (indicador.data_andamento_primeira_tarefa_devel - indicador.data_criacao_ou_atendimento_primeira_tarefa_devel).to_i
        end

        if indicador.data_andamento_primeira_tarefa_devel.present? && indicador.data_resolvida_ultima_tarefa_devel.present?
          indicador.tempo_resolucao_devel = (indicador.data_resolvida_ultima_tarefa_devel - indicador.data_andamento_primeira_tarefa_devel).to_i
        end

        if indicador.data_resolvida_ultima_tarefa_devel.present? && indicador.data_fechamento_ultima_tarefa_devel.present?
          indicador.tempo_fechamento_devel = (indicador.data_fechamento_ultima_tarefa_devel - indicador.data_resolvida_ultima_tarefa_devel).to_i
        end

        # Processar dados QS
        unless tarefas_qs.empty?
          primeira_tarefa_qs = tarefas_qs.first
          ultima_tarefa_qs = tarefas_qs.last

          indicador.primeira_tarefa_qs_id = primeira_tarefa_qs.id
          indicador.ultima_tarefa_qs_id = ultima_tarefa_qs.id
          indicador.sprint_primeira_tarefa_qs = primeira_tarefa_qs.fixed_version.present? ? primeira_tarefa_qs.fixed_version.name : nil
          indicador.sprint_ultima_tarefa_qs = ultima_tarefa_qs.fixed_version.present? ? ultima_tarefa_qs.fixed_version.name : nil
          indicador.projeto_primeira_tarefa_qs = primeira_tarefa_qs.project.name

          indicador.tempo_estimado_qs = tarefas_qs.sum { |t| t.estimated_hours.to_f }
          indicador.tempo_gasto_qs = tarefas_qs.sum { |t| t.spent_hours.to_f }
          indicador.status_ultima_tarefa_qs = ultima_tarefa_qs.status.name
          indicador.houve_teste_nok = tarefas_qs.any? { |t| [SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(t.status.name) }
          indicador.data_criacao_primeira_tarefa_qs = primeira_tarefa_qs.created_on.to_date

          # Separar tarefas QS em ciclos de teste
          ciclos_qs = SkyRedminePlugin::TarefasRelacionadas.separar_ciclos_qs(tarefas_relacionadas)
          primeiro_ciclo_qs = ciclos_qs.first

          # Processar data de início em andamento QS usando apenas o primeiro ciclo
          data_andamento_qs = nil
          primeiro_ciclo_qs.each do |tarefa|
            if tarefa.data_em_andamento.present?
              data_andamento_qs = tarefa.data_em_andamento
              break
            end
          end
          indicador.data_andamento_primeira_tarefa_qs = data_andamento_qs

          # Usar as datas já calculadas pela função obter_lista_tarefas_relacionadas
          indicador.data_resolvida_ultima_tarefa_qs = ultima_tarefa_qs.data_resolvida
          indicador.data_fechamento_ultima_tarefa_qs = ultima_tarefa_qs.data_fechada

          # Calcular tempos QS
          if indicador.data_criacao_primeira_tarefa_qs.present? && indicador.data_andamento_primeira_tarefa_qs.present?
            indicador.tempo_andamento_qs = (indicador.data_andamento_primeira_tarefa_qs - indicador.data_criacao_primeira_tarefa_qs).to_i
          end

          if indicador.data_andamento_primeira_tarefa_qs.present? && indicador.data_resolvida_ultima_tarefa_qs.present?
            indicador.tempo_resolucao_qs = (indicador.data_resolvida_ultima_tarefa_qs - indicador.data_andamento_primeira_tarefa_qs).to_i
          end

          if indicador.data_resolvida_ultima_tarefa_qs.present? && indicador.data_fechamento_ultima_tarefa_qs.present?
            indicador.tempo_fechamento_qs = (indicador.data_fechamento_ultima_tarefa_qs - indicador.data_resolvida_ultima_tarefa_qs).to_i
          end

          # Calcular tempo para encaminhar para QS (apenas no primeiro ciclo)
          if primeiro_ciclo_devel.last.data_resolvida.present? && indicador.data_criacao_primeira_tarefa_qs.present?
            indicador.tempo_para_encaminhar_qs = indicador.data_criacao_primeira_tarefa_qs - primeiro_ciclo_devel.last.data_resolvida
          end

          # Calcular tempo entre conclusão dos testes e liberação da versão
          if indicador.data_resolvida_ultima_tarefa_qs.present? && indicador.data_fechamento_ultima_tarefa_devel.present?
            indicador.tempo_concluido_testes_versao_liberada = (indicador.data_fechamento_ultima_tarefa_devel - indicador.data_resolvida_ultima_tarefa_qs).to_i
          end
        end

        # Determinar o local atual da tarefa
        # Se a última tarefa DEVEL está fechada, está FECHADA
        ultima_tarefa_devel = tarefas_devel.last
        if [SkyRedminePlugin::Constants::IssueStatus::FECHADA].include?(ultima_tarefa_devel.status.name)
          indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA
        else
          if tarefas_qs.empty?
            # Se não existe tarefa QS, está no DEVEL
            indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL
          else
            ultima_tarefa_qs = tarefas_qs.last
            if [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK,
                SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(ultima_tarefa_qs.status.name)
              indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL
            else
              # Se existe tarefa QS e não está fechada, está no QS
              indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::QS
            end
          end
        end

        # Determinar se a tarefa foi fechada sem testes
        if indicador.data_fechamento_ultima_tarefa_devel.present?
          if tarefas_qs.empty?
            # Se não existe tarefa QS e a última tarefa DEVEL está fechada
            indicador.tarefa_fechada_sem_testes = "SIM"
          else
            # Se existe tarefa QS, verificar se a tarefa DEVEL foi fechada antes da tarefa QS
            if indicador.data_fechamento_ultima_tarefa_qs.present?
              if indicador.data_fechamento_ultima_tarefa_devel < indicador.data_fechamento_ultima_tarefa_qs
                # Se a tarefa DEVEL foi fechada antes da tarefa QS
                indicador.tarefa_fechada_sem_testes = "SIM"
              else
                # Se a tarefa DEVEL foi fechada depois da tarefa QS
                indicador.tarefa_fechada_sem_testes = "NAO"
              end
            else
              # Se a tarefa QS ainda não foi fechada
              indicador.tarefa_fechada_sem_testes = "SIM"
            end
          end
        end

        # Calcular tempo total para liberar versão
        if indicador.data_criacao_ou_atendimento_primeira_tarefa_devel && indicador.data_fechamento_ultima_tarefa_devel
          indicador.tempo_total_liberar_versao = (indicador.data_fechamento_ultima_tarefa_devel - indicador.data_criacao_ou_atendimento_primeira_tarefa_devel).to_i
        end

        # Calcular tempo total de desenvolvimento
        if indicador.data_criacao_ou_atendimento_primeira_tarefa_devel && indicador.data_resolvida_ultima_tarefa_devel
          indicador.tempo_total_devel = (indicador.data_resolvida_ultima_tarefa_devel - indicador.data_criacao_ou_atendimento_primeira_tarefa_devel).to_i
        end

        # Calcular tempo total de testes
        if indicador.data_criacao_primeira_tarefa_qs && indicador.data_resolvida_ultima_tarefa_qs &&
           [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK,
            SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA].include?(ultima_tarefa_qs.status.name)
          indicador.tempo_total_testes = (indicador.data_resolvida_ultima_tarefa_qs - indicador.data_criacao_primeira_tarefa_qs).to_i
        end

        # Calcular tempo total desde a criação da tarefa até a conclusão dos testes
        if indicador.data_criacao_ou_atendimento_primeira_tarefa_devel && indicador.data_resolvida_ultima_tarefa_qs
          indicador.tempo_total_devel_concluir_testes = (indicador.data_resolvida_ultima_tarefa_qs.to_date - indicador.data_criacao_ou_atendimento_primeira_tarefa_devel.to_date).to_i
        end

        if indicador.tarefa_complementar == "NAO"          
          # Determinar a situação atual do desenvolvimento
          indicador.situacao_atual = determinar_situacao_atual(indicador, tarefas_relacionadas, tarefas_devel, tarefas_qs, ciclos_devel, ciclos_qs)
          # Atualizar as tags das tarefas com a situação atual
          atualizar_tags_situacao_atual(tarefas_devel, tarefas_qs, indicador.situacao_atual)
        end

        indicador.save(validate: false)
      end
    end

    def self.limpar_campos_indicador(indicador)
      Rails.logger.info ">>> Limpando todos os campos do indicador"
      # Campos de DEVEL
      indicador.ultima_tarefa_devel_id = nil
      indicador.tipo_primeira_tarefa_devel = nil
      indicador.status_ultima_tarefa_devel = nil
      indicador.prioridade_primeira_tarefa_devel = nil
      indicador.projeto_primeira_tarefa_devel = nil
      indicador.sprint_primeira_tarefa_devel = nil
      indicador.sprint_ultima_tarefa_devel = nil
      indicador.tarefa_complementar = nil
      indicador.teste_no_desenvolvimento = nil
      indicador.tempo_estimado_devel = nil
      indicador.tempo_gasto_devel = nil
      indicador.origem_primeira_tarefa_devel = nil
      indicador.skynet_primeira_tarefa_devel = nil
      indicador.qtd_retorno_testes_qs = nil
      indicador.data_criacao_ou_atendimento_primeira_tarefa_devel = nil
      indicador.data_resolvida_ultima_tarefa_devel = nil
      indicador.data_fechamento_ultima_tarefa_devel = nil
      indicador.data_andamento_primeira_tarefa_devel = nil
      indicador.tempo_andamento_devel = nil
      indicador.tempo_resolucao_devel = nil
      indicador.tempo_fechamento_devel = nil
      indicador.tempo_para_encaminhar_qs = nil
      indicador.tempo_total_liberar_versao = nil
      indicador.tempo_total_devel_concluir_testes = nil

      # Campos de QS
      indicador.primeira_tarefa_qs_id = nil
      indicador.ultima_tarefa_qs_id = nil
      indicador.sprint_primeira_tarefa_qs = nil
      indicador.sprint_ultima_tarefa_qs = nil
      indicador.projeto_primeira_tarefa_qs = nil
      indicador.tempo_estimado_qs = nil
      indicador.tempo_gasto_qs = nil
      indicador.status_ultima_tarefa_qs = nil
      indicador.houve_teste_nok = nil
      indicador.data_criacao_primeira_tarefa_qs = nil
      indicador.data_andamento_primeira_tarefa_qs = nil
      indicador.data_resolvida_ultima_tarefa_qs = nil
      indicador.data_fechamento_ultima_tarefa_qs = nil
      indicador.tempo_andamento_qs = nil
      indicador.tempo_resolucao_qs = nil
      indicador.tempo_fechamento_qs = nil
      indicador.tempo_concluido_testes_versao_liberada = nil
      indicador.tempo_total_testes = nil

      # Campo de localização
      indicador.equipe_responsavel_atual = nil
      indicador.tarefa_fechada_sem_testes = nil
      indicador.situacao_atual = nil
      indicador.fluxo_das_tarefas = nil
    end

    # Método para atualizar as tags das tarefas com a situação atual
    def self.atualizar_tags_situacao_atual(tarefas_devel, tarefas_qs, situacao_atual)
      begin
        Rails.logger.info ">>> Atualizando tags das tarefas com situação atual: #{situacao_atual}"

        # Mapeamento de situações para prefixos numéricos
        prefixos_situacoes = {
          SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA => "99",
          SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL => "01",
          SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL => "02",
          SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_TESTES_DEVEL => "03",
          SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL => "03.1",
          SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS => "04",
          SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS => "05",
          SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_QS => "06",
          SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO => "07",
          SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES => "07",
          SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL_RETORNO_TESTES => "01",
          SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL_RETORNO_TESTES => "02",
          SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES => "04",
          SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS_RETORNO_TESTES => "05",
          SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_QS_RETORNO_TESTES => "06",
          SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO_RETORNO_TESTES => "07",
        }

        # Criar a nova tag baseada na situação atual, exceto para VERSAO_LIBERADA
        nova_tag = if situacao_atual == SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
            nil
          else
            prefixo_num = prefixos_situacoes[situacao_atual]
            situacao_formatada = situacao_atual.gsub("RETORNO_TESTES", "RT").gsub("AGUARDANDO", "AGUARDA")
            "E#{prefixo_num}_#{situacao_formatada}"
          end

        Rails.logger.info ">>> Nova tag a ser definida: #{nova_tag || "Nenhuma (VERSAO_LIBERADA)"}"

        # Primeiro, remover todas as tags antigas de todas as tarefas DEVEL
        tarefas_devel.each do |tarefa|
          atualizar_tag_tarefa(tarefa, nil)
        end

        # Depois, se existir uma nova tag para definir, definir apenas na última tarefa DEVEL
        if nova_tag.present? && !tarefas_devel.empty?
          ultima_tarefa_devel = tarefas_devel.last
          atualizar_tag_tarefa(ultima_tarefa_devel, nova_tag)
        end

        Rails.logger.info ">>> Tags atualizadas com sucesso"
      rescue => e
        Rails.logger.error ">>> Erro ao atualizar tags: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end

    # Método auxiliar para atualizar tags de uma tarefa específica
    def self.atualizar_tag_tarefa(tarefa, nova_tag)
      begin
        tarefa = Issue.find(tarefa.id)
        # Verificar se a tarefa tem o método tag_list (alguns plugins de tagging podem não estar instalados)
        return unless tarefa.respond_to?(:tag_list)

        Rails.logger.info ">>> Atualizando tag da tarefa #{tarefa.id}"

        # Obter lista atual de tags da tarefa
        tags_atuais = tarefa.tag_list.dup

        # Remover tags antigas que começam com o prefixo E seguido de dois dígitos e underscore
        tags_filtradas = tags_atuais.reject { |tag| tag =~ /^E\d{2}_/ }

        # Adicionar a nova tag se não for nil
        tags_filtradas << nova_tag if nova_tag.present?

        # Se as tags mudaram, atualizar a tarefa
        if tags_filtradas != tags_atuais
          Rails.logger.info ">>> Tarefa #{tarefa.id}: alterando tags de #{tags_atuais.join(", ")} para #{tags_filtradas.join(", ")}"
          tarefa.tag_list = tags_filtradas
          tarefa.save(validate: false)
        end
      rescue => e
        Rails.logger.error ">>> Erro ao atualizar tag da tarefa #{tarefa.id}: #{e.message}"
      end
    end

    # Método para determinar a situação atual com base no status das tarefas
    def self.determinar_situacao_atual(indicador, tarefas_relacionadas, tarefas_devel, tarefas_qs, ciclos_devel, ciclos_qs)
      # Primeiro verificar se é uma situação DESCONHECIDA
      situacao = verificar_situacao_desconhecida(tarefas_relacionadas, tarefas_devel, ciclos_devel)
      return situacao if situacao == SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA

      ultima_tarefa = tarefas_relacionadas.last
      ultima_tarefa_devel = tarefas_devel.last

      # Se a última tarefa DEVEL está com situação FECHADA, a versão foi liberada
      if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA
        return SkyRedminePlugin::Constants::SituacaoAtual::VERSAO_LIBERADA
      end

      # Verificar se é uma tarefa que não necessita de QS
      if ultima_tarefa_devel.teste_qs == SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE
        # Verificar se é um retorno de testes que já passou pelo QS anteriormente
        if ultima_tarefa_devel.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES && 
           tarefas_qs.any?
          case ultima_tarefa_devel.status.name
          when SkyRedminePlugin::Constants::IssueStatus::NOVA
            return SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
            return SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
            return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO_RETORNO_TESTES
          end
        else
          # Caso ainda não tenha sido encaminhado para QS
          case ultima_tarefa_devel.status.name
          when SkyRedminePlugin::Constants::IssueStatus::NOVA
            return SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL
          when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
            return SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL
          when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
            return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO
          end
        end
      end

      # Verificar se está no primeiro ciclo com teste no desenvolvimento
      if ciclos_devel.size == 1 && ultima_tarefa_devel.teste_no_desenvolvimento != SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE
        if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
          if ultima_tarefa_devel.teste_no_desenvolvimento == SkyRedminePlugin::Constants::CustomFieldsValues::NAO_TESTADA
            return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_TESTES_DEVEL
          elsif ultima_tarefa_devel.teste_no_desenvolvimento == SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_NOK
            return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL
          end
        end
      end

      # Verificar situações baseadas na última tarefa
      # Usar o indicador já calculado para determinar se é um retorno do QS
      is_retorno_do_qs = indicador.qtd_retorno_testes_qs > 0

      case ultima_tarefa.equipe_responsavel
      when SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL
        case ultima_tarefa.status.name
        when SkyRedminePlugin::Constants::IssueStatus::NOVA
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_DEVEL
        when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_DEVEL
        when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_QS
        end

      when SkyRedminePlugin::Constants::EquipeResponsavel::QS
        case ultima_tarefa.status.name
        when SkyRedminePlugin::Constants::IssueStatus::NOVA
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::SituacaoAtual::ESTOQUE_QS
        when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_QS_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::SituacaoAtual::EM_ANDAMENTO_QS
        when SkyRedminePlugin::Constants::IssueStatus::TESTE_OK
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_VERSAO
        when SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK
          return SkyRedminePlugin::Constants::SituacaoAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES
        end
      end

      # Se nenhuma situação foi identificada, retornar DESCONHECIDA
      SkyRedminePlugin::Constants::SituacaoAtual::DESCONHECIDA
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
end
