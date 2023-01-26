class UserMailer < ApplicationMailer
  
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "ユーザー有効化用リンクを送信します"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "パスワード再設定用リンクを送信します"
  end
end
