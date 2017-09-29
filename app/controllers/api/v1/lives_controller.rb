class Api::V1::LivesController < Api::V1::ApplicationController

  def index
    limit = params[:limit].to_i
    @lives = if limit.positive?
               Live.performed.order_by_date.limit(limit)
             else
               Live.performed.order_by_date
             end
  end

  def show
    @live = Live.includes(:songs).find(params[:id])
  end
end
