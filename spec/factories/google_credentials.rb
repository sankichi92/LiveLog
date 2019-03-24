FactoryBot.define do
  factory :google_credential do
    user
    token { 'TOKEN' }
    refresh_token { 'REFRESH_TOKEN' }
    expires_at { 1.hour.from_now }
  end
end
