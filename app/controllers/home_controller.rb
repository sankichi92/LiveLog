class HomeController < ApplicationController
  def show
    @song = Song.includes(plays: :member).pickup
    @lives = Live.published.newest_order.limit(5)
  end
end
