class Api::V1::RegularMeetingsController < Api::V1::ApplicationController
  def show
    # Should return :not_found but Android app may crash
    render json: {
      date: Time.zone.today,
      place: nil,
      note: nil,
      place_url: nil
    }
  end
end
