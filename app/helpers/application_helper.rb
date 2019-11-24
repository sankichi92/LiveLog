module ApplicationHelper
  def link_to_edit(options, html_options)
    link_to icon('fas', 'edit') + ' ' + '編集する', options, html_options
  end

  def link_to_delete(options, html_options)
    link_to icon('fas', 'trash') + ' ' + '削除する', options, html_options.merge(method: :delete)
  end
end
