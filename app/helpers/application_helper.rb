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
end
