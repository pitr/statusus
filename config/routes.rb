Statusus::Application.routes.draw do
  resources :feeds, :only => [:index, :create] do
    resources :messages, :only => :create
  end

  devise_for :users, :controllers => { :registrations => :registrations }

  get '/pricing' => 'application#pricing'
  get '/about' => 'application#about'

  get '/dashboard/:uuid' => 'feeds#dashboard', :as => :dashboard
  get '/' => 'feeds#dashboard', :constraints => { :subdomain => /.+/ }

  post "heroku/resources" => "heroku#create"
  delete "heroku/resources/:id" => "heroku#destroy"

  resources :api, only: :create

  root :to => 'application#welcome'
end
