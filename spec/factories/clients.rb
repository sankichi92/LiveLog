FactoryBot.define do
  factory :client do
    developer
    sequence(:auth0_id) { |n| "auth0_client_id_#{n}" }
    name { Faker::App.name }
    description { Faker::Boolean.boolean ? Faker::Lorem.sentence : nil }
    logo_url { 'https://avatars2.githubusercontent.com/u/9409721?v=4' }
    url { Faker::Boolean.boolean ? Faker::Internet.url : nil }
    sequence(:livelog_grant_id) { |n| "auth0_grant_id_#{n}" }

    app_type { Client::APP_TYPES.sample(random: Faker::Config.random) }
    jwt_signature_alg { auth0_id.present? ? Client::JWT_SIGNATURE_ALGORITHMS.sample(random: Faker::Config.random) : nil }
  end
end
