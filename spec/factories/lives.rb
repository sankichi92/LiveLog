FactoryGirl.define do
  factory :live, class: 'Live' do
    sequence(:date) { |n| n.month.ago }
    name { "#{date.mon}月ライブ" }
    place '4共21'
    album_url 'https://goo.gl/photos/o94hbpFHQtcjzjwj6'

    factory :draft_live do
      sequence(:date) { |n| n.month.from_now }
    end
  end
end
