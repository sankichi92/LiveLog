FactoryBot.define do
  factory :invitation do
    member
    association :inviter, factory: :user
    email { Faker::Internet.email }
  end
end
