if Rails.env.production?
  ActiveModel::SecurePassword.min_cost = false
  BCrypt::Engine.cost = BCrypt::Engine::DEFAULT_COST
else
  ActiveModel::SecurePassword.min_cost = true
  BCrypt::Engine.cost = BCrypt::Engine::MIN_COST
end
