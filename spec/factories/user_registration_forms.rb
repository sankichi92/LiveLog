FactoryBot.define do
  factory :user_registration_form do
    admin
    active_days { [1, 7, 30].sample(random: Faker::Config.random) }
  end
end
