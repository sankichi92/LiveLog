module UserDecorator
  IMAGE_PX_BY_SIZE = { small: 64, medium: 192, large: 384 }

  def display_name
    logged_in? ? name_with_handle : handle
  end

  def inst_to_count
    playings.published.count_insts
  end

  def instruments
    inst_to_count.to_h.keys
  end

  def avatar_url(size)
    px = IMAGE_PX_BY_SIZE[size]
    if avatar.attached?
      url_for avatar.variant(resize: "#{px}x#{px}")
    elsif email.present? && activated?
      hash = Digest::MD5.hexdigest(email)
      "https://www.gravatar.com/avatar/#{hash}?s=#{px}&d=mm"
    else
      "https://www.gravatar.com/avatar/?s=#{px}&d=mm&f=t"
    end
  end

  def avatar_image_tag(size = :small, options = {})
    options[:class] = options[:class].nil? ? "rounded-circle #{size}" : options[:class] + " rounded-circle #{size}"
    image_tag avatar_url(size), options
  end

  def related_playings
    Playing.where(song_id: songs.published.pluck('songs.id'))
  end

  def collaborator_to_count
    related_playings.where.not(user_id: id).group(:user_id).order(count: :desc).count
  end

  def collaborators
    User.where(id: collaborator_to_count.to_h.keys.take(10)).with_attached_avatar
  end

  def delete_link(html_options)
    link_to_delete self, html_options.merge(data: { confirm: t('views.application.delete_confirm') })
  end

  def invite_link(html_options)
    link_to icon('fas', 'envelope') + ' ' + t('views.users.invite'), new_user_activation_path(self), html_options
  end

  def deactivate_link(html_options)
    link_to 'アカウントを無効にする', user_activation_path(self), html_options.merge(method: :delete, data: { confirm: '本当にアカウントを無効にしますか？' })
  end

  def create_admin_link(html_options)
    link_to '管理者にする', user_admin_path(self), html_options.merge(method: :post, data: { confirm: '本当に管理者にしますか？' })
  end

  def delete_admin_link(html_options)
    link_to '管理者権限を無効にする', user_admin_path(self), html_options.merge(method: :delete, data: { confirm: '本当に管理者権限を無効にしますか？' })
  end
end
