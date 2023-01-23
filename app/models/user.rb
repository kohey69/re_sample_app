class User < ApplicationRecord
  attr_accessor :remember_token
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

  def User.new_token
    SecureRandom.urlsafe_base64 #ランダムなトークンを返す
  end

  # 永続セッションのためにトークンをハッシュ化してDBに保存する
  def remember
    self.remember_token = User.new_token #new_tokenメソッドで作成したランダムな文字列をremember_tokenに代入
    update_attribute(:remember_digest, User.digest(self.remember_token)) # remember_tokenをハッシュ化してUserモデルに保存（更新）する
  end

  #ハッシュ化されたトークンをBCryptで認証する
  def authenticated?(remember_token) # remember_tokenは引数
    return false if remember_digest.nil?
    BCrypt::Password.new(self.remember_digest).is_password?(remember_token) # remember_digestはBCryptのinitializeメソッドの引数として使う
    # => BCryptモジュールのPasswordクラスのinitializaメソッドを呼び出している
      # def initialize(raw_hash)
      #   if valid_hash?(raw_hash)
      #     self.replace(raw_hash)
      #     @version, @cost, @salt, @checksum = split_hash(self)
      #   else
      #     raise Errors::InvalidHash.new("invalid hash")
      #   end
      # end
  end

  def forget
    update_attribute(:remember_digest, nil) #remember_digestカラムをnilで更新する
  end
end
