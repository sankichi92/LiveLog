class Token
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
end
