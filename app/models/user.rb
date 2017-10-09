class User < ApplicationRecord
  has_many :playings, dependent: :restrict_with_exception
  has_many :songs, through: :playings
  has_many :tokens, dependent: :destroy

  attr_accessor :remember_token, :activation_token, :reset_token

  has_secure_password(validations: false)

  before_save :downcase_email
  before_save :remove_spaces_from_furigana

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :furigana, presence: true
  validates :nickname, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false },
            on: :update
  validates :joined,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 1994,
              less_than_or_equal_to: Time.zone.today.year
            }
  validates :url, format: /\A#{URI.regexp(%w[http https])}\z/, allow_blank: true
  validates :password,
            presence: true,
            confirmation: true,
            length: { minimum: 6, maximum: 72 },
            allow_nil: true,
            on: :update
  validates :password_confirmation, presence: true, allow_nil: true, on: :update

  scope :natural_order, -> { order('joined DESC', 'furigana COLLATE "C"') } # TODO: Remove 'COLLATE "C"'
  scope :active, -> { includes(songs: :live).where('lives.date': 1.year.ago..Time.zone.today) }
  scope :joined_years, -> { unscope(:order).order(joined: :desc).distinct.pluck(:joined) }

  def name
    "#{last_name} #{first_name}"
  end

  def handle
    nickname.blank? ? last_name : nickname
  end

  def name_with_handle
    nickname.blank? ? name : "#{name} (#{nickname})"
  end

  def display_name(logged_in)
    logged_in ? name_with_handle : handle
  end

  def elder?
    joined < 2011
  end

  def admin_or_elder?
    admin? || elder?
  end

  def performed_songs
    songs.performed
  end

  def performed_playings
    playings.includes(song: :live).where('lives.date <= ?', Time.zone.today)
  end

  def played?(song)
    song.playings.pluck(:user_id).include?(id)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def remember
    self.remember_token = Token.random
    update_column(:remember_digest, Token.digest(remember_token))
  end

  def forget
    update_column(:remember_digest, nil)
  end

  def activate(password_params)
    update(password_params) && update_columns(activated: true, activated_at: Time.zone.now)
  end

  def deactivate
    update_columns(activated: false, activation_digest: nil)
  end

  def send_invitation(email, inviter)
    self.activation_token = Token.random
    return unless update(email: email, activation_digest: Token.digest(activation_token))
    UserMailer.account_activation(self, inviter).deliver_now
  end

  def send_password_reset
    self.reset_token = Token.random
    update_columns(reset_digest: Token.digest(reset_token), reset_sent_at: Time.zone.now)
    UserMailer.password_reset(self).deliver_now
  end

  def reset_password(password_params)
    update(password_params) && update_column(:reset_digest, nil)
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def valid_token?(token)
    digests = tokens.pluck(:digest)
    digests.any? { |d| BCrypt::Password.new(d).is_password?(token) }
  end

  def destroy_token(token)
    token = tokens.find { |t| BCrypt::Password.new(t.digest).is_password?(token) }
    token&.destroy
  end

  private

  def downcase_email
    self.email = email.downcase unless email.nil?
  end

  def remove_spaces_from_furigana
    self.furigana = furigana.gsub(/\s+/, '')
  end
end
