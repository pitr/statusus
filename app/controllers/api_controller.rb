class ApiController < ApplicationController
  before_filter :restrict_access
  respond_to :json

  def create
    @feed = @user.feeds.find(params[:feed_id])
    @message = @feed.messages.build(params[:message])

    if @message.save
      head :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  private

  def restrict_access
    @user = User.where(access_token: params[:access_token]).first
    head :unauthorized unless @user
  end
end
