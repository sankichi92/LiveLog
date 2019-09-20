class User < ApplicationRecord
  has_many :playings, dependent: :restrict_with_exception
  has_many :songs, through: :playings
  has_many :identities, dependent: :destroy

  has_one :google_credential, dependent: :destroy

  has_one_attached :avatar

  attr_accessor :remember_token, :activation_token, :reset_token

  has_secure_password(validations: false)

  before_save :downcase_email

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :furigana, presence: true, format: { with: /\A[\p{Hiragana}ー]+\z/ }
  validates :nickname, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }, uniqueness: { case_sensitive: false }, on: :update
  validates :joined, presence: true, numericality: { only_integer: true, greater_than: 1994, less_than_or_equal_to: Time.zone.today.year }
  validates :url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true
  validates :password, presence: true, confirmation: true, length: { minimum: 6, maximum: 72 }, allow_nil: true, on: :update
  validates :password_confirmation, presence: true, allow_nil: true, on: :update

  scope :natural_order, -> { order(joined: :desc, furigana: :asc) }
  scope :joined_years, -> { unscope(:order).order(joined: :desc).distinct.pluck(:joined) }

  # region Attributes

  def name
    "#{last_name} #{first_name}"
  end

  def handle
    nickname.presence || last_name
  end

  def name_with_handle
    nickname.blank? ? name : "#{name} (#{nickname})"
  end

  # endregion

  # region Status

  def elder?
    joined < 2011
  end

  def admin_or_elder?
    admin? || elder?
  end

  def enable_to_send_info?
    activated? && subscribing?
  end

  def graduate?
    joined <= Time.zone.now.nendo - 4
  end

  def donated?
    donated_ids = ENV['LIVELOG_DONATED_USER_IDS']&.split(',')&.map(&:to_i) || []
    donated_ids.include?(id)
  end

  # endregion

  # region Activation

  def send_invitation(email, inviter)
    self.activation_token = SecureRandom.base64
    return unless update(email: email, activation_digest: encrypt(activation_token))
    UserMailer.account_activation(self, inviter).deliver_now
  end

  def activate(password_params)
    update(password_params.merge(activated: true, activated_at: Time.zone.now, public: true))
  end

  def deactivate
    update_columns(activated: false, activated_at: nil, activation_digest: nil)
  end

  # endregion

  # region Authentication

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def remember
    self.remember_token = SecureRandom.base64
    update_column(:remember_digest, encrypt(remember_token))
  end

  def forget
    update_column(:remember_digest, nil)
  end

  def valid_token?(token)
    digests = tokens.pluck(:digest)
    digests.any? { |d| BCrypt::Password.new(d).is_password?(token) }
  end

  def destroy_token(token)
    token = tokens.find { |t| BCrypt::Password.new(t.digest).is_password?(token) }
    token&.destroy
  end

  # endregion

  # region Password reset

  def send_password_reset
    self.reset_token = SecureRandom.base64
    update_columns(reset_digest: encrypt(reset_token), reset_sent_at: Time.zone.now)
    UserMailer.password_reset(self).deliver_now
  end

  def reset_password(password_params)
    update(password_params.merge(reset_digest: nil, reset_sent_at: nil))
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # endregion

  private

  def encrypt(unencrypted_str)
    BCrypt::Password.create(unencrypted_str)
  end

  def downcase_email
    self.email = email.downcase unless email.nil?
  end
end
