FactoryGirl.define do
  factory :live, class: 'Live' do
    name 'テストライブ'
    sequence(:date) { |n| Date.new(2000) + n.month }
    place '4共21'
    album_url 'https://goo.gl/photos/o94hbpFHQtcjzjwj6'
  end

  factory :future_live, class: 'Live' do
    name '次のライブ'
    sequence(:date) { |n| Date.new(2100) + n.month}
    place '4共31'
    album_url 'https://gooogle/photos/p05icrGIRudkakx7'
  end
end
