require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

end

class InvalidPasswordTest < UsersLogin

  test "ログインパス" do
    get login_path
    assert_template 'sessions/new'
  end
  
  test "間違った情報でログイン" do
    post login_path, params: { session: { email: @user.email, password: "invalid" } }
    assert_not is_logged_in?
    # assert_response :unprocessable_entity
    # assert_template 'sessions/new'
    # assert_not flash.empty?
    # get root_path
    # assert flash.empty?
  end

end


class ValidLogin < UsersLogin

  def setup
    super
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
  end

end

class ValidLoginTest < ValidLogin

  test "正しい情報でログイン" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test "ログイン後の処理" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count:0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

end

class Logout < ValidLogin
  
  def setup
    super
    delete logout_path
  end

end

class LogoutTest < Logout
  
  test "ログアウト成功" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "ログアウト後にリダイレクトされる" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "もう一つのウィンドウでログインした後でも動作する" do
    delete logout_path
    assert_redirected_to root_url
  end

end

class RememberingTest < UsersLogin

  test "Remember me 機能を使ってログインする" do
    log_in_as(@user, remember_me: '1')
    assert_not cookies[:remember_token].blank?
  end

  test "Remember me 機能を使わずにログインする" do
    log_in_as(@user, remember_me: '1') # Cookiesを保存してログイン
    log_in_as(@user, remember_me: '0') # Cookiesが削除されていることを検証してからログイン
    assert cookies[:remember_token].blank?
  end

end
  

