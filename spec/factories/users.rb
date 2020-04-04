FactoryBot.define do
  factory :user do
    member
    email { Faker::Internet.unique.email }

    access_token { 'access_token' }
    access_token_expires_at { 1.day.from_now }
    refresh_token { 'refresh_token' }
    userinfo { {} }

    activated { true }

    trait :inactivated do
      access_token { nil }
      access_token_expires_at { nil }
      refresh_token { nil }
      userinfo { nil }

      activated { false }
    end

    trait :graduate do
      association :member, factory: :member, joined_year: Time.zone.today.nendo - 4
    end

    factory :admin do
      admin { true }
    end
  end
end
