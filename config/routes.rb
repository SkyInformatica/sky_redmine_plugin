# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

# retorno de testes
post "criar_retorno_testes_qs/:id", to: "criar_retorno_testes#criar_retorno_testes_qs", as: "criar_retorno_testes_qs"
post "criar_retorno_testes_devel/:id", to: "criar_retorno_testes#criar_retorno_testes_devel", as: "criar_retorno_testes_devel"
get "criar_retorno_testes_lote", to: "criar_retorno_testes#criar_retorno_testes_lote", as: "criar_retorno_testes_lote"

# continua na proxima sprint
#get "continua_na_proxima_sprint_lote", to: "continua_na_proxima_sprint#continua_na_proxima_sprint_lote", as: "continua_na_proxima_sprint_lote"
