FactoryBot.define do
  factory :live, class: 'Live' do
    sequence(:date) { |n| n.month.ago }
    name { "#{date.mon}月ライブ" }
    place '4共21'
    album_url 'https://goo.gl/photos/o94hbpFHQtcjzjwj6'
    published true
    published_at Time.zone.now

    trait :invalid do
      name ''
    end

    trait :draft do
      sequence(:date) { |n| n.month.from_now }
      published false
      published_at nil
    end

    trait :with_songs do
      after(:create) do |live|
        create_list(:song, 2, live: live)
      end
    end
  end
end
