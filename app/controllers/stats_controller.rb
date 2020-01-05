class StatsController < ApplicationController
  before_action :current_year

  def show(year)
    @stats = Stats.new(year.to_i)
    raise ActionController::RoutingError, 'Not Found' if @stats.invalid?
  end

  private

  def current_year(year)
    redirect_to stat_url(Live.published.years.first) if year == 'current'
  end
end
