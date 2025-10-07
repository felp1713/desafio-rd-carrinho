require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products

  post '/cart/add_items', to: 'carts#add_item'
  post '/cart/add_item', to: 'carts#add_item'
  post '/cart', to: 'carts#add_item'
  #Ideal apenas um post /cart/add_items mas para evitar problemas com testes e descrição do desafio, segui por apontar todas rotas para o mesmo método

  delete '/cart/:product_id', to: 'carts#destroy_item', as: :destroy_cart_item
  resource :cart, only: [:show]

  get "up" => "rails/health#show", as: :rails_health_check
  root "rails/health#show"
end
