module SessionsHelper

  #セッションを張る
  def log_in(user)
    session[:user_id] = user.id # params {"session"=>{"id"}}
  end

  #現在ログイン中のユーザーを返す
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])  
      # =>
      #@current_user = @current_user || User.find_by(id: session[:user_id])と同義
      # =>
      # if @current_user.nil?
      #   @current_user = User.find_by(id: session[:user_id])
      # else
      #   @current_user
      # end　とも同義

    end
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    reset_session
    @current_user = nil #安全のため
  end
end
