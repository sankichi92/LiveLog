FactoryBot.define do
  factory :user do
    last_name '京大'
    first_name 'アンプラ太郎'
    furigana 'きょうだいあんぷらたろう'
    sequence(:email) { |n| "livelog_#{n}@ku-unplugged.net" }
    joined Time.current.year
    password 'foobar'
    password_confirmation 'foobar'
    activated true
    activated_at Time.zone.now
    public false
    subscribing true

    trait :invalid do
      furigana 'キョウダイアンプラタロウ'
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
