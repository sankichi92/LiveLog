FactoryBot.define do
  factory :member do
    joined_year { Faker::Number.within(range: 3.years.ago.year..Time.zone.today.year) }
    name { Faker::Name.unique.last_name }
    url { Faker::Boolean.boolean(true_ratio: 0.2) ? Faker::Internet.url : nil }
    bio { Faker::Boolean.boolean ? Faker::Lorem.sentence : nil }

    trait :with_user do
      user
    end

    transient do
      songs { [] }
    end

    after(:create) do |member, evaluator|
      evaluator.songs.each do |song|
        create(:play, song: song, user: member)
      end
    end
  end

  factory :avatar do
    member
    cloudinary_id { "avatar/#{member.id}" }
  end
end
