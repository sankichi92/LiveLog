module SongDecorator
  def time_and_position
    time.present? ? "#{time_str} #{position}" : position
  end

  def playable?
    policy(self).play? && audio.attached?
  end

  def audio_url
    url_for audio
  end

  def youtube_thumbnail(quality = 'mqdefault')
    "https://i.ytimg.com/vi/#{youtube_id}/#{quality}.jpg" if youtube_id.present?
  end

  def youtube_embed
    return unless youtube_id?
    content_tag :iframe, '',
                id: 'youtube-player',
                data: { song_id: id },
                src: "https://www.youtube.com/embed/#{youtube_id}?enablejsapi=1&origin=#{root_url.chop}&rel=0&autoplay=1",
                frameborder: 0,
                allowfullscreen: true
  end

  def status_icon
    if open?
      icon 'fas', 'globe', 'data-toggle': 'tooltip', 'data-placement': 'right', title: '公開設定: 公開'
    elsif secret?
      icon 'fas', 'lock', 'data-toggle': 'tooltip', 'data-placement': 'right', title: '公開設定: バンド内'
    end
  end

  def previous
    live.songs.played_order.where('songs.time < ? or songs.position < ?', time, position).last
  end

  def next
    live.songs.played_order.where('songs.time > ? or songs.position > ?', time, position).first
  end

  def edit_link(html_options)
    link_to_edit edit_song_path(self), html_options
  end

  def delete_link(html_options)
    link_to_delete self, html_options.merge(data: { confirm: '本当に削除しますか？' })
  end

  def twitter_share_button(html_options)
    uri = URI.parse('https://twitter.com/intent/tweet')
    uri.query = {
      text: "#{live.title} #{time_and_position} #{title}",
      url: song_url(self),
      hashtags: '京大アンプラグド',
      via: 'ku_livelog',
      related: 'kyodaiunplugged:京大アンプラグド公式,sankichi92:LiveLog 開発者',
    }.to_query
    html_options[:class] = html_options[:class].nil? ? 'twitter-share' : html_options[:class] + ' twitter-share'
    link_to(icon('fab', 'twitter') + ' Twitter', uri.to_s, html_options.merge(target: '_blank', data: { content_type: 'song', content_id: id }))
  end

  def facebook_share_button(html_options)
    html_options[:class] = html_options[:class].nil? ? 'fb-share' : html_options[:class] + ' fb-share'
    button_tag icon('fab', 'facebook') + ' Facebook', html_options.merge(data: { url: song_url(self), content_type: 'song', content_id: id }, type: 'button')
  end
end
