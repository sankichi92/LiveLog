module LiveDecorator
  def at_place
    place.present? ? "@#{place}" : ''
  end

  def date_and_place
    "#{l date} #{at_place}"
  end

  def edit_link(html_options)
    link_to_edit edit_live_path(self), html_options
  end

  def delete_link(html_options)
    link_to_delete self, html_options
  end

  def new_song_link(html_options)
    link_to icon('fas', 'plus-circle') + ' ' + t('views.lives.add_song'), new_song_path(live_id: id), html_options
  end

  def new_entry_link(html_options)
    link_to icon('fas', 'paper-plane') + ' ' + t('views.lives.entry'), new_live_entry_path(self), html_options
  end

  def publish_link(html_options)
    link_to t('views.lives.publish'), publish_live_path(self), html_options.merge(method: :put)
  end

  def link_to_album(html_options)
    link_to icon('fas', 'images') + ' ' + t('views.lives.album'), album_url, html_options
  end
end
