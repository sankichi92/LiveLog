FactoryBot.define do
  factory :song do
    live
    name { Faker::UmphreysMcgee.song }
    artist { Faker::RockBand.name }
    sequence(:order) { |n| n }
    status { %i[open closed secret].sample }
    youtube_id { 'https://www.youtube.com/watch?v=2TL90rxt9bo' }
    comment { Faker::Lorem.paragraph }
    audio { Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/files/audio.mp3", 'audio/mpeg') }

    trait :invalid do
      name { '' }
    end

    trait :draft do
      association :live, factory: %i[live draft]
      order { nil }
      youtube_id { nil }
      comment { nil }
      audio { nil }
    end

    transient do
      users { [] }
    end

    after(:create) do |song, evaluator|
      evaluator.users.each do |user|
        create(:playing, song: song, user: user)
      end
      song.reload
    end
  end

  factory :playing do
    user
    song
    inst { %w[Gt Vo Cj Ba Pf Gt&Vo Vn Gt&Cho Pf&Cho Fl].sample }
  end
end
