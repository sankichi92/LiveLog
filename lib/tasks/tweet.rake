namespace :tweet do
  desc "Tweet today's pickup song"
  task :pickup_song do
    song = Song.pickup
    title   = '今日のピックアップ！'
    content = "#{song.live_title} #{song.time_order} #{song.title}"
    url     = Rails.application.routes.url_helpers.song_url(song, host: 'livelog.ku-unplugged.net')
    TwitterClient.new.update("#{title}\n#{content}\n#{url}")
  end
end
