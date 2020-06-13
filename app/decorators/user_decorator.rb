module UserDecorator
  def status_badge
    case
    when admin
      tag.span('管理者', class: 'badge badge-danger')
    when activated?
      tag.span('ログイン済み', class: 'badge badge-primary')
    else
      tag.span('招待済み', class: 'badge badge-success')
    end
  end
end
