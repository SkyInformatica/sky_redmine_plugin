post "retorno_testes_qs/:id", to: "retorno_testes#retorno_testes_qs", as: "retorno_testes_qs"
post "retorno_testes_devel/:id", to: "retorno_testes#retorno_testes_devel", as: "retorno_testes_devel"
get "retorno_testes_lote", to: "retorno_testes#retorno_testes_lote", as: "retorno_testes_lote"

# encaminhar QS
post "encaminhar_qs/:id", to: "encaminhar_qs#encaminhar_qs", as: "encaminhar_qs"
get "encaminhar_qs_lote", to: "encaminhar_qs#encaminhar_qs_lote", as: "encaminhar_qs_lote"

# testar tarefa
post "testar_tarefa/:id", to: "testar_tarefa#testar_tarefa", as: "testar_tarefa"

# continua próxima sprint
post "continua_proxima_sprint/:id", to: "continua_proxima_sprint#continua_proxima_sprint", as: "continua_proxima_sprint"
get "continua_proxima_sprint_lote", to: "continua_proxima_sprint#continua_proxima_sprint_lote", as: "continua_proxima_sprint_lote"

# configurações do plugin
get "sky_redmine_settings", to: "sky_redmine_settings#show", as: "sky_redmine_settings"
post "sky_redmine_settings", to: "sky_redmine_settings#update", as: "update_sky_redmine_settings"
delete "limpar_indicadores", to: "processar_indicadores#limpar_indicadores", as: "limpar_indicadores"

match "projects/:id/indicadores", to: "indicadores#index", via: "get", as: "indicadores"

# processar indicadores
get "processar_indicadores_lote", to: "processar_indicadores#processar_indicadores_lote", as: "processar_indicadores_lote"
post "processar_indicadores_tarefa/:id", to: "processar_indicadores#processar_indicadores_tarefa", as: "processar_indicadores_tarefa"
