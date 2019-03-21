Rails.application.routes.draw do

  root 'static_pages#home'

  get '/donation', to: 'static_pages#donation'

  get '/privacy', to: 'static_pages#privacy'

  resources :songs do
    collection do
      get 'search'
    end
  end

  resources :lives do
    resources :entries, only: %i[index new create]
    member do
      get 'album'
      put 'publish'
    end
  end

  resources :users, path: :members do
    resource :account_activation, except: :show, path: :activation, as: :activation
    resource :password, only: %i[edit update]
    resource :admin, only: %i[create destroy]
  end

  resource :profile, only: :edit

  resources :password_resets, only: %i[new create edit update]

  resources :stats, only: :show, param: :year

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/auth/google_oauth2/callback', to: 'auth#create'

  namespace :api, format: 'json' do
    namespace :v1 do
      resources :regular_meetings, only: :show
      resources :pickups, only: :show
      resources :users, only: %i[index show], path: :members
      resources :lives, only: %i[index show]
      resources :songs, only: %i[index show]
      resource :profile, only: %i[show update]
      post '/login', to: 'tokens#create'
      delete '/logout', to: 'tokens#destroy'
    end
  end

  direct :homepage do
    'https://ku-unplugged.net/'
  end
end
