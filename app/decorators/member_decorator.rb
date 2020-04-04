module MemberDecorator
  IMAGE_PX_BY_SIZE = { small: 64, medium: 192, large: 384 }.freeze

  def avatar_url(size = :small)
    px = IMAGE_PX_BY_SIZE[size]
    if avatar.attached? && avatar.variable?
      avatar.variant(resize_to_fill: [px, px])
    elsif user&.activated?
      "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email)}?s=#{px}&d=mm"
    else
      "https://www.gravatar.com/avatar/?s=#{px}&d=mm&f=t"
    end
  end

  def avatar_image_tag(size = :small, options = {})
    options[:class] = [options[:class], 'rounded-circle', size].compact.join(' ')
    image_tag avatar_url(size), options
  end
end
