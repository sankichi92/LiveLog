FactoryGirl.define do
  factory :song do
    live
    name 'テーマソング'
    artist 'アンプラグダー'
    sequence(:order) { |n| n }
    status :closed
    youtube_id 'https://www.youtube.com/watch?v=2TL90rxt9bo'
    comment 'アンプラグドのテーマソングです'
  end

  factory :playing do
    user
    song
  end
end
