class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  before_action :restrict_api, only: :create

  protect_from_forgery with: :null_session, only: :create, if: :current_user

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

    @message.save

    render 'show'
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

    def message_params
      params.require(:message).permit(:text, :status)
    end

    def restrict_api
      return unless request.authorization
      authenticate_or_request_with_http_token do |token, options|
        @current_user = User.find_by_access_token(token)
      end
    end
end
