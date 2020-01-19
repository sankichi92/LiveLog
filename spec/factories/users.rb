FactoryBot.define do
  factory :user do
    member
    activated { true }

    trait :inactivated do
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
