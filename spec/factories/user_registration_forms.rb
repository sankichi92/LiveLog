# frozen_string_literal: true

FactoryBot.define do
  factory :user_registration_form do
    admin
    active_days { [1, 7, 30].sample(random: Faker::Config.random) }

    trait :expired do
      expires_at { 1.minute.ago }
    end
  end
end
