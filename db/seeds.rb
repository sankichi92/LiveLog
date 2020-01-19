return $stdout.puts 'Records already exist.' if User.exists?

Faker::Config.random = Random.new(42)

admin = FactoryBot.create(:admin, id: 1)
non_admin = FactoryBot.create(:user, id: 2)

if ENV['AUTH0_CLIENT_ID'].present? && ENV['AUTH0_CLIENT_SECRET'].present?
  [[admin, 'admin@example.com'], [non_admin, 'user@example.com']].each do |user, email|
    Auth0User.fetch!(user.auth0_id)
  rescue Auth0::NotFound
    user.assign_attributes(email: email, password: 'password')
    Auth0User.create!(user)
  end
end

members = [admin.member, non_admin.member] + FactoryBot.create_list(:member, 18)

FactoryBot.create_list(:live, 10).each do |live|
  song_count = live.nf? ? 30 : 10
  FactoryBot.create_list(:song, song_count, live: live).each do |song|
    play_count = Faker::Number.normal(mean: 5, standard_deviation: 2).round
    members.sample(play_count.abs, random: Faker::Config.random).each do |member|
      FactoryBot.create(:play, song: song, member: member)
    end
  end
end

FactoryBot.create(:live, :unpublished, date: Time.zone.today.change(month: 11)).tap do |live|
  FactoryBot.create_list(:song, 50, :unpublished, live: live).each do |song|
    FactoryBot.create(:entry, song: song, member: [admin, non_admin].sample(random: Faker::Config.random).member)

    play_count = Faker::Number.normal(mean: 5, standard_deviation: 2).round
    members.sample(play_count.abs, random: Faker::Config.random).each do |member|
      FactoryBot.create(:play, song: song, member: member)
    end
  end
end
