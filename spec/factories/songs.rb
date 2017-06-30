FactoryGirl.define do
  factory :song do
    live
    name 'テーマソング'
    artist 'アンプラグダー'
    sequence(:order) { |n| n }
    status :closed
    youtube_id 'https://www.youtube.com/watch?v=7LBUEYGfisQ'
  end

  factory :playing do
    user
    song
  end
end
