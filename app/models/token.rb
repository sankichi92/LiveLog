class Token < ApplicationRecord
  belongs_to :user

  attr_accessor :token

  before_create :create_token

  def self.digest(string)
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost: cost)
  end

  def self.random(urlsafe: true)
    urlsafe ? SecureRandom.urlsafe_base64 : SecureRandom.base64
  end

  private

  def create_token
    self.token = Token.random(urlsafe: false)
    self.digest = Token.digest(token)
  end
end
