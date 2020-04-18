Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/api/graphql'

  root 'home#show'

  get '/donate', to: 'donations#index'
  get '/privacy', to: 'docs#privacy'
  get '/slack', to: 'slack#show'

  get '/auth/auth0/callback', to: 'auth#auth0'
  get '/auth/github/callback', to: 'auth#github'
  get '/auth/failure', to: 'auth#failure'
  delete '/logout', to: 'auth#logout'

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

  resources :clients, only: %i[index new create]

  namespace :api do
    post '/graphql', to: 'graphql#execute'
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
      resource :administrator, only: :create
    end

    resources :entries, only: %i[index edit update destroy]

    resources :user_registration_forms, only: %i[index new create destroy]

    resources :developers, only: %i[index]

    resources :administrators, only: %i[index edit update destroy]
  end

  direct :organization do
    'https://ku-unplugged.net/'
  end

  direct :github do
    'https://github.com/sankichi92/LiveLog'
  end

  direct :github_user do |github_username|
    "https://github.com/#{github_username}"
  end

  direct :twitter do
    'https://twitter.com/ku_livelog'
  end

  direct :slack_invitation do
    "https://join.slack.com/t/ku-livelog/shared_invite/#{ENV['SLACK_INVITATION_TOKEN']}"
  end
end
