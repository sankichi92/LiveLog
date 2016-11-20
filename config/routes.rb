Rails.application.routes.draw do
  get 'sessions/new'

  root 'static_pages#home'
  get '/about', to: 'static_pages#about'
  get '/signup', to: 'users#signup'
  resources :users
end
