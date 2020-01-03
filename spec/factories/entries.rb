FactoryBot.define do
  factory :entry do
    song
    member
    notes { Faker::Boolean.boolean ? Faker::Lorem.paragraph : nil }
  end
end
