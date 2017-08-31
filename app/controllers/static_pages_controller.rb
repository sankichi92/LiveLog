# frozen_string_literal: true

require 'open-uri'

class StaticPagesController < ApplicationController
  def home
    return unless logged_in?
    today = Time.zone.today
    @song = Rails.cache.fetch("static_pages/home/pickup_#{today}", expires_in: 1.day) do
      songs = Song.where.not(youtube_id: '', status: :secret)
      songs.offset(rand(songs.count)).first
    end
    @info = fetch_place(today)
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

  def fetch_place(date)
    Rails.cache.fetch("static_pages/fetch_place/#{date}", expires_in: 1.day) do
      top_doc = Nokogiri::HTML(open('http://s.maho.jp/homepage/7cffb2d25ef87ff8/'))
      month_url = top_doc.css("a:contains('#{date.month}月活動予定')").attribute('href').value
      month_doc = Nokogiri::HTML(open(month_url))
      day_match = month_doc.at_css('#mahoimain').to_s.match(/\n#{date.day}（[月火水木金土日]）(?<place>[@×].*)<br>/)
      { place: day_match[:place], url: month_url }
    end
  rescue => e
    logger.error e.message
    nil
  end
end
