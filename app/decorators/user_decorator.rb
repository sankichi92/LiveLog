module UserDecorator
  IMAGE_PX_BY_SIZE = { small: 64, medium: 192, large: 384 }.freeze

  def instruments
    playings.published.count_insts.to_h.keys
  end

  def avatar_source(size)
    px = IMAGE_PX_BY_SIZE[size]
    if avatar.attached? && avatar.variable?
      avatar.variant(auto_orient: true, combine_options: { thumbnail: "#{px}x#{px}^", gravity: 'center', crop: "#{px}x#{px}+0+0" })
    elsif email.present?
      hash = Digest::MD5.hexdigest(email)
      "https://www.gravatar.com/avatar/#{hash}?s=#{px}&d=mm"
    else
      "https://www.gravatar.com/avatar/?s=#{px}&d=mm&f=t"
    end
  end

  def avatar_image_tag(size = :small, options = {})
    options[:class] = options[:class].nil? ? "rounded-circle #{size}" : options[:class] + " rounded-circle #{size}"
    image_tag avatar_source(size), options
  end

  def collaborated_playings
    Playing.where(song_id: songs.published.pluck('songs.id')).where.not(user_id: id)
  end

  def collaborators_count
    collaborated_playings.distinct.count(:user_id)
  end

  def top_10_collaborators
    collaborators = collaborated_playings.group(:member).order(count_all: :desc).limit(10).count.keys
    ActiveRecord::Associations::Preloader.new.preload(collaborators, 'avatar_attachment': :blob)
    collaborators.tap { |collaborator| ActiveDecorator::Decorator.instance.decorate(collaborator) }
  end

  def edit_link(html_options)
    link_to_edit edit_user_path(self), html_options
  end

  def delete_link(html_options)
    link_to_delete self, html_options.merge(data: { confirm: '本当に削除しますか？' })
  end

  def create_admin_link(html_options)
    link_to '管理者にする', user_admin_path(self), html_options.merge(method: :post, data: { confirm: '本当に管理者にしますか？' })
  end

  def delete_admin_link(html_options)
    link_to '管理者権限を無効にする', user_admin_path(self), html_options.merge(method: :delete, data: { confirm: '本当に管理者権限を無効にしますか？' })
  end
end
