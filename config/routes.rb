Statusus::Application.routes.draw do
  resources :feeds, :only => [:index, :create] do
    resources :messages, :only => :create
  end

  devise_for :users, :controllers => { :registrations => :registrations }

  get '/pricing' => 'application#pricing'
  get '/about' => 'application#about'

  get '/dashboard/:uuid' => 'dashboard#show', :as => :dashboard
  get '/' => 'dashboard#show', :constraints => lambda { |r| r.subdomain.present? && r.subdomain != 'www' }

  post "heroku/resources" => "heroku#create"
  put "heroku/resources/:id" => "heroku#update"
  delete "heroku/resources/:id" => "heroku#destroy"
  post "heroku/login" => "heroku#login"

  root :to => 'application#welcome'
end
