FactoryGirl.define do
  factory :live, class: 'Live' do
    name 'テストライブ'
    sequence(:date) { |n| Date.new(2000) + n.month }
    place '4共21'
  end
end
