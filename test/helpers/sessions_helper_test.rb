require "test_helper"

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "セッションが張られていない時、current_userは正しいuserを返す" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "remember_digestが誤っている時、current_userはnilを返す" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
