class User < ApplicationRecord
  has_many :playings, dependent: :restrict_with_exception
  has_many :songs, through: :playings
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_save :remove_spaces_from_furigana
  default_scope { order('joined DESC', 'furigana COLLATE "C"') } # TODO: Remove 'COLLATE "C"'
  scope :distinct_joined, -> { unscoped.select(:joined).distinct.order(joined: :desc).pluck(:joined) }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :furigana, presence: true
  validates :nickname, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}, on: :update
  validates :joined, presence: true, numericality: {only_integer: true, greater_than: 1994, less_than_or_equal_to: Date.today.year}
  has_secure_password(validations: false)
  validates :password, presence: true, confirmation: true, length: {minimum: 6, maximum: 72}, allow_nil: true, on: :update
  validates :password_confirmation, presence: true, allow_nil: true, on: :update

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def full_name(logged_in = true)
    if logged_in
      nickname.blank? ? "#{last_name} #{first_name}" : "#{last_name} #{first_name} (#{nickname})"
    else
      handle
    end
  end

  def handle
    nickname.blank? ? last_name : nickname
  end

  def elder?
    joined < 2011
  end

  def admin_or_elder?
    admin? || elder?
  end

  def played?(song)
    songs.include?(song)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_invitation(email)
    self.activation_token = User.new_token
    if update_attributes(email: email, activation_digest: User.digest(activation_token))
      UserMailer.account_activation(self).deliver_now
    end
  end

  def send_password_reset
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  def downcase_email
    self.email = email.downcase unless email.nil?
  end

  def remove_spaces_from_furigana
    self.furigana = furigana.gsub(/\s+/, '')
  end
end
