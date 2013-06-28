class DashboardController < ApplicationController
  def show
    @user = if params[:uuid]
      User.where(uuid: params[:uuid]).first
    else
      User.where(cname: request.host.gsub(/^www./, '')).first
    end
    @feeds = @user.feeds.includes(:messages) # TODO: remove includes
    @hide_navbar = true
  end
end
