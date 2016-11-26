Rails.application.routes.draw do
  root 'static_pages#home'
  get '/stats', to: 'static_pages#stats'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users, path: :members do
    resource :account_activations, only: %i(new create edit update), path: :activations, as: :activations
  end
  resources :password_resets, only: %i(new create edit update)
  resources :lives
  resources :songs
end
