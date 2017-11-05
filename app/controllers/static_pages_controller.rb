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
    @date_range = if params[:y] && Live.years.include?(params[:y]&.to_i)
                    start = Date.new(params[:y].to_i, 4, 1)
                    start...start + 1.year
                  else
                    1.year.ago.to_date..Time.zone.today
                  end
    @songs = Song.published.includes(:live).where('lives.date': @date_range)
    @playings = Playing.published.includes(song: :live).where('lives.date': @date_range)
  end
end
