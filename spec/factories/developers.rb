# frozen_string_literal: true

FactoryBot.define do
  factory :developer do
    user
    sequence(:github_id)
    github_username { Faker::Internet.unique.username }
    github_access_token { 'github_access_token' }
  end
end
