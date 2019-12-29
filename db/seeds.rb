return $stdout.puts 'Records already exist.' if User.exists?

Faker::Config.random = Random.new(42)

admin = FactoryBot.create(:admin)
non_admin = FactoryBot.create(:user)

if ENV['AUTH0_CLIENT_ID'].present? && ENV['AUTH0_CLIENT_SECRET'].present?
  admin.assign_attributes(email: 'admin@example.com', password: 'password')
  Auth0User.create!(admin)
  non_admin.assign_attributes(email: 'user@example.com', password: 'password')
  Auth0User.create!(non_admin)
end

members = [admin.member, non_admin.member] + FactoryBot.create_list(:member, 18)

FactoryBot.create_list(:live, 10).each do |live|
  song_count = live.nf? ? 30 : 10
  FactoryBot.create_list(:song, song_count, live: live).each do |song|
    playing_count = Faker::Number.normal(mean: 5, standard_deviation: 2).round
    members.sample(playing_count.abs, random: Faker::Config.random).each do |member|
      FactoryBot.create(:playing, song: song, member: member)
    end
  end
end

FactoryBot.create(:live, :unpublished).tap do |live|
  FactoryBot.create_list(:song, 5, live: live).each do |song|
    playing_count = Faker::Number.normal(mean: 5, standard_deviation: 2).round
    members.sample(playing_count.abs, random: Faker::Config.random).each do |member|
      FactoryBot.create(:playing, song: song, member: member)
    end
  end
end
