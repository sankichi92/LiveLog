# frozen_string_literal: true

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

    trait :unpublished do
      date { Faker::Date.unique.between(from: Time.zone.today, to: 3.months.from_now.to_date) }
      published { false }
    end

    trait :with_entry_guideline do
      after(:create) do |live|
        create(:entry_guideline, live:)
      end
    end

    trait :with_songs do
      after(:create) do |live|
        create_pair(:song, live:)
      end
    end

    trait :with_entries do
      after(:create) do |live|
        create_pair(:song, live:).each do |song|
          create(:entry, song:)
        end
      end
    end
  end

  factory :entry_guideline do
    live factory: %i[live unpublished]
    deadline { Faker::Time.between(from: 1.minute.from_now, to: live.date.end_of_day) }
    notes { Faker::Boolean.boolean(true_ratio: 0.9) ? Faker::Lorem.paragraph : nil }
  end
end
