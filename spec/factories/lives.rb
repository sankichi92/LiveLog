FactoryBot.define do
  factory :live, class: 'Live' do
    date { Faker::Date.unique.between(from: 3.years.ago.to_date, to: Time.zone.today) }
    name do
      case date.month
      when 4..5
        '新歓ライブ'
      when 11
        'NF'
      when 12
        'クリスマスライブ'
      else
        "#{date.month}月ライブ"
      end
    end
    place { name.include?('NF') ? '共北駐輪場' : %w[4共11 4共21 4共31].sample(random: Faker::Config.random) }
    comment { Faker::Boolean.boolean ? Faker::Lorem.paragraph : nil }
    album_url { Faker::Boolean.boolean ? Faker::Internet.url : nil }
    published { true }
    published_at { published ? Time.zone.now : nil }

    trait :invalid do
      name { '' }
    end

    trait :unpublished do
      date { Faker::Date.unique.between(from: Time.zone.today, to: 3.months.from_now.to_date) }
      published { false }
    end

    trait :with_songs do
      after(:create) do |live|
        create_list(:song, 2, live: live)
      end
    end
  end
end
