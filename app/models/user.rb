class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :furigana, presence: true
  validates :nickname, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, allow_nil: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  validates :joined, presence: true, numericality: {greater_than: 1994}
  has_secure_password
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def full_name
    last_name + ' ' + first_name
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def send_invitation(email)
    self.activation_token = User.new_token
    if update_attributes(email: email, activation_digest: User.digest(activation_token))
      UserMailer.account_activation(self).deliver_now
    end
  end

  def activate(new_password)
    update_attributes(new_password)
    update_attributes(activated: true, activated_at: Time.zone.now)
  end

  private

  def downcase_email
    self.email = email.downcase unless self.email.nil?
  end
end
