class Api::V1::LivesController < Api::V1::ApplicationController

  def index
    @lives = Live.visible.order_by_date
  end

  def show
    @live = Live.includes(:songs).find(params[:id])
  end
end
