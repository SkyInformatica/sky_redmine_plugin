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
      TESTE_OK = "Teste OK"
      TESTE_NOK = "Teste NOK"
      TESTE_NOK_FECHADA = "Teste NOK - Fechada"
    end

    module Sprints
      APTAS_PARA_DESENVOLVIMENTO = "Aptas para desenvolvimento"
      TAREFAS_PARA_TESTAR = "Tarefas para testar"
    end

    module Projects
      NOTARIAL_QS = "Notarial - QS"
      REGISTRAL_QS = "Registral - QS"
      NOTAR = "Equipe Notar"
      PROTESTO = "Equipe Protesto"
      FINANCEIRO = "Equipe Financeiro"
      TED = "Equipe TED"
      CIVIL = "Equipe Civil"
      IMOVEIS = "Equipe Imóveis"
      QS_PROJECTS = [NOTARIAL_QS, REGISTRAL_QS]
      REGISTRAL_PROJECTS = [CIVIL, TED, IMOVEIS]
      NOTARIAL_PROJECTS = [NOTAR, PROTESTO, FINANCEIRO]
    end

    module Trackers
      RETORNO_TESTES = "Retorno de testes"
      DEFEITO = "Defeito"
      FUNCIONALIDADE = "Funcionalidade"
    end

    module CustomFields
      TESTE_QS = "Teste QS"
      SISTEMA = "Sistema"
      TESTE_NO_DESENVOLVIMENTO = "Teste no desenvolvimento"
      RESULTADO_TESTE_NOK = "Resultado Teste NOK"
    end

    module Tags
      TESTAR = "_TESTAR"
      PRONTO = "_PRONTO"
      REVER = "_REVER"
      REUNIAO = "_REUNIAO"
      RETESTAR = "_RETESTAR"
      TODAS_TAGS_AUTOMATIZADAS = [TESTAR, PRONTO, REVER, REUNIAO, RETESTAR]
    end
  end
end
