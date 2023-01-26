class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_exporation, only: [:edit, :update]


  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase) # 再設定用ページで入力したメールアドレスのユーザーを検索
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "メールアドレス宛に再設定用リンクを送信しました"
      redirect_to root_url
    else
      flash.now[:danger] = "入力したメールアドレスのユーザーが見つかりません"
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty? # form_withから受け取ったparams[:user][:password]が空欄の時
      @user.errors.add(:password, "can't be empty")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params) # formで入力されたパスワードで更新できた時
      reset_session
      log_in @user
      flash[:success] = "パスワードが変更できました"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity 
    end
  end
  
  
  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation) # StrongParameters(リクエストで送れるparameterを限定する)の実装
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end
    
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    #トークンが期限切れかどうか確認する
    def check_exporation
      if @user.password_reset_expired?
        flash[:danger] = "パスワードの再設定リンクの利用期限が過ぎています"
        redirect_to new_password_reset_url
      end
    end
end