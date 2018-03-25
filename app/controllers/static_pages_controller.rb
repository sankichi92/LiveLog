class StaticPagesController < ApplicationController
  before_action :logged_in_user, only: :donation

  def home
    @song = Song.includes(playings: :user).pickup
    @lives = Live.published.order_by_date.limit(5)
  end

  def donate; end
end
