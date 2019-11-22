FactoryBot.define do
  factory :user do
    member
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
    password_confirmation { password }
    subscribing { Faker::Boolean.boolean(true_ratio: 0.8) }

    factory :admin do
      admin { true }
    end
  end
end
