class RetornoTestesController < ApplicationController
  include CriarTarefasHelper
  before_action :inicializar
  before_action :find_issue, only: [:retorno_testes_devel, :retorno_testes_qs]
  before_action :find_issues, only: [:retorno_testes_lote]

  ORIGEM_RETORNO_TESTE_DEVEL = "DEVEL"
  ORIGEM_RETORNO_TESTE_QS = "QS"

  def retorno_testes_devel(is_batch_call = false, is_task_rake = false)
    Rails.logger.info ">>> retorno_testes_devel #{@issue.id} - is_batch_call #{is_batch_call} - is_task_rake #{is_task_rake}"
    @origem_retorno_teste = ORIGEM_RETORNO_TESTE_DEVEL

    # Check if the issue is not in QS projects and its status is "Resolvida"
    if (!SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(@issue.project.name)) && (@issue.status.name == SkyRedminePlugin::Constants::IssueStatus::RESOLVIDA)

      # Verificar se já existe uma cópia da tarefa de retorno de testes
      retorno_testes_issue = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_retorno_testes(@issue)

      # Se existir um retorno de testes
      if retorno_testes_issue
        # A tarefa de retorno de testes já foi encaminhada
        if !is_task_rake
          flash[:warning] = "O retorno de testes já foi encaminhado em  #{view_context.link_to "#{retorno_testes_issue.tracker.name} ##{retorno_testes_issue.id}", issue_path(retorno_testes_issue)} e está com status #{retorno_testes_issue.status.name}." unless is_batch_call
          @processed_issues << "[NOK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - o retorno de testes já foi encaminhado em  #{view_context.link_to "#{retorno_testes_issue.tracker.name} ##{retorno_testes_issue.id}", issue_path(retorno_testes_issue)} e está com status #{retorno_testes_issue.status.name}" if is_batch_call
          redirect_to issue_path(@issue) unless is_batch_call
        end
        return
      end

      # Verificar se já existe uma cópia da tarefa nos projetos QS
      copied_to_qs_issue = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_copiada_qs(@issue)

      tarefa_qs_removida = false
      # Se existir uma cópia e seu status for "Nova"
      if copied_to_qs_issue
        if copied_to_qs_issue.status.name == SkyRedminePlugin::Constants::IssueStatus::NOVA
          # Remover a cópia
          tarefa_qs_removida = true
          copied_to_qs_issue.destroy
          # Remover a relação de cópia
          IssueRelation.where(issue_from_id: @issue.id, issue_to_id: copied_to_qs_issue.id, relation_type: "copied_to").destroy_all
        else
          # A tarefa já foi encaminhada para QS e não está como "Nova"
          if !is_task_rake
            flash[:warning] = "Os testes já foram iniciados pelo QS em  #{view_context.link_to "#{copied_to_qs_issue.tracker.name} ##{copied_to_qs_issue.id}", issue_path(copied_to_qs_issue)} e está com status #{copied_to_qs_issue.status.name}.<br>Neste caso não possivel criar um retorno de testes para a tarefa de desenvolvimento.<br>Ou crie uma nova tarefa de Defeito ou crie um retorno de testes apartir da tarefa do QS.".html_safe unless is_batch_call
            @processed_issues << "[NOK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - tarefa já foi encaminhada para o QS em  #{view_context.link_to "#{copied_to_qs_issue.tracker.name} ##{copied_to_qs_issue.id}", issue_path(copied_to_qs_issue)} e está com status #{copied_to_qs_issue.status.name}" if is_batch_call
            redirect_to issue_path(@issue) unless is_batch_call
          end
          return
        end
      end

      new_issue = criar_nova_tarefa(@issue.project, nil, false)
      @issue.init_journal(User.current, "[SkyRedminePlugin] Encaminhado retorno de testes do desenvolvimento")
      if fechada_cont_retorno_testes_status = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::FECHADA_CONTINUA_RETORNO_TESTES)
        @issue.status = fechada_cont_retorno_testes_status
      end
      if custom_field = IssueCustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::TESTE_NO_DESENVOLVIMENTO)
        @issue.custom_field_values = { custom_field.id => SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK }
      end

      #limpar tags da tarefa
      @issue.tag_list = []
      @issue.save

      SkyRedminePlugin::Indicadores.processar_indicadores(@issue)

      if !is_task_rake
        flash[:notice] = "Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada no projeto #{view_context.link_to new_issue.project.name, project_path(new_issue.project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)} com tempo estimado de 1.0h<br>" \
        "Ajuste a descrição da tarefa com o resultado dos testes e orientacoes o que deve ser corrigido #{view_context.link_to "clicando aqui", edit_issue_path(new_issue)}".html_safe unless is_batch_call
        flash[:info] = "Essa tarefa teve seu status ajustado para <strong><em>#{@issue.status.name}</em></strong>" unless is_batch_call
        if tarefa_qs_removida
          flash[:info] = flash[:info] + "<br>A tarefa já havia sido encaminhada para o QS e ainda estava com status Nova, portanto foi removida do backlog do QS".html_safe unless is_batch_call
        end
        @processed_issues << "[OK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - retorno de testes criado em #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} " if is_batch_call
      end
    else
      if !is_task_rake
        flash[:warning] = "O retorno de testes só pode ser criado para tarefas de desenvolvimento com status 'Resolvida'." unless is_batch_call
      end
    end

    if !is_batch_call && !is_task_rake
      redirect_to issue_path(@issue)
    end
  end

  def retorno_testes_qs(is_batch_call = false, is_task_rake = false)
    Rails.logger.info ">>> retorno_testes_qs #{@issue.id} - is_batch_call #{is_batch_call} - is_task_rake #{is_task_rake}"
    @origem_retorno_teste = ORIGEM_RETORNO_TESTE_QS
    usar_sprint_atual = params[:usar_sprint_atual].present?

    # Verificar se a tarefa pertence aos projetos permitidos e se o status é "Teste NOK"
    if (SkyRedminePlugin::Constants::Projects::QS_PROJECTS.include?(@issue.project.name) && (@issue.status.name == SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK))

      # Verificar se já existe uma cópia da tarefa de retorno de testes
      retorno_testes_issue = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_retorno_testes(@issue)

      # Se existir um retorno de testes
      if retorno_testes_issue
        # A tarefa de retorno de testes já foi encaminhada
        if !is_task_rake
          flash[:warning] = "O retorno de testes já foi encaminhado em  #{view_context.link_to "#{retorno_testes_issue.tracker.name} ##{retorno_testes_issue.id}", issue_path(retorno_testes_issue)} e está com status #{retorno_testes_issue.status.name}." unless is_batch_call
          @processed_issues << "[NOK] #{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - o retorno de testes já foi encaminhado em  #{view_context.link_to "#{retorno_testes_issue.tracker.name} ##{retorno_testes_issue.id}", issue_path(retorno_testes_issue)} e está com status #{retorno_testes_issue.status.name}" if is_batch_call
          redirect_to issue_path(@issue) unless is_batch_call
        end
        return
      end

      # localizar a tarefa de origem do desenvolvimento
      devel_issue = SkyRedminePlugin::TarefasRelacionadas.localizar_tarefa_origem_desenvolvimento(@issue)

      if devel_issue
        # Criar nova tarefa com a categoria da tarefa de desenvolvimento
        new_issue = criar_nova_tarefa(devel_issue.project, devel_issue.category_id, usar_sprint_atual)

        # atualizar o status da tarefa de devel para fechada continua retorno de testes e o campo Teste QS para Teste NOK - Fechada
        if fechada_continua_retorno_testes_status = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::FECHADA_CONTINUA_RETORNO_TESTES)
          devel_issue.init_journal(User.current, "[SkyRedminePlugin] Encaminhado retorno de testes do QS")
          devel_issue.status = fechada_continua_retorno_testes_status
          if custom_field = IssueCustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::TESTE_QS)
            devel_issue.custom_field_values = { custom_field.id => SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA }
          end
          devel_issue.save
        end

        @issue.init_journal(User.current, "[SkyRedminePlugin] Encaminhado retorno de testes do QS")
        # ataulizar o status da tarefa de QS para Teste NOK - Fechada
        if testenok_status = IssueStatus.find_by(name: SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK_FECHADA)
          @issue.status = testenok_status
        end

        #limpar tags da tarefa de QS
        @issue.tag_list = []
        @issue.save

        SkyRedminePlugin::Indicadores.processar_indicadores(@issue)

        if !is_task_rake
          flash[:notice] = "Tarefa #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} foi criada no projeto #{view_context.link_to devel_issue.project.name, project_path(devel_issue.project)} na sprint #{view_context.link_to new_issue.fixed_version.name, version_path(new_issue.fixed_version)} com tempo estimado de 1.0h" unless is_batch_call
          flash[:info] = "Tarefa do desenvolvimento #{view_context.link_to "#{devel_issue.tracker.name} ##{devel_issue.id}", issue_path(devel_issue)} foi ajustada o status para <strong><em>#{devel_issue.status.name}</em></strong><br>" \
          "Essa tarefa de testes foi fechada e ajustado seu status para <strong><em>#{@issue.status.name}</em></strong>".html_safe unless is_batch_call

          @processed_issues << "#{view_context.link_to "#{@issue.tracker.name} ##{@issue.id}", issue_path(@issue)} - #{@issue.subject} - retorno de testes criado em #{view_context.link_to "#{new_issue.tracker.name} ##{new_issue.id}", issue_path(new_issue)} " if is_batch_call
        end
      else
        if !is_task_rake
          flash[:warning] = "Não foi possível encontrar o projeto de origem (desenvolvimento) para criar o retorno de testes." unless is_batch_call
        end
      end
    else
      if !is_task_rake
        flash[:warning] = "O retorno de testes só pode ser criado para tarefas do QS com status 'Teste NOK'." unless is_batch_call
      end
    end

    if !is_batch_call && !is_task_rake
      redirect_to issue_path(@issue)
    end
  end

  def retorno_testes_lote
    Rails.logger.info ">>> retorno_testes_lote"

    @origem_retorno_teste = params[:origem] # Recebe 'QS' ou 'DEVEL' como parâmetro
    @issue_ids = params[:ids]
    Rails.logger.info ">>> #{@issue_ids.to_json}"

    # Itera sobre cada issue
    # O metodo find_issues (Redmine) define o @issues quando eh processamento em lote
    @issues.each do |issue|
      # os metodos retorno_testes_qs e retorno_testes_devel usam @issue para referencia a tarefa que deve ser copiada
      # o @issue eh definido pelo find_issue (Redmine) quando eh um processamento individual de uma tarefa
      @issue = issue
      if (@origem_retorno_teste == ORIGEM_RETORNO_TESTE_QS)
        retorno_testes_qs(true)
      elsif (@origem_retorno_teste == ORIGEM_RETORNO_TESTE_DEVEL)
        retorno_testes_devel(true)
      end
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def inicializar
    @processed_issues = []
  end

  def criar_nova_tarefa(project, category_id = nil, usar_sprint_atual = false)
    Rails.logger.info ">>> criar_nova_tarefa"
    new_issue = @issue.copy(project_id: project.id)

    # Preservar o campo versao teste apenas para retornos do QS
    versao_teste = nil
    if @origem_retorno_teste == ORIGEM_RETORNO_TESTE_QS
      if custom_field = IssueCustomField.find_by(name: "Versão teste")
        versao_teste = new_issue.custom_field_value(custom_field.id)
      end
    end

    limpar_campos_nova_tarefa(new_issue, CriarTarefasHelper::TipoCriarNovaTarefa::RETORNO_TESTES)

    # Restaurar o campo versao teste após a limpeza
    if @origem_retorno_teste == ORIGEM_RETORNO_TESTE_QS && versao_teste && custom_field
      new_issue.custom_field_values = { custom_field.id => versao_teste }
    end

    new_issue.tracker = Tracker.find_by_name(SkyRedminePlugin::Constants::Trackers::RETORNO_TESTES)
    new_issue.tag_list = []
    new_issue.estimated_hours = 1

    # Atribuir a categoria, se fornecida
    new_issue.category_id = category_id if category_id

    # Concatenando o valor do campo "Resultado Teste NOK" à descrição
    if (@origem_retorno_teste == ORIGEM_RETORNO_TESTE_QS)
      if custom_field = IssueCustomField.find_by(name: SkyRedminePlugin::Constants::CustomFields::RESULTADO_TESTE_NOK)
        resultado_teste_nok_value = @issue.custom_field_value(custom_field.id)
        if resultado_teste_nok_value && !resultado_teste_nok_value.empty?
          new_issue.description = "*[RETORNO DE TESTES DO QS]*\n\n#{resultado_teste_nok_value}\n\n---\n\n#{new_issue.description}"
        end
      end
    elsif (@origem_retorno_teste == ORIGEM_RETORNO_TESTE_DEVEL)
      new_issue.description = "*[RETORNO DE TESTES DO DESENVOLVIMENTO]*\n\n\n\n---\n\n#{new_issue.description}"
    end

    new_issue.subject = definir_titulo_tarefa_incrementando_numero_copia(@issue.subject)

    if usar_sprint_atual
      sprint = encontrar_sprint_atual(project)
    else
      sprint = Version.find_by(name: SkyRedminePlugin::Constants::Sprints::APTAS_PARA_DESENVOLVIMENTO, project_id: project.id)
    end

    if sprint.nil?
      sprint = Version.new(name: SkyRedminePlugin::Constants::Sprints::APTAS_PARA_DESENVOLVIMENTO, project_id: project.id)
      sprint.save
    end
    new_issue.fixed_version = sprint

    new_issue.save
    new_issue
  end
end
