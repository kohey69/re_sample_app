require "test_helper"

class UserMailerTest < ActionMailer::TestCase

  test "アカウント有効化" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user) # mailオブジェクトをmailに代入している
    assert_equal "ユーザー有効化用リンクを送信します", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["kohey0911@icloud.com"], mail.from
    assert_match user.name, mail.body.encoded
    assert_match user.activation_token, mail.body.encoded
    assert_match CGI.escape(user.email), mail.body.encoded # mailオブジェクトに対してencodedを使うことでメール本文を返す
  end

  test "password_reset" do
    user = users(:michael)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "パスワード再設定用リンクを送信します", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["kohey0911@icloud.com"], mail.from
    assert_match user.reset_token, mail.body.encoded
    assert_match CGI.escape(user.email), mail.body.encoded
  end

end
