module MemberDecorator
  IMAGE_PX_BY_SIZE = { small: 16 * 2 * 2, medium: 16 * 6 * 2, large: 16 * 12 * 2 }.freeze

  def avatar_url(size = :small)
    px = IMAGE_PX_BY_SIZE[size]
    if avatar
      avatar.image_url(px)
    else
      "https://www.gravatar.com/avatar/#{user&.activated? ? Digest::MD5.hexdigest(user.email) : ''}?s=#{px}&d=mm"
    end
  end

  def avatar_image_tag(size = :small, options = {})
    options[:class] = [options[:class], 'rounded-circle', size].compact.join(' ')
    image_tag avatar_url(size), options
  end
end
