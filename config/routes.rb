Statusus::Application.routes.draw do
  resources :feeds, only: [:index, :create] do
    resources :messages, only: :create
  end

  devise_for :users, controllers: { registrations: :registrations }

  get '/pricing' => 'application#pricing'

  get '/dashboard/:uuid' => 'dashboard#show', :as => :dashboard

  root to: 'dashboard#show', constraints: ->(request) { User.exists?(cname: request.host.gsub(/^www./, '')) }

  post    'heroku/resources'      => 'heroku#create'
  put     'heroku/resources/:id'  => 'heroku#update'
  delete  'heroku/resources/:id'  => 'heroku#destroy'
  post    'heroku/login'          => 'heroku#login'

  root to: 'application#welcome'
end
