class SessionsController < ApplicationController
  def new
   
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase) # form_withで入力したデータを変数userに受け取る
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in(user)
        redirect_to forwarding_url || user
      else
        message = "アカウントが有効化されていません"
        message += "あなたのメールボックスで有効化リンクを確認してください"
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash[:now] = "メールアドレスもしくはパスワードに誤りがあります"
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
