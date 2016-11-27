FactoryGirl.define do
  factory :song do
    live
    name 'テーマソング'
    artist 'アンプラグダー'
    sequence(:order) { |n| n }
    status :closed
  end

  factory :playing do
    user
    song
  end
end
