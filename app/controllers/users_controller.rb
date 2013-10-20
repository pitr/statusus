class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def new
    @user = User.new(app_name: 'My App')
  end

  def create
    @user = params[:user] ? User.new(user_params) : User.new_guest

    if @user.save
      @user.populate_with_examples
      current_user.move_to(@user) if current_user && current_user.guest?
      session[:user_id] = @user.id
      redirect_to manage_url, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :app_name, :subdomain)
  end
end
