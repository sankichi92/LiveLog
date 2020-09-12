# frozen_string_literal: true

FactoryBot.define do
  factory :entry do
    association :song, factory: %i[song for_entry]
    member
    notes { Faker::Boolean.boolean ? Faker::Lorem.paragraph : nil }

    transient do
      playable_times_count { Faker::Number.between(from: 1, to: 5) }
    end

    after(:build) do |entry, evaluator|
      entry.playable_times = build_list(:playable_time, evaluator.playable_times_count, entry: entry) if entry.playable_times.empty?
    end
  end

  factory :playable_time do
    entry
    lower { Faker::Time.between_dates(from: entry.song.live.date, to: entry.song.live.date, period: entry.song.live.nf? ? :day : :night).beginning_of_minute }
    upper { Faker::Time.between(from: lower + 1.minute, to: lower + 6.hours).beginning_of_minute }
  end
end
