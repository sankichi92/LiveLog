class Api::V1::RegularMeetingsController < Api::V1::ApplicationController

  def show
    date = params[:id].in_time_zone || Time.zone.today
    @regular_meeting = Rails.cache.fetch("regular_meeting/#{date}", expires_in: 1.day) do
      RegularMeeting.new(date)
    end
  end
end
