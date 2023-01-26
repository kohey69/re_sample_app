class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy] # 各アクションが実行される前にメソッドが実行される
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  def new
    @user = User.new
  end

  def index
    # @users = User.paginate(page: params[:page]) # gem(will_paginate)によってUser.allの.allをpaginateメソッドに書き換えるだけでパージネーションできる
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def create
    # @user = User.new(params[:user]) にStrongParametersを実装しやすくするためuser_paramsをprivateに定義
    @user = User.new(user_params)
    if  @user.save
      @user.send_activation_email
      flash[:info] = "メールアドレス宛に認証メールが届いているか確認してください"
      redirect_to root_url 
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
      @user = User.find(params[:id])
      if @user.update(user_params) # postやpatchリクエストにはStrongParametersを使う
        flash[:success] = "プロフィールの更新完了"
        redirect_to @user
      else
        render 'edit', status: :unprocessable_entity
      end
  end

  def destroy
      User.find(params[:id]).destroy
      flash[:success] = "User deleted"
      redirect_to users_url, status: :see_other
  end
end


private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation) # ここにadminを含めないテクニックをStrongParametersという
  end

  # ログイン済みかどうか確認し、未ログインならログインページに飛ばす
  # def logged_in_user
  #   unless logged_in?
  #     store_location
  #     flash[:danger] = "Please log in"
  #     redirect_to login_url, status: :see_other #redirectの時は名前付きルートはurlしか使えない
  #   end
  # end

  # フォームから入力されたidで@userを検索し、current_userと比較する
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end

  #adminユーザーかどうか確認し、falseならrootにリダイレクトする
  def admin_user
    redirect_to(root_url, status: :see_other) unless current_user.admin?
  end