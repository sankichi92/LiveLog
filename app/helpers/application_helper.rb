module ApplicationHelper

  def full_title(page_title = '')
    base_title = 'LiveLog'
    if page_title.empty?
      base_title
    else
      page_title + ' | ' + base_title
    end
  end

  def nendo(date = Date.today)
    if date.mon < 4
      date.year - 1
    else
      date.year
    end
  end

  def nendo_range(year = Date.today.year)
    start = Date.new(year, 4)
    (start...start + 1.year)
  end

  def glyphicon(name, clazz = '')
    %(<span class="glyphicon glyphicon-#{name} #{clazz}" aria-hidden="true"></span> ).html_safe
  end
end
