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
    member do
      get 'album'
      put 'publish'
    end

    resources :entries, only: %i[index new create]
  end

  resources :members, only: %i[index show] do
    collection do
      get 'year/:year', action: :index, as: :year, constraints: { year: /\d{4}/ }
    end

    resource :user, only: %i[new create]
  end

  resources :stats, only: :show, param: :year

  scope :settings do
    resource :profile, only: %i[show update]
    resource :email, only: %i[show update]
  end

  namespace :admin do
    root to: 'home#show'
    resources :members, only: %i[index new create destroy] do
      resource :user, only: :destroy
      resource :admin, only: %i[create destroy]
    end
  end

  direct :organization do
    'https://ku-unplugged.net/'
  end

  direct :github do
    'https://github.com/sankichi92/LiveLog'
  end

  direct :heroku do
    'https://dashboard.heroku.com/apps/livelog2'
  end

  direct :google_analytics do
    'https://analytics.google.com/analytics/web/#/report-home/a56294602w89689985p93232021'
  end

  direct :google_search_console do
    'https://search.google.com/search-console?resource_id=https%3A%2F%2Flivelog.ku-unplugged.net%2F'
  end

  direct :twitter do
    'https://twitter.com/ku_livelog'
  end

  direct :slack_invitation do
    "https://join.slack.com/t/ku-livelog/shared_invite/#{ENV['SLACK_INVITATION_TOKEN']}"
  end

  direct :feedback do |user|
    uri = URI.parse('https://docs.google.com/forms/d/e/1FAIpQLSfhLHpL54pH_Oh5u7bLN31wGmJdqVUQ8WFSlyOF0A3DEJDzew/viewform')
    uri.query = {
      'entry.1322390882' => user.member.joined_year,
      'entry.1102506699' => user.member.name,
    }.to_query
    uri.to_s
  end
end
