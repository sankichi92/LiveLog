FactoryBot.define do
  factory :song do
    live
    sequence(:name) { |n| "テーマソング #{n}" }
    artist 'アンプラグダー'
    sequence(:order) { |n| n }
    status :closed
    youtube_id 'https://www.youtube.com/watch?v=2TL90rxt9bo'
    comment 'アンプラグドのテーマソングです'

    trait :invalid do
      name ''
    end

    transient do
      users []
    end

    after(:create) do |song, evaluator|
      evaluator.users.each do |user|
        create(:playing, song: song, user: user)
      end
      song.reload
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
    inst %w[Gt Vo Cj Ba Pf Gt&Vo Vn Gt&Cho Pf&Cho Fl].sample
  end
end
