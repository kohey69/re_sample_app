require "test_helper"

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "有効性テスト" do
    assert @micropost.valid?
  end

  test "ユーザーが存在する" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "contentが必ず存在する" do
    @micropost.content = ""
    assert_not @micropost.valid?
  end

  test "contentは140文字いないである" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "最近作成された順にmicropostが並んでいる" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
