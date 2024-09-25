# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
post "criar_retorno_testes_qs/:id", to: "criar_retorno_testes#criar_retorno_testes_qs", as: "criar_retorno_testes_qs"
post "criar_retorno_testes_devel/:id", to: "criar_retorno_testes#criar_retorno_testes_devel", as: "criar_retorno_testes_devel"

get :criar_retorno_testes_qs_lote, to: "criar_retorno_testes#criar_retorno_testes_qs_lote"
