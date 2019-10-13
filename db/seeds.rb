return $stdout.puts 'Records already exist.' if User.exists?

Faker::Config.random = Random.new(42)

admin = FactoryBot.create(
  :admin,
  last_name: '開発',
  first_name: '管理者',
  email: 'admin@dev.ku-unplugged.net',
  password: 'password',
)

non_admin = FactoryBot.create(
  :user,
  last_name: '開発',
  first_name: 'ユーザー',
  email: 'user@dev.ku-unplugged.net',
  password: 'password',
)

users = [admin, non_admin] + FactoryBot.create_list(:user, 20)

FactoryBot.create_list(:live, 20).each do |live|
  song_count = live.nf? ? 30 : 10
  FactoryBot.create_list(:song, song_count, live: live).each do |song|
    playing_count = Faker::Number.normal(mean: 5, standard_deviation: 2).round
    users.sample(playing_count.abs, random: Faker::Config.random).each do |user|
      FactoryBot.create(:playing, song: song, user: user)
    end
  end
end

FactoryBot.create(:live, :draft).tap do |live|
  FactoryBot.create_list(:song, 5, live: live).each do |song|
    playing_count = Faker::Number.normal(mean: 5, standard_deviation: 2).round
    users.sample(playing_count.abs, random: Faker::Config.random).each do |user|
      FactoryBot.create(:playing, song: song, user: user)
    end
  end
end
