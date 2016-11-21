FactoryGirl.define do
  factory :user do
    last_name '京大'
    first_name 'アンプラ太郎'
    furigana 'きょうだいあんぷらたろう'
    nickname 'アンプラ'
    email 'livelog@ku-unplugged.net'
    joined 2010
    password 'foobar'
    password_confirmation 'foobar'
  end
end
