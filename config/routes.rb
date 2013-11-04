Statusus::Application.routes.draw do

  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  resource :user
  resources :sessions
  resources :components, except: :show do
    post :status, on: :member
  end

  resources :messages, defaults: {format: :json}

  subdomain_constraint = lambda { |r| r.subdomain.present? && !%w[www statusus].include?(r.subdomain.split('.').first) }
  get '', to: 'application#public_page', constraints: subdomain_constraint
  get 'feed', to: 'application#feed', constraints: subdomain_constraint

  root 'application#landing'
  get 'manage', to: 'application#manage'
end
