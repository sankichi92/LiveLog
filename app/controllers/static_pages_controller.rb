# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def home
    today = Time.zone.today
    @place = fetch_place(today) if logged_in?
  end

  def stats
    range = if params[:y] && Live.years.include?(params[:y].to_i)
              start = Date.new(params[:y].to_i, 4, 1)
              (start...start + 1.year)
            else
              (1.year.ago..Time.zone.today)
            end

    @songs = Song.includes(:live).where('lives.date' => range)
    @playings = Playing.includes(song: :live).where('lives.date' => range)
  end

  private

  def fetch_place(day)
    Rails.cache.fetch("/place/#{day}", expires_in: 1.day) do
      begin
        place_index_doc = Nokogiri::HTML(open('http://s.maho.jp/homepage/7cffb2d25ef87ff8/'))
        place_detail_url = place_index_doc.css("a:contains('#{day.month}月活動予定')").attribute('href').value
        place_detail_doc = Nokogiri::HTML(open(place_detail_url))
        regex = /\n#{day.day}（[月火水木金土日]）(?<place>[@×].*)<br>/
        match_data = place_detail_doc.at_css('#mahoimain').to_s.match(regex)
        match_data[:place]
      rescue => e
        logger.error e.message
        return
      end
    end
  end
end
