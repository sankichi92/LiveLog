class StaticPagesController < ApplicationController
  before_action :require_current_user, only: :donation

  def home
    @song = Song.includes(playings: :member).pickup
    @lives = Live.published.order_by_date.limit(5)
  end

  def donation; end

  def privacy; end
end
