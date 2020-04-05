Rails.application.routes.draw do
  root 'home#show'

  get '/donate', to: 'donations#index'
  get '/privacy', to: 'docs#privacy'
  get '/slack', to: 'slack#show'

  get '/auth/auth0/callback', to: 'auth0#callback'
  get '/auth/failure', to: 'auth0#failure'
  delete '/logout', to: 'auth0#logout'

  resources :songs, only: %i[index show edit update] do
    collection do
      get 'search'
    end
  end

  resources :lives, only: %i[index show] do
    member do
      get :album
    end

    resource :entry_guideline, only: :show
  end

  resources :members, only: %i[index show] do
    collection do
      get 'year/:year', action: :index, as: :year, constraints: { year: /\d{4}/ }
    end

    resource :user, only: %i[new create]
  end

  resources :summaries, only: %i[index show], param: :year

  resources :entries, except: :show

  resources :user_registration_forms, only: :show, path: 'register', param: :token do
    resources :members, only: :create
  end

  scope :settings do
    resource :profile, only: %i[show update]
    resource :email, only: %i[show update]
  end

  namespace :api do
    root to: 'no_contents#show'
  end

  namespace :admin do
    root to: 'home#show'

    resources :lives do
      member do
        post :publish
      end

      resource :entry_guideline, only: %i[new create edit update]
      resources :songs, only: %i[new create edit update destroy], shallow: true
    end

    resources :members, only: %i[index new create destroy] do
      resource :user, only: :destroy
      resource :admin, only: %i[create destroy]
    end

    resources :entries, only: %i[index edit update destroy]

    resources :user_registration_forms, only: %i[index new create destroy]
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
