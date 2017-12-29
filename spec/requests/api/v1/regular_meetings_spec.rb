require 'rails_helper'

RSpec.describe 'Api::V1::RegularMeetings', type: :request do

  describe 'GET /api/v1/regular_meetings/:id' do
    let(:date) { Time.zone.today }
    let(:expected_body) do
      {
        date: date.to_s,
        place: nil,
        note: nil,
        place_url: nil
      }
    end

    it 'responds with valid status and json' do
      get api_v1_regular_meeting_path(date.strftime('%Y-%m-%d'))
      expect(response).to have_http_status(200)
      expect(response.body).to be_json_as(expected_body)
    end
  end
end
