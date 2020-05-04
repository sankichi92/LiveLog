module MemberDecorator
  def avatar_url(size = :small)
    if avatar
      avatar.image_url(size: size)
    else
      "https://www.gravatar.com/avatar/#{user&.activated? ? Digest::MD5.hexdigest(user.email) : ''}?s=#{Avatar::SIZE_TO_PIXEL[size]}&d=mm"
    end
  end

  def avatar_image_tag(size = :small, options = {})
    options[:class] = [options[:class], 'rounded-circle', size].compact.join(' ')
    image_tag avatar_url(size), options
  end
end
