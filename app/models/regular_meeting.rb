# frozen_string_literal: true

require 'open-uri'

class RegularMeeting
  REGULAR_MEETINGS_INFO_URI = 'http://s.maho.jp/homepage/7cffb2d25ef87ff8/'

  attr_reader :date, :place, :place_uri

  def initialize(date = Time.zone.today)
    @date = date
    @place_uri = fetch_detail_uri
    @place = fetch_place if place_uri.present?
  end

  private

  def fetch_detail_uri
    doc = Nokogiri::HTML(open(REGULAR_MEETINGS_INFO_URI))
    doc.css("a:contains('#{date.month}月活動予定')").attribute('href').value
  rescue => e
    logger.error e.message
    nil
  end

  def fetch_place
    doc = Nokogiri::HTML(open(place_uri))
    match = doc.at_css('#mahoimain').to_s.match(/\n#{date.day}（[月火水木金土日]）(?<place>[@×].*)<br>/)
    match[:place]
  rescue => e
    logger.error e.message
    nil
  end
end
