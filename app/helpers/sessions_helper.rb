module SessionsHelper

  # セッションに "=A" で指定したAの数値を入れるメソッド
  def log_in(user)
    session[:user_id] = user.id # user[:id]でも同じこと # ちなみにhas_secure_passwordをモデルに記載した時点でsessionメソッドが使える
    #セッションに {:user_id => 1 }が登録された(userがuser.rbでUser.find_by(id:1)の場合)
    session[:session_token] = user.session_token # セッションリプレイ攻撃から保護する
  end

  #user.rbに定義しているrememberメソッドとは別物
  #Cookiesを焼く処理(ユーザーIDと記憶トークン)
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id #永続cookiesにユーザーIDを暗号化して保存する
    cookies.permanent[:remember_token] = user.remember_token
  end

  #現在ログイン中のユーザーを返す
  def current_user
    if (user_id = session[:user_id]) #if(変数user_idを定義し、session[:user_id]を代入する
      user = User.find_by(id: user_id)
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id) # 変数userを定義して、User.find_by(id: cookies.encrypted[:user_id]を代入する)
      if user && user.authenticated?(cookies[:remember_token]) # userが存在する かつ cookiesに保存された記憶トークンで認証できる
        log_in user # ログイン処理を行う
        @current_user = user # @current_userにuserを代入する
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget 
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    reset_session
    @current_user = nil #安全のため
  end

  def current_user?(user)
    user && user == current_user
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get? # リクエストがgetリクエストの時、request.original_urlをセッション変数に保存
  end
end

