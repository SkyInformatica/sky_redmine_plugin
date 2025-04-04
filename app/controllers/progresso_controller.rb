class ProgressoController < ApplicationController
  def progresso
    tipo = params[:tipo]

    case tipo
    when "processar_indicadores_2024"
      progresso_data = ProcessarIndicadoresController.progresso_indicadores
      total = progresso_data[:total]
      processados = progresso_data[:processados]
      progresso = total > 0 ? (processados.to_f / total * 100).round(2) : 0
    else
      progresso = 0
    end

    render json: { progresso: progresso }
  end
end
