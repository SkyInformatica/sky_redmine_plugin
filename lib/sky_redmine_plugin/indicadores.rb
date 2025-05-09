module SkyRedminePlugin
  module Indicadores
    include TarefasRelacionadas

    def self.processar_indicadores(issue, is_exclusao = false)
      Rails.logger.info ">>> inicio processar_indicadores issue.id: #{issue.id}, is_exclusao: #{is_exclusao}"

      # Verifica se o projeto da tarefa está na lista de projetos relevantes, se nao estiver, nao continua o processamento
      if !SkyRedminePlugin::Constants::Projects::TODOS_PROJETOS.include?(issue.project.name)
        return
      end

      # Se é uma exclusão, procurar o indicador por qualquer um dos campos de ID
      if is_exclusao
        indicador = SkyRedmineIndicadores.find_by(
          "id_tarefa = ? OR id_ultima_tarefa = ? OR id_tarefa_qs = ? OR id_ultima_tarefa_qs = ?",
          issue.id, issue.id, issue.id, issue.id
        )

        if indicador
          Rails.logger.info ">>> encontrado indicador para issue.id: #{issue.id}"

          # Se a tarefa excluída é a id_tarefa, excluir o indicador
          if indicador.id_tarefa == issue.id
            Rails.logger.info ">>> excluindo indicador pois issue.id é a id_tarefa"
            indicador.destroy
            return
          end

          # Se não é a id_tarefa, reprocessar o indicador
          Rails.logger.info ">>> reprocessando indicador usando id_tarefa: #{indicador.id_tarefa}"
          issue = Issue.find(indicador.id_tarefa)
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

        if primeira_tarefa_devel.tarefa_complementar == SkyRedminePlugin::Constants::TarefasComplementares::TAREFA_NAO_PLANEJADA
          return
        end

        # Encontrar ou inicializar o indicador
        indicador = SkyRedmineIndicadores.find_or_initialize_by(id_tarefa: primeira_tarefa_devel.id)

        # Limpar todos os campos antes de processar
        limpar_campos_indicador(indicador)

        indicador.id_ultima_tarefa = ultima_tarefa_devel.id
        indicador.tipo = primeira_tarefa_devel.tracker.name
        indicador.status = ultima_tarefa_devel.status.name
        indicador.prioridade = primeira_tarefa_devel.priority.name
        indicador.projeto = primeira_tarefa_devel.project.name
        indicador.sprint = primeira_tarefa_devel.fixed_version.present? ? primeira_tarefa_devel.fixed_version.name : nil
        indicador.sprint_ultima_tarefa = ultima_tarefa_devel.fixed_version.present? ? ultima_tarefa_devel.fixed_version.name : nil
        indicador.tarefa_complementar = primeira_tarefa_devel.tarefa_complementar
        indicador.teste_no_desenvolvimento = primeira_tarefa_devel.teste_no_desenvolvimento
        indicador.tempo_estimado = tarefas_devel.sum { |t| t.estimated_hours.to_f }
        indicador.tempo_gasto = tarefas_devel.sum { |t| t.spent_hours.to_f }
        indicador.data_criacao_ou_atendimento = primeira_tarefa_devel.data_criacao
        indicador.data_resolvida = ultima_tarefa_devel.data_resolvida
        indicador.data_fechamento = ultima_tarefa_devel.data_fechada
        indicador.versao_teste = ultima_tarefa_devel.versao_teste
        indicador.versao_estavel = ultima_tarefa_devel.versao_estavel
        indicador.atribuido_para = primeira_tarefa_devel.assigned_to&.name
        indicador.categoria = primeira_tarefa_devel.category&.name
        indicador.origem = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::ORIGEM)
        indicador.skynet = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::SKYNET)
        indicador.sistema = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::SISTEMA)
        indicador.cliente = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::CLIENTE)
        indicador.clientenome = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::CLIENTE_NOME)
        indicador.clientecidade = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::CLIENTE_CIDADE)
        indicador.qtde_skynet = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::QUANTIDADE_SKYNET)
        indicador.data_prevista = primeira_tarefa_devel.due_date
        indicador.tarefa_nao_planejada_imediata = tarefas_devel.any? { |tarefa_qs|
          SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(tarefa_qs, SkyRedminePlugin::Constants::CustomFields::TAREFA_NAO_PLANEJADA_IMEDIATA) == "Sim"
        } ? "Sim" : "Não"

        # Verificar se alguma tarefa QS tem tarefa antecipada sprint = "Sim"
        indicador.tarefa_antecipada_sprint = tarefas_devel.any? { |tarefa_qs|
          SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(tarefa_qs, SkyRedminePlugin::Constants::CustomFields::TAREFA_ANTECIPADA_SPRINT) == "Sim"
        } ? "Sim" : "Não"
        if indicador.tarefa_complementar == "NAO"
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
          indicador.data_andamento = data_andamento

          # Calcular tempos DEVEL
          if indicador.data_criacao_ou_atendimento.present? && indicador.data_andamento.present?
            indicador.tempo_andamento = (indicador.data_andamento.to_date - indicador.data_criacao_ou_atendimento.to_date).to_i
            indicador.tempo_andamento_detalhes = "De #{indicador.data_criacao_ou_atendimento&.strftime("%d/%m/%Y")} até #{indicador.data_andamento&.strftime("%d/%m/%Y")}"
          end

          if indicador.data_andamento.present? && indicador.data_resolvida.present?
            indicador.tempo_resolucao = (indicador.data_resolvida.to_date - indicador.data_andamento.to_date).to_i
            indicador.tempo_resolucao_detalhes = "De #{indicador.data_andamento&.strftime("%d/%m/%Y")} até #{indicador.data_resolvida&.strftime("%d/%m/%Y")}"
          end

          if indicador.data_resolvida.present? && indicador.data_fechamento.present?
            indicador.tempo_fechamento = (indicador.data_fechamento.to_date - indicador.data_resolvida.to_date).to_i
            indicador.tempo_fechamento_detalhes = "De #{indicador.data_resolvida&.strftime("%d/%m/%Y")} até #{indicador.data_fechamento&.strftime("%d/%m/%Y")}"
          end

          # Processar dados QS
          unless tarefas_qs.empty?
            primeira_tarefa_qs = tarefas_qs.first
            ultima_tarefa_qs = tarefas_qs.last

            indicador.id_tarefa_qs = primeira_tarefa_qs.id
            indicador.id_ultima_tarefa_qs = ultima_tarefa_qs.id
            indicador.sprint_qs = primeira_tarefa_qs.fixed_version.present? ? primeira_tarefa_qs.fixed_version.name : nil
            indicador.sprint_ultima_tarefa_qs = ultima_tarefa_qs.fixed_version.present? ? ultima_tarefa_qs.fixed_version.name : nil
            indicador.projeto_qs = primeira_tarefa_qs.project.name
            indicador.atribuido_para_qs = primeira_tarefa_qs.assigned_to&.name
            # Verificar se alguma tarefa QS tem tarefa não planejada imediata = "Sim"
            indicador.tarefa_nao_planejada_imediata_qs = tarefas_qs.any? { |tarefa_qs|
              SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(tarefa_qs, SkyRedminePlugin::Constants::CustomFields::TAREFA_NAO_PLANEJADA_IMEDIATA) == "Sim"
            } ? "Sim" : "Não"

            # Verificar se alguma tarefa QS tem tarefa antecipada sprint = "Sim"
            indicador.tarefa_antecipada_sprint_qs = tarefas_qs.any? { |tarefa_qs|
              SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(tarefa_qs, SkyRedminePlugin::Constants::CustomFields::TAREFA_ANTECIPADA_SPRINT) == "Sim"
            } ? "Sim" : "Não"
            indicador.tarefa_nao_planejada_imediata_qs = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_qs, SkyRedminePlugin::Constants::CustomFields::TAREFA_NAO_PLANEJADA_IMEDIATA)
            indicador.tarefa_antecipada_sprint_qs = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(primeira_tarefa_qs, SkyRedminePlugin::Constants::CustomFields::TAREFA_ANTECIPADA_SPRINT)

            categorias_teste_nok = tarefas_qs.map { |tarefa_qs|
              valor = SkyRedminePlugin::TarefasRelacionadas.obter_valor_campo_personalizado(tarefa_qs, SkyRedminePlugin::Constants::CustomFields::CATEGORIA_TESTE_NOK)
              valor.present? ? valor : nil
            }.compact.uniq.join(", ")

            # Guardar todas as categorias
            indicador.categoria_teste_nok_todas_tarefas_qs = categorias_teste_nok.presence

            # Pegar apenas a primeira categoria de forma mais segura
            indicador.categoria_teste_nok = if categorias_teste_nok.present?
                categorias_teste_nok.split(",").first&.strip
              else
                nil
              end
            indicador.tempo_estimado_qs = tarefas_qs.sum { |t| t.estimated_hours.to_f }
            indicador.tempo_gasto_qs = tarefas_qs.sum { |t| t.spent_hours.to_f }
            indicador.status_qs = ultima_tarefa_qs.status.name
            indicador.houve_teste_nok = tarefas_qs.any? { |t| [SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(t.status.name) }
            indicador.data_criacao_qs = primeira_tarefa_qs.created_on.to_date

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
            indicador.data_andamento_qs = data_andamento_qs

            # Usar as datas já calculadas pela função obter_lista_tarefas_relacionadas
            indicador.data_resolvida_qs = ultima_tarefa_qs.data_resolvida
            indicador.data_fechamento_qs = ultima_tarefa_qs.data_fechada

            # Calcular tempos QS
            if indicador.data_criacao_qs.present? && indicador.data_andamento_qs.present?
              indicador.tempo_andamento_qs = (indicador.data_andamento_qs.to_date - indicador.data_criacao_qs.to_date).to_i
              indicador.tempo_andamento_qs_detalhes = "De #{indicador.data_criacao_qs&.strftime("%d/%m/%Y")} até #{indicador.data_andamento_qs&.strftime("%d/%m/%Y")}"
            end

            if indicador.data_andamento_qs.present? && indicador.data_resolvida_qs.present?
              indicador.tempo_resolucao_qs = (indicador.data_resolvida_qs.to_date - indicador.data_andamento_qs.to_date).to_i
              indicador.tempo_resolucao_qs_detalhes = "De #{indicador.data_andamento_qs&.strftime("%d/%m/%Y")} até #{indicador.data_resolvida_qs&.strftime("%d/%m/%Y")}"
            end

            if indicador.data_resolvida_qs.present? && indicador.data_fechamento_qs.present?
              indicador.tempo_fechamento_qs = (indicador.data_fechamento_qs.to_date - indicador.data_resolvida_qs.to_date).to_i
              indicador.tempo_fechamento_qs_detalhes = "De #{indicador.data_resolvida_qs&.strftime("%d/%m/%Y")} até #{indicador.data_fechamento_qs&.strftime("%d/%m/%Y")}"
            end

            # Calcular tempo para encaminhar para QS (apenas no primeiro ciclo)
            if primeiro_ciclo_devel.last.data_resolvida.present? && indicador.data_criacao_qs.present?
              indicador.tempo_para_encaminhar_qs = (indicador.data_criacao_qs.to_date - primeiro_ciclo_devel.last.data_resolvida.to_date).to_i
              indicador.tempo_para_encaminhar_qs_detalhes = "De #{primeiro_ciclo_devel.last.data_resolvida&.strftime("%d/%m/%Y")} até #{indicador.data_criacao_qs&.strftime("%d/%m/%Y")}"
            end

            # Calcular tempo entre conclusão dos testes e liberação da versão
            if indicador.data_resolvida_qs.present? && indicador.data_fechamento.present?
              indicador.tempo_concluido_testes_versao_liberada = (indicador.data_fechamento.to_date - indicador.data_resolvida_qs.to_date).to_i
              indicador.tempo_concluido_testes_versao_liberada_detalhes = "De #{indicador.data_resolvida_qs&.strftime("%d/%m/%Y")} até #{indicador.data_fechamento&.strftime("%d/%m/%Y")}"
            end
          end

          # Determinar o local atual da tarefa
          # Se a última tarefa DEVEL está fechada, está FECHADAf
          ultima_tarefa_devel = tarefas_devel.last

          if (tarefas_qs.empty? &&
              [SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE].include?(ultima_tarefa_devel.teste_qs) &&
              [SkyRedminePlugin::Constants::IssueStatus::FECHADA].include?(ultima_tarefa_devel.status.name)) ||
             (!tarefas_qs.empty? &&
              [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA, SkyRedminePlugin::Constants::IssueStatus::CANCELADA].include?(ultima_tarefa_qs.status.name) &&
              [SkyRedminePlugin::Constants::IssueStatus::FECHADA].include?(ultima_tarefa_devel.status.name))
            indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA
          else
            if tarefas_qs.empty? || ultima_tarefa_devel.teste_qs == SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE
              # Se não existe tarefa QS, está no DEVEL
              indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL
            else
              if tarefas_qs.size > 0 && [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK,
                                         SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA, SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA].include?(ultima_tarefa_qs.status.name)
                indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL
              else
                # Se existe tarefa QS e não está fechada, está no QS
                indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::QS
              end
            end
          end

          # Determinar se a tarefa foi fechada sem testes
          Rails.logger.info ">>> Verificando se a tarefa foi fechada sem testes"
          if indicador.data_fechamento.present?
            if tarefas_qs.empty?
              # Se não existe tarefa QS e a última tarefa DEVEL está fechada
              indicador.tarefa_fechada_sem_testes = "SIM"
            else
              Rails.logger.info ">>> Verificando se a ultima tarefa QS está CANCELADA #{ultima_tarefa_qs.id} - #{ultima_tarefa_qs.status.name}"
              # Verificar se a última tarefa QS está CANCELADA
              if ultima_tarefa_qs.status.name == SkyRedminePlugin::Constants::IssueStatus::CANCELADA
                indicador.tarefa_fechada_sem_testes = "NAO"
              else
                # Se existe tarefa QS, verificar se a tarefa DEVEL foi fechada antes da tarefa QS
                if indicador.data_fechamento_qs.present?
                  if indicador.data_fechamento.to_date < indicador.data_fechamento_qs.to_date
                    Rails.logger.info ">>> A tarefa DEVEL foi fechada antes da tarefa QS"
                    # Se a tarefa DEVEL foi fechada antes da tarefa QS
                    indicador.tarefa_fechada_sem_testes = "SIM"
                  else
                    Rails.logger.info ">>> A tarefa DEVEL não foi fechada antes da tarefa QS"
                    # Se a tarefa DEVEL foi fechada depois da tarefa QS
                    indicador.tarefa_fechada_sem_testes = "NAO"
                  end
                else
                  Rails.logger.info ">>> A tarefa QS ainda não foi fechada"
                  # Se a tarefa QS ainda não foi fechada
                  indicador.tarefa_fechada_sem_testes = "SIM"
                end
              end
            end
          end

          # Calcular tempo total para liberar versão
          if indicador.data_criacao_ou_atendimento && indicador.data_fechamento
            indicador.tempo_total_liberar_versao = (indicador.data_fechamento.to_date - indicador.data_criacao_ou_atendimento.to_date).to_i
          end

          # Calcular tempo total de desenvolvimento
          if indicador.data_criacao_ou_atendimento && indicador.data_resolvida
            indicador.tempo_total_devel = (indicador.data_resolvida.to_date - indicador.data_criacao_ou_atendimento.to_date).to_i
          end

          # Calcular tempo total de testes
          # Calcular tempo total de testes
          if indicador.data_criacao_qs && indicador.data_resolvida_qs &&
             [SkyRedminePlugin::Constants::IssueStatus::TESTE_OK,
              SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA].include?(ultima_tarefa_qs.status.name)
            indicador.tempo_total_testes = (indicador.data_resolvida_qs.to_date - indicador.data_criacao_qs.to_date).to_i
          end

          # Calcular tempo total desde a criação da tarefa até a conclusão dos testes
          if indicador.data_criacao_ou_atendimento && indicador.data_resolvida_qs
            indicador.tempo_total_devel_concluir_testes = (indicador.data_resolvida_qs.to_date - indicador.data_criacao_ou_atendimento.to_date).to_i
          end

          # Determinar a situação atual do desenvolvimento
          indicador.etapa_atual = determinar_etapa_atual(indicador, tarefas_relacionadas, tarefas_devel, tarefas_qs, ciclos_devel, ciclos_qs)
          #indicador.etapa_atual_agrupado_retorno_testes = obter_etapa_atual_agrupado_retorno_testes(indicador.etapa_atual)
          # Atualizar as tags das tarefas com a situação atual
          atualizar_tags_etapa_atual(tarefas_devel, tarefas_qs, indicador.etapa_atual)
        end

        indicador.save(validate: false)
      end
    end

    def self.limpar_campos_indicador(indicador)
      Rails.logger.info ">>> Limpando todos os campos do indicador"
      # Campos de DEVEL
      indicador.id_ultima_tarefa = nil
      indicador.tipo = nil
      indicador.status = nil
      indicador.prioridade = nil
      indicador.projeto = nil
      indicador.sprint = nil
      indicador.sprint_ultima_tarefa = nil
      indicador.atribuido_para = nil
      indicador.categoria = nil
      indicador.sistema = nil
      indicador.origem = nil
      indicador.skynet = nil
      indicador.cliente = nil
      indicador.clientenome = nil
      indicador.clientecidade = nil
      indicador.qtde_skynet = nil
      indicador.data_prevista = nil
      indicador.tarefa_nao_planejada_imediata = nil
      indicador.tarefa_antecipada_sprint = nil
      indicador.versao_estavel = nil
      indicador.versao_teste = nil
      indicador.teste_no_desenvolvimento = nil
      indicador.tempo_estimado = nil
      indicador.tempo_gasto = nil
      indicador.data_criacao_ou_atendimento = nil
      indicador.data_resolvida = nil
      indicador.data_fechamento = nil
      indicador.data_andamento = nil
      indicador.tempo_andamento = nil
      indicador.tempo_resolucao = nil
      indicador.tempo_fechamento = nil
      indicador.tempo_para_encaminhar_qs = nil
      indicador.tempo_total_liberar_versao = nil
      indicador.tempo_total_devel_concluir_testes = nil
      indicador.tempo_andamento_detalhes = nil
      indicador.tempo_resolucao_detalhes = nil
      indicador.tempo_fechamento_detalhes = nil
      indicador.tempo_para_encaminhar_qs_detalhes = nil
      indicador.tempo_total_devel = nil
      indicador.qtd_retorno_testes_devel = nil

      # Campos de QS
      indicador.id_tarefa_qs = nil
      indicador.id_ultima_tarefa_qs = nil
      indicador.status_qs = nil
      indicador.projeto_qs = nil
      indicador.sprint_qs = nil
      indicador.sprint_ultima_tarefa_qs = nil
      indicador.atribuido_para_qs = nil
      indicador.tarefa_nao_planejada_imediata_qs = nil
      indicador.tarefa_antecipada_sprint_qs = nil
      indicador.tempo_estimado_qs = nil
      indicador.tempo_gasto_qs = nil
      indicador.houve_teste_nok = nil
      indicaodr.categoria_teste_nok = nil
      indicador.data_criacao_qs = nil
      indicador.data_andamento_qs = nil
      indicador.data_resolvida_qs = nil
      indicador.data_fechamento_qs = nil
      indicador.tempo_andamento_qs = nil
      indicador.tempo_resolucao_qs = nil
      indicador.tempo_fechamento_qs = nil
      indicador.tempo_concluido_testes_versao_liberada = nil
      indicador.tempo_total_testes = nil
      indicador.tempo_andamento_qs_detalhes = nil
      indicador.tempo_resolucao_qs_detalhes = nil
      indicador.tempo_fechamento_qs_detalhes = nil
      indicador.tempo_concluido_testes_versao_liberada_detalhes = nil
      indicador.qtd_retorno_testes_qs = nil

      # Campos de controle/status
      indicador.tarefa_complementar = nil
      indicador.equipe_responsavel_atual = nil
      indicador.tarefa_fechada_sem_testes = nil
      indicador.etapa_atual = nil
      indicador.etapa_atual_agrupado_retorno_testes = nil
      indicador.etapa_atual_eh_retorno_testes = nil
      indicador.data_etapa_atual = nil
      indicador.motivo_situacao_desconhecida = nil
    end
    # Método para atualizar as tags das tarefas com a situação atual
    def self.atualizar_tags_etapa_atual(tarefas_devel, tarefas_qs, etapa_atual)
      begin
        Rails.logger.info ">>> Atualizando tags das tarefas com situação atual: #{etapa_atual}"

        # Criar a nova tag baseada na situação atual, exceto para VERSAO_LIBERADA
        nova_tag = if etapa_atual == SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA
            nil
          else
            # Adicionar sufixo _APTAS se for ESTOQUE_DEVEL e estiver na sprint "Aptas para desenvolvimento"
            if etapa_atual == SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_DEVEL &&
               !tarefas_devel.empty? &&
               tarefas_devel.last.fixed_version&.name == SkyRedminePlugin::Constants::Sprints::APTAS_PARA_DESENVOLVIMENTO
              "#{etapa_atual}_APTAS"
            else
              etapa_atual
            end
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

        # Obter lista atual de tags da tarefa
        tags_atuais = tarefa.tag_list.dup

        Rails.logger.info ">>> Validando a necessidade de atualizar tag da tarefa #{tarefa.id} para #{nova_tag ? nova_tag : " remover tag de EXX_ "} - tags atuais: #{tags_atuais.join(", ")}"

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
    def self.determinar_etapa_atual(indicador, tarefas_relacionadas, tarefas_devel, tarefas_qs, ciclos_devel, ciclos_qs)
      Rails.logger.info ">>> Determinando situação atual da tarefa"
      #Rails.logger.info ">>> Ciclos DEVEL.size: #{ciclos_devel ? ciclos_devel.size : 0}"
      #Rails.logger.info ">>> Ciclos QS.size: #{ciclos_qs ? ciclos_qs.size : 0}"
      #Rails.logger.info ">>> Tarefas DEVEL.last: #{tarefas_devel ? tarefas_devel.last.to_json : ""}"
      #Rails.logger.info ">>> Tarefas QS.last: #{tarefas_qs ? tarefas_qs.last.to_json : ""}"
      #Rails.logger.info ">>> Tarefas relacionadas.last: #{tarefas_relacionadas ? tarefas_relacionadas.last.to_json : ""}"
      #Rails.logger.info ">>> Indicador: #{indicador.to_json}"

      # Primeiro verificar se é uma situação DESCONHECIDA
      resultado_desconhecida = verificar_situacao_desconhecida(tarefas_relacionadas, tarefas_devel, tarefas_qs, ciclos_devel, ciclos_qs)
      if resultado_desconhecida[:situacao]
        # Atualizar o motivo no indicador
        indicador.motivo_situacao_desconhecida = resultado_desconhecida[:motivo]
        return resultado_desconhecida[:situacao]
      end

      # Verificar se a última tarefa está nas situações INTERROMPIDA
      situacao_especial = verificar_situacao_interrompida(tarefas_relacionadas)
      return situacao_especial if situacao_especial

      # Verificar se a última tarefa está nas situações CANCELADA
      situacao_especial = verificar_situacao_cancelada(indicador, tarefas_devel)
      if situacao_especial
        indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA
        return situacao_especial
      end

      # Verificar se é uma tarefa que não necessita desenvolvimento
      situacao_sem_desenvolvimento = verificar_situacao_sem_desenvolvimento(indicador, tarefas_relacionadas, tarefas_devel, ciclos_devel)
      if situacao_sem_desenvolvimento
        indicador.equipe_responsavel_atual = SkyRedminePlugin::Constants::EquipeResponsavel::FECHADA
        return situacao_sem_desenvolvimento
      end

      ultima_tarefa = tarefas_relacionadas.last
      ultima_tarefa_devel = tarefas_devel.last

      # Se a última tarefa DEVEL está com situação FECHADA, a versão foi liberada
      #if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA
      #  return SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA
      #end

      # Verificar se é uma tarefa que não necessita de QS
      if ultima_tarefa_devel.tracker.name == SkyRedminePlugin::Constants::Trackers::CONVERSAO ||
         ultima_tarefa_devel.teste_qs == SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE ||
         (tarefas_qs.any? && tarefas_qs.last.status.name == SkyRedminePlugin::Constants::IssueStatus::CANCELADA)
        Rails.logger.info ">>> Tarefa não necessita de QS"
        # Verificar se é um retorno de testes que já passou pelo QS anteriormente
        if ultima_tarefa_devel.tracker.name == SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES &&
           tarefas_qs.any?
          case ultima_tarefa_devel.status.name
          when SkyRedminePlugin::Constants::IssueStatus::NOVA
            indicador.data_etapa_atual = ultima_tarefa_devel.created_on
            return SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_DEVEL_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
            indicador.data_etapa_atual = ultima_tarefa_devel.data_em_andamento
            return SkyRedminePlugin::Constants::EtapaAtual::EM_ANDAMENTO_DEVEL_RETORNO_TESTES
          when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
            if ultima_tarefa_devel.versao_estavel.present?
              indicador.data_etapa_atual = SkyRedminePlugin::TarefasRelacionadas::obter_data_definicao_campo_personalizado(ultima_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::VERSAO_ESTAVEL, ultima_tarefa_devel.versao_estavel)
              return SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA_FALTA_FECHAR
            else
              indicador.data_etapa_atual = ultima_tarefa_devel.data_resolvida
              return SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_VERSAO_RETORNO_TESTES
            end
          when SkyRedminePlugin::Constants::IssueStatus::FECHADA
            indicador.data_etapa_atual = ultima_tarefa_devel.data_fechada
            return SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA
          end
        else
          # Caso ainda não tenha sido encaminhado para QS
          case ultima_tarefa_devel.status.name
          when SkyRedminePlugin::Constants::IssueStatus::NOVA
            indicador.data_etapa_atual = ultima_tarefa_devel.created_on
            return SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_DEVEL
          when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
            indicador.data_etapa_atual = ultima_tarefa_devel.data_em_andamento
            return SkyRedminePlugin::Constants::EtapaAtual::EM_ANDAMENTO_DEVEL
          when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
            if ultima_tarefa_devel.versao_estavel.present?
              indicador.data_etapa_atual = SkyRedminePlugin::TarefasRelacionadas::obter_data_definicao_campo_personalizado(ultima_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::VERSAO_ESTAVEL, ultima_tarefa_devel.versao_estavel)
              return SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA_FALTA_FECHAR
            else
              indicador.data_etapa_atual = ultima_tarefa_devel.data_resolvida
              return SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_VERSAO
            end
          when SkyRedminePlugin::Constants::IssueStatus::FECHADA
            indicador.data_etapa_atual = ultima_tarefa_devel.data_fechada
            return SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA
          end
        end
      end

      # Verificar se está no primeiro ciclo com teste no desenvolvimento
      if ciclos_devel.size == 1 && ultima_tarefa_devel.teste_no_desenvolvimento != SkyRedminePlugin::Constants::CustomFieldsValues::NAO_NECESSITA_TESTE
        Rails.logger.info ">>> Tarefa está no primeiro ciclo com teste no desenvolvimento"
        # Adicionar verificação se já existe tarefa de QS
        ja_tem_tarefa_qs = !tarefas_qs.empty?

        # Se já tem tarefa QS, ignorar o teste no desenvolvimento
        if !ja_tem_tarefa_qs && ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
          if (ultima_tarefa_devel.teste_no_desenvolvimento == SkyRedminePlugin::Constants::CustomFieldsValues::NAO_TESTADA) ||
             (ultima_tarefa_devel.teste_no_desenvolvimento == "")
            indicador.data_etapa_atual = ultima_tarefa_devel.data_resolvida
            return SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_TESTES_DEVEL
          elsif ultima_tarefa_devel.teste_no_desenvolvimento == SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_NOK
            indicador.data_etapa_atual = SkyRedminePlugin::TarefasRelacionadas::obter_data_definicao_campo_personalizado(ultima_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::TESTE_NO_DESENVOLVIMENTO, SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_NOK)
            return SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL
          elsif ultima_tarefa_devel.teste_no_desenvolvimento == SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_OK
            indicador.data_etapa_atual = SkyRedminePlugin::TarefasRelacionadas::obter_data_definicao_campo_personalizado(ultima_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::TESTE_NO_DESENVOLVIMENTO, SkyRedminePlugin::Constants::CustomFieldsValues::TESTE_OK)
            return SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_ENCAMINHAR_QS
          end
        end
      end

      # Verificar situações baseadas na última tarefa
      Rails.logger.info ">>> Verificando situações baseadas na última tarefa"
      # Usar o indicador já calculado para determinar se é um retorno do QS
      is_retorno_do_qs = indicador.qtd_retorno_testes_qs > 0

      case ultima_tarefa.equipe_responsavel
      when SkyRedminePlugin::Constants::EquipeResponsavel::DEVEL
        case ultima_tarefa.status.name
        when SkyRedminePlugin::Constants::IssueStatus::NOVA
          indicador.data_etapa_atual = ultima_tarefa.created_on
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_DEVEL_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_DEVEL
        when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
          indicador.data_etapa_atual = ultima_tarefa.data_em_andamento
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::EtapaAtual::EM_ANDAMENTO_DEVEL_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::EtapaAtual::EM_ANDAMENTO_DEVEL
        when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
          indicador.data_etapa_atual = ultima_tarefa.data_resolvida
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_ENCAMINHAR_QS
        when SkyRedminePlugin::Constants::IssueStatus::FECHADA
          indicador.data_etapa_atual = ultima_tarefa.data_fechada
          return SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA
        end
      when SkyRedminePlugin::Constants::EquipeResponsavel::QS
        case ultima_tarefa.status.name
        when SkyRedminePlugin::Constants::IssueStatus::NOVA
          indicador.data_etapa_atual = ultima_tarefa.created_on
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_QS_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::EtapaAtual::ESTOQUE_QS
        when SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO
          indicador.data_etapa_atual = ultima_tarefa.data_em_andamento
          return is_retorno_do_qs ?
                   SkyRedminePlugin::Constants::EtapaAtual::EM_ANDAMENTO_QS_RETORNO_TESTES :
                   SkyRedminePlugin::Constants::EtapaAtual::EM_ANDAMENTO_QS
        when SkyRedminePlugin::Constants::IssueStatus::TESTE_OK
          if ultima_tarefa_devel.versao_estavel.present?
            indicador.data_etapa_atual = SkyRedminePlugin::TarefasRelacionadas::obter_data_definicao_campo_personalizado(ultima_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::VERSAO_ESTAVEL, ultima_tarefa_devel.versao_estavel)
            return SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA_FALTA_FECHAR
          else
            indicador.data_etapa_atual = ultima_tarefa.data_resolvida
            return is_retorno_do_qs ?
                     SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_VERSAO_RETORNO_TESTES :
                     SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_VERSAO
          end
        when SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK
          indicador.data_etapa_atual = ultima_tarefa.data_resolvida
          return SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_ENCAMINHAR_RETORNO_TESTES
        when SkyRedminePlugin::Constants::IssueStatus::TESTE_OK_FECHADA
          case ultima_tarefa_devel.status.name
          when SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
            if ultima_tarefa_devel.versao_estavel.present?
              indicador.data_etapa_atual = SkyRedminePlugin::TarefasRelacionadas::obter_data_definicao_campo_personalizado(ultima_tarefa_devel, SkyRedminePlugin::Constants::CustomFields::VERSAO_ESTAVEL, ultima_tarefa_devel.versao_estavel)
              return SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA_FALTA_FECHAR
            else
              indicador.data_etapa_atual = ultima_tarefa.data_fechada
              return is_retorno_do_qs ?
                       SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_VERSAO_RETORNO_TESTES :
                       SkyRedminePlugin::Constants::EtapaAtual::AGUARDANDO_VERSAO
            end
          when SkyRedminePlugin::Constants::IssueStatus::FECHADA
            indicador.data_etapa_atual = ultima_tarefa_devel.data_fechada
            return SkyRedminePlugin::Constants::EtapaAtual::VERSAO_LIBERADA
          end
        end
      end

      Rails.logger.info ">>> Nenhuma situação identificada para a tarefa #{ultima_tarefa.id} - #{ultima_tarefa.status.name}, retornando DESCONHECIDA"
      # Se nenhuma situação foi identificada, retornar DESCONHECIDA
      SkyRedminePlugin::Constants::EtapaAtual::DESCONHECIDA
    end

    # Verifica se a última tarefa está nas situações INTERROMPIDA
    # Retorna a situação correspondente ou nil se não estiver em nenhuma dessas situações
    def self.verificar_situacao_interrompida(tarefas_relacionadas)
      Rails.logger.info ">>> Verificando situação interrompida para a tarefa #{tarefas_relacionadas.last.id} - #{tarefas_relacionadas.last.status.name}"
      return nil if tarefas_relacionadas.empty?

      ultima_tarefa = tarefas_relacionadas.last

      case ultima_tarefa.status.name
      when SkyRedminePlugin::Constants::IssueStatus::INTERROMPIDA
        return SkyRedminePlugin::Constants::EtapaAtual::INTERROMPIDA
      when SkyRedminePlugin::Constants::IssueStatus::INTERROMPIDA_ANALISE
        return SkyRedminePlugin::Constants::EtapaAtual::INTERROMPIDA_ANALISE
      end

      nil
    end

    # Verifica se a última tarefa está nas situações CANCELADA
    # Retorna a situação correspondente ou nil se não estiver em nenhuma dessas situações
    def self.verificar_situacao_cancelada(indicador, tarefas_relacionadas)
      Rails.logger.info ">>> Verificando situação cancelada para a tarefa #{tarefas_relacionadas.last.id} - #{tarefas_relacionadas.last.status.name}"
      return nil if tarefas_relacionadas.empty?

      ultima_tarefa = tarefas_relacionadas.last

      case ultima_tarefa.status.name
      when SkyRedminePlugin::Constants::IssueStatus::CANCELADA
        indicador.data_etapa_atual = ultima_tarefa.data_fechada
        return SkyRedminePlugin::Constants::EtapaAtual::CANCELADA
      end

      nil
    end

    # Verifica se a tarefa não necessita desenvolvimento
    # Retorna a situação correspondente ou nil se não for o caso
    def self.verificar_situacao_sem_desenvolvimento(indicador, tarefas_relacionadas, tarefas_devel, ciclos_devel)
      Rails.logger.info ">>> Verificando situação sem desenvolvimento para a tarefa #{tarefas_relacionadas.last.id} - #{tarefas_relacionadas.last.status.name}"
      return nil if tarefas_relacionadas.empty? || tarefas_devel.empty?

      # Verificar se está no primeiro ciclo de desenvolvimento
      return nil if ciclos_devel.size > 1

      ultima_tarefa_devel = tarefas_devel.last

      # Verificar se a última tarefa DEVEL está com situação FECHADA_SEM_DESENVOLVIMENTO
      if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA_SEM_DESENVOLVIMENTO
        indicador.data_etapa_atual = ultima_tarefa_devel.data_fechada
        return SkyRedminePlugin::Constants::EtapaAtual::FECHADA_SEM_DESENVOLVIMENTO
      end

      nil
    end

    # Método para verificar se a situação é DESCONHECIDA
    def self.verificar_situacao_desconhecida(tarefas_relacionadas, tarefas_devel, tarefas_qs, ciclos_devel, ciclos_qs)
      Rails.logger.info ">>> Verificando situação desconhecida para a tarefa #{tarefas_relacionadas.last.id}"

      # Estrutura para retornar situação e motivo
      resultado = { situacao: nil, motivo: nil }

      ultima_tarefa_ciclo = tarefas_relacionadas.last
      ultima_tarefa_devel = tarefas_devel.last
      ultima_tarefa_qs = tarefas_qs.last

      # Regra 1: Verificar se a última tarefa do último ciclo DEVEL é FECHADA_CONTINUA_RETORNO_TESTES
      if ultima_tarefa_devel.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA_CONTINUA_RETORNO_TESTES
        resultado[:situacao] = SkyRedminePlugin::Constants::EtapaAtual::DESCONHECIDA
        resultado[:motivo] = "Tarefa #{ultima_tarefa_devel.id} está com situação FECHADA_CONTINUA_RETORNO_TESTES mas não existe tarefa de continuidade RETORNO_TESTES"
        return resultado
      end

      # Regra 2: Verificar se a última tarefa de todo o ciclo é TESTE_NOK_FECHADA
      if ultima_tarefa_ciclo.equipe_responsavel == SkyRedminePlugin::Constants::EquipeResponsavel::QS &&
         ultima_tarefa_ciclo.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA
        resultado[:situacao] = SkyRedminePlugin::Constants::EtapaAtual::DESCONHECIDA
        resultado[:motivo] = "Tarefa #{ultima_tarefa_ciclo.id} está com situação TESTE_NOK_FECHADA mas não existe tarefa de continuidade RETORNO_TESTES"
        return resultado
      end

      # Regra 3: Verificar se há algum ciclo de continuidade onde as tarefas DEVEL não são do tipo RETORNO_TESTES
      if ciclos_devel.size > 1
        # Verificar todos os ciclos de continuidade (após o primeiro ciclo)
        ciclos_devel[1..-1].each_with_index do |ciclo, index|
          ciclo.each do |tarefa|
            if tarefa.tracker.name != SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES
              resultado[:situacao] = SkyRedminePlugin::Constants::EtapaAtual::DESCONHECIDA
              resultado[:motivo] = "Tarefa #{tarefa.id} no ciclo de continuidade #{index + 2} não é do tipo RETORNO_TESTES"
              return resultado
            end
          end
        end
      end

      # Regra 4: Verificar que nao pode ter FECHADA_SEM_DESENVOLVIMENTO apartir do segundo ciclo de desenvolvimento
      if ciclos_devel.size > 1
        if ultima_tarefa_ciclo.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA_SEM_DESENVOLVIMENTO
          resultado[:situacao] = SkyRedminePlugin::Constants::EtapaAtual::DESCONHECIDA
          resultado[:motivo] = "Tarefa #{ultima_tarefa_ciclo.id} está com situação FECHADA_SEM_DESENVOLVIMENTO porém houverem tarefas anteriores de devel com desenvolvimento."
          return resultado
        end
      end

      # Regra 5: Verificar se há tarefa de continuidade depois de uma tarefa CONTINUA_PROXIMA_SPRINT
      if ultima_tarefa_ciclo.status.name == SkyRedminePlugin::Constants::IssueStatus::CONTINUA_PROXIMA_SPRINT
        resultado[:situacao] = SkyRedminePlugin::Constants::EtapaAtual::DESCONHECIDA
        resultado[:motivo] = "Tarefa #{ultima_tarefa_ciclo.id} está com situação CONTINUA_PROXIMA_SPRINT porém não existe tarefa de continuidade."
        return resultado
      end

      # Regra 6: Verificar se há alguma tarefa do QS com status FECHADA ou RESOLVIDA
      # Regra 6: Verificar se há alguma tarefa do QS com status FECHADA ou RESOLVIDA
      tarefas_qs_invalidas = tarefas_qs.select { |tarefa|
        tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::FECHADA ||
        tarefa.status.name == SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA
      }

      if tarefas_qs_invalidas.any?
        ids_e_status = tarefas_qs_invalidas.map { |t| "#{t.id} com situação #{t.status.name}" }.join(", ")
        resultado[:situacao] = SkyRedminePlugin::Constants::EtapaAtual::DESCONHECIDA
        resultado[:motivo] = "Tarefa do QS #{ids_e_status} o que não é esperado. Tarefas do QS devem usar Teste OK ou NOK. "
        return resultado
      end

      # Se não atende nenhuma condição de DESCONHECIDA, retorna nil para continuar a verificação
      resultado
    end
  end

  def self.obter_etapa_atual_agrupado_retorno_testes(etapa)
    if etapa.to_s.start_with?("E07_AGUARDA_ENCAMINHAR_RT")
      return etapa
    else
      return etapa.to_s.gsub(/_RT$/, "")
    end
  end
end
