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
      INTERROMPIDA_ANALISE = "Interrompida para analise"
      FECHADA_SEM_DESENVOLVIMENTO = "Fechada - sem desenvolvimento"
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
      TODOS_PROJETOS = [
        NOTARIAL_QS,
        REGISTRAL_QS,
        NOTAR,
        PROTESTO,
        FINANCEIRO,
        TED,
        CIVIL,
        IMOVEIS,
      ]
    end

    module Trackers
      RETORNO_TESTES = "Retorno de testes"
      DEFEITO = "Defeito"
      CONVERSAO = "Conversão"
      FUNCIONALIDADE = "Funcionalidade"
      TESTE = "Teste"
      TESTE_ID = 9
      SUPORTE = "Suporte"
      PLANEJAMENTO = "Planejamento"
      DOCUMENTACAO = "Documentação"
      VIDEOS = "Videos"
    end

    module CustomFields
      TESTE_QS = "Teste QS"
      SISTEMA = "Sistema"
      TESTE_NO_DESENVOLVIMENTO = "Teste no desenvolvimento"
      RESULTADO_TESTE_NOK = "Resultado Teste NOK"
      VERSAO_TESTE = "Versão teste"
      VERSAO_ESTAVEL = "Versão estável"
      CLIENTE = "Cliente"
      CLIENTE_NOME = "Cliente Nome"
      CLIENTE_CIDADE = "Cliente Cidade"
      QUANTIDADE_SKYNET = "Quantidade Sky.NET"
      TAREFA_NAO_PLANEJADA_IMEDIATA = "Tarefa não planejada IMEDIATA"
      TAREFA_ANTECIPADA_SPRINT = "Tarefa antecipada na sprint"
      ORIGEM = "Origem"
      SKYNET = "Sky.NET"
      CATEGORIA_TESTE_NOK = "Categoria Teste NOK"
    end

    module CustomFieldsValues
      NAO_NECESSITA_TESTE = "Não necessita teste"
      NAO_TESTADA = "Não testada"
      TESTE_OK = "Teste OK"
      TESTE_NOK = "Teste NOK"
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

    module TarefasComplementares
      TAREFA_NAO_PLANEJADA = "Tarefas nao planejadas"
    end

    module FluxoDasTarefas
      FLUXO_IDEAL = "FLUXO_IDEAL"
      FLUXO_RETORNO_TESTES = "FLUXO_RETORNO_TESTES"
      FLUXO_SEM_QS = "FLUXO_SEM_QS"
    end

    module EtapaAtual
      # Situação desconhecida
      DESCONHECIDA = "E99_DESCONHECIDA"
      INTERROMPIDA = "E99_INTERROMPIDA"
      INTERROMPIDA_ANALISE = "E99_INTERROMPIDA_ANALISE"
      CANCELADA = "E08_CANCELADA"
      FECHADA_SEM_DESENVOLVIMENTO = "E08_FECHADA_SEM_DESENVOLVIMENTO"

      # Situações de desenvolvimento inicial
      ESTOQUE_DEVEL = "E01_ESTOQUE_DEVEL"
      EM_ANDAMENTO_DEVEL = "E02_EM_ANDAMENTO_DEVEL"
      AGUARDANDO_TESTES_DEVEL = "E03_AGUARDA_TESTES_DEVEL"
      AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL = "E03_AGUARDA_ENCAMINHAR_RT_DEVEL"
      AGUARDANDO_ENCAMINHAR_QS = "E04_AGUARDA_ENCAMINHAR_QS"

      # Situações de QS inicial
      ESTOQUE_QS = "E05_ESTOQUE_QS"
      EM_ANDAMENTO_QS = "E06_EM_ANDAMENTO_QS"

      # Situações após aprovação de QS
      AGUARDANDO_VERSAO = "E07_AGUARDA_VERSAO"
      VERSAO_LIBERADA = "E08_VERSAO_LIBERADA"
      VERSAO_LIBERADA_FALTA_FECHAR = "E08_VERSAO_LIBERADA_FALTA_FECHAR"

      # Situações de retorno de testes
      AGUARDANDO_ENCAMINHAR_RETORNO_TESTES = "E07_AGUARDA_ENCAMINHAR_RT"

      # Situações de desenvolvimento em retorno de testes
      ESTOQUE_DEVEL_RETORNO_TESTES = "E01_ESTOQUE_DEVEL_RT"
      EM_ANDAMENTO_DEVEL_RETORNO_TESTES = "E02_EM_ANDAMENTO_DEVEL_RT"
      AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES = "E04_AGUARDA_ENCAMINHAR_QS_RT"

      # Situações de QS em retorno de testes
      ESTOQUE_QS_RETORNO_TESTES = "E05_ESTOQUE_QS_RT"
      EM_ANDAMENTO_QS_RETORNO_TESTES = "E06_EM_ANDAMENTO_QS_RT"
      AGUARDANDO_VERSAO_RETORNO_TESTES = "E07_AGUARDA_VERSAO_RT"

      TODAS_ETAPAS = [
        DESCONHECIDA,
        INTERROMPIDA,
        INTERROMPIDA_ANALISE,
        CANCELADA,
        FECHADA_SEM_DESENVOLVIMENTO,
        ESTOQUE_DEVEL,
        EM_ANDAMENTO_DEVEL,
        AGUARDANDO_TESTES_DEVEL,
        AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL,
        AGUARDANDO_ENCAMINHAR_QS,
        ESTOQUE_QS,
        EM_ANDAMENTO_QS,
        AGUARDANDO_VERSAO,
        VERSAO_LIBERADA,
        VERSAO_LIBERADA_FALTA_FECHAR,
        AGUARDANDO_ENCAMINHAR_RETORNO_TESTES,
        ESTOQUE_DEVEL_RETORNO_TESTES,
        EM_ANDAMENTO_DEVEL_RETORNO_TESTES,
        AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES,
        ESTOQUE_QS_RETORNO_TESTES,
        EM_ANDAMENTO_QS_RETORNO_TESTES,
        AGUARDANDO_VERSAO_RETORNO_TESTES,
      ]

      # Fluxo de situações das tarefas que não passam por QS
      FLUXO_SEM_QS = [
        ESTOQUE_DEVEL,
        EM_ANDAMENTO_DEVEL,
        AGUARDANDO_VERSAO,
        VERSAO_LIBERADA,
      ]

      # Fluxo de situações das tarefas que não passam por QS
      FLUXO_SEM_QS_FECHADA_SEM_DESENVOLVIMENTO = [
        ESTOQUE_DEVEL,
        EM_ANDAMENTO_DEVEL,
        AGUARDANDO_VERSAO,
        FECHADA_SEM_DESENVOLVIMENTO,
      ]

      # Fluxo de situações das tarefas que não tem retorno de testes do QS
      FLUXO_SEM_RETORNO_TESTES = [
        ESTOQUE_DEVEL,
        EM_ANDAMENTO_DEVEL,
        AGUARDANDO_TESTES_DEVEL,
        AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL,
        AGUARDANDO_ENCAMINHAR_QS,
        ESTOQUE_QS,
        EM_ANDAMENTO_QS,
        AGUARDANDO_VERSAO,
        VERSAO_LIBERADA,
      ]

      # Fluxo de situações das tarefas que possuem retorno de testes do QS
      FLUXO_COM_RETORNO_TESTES = [
        ESTOQUE_DEVEL,
        EM_ANDAMENTO_DEVEL,
        AGUARDANDO_TESTES_DEVEL,
        AGUARDANDO_ENCAMINHAR_RETORNO_TESTES_DEVEL,
        AGUARDANDO_ENCAMINHAR_QS,
        ESTOQUE_QS,
        EM_ANDAMENTO_QS,
        AGUARDANDO_ENCAMINHAR_RETORNO_TESTES,
        ESTOQUE_DEVEL_RETORNO_TESTES,
        EM_ANDAMENTO_DEVEL_RETORNO_TESTES,
        AGUARDANDO_ENCAMINHAR_QS_RETORNO_TESTES,
        ESTOQUE_QS_RETORNO_TESTES,
        EM_ANDAMENTO_QS_RETORNO_TESTES,
        AGUARDANDO_VERSAO_RETORNO_TESTES,
        VERSAO_LIBERADA,
      ]
    end
  end
end
