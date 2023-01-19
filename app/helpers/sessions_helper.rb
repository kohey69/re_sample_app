module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id # params {"session"=>{"id"}}
  end

end
