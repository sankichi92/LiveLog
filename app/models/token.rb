class Token
  def self.random(urlsafe: true)
    urlsafe ? SecureRandom.urlsafe_base64 : SecureRandom.base64
  end
end
