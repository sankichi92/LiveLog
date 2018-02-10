Faker::Config.random = Random.new(42)

User.create!(last_name: '京大',
             first_name: 'アンプラ太郎',
             furigana: 'きょうだいあんぷらたろう',
             email: 'admin@livelog.ku-unplugged.net',
             joined: 1.year.ago.year,
             password: 'foobar',
             password_confirmation: 'foobar',
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  activated = Faker::Boolean.boolean(0.9)
  public = activated ? Faker::Boolean.boolean(0.2) : false
  User.create!(first_name: first_name,
               last_name: last_name,
               furigana: last_name + first_name,
               email: activated ? Faker::Internet.email : nil,
               joined: Faker::Date.between(4.years.ago, Time.zone.today).year,
               password: 'password',
               password_confirmation: 'password',
               activated: activated,
               activated_at: activated ? Time.zone.now : nil,
               public: public,
               url: public ? Faker::Internet.url : nil,
               intro: public ? Faker::Lorem.sentence : nil)
end

20.times do
  date = Faker::Date.unique.between(4.years.ago, Time.zone.today)
  month = date.mon
  live_name = case month
              when 4..5
                '新歓ライブ'
              when 11
                'NF'
              when 12
                'クリスマスライブ'
              else
                "#{month}月ライブ"
              end
  place = live_name.include?('NF') ? '共北駐輪場' : %w[4共11 4共21 4共31].sample
  live = Live.create!(name: live_name, date: date, place: place, published: true, published_at: date)

  song_count = live_name.include?('NF') ? 30 : 10
  song_count.times do |n|
    name, artist = if Faker::Boolean.boolean
                     [Faker::BossaNova.song, Faker::BossaNova.artist]
                   else
                     [Faker::UmphreysMcgee.song, Faker::RockBand.name]
                   end
    time = Time.zone.parse('10:00') + ((n / 3) * 30).minutes if live_name.include?('NF')
    song = live.songs.create!(name: name, artist: artist, order: n + 1, time: time, status: Faker::Number.between(0, 2))

    Faker::Number.normal(5, 2).to_i.times do
      random = Faker::Number.unique.between(0, User.count - 1)
      song.playings.create!(user: User.offset(random).first,
                            inst: %w[Vo Vo Vo Gt Gt Gt Pf Pf Ba Ba Cj Cj Vn Fl Perc Gt&Vo Pf&Cho].sample)
    end
    Faker::Number.unique.clear
  end
end
