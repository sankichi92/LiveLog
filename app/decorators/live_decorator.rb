module LiveDecorator
  def at_place
    place.present? ? "@#{place}" : ''
  end

  def date_and_place
    "#{l date} #{at_place}"
  end

  def new_song_link(html_options)
    link_to icon('fas', 'plus-circle') + ' ' + '曲を追加する', new_song_path(live_id: id), html_options
  end

  def link_to_album(html_options)
    link_to icon('fas', 'images') + ' ' + 'アルバムへ', album_url, html_options
  end
end
