Rails.application.routes.draw do
  resources :productos, only: [:index, :show] do
    collection do
      get 'productos_mas_comprados'
      get 'productos_mas_recaudados'
      get 'buscar_compras'
      get 'compras_por_granularidad'
    end
  end
  resources :categorias
  resources :clientes
  resources :compras
end
