class StaticPagesController < ApplicationController
  before_action :logged_in_user, only: :donation

  def home
    today = Time.zone.today
    @song = Rails.cache.fetch("pickup/#{today}", expires_in: 1.day) { Song.includes(playings: :user).pickup(today) }
    @lives = Live.includes(:songs).published.order_by_date.limit(5)
  end

  def donate; end
end
