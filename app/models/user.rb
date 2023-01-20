class User < ApplicationRecord
  before_save {self.email = self.email.downcase}
  validates(:name, presence: true, length: {maximum: 50})
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: true)
  has_secure_password
  validates :password, presence: true, length: {minimum: 6}


  #BCryptの使い方
  def User.digest(string)
    # A? B:C => AがtrueならB、falseならC（三項演算子）
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    # BCrypt::Password.create(xx, cost: yy) => xxをyyコストでハッシュ化
    BCrypt::Password.create(string, cost: cost)
  end
end
