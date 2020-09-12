# frozen_string_literal: true

namespace :mail do
  desc "Send an email to users who performed today's pickup song"
  task pickup_song: :environment do
    SongMailer.pickup.deliver_now
  end
end
