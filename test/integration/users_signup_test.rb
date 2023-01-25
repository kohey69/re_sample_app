require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest

  def setup 
    ActionMailer::Base.deliveries.clear
  end

end

class UsersSignupTest < UsersSignup

  test "ユーザー登録失敗" do
    # get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: {name: "",
                                        email: "user@invalid",
                                        password: "foo",
                                        password_confirmation: "bar"} }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end
  
  test "ユーザー登録成功" do
    get signup_path

    assert_difference 'User.count' do
      post users_path, params: { user: {name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    # follow_redirect!
    # assert_template 'users/show'
    # assert is_logged_in?
  end
end

class AccountActivationTest < UsersSignup

  def setup
    super
    post users_path, params: { user: { name:  "Example User",
                                      email: "user@example.com",
                                      password:              "password",
                                      password_confirmation: "password" } }
    @user = assigns(:user)
  end

  test "有効化されるべきではない" do
    assert_not @user.activated?
  end

  test "アカウント有効化前にログインできるべきではない" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test "無効なアクティベーショントークンでログインできないはず" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  test "間違ったメールアドレスでログインできないはず" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  test "正しい有効化トークンとメールアドレスならログインできる" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end