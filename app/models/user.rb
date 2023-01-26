class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates(:name, presence: true, length: {maximum: 50})
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: true)
  has_secure_password
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true #ユーザー登録時にはhas_secure_passwordのバリデーションが空欄でのパスワード登録を検証するようになっている


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
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  #ハッシュ化されたトークンをBCryptで認証する
  def authenticated?(attribute, token) # remember_tokenは引数
    digest = self.send("#{attribute}_digest") # メソッドを呼び出すメソッド
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token) # remember_digestはBCryptのinitializeメソッドの引数として使う
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

  # アカウントを有効化する
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定用のトークンをハッシュ化しDBに保存する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定用のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワードが期限切れのときtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

private

  def downcase_email
    self.email = self.email.downcase
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token) #activation_digestはuserモデルのカラムのため利用可
  end
end
