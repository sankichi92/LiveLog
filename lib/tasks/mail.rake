namespace :mail do
  desc "Send an email to users who performed today's pickup song"
  task :pickup_song do
    SongMailer.pickup_song.deliver_later
  end
end
