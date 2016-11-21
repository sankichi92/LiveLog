FactoryGirl.define do
  factory :user do
    last_name '京大'
    first_name 'アンプラ太郎'
    furigana 'きょうだいあんぷらたろう'
    sequence(:email) { |n| "livelog_#{n}@ku-unplugged.net" }
    joined 2010
    password 'foobar'
    password_confirmation 'foobar'
    activated true
    activated_at Time.zone.now

    factory :admin do
      admin true
    end
  end
end
