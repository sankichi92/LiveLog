class StaticPagesController < ApplicationController
  def home
    today = Time.zone.today
    @song = Rails.cache.fetch("pickup/#{today}", expires_in: 1.day) { Song.includes(playings: :user).pickup(today) }
    @lives = Live.includes(:songs).published.order_by_date.where('date >= ?', 1.month.ago)
    return unless logged_in?
    @regular_meeting = Rails.cache.fetch("regular_meeting/#{today}", expires_in: 1.day) do
      RegularMeeting.new(today)
    end
  end

  def stats
    @year = params[:y]&.to_i
    @date_range = if Live.years.include?(@year)
                    start = Date.new(@year, 4, 1)
                    start...start + 1.year
                  else
                    @year = nil
                    1.year.ago.to_date..Time.zone.today
                  end
    @songs = Song.published.includes(:live).where('lives.date': @date_range)
    @playings = Playing.published.includes(song: :live).where('lives.date': @date_range)
  end
end
