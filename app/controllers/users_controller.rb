class UsersController < ApplicationController
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

  def edit
    @user = current_user
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :app_name)
  end
end
