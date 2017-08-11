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

  private

  def create_token
    self.token = SecureRandom.base64
    self.digest = Token.digest(token)
  end
end
