Rails.application.routes.draw do
  resources :productos
  resources :categorias
  resources :clientes
  resources :compras
end
