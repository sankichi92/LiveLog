Rails.application.routes.draw do
  root 'static_pages#home'

  get '/donate', to: 'donations#index'
  get '/privacy', to: 'static_pages#privacy'

  get '/auth/auth0/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  delete '/logout', to: 'sessions#destroy'

  resources :songs, only: %i[index show edit update] do
    collection do
      get 'search'
    end
  end

  resources :lives, only: %i[index show] do
    member do
      get :album
    end
  end

  resources :members, only: %i[index show] do
    collection do
      get 'year/:year', action: :index, as: :year, constraints: { year: /\d{4}/ }
    end

    resource :user, only: %i[new create]
  end

  resources :stats, only: :show, param: :year

  resources :entries, except: :show

  scope :settings do
    resource :profile, only: %i[show update]
    resource :email, only: %i[show update]
  end

  namespace :admin do
    root to: 'home#show'

    resources :lives do
      member do
        put :publish
      end

      resources :songs, only: %i[new create edit update destroy], shallow: true
    end

    resources :members, only: %i[index new create destroy] do
      resource :user, only: :destroy
      resource :admin, only: %i[create destroy]
    end

    resources :entries, only: %i[index edit update]
  end

  direct :organization do
    'https://ku-unplugged.net/'
  end

  direct :github do
    'https://github.com/sankichi92/LiveLog'
  end

  direct :twitter do
    'https://twitter.com/ku_livelog'
  end

  direct :slack_invitation do
    "https://join.slack.com/t/ku-livelog/shared_invite/#{ENV['SLACK_INVITATION_TOKEN']}"
  end
end
