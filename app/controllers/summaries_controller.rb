class SummariesController < ApplicationController
  before_action :require_valid_year, only: :show

  def index
    latest_year = Live.published.maximum(:date).nendo
    redirect_to summary_path(latest_year)
  end

  def show(year)
    @summary = Summary::Builder.new(year.to_i).build
  end

  private

  # region Filters

  def require_valid_year(year)
    raise ActionController::RoutingError, "There are no lives in #{year}" unless Live.published.nendo(year.to_i).exists?
  end

  # endregion
end
