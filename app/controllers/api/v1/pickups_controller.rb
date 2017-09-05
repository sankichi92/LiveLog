class Api::V1::PickupsController < Api::V1::ApplicationController

  def show
    date = params[:id].in_time_zone.to_date || Time.zone.today
    @song = Song.pickup(date)
    render 'api/v1/songs/show'
  end
end
