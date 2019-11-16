FactoryBot.define do
  factory :member do
    joined_year { Faker::Number.within(range: 3.years.ago.year..Time.zone.today.year) }
    last_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    furigana { 'ふりがな' }
    nickname { Faker::Boolean.boolean(true_ratio: 0.2) ? Faker::Games::Pokemon.name : nil }
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
        create(:playing, song: song, user: member)
      end
    end
  end
end
