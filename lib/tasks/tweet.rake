# frozen_string_literal: true

namespace :tweet do
  desc "Tweet today's pickup song"
  task pickup_song: :environment do
    song = Song.pickup
    time_and_position = song.time.present? ? "#{song.time.strftime('%R')} #{song.position}" : song.position
    title = '今日のピックアップ！'
    content = "#{song.live.title} #{time_and_position} #{song.title}"
    url = Rails.application.routes.url_helpers.song_url(song, host: 'livelog.ku-unplugged.net')
    Rails.configuration.x.twitter_client.tweet("#{title}\n#{content}\n#{url}")
  end
end
