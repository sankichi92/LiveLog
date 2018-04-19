FactoryBot.define do
  factory :user do
    last_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    furigana 'ふりがな'
    email { Faker::Internet.email }
    joined { Faker::Date.between(Date.new(2011), Time.zone.today).year }
    password 'foobar'
    password_confirmation 'foobar'
    activated true
    activated_at Time.zone.now
    public false
    subscribing true
    url { Faker::Internet.url }
    intro { Faker::Lorem.sentence }
    avatar nil

    trait :invalid do
      furigana 'フリガナ'
    end

    trait :inactivated do
      email nil
      password nil
      password_confirmation nil
      activated false
      activated_at nil
    end

    trait :elder do
      joined 2010
    end

    transient do
      songs []
    end

    after(:create) do |user, evaluator|
      evaluator.songs.each do |song|
        create(:playing, song: song, user: user)
      end
      user.reload
    end

    factory :admin do
      admin true
    end
  end

  factory :token do
    user
  end
end
