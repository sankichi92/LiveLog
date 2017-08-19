Rails.application.routes.draw do

  root 'static_pages#home'

  get '/stats', to: 'static_pages#stats'

  resources :songs

  resources :lives do
    resource :entry, only: %i[new create]
  end

  resources :users, path: :members do
    resource :account_activation, path: :activation, as: :activation
    resource :password, only: %i[edit update]
    resource :admin, only: %i[create destroy]
  end

  resources :password_resets, only: %i[new create edit update]

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  namespace :api, format: 'json' do
    namespace :v1 do
      resources :users, only: %i[index show], path: :members
      resources :lives, only: %i[index show]
      resources :songs, only: %i[index show]
      post '/login', to: 'tokens#create'
      delete '/logout', to: 'tokens#destroy'
    end
  end
end
