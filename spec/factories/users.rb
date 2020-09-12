# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    member
    email { Faker::Internet.unique.email }
    activated { true }

    trait :inactivated do
      activated { false }
    end

    trait :graduate do
      association :member, factory: :member, joined_year: Time.zone.today.nendo - 4
    end
  end

  factory :auth0_credential do
    user
    access_token { 'access_token' }
    refresh_token { 'refresh_token' }
    expires_at { 1.day.from_now }
  end
end
