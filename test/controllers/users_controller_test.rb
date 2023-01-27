require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "未ログインでeditアクションにリクエストした場合リダイレクトする" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "未ログインでupdateアクションにリクエストした場合リダイレクトする" do
    patch user_path(@user), params: { user: { name: @user.name,
                                                email: @user.email }}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "他のユーザーの情報は編集できない" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "他のユーザーの情報は更新できない" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email }}
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "未ログインでindexアクションにリクエストした場合リダイレクトされる" do
    get users_path
    assert_redirected_to login_url
  end

  test "未ログインでdestroyアクションにリクエストした場合loginページにリダイレクトされる" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "adminユーザーでないユーザーがdestroyアクションをリクエストした場合rootページにリダイレクトされる" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "ログインしていない時followingページにリクエストを送るとloginページにリダイレクトされる" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "ログインしていない時followersページにリクエストを送るとloginページにリダイレクトされる" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
