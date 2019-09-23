FactoryBot.define do
  factory :user do
    last_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    furigana { 'ふりがな' }
    nickname { Faker::Boolean.boolean(true_ratio: 0.2) ? Faker::Games::Pokemon.name : nil }
    email { Faker::Internet.unique.email }
    joined { Faker::Number.within(range: 3.years.ago.year..Time.zone.today.year) }
    password { Faker::Internet.password }
    password_confirmation { password }
    activated { true }
    activated_at { activated ? Faker::Time.between(from: Time.zone.local(joined), to: Time.zone.now) : nil }
    public { Faker::Boolean.boolean }
    subscribing { Faker::Boolean.boolean(true_ratio: 0.8) }
    url { Faker::Boolean.boolean(true_ratio: 0.2) ? Faker::Internet.url : nil }
    intro { Faker::Boolean.boolean ? Faker::Lorem.sentence : nil }

    trait :invalid do
      furigana { 'フリガナ' }
    end

    trait :inactivated do
      email { nil }
      password { nil }
      activated { false }
    end

    trait :elder do
      joined { 2010 }
    end

    transient do
      songs { [] }
    end

    after(:create) do |user, evaluator|
      evaluator.songs.each do |song|
        create(:playing, song: song, user: user)
      end
    end

    factory :admin do
      admin { true }
    end
  end
end
