FactoryGirl.define do
  factory :song do
    live
    name 'テーマソング'
    artist 'アンプラグダー'
    sequence(:order) { |n| n }
    status :closed
    youtube_id 'https://www.youtube.com/watch?v=2TL90rxt9bo'
    comment 'アンプラグドのテーマソングです'

    transient do
      user nil
    end

    after(:create) do |song, evaluator|
      create(:playing, song: song, user: evaluator.user) if evaluator.user
    end
  end

  factory :draft_song, parent: :song do
    association :live, factory: :draft_live
    order nil
    youtube_id nil
    comment nil
  end

  factory :playing do
    user
    song
  end
end
