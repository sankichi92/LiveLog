module UserDecorator
  def status_badge
    case
    when activated? && admin?
      content_tag(:span, '管理者', class: 'badge badge-danger')
    when activated?
      content_tag(:span, 'ログイン済み', class: 'badge badge-primary')
    else
      content_tag(:span, '招待済み', class: 'badge badge-success')
    end
  end
end
