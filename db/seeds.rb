# frozen_string_literal: true

Faker::Config.random = Random.new(42)

admin = nil
non_admin = nil

ApplicationRecord.transaction do
  admin = FactoryBot.create(:user, auth0_id: 'auth0|1', email: 'admin@example.com').tap do |user|
    FactoryBot.create(:admin, user: user, scopes: Administrator::SCOPES)
  end
  non_admin = FactoryBot.create(:user, auth0_id: 'auth0|2', email: 'user@example.com')

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

  FactoryBot.create(:live, :unpublished, :with_entry_guideline, date: Time.zone.today.change(month: 11)).tap do |live|
    FactoryBot.create_list(:song, 50, :for_entry, live: live).each do |song|
      FactoryBot.create(:entry, song: song, member: [admin, non_admin].sample(random: Faker::Config.random).member)

      play_count = Faker::Number.normal(mean: 5, standard_deviation: 2).round
      members.sample(play_count.abs, random: Faker::Config.random).each do |member|
        FactoryBot.create(:play, song: song, member: member)
      end
    end
  end
end

if ENV['AUTH0_CLIENT_ID'] && ENV['AUTH0_CLIENT_SECRET']
  [admin, non_admin].each do |user|
    Auth0User.fetch!(user.auth0_id)
  rescue Auth0::NotFound
    Auth0User.create!(user, password: 'password')
  end
end
