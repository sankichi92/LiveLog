module ApplicationHelper

  def full_title(page_title = '')
    base_title = 'LiveLog'
    if page_title.empty?
      base_title
    else
      page_title + ' - ' + base_title
    end
  end

  def nendo(date = Date.today)
    if date.mon < 4
      date.year - 1
    else
      date.year
    end
  end

  def glyphicon(name, klass = '')
    %(<span class="glyphicon glyphicon-#{name} #{klass}" aria-hidden="true"></span> ).html_safe
  end

  def feedback_url(user)
    uri = URI.parse('https://docs.google.com/forms/d/e/1FAIpQLSfhLHpL54pH_Oh5u7bLN31wGmJdqVUQ8WFSlyOF0A3DEJDzew/viewform?usp=pp_url')
    query = URI.encode_www_form(
      :'entry.1322390882' => user.joined,
      :'entry.1102506699' => "#{user.last_name} #{user.first_name}",
      :'entry.724954072' => user.email
    )
    uri.query += '&' + query
    uri.to_s
  end
end
