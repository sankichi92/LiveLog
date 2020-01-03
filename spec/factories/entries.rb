FactoryBot.define do
  factory :entry do
    song
    member
    notes { Faker::Boolean.boolean ? Faker::Lorem.paragraph : nil }
    available_times { build_list(:available_time, Faker::Number.between(from: 1, to: 5)) }
  end

  factory :available_time do
    lower { entry&.song&.live&.date&.beginning_of_day&.iso8601 || 1.month.from_now.beginning_of_day.iso8601 }
    upper { entry&.song&.live&.date&.end_of_day&.iso8601 || 1.month.from_now.end_of_day.iso8601 }
  end
end
