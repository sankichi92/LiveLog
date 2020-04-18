FactoryBot.define do
  factory :client do
    developer
    sequence(:auth0_id) { |n| "auth0_client_id_#{n}" }
    name { Faker::App.name }
    app_type { Client::APP_TYPES.sample(random: Faker::Config.random) }
    url { Faker::Boolean.boolean ? Faker::Internet.url : nil }
    sequence(:livelog_grant_id) { |n| "auth0_grant_id_#{n}" }
  end
end
