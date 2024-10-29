# lib/sky_redmine_plugin/constants.rb

module SkyRedminePlugin
  module Constants
    module IssueStatus
      EM_ANDAMENTO = "Em andamento"
      NOVA = "Nova"
      INTERROMPIDA = "Interrompida"
      CONTINUA_PROXIMA_SPRINT = "Continua proxima sprint"
      RESOLVIDA = "Resolvida"
      FECHADA_CONTINUA_RETORNO_TESTES = "Fechada - cont retorno testes"
      TESTE_NOK = "Teste NOK"
      TESTE_NOK_FECHADA = "Teste NOK - Fechada"
    end

    module Sprints
      APTAS_PARA_DESENVOLVIMENTO = "Aptas para desenvolvimento"
      TAREFAS_PARA_TESTAR = "Tarefas para testar"
    end
  end
end
