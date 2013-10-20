class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  before_action :authorize

  respond_to :json

  # GET /messages
  def index
    @messages = current_user.messages.in_order
  end

  # GET /messages/1
  def show
  end

  # POST /messages
  def create
    @message = current_user.messages.build(message_params)

    if @message.save
      # redirect_to @message, notice: 'Message was successfully created.'
      render json: @message
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /messages/1
  def update
    if @message.update(message_params)
      redirect_to @message, notice: 'Message was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /messages/1
  def destroy
    @message.destroy
    head :ok
  end

  private
    def set_message
      @message = current_user.messages.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def message_params
      params.require(:message).permit(:message, :status)
    end
end
