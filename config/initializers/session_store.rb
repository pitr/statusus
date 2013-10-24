if Rails.env.production?

  require 'action_dispatch/middleware/session/dalli_store'
  Statusus::Application.config.session_store :dalli_store, :namespace => 'sessions', :key => '_statusus_session', :expire_after => 60.minutes

else

  Statusus::Application.config.session_store :cookie_store, key: '_statusus_session'

end
