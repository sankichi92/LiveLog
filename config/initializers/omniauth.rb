Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           Rails.application.credentials.dig(:google_oauth2, :client_id),
           Rails.application.credentials.dig(:google_oauth2, :client_secret)
end
