FactoryBot.define do
  factory :user do
    member
    activated { true }

    trait :inactivated do
      activated { false }
    end

    factory :admin do
      admin { true }
    end
  end
end
