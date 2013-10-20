class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authorize, only: :manage

  def landing
    @custom_html = true
  end

  def manage
  end

  def public_page
    if params[:page]
      @user = User.find_by_subdomain(params[:page])

      unless @user
        redirect_to root_url
        return
      end
    else
      subdomain = request.subdomain.split('.').first
      @user = User.find_by_subdomain(subdomain)
      unless @user
        redirect_to root_url(subdomain: request.subdomain.split('.')[1..-1].join('.'))
        return
      end
    end

    render layout: false
  end

private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def authorize
    redirect_to login_url, alert: "Not authorized" if current_user.nil?
  end

end
