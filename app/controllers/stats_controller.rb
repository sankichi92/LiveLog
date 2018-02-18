class StatsController < ApplicationController
  before_action :current_year

  def show
    @stats = Stats.new(params[:year].to_i)
    raise ActionController::RoutingError, 'Not Found' if @stats.invalid?
  end

  private

  def current_year
    redirect_to stat_url(Live.years.first) if params[:year] == 'current'
  end
end
