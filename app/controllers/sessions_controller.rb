class SessionsController < ApplicationController
  before_action :authorize, only: :destroy

  def create
    user ||= User.find_by_email(params[:email])
    user ||= User.find_by_username(params[:email])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to manage_url, notice: "Logged in!"
    else
      flash.now.alert = "Email or password is invalid."
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end
