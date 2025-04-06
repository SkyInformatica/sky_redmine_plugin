# lib/sky_redmine_plugin/constants.rb

module SkyRedminePlugin
  module Constants
    module IssueStatus
      EM_ANDAMENTO = "Em andamento"
      NOVA = "Nova"
      INTERROMPIDA = "Interrompida"
      CONTINUA_PROXIMA_SPRINT = "Continua proxima sprint"
      RESOLVIDA = "Resolvida"
      FECHADA = "Fechada"
      CANCELADA = "Cancelada"
      FECHADA_CONTINUA_RETORNO_TESTES = "Fechada - cont retorno testes"
      TESTE_OK = "Teste OK"
      TESTE_NOK = "Teste NOK"
      TESTE_OK_FECHADA = "Teste OK - Fechada"
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
      CONVERSAO = "Conversão"
      FUNCIONALIDADE = "Funcionalidade"
      TESTE = "Teste"
      TESTE_ID = 9
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
      URGENTE = "_URGENTE"
      PRIORIDADE = "_PRIORIDADE"
      TODAS_TAGS_AUTOMATIZADAS = [TESTAR, PRONTO, REVER, REUNIAO, RETESTAR]
    end

    module EquipeResponsavel
      FECHADA = "FECHADA"
      DEVEL = "DEVEL"
      QS = "QS"
    end
    
    module SituacaoAtual
      # Situações de desenvolvimento inicial
      ESTOQUE_DEVEL = "ESTOQUE_DEVEL"
      EM_ANDAMENTO_DEVEL = "EM_ANDAMENTO_DEVEL"
      AGUARDANDO_ENCAMINHAR_QS = "AGUARDANDO_ENCAMINHAR_QS"
      
      # Situações de QS inicial
      ESTOQUE_QS = "ESTOQUE_QS"
      EM_ANDAMENTO_QS = "EM_ANDAMENTO_QS"
      
      # Situações após aprovação de QS
      AGUARDANDO_VERSAO = "AGUARDANDO_VERSAO"
      VERSAO_LIBERADA = "VERSAO_LIBERADA"
      
      # Situações de retorno de testes
      AGUARDANDO_RETORNO_TESTES = "AGUARDANDO_RETORNO_TESTES"
      
      # Situações de desenvolvimento em retorno de testes
      ESTOQUE_DEVEL_RETORNO_TESTES = "ESTOQUE_DEVEL_RETORNO_TESTES"
      EM_ANDAMENTO_DEVEL_RETORNO_TESTES = "EM_ANDAMENTO_DEVEL_RETORNO_TESTES"
      AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES = "AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES"
      
      # Situações de QS em retorno de testes
      ESTOQUE_QS_RETORNO_TESTES = "ESTOQUE_QS_RETORNO_TESTES"
      EM_ANDAMENTO_QS_RETORNO_TESTES = "EM_ANDAMENTO_QS_RETORNO_TESTES"
      
      # Lista de todas as situações em ordem cronológica
      TODAS_SITUACOES = [
        ESTOQUE_DEVEL,
        EM_ANDAMENTO_DEVEL,
        AGUARDANDO_ENCAMINHAR_QS,
        ESTOQUE_QS,
        EM_ANDAMENTO_QS,
        AGUARDANDO_VERSAO,
        VERSAO_LIBERADA,
        AGUARDANDO_RETORNO_TESTES,
        ESTOQUE_DEVEL_RETORNO_TESTES,
        EM_ANDAMENTO_DEVEL_RETORNO_TESTES,
        AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES,
        ESTOQUE_QS_RETORNO_TESTES,
        EM_ANDAMENTO_QS_RETORNO_TESTES
      ]
    end
  end
end
