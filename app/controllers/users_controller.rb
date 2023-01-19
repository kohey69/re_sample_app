class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])   
  end

  def create
    # @user = User.new(params[:user])
    @user = User.new(user_params)
    if  @user.save
      flash[:success] = "ユーザー登録成功"
      redirect_to @user #redirect_to user_url(@user)と同じ
    else
      render 'new', status: :unprocessable_entity
    end
  end
end


private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end