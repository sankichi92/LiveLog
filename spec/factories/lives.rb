FactoryBot.define do
  factory :live, class: 'Live' do
    sequence(:date) { |n| n.month.ago }
    name { "#{date.mon}月ライブ" }
    place { %w[4共11 4共21 4共31].sample }
    album_url { Faker::Internet.url }
    published { true }
    published_at { Time.zone.now }

    trait :invalid do
      name { '' }
    end

    trait :draft do
      sequence(:date) { |n| n.month.from_now }
      published { false }
      published_at { nil }
    end

    trait :with_songs do
      after(:create) do |live|
        create_list(:song, 2, live: live)
      end
    end
  end
end
