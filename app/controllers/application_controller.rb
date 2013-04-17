class ApplicationController < ActionController::Base
  protect_from_forgery

  def guest
    redirect_to feeds_path
  end
end
