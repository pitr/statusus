Statusus::Application.routes.draw do

  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  resources :users
  resources :sessions
  # resources :components, except: :show do
  #   post :status, on: :member
  # end

  resources :messages, defaults: {format: :json}

  get '', to: 'application#public_page', constraints: lambda { |r| r.subdomain.present? && !%w[www statusus].include?(r.subdomain.split('.').first) }

  root 'application#landing'
  get 'manage', to: 'application#manage'

  get 'status/*', to: 'application#public_page'
end
