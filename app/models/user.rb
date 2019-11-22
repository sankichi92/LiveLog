class User < ApplicationRecord
  self.ignored_columns = %i[first_name last_name furigana nickname joined]

  has_many :playings, dependent: :restrict_with_exception
  has_many :songs, through: :playings

  has_one :member, dependent: :nullify

  has_one_attached :avatar

  attr_accessor :remember_token, :activation_token, :reset_token

  has_secure_password

  before_save :downcase_email

  validates :email, presence: true, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }

  # region Status

  def enable_to_send_info?
    activated? && subscribing?
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
    update(activated: false, activated_at: nil, activation_digest: nil)
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
    update(remember_digest: encrypt(remember_token))
  end

  def forget
    update(remember_digest: nil)
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
    update!(reset_digest: encrypt(reset_token), reset_sent_at: Time.zone.now)
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
