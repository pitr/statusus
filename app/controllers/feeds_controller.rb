class FeedsController < ApplicationController
  before_action :authenticate_user!

  def index
    @feeds = current_user.feeds.includes(:messages) # TODO: remove includes
  end

  def create
    @feed = current_user.feeds.build(feed_params)

    if @feed.save
      redirect_to feeds_path, notice: 'Feed was successfully created.'
    else
      render action: "index"
    end
  end

  private

  def feed_params
    params.require(:feed).permit(:name)
  end
end
