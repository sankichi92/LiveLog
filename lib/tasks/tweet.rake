namespace :tweet do
  desc "Tweet today's pickup song"
  task :pickup_song do
    song = Song.pickup
    time_order  = song.time.present? ? "#{song.time.strftime('%R')} #{song.order}" : song.order
    title       = '今日のピックアップ！'
    content     = "#{song.live_title} #{time_order} #{song.title}"
    url         = Rails.application.routes.url_helpers.song_url(song, host: 'livelog.ku-unplugged.net')
    TweetJob.perform_now("#{title}\n#{content}\n#{url}")
  end
end
