# frozen_string_literal: true

require 'open-uri'

class RegularMeeting
  REGULAR_MEETINGS_INFO_URL = 'http://s.maho.jp/homepage/7cffb2d25ef87ff8/'

  attr_reader :date, :place, :note, :place_url

  def initialize(date = Time.zone.today)
    @date = date
    @place_url = fetch_detail_url
    @place, @note = fetch_place if place_url.present?
  end

  private

  def fetch_detail_url
    doc = Nokogiri::HTML(open(REGULAR_MEETINGS_INFO_URL))
    url = doc.css("a:contains('#{date.month}月活動予定')").attribute('href').value
    if url.start_with?('http')
      return url
    elsif url.start_with?('//')
      return 'https:' + url
    elsif url.start_with?('/')
      return 'http://s.hamo.jp' + url
    else
      return REGULAR_MEETINGS_INFO_URL + url
    end
  rescue => e
    Rails.logger.error e.message
    nil
  end

  def fetch_place
    doc = Nokogiri::HTML(open(place_url))
    match = doc.at_css('#mahoimain').to_s.match(/\n#{date.day}（[月火水木金土日]）(?<place>[@×][^（<\n]*)(?:（(?<note>.+)）)?.*<br>/)
    [match[:place], match[:note]]
  rescue => e
    Rails.logger.error e.message
    nil
  end
end
