FactoryGirl.define do
  factory :song do
    live
    name 'テーマソング'
    artist 'アンプラグダー'
    sequence(:order) { |n| n }
  end
end
