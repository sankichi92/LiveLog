module ApplicationHelper

  def full_title(page_title = '')
    base_title = 'LiveLog'
    page_title.empty? ? base_title : page_title + ' - ' + base_title
  end

  def feedback_url(user)
    uri = URI.parse('https://docs.google.com/forms/d/e/1FAIpQLSfhLHpL54pH_Oh5u7bLN31wGmJdqVUQ8WFSlyOF0A3DEJDzew/viewform?usp=pp_url')
    query = URI.encode_www_form(
      'entry.1322390882' => user.joined,
      'entry.1102506699' => "#{user.last_name} #{user.first_name}",
      'entry.724954072' => user.email,
    )
    uri.query += '&' + query
    uri.to_s
  end

  def link_to_edit(options, html_options)
    link_to icon('fas', 'edit') + ' ' + t('views.application.edit'), options, html_options
  end

  def link_to_delete(options, html_options)
    link_to icon('fas', 'trash') + ' ' + t('views.application.delete'), options, html_options.merge(method: :delete)
  end
end
