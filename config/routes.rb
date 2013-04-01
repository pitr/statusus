Statusus::Application.routes.draw do
  resources :feeds, :only => [:index, :create] do
    resources :messages, :only => :create
  end

  devise_for :users

  get '/pricing' => 'application#pricing'
  get '/about' => 'application#about'

  post '/' => 'application#guest'

  get '/dashboard/:uuid' => 'feeds#dashboard', :as => :dashboard

  root :to => 'application#welcome'
end