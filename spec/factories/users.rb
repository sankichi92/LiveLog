FactoryBot.define do
  factory :user do
    member
    activated { true }
    email { Faker::Internet.unique.email }
    subscribing { Faker::Boolean.boolean(true_ratio: 0.8) }

    trait :inactivated do
      activated { false }
    end

    factory :admin do
      admin { true }
    end
  end
end
