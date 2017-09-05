class Api::V1::PickupsController < Api::V1::ApplicationController

  def show
    date = params[:id].in_time_zone || Time.zone.today
    @song = Rails.cache.fetch("pickup/#{date}", expires_in: 1.day) { Song.pickup(date) }
    render 'api/v1/songs/show'
  end
end
