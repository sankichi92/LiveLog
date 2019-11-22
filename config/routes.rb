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

  resources :members, only: %i[index show] do
    collection do
      get 'year/:year', action: :year, as: :year, constraints: { year: /\d{4}/ }
    end

    resource :user, only: %i[new]
  end

  resources :users, only: %i[edit update], path: :members do
    resource :account_activation, except: :show, path: :activation, as: :activation
    resource :password, only: %i[edit update]
    resource :admin, only: %i[create destroy]
  end

  scope :settings do
    resource :profile, only: %i[show update]
  end

  resources :password_resets, only: %i[new create edit update]

  resources :stats, only: :show, param: :year

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  direct :homepage do
    'https://ku-unplugged.net/'
  end
end
