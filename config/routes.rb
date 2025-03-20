Rails.application.routes.draw do
  resources :products

  # Usando o cart_id na URL
  resources :carts, only: [:create, :show] do
    post 'add_product', to: 'carts#add_product'
    post 'update_item', to: 'carts#update_quantity'
    delete 'remove_item/:product_id', to: 'carts#remove_product'
  end

  # Usando a sessão, sem passar cart_id na URL
  post 'cart/add_product', to: 'carts#add_product'
  get 'cart', to: 'carts#show'
  post 'cart/update_item', to: 'carts#update_quantity'
  delete 'cart/remove_item/:product_id', to: 'carts#remove_product'

  get "up", to: "rails/health#show", as: :rails_health_check
  root "rails/health#show"
end
