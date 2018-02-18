class StaticPagesController < ApplicationController
  def home
    today = Time.zone.today
    @song = Rails.cache.fetch("pickup/#{today}", expires_in: 1.day) { Song.includes(playings: :user).pickup(today) }
    @lives = Live.includes(:songs).published.order_by_date.where('date >= ?', 1.month.ago)
  end
end
