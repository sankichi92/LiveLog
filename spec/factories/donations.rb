# frozen_string_literal: true

FactoryBot.define do
  factory :donation do
    member
    amount { 1000 }
    donated_on { Time.zone.today }

    trait :expired do
      donated_on { 2.years.ago.to_date }
    end
  end
end
