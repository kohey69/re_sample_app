require "test_helper"

class UserMailerTest < ActionMailer::TestCase

  test "アカウント有効化" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user) # mailオブジェクトをmailに代入している
    assert_equal "ユーザー有効化します", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["kohey0911@icloud.com"], mail.from
    assert_match user.name, mail.body.encoded
    assert_match user.activation_token, mail.body.encoded
    assert_match CGI.escape(user.email), mail.body.encoded
  end

  # test "password_reset" do
  #   mail = UserMailer.password_reset
  #   assert_equal "Password reset", mail.subject
  #   assert_equal ["to@example.org"], mail.to
  #   assert_equal ["from@example.com"], mail.from
  #   assert_match "Hi", mail.body.encoded
  # end

end
