module SongsHelper
  def button_to_add_member(form)
    fields = form.fields_for(:playings, @song.playings.build) do |builder|
      render 'songs/playings_fields', f: builder
    end
    content_tag :button,
                icon('plus') + ' メンバーを追加する',
                id: 'add-member', type: 'button', class: 'btn btn-light', data: { fields: fields.delete("\n") }
  end

  def youtube_embed(song)
    return unless song.youtube_id?
    content_tag :iframe,
                '',
                class: 'player',
                src: "https://www.youtube.com/embed/#{song.youtube_id}?enablejsapi=1&origin=#{root_url.chop}&rel=0&autoplay=1",
                frameborder: 0,
                allowfullscreen: true
  end

  def status_icon(song)
    if song.open?
      icon 'globe',
           'data-toggle': 'tooltip',
           'data-placement': 'right',
           title: '公開設定: 公開'
    elsif song.secret?
      icon 'lock',
           'data-toggle': 'tooltip',
           'data-placement': 'right',
           title: '公開設定: バンド内'
    end
  end

  def twitter_share_button(song, options)
    uri = URI.parse('https://twitter.com/intent/tweet')
    uri.query = {
      text: "#{song.live_title} - #{song.time_order} #{song.title}",
      url: song_url(song),
      hashtags: '京大アンプラグド',
      via: 'ku_livelog',
      related: 'kyodaiunplugged:京大アンプラグド公式,sankichi92:LiveLog 開発者'
    }.to_query
    options[:target] = '_blank'
    options[:onclick] = "ga('send', 'social', 'Twitter', 'tweet', #{song_url(song)});"
    link_to(icon('twitter') + ' Twitter', uri.to_s, options)
  end

  def link_to_search(name, options = nil, html_options = nil, &block)
    options, html_options = name, options if block_given?
    options = search_songs_path(
      name: options[:name],
      artist: options[:artist],
      instruments: options[:instruments],
      players_lower: options[:players_count],
      players_upper: options[:players_count],
      date_lower: options[:date_range]&.begin,
      date_upper: options[:date_range]&.end,
      user_id: options[:user_id]
    ) + '#results'
    block_given? ? link_to(options, html_options, &block) : link_to(name, options, html_options)
  end
end
