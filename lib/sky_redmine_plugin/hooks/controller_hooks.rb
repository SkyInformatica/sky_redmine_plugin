module SkyRedminePlugin
  module Hooks
    class ControllerHooks < Redmine::Hook::Listener
      include CriarTarefasHelper

      def controller_issues_edit_after_save(context = {})
        issue = context[:issue]

        # Atualiza a data de início, se necessário
        atualizar_data_inicio(issue)

        # Atualiza a tag da tarefa com base no status
        atualizar_tag(issue)
      end

      def controller_additionals_change_status_after_save(context = {})
        controller_issues_edit_after_save(context)
      end

      private

      # Método para atualizar a data de início da tarefa
      def atualizar_data_inicio(issue)
        if issue.status.name == SkyRedminePlugin::Constants::IssueStatus::EM_ANDAMENTO && issue.start_date.nil?
          issue.start_date = Date.today
          issue.save(validate: false)
        end
      end

      # Método para atualizar a tag da tarefa com base no status
      def atualizar_tag(issue)
        # Verifica se o status é 'Teste NOK' ou 'Teste OK'
        nova_tag_sufixo = case issue.status.name
          when SkyRedminePlugin::Constants::IssueStatus::TESTE_NOK
            SkyRedminePlugin::Constants::Tags::REVER
          when SkyRedminePlugin::Constants::IssueStatus::TESTE_OK
            SkyRedminePlugin::Constants::Tags::PRONTO
          else
            return # Se não for nenhum dos status, não faz nada
          end

        # Obtém a lista de sufixos automatizados
        sufixos_automatizados = SkyRedminePlugin::Constants::Tags::TODAS_TAGS_AUTOMATIZADAS

        # Inicializa a variável para armazenar o prefixo
        prefixo = nil

        # Procura por tags que terminem com os sufixos automatizados e obtém o prefixo
        issue.tag_list = issue.tag_list.reject do |tag|
          sufixo_encontrado = sufixos_automatizados.find { |sufixo| tag.end_with?(sufixo) }
          if sufixo_encontrado
            # Extrai o prefixo (parte antes do sufixo)
            prefixo = tag[0...-sufixo_encontrado.length]
            true # Remove a tag
          else
            false # Mantém a tag
          end
        end

        # Se não foi encontrado um prefixo
        if prefixo.nil?
          return # Neste caso, não adicionaremos uma nova tag
        end

        # Constrói a nova tag com o mesmo prefixo e o novo sufixo
        nova_tag = "#{prefixo}#{nova_tag_sufixo}"

        # Adiciona a nova tag ao issue
        issue.tag_list.add(nova_tag)

        # Salva o issue sem validações
        issue.save(validate: false)
      end
    end
  end
end
