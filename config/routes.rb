# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# retorno de testes
post "retorno_testes_qs/:id", to: "retorno_testes#retorno_testes_qs", as: "retorno_testes_qs"
post "retorno_testes_devel/:id", to: "retorno_testes#retorno_testes_devel", as: "retorno_testes_devel"
get "retorno_testes_lote", to: "retorno_testes#retorno_testes_lote", as: "retorno_testes_lote"

# encaminhar QS
post "encaminhar_qs/:id", to: "encaminhar_qs#encaminhar_qs", as: "encaminhar_qs"
get "encaminhar_qs_lote", to: "encaminhar_qs#encaminhar_qs_lote", as: "encaminhar_qs_lote"

#continua proxima sprint
get "continua_proxima_sprint_lote", to: "continua_proxima_sprint#continua_proxima_sprint_lote", as: "continua_proxima_sprint_lote"

# continua na proxima sprint
#get "continua_na_proxima_sprint_lote", to: "continua_na_proxima_sprint#continua_na_proxima_sprint_lote", as: "continua_na_proxima_sprint_lote"
