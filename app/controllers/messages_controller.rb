class MessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @feed = Feed.find(params[:feed_id])
    @message = @feed.messages.build(params[:message])

    respond_to do |format|
      if @message.save
        format.html { redirect_to feeds_path, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { redirect_to feeds_path, notice: @message.errors }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
end
