module SongDecorator
  def time_and_position
    time.present? ? "#{time_str} #{position}" : position
  end

  def youtube_playable?
    youtube_id.present? && media_playable?
  end

  def audio_playable?
    audio.attached? && media_playable?
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
                src: "https://www.youtube.com/embed/#{youtube_id}?enablejsapi=1&origin=#{root_url.chop}&rel=0&autoplay=1",
                frameborder: 0,
                allowfullscreen: true
  end

  def title_with_original
    if original?
      safe_join [title, content_tag(:small, '（オリジナル曲）')]
    else
      title
    end
  end

  def status_icon
    if open?
      icon 'fas', 'globe', title: '公開設定: 公開', data: { toggle: 'tooltip', placement: 'right', controller: 'tooltip' }
    elsif secret?
      icon 'fas', 'lock', title: '公開設定: バンド内', data: { toggle: 'tooltip', placement: 'right', controller: 'tooltip' }
    end
  end

  def twitter_share_link(html_options)
    uri = URI.parse('https://twitter.com/intent/tweet')
    uri.query = {
      text: "#{live.title} #{time_and_position} #{title}",
      url: song_url(self),
      hashtags: '京大アンプラグド',
      via: 'ku_livelog',
      related: 'kyodaiunplugged:京大アンプラグド公式,sankichi92:LiveLog 開発者',
    }.to_query
    link_to icon('fab', 'twitter', 'ツイート'), uri.to_s, html_options.merge(target: '_blank')
  end

  private

  def media_playable?
    open? || closed? && current_user || player?(current_user&.member)
  end
end
