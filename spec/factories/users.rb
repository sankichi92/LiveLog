FactoryGirl.define do
  factory :user do
    first_name '京大'
    last_name 'アンプラ太郎'
    furigana 'きょうだいあんぷらたろう'
    nickname 'アンプラ'
    email 'livelog@ku-unplugged.net'
    joined 2011
    password 'foobar'
    password_confirmation 'foobar'
  end
end
