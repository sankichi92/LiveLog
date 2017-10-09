module UsersHelper

  def link_to_user(user, logged_in, options, &block)
    if logged_in || user.public?
      link_to user, options, &block
    else
      content_tag(:button, options.merge(disabled: true), &block)
    end
  end
end
