class ApplicationController < ActionController::Base
  # protect_from_forgery

  def guest
    unless user_signed_in?
      user = User.where(email: params[:email]).first_or_create!(password: 'helloworld')

      sign_in user
    end

    redirect_to feeds_path
  end
end
