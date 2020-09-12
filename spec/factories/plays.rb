# frozen_string_literal: true

FactoryBot.define do
  factory :play do
    member
    song
    instrument { %w[Vo Vo Vo Gt Gt Gt Pf Pf Ba Ba Cj Cj Vn Fl Perc Gt&Vo Pf&Cho].sample(random: Faker::Config.random) }
  end
end
