# frozen_string_literal: true

FactoryBot.define do
  factory :admin, class: 'Administrator' do
    user
  end
end
