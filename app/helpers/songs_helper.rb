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
    embed_uri = URI.parse("https://www.youtube.com/embed/#{song.youtube_id}")
    embed_uri.query = { enablejsapi: 1, origin: root_url.chop, rel: 0, autoplay: 1 }.to_query
    content_tag :iframe,
                '',
                id: "player-#{song.id}",
                src: embed_uri,
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

  def original_icon
    icon('check-circle', 'data-toggle': 'tooltip', 'data-placement': 'right', title: 'オリジナル曲')
  end

  def link_to_song(song)
    song.watchable?(current_user) ? link_to(song.name, song) : song.name
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
