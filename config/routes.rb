Rails.application.routes.draw do
  root 'static_pages#home'
  get '/about', to: 'static_pages#about'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users do
    resource :account_activations, only: %i(new create edit update), path: :activations, as: :activations
  end
  resources :password_resets, only: %i(new create edit update)
end
