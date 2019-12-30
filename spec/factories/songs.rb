FactoryBot.define do
  factory :song do
    live
    name { Faker::Music.album }
    artist { Faker::Music.band }
    sequence(:position) { |n| live ? live.songs.count + 1 : n + 1 }
    time { live&.nf? && position ? (Time.zone.at(0).change(hour: 10) + (position * 10).minutes).strftime('%R') : nil }
    status { %i[open closed secret].sample(random: Faker::Config.random) }
    youtube_id { Faker::Boolean.boolean ? 'https://www.youtube.com/watch?v=2TL90rxt9bo' : nil }
    comment { Faker::Boolean.boolean(true_ratio: 0.2) ? Faker::Lorem.paragraph : nil }
    audio { Faker::Boolean.boolean ? Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/files/audio.mp3", 'audio/mpeg') : nil }

    trait :invalid do
      name { '' }
    end

    trait :draft do
      association :live, factory: %i[live unpublished]
      position { nil }
      youtube_id { nil }
      comment { nil }
      audio { nil }
    end

    transient do
      members { [] }
    end

    after(:create) do |song, evaluator|
      evaluator.members.each do |member|
        create(:playing, song: song, member: member)
      end
      song.reload
    end
  end
end
