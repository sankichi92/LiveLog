module UserDecorator
  def display_name
    logged_in? ? name_with_handle : handle
  end

  def inst_to_count
    playings.published.count_insts
  end

  def related_playings
    Playing.where(song_id: songs.published.pluck('songs.id'))
  end

  def collaborator_to_count
    related_playings.where.not(user_id: id).group(:user).order(count: :desc).count
  end

  def formation_to_count
    related_playings.count_formations
  end

  def delete_link(html_options)
    link_to_delete self, html_options.merge(data: { confirm: t('views.application.delete_confirm') })
  end
end
