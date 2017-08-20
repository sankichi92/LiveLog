module ApplicationHelper

  def full_title(page_title = '')
    base_title = 'LiveLog'
    page_title.empty? ? base_title : page_title + ' - ' + base_title
  end

  def nendo(date = Time.zone.today)
    date.mon < 4 ? date.year - 1 : date.year
  end

  def glyphicon(name)
    %(<span class="glyphicon glyphicon-#{name}" aria-hidden="true"></span> ).html_safe
  end

  def feedback_url(user)
    uri = URI.parse('https://docs.google.com/forms/d/e/1FAIpQLSfhLHpL54pH_Oh5u7bLN31wGmJdqVUQ8WFSlyOF0A3DEJDzew/viewform?usp=pp_url')
    query = URI.encode_www_form(
      'entry.1322390882' => user.joined,
      'entry.1102506699' => "#{user.last_name} #{user.first_name}",
      'entry.724954072' => user.email
    )
    uri.query += '&' + query
    uri.to_s
  end
end
