Rails.application.routes.draw do

  root 'static_pages#home'

  get '/stats', to: 'static_pages#stats'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :password_resets, only: %i[new create edit update]

  resources :users, path: :members do
    resource :account_activation, path: :activation, as: :activation
    resource :password, only: %i[edit update]
    resource :admin, only: %i[create destroy]
  end

  resources :lives

  resources :songs

  namespace :api, format: 'json' do
    namespace :v1 do
      resources :users, only: %i[index show], path: :members
      resources :lives, only: %i[index show]
      resources :songs, only: %i[index show]
    end
  end

end
