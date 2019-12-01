Rails.application.routes.draw do
  root 'static_pages#home'

  get '/donation', to: 'static_pages#donation'
  get '/privacy', to: 'static_pages#privacy'

  get '/auth/auth0/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  delete '/logout', to: 'sessions#destroy'

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

    resource :user, only: %i[new create]
  end

  scope :settings do
    resource :profile, only: %i[show update]
  end

  resources :users, only: %i[edit update], path: :members do
    resource :password, only: %i[edit update]
    resource :admin, only: %i[create destroy]
  end

  resources :password_resets, only: %i[new create edit update]

  resources :stats, only: :show, param: :year

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

  direct :feedback do |user|
    uri = URI.parse('https://docs.google.com/forms/d/e/1FAIpQLSfhLHpL54pH_Oh5u7bLN31wGmJdqVUQ8WFSlyOF0A3DEJDzew/viewform')
    uri.query = URI.encode_www_form(
      'entry.1322390882' => user.member.joined_year,
      'entry.1102506699' => user.member.name,
      'entry.724954072' => user.email,
    )
    uri.to_s
  end
end
