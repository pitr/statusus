class FeedsController < ApplicationController
  before_filter :authenticate_user!, :except => :dashboard

  def index
    @feeds = current_user.feeds.includes(:messages) # TODO: remove includes
  end

  def create
    @feed = current_user.feeds.build(params[:feed])

    if @feed.save
      redirect_to feeds_path, notice: 'Feed was successfully created.'
    else
      render action: "index"
    end
  end

  def dashboard
    @user = if params[:uuid]
      User.where(uuid: params[:uuid]).first
    else
      User.where(cname: request.host).first
    end
    @feeds = @user.feeds.includes(:messages) # TODO: remove includes
    @hide_navbar = true
  end
end
