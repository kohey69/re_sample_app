require "test_helper"

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id, followed_id: users(:archer).id)
  end

  test "有効かどうか" do
    assert @relationship.valid?
  end

  test "follower_idがnilでは@relationshipを登録できない" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test "followed_idがnilでは@relationshipを登録できない" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
