# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
users_info = [
  { last_name: 'ライブログ', first_name: '管理者', furigana: 'らいぶろぐかんりしゃ', email: 'admin@example.com', password: 'pass', joined: 2017, activated: true, admin:true},
  { last_name: '京大', first_name: '太郎', furigana: 'きょうだいたろう', email: 'taro@example.com', password: 'pass', joined: 2017, activated: true, },
  { last_name: '一条', first_name: '花子', furigana: 'いちじょうはなこ', email: 'hanako@example.com', password: 'pass', joined: 2016, activated: true },
  { last_name: '二条', first_name: '次郎', furigana: 'にじょうじろう', email: 'jiro@komon.com', password: 'pass', joined: 2016, activated: true },
  { last_name: '三条', first_name: '良子', furigana: 'さんじょうりょうこ', email: 'ryoko@komon.com', password: 'pass', joined: 2017, activated: true },
  { last_name: '四条', first_name: '静香', furigana: 'しじょうしずか', email: 'shizuka@example.com', password: 'pass', joined: 2015, activated: true }
]

if Rails.env.development?
  users_info.each do |user_info|
    user = User.create(user_info)
  end
  user.save
end