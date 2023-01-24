require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "編集失敗時" do
    log_in_as @user
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: {name: "",
                                      email: "foo@invalid",
                                      password: "foo",
                                      password_confirmation: "bar"}}
    assert_select "div.alert", "The form contains 4 errors."
    assert_template 'users/edit'
  end

  test "編集成功時friendlyforwardingによってユーザーの詳細ページに遷移する" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: "",
                                              password_confirmation: ""}}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
    get edit_user_path(@user)
    log_in_as(@user)
    assert is_logged_in?
    assert_redirected_to user_path(@user)
  end

end
