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
    subscribing true

    trait :elder do
      joined 2010
    end

    factory :admin do
      admin true
    end
  end

  factory :token do
    user
  end
end
